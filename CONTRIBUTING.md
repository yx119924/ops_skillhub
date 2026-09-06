# 贡献指南

欢迎贡献新 Skill 或改进现有 Skill！本文档说明如何规范地编写和提交。

---

## 一、命名规范

### Skill 目录名

格式：`ops-<领域>-<功能>`，全小写、连字符分隔

✅ 推荐：
- `ops-ssh-troubleshoot`
- `ops-disk-cleanup`
- `ops-mysql-replication`
- `ops-incident-triage`

❌ 不推荐：
- `SSH故障排查`（中文）
- `ops_ssh`（下划线）
- `OpsSsh`（大写）

### 分类目录名

格式：`NN-<领域名>-<细分>`，两位数字 + 连字符

✅ 推荐：
- `01-ssh-network`
- `02-disk-storage`
- `03-incident-response`
- `04-deploy-docs`
- `05-ops-experience`
- `06-sop-templates`

新分类时，在现有分类后面追加两位数字（07、08...）。

---

## 二、SKILL.md 编写规范

### 必需的 YAML Frontmatter

```yaml
---
name: ops-xxx-yyy
description: 一句话说明 skill 做什么 + 用户会怎么问（包含 3-5 个触发关键词）。
agent_created: true
---
```

### description 字段要求

这是 AI 自动调用的关键，必须包含：

1. **Skill 功能**：做什么
2. **触发关键词**：用户会说的具体话术（至少 3 个）

示例：

```yaml
# ✅ 好的写法
description: SSH 连接失败时的标准排查 SOP。用户报告「SSH 连不上」「远程登录失败」「ssh 超时」「堡垒机登不进去」时自动使用。基于「自下而上」分层排查：网络层 → 端口层 → 服务层 → 认证层 → 权限层，每层给出具体命令和判断标准。

# ❌ 不好的写法
description: 提供 SSH 故障排查帮助。
```

### 正文写作要求

使用**命令式语气**（动词开头），避免"你应该..."这种第二人称：

```markdown
## 排查流程

### 第一步：网络层（ping/路由）

执行以下命令：

\`\`\`bash
ping -c 3 <target_ip>
traceroute -n -T -w2 <target_ip>
\`\`\`

**判断标准**：
- ping 通 + 端口不通 → 安全组/防火墙
- ping 不通 → 物理网络或路由
```

避免：
- ❌ 「SSH 是用于远程登录的协议...」（百科式开场）
- ❌ 「你可以尝试一下...」（第二人称）
- ❌ 「如果遇到问题...」（无具体命令）

---

## 三、目录结构

```
ops-xxx-yyy/
├── SKILL.md              ← 必需
├── scripts/              ← 可选
│   └── 诊断脚本.sh
└── references/           ← 可选
    ├── 配置基线.md
    └── 报错对照表.md
```

### 何时放 scripts/

- 同一脚本被反复重写（节省 token）
- 需要确定性结果（避免 AI 自由发挥）
- 跨平台命令封装

### 何时放 references/

- 长文档（>500 字的参考）
- 命令清单、API 规范
- 不需要每次都加载的细节

### SKILL.md 长度控制

- 主体建议 ≤ 5k 字
- 详细内容拆到 `references/`
- 长文档在 SKILL.md 中用「详见 references/xxx.md」指引

---

## 四、提交流程

### 1. Fork 仓库

在你的 GitHub 上 fork 本仓库。

### 2. 创建分支

```bash
git checkout -b add-ops-disk-cleanup
```

### 3. 添加 Skill

把 Skill 文件夹放到对应分类目录下，例如：

```bash
cp -r ops-disk-cleanup 02-disk-storage/
```

### 4. 更新分类索引

编辑 `categories.md`，在对应分类下追加 Skill 链接。

### 5. 提交

```bash
git add .
git commit -m "feat(disk): add ops-disk-cleanup skill"
git push origin add-ops-disk-cleanup
```

### 6. 创建 Pull Request

在 GitHub 上创建 PR，描述：

- 这个 Skill 解决什么问题
- 适用场景
- 测试情况

---

## 五、版本管理

使用语义化版本（Semantic Versioning）：

- **MAJOR**：不兼容的架构变更（如目录结构调整）
- **MINOR**：新增 Skill
- **PATCH**：Skill 内容修正、文档完善

在 `categories.md` 顶部标注当前版本。

---

## 六、质量自检清单

提交前对照检查：

- [ ] YAML frontmatter 完整（name + description + agent_created: true）
- [ ] description 包含至少 3 个用户会说的关键词
- [ ] SKILL.md 用命令式语气，无第二人称
- [ ] 所有命令都用代码块包裹，可直接复制执行
- [ ] 每一步给出「OK/FAIL」的判断标准
- [ ] 涉及破坏性操作有警告
- [ ] 文件名全英文小写 + 连字符
- [ ] 已在本地 WorkBuddy 中测试通过
- [ ] categories.md 已更新