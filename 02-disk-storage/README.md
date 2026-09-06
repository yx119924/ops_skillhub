# 02-disk-storage ｜ 磁盘与存储

磁盘空间清理、日志管理、LVM 扩容、备份策略等相关 Skill。

---

## 🚧 规划中

| Skill | 解决场景 | 优先级 |
|---|---|---|
| `ops-disk-cleanup` | 磁盘满、大文件查找、日志清理 | ⭐⭐⭐⭐⭐ |
| `ops-log-rotation` | logrotate 配置与策略 | ⭐⭐⭐⭐ |
| `ops-lvm-expansion` | LVM 在线扩容 | ⭐⭐⭐ |
| `ops-backup-verify` | 备份有效性验证（恢复演练） | ⭐⭐⭐ |
| `ops-disk-io-bottleneck` | 磁盘 IO 瓶颈排查 | ⭐⭐⭐ |

---

## 待补充 Skill

如果你有相关 SOP 或经验，欢迎贡献。详见 [CONTRIBUTING.md](../CONTRIBUTING.md)。

### 推荐贡献的 Skill 模板

```
02-disk-storage/
└── ops-disk-cleanup/
    ├── SKILL.md
    ├── scripts/
    │   └── find_large_files.sh
    └── references/
        └── cleanup-checklist.md
```