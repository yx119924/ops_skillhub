# 06-sop-templates ｜ SOP 模板

标准操作流程模板：服务器交付、变更管理、应急响应、安全事件等。

---

## 🚧 规划中

| Skill | 解决场景 | 优先级 |
|---|---|---|
| `sop-server-provision` | 新服务器交付 SOP | ⭐⭐⭐⭐⭐ |
| `sop-change-management` | 变更管理 SOP（含审批、灰度、回滚） | ⭐⭐⭐⭐⭐ |
| `sop-incident-response` | 应急响应 SOP | ⭐⭐⭐⭐⭐ |
| `sop-security-incident` | 安全事件 SOP | ⭐⭐⭐⭐ |
| `sop-data-recovery` | 数据恢复 SOP（误删、损坏） | ⭐⭐⭐⭐ |
| `sop-business-continuity` | 业务连续性 SOP（机房切换、容灾） | ⭐⭐⭐ |

---

## SOP 模板通用结构

```
1. 适用范围
2. 角色与职责
3. 前置条件
4. 操作步骤（含时间节点）
5. 验证标准
6. 异常处理
7. 记录与归档
```

---

## 与普通 Skill 的区别

| Skill（操作类） | SOP（流程类） |
|---|---|
| 解决「怎么做」 | 解决「什么时候由谁做」 |
| 命令步骤为主 | 角色 + 时间节点为主 |
| 偏技术 | 偏管理 + 技术 |
| 单人可执行 | 多人协作 |