---
name: ops-disk-cleanup
description: Linux 磁盘空间清理 SOP。当用户报告「磁盘满了」「磁盘空间不足」「服务器无法写入」「清理磁盘」「找大文件」「/var/log 占满」「inode 用完」时自动使用。基于「先看再用再清」三步走：先用 df/du 看清占用、找到大文件、清理并验证。
agent_created: true
---

# 磁盘清理 SOP

## 何时使用

触发场景（满足任一即调用）：
- 用户报告磁盘已满、写不进去文件、服务异常退出
- 监控告警：磁盘使用率 > 80%、inode > 90%
- 关键词：「磁盘满了」「空间不足」「清理」「找大文件」「log 占满」「inode 用完」「no space left」
- 计划性清理（每月/季度巡检）

## 核心原则

1. **先查后删** —— 永远先 `df` + `du` 看清情况，再动手
2. **分级处理** —— 日志→缓存→临时文件→历史数据，按风险递增
4. **可回滚** —— 删除前确认或备份
5. **避免误删** —— 永远不要 `rm -rf /*`，不要删 `/proc`、`/sys`、`/dev` 内容

---

## 排查流程（按顺序执行）

### 第一步：看全局（df + inode）

\`\`\`bash
# 1. 看磁盘空间（人类可读）
df -h

# 2. 看 inode 使用率（inode 用完也会写不进）
df -i

# 3. 看挂载点分布
lsblk
\`\`\`

**判断标准**：
- `Use%` > 90% → 高危，立即进入下一步
- `Use%` 50-80% → 中危，可安排清理
- `Use%` < 50% → 不是空间问题，考虑其他方向（inode / 文件描述符 / 权限）

### 第二步：定位占用（du 按目录排序）

\`\`\`bash
# 1. 找出 / 下最大的 10 个一级目录
sudo du -h --max-depth=1 / 2>/dev/null | sort -hr | head -10

# 2. 重点查常见吃空间大户
sudo du -sh /var/log/* 2>/dev/null | sort -hr | head -5
sudo du -sh /var/cache/* 2>/dev/null | sort -hr | head -5
sudo du -sh /tmp/* 2>/dev/null | sort -hr | head -5
sudo du -sh /home/* 2>/dev/null | sort -hr | head -5

# 3. 找大于 1G 的单个文件
sudo find / -type f -size +1G 2>/dev/null | head -20
\`\`\`

**判断标准**：
- `/var/log` 巨大 → 日志清理（看第三步 A）
- `/var/cache` 巨大 → 应用缓存清理（看第三步 B）
- `/tmp` 巨大 → 临时文件清理（看第三步 C）
- 散落大文件 → 业务数据归档（看第三步 D）

### 第三步：分级清理（按风险递增）

#### A 级：日志清理（最常见，**风险低**）

\`\`\`bash
# 1. 找已轮转的旧日志（.gz、.1、.log.old）
sudo find /var/log -name "*.gz" -size +100M -mtime +30 2>/dev/null
sudo find /var/log -name "*.log.*" -size +100M -mtime +30 2>/dev/null

# 2. 清理（先 list 再删，避免误操作）
sudo find /var/log -name "*.gz" -mtime +30 -delete

# 3. 截断正在写入的大日志（比删除安全）
sudo truncate -s 0 /var/log/syslog
sudo truncate -s 0 /var/log/messages

# 4. 配置 logrotate 自动管理（推荐一次性解决）
sudo vim /etc/logrotate.d/<service>
\`\`\`

#### B 级：应用缓存清理（**风险中**）

\`\`\`bash
# 1. 包管理器缓存
sudo apt clean
sudo yum clean all

# 2. Docker 缓存（最容易忽略）
docker system df
docker system prune -a --volumes    # ⚠️ 会删未使用的镜像和卷

# 3. 前端构建缓存
rm -rf node_modules/.cache
rm -rf .next/cache

# 4. 系统缓存
sync && sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'    # 释放 page cache
\`\`\`

#### C 级：临时文件清理（**风险中**）

\`\`\`bash
# 1. /tmp 下超过 7 天的文件
sudo find /tmp -type f -atime +7 -delete

# 2. /var/tmp 下超过 30 天的
sudo find /var/tmp -type f -atime +30 -delete

# 3. 用户上传临时目录
sudo find /upload_tmp -type f -atime +3 -delete
\`\`\`

#### D 级：业务数据归档（**风险高**，必须确认）

\`\`\`bash
# 1. 找 90 天前的业务文件（先 list 再确认）
find /data/uploads -type f -mtime +90 | head -20

# 2. 压缩归档后删除（推荐）
tar -czf /backup/data_$(date +%Y%m%d).tar.gz /data/uploads/2023-* --remove-files

# 3. ⚠️ 涉及业务数据的，必须先与业务方确认
\`\`\`

### 第四步：验证

\`\`\`bash
# 1. 确认磁盘释放
df -h
df -i

# 2. 确认服务正常
systemctl status <service>
curl -I http://localhost:<port>

# 3. 监控指标恢复
# （Grafana 看磁盘使用率趋势）
\`\`\`

---

## 输出格式

执行后给出：
1. **问题定位**：哪一层（df / du / inode / 业务）
2. **清理清单**：具体删了什么、释放了多少
3. **验证结果**：磁盘使用率前后对比
4. **防范措施**：是否需要调 logrotate / 监控阈值 / 容量规划

## 注意事项

| 红线 | 说明 |
|---|---|
| ❌ 不要 `rm -rf /*` 或 `rm -rf /var` | 会删掉系统关键文件 |
| ❌ 不要删 `/proc`、`/sys`、`/dev` 下的内容 | 虚拟文件系统，删了系统会崩 |
| ⚠️ `truncate` 比 `rm` 安全 | 文件句柄保留，应用继续写 |
| ⚠️ Docker `prune` 慎用 | 会清理未使用的镜像和数据卷 |
| ⚠️ 业务数据必须先归档再删 | 否则无法恢复 |
| ✅ 优先清 log 和 cache | 风险最低、收益最大 |

## 快速清磁盘（一句话命令）

```bash
# 看占用
df -h && du -sh /var/log/* 2>/dev/null | sort -hr | head -5

# 清日志 + 包缓存
sudo find /var/log -name "*.gz" -mtime +30 -delete && sudo apt clean -y

# 清 Docker
docker system prune -af