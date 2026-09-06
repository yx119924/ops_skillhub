# 03-incident-response ｜ 故障响应

通用故障排查框架、复盘模板、值班交接等相关 Skill。

---

## ✅ 已收录

| Skill | 说明 | 版本 |
|---|---|---|
| [ops-incident-triage](./ops-incident-triage/) | 通用故障排查框架（任何告警先走这个：确认→止血→定位→修复→复盘） | v1.0 |
| [ops-high-cpu-load](./ops-high-cpu-load/) | CPU/load 高排查（系统→进程→线程→抓栈） | v1.0 |

---

## 🚧 规划中

| Skill | 解决场景 | 优先级 |
|---|---|---|
| `ops-oncall-handover` | 值班交接清单 | ⭐⭐⭐ |
| `ops-502-diagnose` | Web 服务 502 排查 | ⭐⭐⭐⭐ |
| `ops-mysql-replication-break` | MySQL 主从复制中断 | ⭐⭐⭐ |
| `ops-memory-leak` | 内存泄漏排查 | ⭐⭐⭐⭐ |
| `ops-disk-io-bottleneck` | 磁盘 IO 瓶颈 | ⭐⭐⭐ |

> 💡 `ops-postmortem-template` 已包含在 `ops-incident-triage` 的 references/ 中，无需独立 skill。

---

## 使用建议

**故障发生时的优先级**：

1. **先用 `ops-incident-triage`**（总框架）—— 五步流程
2. **按现象叠加专项 skill**：
   - CPU 高 → `ops-high-cpu-load`
   - 磁盘满 → `ops-disk-cleanup`
   - 网络不通 → `ops-network-diagnose`
   - SSH 连不上 → `ops-ssh-troubleshoot`

---

## 安装

```bash
./install.sh --category 03-incident-response
```