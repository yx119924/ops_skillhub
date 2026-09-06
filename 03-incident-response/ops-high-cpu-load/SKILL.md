---
name: ops-high-cpu-load
description: Linux 服务器 CPU 负载过高（load average 高、单核占用高）排查 SOP。当用户报告「CPU 占用高」「load average 高」「服务器卡顿」「系统响应慢」「进程占用 CPU 高」「服务无响应」时自动使用。基于「系统级 → 进程级 → 线程级 → 抓栈」分层诊断，每层给出具体命令和判断标准。
agent_created: true
---

# CPU 负载过高排查 SOP

## 何时使用

触发场景（满足任一即调用）：
- 用户报告服务器卡顿、慢、响应时间长
- 监控告警：CPU > 80%、load average > CPU 核数
- 关键词：「CPU 高」「负载高」「load 高」「卡顿」「慢」「CPU 100%」「响应慢」
- 服务进程异常占用

## 关键概念

| 指标 | 含义 | 异常阈值 |
|---|---|---|
| **CPU 使用率** | 实际跑指令的时间占比 | > 80% 持续 5 分钟 |
| **Load Average** | 单位时间内的平均活跃任务数（含就绪+不可中断） | > CPU 核数 |
| **iowait** | 等 IO 完成的时间（磁盘慢会高） | > 20% |
| **CPU 上下文切换** | 进程/线程切换频率 | > 10000/s 持续 |

**核心判断**：
- CPU 高 + Load 高 → 真有进程占 CPU
- CPU 不高 + Load 高 → 多半是 iowait（卡在 IO）
- CPU 高 + Load 不高 → 单核打满，其他核空闲（线程少）

---

## 排查流程（按顺序执行）

### 第一步：系统级（top / uptime）

\`\`\`bash
# 1. 看系统总体负载
uptime
# 输出示例：load average: 4.21, 4.53, 4.81（1/5/15分钟）

# 2. 看 CPU 核数
nproc
grep -c ^processor /proc/cpuinfo

# 3. 看 CPU 使用率（按用户/系统/iowait 分项）
top -bn1 | head -20

# 或更清晰的 mpstat（需 sysstat）
mpstat 1 5
\`\`\`

**判断标准**：
- `load average` > `nproc` → 负载真高，进入下一步
- `%wa`（iowait）> 20% → 卡 IO，跳到 IO 排查方向
- `%us`（用户态）> 80% → 用户进程占用大，进入第二步
- `%sy`（系统态）> 20% → 内核态高，可能是系统调用过多或网卡/磁盘中断

### 第二步：进程级（找谁占用 CPU）

\`\`\`bash
# 1. 按 CPU 排序的进程（top 风格）
ps aux --sort=-%cpu | head -15
# 或
top -bn1 -o %CPU | head -15

# 2. 看进程树关系
pstree -p <PID>
ps -ef --forest | grep -A5 <PID>

# 3. 看进程命令行和启动时间
ps -o pid,user,pri,ni,vsz,rss,stat,start,time,cmd -p <PID>

# 4. 看进程打开的文件数和 fd
ls /proc/<PID>/fd | wc -l
cat /proc/<PID>/status | grep -E "Threads|VmRSS"
\`\`\`

**判断标准**：
- 单进程 CPU > 80% → 进入第三步抓栈
- 多个进程各占 10-20% → 多线程/多进程型，看业务是否合理
- 系统进程（systemd、migration）占 → 内核态问题

### 第三步：线程级（同一个进程里谁在跑）

\`\`\`bash
# 1. 按线程 CPU 排序
ps -eLo pid,tid,pcpu,stat,comm --sort=-pcpu | head -20

# 2. 看进程内每个线程
top -H -p <PID>

# 3. 看线程名（TID → 16 进制转成 nid）
ps -eLo pid,tid,pcpu,stat,comm | grep <PID>
\`\`\`

**判断标准**：
- 线程名有 GC / JIT / Compiler → 应用层问题
- 线程名是 `kworker` / `ksoftirqd` → 内核线程，处理中断或 workqueue
- 多线程均匀高 → 应用逻辑问题（死循环、计算密集）

### 第四步：抓栈（jstack / pstack）

\`\`\`bash
# Java 进程
jstack <PID> | head -100
# 多次采样看变化
for i in 1 2 3; do
  jstack <PID> > /tmp/jstack_$i.txt
  sleep 2
done

# C/C++/Go/Python 进程
sudo cat /proc/<PID>/stack     # 内核栈
sudo strace -p <PID> -c        # 统计系统调用

# perf（万能，性能采样）
sudo perf top -p <PID> -g      # 看热点函数
sudo perf record -p <PID> -g -- sleep 10
sudo perf report
\`\`\`

**判断标准**：
- Java 栈停在 GC → 内存压力、内存泄漏
- Java 栈停在业务方法 → 业务逻辑问题
- C 进程栈停在 syscall → 系统调用密集（IO/网络）
- 栈没有变化 → 真死循环

### 第五步：根因定位（结合上下文）

| 现象 | 根因方向 | 验证方法 |
|---|---|---|
| iowait 高 + CPU 高 | 磁盘慢（看磁盘工具） | iotop、vmstat 1 |
| us 高 + 单进程 | 应用 bug / 配置错 | 抓栈 |
| sy 高 + 网络密集 | 网卡软中断 | `cat /proc/softirqs` |
| us 高 + GC 频繁 | 内存问题 | jstat、jmap |
| CPU 不高 + Load 高 | iowait / D 状态进程 | `ps -eo stat,pid` | 找 D 进程 |

---

## 快速止血（kill 之前先尝试）

\`\`\`bash
# 1. 降低进程优先级（nice 值）
sudo renice +19 <PID>

# 2. 限制进程 CPU 使用（需 cgroup）
sudo systemctl set-property <service> CPUQuota=80%

# 3. 重启服务（最粗暴但有效）
sudo systemctl restart <service>

# 4. 杀进程（最后手段）
sudo kill -15 <PID>     # 优雅退出
sudo kill -9 <PID>      # 强制杀（数据可能丢）
\`\`\`

---

## 输出格式

排查完成后给出：
1. **负载现状**：uptime 输出 + CPU 核数 + 占用率分解
2. **TOP 进程**：占用 CPU 最高的 3-5 个进程/线程
3. **根因分析**：基于栈/调用链的判断
4. **临时止血**：renice / restart / kill
5. **长期方案**：扩容 / 代码优化 / 限流 / 缓存

## 注意事项

| 红线 | 说明 |
|---|---|
| ❌ 不要盲目 kill -9 数据库进程 | 数据可能丢，要先 graceful shutdown |
| ❌ 不要直接改 sysctl 内核参数 | 可能影响系统稳定性 |
| ⚠️ 抓栈前确认权限 | strace/perf 需要 root 或 cap_sys_ptrace |
| ⚠️ Load 高不一定是 CPU 问题 | iowait 高也会拉高 load |
| ✅ 多次采样对比 | 一次抓栈可能只是瞬时状态 |
| ✅ 看趋势比看绝对值重要 | 持续高 vs 瞬时尖峰 |

## 一键诊断脚本

参考 `scripts/cpu_diag.sh`，自动收集：
- 系统负载
- TOP 进程
- 热点线程
- CPU 使用率分解
- 上下文切换

输出适合贴到工单或群里反馈。