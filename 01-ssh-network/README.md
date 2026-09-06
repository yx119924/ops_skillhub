# 01-ssh-network ｜ SSH 与网络

SSH 连接、网络诊断、路由追踪、防火墙审计等相关 Skill。

---

## ✅ 已收录

| Skill | 说明 | 版本 |
|---|---|---|
| [ops-ssh-troubleshoot](./ops-ssh-troubleshoot/) | SSH 连接失败时的标准排查 SOP（5 层诊断 + 常见报错对照） | v1.0 |
| [ops-network-diagnose](./ops-network-diagnose/) | 网络不通/丢包/延迟高/DNS 故障排查（物理→网络→传输→应用） | v1.0 |

---

## 🚧 规划中

| Skill | 解决场景 |
|---|---|
| `ops-vlan-stp-troubleshoot` | VLAN / STP 配置错误、广播风暴 |
| `ops-firewall-rules-check` | 防火墙规则审计（iptables / nftables） |
| `ops-wireguard-deploy` | WireGuard 部署（适合 UDP 受限网络） |

---

## 安装

```bash
# 一键安装本分类所有 skill
./install.sh --category 01-ssh-network

# 或安装单个
./install.sh ops-ssh-troubleshoot
./install.sh ops-network-diagnose
```