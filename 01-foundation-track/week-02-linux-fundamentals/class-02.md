# Week 2: Linux Fundamentals for Cloud and DevOps
> **▶ Runnable lab for this class:** [`labs/linux-shell-automation/`](../../labs/linux-shell-automation/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 2 Package: Linux Processes, Services, Logs, and Troubleshooting

**Track:** Unified DevOps · Cloud · SRE Track

---

## 1. Class Overview

**Class title:** Class 2: Linux Operations and Troubleshooting for Cloud Servers

**Class purpose:** Teach students how to move from Linux file navigation into real operational troubleshooting. Students inspect processes, services, logs, disk, memory, and SSH access patterns used on cloud Linux servers.

**How this class builds from Class 1:** Class 1 focused on filesystem navigation, files, users, groups, ownership, permissions, and fixing script execution with `chmod +x`. Class 2 extends that foundation into running systems: services, processes, logs, resource checks, SSH, and evidence-based troubleshooting.

**What students will practice:**

- Checking and interpreting system health with `df`, `du`, `free`, `uptime`, and `nproc`
- Inspecting processes with `ps`, `top`, and `pgrep`
- Managing services with `systemctl` and confirming listening ports with `ss -tulnp`
- Reading logs with `journalctl`
- Accessing cloud Linux servers with SSM Session Manager (primary) and SSH (break-glass)
- Scheduling recurring work with cron and systemd timers
- Troubleshooting a failed service caused by disk/log issues
- Creating a Linux troubleshooting checklist

---

## 2. Quick Review of Class 1

### Review Points

1. Linux is common on cloud servers, containers, CI/CD runners, and Kubernetes nodes.
2. `pwd`, `ls`, and `cd` help confirm where you are before taking action.
3. `/etc`, `/var/log`, `/home`, and `/tmp` are important Linux directories.
4. `cat`, `less`, `head`, `tail`, and `grep` help inspect text files and logs.
5. `ls -l` shows file permissions, ownership, and metadata.
6. `chmod +x` fixes a script that cannot execute.
7. `chmod 777` is unsafe and should not be used as a default fix.
8. Permissions affect both security and reliability.

### Quick Recall Questions

1. Which command shows your current directory?  
   **Answer:** `pwd`

2. Which command shows file permissions and ownership?  
   **Answer:** `ls -l`

3. What permission is required to run a script?  
   **Answer:** Execute permission, shown as `x`

### Common Gaps

| Gap | Instructor Bridge |
|---|---|
| Confusing `/` and `/root` | Redraw the filesystem tree briefly |
| Forgetting to check `pwd` | Reinforce “location first, action second” |
| Overusing `sudo` | Remind students to investigate before escalating privileges |
| Using `chmod 777` | Reframe permissions around least privilege |
| Forgetting `./script.sh` | Show that Linux does not automatically search the current directory |

**Bridge into Class 2:**  
Last class answered “Where are the files and who can use them?” This class answers “Is the system running correctly, and what evidence proves the root cause?”

---

## 3. Class Learning Objectives

By the end of this class, students will be able to:

1. **Explain** the difference between a process and a service.
2. **Inspect** running processes using `ps`, `top`, and `pgrep`.
3. **Validate and interpret** system health using `df`, `du`, `free`, `uptime`, and `nproc` (load vs cores, available vs free memory).
4. **Manage** Linux services using `systemctl`, and confirm listening ports with `ss -tulnp`.
5. **Troubleshoot** service issues using `systemctl status` and `journalctl`.
6. **Access** cloud Linux servers using SSM Session Manager (primary, keyless) and SSH (legacy/break-glass).
7. **Schedule** recurring operational tasks with cron and systemd timers.
8. **Analyze** logs and resource usage to identify why a service failed.
9. **Document** a Linux troubleshooting checklist for cloud operations.

---

## 4. Prerequisites Students Should Already Know

### Required Class 1 Knowledge

Students should know how to:

- Use `pwd`, `ls`, and `cd`
- Create files and folders
- Read file content with `cat`, `less`, `tail`, and `grep`
- Read permissions using `ls -l`
- Fix script execution using `chmod +x`
- Explain basic users, groups, and ownership

### Required Prior Concepts

- A server runs applications.
- Applications generate logs.
- Commands can succeed or fail.
- Cloud virtual machines often run Linux.
- Troubleshooting requires careful reading of error messages.

### Required Tools

- Linux VM, WSL with systemd enabled, cloud Linux sandbox, or AWS EC2 Linux instance
- Terminal
- VS Code, optional
- SSH client
- AWS CLI, optional

### Starting Point From Class 1

Helpful but not required:

```text
~/week2-linux-lab
```

---

## 5. Key Terms and Definitions

| Term | Definition | Real-World Context |
|---|---|---|
| Process | A running program | Web servers, scripts, and agents run as processes |
| PID | Process ID | Used to inspect or stop a specific process |
| Service | A long-running background process | `nginx`, `ssh`, app services, and monitoring agents |
| Daemon | Background service | Many system services run as daemons |
| `systemd` | Linux service manager | Common on modern Linux systems |
| `systemctl` | Command to manage services | Check, start, stop, restart, enable, or disable services |
| `journalctl` | Command to read systemd logs | Useful for diagnosing service failures |
| Log | Record of system or application activity | Evidence during incidents |
| Disk usage | Storage consumed by filesystems | Full disks can stop services |
| Memory usage | RAM consumed by processes | Low memory can cause instability |
| SSH | Secure Shell for remote access | Legacy/break-glass way to connect to EC2; needs port 22 and a key |
| SSM Session Manager | Keyless, audited shell access via AWS Systems Manager | Modern 2026 default: no inbound port 22, no key files, IAM-controlled |
| Port | Network endpoint used by a service | SSH uses 22, HTTP uses 80, HTTPS uses 443 |
| Listening socket | A port a service is actively accepting connections on | `ss -tulnp` confirms a service is actually listening |
| Load average | 1/5/15-minute run-queue length from `uptime` | Compared against core count to judge saturation |
| cron / systemd timer | Mechanisms that run jobs on a schedule | Log rotation, backups, health checks, cleanup tasks |

---

## 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| `ps aux` | Lists running processes |
| `top` | Shows real-time CPU and memory usage |
| `pgrep` | Finds process IDs by name |
| `kill` | Stops a process by PID |
| `df -h` | Shows filesystem disk usage |
| `du -sh` | Shows size of files or directories |
| `free -h` | Shows memory usage |
| `uptime` | Shows uptime and load average |
| `who` | Shows logged-in users |
| `systemctl` | Manages services |
| `journalctl` | Reads service and system logs |
| `tail` | Views the end of logs |
| `grep` | Searches logs and files |
| `ss -tulnp` | Shows listening TCP/UDP ports and owning process (modern `netstat`) |
| `lsof` | Lists open files and the ports/files a process holds |
| `ssh` | Connects to remote Linux servers (legacy / break-glass) |
| `aws ssm start-session` | Modern keyless access to EC2 via Session Manager (primary path) |
| `crontab` | Schedules recurring jobs with cron |
| `systemd timers` | Modern scheduled units managed by systemd |
| `chmod` | Fixes script or SSH key permissions |

---

## 7. AWS Services Used

| AWS Service | Class Connection |
|---|---|
| Amazon EC2 | Linux servers in AWS are EC2 instances |
| Systems Manager (SSM) Session Manager | Modern, keyless, audited shell access — the **primary** 2026 access path; no inbound port 22 |
| EC2 Key Pairs | Private keys for legacy/break-glass SSH access |
| Security Groups | Only needed for SSH (port 22); SSM needs **no** inbound rule |
| EBS Volumes | Disk checks often inspect filesystems backed by EBS |
| CloudWatch Logs | Used to centralize logs from servers (Week 16 observability) |
| IAM | Controls who may open an SSM session and what they may do |

### AWS Safety Notes

If EC2 is used:

- Use a small instance type.
- Stop or terminate the instance after class.
- Do not leave unused EBS volumes.
- Do not open SSH broadly in real environments.
- Use least privilege IAM access.

---

## 8. Azure and GCP Comparison Notes

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Linux server | EC2 | Azure Linux VM | Compute Engine VM |
| Disk | EBS | Managed Disk | Persistent Disk |
| Firewall | Security Group | Network Security Group | Firewall Rule |
| Remote access | SSH or Systems Manager | SSH or Azure Bastion | SSH or IAP TCP forwarding |
| Logs | CloudWatch Logs | Azure Monitor Logs | Cloud Logging |

The Linux commands are mostly the same across AWS, Azure, and GCP. The cloud provider changes access, networking, and disk attachment, but inside the server the investigation flow is similar.

---

## 9. Time-Boxed Instructor Agenda

| Time | Section | Activity |
|---:|---|---|
| 0:00 - 0:10 | Class 1 review | Filesystem, permissions, and script execution |
| 0:10 - 0:35 | Processes and reading system health | `ps`, `top`, `free`, `uptime` — and how to *interpret* load average and memory (Section 11) |
| 0:35 - 1:00 | Services, `systemctl`, and listening ports | Service states, `systemctl`, `ss -tulnp` in the main flow |
| 1:00 - 1:20 | Logs | `journalctl`, service logs, error evidence |
| 1:20 - 1:30 | Break | Short break |
| 1:30 - 1:55 | Cloud access: SSM Session Manager (primary) + SSH (legacy) | Demo keyless SSM; pem-SSH as break-glass (Section 11) |
| 1:55 - 2:10 | Scheduling: cron and systemd timers | `crontab`, a `.timer`/`.service` pair (Section 11) |
| 2:10 - 2:35 | Instructor demo | Failed service investigation |
| 2:35 - 2:52 | Student lab | Service, port, and log troubleshooting |
| 2:52 - 2:57 | Discussion | Production troubleshooting flow |
| 2:57 - 3:00 | Wrap-up | Homework and Week 3 (Git) preview |

---

## 10. Instructor Lesson Plan

### Step 1: Start With Review

Ask:

- How do you check your current directory?
- How do you check file permissions?
- What does `chmod +x` do?
- Why is `chmod 777` unsafe?

Transition: Class 1 focused on files. Class 2 focuses on what is running, what is failing, and what the system is telling us.

### Step 2: Explain Processes

Show:

```bash
ps aux | head
top
pgrep ssh
```

Explain that a process is a running program, every process has a PID, and processes consume CPU and memory.

Pause and ask: If a web application is down, why might checking processes help?

### Step 3: Explain Resource Checks

Show:

```bash
df -h
free -h
uptime
du -sh /var/log
```

Explain:

- `df -h` checks filesystem usage.
- `du -sh` finds what is consuming space.
- `free -h` shows memory usage.
- `uptime` shows uptime and load average.

Do not just run these — teach students to *read* them. Section 11 ("Reading `uptime`, `free`, and `top` Meaningfully") covers load-average-vs-core-count and the "Linux ate my RAM" cache confusion. Cover that interpretation here.

### Step 4: Explain Services, `systemctl`, and Listening Ports

Show:

```bash
systemctl status ssh
systemctl list-units --type=service --state=running
```

If using nginx:

```bash
systemctl status nginx
```

Explain service states: active, inactive, failed, enabled, disabled.

Then immediately confirm the service is actually *listening* — a service can be "active" yet not accepting connections on the expected port:

```bash
ss -tulnp           # t=tcp u=udp l=listening n=numeric p=process (needs sudo to see process)
sudo ss -tulnp | grep ':22'    # is sshd listening on 22?
sudo ss -tlnp | grep ':80'     # is the web server listening on 80?
```

Teaching point:
> `ss -tulnp` belongs in the *first* round of service triage, not as an advanced extra. `netstat` is deprecated on modern distros; `ss` is the replacement. "Is the service running?" and "is it listening on the right port?" are two different questions — answer both.

### Step 5: Explain Logs and `journalctl`

Show:

```bash
journalctl -u ssh --no-pager | tail
journalctl -p err --since "1 hour ago"
```

Explain that logs provide evidence and should be reviewed before guessing or restarting services.

### Step 6: Explain Cloud Access — SSM Session Manager First, SSH as Break-Glass

In 2026 the default, recommended way to get a shell on an EC2 instance is **AWS Systems Manager (SSM) Session Manager**, not SSH with a `.pem` file. SSM needs no inbound port 22, no key files to distribute or rotate, and every session is authorized by IAM and audited in CloudTrail. Teach this as primary; teach pem-SSH as the legacy / break-glass fallback.

```text
                 SSM Session Manager (primary)            SSH (legacy / break-glass)
Engineer ── IAM auth ──► SSM ──► SSM Agent on EC2          Engineer ── key.pem ──► port 22 ──► sshd on EC2
   - no inbound port 22, no key files                         - inbound 22 open in security group
   - session logged in CloudTrail                             - private key must be protected & rotated
   - access controlled by IAM policy                          - works even if SSM agent is broken
                 │                                                          │
                 ▼                                                          ▼
                      AWS EC2 Linux Instance ──► Linux shell ──► processes, services, logs, files
```

**Modern path (SSM Session Manager) — demonstrate this (see Section 13 demo):**

```bash
# Prereqs (one-time): instance has the SSM Agent (default on current Amazon Linux/Ubuntu AMIs),
# an instance profile with the AmazonSSMManagedInstanceCore policy, and outbound 443 to SSM endpoints.
aws ssm describe-instance-information \
  --query "InstanceInformationList[].InstanceId" --output text   # confirm the instance is registered

aws ssm start-session --target i-0123456789abcdef0               # opens an interactive shell, no key, no port 22
# inside the session you land as ssm-user; run: whoami, sudo su - ec2-user, then normal Linux commands
exit                                                             # ends the session
```

**Legacy path (pem-based SSH) — keep for break-glass only:**

```bash
chmod 400 key.pem                       # key must be owner-read-only or ssh refuses it
ssh -i key.pem ec2-user@<public-ip>     # Amazon Linux user is ec2-user; Ubuntu is ubuntu
```

Teaching point:
> If a reviewer sees "open port 22 to 0.0.0.0/0 and hand out a .pem" as the *default* access design in 2026, that is a red flag. Prefer SSM Session Manager (keyless, audited, no inbound port). Keep one break-glass key path for when the SSM agent itself is broken.

Cost/security/cleanup note:
> SSM Session Manager itself has no extra charge for interactive sessions. If you launch an EC2 instance to practice, use a small type (e.g. `t3.micro`), and **stop or terminate it after class** and remove any unused EBS volumes. Never commit a `.pem` file to Git.

### Step 6.5: Explain Scheduling — cron and systemd Timers

Operational work is rarely one-off: log rotation, backups, certificate renewal, and health checks all run on a schedule. Two mechanisms do this on Linux.

**cron** (classic, per-user):

```bash
crontab -e          # edit the current user's cron jobs
crontab -l          # list them
```

A cron line has five time fields then the command:

```text
# ┌ minute (0-59)
# │ ┌ hour (0-23)
# │ │ ┌ day of month (1-31)
# │ │ │ ┌ month (1-12)
# │ │ │ │ ┌ day of week (0-6, 0=Sunday)
# │ │ │ │ │
  0 2 * * *  /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1   # every day at 02:00
  */15 * * * * /usr/local/bin/health-check.sh                       # every 15 minutes
```

**systemd timers** (modern, preferred on systemd hosts) — a `.timer` unit triggers a matching `.service` unit. They give logging via `journalctl`, dependency control, and `OnCalendar` schedules:

```ini
# /etc/systemd/system/health-check.service
[Unit]
Description=Run health check

[Service]
Type=oneshot
ExecStart=/usr/local/bin/health-check.sh
```

```ini
# /etc/systemd/system/health-check.timer
[Unit]
Description=Run health check every 15 minutes

[Timer]
OnCalendar=*:0/15
Persistent=true

[Install]
WantedBy=timers.target
```

Enable and inspect:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now health-check.timer
systemctl list-timers --all          # see next/last run times
journalctl -u health-check.service   # see the job's output (cron has no built-in equivalent)
```

Teaching point:
> Use cron when it is already there and the task is trivial. Prefer systemd timers on modern servers because the run output lands in `journalctl`, failures are visible via `systemctl`, and scheduling (`OnCalendar`) is more expressive. Either way, redirect cron output to a log or you will never see why a job failed.

### Step 7: Instructor Demo

Run the failed service demo in Section 13.

### Step 8: Student Lab

Students complete the lab in Section 14.

### Step 9: Troubleshooting Activity

Run the disk-full service failure scenario.

### Step 10: Wrap Up

Preview Week 3: **Git and version control** — branching, commits, pull requests, and how the scripts and configs students just edited on a server get tracked, reviewed, and shipped. (The networking layer — DNS, ports, routes, firewalls, HTTP/TLS, and VPC — is covered later in Week 5.)

---

## 11. Instructor Lecture Notes

### Processes Are Running Programs

A process is any program currently running on the server. When students open a shell, that shell is a process. When a web server runs, it has one or more processes. When a script runs, it becomes a process for the duration of execution.

Useful command:

```bash
ps aux
```

Talking point:

> If an application is supposed to be running but there is no process for it, the problem is probably not the network yet. First confirm whether the app is actually running.

### Services Are Managed Background Processes

A service is usually a long-running background process controlled by the system.

Examples:

- SSH service
- Web server
- Database service
- Application service
- Monitoring agent
- Logging agent

Common commands:

```bash
systemctl status nginx
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
sudo systemctl disable nginx
```

Talking point:

> `systemctl status` is one of the most valuable first commands during Linux service troubleshooting.

### Logs Are Evidence

Useful commands:

```bash
journalctl -u nginx --no-pager
journalctl -u nginx --since "30 minutes ago"
journalctl -p err --since "1 hour ago"
tail -f /var/log/syslog
grep -i error /var/log/syslog
```

Logs may be noisy or incomplete. Combine logs with service status, resource checks, and recent change history.

### Disk Full Is a Classic Production Issue

A full disk can cause:

- Services failing to start
- Applications failing to write logs
- Databases becoming unhealthy
- Deployments failing
- SSH instability
- Package install failures

Useful commands:

```bash
df -h
du -sh /var/log/*
du -sh /*
```

Production warning: Never delete logs blindly. Preserve evidence, use approved cleanup, configure log rotation, and add alerts.

### Reading `uptime`, `free`, and `top` Meaningfully

Running these commands is easy; *interpreting* them is the skill. Deep performance methodology (the USE method, `strace`, `/proc`) comes later in the SRE and performance weeks (Week 21–22), but students need basic literacy now or the resource checks are just noise.

**`uptime` — load average vs core count:**

```bash
uptime
```

```text
 14:02:31 up 5 days,  3:11,  2 users,  load average: 0.42, 1.85, 2.10
```

- The three numbers are the average number of processes runnable/uninterruptible over the last **1, 5, and 15 minutes**.
- Interpret load **relative to CPU core count**. Check cores with `nproc`. A load of `2.10` on an 8-core box is fine; the same `2.10` on a 1-core box means the run queue is backed up.
- Compare the three numbers for *trend*: `0.42, 1.85, 2.10` is **falling** (recent < older) — the spike is recovering. Rising numbers mean it is getting worse.

```bash
nproc          # how many cores — the denominator for load average
```

**`free -h` — the "Linux ate my RAM" confusion:**

```bash
free -h
```

```text
               total        used        free      shared  buff/cache   available
Mem:           7.7Gi       1.2Gi       0.3Gi       0.1Gi       6.2Gi       6.1Gi
Swap:          2.0Gi          0B       2.0Gi
```

- Low `free` is **normal and good**. Linux uses otherwise-idle RAM for `buff/cache` (disk cache) and gives it back instantly when applications need it.
- The number that matters is **`available`** — that is how much memory new programs can actually get. Here 6.1Gi is available even though only 0.3Gi is "free."
- Watch **`Swap` used**: if swap is filling up, the system is under real memory pressure and may be thrashing.

**`top` — the header and the key columns:**

```bash
top      # press q to quit; press M to sort by memory, P to sort by CPU
```

- Header `load average:` matches `uptime`.
- `%Cpu(s)` line: `us` = user CPU, `sy` = system/kernel, `id` = idle, and **`wa` = I/O wait**. High `wa` means the CPU is stalled waiting on disk/network, not computing — a different problem from high `us`.
- Per-process columns: `%CPU`, `%MEM`, `RES` (resident memory actually in RAM), and `COMMAND`. Sort with `P` (CPU) or `M` (memory) to find the heavy process.

Teaching point:
> Three quick reads tell you a lot: load average vs `nproc` (CPU saturation?), `available` in `free` and swap usage (memory pressure?), and `%wa` in `top` (stuck on I/O?). That triage is enough at this stage; depth comes in the SRE/performance weeks.

### Connecting to Remote Linux Servers — SSM First, SSH Second

The modern default for EC2 shell access is **SSM Session Manager** (keyless, no inbound port 22, IAM-controlled, CloudTrail-audited):

```bash
aws ssm start-session --target i-0123456789abcdef0
```

Use pem-based **SSH** as the legacy / break-glass path (for example, when the SSM agent itself is broken):

```bash
ssh -i key.pem ec2-user@<public-ip>     # Amazon Linux
ssh -i key.pem ubuntu@<public-ip>       # Ubuntu
```

**Common SSM access problems:**

- Instance missing an instance profile with `AmazonSSMManagedInstanceCore`
- SSM agent not running, or no outbound 443 to SSM endpoints (no NAT / no VPC endpoint)
- IAM user/role lacks `ssm:StartSession`
- AWS CLI Session Manager plugin not installed locally

**Common SSH problems:**

- Wrong private key
- Key permissions too open (must be `chmod 400`)
- Wrong username (`ec2-user` vs `ubuntu`)
- Security group missing inbound port 22
- Instance has no public IP (or you are not on the right network)
- SSH service not running
- Route or firewall issue

Teaching point:
> Notice the failure modes differ. SSM problems are IAM/agent/endpoint issues; SSH problems are key/port/network issues. Knowing which path you are on tells you which list to triage.

---

## 12. Whiteboard Explanation

### Class 1 to Class 2 Progression

```text
Class 1: Files and Permissions
|
|-- Where am I?
|-- What files exist?
|-- Who owns this file?
|-- Can this script run?
|
v
Class 2: Running Systems
|
|-- Is the process running?
|-- Is the service healthy?
|-- What do the logs say?
|-- Is disk or memory causing the issue?
|-- Can I connect through SSH?
```

### Linux Troubleshooting Flow

```text
Application Not Working
        |
        v
1. Can I access the server?
   - SSM Session Manager (primary)
   - ssh + correct user + key permissions (break-glass)
        |
        v
2. Is the service running AND listening?
   - systemctl status
   - ps aux
   - ss -tulnp (listening on the right port?)
        |
        v
3. What do logs say?
   - journalctl
   - /var/log
        |
        v
4. Are resources healthy?
   - df -h
   - free -h
   - top
        |
        v
5. Was there a recent change?
   - deployment
   - config change
   - permission change
```

### Enterprise Version

```text
Enterprise App Server
|
|-- Application Service
|   |-- managed by systemd
|
|-- Config Files
|   |-- controlled by deployment process
|
|-- Logs
|   |-- reviewed during incidents
|   |-- shipped to monitoring platform
|
|-- Cloud Controls
|   |-- IAM
|   |-- Security Groups
|   |-- EBS
|   |-- CloudWatch
|
|-- Operational Controls
    |-- change approval
    |-- runbooks
    |-- incident timeline
    |-- postmortem
```

---

## 13. Instructor Demo Script

### Demo Title

**Investigating a Failed Linux Service**

### Demo Objective

Show students how to troubleshoot a failed service using `systemctl`, `journalctl`, process checks, and disk checks.

### Required Setup

Recommended:

- Ubuntu VM, WSL with systemd enabled, or EC2 Ubuntu instance
- `sudo` access
- Internet access if installing nginx

Alternative:

- Amazon Linux EC2 instance
- Use simulated outputs if package installation is unavailable

### Demo Option 0 (Recommended): Connect With SSM Session Manager Instead of SSH

Demonstrate the modern keyless access path before any service work. Run this from the instructor laptop with AWS CLI v2 and the Session Manager plugin installed.

```bash
# 1. Confirm the instance is registered with SSM (proves agent + instance profile are working)
aws ssm describe-instance-information \
  --query "InstanceInformationList[].[InstanceId,PingStatus,PlatformName]" --output table

# 2. Open an interactive shell — no key file, no port 22, no public IP required
aws ssm start-session --target i-0123456789abcdef0

# 3. Inside the session (you start as ssm-user):
whoami
sudo su - ec2-user        # or stay as ssm-user; both can sudo per instance config
uptime
exit                      # leave the elevated shell

# 4. End the SSM session
exit
```

Expected (abridged):

```text
-------------------------------------------------
|        DescribeInstanceInformation            |
+----------------------+----------+-------------+
|  i-0123456789abcdef0 |  Online  |  Amazon Linux|
+----------------------+----------+-------------+

Starting session with SessionId: ...
sh-5.2$ whoami
ssm-user
```

Talking points:
> No `.pem`, no `chmod 400`, no inbound port 22 in the security group. Access is granted by IAM and the whole session is recorded in CloudTrail. This is the access pattern a 2026 reviewer expects to see; pem-SSH (Option below) is the break-glass fallback.

Cost/cleanup note:
> If you launched a practice instance, use `t3.micro`, and **stop or terminate it after the demo**; delete unused EBS volumes. SSM interactive sessions incur no extra service charge.

If SSM is not available (no AWS account in class), fall back to SSH and state clearly that it is the legacy path:

```bash
chmod 400 key.pem
ssh -i key.pem ec2-user@<public-ip>
```

### Demo Option A: Ubuntu or Debian

Install nginx:

```bash
sudo apt update
sudo apt install nginx -y
```

Check status:

```bash
systemctl status nginx
```

Expected:

```text
Active: active (running)
```

Check process:

```bash
ps aux | grep nginx
```

Confirm it is listening, then validate locally:

```bash
sudo ss -tlnp | grep ':80'    # nginx should be listening on port 80
curl localhost
```

Expected:

```text
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=...))
Welcome to nginx!
```

Teaching point:
> `ss` proves the service is *listening*; `curl` proves it *responds*. If `ss` shows nothing on `:80`, the service is not bound — checking `curl` first would only tell you "connection refused" without saying why.

Stop service:

```bash
sudo systemctl stop nginx
systemctl status nginx
```

Expected:

```text
Active: inactive (dead)
```

Start again:

```bash
sudo systemctl start nginx
systemctl status nginx
```

Show logs:

```bash
journalctl -u nginx --no-pager | tail -20
```

Create controlled config failure:

```bash
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
echo "bad_directive;" | sudo tee -a /etc/nginx/nginx.conf
sudo nginx -t
```

Expected:

```text
nginx: [emerg] unknown directive "bad_directive;"
nginx: configuration file /etc/nginx/nginx.conf test failed
```

Restart and inspect failure:

```bash
sudo systemctl restart nginx
systemctl status nginx
journalctl -u nginx --since "10 minutes ago" --no-pager
```

Recover:

```bash
sudo cp /etc/nginx/nginx.conf.backup /etc/nginx/nginx.conf
sudo nginx -t
sudo systemctl restart nginx
systemctl status nginx
```

Expected:

```text
nginx: configuration file /etc/nginx/nginx.conf test is successful
Active: active (running)
```

### Demo Option B: Amazon Linux

```bash
sudo yum install nginx -y
sudo systemctl start nginx
systemctl status nginx
curl localhost
journalctl -u nginx --no-pager | tail -20
```

### Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| `systemctl: command not found` | Environment does not use systemd | Use EC2, VM, or simulated outputs |
| `Unit nginx.service could not be found` | nginx not installed | Install nginx or use `ssh`/`sshd` |
| Permission denied editing config | Missing sudo | Use `sudo` carefully |
| `curl localhost` fails | Service not listening or not running | Check `systemctl status nginx` and `ss -tulnp` |
| Cannot install package | No internet or repo issue | Use simulated outputs |

### Cleanup Steps

```bash
sudo cp /etc/nginx/nginx.conf.backup /etc/nginx/nginx.conf
sudo systemctl restart nginx
sudo systemctl stop nginx
```

Optional package removal:

```bash
sudo apt remove nginx -y
```

For Amazon Linux:

```bash
sudo yum remove nginx -y
```

If using EC2, stop or terminate the instance after class.

---

## 14. Student Lab Manual

### Lab Title

**Linux Service and Log Troubleshooting Lab**

### Lab Objective

Students will check system health, inspect processes, view service status, read logs, and write a short troubleshooting report.

### Estimated Time

35 to 45 minutes

### Student Prerequisites

Students should know basic navigation, file reading, and permission concepts from Class 1.

### Starting Point From Class 1

Students may use:

```text
~/week2-linux-lab
```

### Workflow Overview

```text
Linux Server
|
|-- Processes: ps, top, pgrep
|-- Services: systemctl
|-- Logs: journalctl, tail
|-- Resources: df, du, free, uptime
```

### Step 1: Create a Report Folder

```bash
mkdir -p ~/week2-linux-lab/class2
cd ~/week2-linux-lab/class2
pwd
```

Expected:

```text
/home/student/week2-linux-lab/class2
```

### Step 2: Check Uptime

```bash
uptime
```

Write down current time, uptime, and load average.

### Step 3: Check Disk Usage

```bash
df -h
```

Question: Is any filesystem above 80%?

### Step 4: Check Directory Size

```bash
du -sh /var/log 2>/dev/null
```

Permission errors may appear on some systems. That is acceptable.

### Step 5: Check Memory

```bash
free -h
```

Question: Is memory critically low?

### Step 6: Check Processes

```bash
ps aux | head
top
```

Press `q` to exit `top`.

### Step 7: List Running Services

```bash
systemctl list-units --type=service --state=running | head
```

If `systemctl` does not work, notify the instructor.

### Step 7.5: Check Listening Ports

```bash
sudo ss -tulnp
sudo ss -tlnp | grep ':22'
```

Expected (a server with SSH up will show a listener on 22):

```text
LISTEN 0  128  0.0.0.0:22  0.0.0.0:*  users:(("sshd",pid=...))
```

Question: Which ports are open, and which process owns each one? This answers "is the service actually listening?" — a different question from "is the service active?"

### Step 8: Check SSH Service

Ubuntu/Debian:

```bash
systemctl status ssh
```

Amazon Linux/RHEL:

```bash
systemctl status sshd
```

Expected:

```text
Active: active (running)
```

### Step 9: View Service Logs

Ubuntu/Debian:

```bash
journalctl -u ssh --no-pager | tail -20
```

Amazon Linux/RHEL:

```bash
journalctl -u sshd --no-pager | tail -20
```

### Step 10: Search Recent Errors

```bash
journalctl -p err --since "1 hour ago" --no-pager
```

Possible healthy output:

```text
-- No entries --
```

### Step 11: Create Troubleshooting Report

```bash
cat > linux-health-report.txt <<'REPORT'
Linux Health Report

Uptime / load average (vs nproc cores):
Disk usage:
Memory available (not just free) + swap used:
Listening ports (ss -tulnp):
Service checked:
Service status:
Recent errors:
Recommended action:
REPORT
```

Fill in the report using command outputs.

### Expected Deliverable

`linux-health-report.txt` with:

- Uptime / load average summary (compared to core count)
- Disk usage summary
- Memory summary (available + swap, not just free)
- Listening ports summary
- Service checked
- Service status
- Recent errors found
- Recommended action

### Validation Checklist

```bash
pwd
df -h
free -h
uptime
nproc
sudo ss -tulnp
systemctl status ssh
journalctl -p err --since "1 hour ago" --no-pager
cat linux-health-report.txt
```

For Amazon Linux:

```bash
systemctl status sshd
```

### Troubleshooting Tips

| Problem | Likely Cause | Fix |
|---|---|---|
| `systemctl: command not found` | No systemd | Use instructor VM or simulated output |
| `Unit ssh.service could not be found` | Service name differs | Try `sshd` |
| Permission denied reading logs | User lacks access | Use `sudo` if allowed |
| `top` will not exit | Student is stuck in interactive view | Press `q` |
| No errors found | System may be healthy | Document “No recent errors found” |

### Cleanup Steps

No cleanup required unless nginx was installed.

Optional:

```bash
cd ~
rm -rf ~/week2-linux-lab/class2
```

### Reflection Questions

1. Which command gave the clearest view of system health?
2. Why is `systemctl status` useful, and why is `ss -tulnp` a *separate* check from it?
3. A load average of `3.0` — is that bad? What do you need to know to decide?
4. `free -h` shows almost no `free` memory but plenty `available`. Is the server low on memory? Why or why not?
5. Why should engineers check logs before restarting a service?
6. What could happen if disk usage reaches 100%?
7. Why is SSM Session Manager preferred over pem-based SSH for accessing EC2 in 2026?

### Optional Challenge

Install and test nginx if supported.

Ubuntu:

```bash
sudo apt update
sudo apt install nginx -y
systemctl status nginx
curl localhost
journalctl -u nginx --no-pager | tail -20
```

Amazon Linux:

```bash
sudo yum install nginx -y
sudo systemctl start nginx
systemctl status nginx
curl localhost
journalctl -u nginx --no-pager | tail -20
```

Cleanup:

```bash
sudo systemctl stop nginx
```

---

## 15. Troubleshooting Activity

### Incident Title

**Web Service Fails Because Disk Is Full**

### Business Impact

A production application server is not serving users after a deployment. The web service will not start, and the business application is unavailable.

### Symptoms

Application team reports:

```text
The server is reachable, but the web application is down.
The service restart failed after deployment.
```

Service status:

```bash
systemctl status webapp
```

Example:

```text
webapp.service - Internal Web Application
Loaded: loaded (/etc/systemd/system/webapp.service; enabled)
Active: failed (Result: exit-code)
Main PID: 2241 (code=exited, status=1/FAILURE)
```

Disk check:

```bash
df -h
```

Example:

```text
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       20G   20G     0 100% /
```

Logs:

```bash
journalctl -u webapp --since "30 minutes ago"
```

Example:

```text
ERROR: No space left on device
ERROR: Failed to write application log
ERROR: Service startup failed
```

### Student Investigation Steps

```bash
systemctl status webapp
journalctl -u webapp --since "30 minutes ago"
df -h
du -sh /*
du -sh /var/*
du -sh /var/log/*
```

Ask:

1. Is the service running?
2. What does service status show?
3. What do logs say?
4. Is disk full?
5. Which directory consumes space?
6. What is the safest fix?

### Expected Root Cause

The root filesystem is full. The service cannot start because it cannot write required log or temporary files.

### Correct Resolution

Training lab example:

```bash
sudo du -sh /var/log/*
sudo truncate -s 0 /var/log/app.log
sudo systemctl restart webapp
systemctl status webapp
```

Enterprise-safe approach:

1. Confirm the largest files.
2. Preserve important logs if needed.
3. Compress or rotate logs.
4. Clear only approved non-critical files.
5. Restart the service.
6. Validate the application.
7. Create prevention action items.

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Restarting repeatedly | Does not fix disk usage |
| Deleting random files | Can remove data or evidence |
| Blaming network first | Server is reachable and service is failing locally |
| Increasing instance size immediately | May not solve root volume fullness |
| Ignoring logs | Logs state the root cause |
| `rm -rf /var/log/*` | Unsafe and may destroy audit evidence |

### Instructor Hints

1. Is the service active or failed?
2. What does the log say?
3. What does `df -h` show?
4. What directory usually grows because of logs?
5. How would you fix this safely in production?

### Preventive Action

- Configure log rotation.
- Add disk usage alerts.
- Use CloudWatch agent or centralized logging.
- Consider a separate log volume for high-volume apps.
- Review application logging behavior.
- Define retention policy.
- Create a disk cleanup runbook.

---

## 16. Scenario-Based Discussion Questions

1. **A service is down, but the server is reachable over SSH. What should you check first?**  
   Expected themes: service status, process list, logs, disk, memory, recent deployment.  
   Follow-up: Why not start with DNS or firewall troubleshooting?

2. **Should you restart a failed service before checking logs?**  
   Expected themes: usually no, logs may contain root cause, restarting can change state.  
   Follow-up: When might an immediate restart be acceptable?

3. **Why can a full disk cause a service to fail?**  
   Expected themes: cannot write logs, temp files, PID files, database/app writes fail.  
   Follow-up: Which command confirms disk usage fastest?

4. **In AWS, what settings might prevent SSH before Linux troubleshooting begins?**  
   Expected themes: security group, key pair, username, public IP, route table, NACL.  
   Follow-up: Which are AWS-level vs Linux-level?

5. **Why is deleting logs during an incident risky?**  
   Expected themes: evidence loss, audit risk, postmortem gaps, security impact.  
   Follow-up: What is safer than deleting logs?

6. **How does this class connect to SRE work?**  
   Expected themes: incident response, reliability, logs, evidence, alerts.  
   Follow-up: What alert would you create after a disk-full incident?

7. **How does this class connect to DevOps work?**  
   Expected themes: CI/CD runners, deployment scripts, release failures, logs.  
   Follow-up: What pre-deployment check could prevent a failed release?

---

## 17. Knowledge Check or Mini-Quiz With Answer Key

1. **Which command checks Linux service status?**  
   A. `ls -l` B. `systemctl status` C. `chmod +x` D. `pwd`  
   **Answer:** B. `systemctl status` shows the current state of a service.

2. **Which command shows filesystem disk usage?**  
   A. `df -h` B. `free -h` C. `ps aux` D. `whoami`  
   **Answer:** A. `df -h` shows disk usage in human-readable format.

3. **True or False: A process is a running program.**  
   **Answer:** True.

4. **Which command views logs for a systemd service?**  
   A. `journalctl -u service-name` B. `chmod service-name` C. `cd service-name` D. `mkdir service-name`  
   **Answer:** A. `journalctl -u` filters logs for a specific service.

5. **Troubleshooting:** Logs show `No space left on device`. What command should you run next?  
   **Answer:** `df -h`. It confirms whether a filesystem is full.

6. **Troubleshooting:** `systemctl status nginx` shows `Active: failed`. What should you check next?  
   **Answer:** `journalctl -u nginx --since "30 minutes ago"`. Logs usually explain why the service failed.

7. **AWS:** Which AWS service provides Linux virtual servers?  
   A. S3 B. EC2 C. Route 53 D. IAM  
   **Answer:** B. EC2.

8. **AWS:** What AWS network control usually needs to allow SSH port 22?  
   A. S3 bucket policy B. Security Group C. CloudWatch Alarm D. EBS Snapshot  
   **Answer:** B. Security Group.

9. **Class 1 connection:** A deployment script will not run. Which command helps inspect permissions?  
   **Answer:** `ls -l deploy.sh`.

10. **Class 1 connection:** A service cannot read a config file. Which Class 1 concept may be involved?  
    **Answer:** File permissions or ownership.

11. **Short answer:** Difference between `systemctl restart nginx` and `systemctl enable nginx`?  
    **Answer:** `restart` restarts now. `enable` configures startup at boot.

12. **True or False:** It is always safe to delete large logs during production incidents.  
    **Answer:** False. Logs may be required for audit, security, and root cause analysis.

13. **Which command shows which ports are listening and which process owns them?**  
    A. `df -h` B. `ss -tulnp` C. `chmod` D. `uptime`  
    **Answer:** B. `ss -tulnp` lists listening TCP/UDP sockets with the owning process (`netstat` is deprecated).

14. **`systemctl status webapp` shows `active (running)`, but users get connection refused. What is the next best check?**  
    **Answer:** `sudo ss -tlnp | grep ':<port>'` — confirm the service is actually *listening* on the expected port. "Active" does not guarantee "listening."

15. **In 2026, what is the recommended way to get a shell on an EC2 instance without opening port 22 or distributing key files?**  
    A. `telnet` B. SSM Session Manager (`aws ssm start-session`) C. RDP D. FTP  
    **Answer:** B. Session Manager is keyless, needs no inbound port 22, and is IAM-controlled and audited.

16. **`uptime` reports a load average of `4.0` on a machine where `nproc` returns `8`. Is the CPU saturated?**  
    **Answer:** No. Load `4.0` on 8 cores means roughly half the CPU capacity is in use; saturation would be load near or above `8`.

17. **`free -h` shows `free` of `0.2Gi` but `available` of `6.0Gi`. Is the server out of memory?**  
    **Answer:** No. Linux uses idle RAM for buff/cache and reclaims it on demand; `available` (6.0Gi) is what new processes can use, so the server is fine.

18. **Short answer:** Name one advantage of a systemd `.timer` over a cron job.  
    **Answer:** Output and failures are captured in `journalctl`/`systemctl` (cron has no built-in run logging); `OnCalendar` schedules are more expressive; timers integrate with systemd dependencies.

---

## 18. Homework Assignment

### Assignment Title

**Linux Troubleshooting Checklist for Cloud Engineers**

### Scenario

You are joining a cloud operations team that supports Linux-based application servers in AWS. The team wants a beginner-friendly checklist engineers can use when a server is reachable but the application is not working.

### Student Tasks

Create a checklist that includes:

1. Server reachability checks
2. SSH checks
3. Disk checks
4. Memory checks
5. Process checks
6. Service checks
7. Log checks
8. Permission checks
9. Network checks
10. Recent change checks

### Required Commands

```bash
ping
ssh
aws ssm start-session
df -h
du -sh
free -h
uptime
nproc
top
ps aux
systemctl status
systemctl list-timers
journalctl -u
tail -f
grep
ss -tulnp
lsof -i
crontab -l
chmod
chown
```

### Expected Deliverables

- Checklist title
- Scenario description
- Command table
- Step-by-step investigation order
- Example: “Service failed because disk is full”
- Preventive actions

### Submission Format

Markdown, Word document, PDF, or Git README.

### Estimated Completion Time

2 hours

### Grading Criteria

| Criteria | Points |
|---|---:|
| Includes required commands | 20 |
| Commands grouped logically | 15 |
| Clear troubleshooting order | 20 |
| Includes service and log investigation | 15 |
| Includes AWS EC2 connection notes | 10 |
| Includes preventive actions | 10 |
| Clear formatting | 10 |

### Optional Advanced Challenge

Add a section called **How I Would Troubleshoot an EC2 Web Server Outage** with AWS checks, Linux checks, service checks, log checks, and a final status update example.

---

## 19. Common Student Mistakes

| Mistake | Why It Happens | Fix |
|---|---|---|
| Restarting before checking logs | Students want fast fixes | Teach evidence-first troubleshooting |
| Confusing stopped and failed | Both mean app is not running | Explain `inactive` vs `failed` |
| Forgetting `sudo` for service actions | Service changes require privilege | Use `sudo` only when needed |
| Wrong service name | Distros use different names | Try `ssh` vs `sshd`; list services |
| Ignoring disk usage | Students focus only on service state | Include `df -h` in first checks |
| Deleting logs blindly | Students want to free space quickly | Preserve evidence and rotate/compress logs |
| Not reading exact errors | Beginners skim output | Read the exact line aloud |
| Assuming every issue is cloud networking | Server access does not prove app health | Separate cloud-level and Linux-level checks |
| Not documenting findings | Troubleshooting cannot be shared | Require a short report |
| Overusing root privileges | `sudo` feels easier | Reinforce least privilege |

---

## 20. Real-World Enterprise Scenario

A company runs an internal order-processing application on Linux EC2 instances. After deployment, users report that the application is unavailable. The EC2 instance is reachable by SSH, but the application endpoint returns an error.

The DevOps engineer finds:

```text
webapp.service failed
No space left on device
```

### Constraints

- Production logs must be preserved for audit.
- Engineers cannot delete files without approval.
- Restarting repeatedly may worsen the issue.
- The deployment window is limited.
- Security requires least privilege access.
- Leadership needs status updates.
- The team must document root cause and prevention.

### Role Actions

**DevOps Engineer:** Check if deployment caused excessive logging, validate restart after safe cleanup, add pre-deployment disk checks.

**Cloud Engineer:** Check EBS volume size, CloudWatch disk metrics if configured, storage design, and approved volume expansion.

**SRE:** Create incident timeline, improve alerts, add log rotation, create runbook, define prevention actions.

---

## 21. Instructor Tips

### Teaching Tips

- Keep the troubleshooting flow visible.
- Ask students what each command proves.
- Emphasize evidence over guessing.
- Use realistic failure messages.
- Compare symptom vs root cause.

### Pacing Tips

- Do not go deep into performance tuning.
- Keep `top`, memory, and load average introductory.
- Spend more time on `systemctl` and `journalctl`.
- Leave time for the troubleshooting scenario.

### Lab Support Tips

Ask stuck students:

1. What command did you run?
2. What output did you get?
3. Is the service running, stopped, or failed?
4. What do the logs say?
5. What does `df -h` show?

### Helping Struggling Students

Give them this flow:

```text
1. Check service status
2. Check logs
3. Check disk
4. Check memory
5. Check process
6. Document what you found
```

### Challenging Advanced Students

Ask them to:

- Use `lsof -i :80` to find exactly which process holds a port
- Write a systemd `.timer` + `.service` pair that runs a health-check script every 5 minutes, and inspect it with `systemctl list-timers` and `journalctl`
- Compare `ps aux` with `systemctl status`
- Explain the IAM + SSM agent prerequisites that make `aws ssm start-session` work
- Explain how CloudWatch Logs would help
- Suggest disk alert thresholds

---

## 22. Student Outcome Checklist

### Students Should Be Able to Explain

- Difference between a process and a service
- Difference between a service being *active* and being *listening* (`ss -tulnp`)
- What `systemctl` does
- What `journalctl` does
- How to read load average (vs core count), `free` available memory, and `%wa` in `top`
- Why logs matter during incidents
- Why disk-full issues break services
- Why SSM Session Manager is preferred over pem-based SSH for EC2 access in 2026
- How cron and systemd timers schedule recurring operational work
- How Class 1 permissions can affect Class 2 service failures
- How Linux troubleshooting applies to AWS EC2, Azure VM, and GCP Compute Engine

### Students Should Be Able to Build or Configure

- Basic Linux health report
- Service investigation checklist
- Command-based troubleshooting workflow
- Documented incident summary
- Optional nginx service test

### Students Should Be Able to Troubleshoot

- Failed service status
- Missing or unclear logs
- High disk usage
- Basic memory pressure indicators
- Wrong service name
- SSH key permission issue
- Script permission issue affecting service startup
- Confusing cloud access issues with Linux service issues

---

## 23. Class Completion Checklist

### Instructor Checklist

Confirm students can:

- Run `df -h`
- Run `free -h` and read `available` vs `free`
- Run `uptime` and interpret load against `nproc`
- Run `ps aux`
- Run `sudo ss -tulnp` and identify a listening service
- Run `systemctl status`
- Run `journalctl -u`
- Explain stopped vs failed services
- Explain why disk-full can break a service
- Explain SSM Session Manager as the primary EC2 access path and SSH as break-glass
- Complete the troubleshooting report

### Student Checklist

Students should have:

- Completed `linux-health-report.txt`
- Checked at least one service status
- Viewed at least one set of service logs
- Checked disk and memory usage
- Answered reflection questions
- Written down homework instructions

Validation commands:

```bash
df -h
free -h
uptime
sudo ss -tulnp | head
ps aux | head
systemctl list-units --type=service --state=running | head
journalctl -p err --since "1 hour ago" --no-pager
```

### Verify Before Closing the Week

Students should be comfortable with:

- Linux navigation
- File permissions
- Basic scripts
- Processes
- Services and listening ports (`ss -tulnp`)
- Logs
- Disk checks
- Memory and load interpretation
- Cloud access: SSM Session Manager (primary) and SSH (break-glass)
- Scheduling with cron and systemd timers
- Evidence-based troubleshooting

---

## 24. End-of-Week Summary

### What Students Learned This Week

Students learned how to:

- Navigate Linux systems
- Manage files and directories
- Understand users, groups, ownership, and permissions
- Run and fix executable scripts
- Inspect running processes
- Check service status and listening ports (`ss -tulnp`)
- Read service logs
- Check and interpret disk, memory, and load
- Access cloud servers with SSM Session Manager (primary) and SSH (break-glass)
- Schedule recurring work with cron and systemd timers
- Troubleshoot a failed service

### How Class 1 and Class 2 Connect

Class 1 answered:

```text
Where are the files?
Who owns them?
Can scripts run?
Are permissions correct?
```

Class 2 answered:

```text
Is the service running?
What do the logs say?
Is the system healthy?
Can I connect to the server?
What is the likely root cause?
```

Together, they form the foundation of Linux operational troubleshooting.

### How This Week Prepares Students for Week 3

Week 3 focuses on **Git and version control**. The scripts, configs, and troubleshooting reports students created and edited this week are exactly the kind of files that belong in a Git repository. Students will be ready to:

- Track the `deploy.sh` script and config files they wrote, instead of editing them ad hoc on a server.
- Use a branch and a pull request to propose and review a change.
- Understand why "edit on the server" is a break-glass action, while "commit, review, deploy" is the safe path.
- Preserve correct file permissions (the executable bit) through version control.

Later, in **Week 5 (Networking & VPC)**, students will extend today's "is the service running?" triage to the network layer: is DNS resolving, is the port open, is a security group or firewall blocking traffic, is the route correct, is HTTP/HTTPS responding?

### What Students Should Review

- `pwd`, `ls`, `cd`
- `chmod`, `chown`, `ls -l`
- `df -h`, `du -sh`
- `free -h`, `top`, `uptime`, `nproc`
- `ps aux`
- `ss -tulnp`
- `systemctl status`, `systemctl list-timers`
- `journalctl -u`
- `aws ssm start-session` (primary) and basic SSH syntax (break-glass)
- cron / systemd timer basics
- Difference between local server issues and network connectivity issues

---

## Class Artifacts & Validation

These are the on-disk, validated artifacts in [`labs/linux-shell-automation/`](../../labs/linux-shell-automation/) that back this class. Class 2's themes — disk checks as a cron/monitoring gate, log rotation (the disk-full prevention from the troubleshooting activity), retention/backup as scheduled ops, and log triage — are exactly what these scripts implement. The toolkit is **reused in Week 08 Class 01** (automation toolkit / cron-driven ops), per the module README. All commands below were run in this environment (bash 5.1, GNU coreutils, ShellCheck 0.10.0).

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/linux-shell-automation/solution/disk-check.sh | shell | `df -P` parser that exits non-zero when any mount exceeds `--threshold` — usable directly as a cron/monitoring gate (the disk-full check at the heart of this class's troubleshooting scenario) | `bash -n solution/disk-check.sh` then `shellcheck -x solution/disk-check.sh` | PASS (syntax + lint-clean) |
| 2 | labs/linux-shell-automation/solution/log-rotate.sh | shell | gzip-rotates files older than N days with `--dry-run`; the safe alternative to `rm -rf /var/log/*` and the log-rotation prevention action this class teaches | `bash -n solution/log-rotate.sh` then `shellcheck -x solution/log-rotate.sh` | PASS (syntax + lint-clean) |
| 3 | labs/linux-shell-automation/solution/backup.sh | shell | Timestamped `tar.gz` with `--keep N` retention pruning — a typical cron/systemd-timer scheduled job (Section 10.6) | `bash -n solution/backup.sh` then `shellcheck -x solution/backup.sh` | PASS (syntax + lint-clean) |
| 4 | labs/linux-shell-automation/solution/lib/common.sh | shell | Sourced library (`log()`, `die()`, `require_cmd()`); diagnostics to stderr so scripts compose cleanly in pipelines and cron | `bash -n solution/lib/common.sh` then `shellcheck -x solution/lib/common.sh` | PASS (syntax + lint-clean) |
| 5 | labs/linux-shell-automation/tests/run-tests.sh | shell | Functional suite — asserts disk-check threshold/exit behaviour, log-rotate idempotency, and backup retention in a sandbox | `bash tests/run-tests.sh` | PASS — `25 passed, 0 failed`, exit 0 |
| 6 | labs/linux-shell-automation/validate.sh | shell | Module gate runner: `bash -n` on every script + the functional suite + `shellcheck -x` | `./validate.sh` | PASS — `22 passed, 0 failed` |

> Note: This class's own student lab produces a `linux-health-report.txt` and live terminal commands (`df -h`, `free -h`, `ss -tulnp`, `systemctl status`, `journalctl`). Those are run-on-a-host teaching activities. The rows above are the committed, validated artifacts; they are static-validated (syntax + lint + functional tests). There is **no captured live cloud/EC2 evidence file** (no `LIVE-*` artifact) for the SSM/SSH/nginx/`systemctl` demos — those run on an instructor VM or EC2 at class time and are not committed here.

## Definition of Done

- [x] Every technology taught with a committed artifact ships a **runnable file on disk** — `disk-check.sh`, `log-rotate.sh`, `backup.sh`, `lib/common.sh` (not just fenced snippets). The live-host commands (`systemctl`, `journalctl`, `ss`, SSM/SSH) are inherently host-side and are demonstrated, not committed as files.
- [x] Each committed artifact passes its **validation gate** from §3 (`bash -n` **and** `shellcheck -x`), plus the functional suite; output captured in the lab README and re-run above.
- [x] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, and **cost notes** ($0, local-only).
- [x] **Cleanup/teardown** is provided and idempotent — the class lab cleans up with `rm -rf ~/week2-linux-lab/class2`; the test suite uses a `mktemp -d` sandbox removed via `trap cleanup EXIT`; EC2/nginx steps include explicit stop/terminate cleanup (Section 13).
- [x] **Instructor answer key** exists — quiz answer key (Section 17), homework grading rubric (Section 18), and a worked troubleshooting answer key for the disk-full incident (Section 15); module lab answer key in the README.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — the "Web Service Fails Because Disk Is Full" incident (Section 15) with reproducible symptoms; the module also ships the `broken/disk-check-broken.sh` fixture (two genuine bugs).
- [x] **Expected outputs** are shown for the demo (Section 13), the lab (Section 14), and each manifest gate.
- [x] **Cost & security warnings** present — small instance types, stop/terminate after class, never commit `.pem`, least-privilege IAM, never `rm -rf /var/log/*` (Sections 7, 13, 15); committed artifacts read/write only where told.
- [x] **Cross-references** are present and verified — Class 1, the `linux-shell-automation` module, Week 3 (Git), Week 5 (Networking), Week 16 (observability), and the Week 08 reuse of this toolkit.
- [x] The **artifact manifest** (§4.2) is present above and every path resolves (verified with `ls`).
