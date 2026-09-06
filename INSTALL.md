# 安装指南

本文档介绍如何把本仓库的 Skill 安装到不同的 AI 工具中。

---

## 一、WorkBuddy（推荐，原生支持）

### 单个 Skill 安装

```bash
# Linux / macOS / Git Bash
cp -r 01-ssh-network/ops-ssh-troubleshoot ~/.workbuddy/skills/

# Windows PowerShell
Copy-Item -Recurse "01-ssh-network\ops-ssh-troubleshoot" "$env:USERPROFILE\.workbuddy\skills\"
```

### 一次性安装所有 Skill

```bash
# 一键复制所有 skill 到 WorkBuddy
for dir in */ops-*; do
  skill_name=$(basename "$dir")
  cp -r "$dir" "$HOME/.workbuddy/skills/"
  echo "✅ Installed: $skill_name"
done
```

### 验证安装

```bash
# 查看已安装的 skill
ls ~/.workbuddy/skills/

# 应能看到类似输出：
# ops-ssh-troubleshoot/
# ops-disk-cleanup/
# ...
```

打开 WorkBuddy 对话框，输入：

```
/ops-ssh-troubleshoot
```

如果出现 Skill 内容，说明安装成功。

---

## 二、项目级安装（仅当前项目生效）

如果你只想在某个项目里用 Skill（不影响其他项目）：

```bash
# 假设你的项目在 /path/to/project
cp -r 01-ssh-network/ops-ssh-troubleshoot /path/to/project/.workbuddy/skills/
```

Skill 仅在该项目的工作目录下生效。

---

## 三、其他 AI 工具

### Claude Code

```bash
# Claude Code 的 skills 目录路径（根据官方文档调整）
cp -r 01-ssh-network/ops-ssh-troubleshoot ~/.claude/skills/
```

### Cursor

Cursor 的 Skill 系统使用 `.cursor/skills/` 目录：

```bash
cp -r 01-ssh-network/ops-ssh-troubleshoot ~/.cursor/skills/
```

### 通用自定义路径

如果你的 AI 工具使用其他路径，只需把 skill 文件夹复制到对应位置，并确保工具会扫描该目录。

---

## 四、Skill 目录结构要求

每个 Skill 必须是如下结构：

```
ops-xxx/
├── SKILL.md              ← 必需，主入口
├── scripts/              ← 可选，脚本
│   └── xxx.sh
└── references/           ← 可选，参考文档
    └── xxx.md
```

详见 [CONTRIBUTING.md](./CONTRIBUTING.md)。

---

## 五、卸载

直接删除对应目录即可：

```bash
rm -rf ~/.workbuddy/skills/ops-ssh-troubleshoot
```

---

## 六、故障排查

| 问题 | 原因 | 解决 |
|---|---|---|
| Skill 没被自动调用 | description 关键词不匹配 | 检查用户提问是否包含 SKILL.md 中列出的关键词 |
| Skill 内容没加载 | 目录结构错 | 确保 SKILL.md 在 skill 根目录 |
| YAML frontmatter 报错 | 格式问题 | 检查是否有 `name:` `description:` `agent_created: true` 三个字段 |
| 脚本无法执行 | 权限不足 | `chmod +x scripts/*.sh` |