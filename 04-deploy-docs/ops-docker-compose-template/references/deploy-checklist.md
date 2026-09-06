# Docker Compose 部署 Checklist

## 部署前

### 环境准备

- [ ] Docker / docker-compose 已安装（version 验证：`docker compose version`）
- [ ] 服务器资源充足（CPU/内存/磁盘）
- [ ] 端口未冲突（`ss -tlnp` 检查）
- [ ] 目录已创建并有正确权限

```bash
# 创建部署目录
mkdir -p /opt/<project>/{config,data,logs}
chown -R <user>:<group> /opt/<project>
```

### 配置检查

- [ ] `docker-compose.yml` 已通过 `docker compose config -q` 验证
- [ ] `.env.example` 已就位
- [ ] 镜像版本已固定（不用 `latest`）
- [ ] 敏感信息走 `.env`（不在 yml 中硬编码密码）
- [ ] `.gitignore` 排除 `.env`、本地 data/volumes

```bash
# 验证 yml 语法
docker compose config -q

# 检查是否有 latest
grep -n "latest" docker-compose.yml
```

### 网络规划

- [ ] 按层划分网络（edge/backend/monitoring）
- [ ] 内部服务用 `internal: true`
- [ ] DB/Cache 端口绑 `127.0.0.1`
- [ ] 跨主机通信已规划（用 host 网络/Overlay）

---

## 部署中

### 启动顺序

\`\`\`bash
# 1. 先拉镜像
docker compose pull

# 2. 后台启动
docker compose up -d

# 3. 看启动日志
docker compose logs -f --tail=100

# 4. 验证服务状态
docker compose ps

# 5. 检查健康检查
docker inspect --format='{{.State.Health.Status}}' <container>
\`\`\`

### 资源监控

\`\`\`bash
# 看资源占用
docker stats

# 看具体容器
docker stats <container>
\`\`\`

### 关键检查点

- [ ] 所有服务 healthcheck 通过
- [ ] 日志无启动报错
- [ ] 端口监听正常（`ss -tlnp`）
- [ ] 依赖服务（DB/Cache）连接正常
- [ ] 关键目录可写（上传、缓存）

---

## 部署后

### 立即验证（5-15 分钟）

- [ ] 业务功能验证（核心接口）
- [ ] 数据库连接验证
- [ ] 缓存连接验证
- [ ] 文件读写验证
- [ ] 健康检查端点验证

\`\`\`bash
# 健康检查
curl -I http://localhost:<port>/health

# 数据库连接
docker compose exec mysql mysql -u root -p -e "SHOW DATABASES;"

# Redis 连接
docker compose exec redis redis-cli -a <password> PING
\`\`\`

### 持续观察（1-24 小时）

- [ ] 监控指标无异常
- [ ] 日志无新报错
- [ ] 资源使用稳定
- [ ] 用户无新投诉
- [ ] 上游下游依赖正常

### 备份确认

- [ ] 数据卷已加入备份策略
- [ ] 配置文件已 git 化
- [ ] 部署脚本已记录

---

## 回滚预案

### 触发回滚条件（满足任一立即回滚）

- ❌ 启动失败且无法快速修复
- ❌ 健康检查持续失败
- ❌ 业务功能异常
- ❌ 错误率显著上升
- ❌ 资源占用异常

### 回滚步骤

\`\`\`bash
# 1. 停止当前服务
docker compose down

# 2. 恢复上一版本配置
git checkout <previous-tag> -- docker-compose.yml .env.example

# 3. 用旧镜像启动
docker compose up -d

# 4. 验证
docker compose ps
curl -I http://localhost:<port>/health
\`\`\`

### 回滚失败的应急

- [ ] 上一版本镜像仍在
- [ ] 数据卷未损坏
- [ ] 备份的 .env 文件可用

---

## 常见问题速查

| 问题 | 原因 | 解决 |
|---|---|---|
| 端口冲突 | 端口被其他服务占用 | `ss -tlnp` 查，改端口 |
| 镜像拉取失败 | 网络问题/镜像不存在 | 检查网络/镜像 tag |
| 容器启动后立即退出 | 启动命令错/配置错 | `docker compose logs` |
| healthcheck 失败 | 服务没起来/健康端点错 | 进容器手动 curl |
| 数据卷丢失 | 用匿名卷 | 改用命名卷 |
| 网络不通 | 子网冲突/防火墙 | 检查网络规划 |
| 资源限制过严 | 内存/CPU 不够 | 调整 deploy.resources |
| 时区不对 | 容器默认 UTC | 设置 `TZ=Asia/Shanghai` |
| 中文乱码 | locale 缺失 | 加 `LANG=C.UTF-8` |
| 日志太多占满磁盘 | 没限制日志大小 | 加 logging 配置 |

---

## 安全检查清单

- [ ] 所有 image 用官方/可信私有仓库
- [ ] 不用 `:latest` 标签
- [ ] 敏感端口绑 `127.0.0.1`
- [ ] 不用 root 用户运行（设置 `user:`）
- [ ] 启用 read-only root filesystem（必要时）
- [ ] 不用特权模式（不加 `privileged: true`）
- [ ] 限制 capabilities（`cap_drop: [ALL]`）
- [ ] 不挂载敏感目录（`/`, `/etc`, `/var/run/docker.sock`）
- [ ] 环境变量不含明文密码（用 secrets）
- [ ] 网络隔离（敏感服务用 internal 网络）

---

## 资源规划参考

### 按服务类型估算

| 服务类型 | CPU | 内存 | 磁盘 |
|---|---|---|---|
| Nginx/反向代理 | 0.5 | 256M | 1G |
| Node.js 应用 | 1.0 | 512M-2G | 5-20G |
| Python (Django) | 1.0 | 512M-2G | 5-20G |
| MySQL | 2-4 | 4-16G | 50-500G |
| Redis | 1-2 | 2-8G | 10-100G |
| Elasticsearch | 2-4 | 4-16G | 100G+ |
| Prometheus | 1-2 | 2-8G | 50-200G |
| Grafana | 0.5 | 512M | 1G |

### 容量规划原则

- 起步资源 = 预期平均负载 × 1.5
- 上限资源 = 预期峰值 × 1.2
- 预留 20% 系统资源

---

## 维护窗口

| 操作 | 推荐时间 |
|---|---|
| 大版本升级 | 凌晨 2-6 点 |
| DB 迁移 | 凌晨 0-6 点 |
| 配置变更 | 业务低峰 |
| 日志切割测试 | 任意 |
| 安全补丁 | 24 小时内尽快 |

---

## 必做事项（首次部署）

- [ ] 备份策略已制定
- [ ] 监控告警已配置
- [ ] 日志收集已对接
- [ ] 文档已写（部署文档、Runbook）
- [ ] 应急联系人已确认
- [ ] 回滚方案已演练