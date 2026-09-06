# SSH 客户端配置基线（推荐）

## ~/.ssh/config 模板

\`\`\`sshconfig
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
    HashKnownHosts yes
    UserKnownHostsFile ~/.ssh/known_hosts

# 开发机
Host dev
    HostName 192.168.1.100
    User ops
    Port 22
    IdentityFile ~/.ssh/id_rsa_dev

# 跳板机模式（连接内网机器）
Host intranet-*
    User ops
    ProxyCommand ssh -W %h:%p jumpuser@jumphost
    IdentityFile ~/.ssh/id_rsa_intranet
\`\`\`

## sshd_config 服务端基线

\`\`\`sshdconfig
# 端口（可改非 22 减少扫描）
Port 22

# 协议版本
Protocol 2

# 认证
PasswordAuthentication no           # 生产强制密钥
PubkeyAuthentication yes
PermitRootLogin prohibit-password   # 禁止 root 密码登录
MaxAuthTries 6
LoginGraceTime 30

# 安全
X11Forwarding no
AllowTcpForwarding no               # 按需开启
PermitEmptyPasswords no

# 日志
LogLevel VERBOSE

# 仅允许特定用户/组
AllowGroups ssh-users
\`\`\`