# Ops SkillHub 🛠️

> 运维工程师的 AI Skill 仓库 —— 沉淀多年实战经验，让任何 AI 都能按你的 SOP 干活

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skill Count](https://img.shields.io/badge/skills-1-blue)](categories.md)
[![Status](https://img.shields.io/badge/status-active-success)]()

## 这是什么

把日常运维的 **排查套路、Runbook、规范、命令模板** 沉淀成 WorkBuddy/Claude/Cursor 等 AI 工具可识别的 Skill 文件，让 AI 在面对运维问题时：

- ✅ 按你的标准流程排查，而不是胡猜
- ✅ 用你的命令模板，而不是通用方案
- ✅ 引用你的内部规范，而不是百科式回答
- ✅ 跨公司、跨工具复用，一次编写到处可用

## 包含什么

| 分类 | Skill | 状态 |
|---|---|---|
| [01-ssh-network](./01-ssh-network/) | [ops-ssh-troubleshoot](./01-ssh-network/ops-ssh-troubleshoot/) | ✅ 已完成 |
| [02-disk-storage](./02-disk-storage/) | 磁盘清理、空间排查、日志轮转 | 🚧 规划中 |
| [03-incident-response](./03-incident-response/) | 通用故障排查框架 | 🚧 规划中 |
| [04-deploy-docs](./04-deploy-docs/) | 部署文档模板与编写规范 | 🚧 规划中 |
| [05-ops-experience](./05-ops-experience/) | 运维经验沉淀（架构、容量、稳定性） | 🚧 规划中 |
| [06-sop-templates](./06-sop-templates/) | 标准 SOP 模板（变更、应急、上线） | 🚧 规划中 |

完整索引见 [categories.md](./categories.md)。

## 快速开始

### 安装单个 Skill

```bash
# 把整个 skill 文件夹复制到 WorkBuddy 的 skills 目录
cp -r 01-ssh-network/ops-ssh-troubleshoot ~/.workbuddy/skills/

# 下次 AI 收到"SSH 连不上"类问题会自动加载此 skill
```

### 在 GitHub 上浏览

直接访问 https://github.com/<your-username>/ops_skillhub 浏览所有 skill，挑选需要的复制。

### 编写新 Skill

查看 [CONTRIBUTING.md](./CONTRIBUTING.md) 了解命名规范、YAML frontmatter 要求、提交流程。

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