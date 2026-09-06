# 磁盘清理 Checklist

## 🚨 应急清理（磁盘已满，服务异常）

### Step 1: 看现状（1 分钟）

```bash
df -h            # 看磁盘空间
df -i            # 看 inode（inode 用完也会写不进）
du -sh /var/log /var/cache /tmp /home 2>/dev/null
```

### Step 2: 找元凶（2 分钟）

```bash
# Top 10 大目录
sudo du -h --max-depth=1 / 2>/dev/null | sort -hr | head -10

# Top 10 大文件
sudo find / -type f -size +500M 2>/dev/null | head -20
```

### Step 3: 立即止血（5 分钟）

按风险从低到高：

| 操作 | 命令 | 风险 |
|---|---|---|
| 清 logrotate 旧日志 | `sudo find /var/log -name "*.gz" -mtime +7 -delete` | 极低 |
| 截断正在写的日志 | `sudo truncate -s 0 /var/log/syslog` | 低 |
| 清包管理器缓存 | `sudo apt clean` 或 `sudo yum clean all` | 极低 |
| 清 Docker | `docker system prune -a` | 中（删未使用的） |
| 清 /tmp | `sudo find /tmp -type f -atime +3 -delete` | 低 |
| 清业务数据 | ⚠️ **必须先归档** | 高 |

### Step 4: 验证（1 分钟）

```bash
df -h              # 确认释放
systemctl status <service>  # 确认服务正常
```

---

## 🛡 防范措施（根治）

### 1. 配置 logrotate（最重要）

```bash
# /etc/logrotate.d/<service>
/var/log/<service>/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
    size 100M    # 单文件超过 100M 触发轮转
    postrotate
        systemctl reload <service>
    endscript
}
```

### 2. 配置监控告警

- 磁盘使用率 > 80% 告警
- inode 使用率 > 90% 告警
- /var/log 单目录 > 10G 告警

### 3. 定期巡检脚本

```bash
#!/bin/bash
# /usr/local/bin/disk_check.sh
THRESHOLD=80
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "WARNING: 磁盘使用率 ${USAGE}%"
    # 触发告警
fi
```

加入 crontab：
```bash
0 */6 * * * /usr/local/bin/disk_check.sh
```

### 4. 容量规划

- 业务数据：按 3-6 个月增长预测容量
- 日志：按保留周期计算（保留 7 天 × 日均量）
- 预留 20% buffer

---

## 🚫 绝对禁止

| ❌ 禁止 | 后果 |
|---|---|
| `rm -rf /*` | 删光系统，无法恢复 |
| `rm -rf /var` | 删光应用数据 |
| 删 `/proc /sys /dev` 内容 | 虚拟文件系统，删了系统崩 |
| 删 `/etc` 下配置 | 服务无法启动 |
| 没确认就 `rm` 业务数据 | 数据无法恢复 |
| 不看 `df -i` 就动手 | inode 满不是清文件能解决的 |

---

## ✅ 最佳实践

1. **截断 > 删除** —— `truncate` 保留文件句柄
2. **list 后 delete** —— 先 `find ... -print` 看看，再 `-delete`
3. **定期演练** —— 每季度演练一次恢复
4. **离线备份** —— 关键数据必须有异地备份
5. **监控在前** —— 告警阈值设 80%，别等满了才处理

---

## 📋 常见业务日志路径速查

| 应用 | 日志路径 |
|---|---|
| Nginx | /var/log/nginx/ |
| Apache | /var/log/apache2/ 或 /var/log/httpd/ |
| MySQL | /var/log/mysql/ |
| Redis | /var/log/redis/ |
| Docker | /var/lib/docker/containers/*/*.log |
| Systemd | journalctl（需 vacuum） |
| Tomcat | /opt/tomcat/logs/ |
| Django | 项目目录下 logs/ |
| Node 应用 | 项目目录下 logs/ |

---

## 🔧 应急一键命令

```bash
# 紧急清日志（不影响服务）
sudo find /var/log -name "*.gz" -mtime +7 -delete
sudo find /var/log -name "*.log.*" -mtime +7 -delete
sudo truncate -s 0 /var/log/syslog /var/log/messages
sudo journalctl --vacuum-time=7d

# 紧急清 Docker
docker system prune -af

# 紧急清包缓存
sudo apt clean -y
sudo yum clean all

# 释放 page cache（无损）
sudo sync && sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
```