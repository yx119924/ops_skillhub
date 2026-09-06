---
name: ops-ssh-troubleshoot
description: SSH 连接失败时的标准排查 SOP。用户报告「SSH 连不上」「远程登录失败」「ssh 超时」「堡垒机登不进去」时自动使用。基于「自下而上」分层排查：网络层 → 端口层 → 服务层 → 认证层 → 权限层，每层给出具体命令和判断标准。
agent_created: true
---

# SSH 故障排查 SOP

## 何时使用

触发场景（满足任一即调用）：

- 用户反馈 SSH 连接超时、拒绝、卡住
- 堡垒机登录失败
- 自动化脚本/Ansible/paramiko SSH 异常
- 关键词包含：「ssh 连不上」「ssh 失败」「远程登录」「ssh 超时」「堡垒机登不上」

## 排查原则

1. **客户端优先**：先在调用方排查，不要急于登服务器（连接断了客户端先自查）
2. **分层定位**：自下而上 5 层，逐层排除，避免跳步
3. **先通后验**：先用最简单方式（ping/密码）验证基础连通，再排查复杂配置
4. **留痕**：每步输出结果，便于复盘

## 排查流程（严格按顺序）

### Layer 1 - 网络层（IP 是否可达）

\`\`\`bash
# 1.1 基础连通性
ping -c 3 -W 2 <target_ip>

# 1.2 路由追踪（ping 失败时）
traceroute -n -T -w 2 <target_ip>     # TCP 模式，绕过 ICMP 限制
mtr -n -r -c 10 <target_ip>          # 持续丢包率统计

# 1.3 DNS 验证（用域名时）
nslookup <hostname>
dig <hostname> +short
\`\`\`

**判断**：
- ping 通 → 进 Layer 2
- ping 不通 + traceroute 断在某跳 → 找该跳负责人
- ping 不通 + traceroute 全程超时 → 目标机宕机或防火墙全拒

### Layer 2 - 端口层（22 端口是否开放）

\`\`\`bash
# 2.1 端口扫描（任选其一）
telnet <target_ip> 22
nc -zv <target_ip> 22
nmap -p 22 --open <target_ip>        # 需安装 nmap

# 2.2 改用其他端口尝试
ssh -p 2222 user@<target_ip>         # 假设 SSH 改端口了
\`\`\`

**判断**：
- 端口开放 → 进 Layer 3
- 端口关闭 → 安全组/防火墙未放行（最常见原因）
- 端口开放但 SSH 报 Connection refused → 端口被冒充，进 Layer 3 验服务

### Layer 3 - 服务层（SSH 服务是否运行）

需先能进服务器（用 IPMI/iDRAC/Console），或在客户端抓 banner：

\`\`\`bash
# 3.1 抓 banner（无需登录）
nc -v <target_ip> 22 < /dev/null
ssh -vvv user@<target_ip>            # 详细调试，看到协议版本

# 3.2 服务器端检查（需已登入）
systemctl status sshd
systemctl status ssh                 # 部分系统叫 ssh
ps aux | grep -E "sshd|ssh-agent"
ss -tlnp | grep :22                  # 确认监听端口
\`\`\`

**判断**：
- banner 正常返回 OpenSSH 版本 → 服务在
- 无响应 / Connection refused → sshd 未启动或挂了，systemctl restart sshd

### Layer 4 - 认证层（密钥/密码）

\`\`\`bash
# 4.1 客户端密钥检查
ls -la ~/.ssh/
ssh-add -l                            # 看已加载的 key

# 4.2 密钥权限修正（常见坑）
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 644 ~/.ssh/known_hosts          # 注意：早期版本要求 600

# 4.3 服务端 authorized_keys 校验
cat ~/.ssh/authorized_keys            # 是否包含客户端公钥
\`\`\`

**判断**：
- Permission denied (publickey) → 密钥不匹配或权限错
- Permission denied (password) → PasswordAuthentication no 或密码错
- Too many authentication failures → 客户端 ssh-agent 携带太多 key，服务端 MaxAuthTries 限制

### Layer 5 - 权限层（能登但操作受限）

\`\`\`bash
# 5.1 登入后立即检查
whoami
id
sudo -l                              # 看 sudo 权限

# 5.2 /etc/sudoers 检查
visudo -c -f /etc/sudoers
\`\`\`

**判断**：
- 普通用户无 sudo → 申请权限或切 root
- 「不在 sudoers 文件中」→ 加 sudo 配置

## 常用修复命令速查

| 故障现象 | 修复命令 |
|---|---|
| sshd 未启动 | `systemctl enable --now sshd` |
| 端口被改 | `grep Port /etc/ssh/sshd_config` |
| 禁止密码登录 | `sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && systemctl reload sshd` |
| PermitRootLogin 禁止 | `sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config` |
| MaxAuthTries 过低 | `sed -i 's/#MaxAuthTries.*/MaxAuthTries 6/' /etc/ssh/sshd_config` |
| 防火墙阻断 | `firewall-cmd --add-port=22/tcp --permanent && firewall-cmd --reload` |

## 输出格式

排查完成后必须给出：

1. **故障定位**：哪一层、具体原因
2. **修复命令**：可直接复制执行
3. **防范措施**：避免复发的建议（如 SSH 配置基线、堡垒机管控）
4. **复盘文档**：建议归档到 Runbook 知识库

## 注意事项

- **不要**在生产机直接改 /etc/ssh/sshd_config，先备份 `cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%F)`
- **不要**reload sshd 前关闭当前会话，留一个备用连接防失联
- **不要**暴力重启 sshd，先 `sshd -t` 测试配置
- 涉及防火墙变更必须确认变更窗口（生产避开业务高峰）
- 内网环境下优先排查 ACL（交换机/防火墙），公网优先排查安全组

## 参考资源

- 见 \`references/ssh-config-baseline.md\`：SSH 配置基线模板
- 见 \`references/common-errors.md\`：常见报错对照表
- 见 \`scripts/ssh_diag.sh\`：一键诊断脚本（在能登录的客户端运行）