# 分类索引

> 📚 Ops SkillHub 全量 Skill 索引，按运维场景分类

最后更新：2026-09-06 | 当前版本：**v0.2.0**

---

## 📡 01-ssh-network ｜ SSH 与网络

| Skill | 说明 | 状态 |
|---|---|---|
| [ops-ssh-troubleshoot](./01-ssh-network/ops-ssh-troubleshoot/) | SSH 连接失败时的标准排查 SOP（5 层诊断 + 常见报错对照） | ✅ v1.0 |
| [ops-network-diagnose](./01-ssh-network/ops-network-diagnose/) | 网络不通/丢包/延迟高/DNS 故障排查（物理→网络→传输→应用） | ✅ v1.0 |

### 规划中

- `ops-vlan-stp-troubleshoot` —— VLAN / STP 故障排查
- `ops-firewall-rules-check` —— 防火墙规则审计
- `ops-wireguard-deploy` —— WireGuard 部署（适合 UDP 受限网络）

---

## 💾 02-disk-storage ｜ 磁盘与存储

| Skill | 说明 | 状态 |
|---|---|---|
| [ops-disk-cleanup](./02-disk-storage/ops-disk-cleanup/) | 磁盘满、空间排查、日志清理（df→du→分级清理→验证） | ✅ v1.0 |

### 规划中

- `ops-log-rotation` —— logrotate 配置与策略
- `ops-lvm-expansion` —— LVM 在线扩容
- `ops-backup-verify` —— 备份有效性验证
- `ops-disk-io-bottleneck` —— 磁盘 IO 瓶颈排查

---

## 🚨 03-incident-response ｜ 故障响应

| Skill | 说明 | 状态 |
|---|---|---|
| [ops-incident-triage](./03-incident-response/ops-incident-triage/) | 通用故障排查框架（任何告警先走这个：确认→止血→定位→修复→复盘） | ✅ v1.0 |
| [ops-high-cpu-load](./03-incident-response/ops-high-cpu-load/) | CPU/load 高排查（系统→进程→线程→抓栈） | ✅ v1.0 |

### 规划中

- `ops-postmortem-template` —— 故障复盘模板（已包含在 incident-triage 的 references）
- `ops-oncall-handover` —— 值班交接清单
- `ops-502-diagnose` —— Web 服务 502 排查
- `ops-mysql-replication-break` —— MySQL 主从复制中断
- `ops-memory-leak` —— 内存泄漏排查

---

## 📝 04-deploy-docs ｜ 部署文档编写

| Skill | 说明 | 状态 |
|---|---|---|
| [ops-docker-compose-template](./04-deploy-docs/ops-docker-compose-template/) | docker-compose 部署模板库（Web/DB/Cache/中间件 5+ 场景） | ✅ v1.0 |

### 规划中

- `deploy-doc-template` —— 部署文档标准模板
- `rollback-plan-template` —— 回滚方案模板
- `env-diff-checklist` —— 环境差异检查清单
- `deploy-readiness-review` —— 上线前 Readiness 检查清单

---

## 🧠 05-ops-experience ｜ 运维经验沉淀

| Skill | 说明 | 状态 |
|---|---|---|
| _待补充_ |  | 🚧 |

### 规划中

- `ops-capacity-planning` —— 容量规划方法
- `ops-arch-design-checklist` —— 架构设计 checklist
- `ops-stability-patterns` —— 稳定性设计模式（限流、熔断、降级）

---

## 📋 06-sop-templates ｜ SOP 模板

| Skill | 说明 | 状态 |
|---|---|---|
| [sop-change-management](./06-sop-templates/sop-change-management/) | 变更管理 SOP（申请→评估→审批→灰度→验证→归档） | ✅ v1.0 |

### 规划中

- `sop-server-provision` —— 新服务器交付 SOP
- `sop-incident-response` —— 应急响应 SOP
- `sop-security-incident` —— 安全事件 SOP
- `sop-data-recovery` —— 数据恢复 SOP

---

## 🔄 更新日志

### v0.2.0 (2026-09-06)

🎉 新增 6 个核心 skill：

- ✅ `ops-disk-cleanup`（磁盘清理）
- ✅ `ops-high-cpu-load`（CPU 负载排查）
- ✅ `ops-incident-triage`（通用故障框架）
- ✅ `ops-network-diagnose`（网络故障排查）
- ✅ `ops-docker-compose-template`（docker-compose 模板库）
- ✅ `sop-change-management`（变更管理 SOP）

### v0.1.0 (2026-09-06)

- 🎉 仓库初始化
- ✅ 新增 `ops-ssh-troubleshoot` skill
- 📝 完善文档：README、INSTALL、CONTRIBUTING