# 03-sre ｜ SRE 建设

SRE 工程实践：SOP、稳定性设计、容量规划、架构规范、可观测性等。提升团队整体工程化能力。

---

## ✅ 已收录

| Skill | 说明 | 适用场景 |
|---|---|---|
| [sop-change-management](./sop-change-management/) | 变更管理 SOP（申请→评估→审批→灰度→验证→归档） | 任何生产环境变更 |

---

## 🚧 规划中

| Skill | 解决场景 | 优先级 |
|---|---|---|
| `sop-incident-response` | 应急响应 SOP | ⭐⭐⭐⭐⭐ |
| `sop-server-provision` | 新服务器交付 SOP | ⭐⭐⭐⭐ |
| `ops-capacity-planning` | 容量规划方法（CPU/内存/磁盘/带宽） | ⭐⭐⭐⭐ |
| `ops-arch-design-checklist` | 架构设计 checklist（高可用、可扩展、安全） | ⭐⭐⭐⭐ |
| `ops-stability-patterns` | 稳定性设计模式（限流、熔断、降级、超时） | ⭐⭐⭐⭐ |
| `ops-monitoring-design` | 监控设计原则（指标、日志、链路） | ⭐⭐⭐⭐ |
| `ops-cost-optimization` | 成本优化经验（云资源、带宽、存储） | ⭐⭐⭐ |
| `sop-security-incident` | 安全事件 SOP | ⭐⭐⭐⭐ |
| `sop-data-recovery` | 数据恢复 SOP | ⭐⭐⭐⭐ |
| `sop-business-continuity` | 业务连续性 SOP（机房切换、容灾） | ⭐⭐⭐ |

---

## 这一类 Skill 的特点

| 维度 | 特点 |
|---|---|
| **场景** | 不是处理单一故障，而是建立系统性能力 |
| **角色** | 多人协作（执行/评估/审批/观察） |
| **产出** | 不只是修复，而是规范、模板、流程 |
| **价值** | 一次建设，长期受益 |

---

## 安装

```bash
./install.sh --category 03-sre
```