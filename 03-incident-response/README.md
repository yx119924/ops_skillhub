# 03-incident-response ｜ 故障响应

通用故障排查框架、复盘模板、值班交接等相关 Skill。

---

## 🚧 规划中

| Skill | 解决场景 | 优先级 |
|---|---|---|
| `ops-incident-triage` | 通用故障排查框架（任何告警先走这个） | ⭐⭐⭐⭐⭐ |
| `ops-postmortem-template` | 故障复盘模板（Postmortem） | ⭐⭐⭐⭐ |
| `ops-oncall-handover` | 值班交接清单 | ⭐⭐⭐ |
| `ops-502-diagnose` | Web 服务 502 排查 | ⭐⭐⭐⭐ |
| `ops-mysql-replication-break` | MySQL 主从复制中断 | ⭐⭐⭐ |

---

## 待补充 Skill

`ops-incident-triage` 是最高优先级，建议优先编写。

### 编写提示

故障排查通用框架应该：

1. **先确认范围**：影响哪些业务、哪些用户
2. **快速止血**：能不能先临时恢复（重启 / 切流量 / 回滚）
3. **深入定位**：从外到内、从现象到根因
4. **验证修复**：是否真的解决了
5. **事后复盘**：写 Postmortem、改进措施