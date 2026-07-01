# Week 2: Linux Fundamentals for Cloud and DevOps
> **▶ Runnable lab for this class:** [`labs/linux-shell-automation/`](../../labs/linux-shell-automation/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 1 Package: Linux Filesystem, Files, Users, and Permissions

**Track:** Unified DevOps · Cloud · SRE Track

---

## 1. Class Overview

### Class Title
**Class 1: Linux Foundations for Cloud Engineers**

### Class Purpose
This class introduces students to the Linux command line, filesystem navigation, file management, users, groups, ownership, and permissions. These are foundational skills for DevOps Engineers, Cloud Engineers, and SREs because most cloud servers, CI/CD runners, Kubernetes nodes, containers, and automation workflows rely heavily on Linux.

### How This Class Connects to the Overall Course
This class prepares students for later work with AWS EC2 Linux instances, Bash scripting, CI/CD runners, Docker containers, Kubernetes nodes, Terraform execution environments, monitoring agents, and production troubleshooting.

### What Students Will Build, Analyze, or Practice
Students will practice navigating Linux, creating files and folders, viewing file contents, inspecting users and groups, reading permissions, fixing a script execution issue, and connecting Linux basics to real cloud operations.

---

## 2. Class Learning Objectives

By the end of this class, students will be able to:

1. Explain why Linux is important for DevOps, Cloud Engineering, and SRE roles.
2. Navigate the Linux filesystem using `pwd`, `ls`, and `cd`.
3. Create and manage files and directories using `touch`, `mkdir`, `cp`, `mv`, and `rm`.
4. Inspect file contents using `cat`, `less`, `head`, `tail`, and `grep`.
5. Use pipes (`|`), redirection (`>`, `>>`, `2>`), and `find` to combine commands and locate files.
6. Process text with `grep`, `cut`, `sort`, `uniq`, `wc`, and a first look at `awk`/`sed` for log triage.
7. Explain users, groups, ownership, and permission categories.
8. Validate permissions using `ls -l`.
9. Configure permissions using both symbolic (`chmod +x`, `u+rw`) and numeric/octal (`755`, `644`, `600`) modes, and explain `umask`.
10. Edit a file over a remote shell using `vim` survival commands and `nano`.
11. Compare Linux usage across AWS EC2, Azure Virtual Machines, and GCP Compute Engine.

---

## 3. Prerequisites Students Should Already Know

### Required Prior Concepts
- Basic file and folder concepts
- Basic terminal purpose
- Basic understanding of cloud servers
- Difference between local machine and remote server
- Basic idea that applications run on servers

### Required Tools Already Installed
- VS Code
- Terminal, Git Bash, WSL, macOS Terminal, Linux VM, or cloud shell
- Optional: Docker Desktop
- Optional: AWS CLI

### Required Accounts or Access
Students can use a local Linux shell, WSL, Linux VM, cloud sandbox, or optional AWS EC2 Linux instance.

### Files, Repos, or Sample Code Needed
No starter repo is required. Students will create this lab structure:

```text
week2-linux-lab/
├── app/
├── config/
├── logs/
└── scripts/
```

---

## 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Linux | Operating system commonly used on servers | Most cloud servers, containers, and Kubernetes nodes run Linux |
| Shell | Command-line interface to the operating system | Used for commands, scripts, and troubleshooting |
| Terminal | Application used to access the shell | Main student interface for Linux commands |
| Filesystem | How Linux organizes files and folders | Logs, configs, scripts, and applications live in predictable locations |
| Root directory `/` | Top of the Linux filesystem | Everything exists under `/` |
| Home directory | User's personal working directory | Example: `/home/student` |
| Absolute path | Full path from `/` | Example: `/var/log/app.log` |
| Relative path | Path from current directory | Example: `logs/app.log` |
| Hidden file | File beginning with `.` | Example: `.bashrc`, `.gitignore` |
| User | Account that logs in or runs commands | Example: `ubuntu`, `ec2-user`, `student` |
| Group | Collection of users sharing access | Used for shared permissions |
| Owner | User that owns a file | Determines access control |
| Permission | Read, write, execute rules | Incorrect permissions can break apps or expose secrets |
| `sudo` | Runs approved commands with elevated privileges | Used carefully for admin tasks |
| Executable file | File that can run as a script or program | Deployment scripts need execute permission |

---

## 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| Linux shell | Main environment for commands |
| Terminal | Access to the Linux shell |
| VS Code | Optional file editor |
| `pwd` | Shows current directory |
| `ls` | Lists files and folders |
| `cd` | Changes directories |
| `mkdir` | Creates directories |
| `touch` | Creates files |
| `cp` | Copies files |
| `mv` | Moves or renames files |
| `rm` | Removes files |
| `cat` | Displays file content |
| `less` | Views long files |
| `head` | Shows beginning of file |
| `tail` | Shows end of file/log |
| `grep` | Searches text (supports `-r`, `-i`, `-c`, `-n`, regex) |
| `find` | Locates files by name, type, or attribute |
| `cut` | Extracts columns/fields from text |
| `sort` | Orders lines |
| `uniq` | Collapses or counts duplicate lines |
| `wc` | Counts lines, words, bytes |
| `awk` | Field-aware text processing |
| `sed` | Stream editing and substitution |
| `chmod` | Changes permissions (symbolic and octal) |
| `chown` | Changes ownership |
| `umask` | Sets default permission mask for new files |
| `vim` | In-terminal editor for remote files |
| `nano` | Beginner-friendly in-terminal editor |
| `whoami` | Shows current user |
| `id` | Shows user and group IDs |
| `groups` | Shows user groups |

---

## 6. AWS Services Used

This class does not require students to create AWS resources, but it introduces Linux skills needed for AWS EC2.

| AWS Service | Connection to Class Topic |
|---|---|
| Amazon EC2 | EC2 Linux instances are cloud servers where students will later use Linux commands |
| Amazon Machine Images | AMIs are used to launch Linux-based EC2 servers |
| EC2 Key Pairs | Used later for SSH access |
| Security Groups | Used later to allow SSH and application traffic |
| EBS Volumes | Linux filesystems often live on EBS-backed disks |

### Cost Warning
If using EC2, stop or terminate instances after class, avoid large instance types, and remove unused EBS volumes.

---

## 7. Azure and GCP Comparison Notes

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Linux virtual server | EC2 Linux instance | Azure Linux VM | Compute Engine Linux VM |
| Disk | EBS volume | Managed Disk | Persistent Disk |
| SSH access | Key pair and security group | SSH key and NSG rule | SSH key and firewall rule |
| Server image | AMI | VM image | Machine image |

The Linux commands students learn today are mostly the same across AWS, Azure, GCP, VMware, and local Linux environments.

---

## 8. Time-Boxed Instructor Agenda

| Time | Section | Activity |
|---:|---|---|
| 0:00 - 0:10 | Welcome and context | Explain why Linux matters in DevOps, Cloud, and SRE |
| 0:10 - 0:20 | Linux in cloud environments | EC2, Azure VM, and GCP Compute Engine comparison |
| 0:20 - 0:40 | Filesystem navigation | Teach `pwd`, `ls`, `cd`, paths, and hidden files |
| 0:40 - 1:00 | File and directory operations | Teach `mkdir`, `touch`, `cp`, `mv`, `rm` |
| 1:00 - 1:20 | Pipes, redirection, and `find` | Teach `|`, `>`, `>>`, `2>`, and `find` **before** they appear in labs (Section 7.5) |
| 1:20 - 1:30 | Break | Short break |
| 1:30 - 1:50 | Viewing and text processing | Teach `cat`, `less`, `head`, `tail`, `grep`, `cut`, `sort`, `uniq`, `wc`, `awk`/`sed` intro (Section 7.6) |
| 1:50 - 2:20 | Users, ownership, permissions | Teach `whoami`, `id`, `ls -l`, symbolic AND octal `chmod`, `umask`, `chown` (Section 7.7) |
| 2:20 - 2:30 | Editing over SSH | `vim` survival + `nano` (Section 7.8) |
| 2:30 - 2:45 | Instructor demo | Navigating and securing a Linux application directory |
| 2:45 - 2:55 | Student lab start | Guided lab tasks |
| 2:55 - 3:00 | Recap and homework | Confirm outcomes and assign homework |

---

## 9. Instructor Lesson Plan

### Step 1: Open With Role Context
Explain that Linux is a daily working skill for DevOps Engineers, Cloud Engineers, and SREs. When deployments fail, scripts cannot execute, apps cannot read configs, or logs need review, Linux knowledge helps engineers investigate quickly.

Ask:
- Where does Linux appear in cloud environments?
- Have you used a terminal before?
- What feels difficult about command-line work?

### Step 2: Connect Linux to Cloud Infrastructure
Linux appears in EC2 instances, Azure VMs, GCP Compute Engine, Docker containers, Kubernetes nodes, CI/CD runners, bastion hosts, monitoring agents, and automation servers.

Instructor talking point:
> Even if your company uses managed cloud services, Linux still appears in build agents, containers, Kubernetes, and troubleshooting workflows.

### Step 3: Teach Filesystem Navigation
Show:

```bash
pwd
ls
ls -l
ls -la
cd /
cd ~
cd ..
```

Explain:
- `pwd` tells you where you are.
- `ls` shows what exists.
- `cd` moves between directories.
- `.` means current directory.
- `..` means parent directory.
- `~` means home directory.

### Step 4: Teach Common Linux Directories

```text
/
├── home
├── etc
├── var
├── tmp
├── usr
├── opt
└── root
```

Key points:
- `/etc` stores configuration.
- `/var/log` stores logs.
- `/home` stores user files.
- `/tmp` stores temporary files.
- `/opt` often stores third-party apps.

### Step 5: Teach File and Directory Operations

```bash
mkdir cloud-app
cd cloud-app
touch app.log config.txt deploy.sh
ls -l
cp config.txt config-backup.txt
mv config-backup.txt backup-config.txt
rm backup-config.txt
```

Security warning:
> Be careful with `rm`, especially `rm -rf`. In production, deleting the wrong directory can cause outages or data loss.

### Step 6: Teach Viewing and Searching Files

```bash
echo "application started" > app.log
cat app.log
head app.log
tail app.log
grep "started" app.log
```

Explain that `tail` and `grep` are heavily used during log investigations.

### Step 6.5: Teach Pipes, Redirection, and `find` (BEFORE They Appear in the Lab)

These are taught here, before the lab, because the lab and troubleshooting activity use `>`, `>>`, `|`, and `find` — students must see them defined first.

**Redirection** sends command output to files instead of the screen:

```bash
echo "application started" > app.log     # > overwrites (creates or truncates)
echo "second line" >> app.log            # >> appends (keeps existing content)
ls /nonexistent 2> errors.txt            # 2> redirects stderr (error stream) to a file
ls /etc > out.txt 2>&1                    # send stdout AND stderr to the same file
```

Teaching point:
> `>` is destructive — it truncates the file first. Use `>>` when you want to keep what is already there. This trips up beginners who overwrite a config with `>` instead of `>>`.

**Pipes** (`|`) connect the output of one command to the input of the next:

```bash
ls -l /etc | head            # only the first lines of a long listing
ps aux | grep ssh            # find ssh-related lines in the process list
cat app.log | wc -l          # count lines in a file
```

**`find`** locates files by name, type, age, or size:

```bash
find . -type f                       # all files under the current directory
find . -name "*.log"                 # files ending in .log
find /var/log -name "*.log" -type f  # log files under /var/log
find . -type f -mtime -1             # files modified in the last day
```

Teaching point:
> `find` walks a directory tree; `ls` only looks at one level. During incidents you use `find` to locate "where is that config / which file is huge."

### Step 6.6: Teach Text Processing for Log Triage

Real log triage almost never uses `cat` alone — it chains small tools. Build a tiny sample and process it:

```bash
cat > access.log <<'EOF'
10.0.0.1 GET /home 200
10.0.0.2 GET /login 200
10.0.0.1 POST /login 401
10.0.0.3 GET /home 500
10.0.0.1 GET /home 200
EOF
```

Now process it:

```bash
grep " 500" access.log              # only server-error (500) lines
grep -c " 200" access.log           # COUNT of matching lines (not the lines)
grep -i error /var/log/syslog       # case-insensitive search
cut -d' ' -f1 access.log            # field 1 (the IP) using space as delimiter
cut -d' ' -f1 access.log | sort | uniq -c | sort -rn   # top talkers: count per IP, busiest first
awk '{ print $3, $4 }' access.log   # awk: print fields 3 and 4 (path, status)
awk '$4 == 500 { print $1 }' access.log   # awk with a condition: IPs that got a 500
sed 's/GET/FETCH/' access.log       # sed: substitute GET with FETCH in the output
wc -l access.log                    # how many lines total
```

Teaching point:
> `cut -d' ' -f1 access.log | sort | uniq -c | sort -rn` is the classic "who is hitting us most?" one-liner. `uniq -c` only collapses *adjacent* duplicates, which is why you `sort` first. This pattern — extract a field, sort, count — is one of the most common live-coding interview asks for ops roles.

Note the modern alternative:
> `grep -r` (lowercase) recursively searches a directory tree, same as `grep -R`. Many teams now use `rg` (ripgrep) instead — it is faster and respects `.gitignore`. If `rg` is installed, `rg error /var/log` is the modern equivalent of `grep -r error /var/log`.

### Step 7: Teach Users, Groups, Ownership, and Permissions

```bash
whoami
id
groups
ls -l
```

Permission example:

```text
-rwxr-xr--
```

Breakdown:

```text
- rwx r-x r--
|  |   |   |
|  |   |   └── Others
|  |   └────── Group
|  └────────── Owner
└───────────── File type
```

Explain:
- `r` = read
- `w` = write
- `x` = execute

#### Octal (Numeric) Permissions — Core, Not Advanced

Octal notation is what engineers actually type daily and what appears in Dockerfiles, Ansible, and Terraform `file`/`local_file` resources. Each permission triad is a single digit, summing `r=4`, `w=2`, `x=1`:

```text
r = 4
w = 2
x = 1

rwx = 4+2+1 = 7
rw- = 4+2+0 = 6
r-x = 4+0+1 = 5
r-- = 4+0+0 = 4
```

So three triads (owner, group, others) become three digits:

```text
755 = rwxr-xr-x   scripts, directories (owner full; others read/traverse)
644 = rw-r--r--   normal files, configs (owner read/write; others read)
600 = rw-------   private files: SSH keys, secrets (owner only)
700 = rwx------   private executable / private directory
640 = rw-r-----   config readable by a group, not the world
```

Apply with `chmod`:

```bash
chmod 755 deploy.sh      # exactly rwxr-xr-x
chmod 644 config.txt     # exactly rw-r--r--
chmod 600 secret.key     # exactly rw------- (lock down a secret)
```

#### Symbolic vs Octal — Both Are Core

- **Symbolic** changes bits *relatively*: `chmod +x deploy.sh` adds execute for everyone who already has read; `chmod u+rw,go-rwx secret.key` adds owner read/write and removes all group/other access.
- **Octal** sets the mode *absolutely*: `chmod 600 secret.key` replaces all nine bits at once.

Teaching point:
> Use symbolic when you mean "add/remove one bit" (`+x`). Use octal when you mean "make it exactly this" (`600` for a key). `chmod 600` is unambiguous; `chmod +x` only changes execute.

#### File `x` vs Directory `x`

The execute bit means different things:
- On a **file**, `x` means "this file can be run as a program/script."
- On a **directory**, `x` means "you can traverse into it" (`cd`, and access files inside by name). A directory with `r` but no `x` lets you list names but not actually use them.

```bash
ls -ld /var/log          # the leading 'd' marks a directory; its x = traverse
```

#### `umask` — Why New Files Are 644 and Not 666

New files are not created with all bits set; the shell's `umask` *subtracts* permissions from the defaults (`666` for files, `777` for directories):

```bash
umask            # show current mask, commonly 0022
touch newfile    # 666 - 022 = 644 (rw-r--r--)
mkdir newdir     # 777 - 022 = 755 (rwxr-xr-x)
```

Teaching point:
> A `umask` of `0027` (common on hardened servers) makes new files `640` and directories `750` — nothing is world-readable by default. This is a security control, not a beginner curiosity.

### Step 8: Run Instructor Demo
Run the demo in Section 12 and intentionally show `Permission denied` before fixing it.

### Step 8.5: Editing Files Over SSH (`vim` Survival + `nano`)

Next class students SSH into servers. Editing a config over SSH is a day-one task, and on a bare server `vim` is the editor that is always installed. Teach the minimum to survive:

```bash
vim config.txt
```

`vim` survival commands:

```text
i            enter INSERT mode (now you can type)
Esc          leave INSERT mode, back to NORMAL mode
:w           write (save)
:q           quit
:wq          save and quit
:q!          quit WITHOUT saving (discard changes) — the "I'm stuck, get me out" command
/word        search for "word" (press n for next match)
dd           delete the current line
```

Teaching point:
> The classic beginner trap is being stuck in `vim`. The escape hatch is: press `Esc`, then type `:q!` and Enter. That always gets you out without saving.

`nano` is friendlier when available (the bottom bar shows shortcuts; `^` means Ctrl):

```bash
nano config.txt
# Ctrl+O then Enter = save (Write Out);  Ctrl+X = exit
```

Teaching point:
> Use whichever is installed. `nano` is easier; `vim` is universal. On a minimal EC2 or container, assume only `vi`/`vim` exists.

### Step 9: Start Student Lab
Students complete the lab while the instructor checks common issues such as wrong directory, mistyped filenames, missing `chmod +x`, or forgetting `./` before a script.

### Step 10: Recap and Transition to Class 2
> Today we learned how to move around Linux, manage files, and fix basic permission problems. In Class 2, we move from files into running systems: processes, services, logs, SSH, and troubleshooting failed services.

---

## 10. Instructor Lecture Notes

### Linux Is the Operating System Behind Much of Cloud Engineering
Linux is widely used in cloud infrastructure because it is stable, scriptable, lightweight, and well-supported across platforms. In AWS, EC2 Linux instances use Linux. CI/CD runners often use Linux. Containers are usually Linux-based. Kubernetes worker nodes often run Linux.

A beginner may think Linux is only about memorizing commands. The better mindset is understanding how a server is organized and how to investigate what is happening.

A cloud engineer asks:
- Where is the config file?
- Who owns it?
- Can the application read it?
- Can this script run?
- Where are the logs?
- What changed?

### Filesystem Navigation Is the First Troubleshooting Skill
`pwd` answers “Where am I?” and `ls -la` answers “What exists here and what permissions does it have?”

```bash
pwd
ls -la
```

Talking point:
> In production, always know where you are before running a command.

### Important Linux Directories

| Directory | Instructor Talking Point |
|---|---|
| `/home` | Where normal users usually work |
| `/etc` | Where system and application configuration often lives |
| `/var/log` | One of the first places to check during troubleshooting |
| `/tmp` | Temporary files, often cleaned automatically |
| `/opt` | Sometimes used for third-party applications |
| `/root` | Root user’s home directory, not the same as `/` |

### File Operations Are Used in Deployments and Troubleshooting
DevOps and SRE work often involves copying config files, backing up files before editing, moving artifacts, creating scripts, and inspecting logs.

Safe pattern:

```bash
cp app.conf app.conf.backup
```

### Viewing File Content

```bash
cat config.txt
less large-log-file.log
tail -n 50 app.log
grep -i error app.log
```

Production example:

```text
ERROR: Permission denied reading /etc/app/config.yaml
```

This points students back to ownership and permissions.

### Permissions Are Both a Security and Reliability Topic
Permissions affect whether scripts can run, applications can read configs, logs can be written, secrets are exposed, and deployment users can modify files.

Important warning:
> Never teach students to fix every permission issue with `chmod 777`. That is unsafe and creates security risk. The correct answers are usually `chmod +x` (for scripts), `644` (for configs), or `600` (for secrets and SSH keys) — never `777`.

Numeric/octal permissions (`755`, `644`, `600`) are **core**, not an advanced aside: they are what you type in Dockerfiles, Ansible `mode:`, and Terraform `file_permission`. Make sure every student can read and write octal by the end of class.

---

## 11. Whiteboard Explanation

### Simple Diagram: Linux Filesystem for Cloud Work

```text
Linux Server
|
|-- /home
|   |
|   |-- student
|       |
|       |-- scripts
|       |-- notes
|
|-- /etc
|   |
|   |-- app config files
|
|-- /var
|   |
|   |-- log
|       |
|       |-- application logs
|       |-- system logs
|
|-- /opt
    |
    |-- installed applications
```

### Permission Diagram

```text
Example:
-rwxr-xr--

Breakdown:
[File Type] [Owner] [Group] [Others]
     -       rwx     r-x     r--

r = read
w = write
x = execute
```

### Enterprise Version

```text
Enterprise Cloud Server
|
|-- Application files
|   |-- owned by deployment user
|
|-- Config files
|   |-- readable by app service account
|   |-- writable only by approved admin or deployment process
|
|-- Log files
|   |-- writable by app
|   |-- readable by operations team
|
|-- Secret files
    |-- tightly restricted
    |-- never world-readable
```

---

## 12. Instructor Demo Script

### Demo Title
**Navigating and Securing a Linux Application Directory**

### Demo Objective
Demonstrate how a cloud engineer organizes application files, views content, inspects permissions, and fixes a script that cannot execute.

### Required Setup
- Linux shell, WSL, macOS terminal, or Linux VM
- No cloud resources required
- Optional EC2 Linux instance

### Step 1: Confirm User and Location

```bash
whoami
pwd
```

Expected output:

```text
student
/home/student
```

### Step 2: Create Application Directory

```bash
mkdir cloud-app
cd cloud-app
pwd
```

Expected output:

```text
/home/student/cloud-app
```

### Step 3: Create Files

```bash
touch app.log config.txt deploy.sh
ls -l
```

Expected output:

```text
-rw-r--r-- 1 student student 0 Apr 25 10:00 app.log
-rw-r--r-- 1 student student 0 Apr 25 10:00 config.txt
-rw-r--r-- 1 student student 0 Apr 25 10:00 deploy.sh
```

### Step 4: Add Sample Content

```bash
echo "application started" > app.log
echo "PORT=8080" > config.txt
printf '#!/usr/bin/env bash\necho deploying application\n' > deploy.sh
```

Note the `#!/usr/bin/env bash` first line (the **shebang**). It tells the kernel which interpreter to run when the file is executed directly with `./deploy.sh`.

### Step 5: View File Content

```bash
cat config.txt
tail app.log
cat deploy.sh
```

Expected output:

```text
PORT=8080
application started
#!/usr/bin/env bash
echo deploying application
```

### Step 6: Try to Execute Script

```bash
./deploy.sh
```

Expected output:

```text
-bash: ./deploy.sh: Permission denied
```

#### Why It Fails — and Why `bash deploy.sh` Would Have Worked

Explain the distinction students always ask about:
- `./deploy.sh` asks the kernel to **execute the file directly**. The kernel checks the execute (`x`) bit first; the file is `rw-r--r--` (no `x`), so it refuses with `Permission denied` *before* it ever reads the shebang.
- `bash deploy.sh` instead launches the `bash` interpreter and hands it the file to **read** as input. That only needs the read (`r`) bit, which the file has — so this would run without `chmod +x`.

```bash
bash deploy.sh        # works now: only needs READ, not execute
./deploy.sh           # still fails: direct execution needs the x bit
```

Teaching point:
> "Execute the file" needs `x`. "Feed the file to an interpreter" needs only `r`. We will fix the file the correct way (`chmod +x`) so `./deploy.sh` works directly, which is how CI and deployment systems invoke it.

### Step 7: Check Permissions

```bash
ls -l deploy.sh
```

Expected output:

```text
-rw-r--r-- 1 student student 47 Apr 25 10:05 deploy.sh
```

### Step 8: Fix Permissions

```bash
chmod +x deploy.sh
ls -l deploy.sh
./deploy.sh
```

Expected output:

```text
-rwxr-xr-x 1 student student 47 Apr 25 10:05 deploy.sh
deploying application
```

### Step 9: Show Ownership

```bash
whoami
id
ls -l
```

### Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| `mkdir: cannot create directory` | Directory already exists | Use a different folder name |
| `Permission denied` when creating files | Instructor is in restricted directory | Run `cd ~` and retry |
| `./deploy.sh: command not found` | Wrong directory or missing `./` | Run `pwd` and `ls -l` |
| Script does not print expected output | File content not added correctly | Run `cat deploy.sh` and fix content |
| `chmod` does not work | Wrong filename | Confirm with `ls -l` |

### Cleanup Steps

```bash
cd ~
rm -rf cloud-app
```

Warning: Only remove the demo folder you created.

---

## 13. Student Lab Manual

### Lab Title
**Linux Filesystem and Permission Practice**

### Lab Objective
Practice navigating Linux, creating an application-style folder structure, viewing files, and fixing a script permission issue.

### Estimated Time
35 to 45 minutes

### Student Prerequisites
- Terminal access
- Basic ability to type commands
- Linux shell, WSL, macOS terminal, Linux VM, or cloud sandbox

### Architecture or Workflow Overview

```text
Student Linux Environment
|
|-- week2-linux-lab
    |
    |-- app
    |-- config
    |-- logs
    |-- scripts
```

### Step 1: Confirm User and Directory

```bash
whoami
pwd
```

### Step 2: Create Lab Directory

```bash
mkdir week2-linux-lab
cd week2-linux-lab
pwd
```

### Step 3: Create Application-Style Folders

```bash
mkdir app logs scripts config
ls
```

Expected output:

```text
app  config  logs  scripts
```

### Step 4: Create Sample Files

```bash
touch logs/app.log
touch config/app.conf
touch scripts/deploy.sh
find . -type f
```

Expected output:

```text
./logs/app.log
./config/app.conf
./scripts/deploy.sh
```

### Step 5: Add Sample Content

```bash
echo "Application configuration file" > config/app.conf
echo "PORT=8080" >> config/app.conf
echo "Application started successfully" > logs/app.log
printf '#!/usr/bin/env bash\necho Deploying app...\n' > scripts/deploy.sh
```

The `#!/usr/bin/env bash` first line is the shebang — it tells the kernel which interpreter to use when the script is run directly.

### Step 6: View File Contents

```bash
cat config/app.conf
tail logs/app.log
cat scripts/deploy.sh
```

Expected output:

```text
Application configuration file
PORT=8080
Application started successfully
echo Deploying app...
```

### Step 7: Inspect Permissions

```bash
ls -l scripts/deploy.sh
```

Expected output:

```text
-rw-r--r-- 1 student student 42 Apr 25 10:30 scripts/deploy.sh
```

### Step 8: Try Running the Script

```bash
./scripts/deploy.sh
```

Expected output:

```text
-bash: ./scripts/deploy.sh: Permission denied
```

Confirm that running it through the interpreter works even without the execute bit (only read is needed):

```bash
bash scripts/deploy.sh
```

Expected output:

```text
Deploying app...
```

### Step 9: Fix Permission (Symbolic, Then Verify Octal)

```bash
chmod +x scripts/deploy.sh
ls -l scripts/deploy.sh
```

Expected output:

```text
-rwxr-xr-x 1 student student 42 Apr 25 10:31 scripts/deploy.sh
```

The same result with octal (`755` = `rwxr-xr-x`):

```bash
chmod 755 scripts/deploy.sh
ls -l scripts/deploy.sh
```

Now lock down the config as a normal file and treat a fake secret like a real one:

```bash
chmod 644 config/app.conf      # rw-r--r-- : owner writes, others read
printf 'API_TOKEN=do-not-share\n' > config/secret.env
chmod 600 config/secret.env    # rw------- : owner only, never world-readable
ls -l config/
```

Expected output (modes are what matters):

```text
-rw-r--r-- 1 student student  ... app.conf
-rw------- 1 student student  ... secret.env
```

### Step 10: Run Script Again

```bash
./scripts/deploy.sh
```

Expected output:

```text
Deploying app...
```

### Step 11: Create Notes File

```bash
echo "Linux permissions are important for security and application reliability." > notes.txt
cat notes.txt
```

### Step 12: Search for a Word

```bash
grep -r "Application" .
```

(`grep -r` and `grep -R` both search recursively; `-r` is the more common form. If `rg` is installed, `rg Application` does the same thing faster.)

Expected output:

```text
./config/app.conf:Application configuration file
./logs/app.log:Application started successfully
```

### Step 13: Text Processing on a Sample Log

Create a small access log and triage it with the pipeline tools from Section 7.6:

```bash
cat > logs/access.log <<'EOF'
10.0.0.1 GET /home 200
10.0.0.2 GET /login 200
10.0.0.1 POST /login 401
10.0.0.3 GET /home 500
10.0.0.1 GET /home 200
EOF

grep " 500" logs/access.log                 # only the error line
grep -c " 200" logs/access.log              # count of successful requests
cut -d' ' -f1 logs/access.log | sort | uniq -c | sort -rn   # busiest IPs first
awk '$4 == 500 { print $1 }' logs/access.log  # which IP got a 500
```

Expected highlights:

```text
10.0.0.3 GET /home 500     # from grep " 500"
3                          # from grep -c " 200"
      3 10.0.0.1           # top line of the uniq -c | sort -rn output
10.0.0.3                   # from the awk condition
```

### Validation Checklist
Students should be able to show:

```bash
pwd
find . -type f
ls -l scripts/deploy.sh config/secret.env
./scripts/deploy.sh
grep -r "Application" .
cut -d' ' -f1 logs/access.log | sort | uniq -c | sort -rn
```

### Troubleshooting Tips

| Problem | Likely Cause | Fix |
|---|---|---|
| `No such file or directory` | Wrong directory | Run `pwd` and `ls` |
| `Permission denied` | Script is not executable | Run `chmod +x scripts/deploy.sh` |
| `command not found` | Script path is wrong | Use `./scripts/deploy.sh` |
| Empty file | Content was not added | Use `echo "text" > file` |
| `mkdir: File exists` | Folder already exists | Continue or use a new name |

### Cleanup Steps

```bash
cd ~
rm -rf week2-linux-lab
```

Warning: Only delete the lab folder.

### Reflection Questions
1. Why did `./deploy.sh` fail with `Permission denied`, yet `bash deploy.sh` worked?
2. What changed after running `chmod +x`? What octal mode is equivalent?
3. Why is `chmod 600` correct for `secret.env` but wrong for a shared config?
4. Why should teams avoid `chmod 777`?
5. Write the pipeline that lists the busiest IP in `access.log`. Why is `sort` needed before `uniq -c`?
6. Where would you look for logs on a Linux server?
7. How does this lab connect to AWS EC2 or CI/CD runners?

### Optional Challenge Task

```bash
echo "echo Checking app health..." > scripts/health-check.sh
echo "echo App status: OK" >> scripts/health-check.sh
chmod +x scripts/health-check.sh
./scripts/health-check.sh
```

Expected output:

```text
Checking app health...
App status: OK
```

---

## 14. Troubleshooting Activity

### Incident Title
**Deployment Script Fails With Permission Denied**

### Business Impact
A deployment to a Linux application server is delayed because the deployment script cannot run.

### Symptoms

```bash
./deploy.sh
```

Output:

```text
Permission denied
```

### Starting Evidence

```bash
ls -l deploy.sh
```

Output:

```text
-rw-r--r-- 1 student student 27 Apr 25 10:00 deploy.sh
```

```bash
cat deploy.sh
whoami
```

Expected output:

```text
echo Deploying application
student
```

### Student Investigation Steps

```bash
pwd
ls -l
whoami
cat deploy.sh
ls -l deploy.sh
```

### Expected Root Cause
`deploy.sh` is missing execute permission.

### Correct Resolution

```bash
chmod +x deploy.sh
./deploy.sh
```

Expected output:

```text
Deploying application
```

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Running `sudo ./deploy.sh` immediately | Bypasses the real issue and teaches unsafe habits |
| Recreating the file | File already exists and content is valid |
| Using `chmod 777` | Overly permissive and unsafe |
| Assuming Git is broken | This is a local Linux permission issue |
| Assuming cloud access is broken | Script fails before any cloud operation |

### Instructor Hints
1. Does the file exist?
2. Can you read the file?
3. What does `ls -l` show?
4. Which permission allows execution?
5. What command adds execute permission?

### Preventive Action
- Store executable scripts in Git with correct permissions.
- Validate script permissions in CI.
- Document deployment steps.
- Avoid manual fixes in production.
- Use controlled deployment users and service accounts.

---

## 15. Scenario-Based Discussion Questions

1. A developer says, “The deployment script is broken.” What evidence would you check before agreeing?
   - Expected themes: file exists, content, permissions, current directory, user, error.
   - Follow-up: What command gives the fastest clue?

2. Why is `chmod 777` usually a bad fix?
   - Expected themes: too much access, security risk, accidental modification, enterprise policy violation.
   - Follow-up: What permission is safer for a deployment script?

3. How do Linux permissions affect application reliability?
   - Expected themes: app may not read config, write logs, or execute scripts.
   - Follow-up: Can a permission issue cause an outage?

4. In an enterprise environment, who should modify production scripts?
   - Expected themes: approved deployment users, CI/CD service accounts, platform team, limited admins.
   - Follow-up: How does Git review reduce risk?

5. How does today’s Linux practice connect to AWS EC2?
   - Expected themes: EC2 Linux uses same commands, SSH lands in shell, permissions affect apps.
   - Follow-up: What AWS setting could block access before Linux troubleshooting begins?

6. Should students use root or sudo for every command?
   - Expected themes: no, least privilege, understand error first.
   - Follow-up: When is sudo appropriate?

7. Why should DevOps engineers understand Linux if they mostly use Terraform and Kubernetes?
   - Expected themes: Terraform runners, Kubernetes nodes, containers, CI/CD, troubleshooting.
   - Follow-up: Where does Linux show up outside traditional servers?

---

## 16. Knowledge Check or Mini-Quiz With Answer Key

### Question 1
Which command shows your current directory?

A. `ls`  
B. `pwd`  
C. `cd`  
D. `whoami`

**Answer:** B  
**Explanation:** `pwd` prints the current working directory.

### Question 2
Which command lists hidden files?

A. `ls`  
B. `ls -l`  
C. `ls -la`  
D. `cat`

**Answer:** C  
**Explanation:** `ls -la` lists all files, including hidden files that start with a dot.

### Question 3
The `/var/log` directory commonly contains Linux and application logs.

**Answer:** True  
**Explanation:** `/var/log` is a common location for logs.

### Question 4
What does the `x` permission allow?

A. Read a file  
B. Write to a file  
C. Execute a file  
D. Delete a file automatically

**Answer:** C  
**Explanation:** `x` allows a file to be executed.

### Question 5
What command adds execute permission to `deploy.sh`?

**Answer:**

```bash
chmod +x deploy.sh
```

### Question 6
You run `./deploy.sh` and receive `Permission denied`. What should you check first?

**Answer:**

```bash
ls -l deploy.sh
```

### Question 7
Which command shows the current user?

A. `id`  
B. `whoami`  
C. `groups`  
D. `pwd`

**Answer:** B

### Question 8
Which AWS service commonly provides Linux virtual servers?

A. S3  
B. IAM  
C. EC2  
D. Route 53

**Answer:** C

### Question 9
If you SSH into an Amazon Linux EC2 instance, what type of environment are you usually accessing?

A. Windows PowerShell only  
B. Linux shell  
C. AWS billing console  
D. S3 bucket shell

**Answer:** B

### Question 10
Using `chmod 777` is always the best way to fix permission errors.

**Answer:** False  
**Explanation:** `chmod 777` is overly permissive and unsafe.

### Question 11
What is the difference between an absolute path and a relative path?

**Answer:** An absolute path starts from `/`, such as `/var/log/app.log`. A relative path starts from the current directory, such as `logs/app.log`.

### Question 12
A student says a file is missing, but you suspect they are in the wrong directory. Which two commands should they run?

**Answer:**

```bash
pwd
ls
```

### Question 13
What octal mode is equivalent to `rwxr-xr-x`?

A. `644`  
B. `600`  
C. `755`  
D. `777`

**Answer:** C  
**Explanation:** `rwx=7`, `r-x=5`, `r-x=5`, so `755`.

### Question 14
You need to lock down an SSH private key so only the owner can read and write it. Which command is correct?

A. `chmod 777 key.pem`  
B. `chmod 644 key.pem`  
C. `chmod 600 key.pem`  
D. `chmod +x key.pem`

**Answer:** C  
**Explanation:** `600` is `rw-------` — owner read/write only, no group or other access. SSH refuses keys that are group- or world-readable.

### Question 15
Which command counts how many lines in `app.log` contain the word `ERROR`?

A. `grep ERROR app.log`  
B. `grep -c ERROR app.log`  
C. `cat app.log | ERROR`  
D. `find app.log ERROR`

**Answer:** B  
**Explanation:** `grep -c` prints the count of matching lines.

### Question 16
Why does this pipeline `sort` before `uniq -c`?

```bash
cut -d' ' -f1 access.log | sort | uniq -c
```

**Answer:** `uniq` only collapses *adjacent* duplicate lines, so identical values must be grouped together first by `sort`; otherwise the counts are wrong.

### Question 17
You opened a file in `vim` and need to leave WITHOUT saving. What do you type?

**Answer:** Press `Esc`, then type `:q!` and Enter.

### Question 18
What does `>` do differently from `>>`?

**Answer:** `>` overwrites (truncates) the target file; `>>` appends to it, preserving existing content.

---

## 17. Homework Assignment

### Assignment Title
**Linux Command Cheat Sheet for Cloud Engineers**

### Scenario
You are joining a cloud operations team. Your manager asks you to create a beginner-friendly Linux command cheat sheet for new team members working with AWS EC2 Linux instances, CI/CD runners, and troubleshooting tasks.

### Student Tasks
Create a cheat sheet with at least 25 Linux commands.

Include commands from these categories:
1. Navigation
2. File and directory management
3. Viewing files
4. Searching text
5. Users and groups
6. Permissions and ownership
7. Disk checks
8. Process checks
9. Logs
10. Basic troubleshooting

### Expected Deliverables
Submit a document or markdown file with this format:

| Command | Category | What It Does | Example | Real-World Use |
|---|---|---|---|---|
| `pwd` | Navigation | Shows current directory | `pwd` | Confirm location before making changes |
| `chmod +x` | Permissions | Adds execute permission | `chmod +x deploy.sh` | Fix script execution issue |

### Required Commands

```bash
pwd
ls
ls -la
cd
mkdir
touch
cp
mv
rm
cat
less
head
tail
grep
find
cut
sort
uniq
wc
whoami
id
groups
chmod
chown
umask
df -h
du -sh
ps aux
top
journalctl
systemctl
```

### Submission Format
- Markdown file
- Word document
- PDF
- Git repo README

### Estimated Completion Time
1.5 to 2 hours

### Grading Criteria

| Criteria | Points |
|---|---:|
| Includes at least 25 commands | 25 |
| Commands are categorized clearly | 15 |
| Each command has a correct explanation | 20 |
| Each command has a useful example | 20 |
| Includes real-world DevOps, Cloud, or SRE use case | 15 |
| Clean formatting and readability | 5 |

### Optional Advanced Challenge
Add a section titled **Linux Commands I Would Use During a Production Incident** and include at least 10 commands in order of use.

---

## 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid It |
|---|---|---|
| Running commands in the wrong directory | Students do not check `pwd` first | Always run `pwd` before file changes |
| Forgetting `./` before scripts | Students expect Linux to search current folder automatically | Use `./script.sh` |
| Confusing `/` and `/root` | Names sound similar | Explain `/` is filesystem root and `/root` is root user home |
| Using `chmod 777` | Students want quick fix | Teach least privilege |
| Deleting wrong files with `rm` | Students do not verify path | Use `ls` before `rm` |
| Thinking `sudo` fixes everything | Confuses permission design with admin rights | Investigate before escalating privileges |
| Typing filenames incorrectly | Linux is case-sensitive | Use tab completion |
| Not reading error messages | Beginners panic when commands fail | Read exact output slowly |
| Not validating after changes | Students assume fix worked | Re-run command and check output |
| Ignoring ownership | Students focus only on mode bits | Use `ls -l` to inspect owner and group |

---

## 19. Real-World Enterprise Scenario

A logistics company runs an internal shipment tracking application on Linux servers in AWS EC2. The application team recently pushed a deployment package containing a new `deploy.sh` script.

During the deployment window, the DevOps engineer runs:

```bash
./deploy.sh
```

The command fails:

```text
Permission denied
```

The release is delayed. The operations manager wants to know whether this is an infrastructure issue, code issue, or access issue.

### Constraints
- Production changes require approval.
- Engineers must avoid root unless necessary.
- Scripts must be stored in Git and reviewed.
- Logs must be preserved for audit.
- Security does not allow world-writable files.
- Deployment window is limited.
- Rollback must remain available.

### DevOps Engineer Response
- Check script exists.
- Inspect permissions.
- Add execute permission safely.
- Confirm script content.
- Re-run deployment.
- Update Git if script permission was not preserved.
- Add pipeline validation.

### Cloud Engineer Response
- Confirm server access and user permissions.
- Validate whether issue is OS-level or cloud-level.
- Check EC2 access, SSH, or IAM relevance.
- Avoid unnecessary cloud changes.

### SRE Response
- Treat as release reliability issue.
- Capture timeline and symptoms.
- Recommend pre-deployment validation.
- Add checklist item for script permissions.
- Prevent repeated operational failure.

---

## 20. Instructor Tips

### Teaching Tips
- Start slow with navigation and paths.
- Ask students to explain command output.
- Use mistakes intentionally.
- Avoid too many flags at once.
- Reinforce that command-line confidence comes from repetition.

### Pacing Tips
- Spend enough time on `pwd`, `ls`, and `cd`.
- Do not rush permissions.
- Keep ownership and permissions visual.
- Teach numeric/octal permissions right after `rwx` in the same segment — it is core, not optional. Show `rwx=7, rw-=6, r-x=5, r--=4` and have students convert `755`/`644`/`600` both directions.

### Lab Support Tips
When students get stuck, ask:
1. What directory are you in?
2. What files do you see?
3. What command did you run?
4. What exact error did you get?
5. What does `ls -l` show?

### Helping Struggling Students
Use this pattern:

```bash
pwd
ls -la
```

Use this checklist:

```text
1. Where am I?
2. What files exist?
3. What permissions exist?
4. What user am I?
5. What error did I get?
```

### Challenging Advanced Students
Ask advanced students to:
- Set a `umask` of `0027`, create a new file, and explain the resulting `640` mode.
- Write a one-liner that prints the top 3 IPs by request count from `access.log` (`cut | sort | uniq -c | sort -rn | head -3`).
- Use `sed` to redact tokens from a log line before sharing it.
- Create a health-check script with a shebang and correct `chmod`.
- Compare local script permissions with Git-tracked permissions (`git ls-files -s`).
- Add validation logic to a script.

---

## 21. Student Outcome Checklist

### Students Should Be Able to Explain
- Why Linux matters in cloud roles
- What the Linux filesystem is
- Absolute vs relative paths
- Uses of `/home`, `/etc`, and `/var/log`
- Users and groups
- Owner, group, and others
- Read, write, and execute permissions, in both symbolic and octal (`755`/`644`/`600`) form
- The difference between file `x` (execute) and directory `x` (traverse)
- What `umask` does to new files
- Why `./script.sh` needs `x` but `bash script.sh` needs only `r`
- Why `chmod 777` is unsafe
- How Linux connects to AWS EC2, Azure VM, and GCP Compute Engine

### Students Should Be Able to Build or Configure
- Working lab directory
- Application-style folders
- Sample config, log, and script files (with a shebang)
- Executable script permissions (symbolic and octal)
- A locked-down `600` secret file
- A log-triage pipeline (`cut | sort | uniq -c | sort -rn`)
- Basic command cheat sheet

### Students Should Be Able to Troubleshoot
- Wrong directory issues
- Missing file issues
- Script permission errors
- Ownership confusion
- File content validation
- Hidden file visibility
- Simple command syntax mistakes

---

## 22. Class Completion Checklist

### Instructor Checklist Before Ending Class
Confirm students can:
- Run `pwd`, `ls`, and `cd`
- Create files and directories
- Use `cat`, `tail`, `grep`, and pipe into `cut`/`sort`/`uniq`
- Use `>`, `>>`, and `find`
- Explain `rwx` and convert it to/from octal (`755`/`644`/`600`)
- Run `ls -l` and interpret output
- Fix `Permission denied` with `chmod +x` (and know `bash script.sh` works without it)
- Save and quit `vim` (including `:q!`)
- Explain why Linux matters for cloud work

Also confirm:
- Students know the homework assignment.
- Students understand cleanup instructions.
- Students know Class 2 covers processes, services, logs, SSH, and troubleshooting.

### Student Checklist Before Leaving Class
Students should verify:

```bash
cd ~/week2-linux-lab
find . -type f
ls -l scripts/deploy.sh
./scripts/deploy.sh
```

Expected output:

```text
Deploying app...
```

### Items to Verify Before Moving to Class 2
Students should be comfortable with:
- Navigating directories
- Creating and viewing files
- Understanding basic permissions
- Running scripts
- Reading command output
- Asking troubleshooting questions based on evidence

Class 2 builds on this by moving from static files into live system operations: processes, services, logs, SSH, system health, and failed service troubleshooting.

---

## Class Artifacts & Validation

These are the on-disk, validated artifacts in [`labs/linux-shell-automation/`](../../labs/linux-shell-automation/) that back this class. Class 1's concepts — file/dir operations, users/groups/ownership, symbolic vs octal permissions, and fixing a script the *correct* way — are exercised by these real scripts and by the Week-2 troubleshooting fixture, not just the inline snippets above. All commands below were run in this environment (bash 5.1, GNU coreutils, ShellCheck 0.10.0).

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/linux-shell-automation/solution/user-audit.sh | shell | Lists human accounts (UID ≥ min) from `/etc/passwd` and flags sudo/wheel membership — the users/groups/ownership topic of this class | `bash -n solution/user-audit.sh` then `shellcheck -x solution/user-audit.sh` | PASS (syntax + lint-clean) |
| 2 | labs/linux-shell-automation/solution/disk-check.sh | shell | Parses `df -P` (space-safe mount paths) and exits non-zero on a `--threshold` breach; shows octal-permission/`chmod +x` script execution in practice | `bash -n solution/disk-check.sh` then `shellcheck -x solution/disk-check.sh` | PASS (syntax + lint-clean) |
| 3 | labs/linux-shell-automation/solution/lib/common.sh | shell | Sourced library (`log()`, `die()`, `require_cmd()`); diagnostics to stderr so stdout stays pipeable | `bash -n solution/lib/common.sh` then `shellcheck -x solution/lib/common.sh` | PASS (syntax + lint-clean) |
| 4 | labs/linux-shell-automation/broken/disk-check-broken.sh | shell | Week-2 troubleshooting fixture — two real bugs (unquoted `$mount` word-split; `>=` off-by-one). Mirrors this class's "fix the script the correct way" troubleshooting activity | `shellcheck -x broken/disk-check-broken.sh` | PASS — fixture intentionally reports SC2086 (unquoted `$mount`); `validate.sh` asserts it still does |
| 5 | labs/linux-shell-automation/starter/ + solution/ | shell | Starter (intentionally gapped `TODO(student)`) and reference solution pair students complete and check against | `./validate.sh` (all gates) | PASS — `22 passed, 0 failed` |
| 6 | labs/linux-shell-automation/tests/run-tests.sh | shell | Functional test suite that fabricates a sandbox and asserts behaviour of the solution scripts | `bash tests/run-tests.sh` | PASS — `25 passed, 0 failed`, exit 0 |

> Note: Class 1 also has its own inline mini-lab (create `week2-linux-lab/`, `chmod +x`, octal modes, `grep -r`, a `cut | sort | uniq -c` pipeline). That mini-lab is a teaching aid run live in the terminal; the rows above are the committed, validated module artifacts students keep and reuse. There is **no live cloud/EC2 evidence** for this class — all validation is static (syntax + lint + functional tests), which is appropriate since the class provisions no cloud resources.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — the four `solution/*.sh` scripts plus `lib/common.sh` and the `broken/` fixture (not just fenced snippets).
- [x] Each artifact passes its **validation gate** from §3 (`bash -n` syntax **and** `shellcheck -x`); output captured in the lab README's Validation section and re-run above.
- [x] Lab has **starter** (intentionally incomplete `TODO(student)` gaps) and **solution** (reference) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, and **cost notes** ($0, local-only).
- [x] **Cleanup/teardown** is provided and idempotent — the inline mini-lab cleans up with `rm -rf week2-linux-lab`; the test suite uses a `mktemp -d` sandbox removed via `trap cleanup EXIT`; no cloud resources are created.
- [x] **Instructor answer key** exists — lab answer key in the module README; this class ships a quiz answer key (Section 16), homework grading rubric (Section 17), and a troubleshooting answer key (Section 14 + the module Troubleshooting section).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `broken/disk-check-broken.sh` (two genuine bugs), plus this class's own reproducible `Permission denied` activity (Section 14).
- [x] **Expected outputs** are shown for the demo (Section 12), the lab (Section 13), and each manifest gate.
- [x] **Cost & security warnings** present — `chmod 777` warnings, `600` for secrets, `rm -rf` cautions (Sections 9, 10, 14); no secrets are committed; cost is $0.
- [x] **Cross-references** to the module repo and to Class 2 / Week 3 are present and verified.
- [x] The **artifact manifest** (§4.2) is present above and every path resolves (verified with `ls`).
