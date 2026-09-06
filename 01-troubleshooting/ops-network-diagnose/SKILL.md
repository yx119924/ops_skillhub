---
name: ops-network-diagnose
description: Linux 网络故障排查 SOP。当用户报告「网络不通」「连不上」「ping 不通」「telnet 失败」「端口连不上」「丢包」「延迟高」「DNS 解析失败」「traceroute」时自动使用。基于「物理层 → 网络层 → 传输层 → 应用层」分层诊断，每层给出具体命令。
agent_created: true
---

# 网络故障排查 SOP

## 何时使用

触发场景（满足任一即调用）：
- 客户端连不上服务器（业务端口、SSH、数据库）
- ping 失败、超时、丢包
- DNS 解析异常
- 网络延迟突然变高
- 关键词：「网络不通」「ping 不通」「telnet 失败」「端口连不上」「丢包」「延迟高」「DNS 故障」「解析失败」

---

## 核心思路：分层诊断

\`\`\`
应用层（HTTP/SSH/MySQL）→ 端口是否通？服务在监听？
    ↓
传输层（TCP/UDP）→ 三次握手？丢包？
    ↓
网络层（IP/ICMP）→ 路由可达？丢包？
    ↓
物理层（网卡/交换机）→ 网卡 up？链路正常？
\`\`\`

**关键原则**：**从上往下**或**从下往上**，每层必须有「OK / FAIL」判断。

---

## 排查流程（按顺序执行）

### 第一步：确认问题（**30 秒**）

\`\`\`bash
# 1. 复现问题
curl -v http://target:8080/         # HTTP 服务
mysql -h target -u user -p           # DB
ssh user@target                       # SSH

# 2. 错误信息记录
# - 是 timeout？connection refused？reset？
# - 单次失败还是持续失败？
# - 多个客户端都失败还是单个客户端？
\`\`\`

**判断标准**：
- 单客户端失败 → 客户端问题或中间网络
- 多客户端失败 → 服务端问题或上游网络
- timeout → 中间丢包/防火墙
- connection refused → 服务未监听或本地防火墙
- connection reset → 服务端主动断开

### 第二步：物理层（网卡 / 链路）

\`\`\`bash
# 1. 看本机网卡状态
ip link show
ip addr show

# 2. 看网卡统计（丢包、错误）
ip -s link show
ifconfig <interface>     # 旧版工具

# 3. 看网卡驱动和速率
ethtool <interface>
dmesg | grep -i eth      # 网卡驱动错误

# 4. 看交换机侧（带外管理或 LLDP）
\`\`\`

**判断标准**：
- 网卡 DOWN → 检查网线/SFP/交换机端口
- `errors` / `dropped` 持续增长 → 链路质量差或硬件故障
- 速率协商异常（100M 而不是 1G）→ 网线或端口问题

### 第三步：网络层（IP / 路由）

\`\`\`bash
# 1. 看本机 IP 和路由表
ip addr
ip route

# 2. ping 目标（基础连通性）
ping -c 5 <target_ip>

# 3. traceroute / mtr（路径追踪）
traceroute -n -T -w2 <target_ip>      # TCP 模式（绕开 ICMP 限制）
mtr -rwc 30 <target_ip>              # 实时统计丢包点

# 4. 看 ARP 表（同网段）
ip neigh
arp -an
\`\`\`

**判断标准**：
- ping 通 → 网络层 OK，进入传输层
- ping 不通 → 检查路由、网关、ACL
- traceroute 中间某跳开始丢包 → 该跳或上游问题
- 全部丢包 → 目标机防火墙丢 ICMP（用 TCP 模式 traceroute）

### 第四步：DNS（解析层）

\`\`\`bash
# 1. 用系统解析
getent hosts example.com
cat /etc/hosts

# 2. 用 dig 看完整解析过程
dig example.com
dig +trace example.com              # 完整追踪
dig @8.8.8.8 example.com            # 指定 DNS

# 3. 反向解析
dig -x <ip>

# 4. 看 /etc/resolv.conf
cat /etc/resolv.conf
\`\`\`

**判断标准**：
- 解析失败 → DNS 服务问题或域名不存在
- 解析到错误 IP → DNS 污染或 hosts 配置错
- 部分地区解析失败 → DNS 递归慢或缓存问题

### 第五步：传输层（端口连通性）

\`\`\`bash
# 1. 端口连通性测试
telnet <target> <port>              # 经典工具
nc -zv <target> <port>              # nc 一行
curl -v telnet://<target>:<port>    # 无 nc/telnet 时用 curl
nmap -p <port> <target>             # 端口扫描

# 2. 看本地监听端口
ss -tlnp                            # TCP 监听
ss -ulnp                            # UDP 监听
netstat -tlnp                       # 旧版

# 3. 看已建立的连接
ss -tan state established

# 4. 看连接状态分布
ss -s
\`\`\`

**判断标准**：
- 端口通 → 应用层问题
- 端口不通 + 本机有监听 → 防火墙/安全组
- 端口不通 + 本机无监听 → 服务没起或绑错地址（只绑 127.0.0.1）
- `connection refused` → 服务未监听或主动拒绝
- `timeout` → 中间网络或防火墙丢包

### 第六步：应用层（抓包）

\`\`\`bash
# 1. tcpdump 抓包（看真实通信）
sudo tcpdump -i <interface> host <target_ip> -nn -vv
sudo tcpdump -i <interface> port <port> -w /tmp/cap.pcap
# 用 Wireshark 打开 .pcap 分析

# 2. SSL/TLS 握手分析
openssl s_client -connect <target>:<port> -showcerts

# 3. 应用层日志
journalctl -u <service> -f
tail -f /var/log/<service>/access.log
\`\`\`

**判断标准**：
- 看到 SYN 但无 SYN-ACK → 服务端没收到或防火墙丢
- 看到 RST → 服务端主动拒绝（端口未开或应用层拒绝）
- 看到完整握手但无数据 → 应用层 hang 死
- TLS 握手失败 → 证书/协议/加密套件问题

---

## 常见场景速查

| 场景 | 首选工具 |
|---|---|
| 业务端口连不上 | `nc -zv` 或 `telnet` |
| ping 不通但业务通 | 说明 ICMP 被策略阻，正常 |
| 延迟突然变高 | `mtr` 看丢包节点 |
| DNS 解析慢/失败 | `dig +trace` 看完整过程 |
| SSH 连不上 | 叠加 ops-ssh-troubleshoot |
| 服务端无响应 | `tcpdump` + `strace` 进程 |
| 间歇性失败 | 看连接状态（`ss -s`）+ mtr 看是否抖动 |
| 跨国/跨运营商慢 | mtr 找瓶颈节点，必要时换线路 |

---

## 防火墙与安全组

\`\`\`bash
# 本机防火墙
sudo iptables -L -n -v
sudo iptables -t nat -L -n

# nftables（新版）
sudo nft list ruleset

# firewalld（CentOS/RHEL）
sudo firewall-cmd --list-all

# ufw（Ubuntu）
sudo ufw status
\`\`\`

**云上安全组**（在云控制台看）：
- 入口规则是否放行目标端口
- 源 IP 限制是否包含客户端 IP
- 跨 VPC/跨账号需要 Peering

---

## 输出格式

排查完成后给出：
1. **问题定位**：哪一层（物理/网络/传输/应用）
2. **证据**：关键命令输出
3. **根因**：直接原因 + 根本原因
4. **修复建议**：具体配置变更或绕行方案
5. **防范措施**：监控、巡检、规范

---

## 注意事项

| 红线 | 说明 |
|---|---|
| ❌ 不要在生产用 nmap 扫描 | 可能被 IDS 告警或触发封禁 |
| ❌ 不要长时间抓包 | pcap 文件会很大 |
| ⚠️ ping 不通 ≠ 业务不通 | ICMP 常被策略阻 |
| ⚠️ 改防火墙前先备份规则 | `iptables-save > /tmp/iptables.bak` |
| ⚠️ 跨国网络问题不靠运维 | 通常要找 ISP 或换线路 |
| ✅ 多用 mtr 替代 traceroute | 持续统计丢包率 |
| ✅ 先本机后外部 | 本机网卡/路由正常再看上游 |

## 一键诊断

参考 `scripts/network_diag.sh`，自动收集：
- 网卡状态
- IP/路由
- DNS 配置
- 监听端口
- 远程连通性
- 抓包样本

适合贴到工单反馈。