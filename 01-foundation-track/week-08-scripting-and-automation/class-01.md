# Week 8: Bash Scripting and Automation
> **▶ Runnable lab for this class:** [`labs/linux-shell-automation/`](../../labs/linux-shell-automation/) · [`labs/python-automation/`](../../labs/python-automation/) · [`labs/ansible-config-mgmt/`](../../labs/ansible-config-mgmt/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 1 Package: Bash Scripting and Automation

**Week:** 8
**Class:** 1
**Track:** Unified DevOps · Cloud · SRE Track

---

# 1. Class Overview

## Class Title

**Bash Scripting Basics, Variables, Conditions, and Exit Codes**

## Class Purpose

This class introduces students to Bash scripting as a practical automation tool for DevOps, Cloud Engineering, and SRE work. Students will learn how to create simple scripts, run them safely, use variables, make decisions with conditions, capture command output, and check whether commands succeeded or failed.

## How This Class Connects to the Overall Course

Students already learned Linux fundamentals, networking basics, Git workflows, and AWS foundations. This class builds on those skills by showing students how to automate repeated Linux and operational tasks instead of running commands manually one at a time.

This class prepares students for:

- Class 2: Python for DevOps automation (the other half of this week's scripting toolkit)
- Week 9: CI/CD fundamentals, where exit codes become pipeline gates
- Week 10: Docker and containers
- Later Terraform, Kubernetes, observability, and incident response work

## What Students Will Build, Analyze, or Practice

Students will:

- Build a basic Bash script
- Make the script executable
- Use variables and command substitution
- Use `if`, `else`, and `elif`
- Check command exit codes
- Build a simple Linux health check script
- Troubleshoot script execution problems

---

# 2. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** why Bash scripting is useful in DevOps, Cloud Engineering, and SRE work.
2. **Create** a Bash script using a shebang and standard script structure.
3. **Configure** file permissions so a script can run safely.
4. **Use** variables and command substitution to make scripts reusable.
5. **Build** conditional logic using `if`, `else`, `elif`, the `[[ ]]` test construct, and `case`.
6. **Validate** command success or failure using exit codes.
7. **Apply** production-safety idioms (`set -euo pipefail`, `trap` cleanup) and lint scripts with ShellCheck.
8. **Write** functions, `for`/`while` loops, and arrays to remove repetition from operational scripts.
9. **Process** text and logs with `grep`, `sed`, and `awk`.
10. **Schedule** scripts with cron and systemd timers, including log cleanup and report generation.
11. **Troubleshoot** common Bash script errors such as permission issues, wrong paths, and bad syntax.
12. **Document** what a health check script does and how it could be used in operations.

---

# 3. Prerequisites Students Should Already Know

## Required Prior Concepts

Students should already understand:

- Basic Linux commands
- Files and directories
- File permissions
- Running commands in a terminal
- Basic service management with `systemctl`
- Viewing logs with `journalctl`
- Basic Git workflow
- Basic AWS account and EC2 concepts

## Required Tools Already Installed

Students should have:

- Linux terminal or WSL on Windows
- VS Code or another text editor
- Bash shell
- Git
- SSH client
- AWS CLI, optional for this class
- Access to a Linux VM, local Linux environment, WSL, or cloud-based Linux instance

## Required Accounts or Access

Recommended:

- Local Linux environment, WSL, or classroom-provided Linux VM
- Optional AWS account if instructor wants to demonstrate on EC2
- No production access required

## Files, Repos, or Sample Code Needed

The instructor may create a simple class folder:

```bash
mkdir -p ~/devops-course/week-08/class-01
cd ~/devops-course/week-08/class-01
```

Students can use the same folder for all class scripts.

---

# 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Bash | A command-line shell used to run Linux commands and scripts | Common in Linux servers, cloud instances, CI/CD pipelines, and incident response |
| Script | A file containing commands that run in sequence | Used to automate repeatable operational tasks |
| Shebang | The first line of a script, such as `#!/bin/bash`, that tells Linux what interpreter to use | Helps systems know how to execute the script |
| Variable | A named value that stores text, numbers, paths, or command output | Makes scripts reusable across environments |
| Command substitution | Capturing the output of a command using `$(command)` | Used to store dynamic values such as date, hostname, disk usage, or AWS CLI output |
| Conditional logic | Logic that allows scripts to make decisions | Used when scripts need to react differently based on system state |
| Exit code | A numeric value returned by a command to indicate success or failure | Used heavily in CI/CD pipelines and automation |
| `chmod` | Linux command used to change file permissions | Required when making a script executable |
| Executable permission | Permission that allows a file to be run as a program | Without it, scripts may fail with `Permission denied` |
| `systemctl` | Tool used to inspect and manage Linux services | Useful for checking whether services like SSH, cron, Docker, or Nginx are running |
| Health check | A script or process that validates whether a system or service is working | Common in operations, monitoring, load balancers, and incident response |

---

# 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| Bash | Main scripting language for this class |
| Linux CLI | Used to run commands, inspect files, and execute scripts |
| VS Code or nano | Used to write and edit script files |
| `chmod` | Used to make scripts executable |
| `echo` | Used to print messages and script output |
| `whoami` | Used to identify the current user |
| `hostname` | Used to identify the server name |
| `date` | Used to print current date and time |
| `df -h` | Used to check disk usage |
| `free -h` | Used to check memory usage |
| `ps` | Used to inspect running processes |
| `systemctl` | Used to check service status |
| `journalctl` | Optional tool for viewing system logs |
| AWS EC2 | Optional cloud-based Linux server for realistic demo context |
| AWS CLI | Optional for later automation examples and AWS integration |

---

# 6. AWS Services Used

This class is mostly Linux and Bash focused, but AWS appears as the primary cloud operations context.

| AWS Service | How It Connects to the Class |
|---|---|
| EC2 | Students can run Bash scripts on Linux EC2 instances, just like real cloud operations teams |
| Systems Manager, preview only | Later automation can run scripts across EC2 instances without direct SSH |
| CloudWatch, preview only | Health check scripts can eventually feed logs or metrics into monitoring tools |
| IAM, preview only | Any AWS CLI automation must use safe permissions and avoid hardcoded credentials |

## AWS Teaching Note

Do not make AWS the main complexity of this class. Use AWS to explain where Bash scripts run in real cloud environments:

```text
Cloud engineer logs into EC2
        |
        v
Runs health check script
        |
        v
Finds disk, memory, service, or network issue
        |
        v
Reports finding or automates the check
```

---

# 7. Azure and GCP Comparison Notes

Keep this section short during class.

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Linux VM | EC2 | Azure Virtual Machine | Compute Engine |
| CLI automation | AWS CLI plus Bash | Azure CLI plus Bash | gcloud CLI plus Bash |
| Script execution at scale | Systems Manager | Azure Run Command / Automation | OS Config / Cloud Run jobs depending on use case |

## Practical Comparison

Bash is cloud-agnostic. A script that checks disk, memory, logs, and services works similarly on Linux servers in AWS, Azure, GCP, on-prem, or local labs.

---

# 8. Time-Boxed Instructor Agenda

## 3-Hour Agenda

| Time | Duration | Segment |
|---:|---:|---|
| 0:00 to 0:10 | 10 min | Welcome, Week 8 context, why Bash matters |
| 0:10 to 0:20 | 10 min | Real-world Bash use cases in DevOps, Cloud, and SRE |
| 0:20 to 0:35 | 15 min | Bash script structure, shebang, comments, execution methods |
| 0:35 to 0:55 | 20 min | Variables, quoting, command substitution, and `set -euo pipefail` |
| 0:55 to 1:15 | 20 min | Conditions with `if`/`elif`/`case`, `[ ]` vs `[[ ]]`, exit codes |
| 1:15 to 1:25 | 10 min | Break |
| 1:25 to 1:50 | 25 min | Functions, loops, arrays, and `trap` cleanup |
| 1:50 to 2:10 | 20 min | Text processing with `grep`, `sed`, `awk`; ShellCheck linting |
| 2:10 to 2:25 | 15 min | Scheduling with cron and systemd timers (log cleanup + reports) |
| 2:25 to 2:50 | 25 min | Student lab: hardened health check + scheduled fleet report |
| 2:50 to 3:00 | 10 min | Troubleshooting recap, discussion, homework explanation |

---

# 9. Instructor Lesson Plan

## Step 1: Open the Class

Explain:

“Last week we worked with AWS compute, storage, and databases. This week we start automating repeated operational work. Bash is one of the simplest and most common tools used by DevOps Engineers, Cloud Engineers, and SREs because it lets us combine Linux commands into repeatable workflows.”

Show:

```bash
pwd
whoami
hostname
date
```

Ask:

“What are some tasks you would not want to do manually every morning?”

Expected answers:

- Check disk usage
- Check service status
- Check logs
- Validate deployments
- Restart failed services
- Generate health reports

## Step 2: Explain What a Bash Script Is

Explain:

A Bash script is just a file containing shell commands. Instead of typing commands one by one, we put them in a file and run them together.

Show a simple script:

```bash
#!/bin/bash

echo "Hello from my first Bash script"
date
hostname
```

Explain:

- `#!/bin/bash` tells Linux to run the file using Bash
- `echo` prints text
- Commands execute from top to bottom

Pause for questions.

## Step 3: Explain Script Execution Methods

Show two ways to run a script:

```bash
bash script.sh
```

and:

```bash
chmod +x script.sh
./script.sh
```

Explain the difference:

- `bash script.sh` runs the file by passing it to Bash
- `./script.sh` runs it as an executable file
- Executable permission is needed for `./script.sh`

Teaching tip:

Many beginners confuse “file exists” with “file can execute.” Make this distinction clear.

## Step 4: Teach Variables and Quoting

Explain:

Variables store values so we do not repeat ourselves.

Show:

```bash
SERVICE_NAME="ssh"
echo "Checking service: $SERVICE_NAME"
```

Explain quoting:

```bash
NAME="DevOps Student"
echo "$NAME"
```

Explain:

Always quote variables unless you have a specific reason not to. Quoting avoids issues when values contain spaces or special characters.

Pause and ask:

“What could go wrong if a file path has spaces and we do not quote it?”

## Step 5: Teach Command Substitution

Explain:

Command substitution lets us save command output into a variable.

Show:

```bash
CURRENT_DATE=$(date)
SERVER_NAME=$(hostname)

echo "Date: $CURRENT_DATE"
echo "Server: $SERVER_NAME"
```

Real-world example:

A health report script may include the date, hostname, disk usage, and service status automatically.

## Step 6: Teach Conditions

Explain:

Scripts need decision-making. Conditions let scripts respond to different system states.

Show:

```bash
if systemctl is-active --quiet ssh; then
    echo "ssh is running"
else
    echo "ssh is not running"
fi
```

Explain:

- `if` starts the decision
- `then` begins the action
- `else` handles the alternative
- `fi` ends the condition

Beginner tip:

`fi` is `if` reversed. This helps students remember it.

## Step 7: Teach Exit Codes

Explain:

Every Linux command returns an exit code.

- `0` usually means success
- Non-zero usually means failure

Show:

```bash
ls /tmp
echo $?

ls /fake-directory
echo $?
```

Explain:

CI/CD pipelines use exit codes heavily. If tests fail and return a non-zero exit code, the pipeline fails.

Ask:

“Why would a pipeline need to stop when a command fails?”

Expected answer:

To prevent bad code, broken infrastructure, or unsafe deployments from continuing.

## Step 8: Instructor Demo

Transition:

“Now we will combine these ideas into a practical health check script.”

Run the demo script from Section 12.

## Step 9: Student Lab

Transition:

“You will now create your own beginner health check script. The goal is not to memorize every command. The goal is to understand the script structure and how to validate your work.”

Support students as they create and run the script.

## Step 10: Troubleshooting and Wrap-Up

Review common issues:

- `Permission denied`
- Wrong file path
- Bad filename
- Missing shebang
- Typo in command
- Incorrect service name
- Missing quotes

End with:

“Today you built the foundation and then hardened it: `set -euo pipefail`, `trap` cleanup, functions, loops, `grep`/`sed`/`awk`, ShellCheck, and a cron/systemd-scheduled fleet report. In Class 2 we switch to Python, which is the better tool once automation needs structured data, JSON, APIs, and larger logic.”

---

# 10. Instructor Lecture Notes

## Why Bash Matters

Bash is not just a beginner topic. It is used every day in real environments. Even advanced cloud and DevOps teams use Bash because it is available almost everywhere.

Instructor talking point:

“Bash is often the glue between tools. Terraform, Docker, Kubernetes, AWS CLI, Git, and CI/CD systems all commonly call shell commands somewhere in the workflow.”

## Examples of Real Bash Use

DevOps Engineers use Bash to:

- Run build steps
- Validate files before a deployment
- Trigger Docker builds
- Run deployment commands
- Check environment variables in pipelines

Cloud Engineers use Bash to:

- Query cloud resources
- Run AWS CLI commands
- Check EC2 instance health
- Validate network reachability
- Generate resource reports

SREs use Bash to:

- Collect logs during incidents
- Check service status
- Validate disk, memory, and CPU
- Run emergency remediation steps
- Automate repetitive operational checks

## Common Misconception: Bash Is Only for Simple Tasks

Students may think Bash is only for small scripts. Explain that Bash is simple, but powerful. It should not replace every tool, but it is excellent for connecting tools and automating routine tasks.

Say:

“Bash is not always the final automation solution, but it is often the fastest way to automate something safely when used with good practices.”

## Common Misconception: If a Script Runs Once, It Is Ready

Explain that production scripts need:

- Clear names
- Comments
- Logging
- Error handling
- Safe defaults
- No hardcoded secrets
- Testing in non-production
- Code review

## Variables

Use variables when values may change:

```bash
SERVICE_NAME="ssh"
REPORT_DIR="$HOME/reports"
THRESHOLD=80
```

Explain:

“If I hardcode values everywhere, the script becomes hard to update. If I use variables, I can change behavior in one place.”

## Command Substitution

Use command substitution for dynamic data:

```bash
TODAY=$(date +%Y-%m-%d)
HOST=$(hostname)
```

Real-world example:

A report file can include the current date:

```bash
REPORT_FILE="health-report-$TODAY.txt"
```

## Conditions

Conditions allow scripts to react:

```bash
if [ -f "/etc/passwd" ]; then
    echo "File exists"
else
    echo "File missing"
fi
```

Use cases:

- Is a file present?
- Is a directory present?
- Is disk usage too high?
- Is service running?
- Did command succeed?
- Is a required variable empty?

## Exit Codes

Exit codes are critical in automation.

Example:

```bash
systemctl is-active --quiet ssh
echo $?
```

Explain:

“In automation, we do not always read text output. Scripts and pipelines often make decisions based on success or failure codes.”

## Enterprise Context

In an enterprise environment, a Bash script might be part of:

- A GitLab pipeline
- A production support runbook
- A daily health report
- A Linux patching workflow
- A pre-deployment validation
- A cloud inventory script
- A troubleshooting toolkit

Important production warning:

Never put secrets, passwords, access keys, or tokens directly into scripts.

---

# 11. Whiteboard Explanation

## Simple Diagram: How a Bash Script Works

```text
Engineer runs script
        |
        v
Linux reads shebang
        |
        v
Bash runs commands line by line
        |
        v
Commands produce output and exit codes
        |
        v
Script uses variables and conditions
        |
        v
Script prints result or performs action
```

## Step-by-Step Flow

1. The engineer runs the script.
2. Linux checks the shebang line.
3. Bash executes each command in order.
4. Variables store reusable values.
5. Command substitution captures dynamic output.
6. Conditions decide what happens next.
7. Exit codes tell the script whether a command succeeded.
8. The script prints a result or performs an action.

## Example Health Check Flow

```text
Start health check
        |
        v
Get hostname and date
        |
        v
Check disk usage
        |
        v
Check memory usage
        |
        v
Check service status
        |
        v
If service is running
        | 
        v
Print success
        |
        v
If service is not running
        |
        v
Print warning
        |
        v
End health check
```

## Enterprise Version of the Diagram

```text
Operations team
      |
      v
Scheduled health check script
      |
      v
Linux servers or EC2 instances
      |
      v
Checks disk, memory, services, logs
      |
      v
Report saved or sent to team
      |
      v
Issues become tickets, alerts, or incident actions
```

## What Each Component Means

| Component | Meaning |
|---|---|
| Operations team | Team responsible for system health |
| Script | Repeatable automation |
| Linux/EC2 server | Target system being checked |
| Disk, memory, services | Core operational signals |
| Report | Evidence for support or troubleshooting |
| Ticket or alert | Follow-up workflow for issues |

---

# 12. Instructor Demo Script

## Demo Title

**Create a Basic Linux Health Check Script**

## Demo Objective

Show students how to build a Bash script that checks basic Linux system health and service status.

## Required Setup

Instructor should have:

- Linux terminal, WSL, or EC2 Linux instance
- Bash shell
- Text editor such as VS Code or nano
- `systemctl` available if possible

Create working directory:

```bash
mkdir -p ~/devops-course/week-08/class-01
cd ~/devops-course/week-08/class-01
```

## Step 1: Create the Script File

Command:

```bash
nano health-check.sh
```

Paste:

```bash
#!/bin/bash

echo "===== Basic Server Health Check ====="

echo "Current date and time:"
date

echo
echo "Current user:"
whoami

echo
echo "Hostname:"
hostname

echo
echo "Disk usage:"
df -h

echo
echo "Memory usage:"
free -h

echo
echo "Top running processes by memory:"
ps aux --sort=-%mem | head -5

SERVICE_NAME="ssh"

echo
echo "Checking service: $SERVICE_NAME"

if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "$SERVICE_NAME is running"
else
    echo "$SERVICE_NAME is not running"
fi

echo
echo "Health check completed"
```

Save and exit.

## Step 2: Show File Exists

Command:

```bash
ls -l
```

Expected output:

```text
-rw-r--r-- 1 student student 500 Apr 26 10:00 health-check.sh
```

Explain:

The script exists, but it is not executable yet because there is no `x` permission.

## Step 3: Try to Run It Directly

Command:

```bash
./health-check.sh
```

Possible expected output:

```text
bash: ./health-check.sh: Permission denied
```

Explain:

This is intentional. The script file does not have executable permission.

## Step 4: Make Script Executable

Command:

```bash
chmod +x health-check.sh
ls -l health-check.sh
```

Expected output:

```text
-rwxr-xr-x 1 student student 500 Apr 26 10:00 health-check.sh
```

Explain:

The `x` means the file can be executed.

## Step 5: Run the Script

Command:

```bash
./health-check.sh
```

Expected output example:

```text
===== Basic Server Health Check =====
Current date and time:
Sun Apr 26 10:05:00 EDT 2026

Current user:
student

Hostname:
devops-lab

Disk usage:
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        30G  8.1G   22G  28% /

Memory usage:
               total        used        free
Mem:           3.8Gi       1.2Gi       2.1Gi

Top running processes by memory:
USER         PID %CPU %MEM COMMAND
...

Checking service: ssh
ssh is running

Health check completed
```

## Step 6: Show Alternate Execution Method

Command:

```bash
bash health-check.sh
```

Explain:

This works even without executable permission because we are explicitly asking Bash to run the file.

## Step 7: Demonstrate Exit Codes

Command:

```bash
systemctl is-active --quiet ssh
echo $?
```

Expected output if service is active:

```text
0
```

Try a fake service:

```bash
systemctl is-active --quiet fake-service-name
echo $?
```

Expected output: a **non-zero** value (commonly `3` for an inactive or unknown unit, but the exact number is version- and state-dependent).

```text
3
```

Teaching point:

Do not teach students to match a specific number. Teach them to check `0` (success) versus **any non-zero** value (failure). Robust scripts branch on success/failure, not on a particular code.

Explain:

Exit codes allow scripts to make decisions.

## Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| `systemctl: command not found` | Environment does not use systemd | Use `ps aux` check instead |
| `ssh is not running` | Service may be named differently | Try `sshd` or explain OS differences |
| `Permission denied` | Script not executable | Run `chmod +x` |
| `No such file or directory` | Wrong directory | Run `pwd` and `ls` |
| Bad copy/paste formatting | Hidden characters or missing quotes | Re-type affected line |

## Recovery Alternative if `systemctl` Does Not Work

Use this condition instead:

```bash
if ps aux | grep -v grep | grep -q ssh; then
    echo "ssh process found"
else
    echo "ssh process not found"
fi
```

## Cleanup Steps

Local cleanup:

```bash
rm -f health-check.sh
```

Optional if using a class folder:

```bash
cd ~
rm -rf ~/devops-course/week-08/class-01
```

No AWS cleanup is required unless an EC2 instance was created for the demo. If EC2 was used, stop or terminate it according to lab policy.

---

# 12A. Production-Grade Bash (Deep Dive)

The basic health check above runs, but it is **not** production-grade. A junior engineer can write a script that works once on their laptop. A senior engineer writes a script that fails safely, is re-runnable, is linted, and can be scheduled to run unattended at 3 a.m. with no human watching. This section closes that gap. Everything here is testable in the same lab VM, WSL, or EC2 instance used above.

## 12A.1 The Safety Header: `set -euo pipefail` and `trap`

The single most important habit in production Bash is the safety header. Put it on the line directly after the shebang of **every** non-trivial script.

```bash
#!/usr/bin/env bash
set -euo pipefail
```

What each option does, and the failure it prevents:

| Option | Meaning | Failure it prevents |
|---|---|---|
| `set -e` | Exit immediately if any command returns non-zero | A failed `cd` followed by a destructive `rm` running in the wrong directory |
| `set -u` | Error on use of an unset variable | `rm -rf "$DIR/"` deleting `/` because `DIR` was never set (expands to empty) |
| `set -o pipefail` | A pipeline fails if **any** command in it fails, not just the last | `curl badurl | grep ok` reporting success because `grep` exited 0 |

Why `#!/usr/bin/env bash` instead of `#!/bin/bash`? `env` finds Bash on the `PATH`, which is more portable across distros and macOS (where Bash may live in `/usr/local/bin` or `/opt/homebrew/bin`). Both are acceptable; `env bash` is the safer default for portable scripts.

> **Important caveat on `set -e`:** It does **not** fire for a command whose non-zero exit you are deliberately testing (e.g., the command in an `if`, or one followed by `|| true`). That is correct and intended. So `if grep -q foo file; then` is safe even under `set -e`.

### `trap` for cleanup

`set -e` makes a script exit on the first error — but what about the temp file or lock it already created? `trap` registers a cleanup function that runs no matter how the script exits (success, error, or Ctrl-C).

```bash
#!/usr/bin/env bash
set -euo pipefail

# mktemp creates a uniquely named temp file safely (no race, no guessing names)
WORKDIR="$(mktemp -d)"

cleanup() {
    # This runs on ANY exit: success, error, or interrupt.
    rm -rf "$WORKDIR"
    echo "Cleaned up $WORKDIR"
}
trap cleanup EXIT

echo "Working in $WORKDIR"
# ... do work that writes into "$WORKDIR" ...
# No explicit cleanup needed at the end; the trap handles it.
```

`trap cleanup EXIT` is the workhorse. You can also trap specific signals (`trap cleanup INT TERM`), but `EXIT` covers normal exit and most interrupts in one line.

## 12A.2 `[ ]` vs `[[ ]]`

Class 1 used `[ ... ]` (the POSIX `test` builtin). Senior Bash prefers `[[ ... ]]`, a Bash keyword that is safer and more capable:

```bash
name="DevOps Student"

# [ ] breaks here: word-splitting turns the unquoted variable into multiple args.
# Always quote inside [ ].
if [ "$name" = "DevOps Student" ]; then echo "match"; fi

# [[ ]] does not word-split and supports glob/regex matching:
if [[ $name == "DevOps Student" ]]; then echo "match"; fi
if [[ $name == DevOps* ]]; then echo "starts with DevOps"; fi
if [[ $name =~ ^DevOps ]]; then echo "regex match"; fi
```

Rules of thumb:
- Use `[[ ]]` for string and file tests in Bash scripts.
- Use `(( ))` for arithmetic: `if (( disk_usage > 80 )); then ...`.
- Reserve `[ ]` only when you specifically need POSIX `sh` portability.

## 12A.3 Functions, `local`, and Return Values

Functions remove repetition and make scripts testable. Use `local` for variables so they do not leak into the global scope.

```bash
#!/usr/bin/env bash
set -euo pipefail

log() {
    # Structured, timestamped log line written to stderr so it does not
    # pollute stdout (which may be a report or piped value).
    local level="$1"; shift
    echo "$(date '+%Y-%m-%dT%H:%M:%S%z') [$level] $*" >&2
}

# A function "returns" data via stdout (captured with $(...)),
# and signals success/failure via its exit code (0 = ok).
check_service() {
    local service="$1"
    if systemctl is-active --quiet "$service"; then
        return 0
    else
        return 1
    fi
}

if check_service ssh; then
    log INFO "ssh is running"
else
    log WARN "ssh is NOT running"
fi
```

Key points: a function's `return` value is an **exit code** (0–255), not data. To return text, `echo` it and capture with `result="$(my_func)"`. Always `shift` after consuming positional args, and prefer `"$@"` (quoted) to pass all remaining arguments through intact.

## 12A.4 Loops and Arrays

```bash
#!/usr/bin/env bash
set -euo pipefail

# Arrays hold lists safely, even with spaces in elements.
services=("ssh" "cron" "systemd-journald")

# for loop over an array. Quote "${services[@]}" so each element stays whole.
for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "OK:   $service"
    else
        echo "FAIL: $service"
    fi
done

# while loop reading a file line-by-line WITHOUT word-splitting/glob issues.
# IFS= keeps leading/trailing whitespace; -r stops backslash mangling.
while IFS= read -r line; do
    echo "Read: $line"
done < /etc/hostname

# C-style arithmetic loop:
for (( i=1; i<=3; i++ )); do
    echo "Attempt $i"
done
```

> **Pitfall:** never do `for f in $(ls *.log)`. Filenames with spaces break it, and it fails under `set -u` if no match. Use a glob directly: `for f in *.log; do ...; done` (and guard with `[[ -e "$f" ]]` for the no-match case).

## 12A.5 `case` and `getopts` Argument Parsing

`case` is cleaner than long `if/elif` chains:

```bash
read -r -p "Environment (dev/test/prod): " env
case "$env" in
    dev|test)  echo "Non-production" ;;
    prod)      echo "PRODUCTION — extra confirmation required" ;;
    *)         echo "Unknown environment: $env" >&2; exit 1 ;;
esac
```

For real scripts, parse flags with `getopts` instead of relying on positional `$1`/`$2`:

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() { echo "Usage: $0 -s <service> [-t <threshold>]" >&2; exit 1; }

service=""
threshold=80
while getopts ":s:t:h" opt; do
    case "$opt" in
        s) service="$OPTARG" ;;
        t) threshold="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

[[ -z "$service" ]] && usage
echo "Checking $service with disk threshold ${threshold}%"
```

## 12A.6 Text Processing: `grep`, `sed`, `awk`

These three tools are daily SRE/DevOps work — parsing logs, extracting fields, and transforming output. Learn them as a unit.

**`grep` — find lines:**

```bash
grep "ERROR" app.log               # lines containing ERROR
grep -i "error" app.log            # case-insensitive
grep -c "ERROR" app.log            # count matching lines
grep -n "ERROR" app.log            # show line numbers
grep -E "ERROR|WARN" app.log       # extended regex (alternation)
grep -v "DEBUG" app.log            # invert: lines NOT containing DEBUG
```

**`sed` — stream edit / substitute:**

```bash
sed 's/ERROR/PROBLEM/g' app.log    # replace all ERROR with PROBLEM (to stdout)
sed -n '10,20p' app.log            # print only lines 10-20
sed 's/%//' <<< "85%"              # strip a trailing % -> 85
sed -i.bak 's/old/new/g' config    # edit file in place, keeping config.bak backup
```

**`awk` — field extraction and aggregation** (the most powerful of the three):

```bash
# Print the 5th column (Use%) of df for the root filesystem, no % sign:
df / | awk 'NR==2 {gsub("%","",$5); print $5}'

# Sum the bytes (column 10) in an nginx access log:
awk '{sum += $10} END {print sum " bytes total"}' access.log

# Count requests per HTTP status code (column 9):
awk '{count[$9]++} END {for (code in count) print code, count[code]}' access.log
```

This replaces the fragile `df / | tail -1 | awk '{print $5}' | sed 's/%//'` chain from the Class 1 challenge with a single robust `awk` expression — a good "evidence → simpler fix" teaching moment.

## 12A.7 ShellCheck: Lint Before You Ship

ShellCheck is the de-facto Bash linter. Every serious script author runs it, and it belongs in CI. It catches the exact bugs taught above (unquoted variables, useless `cat`, `set -e` foot-guns).

```bash
# Install (Debian/Ubuntu):
sudo apt-get install -y shellcheck
# macOS:  brew install shellcheck

# Lint a script:
shellcheck health-check.sh
```

Example finding and fix:

```text
In health-check.sh line 12:
echo Checking $SERVICE_NAME
            ^-- SC2086: Double quote to prevent globbing and word splitting.
```

Run it in CI so unsafe scripts never merge. GitHub Actions example:

```yaml
# .github/workflows/shellcheck.yml
name: shellcheck
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run ShellCheck
        run: |
          sudo apt-get update && sudo apt-get install -y shellcheck
          shellcheck *.sh   # non-zero exit fails the job and blocks the merge
```

This mirrors the exit-code-as-pipeline-gate discipline from Section 9: ShellCheck returns non-zero on findings, which fails the job.

## 12A.8 Scheduling: cron and systemd Timers

A health report nobody runs is useless. Schedule it.

**cron** (simple, ubiquitous). Edit your user crontab with `crontab -e`:

```cron
# m h dom mon dow   command
# Run the fleet health report every weekday at 07:00, log output:
0 7 * * 1-5 /home/student/devops-course/week-08/class-01/fleet-report.sh >> /home/student/logs/fleet-report.log 2>&1
```

Use `crontab -l` to list and the site https://crontab.guru to decode expressions. Always redirect stdout **and** stderr (`>> file 2>&1`) or cron emails you on every run. Cron has a minimal environment — use **absolute paths** for everything.

**systemd timer** (preferred on modern Linux: logging via `journalctl`, dependency control, missed-run catch-up with `Persistent=true`). Two unit files:

```ini
# /etc/systemd/system/fleet-report.service
[Unit]
Description=Daily fleet health report

[Service]
Type=oneshot
ExecStart=/home/student/devops-course/week-08/class-01/fleet-report.sh
User=student
```

```ini
# /etc/systemd/system/fleet-report.timer
[Unit]
Description=Run fleet health report on weekday mornings

[Timer]
OnCalendar=Mon..Fri 07:00
Persistent=true

[Install]
WantedBy=timers.target
```

Enable and inspect:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now fleet-report.timer
systemctl list-timers fleet-report.timer    # show next/last run
journalctl -u fleet-report.service          # read the run's output/logs
```

**Cleanup (no lingering scheduled jobs after the lab):**

```bash
sudo systemctl disable --now fleet-report.timer
sudo rm -f /etc/systemd/system/fleet-report.{service,timer}
sudo systemctl daemon-reload
# For cron: run `crontab -e` and delete the line you added.
```

## 12A.9 Capstone Script: Scheduled Fleet Health Report with Log Cleanup

This ties every concept together: safety header, `trap`, functions, loops, arrays, `[[ ]]`, `awk`, a report file written to disk, retention-based log cleanup, and a script meant to be scheduled. It extends the Class 1 health check rather than replacing it.

```bash
#!/usr/bin/env bash
#
# fleet-report.sh — write a timestamped health report and prune old reports.
# Safe to re-run (idempotent) and safe to schedule via cron or a systemd timer.
#
set -euo pipefail

# --- Configuration (override via environment if desired) ---
REPORT_DIR="${REPORT_DIR:-$HOME/health-reports}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
DISK_THRESHOLD="${DISK_THRESHOLD:-80}"
SERVICES=("ssh" "cron")

TODAY="$(date +%Y-%m-%d)"
REPORT_FILE="$REPORT_DIR/health-report-$TODAY.txt"

log() { echo "$(date '+%H:%M:%S') [$1] ${*:2}" >&2; }

# --- Cleanup runs on any exit ---
TMP_FILE="$(mktemp)"
cleanup() { rm -f "$TMP_FILE"; }
trap cleanup EXIT

# mkdir -p is idempotent: no error if the directory already exists.
mkdir -p "$REPORT_DIR"

# --- Gather evidence into a temp file first, then publish atomically ---
{
    echo "===== Fleet Health Report ($TODAY) ====="
    echo "Host: $(hostname)   User: $(whoami)"
    echo

    # Disk: extract root-filesystem use% with awk (no fragile pipe chain).
    disk_usage="$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')"
    echo "Root disk usage: ${disk_usage}%"
    if (( disk_usage > DISK_THRESHOLD )); then
        echo "WARNING: root disk usage above ${DISK_THRESHOLD}%"
    fi
    echo

    echo "Service status:"
    for service in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$service"; then
            echo "  OK:   $service"
        else
            echo "  FAIL: $service"
        fi
    done
} > "$TMP_FILE"

# Atomic publish: a reader never sees a half-written report.
mv "$TMP_FILE" "$REPORT_FILE"
trap - EXIT            # report published; nothing left to clean up
log INFO "Report written to $REPORT_FILE"

# --- Retention: delete reports older than RETENTION_DAYS ---
# -mtime +N matches files modified more than N days ago.
deleted="$(find "$REPORT_DIR" -name 'health-report-*.txt' -mtime +"$RETENTION_DAYS" -print -delete | wc -l)"
log INFO "Pruned $deleted report(s) older than $RETENTION_DAYS days"
```

Validate before scheduling — always run a script by hand and lint it first:

```bash
shellcheck fleet-report.sh        # lint
chmod +x fleet-report.sh
./fleet-report.sh                 # run once, confirm the report file appears
cat ~/health-reports/health-report-*.txt
```

Then schedule it with cron or the systemd timer from 12A.8.

---

# 13. Student Lab Manual

## Lab Title

**Create Your First Bash Health Check Script**

## Lab Objective

Create a Bash script that checks basic Linux system health and validates whether a service is running.

## Estimated Time

25 to 35 minutes

## Student Prerequisites

Students should know how to:

- Open a terminal
- Navigate directories
- Create files
- Run Linux commands
- Use `chmod`
- Use a text editor such as VS Code or nano

## Architecture or Workflow Overview

```text
Student terminal
      |
      v
Bash script
      |
      v
Linux commands
      |
      v
System health output
      |
      v
Student validates results
```

## Step 1: Create a Lab Directory

Run:

```bash
mkdir -p ~/devops-course/week-08/class-01-lab
cd ~/devops-course/week-08/class-01-lab
```

Validate:

```bash
pwd
```

Expected output example:

```text
/home/student/devops-course/week-08/class-01-lab
```

## Step 2: Create Script File

Run:

```bash
nano student-health-check.sh
```

Paste:

```bash
#!/bin/bash

echo "===== Student System Health Check ====="

echo
echo "Date and time:"
date

echo
echo "Current user:"
whoami

echo
echo "Hostname:"
hostname

echo
echo "Disk usage:"
df -h

echo
echo "Memory usage:"
free -h

SERVICE_NAME="ssh"

echo
echo "Checking service: $SERVICE_NAME"

if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "$SERVICE_NAME is running"
else
    echo "$SERVICE_NAME is not running"
fi

echo
echo "Script completed"
```

Save and exit.

## Step 3: Check File Permissions

Run:

```bash
ls -l student-health-check.sh
```

Expected output:

```text
-rw-r--r-- 1 student student ... student-health-check.sh
```

Notice that the file is not executable yet.

## Step 4: Run Script With Bash

Run:

```bash
bash student-health-check.sh
```

Expected output should include:

```text
===== Student System Health Check =====
Date and time:
...
Current user:
...
Hostname:
...
Disk usage:
...
Memory usage:
...
Checking service: ssh
...
Script completed
```

## Step 5: Make Script Executable

Run:

```bash
chmod +x student-health-check.sh
```

Validate:

```bash
ls -l student-health-check.sh
```

Expected output should include executable permission:

```text
-rwxr-xr-x
```

## Step 6: Run Script Directly

Run:

```bash
./student-health-check.sh
```

Expected result:

The script should run successfully.

## Step 7: Add Command Substitution

Edit the script:

```bash
nano student-health-check.sh
```

Add these variables near the top:

```bash
CURRENT_DATE=$(date)
SERVER_NAME=$(hostname)
CURRENT_USER=$(whoami)
```

Then replace some commands with:

```bash
echo "Report date: $CURRENT_DATE"
echo "Server name: $SERVER_NAME"
echo "Current user: $CURRENT_USER"
```

Run again:

```bash
./student-health-check.sh
```

## Step 8: Validate Exit Codes

Run:

```bash
systemctl is-active --quiet ssh
echo $?
```

Then run:

```bash
systemctl is-active --quiet fake-service-name
echo $?
```

Write down the difference. Note that the failure code is **non-zero** — your scripts should branch on `0` vs non-zero, not on a specific number.

## Step 9: Harden the Script (Production-Safety)

Edit `student-health-check.sh` and turn it into a production-grade script using Section 12A patterns. Replace the shebang line and add the safety header plus a loop and a `trap`:

```bash
#!/usr/bin/env bash
set -euo pipefail

cleanup() { echo "Health check finished at $(date '+%H:%M:%S')"; }
trap cleanup EXIT

SERVICES=("ssh" "cron")

echo "===== Student System Health Check ====="
echo "Host: $(hostname)   User: $(whoami)   Date: $(date +%Y-%m-%d)"

# Disk usage via awk (replaces the fragile tail|awk|sed chain):
disk_usage="$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')"
echo "Root disk usage: ${disk_usage}%"
if (( disk_usage > 80 )); then
    echo "WARNING: root disk usage above 80%"
fi

for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "OK:   $service"
    else
        echo "FAIL: $service"
    fi
done
```

Lint and run it:

```bash
shellcheck student-health-check.sh   # fix any findings before continuing
./student-health-check.sh
```

## Step 10: Generate and Schedule a Report (Optional, time-permitting)

Create the capstone `fleet-report.sh` from Section 12A.9, lint it, run it once, and confirm the report file is created:

```bash
shellcheck fleet-report.sh
chmod +x fleet-report.sh
./fleet-report.sh
ls ~/health-reports/
```

Then schedule it with either cron (`crontab -e`) or the systemd timer shown in Section 12A.8. **Remember the cleanup steps in 12A.8** so no scheduled job is left running after the lab.

## Validation Checklist

Students should confirm:

- [ ] Script file exists
- [ ] Script starts with `#!/usr/bin/env bash` and `set -euo pipefail`
- [ ] Script runs with `bash script-name.sh`
- [ ] Script runs with `./script-name.sh` after `chmod +x`
- [ ] Script prints date, user, hostname, disk, and memory
- [ ] Script checks service status using a loop over an array
- [ ] Script uses at least one variable and a `trap` cleanup
- [ ] `shellcheck` reports no errors on the script
- [ ] Student can explain what exit code `0` means and why to branch on non-zero
- [ ] (Optional) `fleet-report.sh` wrote a report file and was scheduled, then cleaned up

## Troubleshooting Tips

| Problem | What to Check | Fix |
|---|---|---|
| `Permission denied` | Is the file executable? | Run `chmod +x student-health-check.sh` |
| `No such file or directory` | Are you in the right directory? | Run `pwd` and `ls` |
| `command not found` | Typo or missing command | Check spelling |
| Script prints blank variable | Variable was not assigned correctly | Check syntax like `NAME=value` |
| `systemctl` does not work | Environment may not use systemd | Use alternate process check |
| Service shows not running | Service name may differ | Try `ssh`, `sshd`, or another installed service |

## Cleanup Steps

Run only if instructed:

```bash
cd ~
rm -rf ~/devops-course/week-08/class-01-lab
```

No cloud resources are created in this lab unless the instructor provides an EC2 instance.

## Reflection Questions

1. Why is it useful to put health check commands into a script?
2. What is the difference between `bash script.sh` and `./script.sh`?
3. Why should scripts avoid hardcoded secrets?
4. How could this script help during a production incident?
5. What would you add to make this script more useful for an operations team?

## Optional Challenge Task

Add a disk warning.

Example:

```bash
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

if [ "$DISK_USAGE" -gt 80 ]; then
    echo "WARNING: Root disk usage is above 80%"
else
    echo "Disk usage is within normal range"
fi
```

---

# 14. Troubleshooting Activity

## Incident Title

**Health Check Script Fails During Morning Operations Review**

## Business Impact

The operations team depends on a daily health check before business hours. The script fails, so the team does not know whether key Linux servers are healthy before application teams begin deployments.

## Symptoms

The engineer runs:

```bash
./health-check.sh
```

Error:

```text
bash: ./health-check.sh: Permission denied
```

Another student runs:

```bash
health-check.sh
```

Error:

```text
health-check.sh: command not found
```

A third student runs:

```bash
./health-check.sh
```

Error:

```text
./health-check.sh: line 12: syntax error near unexpected token `then'
```

## Starting Evidence

File listing:

```bash
ls -l health-check.sh
```

Output:

```text
-rw-r--r-- 1 student student 432 Apr 26 08:00 health-check.sh
```

Current directory:

```bash
pwd
```

Output:

```text
/home/student/devops-course/week-08/class-01
```

Script snippet:

```bash
if systemctl is-active --quiet "$SERVICE_NAME"
    echo "$SERVICE_NAME is running"
else
    echo "$SERVICE_NAME is not running"
fi
```

## Student Investigation Steps

Students should:

1. Confirm current directory:

```bash
pwd
```

2. Confirm file exists:

```bash
ls -l
```

3. Check file permissions:

```bash
ls -l health-check.sh
```

4. Add executable permission:

```bash
chmod +x health-check.sh
```

5. Run with relative path:

```bash
./health-check.sh
```

6. If syntax error appears, inspect the condition.

7. Correct the missing `then`.

Corrected snippet:

```bash
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "$SERVICE_NAME is running"
else
    echo "$SERVICE_NAME is not running"
fi
```

## Expected Root Cause

There are two main issues:

1. The script does not have executable permission.
2. The `if` statement is missing `then`.

## Correct Resolution

Run:

```bash
chmod +x health-check.sh
```

Fix script syntax:

```bash
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "$SERVICE_NAME is running"
else
    echo "$SERVICE_NAME is not running"
fi
```

Run:

```bash
./health-check.sh
```

## Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Reinstalling Bash | Bash is not the issue |
| Restarting the server | The issue is script permission and syntax |
| Changing AWS security groups | This is a local script execution problem |
| Running as root immediately | Root is not needed to fix basic script permissions |
| Deleting and recreating the file without checking | Students lose useful evidence |

## Instructor Hints

Use hints gradually:

1. “What does `ls -l` show?”
2. “Do you see an `x` in the file permissions?”
3. “Can you run the script with `bash health-check.sh`?”
4. “What does Bash say the line number is?”
5. “What keyword usually appears after an `if` condition?”

## Preventive Action

Students should use a script checklist:

- Include shebang
- Use executable permission
- Run from correct directory
- Quote variables
- Test conditions manually first
- Validate syntax before sharing
- Keep scripts in Git
- Use peer review for scripts used by teams

---

# 15. Scenario-Based Discussion Questions

## Question 1

**When should a team use a Bash script instead of manually running commands?**

Expected themes:

- Repeated tasks
- Error-prone manual steps
- Health checks
- CI/CD commands
- Incident response steps

Follow-up:

“What risks appear when a manual task becomes a script?”

## Question 2

**What makes a Bash script unsafe in production?**

Expected themes:

- Deletes files without confirmation
- Hardcoded secrets
- No error handling
- Runs as root unnecessarily
- Poor logging
- No review process

Follow-up:

“What safety checks would you add before allowing a script to run on production servers?”

## Question 3

**Why are exit codes important in CI/CD pipelines?**

Expected themes:

- Pipelines need clear success or failure signals
- Failed tests should stop deployments
- Non-zero exit codes prevent unsafe continuation

Follow-up:

“What could happen if a failed command still returns success?”

## Question 4

**How could a Cloud Engineer use Bash with AWS?**

Expected themes:

- Run AWS CLI commands
- Inventory EC2 instances
- Validate S3 buckets
- Check tags
- Automate reports
- Run setup scripts on EC2

Follow-up:

“What IAM risks should be considered when scripting AWS CLI commands?”

## Question 5

**How could an SRE use a Bash health check during an incident?**

Expected themes:

- Check disk
- Check memory
- Check service status
- Collect logs
- Validate network connectivity
- Save evidence

Follow-up:

“What should an SRE avoid doing during an incident when using scripts?”

## Question 6

**Should every Bash script be converted to Python, Terraform, or Ansible later?**

Expected themes:

- Not always
- Depends on complexity
- Bash is good for simple command orchestration
- Python is better for complex logic
- Terraform is for infrastructure state
- Ansible is for configuration management

Follow-up:

“How would you decide when Bash is no longer the right tool?”

## Question 7

**Why should scripts be stored in Git?**

Expected themes:

- Version history
- Peer review
- Rollback
- Documentation
- Team visibility
- Auditability

Follow-up:

“What branch or review process would you use for scripts that affect production?”

---

# 16. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

What is the purpose of the shebang line `#!/bin/bash`?

A. It creates a new Bash user  
B. It tells Linux which interpreter should run the script  
C. It installs Bash  
D. It makes the file executable  

**Answer:** B  
**Explanation:** The shebang tells the operating system to run the script using Bash.

## Question 2: Multiple Choice

Which command makes a script executable?

A. `run script.sh`  
B. `execute script.sh`  
C. `chmod +x script.sh`  
D. `bash +x script.sh`  

**Answer:** C  
**Explanation:** `chmod +x` adds executable permission.

## Question 3: True or False

A script can always be run with `./script.sh` even if it does not have executable permission.

**Answer:** False  
**Explanation:** Running with `./script.sh` requires executable permission.

## Question 4: Short Answer

What does exit code `0` usually mean?

**Answer:** The command completed successfully.  
**Explanation:** In Linux and automation tools, `0` typically means success.

## Question 5: Multiple Choice

Which syntax captures command output into a variable?

A. `DATE=date`  
B. `DATE=$(date)`  
C. `DATE={date}`  
D. `DATE=>date`  

**Answer:** B  
**Explanation:** `$(command)` performs command substitution.

## Question 6: Troubleshooting

A student runs:

```bash
./health-check.sh
```

They receive:

```text
Permission denied
```

What should they check first?

**Answer:** File permissions using `ls -l health-check.sh`.  
**Explanation:** The script likely does not have executable permission. The fix is usually `chmod +x health-check.sh`.

## Question 7: AWS-Related

Where might a Cloud Engineer commonly run a Bash health check script in AWS?

A. On an EC2 Linux instance  
B. Inside IAM policy editor only  
C. Inside AWS Billing console only  
D. In Route 53 hosted zone records only  

**Answer:** A  
**Explanation:** EC2 Linux instances commonly support Bash scripts for operational checks.

## Question 8: True or False

Hardcoding AWS access keys directly inside a Bash script is a recommended production practice.

**Answer:** False  
**Explanation:** Secrets should not be hardcoded. Use IAM roles, environment variables, or secret management tools.

## Question 9: Short Answer

Why should variables be quoted in Bash scripts?

**Answer:** To prevent issues with spaces, empty values, and unexpected word splitting.  
**Explanation:** Quoting variables makes scripts safer and more predictable.

## Question 10: Troubleshooting

A script has this error:

```text
syntax error near unexpected token `else'
```

What is one likely cause?

**Answer:** The `if` block may be missing `then`, have a bad condition, or have incorrect structure.  
**Explanation:** Bash condition blocks require correct syntax: `if condition; then ... else ... fi`.

## Question 11: Multiple Choice

Which command checks whether the `ssh` service is active?

A. `ssh status`  
B. `service-check ssh`  
C. `systemctl is-active ssh`  
D. `check ssh now`  

**Answer:** C  
**Explanation:** `systemctl is-active ssh` checks whether the service is active on systemd-based Linux systems.

## Question 12: AWS-Related Short Answer

Why is Bash useful with AWS CLI?

**Answer:** Bash can automate AWS CLI commands for inventory, validation, reporting, and operational tasks.  
**Explanation:** Many cloud automation workflows combine Bash with AWS CLI commands.

---

# 17. Homework Assignment

## Assignment Title

**Build a Basic System Report Script**

## Scenario

Your operations team wants a simple script that junior engineers can run before the start of the business day. The script should print important system details and confirm whether a key service is running.

## Student Tasks

Create a Bash script named:

```bash
basic-system-report.sh
```

The script must display:

1. Date and time
2. Hostname
3. Current user
4. Disk usage
5. Memory usage
6. Top 5 memory-consuming processes
7. Status of the `ssh` service
8. A final message saying whether the system check completed

## Expected Deliverables

Students must submit:

1. `basic-system-report.sh`
2. Output from running the script
3. Short explanation of each section
4. Notes about any errors encountered and how they fixed them

## Submission Format

Submit as:

```text
week-08-class-01-homework/
  basic-system-report.sh
  output.txt
  explanation.md
```

## Estimated Completion Time

45 to 75 minutes

## Grading Criteria

| Criteria | Points |
|---|---:|
| Script has proper shebang | 10 |
| Script runs successfully | 20 |
| Uses variables correctly | 15 |
| Checks disk, memory, user, hostname, and date | 20 |
| Checks service status with condition | 15 |
| Output is readable | 10 |
| Explanation is clear | 10 |

## Optional Advanced Challenge

Add disk threshold logic.

If root disk usage is greater than 80%, print:

```text
WARNING: Root disk usage is above 80%
```

Otherwise print:

```text
Disk usage is within normal range
```

---

# 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Forgetting the shebang | Students do not understand script interpreter selection yet | Start every script with `#!/bin/bash` |
| Running `./script.sh` without execute permission | File exists but does not have `x` permission | Use `chmod +x script.sh` |
| Running from the wrong directory | Students lose track of path | Use `pwd` and `ls` before running |
| Missing spaces in conditions | Bash syntax is strict | Use `[ "$VAR" = "value" ]` with spaces |
| Forgetting `then` | Beginner syntax issue | Use template snippets |
| Forgetting `fi` | Students do not know how Bash ends `if` blocks | Remember `fi` closes `if` |
| Not quoting variables | Students copy simple examples without understanding edge cases | Use `"$VARIABLE"` by default |
| Hardcoding sensitive values | Students may not understand secrets risk | Never place passwords, tokens, or AWS keys in scripts |
| Assuming service names are universal | Service names differ by Linux distro | Validate with `systemctl list-units` |
| Ignoring exit codes | Students focus only on visible output | Teach `echo $?` after commands |

---

# 19. Real-World Enterprise Scenario

## Scenario

A logistics company runs several internal applications on Linux servers in AWS EC2. Every morning before application teams start deployments, the operations team checks whether servers are healthy.

Currently, engineers manually run:

```bash
df -h
free -h
systemctl status ssh
ps aux
```

This creates inconsistent results because different engineers run different commands and document findings differently.

## Constraints

| Constraint | Example |
|---|---|
| Access control | Junior engineers have limited Linux access |
| Security | Scripts must not include passwords or AWS access keys |
| Reliability | The script must not restart or change services yet |
| Cost | No new AWS paid services should be created for this beginner check |
| Production impact | Script must be read-only and safe |
| Team workflow | Script should be stored in Git and reviewed |

## How the Class Topic Applies

Students learn to convert repeated manual commands into a consistent script.

## What Each Role Would Do

| Role | Responsibility |
|---|---|
| DevOps Engineer | Put the script in Git and later integrate it into CI/CD or deployment checks |
| Cloud Engineer | Run or adapt the script for EC2 Linux instances and ensure access uses IAM-approved methods |
| SRE | Use the script during incident response or daily reliability checks, then improve it with logging and alerting |

---

# 20. Instructor Tips

## Teaching Tips

- Start with commands students already know.
- Show manual commands before putting them into a script.
- Explain each line as if students have never scripted before.
- Use mistakes intentionally, especially permission errors.
- Keep syntax examples small before building the full script.

## Pacing Tips

- Teach the fundamentals (Sections 9-12) first; only reach for Section 12A once students can write and run a basic script.
- Keep the safety header (`set -euo pipefail`) front and center — introduce it the moment students write their second script.
- If time is short, prioritize `set -euo pipefail` + `trap`, functions, and one loop; `getopts` and the systemd timer can be demoed and left as homework.
- Give students time to type and run commands themselves; run ShellCheck live so they see findings.

## Lab Support Tips

When students struggle, ask:

1. “What directory are you in?”
2. “Does the file exist?”
3. “What do permissions show?”
4. “Can you run it with `bash script.sh`?”
5. “What line number does the error mention?”

## Helping Struggling Students

Give them this minimal working script:

```bash
#!/bin/bash

echo "Hello"
date
hostname
```

Then have them add one feature at a time.

## Challenging Advanced Students

Ask them to:

- Add disk threshold checks
- Add a report file
- Add input validation
- Add service name as an argument
- Add comments and better formatting
- Add safe error handling

Example argument challenge:

```bash
SERVICE_NAME="$1"

if [ -z "$SERVICE_NAME" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi
```

---

# 21. Student Outcome Checklist

## Students Should Be Able to Explain

- [ ] What Bash is
- [ ] Why Bash is useful in DevOps, Cloud Engineering, and SRE work
- [ ] What a shebang does
- [ ] What variables are used for
- [ ] What command substitution does
- [ ] How conditions work
- [ ] What exit codes mean
- [ ] Why scripts need safe permissions
- [ ] Why hardcoded secrets are dangerous

## Students Should Be Able to Build or Configure

- [ ] Create a `.sh` script file
- [ ] Add `#!/bin/bash`
- [ ] Print readable output
- [ ] Use variables
- [ ] Use `$(command)`
- [ ] Use `if`, `else`, and `fi`
- [ ] Check service status
- [ ] Make a script executable with `chmod +x`
- [ ] Run a script with `bash script.sh`
- [ ] Run a script with `./script.sh`

## Students Should Be Able to Troubleshoot

- [ ] `Permission denied`
- [ ] `No such file or directory`
- [ ] `command not found`
- [ ] Empty variables
- [ ] Bad service name
- [ ] Missing `then`
- [ ] Missing `fi`
- [ ] Incorrect working directory
- [ ] Exit code-based failures

---

# 22. Class Completion Checklist

## Instructor Checklist Before Ending Class

- [ ] Students understand why Bash is used in DevOps and operations.
- [ ] Students created at least one Bash script.
- [ ] Students ran a script using `bash script.sh`.
- [ ] Students made a script executable using `chmod +x`.
- [ ] Students ran a script using `./script.sh`.
- [ ] Students used at least one variable.
- [ ] Students used one conditional check.
- [ ] Students saw how exit codes work.
- [ ] Students completed or started the health check lab.
- [ ] Students added a `set -euo pipefail` safety header and a `trap` cleanup.
- [ ] Students ran ShellCheck on at least one script.
- [ ] Students saw cron and/or a systemd timer schedule a script.
- [ ] Homework expectations are clear.
- [ ] Students understand that Class 2 moves to Python for structured-data and API automation.

## Student Checklist Before Leaving Class

- [ ] I can explain what a Bash script is.
- [ ] I created `student-health-check.sh`.
- [ ] I can run my script.
- [ ] I know how to fix `Permission denied`.
- [ ] I used a variable in my script.
- [ ] I used an `if` condition in my script.
- [ ] I checked an exit code using `echo $?`.
- [ ] I understand the homework assignment.
- [ ] I saved my script for later use.

## Items to Verify Before Moving to Class 2

Students should bring to Class 2:

- Completed or mostly completed `basic-system-report.sh`
- Understanding of variables
- Understanding of `if/else`
- Ability to run scripts
- Ability to fix script permission issues
- Basic comfort reading terminal errors

Class 2 switches from Bash to Python, the better tool once automation needs structured data and APIs. It will build on the scripting mindset from this class and add:

- Python virtual environments
- Reading and validating JSON configuration
- Functions and structured error handling
- The load → validate → process → output pattern
- A preview of AWS automation with `boto3`

---

# Class Artifacts & Validation

The runnable, on-disk artifacts for this class live in the [`labs/linux-shell-automation/`](../../labs/linux-shell-automation/) module — the same shell-operations toolkit excerpted inline above (`set -euo pipefail`, `trap`, functions, loops, `awk`, ShellCheck, scheduling). Every gate below was **run in this environment** (bash 5.1, GNU coreutils, ShellCheck 0.10.0); `./validate.sh` reports `22 passed, 0 failed`, exit 0.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/linux-shell-automation/solution/lib/common.sh | shell (`.sh`) | Sourced library: `log()`, `die()`, `require_cmd()` (stderr diagnostics) | `bash -n solution/lib/common.sh` + `shellcheck -x` | PASS (lint-clean) |
| 2 | labs/linux-shell-automation/solution/disk-check.sh | shell (`.sh`) | Parses `df -P`, breaches strictly over `--threshold`, exits 1 on breach (cron/monitoring gate) | `bash -n` + `shellcheck -x` + `tests/run-tests.sh` | PASS |
| 3 | labs/linux-shell-automation/solution/log-rotate.sh | shell (`.sh`) | gzip-rotates files older than N days, `--dry-run`, idempotent (excludes `*.gz`) | `bash -n` + `shellcheck -x` + `tests/run-tests.sh` | PASS |
| 4 | labs/linux-shell-automation/solution/backup.sh | shell (`.sh`) | Timestamped `tar.gz` with `--keep N` retention pruning | `bash -n` + `shellcheck -x` + `tests/run-tests.sh` | PASS |
| 5 | labs/linux-shell-automation/solution/user-audit.sh | shell (`.sh`) | Lists human accounts (UID ≥ 1000) and flags sudo/wheel/admin membership | `bash -n` + `shellcheck -x` + `tests/run-tests.sh` | PASS |
| 6 | labs/linux-shell-automation/tests/run-tests.sh | shell (`.sh`) | Functional suite: fabricates a sandbox, asserts script behaviour | `bash tests/run-tests.sh` | PASS — `25 passed, 0 failed`, exit 0 |
| 7 | labs/linux-shell-automation/broken/disk-check-broken.sh | shell (`.sh`) | Week-2 troubleshooting fixture: unquoted `$mount` (SC2086) + `>=` off-by-one | `shellcheck -x broken/disk-check-broken.sh` (must still report SC2086) | PASS — fixture intentionally trips SC2086 (gate asserts it) |
| 8 | labs/linux-shell-automation/validate.sh | shell (`.sh`) | Module gate runner: `bash -n` on every script + functional suite + ShellCheck | `./validate.sh` | PASS — `22 passed, 0 failed`, exit 0 |

> Run all gates: `cd labs/linux-shell-automation && ./validate.sh`. The ShellCheck gate is `command -v`-guarded, so it runs where the linter exists and `[SKIP]`s (without failing) where it does not. The `broken/` fixture is the graded troubleshooting deliverable; the linter still catches Bug 1 (SC2086) while Bug 2 (`>=` vs `>`) is behavioural and is caught by the functional suite.

---

# Definition of Done

Ticked honestly for **this class** (Bash scripting, backed by `labs/linux-shell-automation/`):

- [x] Every technology taught ships at least one **runnable file on disk** — five `.sh` tools + a sourced library in `solution/`, not just fences.
- [x] Each artifact passes (or documents) its **validation gate** from §3 — `bash -n` + `shellcheck -x` (the §3 "Linux / shell automation" row); output captured above and re-run live (`22 passed, 0 failed`).
- [x] Lab has **starter** (intentionally incomplete `TODO(student)` gaps) and **solution** (reference) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, and cost notes (`$0`, all local).
- [x] **Cleanup/teardown** is provided and idempotent — `tests/run-tests.sh` uses a `trap`-cleaned `mktemp -d`; manual scratch dirs documented in the README Cleanup section. (No cloud resources created.)
- [x] **Instructor answer key** exists — `solution/` plus the README "Instructor answer key" section, and an answer key for the in-class quiz (Section 16) and homework (Section 17).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `broken/disk-check-broken.sh` with two genuine bugs (SC2086 word-split + `>=` off-by-one), not a hypothetical.
- [x] **Expected outputs** are shown for the demo, lab, and every gate (captured `validate.sh` / `run-tests.sh` output).
- [x] **Cost & security warnings** present — `$0`/local-only cost note; security notes cover no-secrets, least-privilege `user-audit.sh`, destructive-op scoping, and quoting/injection safety.
- [x] **Cross-references** to the module repo and to prior/next weeks are correct (Week 2 troubleshooting fixture origin; Class 2 → Python; Week 9 → CI/CD exit-code gates).
- [x] The **artifact manifest** (§4.2) is present above and every path resolves (verified with `ls`).
- [ ] **Mastered / live operation** — these scripts are *built and validated*, not yet operated as a live scheduled job with captured runtime evidence, and they are not reused/extended in the capstone. No `LIVE-*` evidence file exists for this lab (the cron/systemd scheduling in §12A.8 is demonstrated, not captured as a live run). This caps the class below the 8–10 band per §6.
