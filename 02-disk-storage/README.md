# 02-disk-storage ｜ 磁盘与存储

磁盘空间清理、日志管理、LVM 扩容、备份策略等相关 Skill。

---

## ✅ 已收录

| Skill | 说明 | 版本 |
|---|---|---|
| [ops-disk-cleanup](./ops-disk-cleanup/) | 磁盘满、空间排查、日志清理（df→du→分级清理→验证） | v1.0 |

---

## 🚧 规划中

| Skill | 解决场景 | 优先级 |
|---|---|---|
| `ops-log-rotation` | logrotate 配置与策略 | ⭐⭐⭐⭐ |
| `ops-lvm-expansion` | LVM 在线扩容 | ⭐⭐⭐ |
| `ops-backup-verify` | 备份有效性验证（恢复演练） | ⭐⭐⭐ |
| `ops-disk-io-bottleneck` | 磁盘 IO 瓶颈排查 | ⭐⭐⭐ |

---

## 安装

```bash
./install.sh --category 02-disk-storage
# 或
./install.sh ops-disk-cleanup
```