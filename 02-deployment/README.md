# 02-deployment ｜ 部署方案

应用/服务的部署、变更、回滚方案。覆盖容器化、配置管理、脚本规范等。

---

## ✅ 已收录

| Skill | 说明 | 适用场景 |
|---|---|---|
| [ops-docker-compose-template](./ops-docker-compose-template/) | docker-compose 部署模板库（Web/DB/Cache/中间件 5+ 场景） | 新服务容器化部署、现有 compose 改造 |

---

## 🚧 规划中

| Skill | 解决场景 | 优先级 |
|---|---|---|
| `deploy-doc-template` | 部署文档标准模板 | ⭐⭐⭐⭐⭐ |
| `deploy-script-checklist` | 部署脚本编写规范（幂等、可逆、可观测） | ⭐⭐⭐⭐ |
| `rollback-plan-template` | 回滚方案模板 | ⭐⭐⭐⭐⭐ |
| `env-diff-checklist` | 环境差异检查清单（dev/test/prod） | ⭐⭐⭐ |
| `deploy-readiness-review` | 上线前 Readiness 检查清单 | ⭐⭐⭐⭐ |
| `k8s-deploy-template` | Kubernetes 部署模板 | ⭐⭐⭐ |
| `helm-chart-template` | Helm Chart 模板 | ⭐⭐ |

---

## 使用说明

`ops-docker-compose-template` 包含：

- 5+ 场景模板（Web + DB + Cache + DVAdmin/Django 全栈 + Prometheus/Grafana）
- 12 项编写规范 checklist
- .env 文件模板
- 常用命令速查
- 安全红线清单

---

## 安装

```bash
./install.sh --category 02-deployment
```