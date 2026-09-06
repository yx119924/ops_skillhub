# 常见服务端口速查表

## 🌐 Web 服务

| 端口 | 服务 | 说明 |
|---|---|---|
| 80 | HTTP | Web 默认 |
| 443 | HTTPS | HTTPS 默认 |
| 8080 | HTTP Alt | Tomcat / 多服务常见 |
| 8443 | HTTPS Alt | HTTPS 备用 |
| 8000 | Django Dev | Django 开发服务器 |
| 3000 | Node.js | Express/Next.js 默认 |
| 5000 | Flask | Flask 默认 |
| 9000 | PHP-FPM | FastCGI |

## 🗄 数据库

| 端口 | 服务 | 说明 |
|---|---|---|
| 3306 | MySQL | MySQL/MariaDB |
| 5432 | PostgreSQL | PG |
| 6379 | Redis | Redis |
| 27017 | MongoDB | Mongo |
| 1521 | Oracle | Oracle DB |
| 1433 | SQL Server | MSSQL |
| 9200 | Elasticsearch | ES HTTP |
| 9300 | Elasticsearch | ES Transport |
| 5984 | CouchDB | CouchDB |

## 🔐 远程访问

| 端口 | 服务 | 说明 |
|---|---|---|
| 22 | SSH | Linux 远程登录 |
| 23 | Telnet | 不安全，禁用 |
| 3389 | RDP | Windows 远程桌面 |
| 5900 | VNC | VNC 远程桌面 |

## 📧 邮件

| 端口 | 服务 | 说明 |
|---|---|---|
| 25 | SMTP | 邮件发送 |
| 110 | POP3 | 邮件接收（旧） |
| 143 | IMAP | 邮件接收 |
| 465 | SMTP SSL | 邮件 SSL |
| 587 | SMTP TLS | 邮件 STARTTLS |
| 993 | IMAPS | IMAP SSL |
| 995 | POP3S | POP3 SSL |

## 📁 文件/存储

| 端口 | 服务 | 说明 |
|---|---|---|
| 21 | FTP | 文件传输（不加密） |
| 22 | SFTP | SSH 文件 |
| 69 | TFTP | 简单文件 |
| 2049 | NFS | 网络文件系统 |
| 137-139 | NetBIOS | Windows 共享（旧） |
| 445 | SMB | Windows 共享 |
| 111 | RPC | NFS 依赖 |

## 🏗 中间件

| 端口 | 服务 | 说明 |
|---|---|---|
| 5672 | RabbitMQ | AMQP |
| 15672 | RabbitMQ Mgmt | 管理界面 |
| 9092 | Kafka | Kafka Broker |
| 2181 | ZooKeeper | ZK |
| 5601 | Kibana | Kibana |
| 5044 | Logstash | Beats input |
| 8500 | Consul | Consul UI |
| 2379-2380 | etcd | etcd |

## 📊 监控告警

| 端口 | 服务 | 说明 |
|---|---|---|
| 9090 | Prometheus | Prom HTTP |
| 9093 | Alertmanager | AM HTTP |
| 3000 | Grafana | Grafana UI |
| 9100 | Node Exporter | node_exporter |
| 9104 | HAProxy Exporter | |
| 9115 | Nginx Exporter | |
| 9121 | MySQL Exporter | |
| 9182 | Redis Exporter | |
| 9280 | Webhook | Webhook |

## 🔧 CI/CD / DevOps

| 端口 | 服务 | 说明 |
|---|---|---|
| 8080 | Jenkins | Jenkins 默认 |
| 9000 | SonarQube | 代码质量 |
| 5000 | Docker Registry | 私有仓库 |
| 50000 | Jenkins Agent | JNLP |

## 🔌 网络代理

| 端口 | 服务 | 说明 |
|---|---|---|
| 80/443 | 反向代理 | Nginx/Haproxy |
| 1080 | SOCKS | 代理 |
| 3128 | Squid | HTTP 代理 |
| 8080 | HTTP Proxy | 代理 |
| 51820 | WireGuard | WireGuard 默认 |
| 51830 | WireGuard (custom) | 自定义端口 |

## 📡 容器/虚拟化

| 端口 | 服务 | 说明 |
|---|---|---|
| 2375 | Docker API | 未加密（禁用） |
| 2376 | Docker API | TLS 加密 |
| 4243 | Docker Alt | 旧版本 |
| 10250 | Kubelet API | K8s kubelet |
| 10255 | Kubelet ReadOnly | K8s kubelet 只读 |
| 6443 | K8s API Server | K8s API |

## 🔍 诊断常用命令

```bash
# 看本机监听端口
ss -tlnp          # TCP
ss -ulnp          # UDP
netstat -tlnp     # 旧版

# 看远程端口
nc -zv <host> <port>
telnet <host> <port>
nmap -p <port> <host>

# 抓包确认
tcpdump -i any port <port>
```

## ⚠️ 安全红线

| ❌ 禁止 | 说明 |
|---|---|
| 暴露 22 到公网 | 必须经堡垒机 |
| 暴露 3306 到公网 | DB 端口绑 127.0.0.1 |
| 暴露 6379 无密码 | 必须设密码 |
| 暴露 9200/9300 到公网 | ES 集群端口 |
| 启用 Docker 2375 | 必须 TLS（2376） |
| 启用 Telnet 23 | 用 SSH 替代 |
| 启用 SMB 445 到公网 | 高危 |

## 📋 安全合规检查清单

- [ ] 22 端口仅内网可达
- [ ] 3306/6379 绑 127.0.0.1
- [ ] 9200/9300 内部网络隔离
- [ ] Docker API 不暴露公网
- [ ] 所有 Redis 设密码
- [ ] 所有 MySQL 不允许 root 远程登录
- [ ] 启用 fail2ban（SSH 暴力破解防护）