# 01-troubleshooting ｜ 故障排查

主动或被动触发的故障诊断 SOP 集合 —— 任何告警、异常、用户反馈，先来这里找对应的排查套路。

---

## ✅ 已收录

| Skill | 说明 | 触发场景 |
|---|---|---|
| [ops-incident-triage](./ops-incident-triage/) | 通用故障排查框架（**任何告警先走这个**） | 收到告警、服务异常、慢、报错 |
| [ops-ssh-troubleshoot](./ops-ssh-troubleshoot/) | SSH 连接失败 5 层诊断 | SSH 连不上、超时、被拒 |
| [ops-network-diagnose](./ops-network-diagnose/) | 网络故障排查（物理→网络→传输→应用） | ping 不通、丢包、端口连不上 |
| [ops-high-cpu-load](./ops-high-cpu-load/) | CPU/load 高排查（系统→进程→线程→抓栈） | CPU 100%、load 高、卡顿 |

---

## 🚧 规划中

| Skill | 解决场景 | 优先级 |
|---|---|---|
| `ops-502-diagnose` | Web 服务 502/503/504 排查 | ⭐⭐⭐⭐ |
| `ops-mysql-replication-break` | MySQL 主从复制中断 | ⭐⭐⭐ |
| `ops-memory-leak` | 内存泄漏/oom 排查 | ⭐⭐⭐⭐ |
| `ops-disk-io-bottleneck` | 磁盘 IO 瓶颈排查 | ⭐⭐⭐ |
| `ops-oncall-handover` | 值班交接清单 | ⭐⭐⭐ |

---

## 使用建议

**故障发生时的优先级**：

```
1. 先调 ops-incident-triage（总框架）
   ↓
2. 按现象叠加对应专项 skill
   ├── CPU 高 → ops-high-cpu-load
   ├── 磁盘满 → 04-basics/ops-disk-cleanup
   ├── 网络不通 → ops-network-diagnose
   └── SSH 连不上 → ops-ssh-troubleshoot
```

---

## 安装

```bash
# 一键安装本分类所有 skill
./install.sh --category 01-troubleshooting

# 或安装单个
./install.sh ops-incident-triage
```