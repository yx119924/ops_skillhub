# 分类索引

> 📚 Ops SkillHub 全量 Skill 索引，按运维职能分类

最后更新：2026-09-06 | 当前版本：**v0.3.0**

---

## 🔍 01-troubleshooting ｜ 故障排查

主动或被动触发的故障诊断 SOP 集合。

| Skill | 说明 | 状态 |
|---|---|---|
| [ops-incident-triage](./01-troubleshooting/ops-incident-triage/) | 通用故障排查框架（任何告警先走这个：确认→止血→定位→修复→复盘） | ✅ v1.0 |
| [ops-ssh-troubleshoot](./01-troubleshooting/ops-ssh-troubleshoot/) | SSH 连接失败 5 层诊断 + 常见报错对照 | ✅ v1.0 |
| [ops-network-diagnose](./01-troubleshooting/ops-network-diagnose/) | 网络不通/丢包/延迟高/DNS 故障（物理→网络→传输→应用） | ✅ v1.0 |
| [ops-high-cpu-load](./01-troubleshooting/ops-high-cpu-load/) | CPU/load 高排查（系统→进程→线程→抓栈） | ✅ v1.0 |

### 规划中

- `ops-502-diagnose` —— Web 服务 502/503/504 排查
- `ops-mysql-replication-break` —— MySQL 主从复制中断
- `ops-memory-leak` —— 内存泄漏/OOM 排查
- `ops-disk-io-bottleneck` —— 磁盘 IO 瓶颈排查
- `ops-oncall-handover` —— 值班交接清单

---

## 📦 02-deployment ｜ 部署方案

应用/服务的部署、变更、回滚。

| Skill | 说明 | 状态 |
|---|---|---|
| [ops-docker-compose-template](./02-deployment/ops-docker-compose-template/) | docker-compose 部署模板库（Web/DB/Cache/中间件 5+ 场景） | ✅ v1.0 |

### 规划中

- `deploy-doc-template` —— 部署文档标准模板
- `deploy-script-checklist` —— 部署脚本编写规范（幂等、可逆、可观测）
- `rollback-plan-template` —— 回滚方案模板
- `env-diff-checklist` —— 环境差异检查清单（dev/test/prod）
- `deploy-readiness-review` —— 上线前 Readiness 检查清单
- `k8s-deploy-template` —— Kubernetes 部署模板
- `helm-chart-template` —— Helm Chart 模板

---

## 🛡 03-sre ｜ SRE 建设

SRE 工程实践：SOP、稳定性、容量、架构、可观测性。

| Skill | 说明 | 状态 |
|---|---|---|
| [sop-change-management](./03-sre/sop-change-management/) | 变更管理 SOP（申请→评估→审批→灰度→验证→归档） | ✅ v1.0 |

### 规划中

- `sop-incident-response` —— 应急响应 SOP
- `sop-server-provision` —— 新服务器交付 SOP
- `ops-capacity-planning` —— 容量规划方法
- `ops-arch-design-checklist` —— 架构设计 checklist（高可用、可扩展、安全）
- `ops-stability-patterns` —— 稳定性设计模式（限流、熔断、降级、超时）
- `ops-monitoring-design` —— 监控设计原则（指标、日志、链路）
- `ops-cost-optimization` —— 成本优化经验
- `sop-security-incident` —— 安全事件 SOP
- `sop-data-recovery` —— 数据恢复 SOP
- `sop-business-continuity` —— 业务连续性 SOP（机房切换、容灾）

---

## 🔧 04-basics ｜ 基础运维

日常运维基础操作：磁盘、日志、配置、用户管理等高频但非故障性的任务。

| Skill | 说明 | 状态 |
|---|---|---|
| [ops-disk-cleanup](./04-basics/ops-disk-cleanup/) | 磁盘空间清理 SOP（df→du→分级清理→验证） | ✅ v1.0 |

### 规划中

- `ops-log-rotation` —— logrotate 配置与策略
- `ops-lvm-expansion` —— LVM 在线扩容
- `ops-backup-verify` —— 备份有效性验证（恢复演练）
- `ops-user-management` —— 用户/权限/SSH Key 管理
- `ops-package-install` —— 包管理器使用（apt/yum/dnf）
- `ops-cron-job-template` —— 定时任务规范
- `ops-ssh-key-distribute` —— SSH 公钥批量下发

---

## 📊 全局统计

| 分类 | Skill 数 | 已规划 | 总计 |
|---|---|---|---|
| 01-troubleshooting | 4 | 5 | 9 |
| 02-deployment | 1 | 7 | 8 |
| 03-sre | 1 | 10 | 11 |
| 04-basics | 1 | 7 | 8 |
| **合计** | **7** | **29** | **36** |

---

## 🔄 更新日志

### v0.3.0 (2026-09-06)

🔄 **重构：分类体系升级**

按运维职能视角重新组织（从 6 大技术分类 → 4 大职能分类）：

- ✨ **新增 01-troubleshooting**：故障排查（汇集 ops-ssh-troubleshoot、ops-network-diagnose、ops-incident-triage、ops-high-cpu-load）
- ✨ **新增 02-deployment**：部署方案（ops-docker-compose-template）
- ✨ **新增 03-sre**：SRE 建设（sop-change-management）
- ✨ **新增 04-basics**：基础运维（ops-disk-cleanup）
- 🗑 **删除**：01-ssh-network / 02-disk-storage / 03-incident-response / 04-deploy-docs / 05-ops-experience / 06-sop-templates
- 📝 所有 git 历史保留（git mv rename detected）

### v0.2.0 (2026-09-06)

🎉 新增 6 个核心 skill：ops-disk-cleanup、ops-high-cpu-load、ops-incident-triage、ops-network-diagnose、ops-docker-compose-template、sop-change-management

### v0.1.0 (2026-09-06)

🎉 仓库初始化 + ops-ssh-troubleshoot