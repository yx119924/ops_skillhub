# 04-basics ｜ 基础运维

日常运维基础操作：磁盘、日志、配置、用户管理等高频但非故障性的任务。

---

## ✅ 已收录

| Skill | 说明 | 适用场景 |
|---|---|---|
| [ops-disk-cleanup](./ops-disk-cleanup/) | 磁盘空间清理 SOP（df→du→分级清理→验证） | 磁盘满、空间不足、inode 用完 |

---

## 🚧 规划中

| Skill | 解决场景 | 优先级 |
|---|---|---|
| `ops-log-rotation` | logrotate 配置与策略 | ⭐⭐⭐⭐ |
| `ops-lvm-expansion` | LVM 在线扩容 | ⭐⭐⭐ |
| `ops-backup-verify` | 备份有效性验证（恢复演练） | ⭐⭐⭐ |
| `ops-user-management` | 用户/权限/SSH Key 管理 | ⭐⭐⭐ |
| `ops-package-install` | 包管理器使用（apt/yum/dnf） | ⭐⭐⭐ |
| `ops-cron-job-template` | 定时任务规范 | ⭐⭐⭐ |
| `ops-ssh-key-distribute` | SSH 公钥批量下发 | ⭐⭐⭐ |

---

## 与故障排查的区别

| Basics（基础运维） | Troubleshooting（故障排查） |
|---|---|
| 主动的、有计划的 | 被动响应告警/异常 |
| 高频但低风险 | 低频但高紧迫 |
| 标准化操作即可 | 需要分层诊断+判断 |
| 例：磁盘清理、日志轮转 | 例：CPU 高、网络不通 |

---

## 安装

```bash
./install.sh --category 04-basics
```