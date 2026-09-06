# SSH 常见报错对照表

| 报错信息 | 可能原因 | 排查方向 |
|---|---|---|
| `Connection refused` | 端口未监听 / 服务未启 / 防火墙拒 | Layer 2-3 |
| `Connection timed out` | 网络不通 / 防火墙丢包 | Layer 1-2 |
| `No route to host` | 路由不可达 / 目标机宕机 | Layer 1 |
| `Permission denied (publickey)` | 密钥不匹配 / 权限错 / authorized_keys 无此 key | Layer 4 |
| `Permission denied (password)` | 密码错 / PasswordAuthentication no | Layer 4 |
| `Too many authentication failures` | ssh-agent 携带 key 太多 / MaxAuthTries 过低 | Layer 4 |
| `Host key verification failed` | known_hosts 与服务器指纹不符（被中间人或重装） | 删除旧条目重连 |
| `REMOTE HOST IDENTIFICATION HAS CHANGED!` | 同上，强烈警告 | 确认是重装后删除旧 key |
| `ssh: Could not resolve hostname` | DNS 解析失败 | 检查 /etc/resolv.conf 或 hosts |
| `PTY allocation request failed` | 服务器 sshd 配置问题 | 检查 UsePAM |
| `bash: rsync: command not found` | 服务器没装 rsync | 改 scp 或装 rsync |
| `kex_exchange_identification` | SSH 协议协商失败 | 升级客户端或放宽服务端算法配置 |
| `sign_and_send_pubkey: signing failed` | 密钥权限错或 ssh-agent 异常 | chmod 600 + ssh-add |