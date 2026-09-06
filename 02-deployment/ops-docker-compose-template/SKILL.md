---
name: ops-docker-compose-template
description: docker-compose 部署方案的固定模板库。当用户需要编写/部署/修改 docker-compose.yml 时使用。基于「通用模板 + 场景化组合」思路，覆盖 Web/API/DB/Cache/中间件等常见服务的标准部署模板，以及 docker-compose 编写规范。
agent_created: true
---

# Docker Compose 部署模板

## 何时使用

触发场景（满足任一即调用）：
- 需要编写新的 docker-compose.yml
- 需要部署新服务（Web/DB/Cache/中间件）
- 现有 compose 文件不规范，需要改造
- 关键词：「docker-compose」「docker compose」「容器化部署」「写 compose」「yml 模板」「编排」「stack 部署」

---

## 核心原则

1. **版本控制**：所有 compose 文件必须 git 化
2. **环境隔离**：dev / test / staging / prod 用不同 .env
3. **可重启**：服务异常自动恢复（restart: always / unless-stopped）
4. **资源限制**：CPU/内存 显式声明，避免相互抢占
5. **健康检查**：所有长服务必须有 healthcheck
6. **数据持久化**：所有数据卷必须显式声明（避免匿名卷）
7. **网络规划**：固定网段，不用默认 bridge
8. **日志规范**：JSON 格式 + 限制大小 + 驱动统一

---

## 基础模板（最简版）

\`\`\`yaml
version: '3.8'

services:
  web:
    image: nginx:1.25-alpine
    container_name: web
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf:/etc/nginx/conf.d:ro
      - ./nginx/html:/usr/share/nginx/html:ro
      - web_logs:/var/log/nginx
    networks:
      - frontend
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost/"]
      interval: 30s
      timeout: 5s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 128M
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  web_logs:

networks:
  frontend:
    driver: bridge
\`\`\`

---

## 场景模板库

### 模板 1：Web 应用（Nginx + App）

\`\`\`yaml
version: '3.8'

services:
  nginx:
    image: nginx:1.25-alpine
    container_name: ${PROJECT_NAME}_nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./nginx/certs:/etc/nginx/certs:ro
      - ./nginx/html:/usr/share/nginx/html:ro
    depends_on:
      app:
        condition: service_healthy
    networks:
      - edge
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost/health"]
      interval: 30s
      timeout: 5s
      retries: 3
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"

  app:
    image: ${APP_IMAGE:-myapp:latest}
    container_name: ${PROJECT_NAME}_app
    restart: unless-stopped
    environment:
      - TZ=Asia/Shanghai
      - NODE_ENV=${APP_ENV:-production}
    volumes:
      - ./app/uploads:/app/uploads
      - ./app/logs:/app/logs
    networks:
      - edge
      - backend
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G

networks:
  edge:
    driver: bridge
  backend:
    driver: bridge
    internal: false
\`\`\`

### 模板 2：MySQL

\`\`\`yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: ${PROJECT_NAME}_mysql
    restart: unless-stopped
    ports:
      - "127.0.0.1:3306:3306"     # ⚠️ 生产不要暴露 0.0.0.0
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:?required}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD:?required}
      TZ: Asia/Shanghai
    volumes:
      - mysql_data:/var/lib/mysql
      - ./mysql/conf:/etc/mysql/conf.d:ro
      - ./mysql/init:/docker-entrypoint-initdb.d:ro
    command:
      - --character-set-server=utf8mb4
      - --collation-server=utf8mb4_unicode_ci
      - --default-authentication-plugin=mysql_native_password
      - --max-connections=500
      - --innodb-buffer-pool-size=1G
    networks:
      - backend
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${MYSQL_ROOT_PASSWORD}"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
    deploy:
      resources:
        limits:
          cpus: '4.0'
          memory: 4G

volumes:
  mysql_data:
    name: ${PROJECT_NAME}_mysql_data

networks:
  backend:
    driver: bridge
\`\`\`

### 模板 3：Redis

\`\`\`yaml
version: '3.8'

services:
  redis:
    image: redis:7.2-alpine
    container_name: ${PROJECT_NAME}_redis
    restart: unless-stopped
    ports:
      - "127.0.0.1:6379:6379"
    command:
      - redis-server
      - --requirepass ${REDIS_PASSWORD:?required}
      - --maxmemory 2gb
      - --maxmemory-policy allkeys-lru
      - --appendonly yes
      - --appendfsync everysec
      - --save 900 1
      - --save 300 10
    volumes:
      - redis_data:/data
      - ./redis/redis.conf:/usr/local/etc/redis/redis.conf:ro
    networks:
      - backend
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 30s
      timeout: 5s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 3G

volumes:
  redis_data:
    name: ${PROJECT_NAME}_redis_data

networks:
  backend:
    driver: bridge
\`\`\`

### 模板 4：DVAdmin / Django 应用栈（web + celery + mysql + redis）

\`\`\`yaml
version: '3.8'

services:
  web:
    image: ${WEB_IMAGE:-dvadmin3-web:latest}
    container_name: ${PROJECT_NAME}_web
    restart: unless-stopped
    ports:
      - "${WEB_PORT:-8080}:8080"
    env_file:
      - .env
    volumes:
      - ./web/logs:/app/logs
      - ./web/media:/app/media
      - ./web/static:/app/static
    depends_on:
      mysql:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - edge
      - backend
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/init/settings/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  celery_worker:
    image: ${CELERY_IMAGE:-dvadmin3-celery:latest}
    container_name: ${PROJECT_NAME}_celery_worker
    restart: unless-stopped
    env_file:
      - .env
    command: celery -A application worker -l info
    depends_on:
      - mysql
      - redis
    networks:
      - backend
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G

  celery_beat:
    image: ${CELERY_IMAGE:-dvadmin3-celery:latest}
    container_name: ${PROJECT_NAME}_celery_beat
    restart: unless-stopped
    env_file:
      - .env
    command: celery -A application beat -l info --scheduler django_celery_beat.schedulers:DatabaseScheduler
    depends_on:
      - mysql
      - redis
    networks:
      - backend

  mysql:
    image: mysql:8.0
    # ... 同模板 2
    networks:
      - backend

  redis:
    image: redis:7.2-alpine
    # ... 同模板 3
    networks:
      - backend

networks:
  edge:
  backend:
\`\`\`

### 模板 5：Prometheus + Grafana（监控栈）

\`\`\`yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:v2.50.0
    container_name: prometheus
    restart: unless-stopped
    ports:
      - "127.0.0.1:9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus/rules:/etc/prometheus/rules:ro
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'
      - '--web.enable-lifecycle'
    networks:
      - monitoring
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:9090/-/healthy"]
      interval: 30s
      timeout: 5s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 4G

  grafana:
    image: grafana/grafana:10.4.0
    container_name: grafana
    restart: unless-stopped
    ports:
      - "127.0.0.1:3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GF_ADMIN_PASSWORD:?required}
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_SERVER_DOMAIN=${GF_DOMAIN:-localhost}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
      - ./grafana/dashboards:/var/lib/grafana/dashboards:ro
    depends_on:
      - prometheus
    networks:
      - monitoring
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 5s
      retries: 3

volumes:
  prometheus_data:
    name: monitoring_prometheus_data
  grafana_data:
    name: monitoring_grafana_data

networks:
  monitoring:
    driver: bridge
\`\`\`

---

## 编写规范 checklist

部署前对照检查：

- [ ] **版本固定**：所有 `image:` 用具体 tag，不用 `latest`
- [ ] **重启策略**：所有长服务有 `restart: unless-stopped`
- [ ] **健康检查**：所有长服务有 `healthcheck`
- [ ] **资源限制**：所有服务有 `deploy.resources.limits`
- [ ] **数据持久化**：数据卷用命名卷，不用匿名卷
- [ ] **网络隔离**：内部服务用 `internal: true` 网络
- [ ] **端口限制**：敏感端口（DB/Cache）绑 `127.0.0.1`
- [ ] **环境变量**：敏感信息走 `.env` + `${VAR:?required}`
- [ ] **时区统一**：所有服务 `TZ=Asia/Shanghai`
- [ ] **日志规范**：JSON + 大小限制
- [ ] **依赖顺序**：`depends_on.condition: service_healthy`
- [ ] **镜像来源**：只用官方镜像或私有仓库，不用可疑第三方
- [ ] **.env 文件**：`.gitignore` 中排除，模板另存 `.env.example`

---

## .env 文件模板

\`\`\`bash
# .env.example（提交到 git）

# 项目标识
PROJECT_NAME=myapp

# 应用配置
APP_ENV=production
APP_IMAGE=registry.xxx.com/myapp/web:v1.0.0
CELERY_IMAGE=registry.xxx.com/myapp/celery:v1.0.0
WEB_PORT=8080

# 数据库
MYSQL_ROOT_PASSWORD=change_me
MYSQL_DATABASE=myapp
MYSQL_USER=myapp
MYSQL_PASSWORD=change_me

# Redis
REDIS_PASSWORD=change_me

# Grafana
GF_ADMIN_PASSWORD=change_me
GF_DOMAIN=grafana.example.com
\`\`\`

---

## 常用命令

\`\`\`bash
# 启动
docker compose up -d

# 查看状态
docker compose ps

# 查看资源占用
docker compose top

# 看日志
docker compose logs -f --tail=100 <service>

# 进入容器
docker compose exec <service> bash

# 优雅停止
docker compose down

# 完全清理（含卷，⚠️ 数据会丢）
docker compose down -v

# 拉取最新镜像并重建
docker compose pull
docker compose up -d

# 验证 compose 文件
docker compose config -q
\`\`\`

---

## 注意事项

| 红线 | 说明 |
|---|---|
| ❌ 不要 `image: xxx:latest` | 版本不可控 |
| ❌ 不要暴露 DB 端口到公网 | 用 `127.0.0.1` 绑定 |
| ❌ 不要在 compose 里写密码 | 用 .env 或 secrets |
| ❌ 不要所有服务跑一个网络 | 按层划分（edge/backend/monitoring） |
| ❌ 不要忘 `depends_on.condition: service_healthy` | 否则启动顺序不可控 |
| ⚠️ `restart: always` vs `unless-stopped` | 手动 stop 后，always 还会重启 |
| ✅ 端口尽量用 `127.0.0.1:` 前缀 | 减少公网暴露面 |
| ✅ 用命名卷，便于备份恢复 | 避免匿名卷难管理 |
| ✅ 大型部署用多个 compose 文件 | override 分层管理 |