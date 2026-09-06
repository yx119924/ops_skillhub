# Ops SkillHub 🛠️

> 运维工程师的 AI Skill 仓库 —— 沉淀多年实战经验，让任何 AI 都能按你的 SOP 干活

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skill Count](https://img.shields.io/badge/skills-7-blue)](categories.md)
[![Version](https://img.shields.io/badge/version-v0.2.0-success)]()
[![Status](https://img.shields.io/badge/status-active-success)]()

## 这是什么

把日常运维的 **排查套路、Runbook、规范、命令模板** 沉淀成 WorkBuddy/Claude/Cursor 等 AI 工具可识别的 Skill 文件，让 AI 在面对运维问题时：

- ✅ 按你的标准流程排查，而不是胡猜
- ✅ 用你的命令模板，而不是通用方案
- ✅ 引用你的内部规范，而不是百科式回答
- ✅ 跨公司、跨工具复用，一次编写到处可用

## 包含什么

| 分类 | 已有 Skill | 状态 |
|---|---|---|
| [01-ssh-network](./01-ssh-network/) | ops-ssh-troubleshoot / ops-network-diagnose | ✅ 2 个 |
| [02-disk-storage](./02-disk-storage/) | ops-disk-cleanup | ✅ 1 个 |
| [03-incident-response](./03-incident-response/) | ops-incident-triage / ops-high-cpu-load | ✅ 2 个 |
| [04-deploy-docs](./04-deploy-docs/) | ops-docker-compose-template | ✅ 1 个 |
| [05-ops-experience](./05-ops-experience/) | 容量规划、架构设计 | 🚧 规划中 |
| [06-sop-templates](./06-sop-templates/) | sop-change-management | ✅ 1 个 |

**当前共 7 个 Skill**，完整索引见 [categories.md](./categories.md)。

## 快速开始

### 一键安装（推荐）

```bash
# 1. 克隆仓库
git clone https://github.com/yx119924/ops_skillhub.git
cd ops_skillhub

# 2. 一键安装所有 skill
./install.sh

# 或 Windows PowerShell
.\install.ps1
```

### 安装单个 Skill

```bash
./install.sh ops-ssh-troubleshoot
```

### 按分类安装

```bash
./install.sh --category 02-disk-storage
```

### 查看所有可用 skill

```bash
./install.sh --list
```

### 卸载/更新

```bash
./install.sh --uninstall ops-ssh-troubleshoot
./install.sh --update
```

### 高级用法

```bash
# 直接通过 curl/wget 执行（不克隆仓库）
curl -fsSL https://raw.githubusercontent.com/yx119924/ops_skillhub/main/install.sh | bash -s -- all

# 让 AI 帮你安装（在对话中说即可）：
# "帮我从 ops_skillhub 仓库安装 SSH 故障排查 skill"
```

> 完整文档见 [INSTALL.md](./INSTALL.md)

## 设计原则

1. **一次编写，到处使用** —— Skill 是 AI 工具无关的，可在 WorkBuddy / Claude / Cursor / 其他支持 Skill 系统的工具中使用
2. **命令式步骤** —— SKILL.md 必须是「第一步做什么、第二步做什么」的可执行步骤，不写理论文章
3. **触发关键词清晰** —— description 字段必须包含用户会说的具体话术，AI 才能自动调用
4. **可独立运行** —— 每个 skill 自包含，依赖的脚本/参考文档放自己的子目录
5. **持续演进** —— 经验在增长，skill 也持续更新，版本号语义化

## 适用工具

本仓库的 Skill 设计兼容以下 AI 工具（只要支持 Skill 系统）：

- ✅ **WorkBuddy**（原生支持，复制到 `~/.workbuddy/skills/` 即可）
- ✅ **Claude Code**（支持 Skill 系统）
- ✅ **Cursor**（支持 Skill 系统）
- ⚠️ 其他工具需自行适配目录结构

## 贡献者

由 [@yex](https://github.com/yex) 维护，欢迎 fork、PR、Issue。

## 许可证

[MIT](./LICENSE)