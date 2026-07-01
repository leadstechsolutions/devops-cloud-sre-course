# Week 8: Scripting and Automation
> **▶ Runnable lab for this class:** [`labs/linux-shell-automation/`](../../labs/linux-shell-automation/) · [`labs/python-automation/`](../../labs/python-automation/) · [`labs/ansible-config-mgmt/`](../../labs/ansible-config-mgmt/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 2 Package: Python for DevOps Automation

**Week:** 8
**Class:** 2
**Track:** Unified DevOps · Cloud · SRE Track

---

# 1. Class Overview

## Class Title

**Python for DevOps Automation: Basics for DevOps, Cloud, and SRE**

## Class Purpose

The purpose of this class is to help students understand Python as a practical automation tool for DevOps, Cloud Engineering, and SRE work.

This class is not focused on general software development. It focuses on how Python helps infrastructure and operations teams:

- Read configuration files
- Validate inputs
- Parse JSON
- Generate simple reports
- Handle errors safely
- Prepare for cloud API automation using AWS `boto3` (previewed at the end of this class)

## How This Class Connects to the Overall Course

This class is the second half of Week 8's scripting toolkit. Class 1 covered Bash for local system automation; this class covers Python for structured-data, JSON, and API-driven automation. It builds directly on earlier course topics:

- **Linux (Week 2):** Students use the terminal to run scripts.
- **Git (Week 3):** Students organize scripts in a repository.
- **AWS foundations (Week 4):** Students prepare for AWS inventory automation.
- **Bash scripting (this week, Class 1):** Students compare Bash and Python automation use cases.
- **CI/CD (Week 9):** Students begin writing scripts that can later run inside pipelines.
- **Cloud operations:** Students practice safe validation and error handling.

This class also **previews** AWS automation with `boto3` (the AWS SDK for Python) in Section 12A, so students see where the load → validate → process → output pattern goes next: from local JSON files to live, read-only AWS API calls. Deeper `boto3` work recurs later in the course alongside cloud operations and cost optimization.

## What Students Will Build, Analyze, or Practice

Students will:

- Create a Python virtual environment
- Write simple Python scripts
- Read a JSON file
- Validate required configuration fields
- Use functions to organize code
- Add beginner-friendly error handling
- Troubleshoot common Python and JSON failures

---

# 2. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** why Python is commonly used for DevOps, Cloud Engineering, and SRE automation.
2. **Configure** a Python virtual environment for a small automation project.
3. **Write** Python scripts using variables, lists, dictionaries, loops, and functions.
4. **Read** and **parse** JSON configuration files.
5. **Validate** required fields in a configuration file.
6. **Troubleshoot** missing files, invalid JSON, missing keys, and basic runtime errors.
7. **Document** how a Python script supports real-world infrastructure automation.
8. **Compare** Python automation use cases with Bash automation use cases.

---

# 3. Prerequisites Students Should Already Know

## Required Prior Concepts

Students should already understand:

- Basic terminal navigation
- Basic Linux file and directory commands
- How to create and edit files in VS Code
- Basic Git workflow
- Basic cloud role concepts
- Basic automation concepts from Bash scripting
- Basic JSON concept as structured data

## Required Tools Already Installed

Students should have:

- Python 3 installed
- `pip` installed
- VS Code installed
- Terminal or PowerShell access
- Git installed
- A working course folder or Git repository

## Required Accounts or Access

For this class, no AWS account access is required for live API calls.

AWS is discussed conceptually, with a **read-only `boto3` preview** in Section 12A. Hands-on, write-capable AWS automation is developed later in the course alongside cloud operations and cost optimization.

## Files, Repos, or Sample Code Needed

Instructor should provide or have students create:

```text
week-08-python-devops/
  class-02/
    servers.json
    inventory_report.py
    app_config.json
    validate_config.py
```

---

# 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Python | A programming language commonly used for automation, scripting, APIs, and tooling | DevOps teams use Python to automate cloud inventory, reporting, validation, and operational tasks |
| Script | A file containing commands or logic that runs a task automatically | A script may check disk usage, validate config files, or list cloud resources |
| Variable | A named place to store a value | Example: storing an environment name like `dev` or `prod` |
| List | A collection of values in order | Example: a list of server names or AWS regions |
| Dictionary | A collection of key-value pairs | Example: server details such as name, status, owner, and environment |
| Function | A reusable block of code that performs a task | Example: a function that loads a JSON file or prints a report |
| JSON | A structured data format commonly used in APIs and configuration files | AWS, Azure, GCP, Kubernetes, Terraform, and CI/CD tools often return or consume JSON |
| Error handling | Code that catches problems and responds safely | Production automation should give clear errors instead of failing silently |
| Virtual environment | An isolated Python environment for project dependencies | Prevents one project’s packages from interfering with another project |
| `pip` | Python package installer | Used later to install `boto3` for AWS automation |
| Automation | Using scripts or tools to perform repeatable tasks | Reduces manual work and improves consistency |
| Validation | Checking whether input data meets required rules | Prevents bad configurations from reaching production workflows |

---

# 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| Python 3 | Main scripting language for automation |
| pip | Installs Python packages |
| venv | Creates isolated Python environments |
| VS Code | Code editor for writing and reviewing scripts |
| Terminal or PowerShell | Runs Python commands and scripts |
| JSON files | Represents configuration and inventory data |
| Git | Tracks script changes and supports team collaboration |
| AWS CLI, conceptual in the core lab | Used to validate credentials before the `boto3` preview in Section 12A |

---

# 6. AWS Services Used

The core lab does not make live AWS API calls, but it introduces AWS resource inventory concepts that the Section 12A `boto3` preview begins to automate (read-only).

| AWS Service | How It Connects to This Class |
|---|---|
| EC2 | Used as an example of resources that can be inventoried with Python |
| S3 | Used as an example of resources that can be listed and reported |
| IAM | Used to explain why automation must respect permissions |
| STS | Previewed as the service used later to confirm AWS identity |
| AWS CLI | Used later to validate credentials before Python uses AWS APIs |

## Instructor Note

Explain that Python automation should not start with dangerous write actions. Students should first learn safe read-only reporting and validation patterns.

---

# 7. Azure and GCP Comparison Notes

Keep this short during class.

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Python SDK | boto3 | Azure SDK for Python | Google Cloud Client Libraries |
| Identity check | STS caller identity | Azure identity libraries | Google auth libraries |
| Resource inventory | EC2, S3, IAM APIs | Azure Resource Graph, SDK clients | Cloud Asset Inventory, SDK clients |
| Config format | JSON commonly used | JSON commonly used | JSON commonly used |

## Instructor Talking Point

The Python basics students learn today apply across AWS, Azure, and GCP. The SDK changes, but the scripting pattern remains similar:

```text
Load config -> Authenticate -> Call API -> Parse response -> Produce report
```

---

# 8. Time-Boxed Instructor Agenda

| Time | Section | Activity |
|---:|---|---|
| 0:00 to 0:10 | Opening | Explain why Python matters for DevOps, Cloud, and SRE |
| 0:10 to 0:30 | Setup | Validate Python, pip, VS Code, terminal, and project folder |
| 0:30 to 0:55 | Python basics | Variables, strings, numbers, lists, dictionaries |
| 0:55 to 1:15 | Logic and functions | Conditions, loops, functions, reusable code |
| 1:15 to 1:25 | Break | Short break |
| 1:25 to 1:50 | Files and JSON | Read files, parse JSON, inspect structured data |
| 1:50 to 2:15 | Error handling | `try`, `except`, missing files, invalid JSON, missing keys |
| 2:15 to 2:35 | Instructor demo | Build a basic JSON-based inventory report |
| 2:35 to 2:45 | boto3 preview | Same pattern against live, read-only AWS (Section 12A) |
| 2:45 to 2:55 | Student lab start | Students build JSON config validator |
| 2:55 to 3:00 | Wrap-up | Review outcomes and assign homework |

---

# 9. Instructor Lesson Plan

## Step 1: Open the Class

Start with this framing:

“Last week, we used Bash for local system automation. Today we move into Python, which is better when the automation needs structured data, APIs, cloud SDKs, JSON, or larger logic.”

Explain that Python is often used by:

- DevOps Engineers for CI/CD helper scripts
- Cloud Engineers for inventory and reporting
- SREs for operational checks and toil reduction
- Platform teams for internal tools and validations

Pause and ask:

“What tasks have you done manually that could be scripted?”

Expected answers:

- Checking server status
- Listing cloud resources
- Validating files
- Restarting services
- Reading logs
- Generating reports

---

## Step 2: Validate Student Setup

Have students run:

```bash
python --version
```

or:

```bash
python3 --version
```

Then:

```bash
pip --version
```

Create project folder:

```bash
mkdir -p week-08-python-devops/class-02
cd week-08-python-devops/class-02
```

Create a virtual environment:

```bash
python -m venv .venv
```

Activate it.

Linux/macOS:

```bash
source .venv/bin/activate
```

Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

Expected prompt may show:

```text
(.venv)
```

Teaching tip:

Do not spend too long troubleshooting every machine during lecture. If some students are blocked, pair them or let them use an online Python environment temporarily.

---

## Step 3: Teach Core Python Data Types

Explain with infrastructure examples:

```python
server_name = "web-01"
environment = "dev"
instance_count = 3
is_production = False
```

Lists:

```python
servers = ["web-01", "api-01", "db-01"]
```

Dictionaries:

```python
server = {
    "name": "web-01",
    "environment": "dev",
    "status": "running"
}
```

Explain:

- Lists are good for many items.
- Dictionaries are good for describing one item.
- Cloud API responses often use both.

Pause and ask:

“If AWS returns 100 EC2 instances, would that be closer to a list or a dictionary?”

Expected answer:

A list of dictionaries.

---

## Step 4: Teach Conditions, Loops, and Functions

Condition example:

```python
environment = "prod"

if environment == "prod":
    print("Production environment")
else:
    print("Non-production environment")
```

Loop example:

```python
servers = ["web-01", "api-01", "db-01"]

for server in servers:
    print(server)
```

Function example:

```python
def print_server_name(name):
    print(f"Server name: {name}")

print_server_name("web-01")
```

Explain:

Functions help organize scripts so the code is easier to read, test, and reuse.

---

## Step 5: Teach JSON and Files

Explain that JSON is common in:

- AWS API responses
- Terraform plan output
- Kubernetes manifests, when converted from YAML
- CI/CD pipeline metadata
- Application config files
- Monitoring and logging tools

Create example `servers.json`:

```json
[
  {
    "name": "web-01",
    "environment": "dev",
    "status": "running",
    "owner": "platform"
  },
  {
    "name": "api-01",
    "environment": "test",
    "status": "stopped",
    "owner": "devops"
  }
]
```

Read JSON:

```python
import json

with open("servers.json", "r") as file:
    servers = json.load(file)

print(servers)
```

Explain:

`json.load()` converts JSON into Python lists and dictionaries.

---

## Step 6: Teach Error Handling

Start with the problem:

“Automation usually fails at the worst time, during deployments, incidents, or scheduled jobs. Good scripts need clear error messages.”

Basic example:

```python
try:
    with open("servers.json", "r") as file:
        servers = json.load(file)
except FileNotFoundError:
    print("Error: servers.json was not found.")
except json.JSONDecodeError:
    print("Error: servers.json contains invalid JSON.")
```

Explain:

- `try` wraps risky code.
- `except` handles known failure types.
- Clear errors save troubleshooting time.

---

## Step 7: Transition to Demo

Say:

“Now we will combine everything: JSON, functions, loops, dictionaries, and error handling into a simple inventory report. This is the same pattern we will later use with AWS APIs.”

---

# 10. Instructor Lecture Notes

## Why Python Matters in DevOps

Python is one of the most common languages for infrastructure automation because it works well with APIs, structured data, files, and cloud SDKs.

Bash is useful for quick shell automation. Python is better when logic becomes more complex.

Example talking point:

“Bash is great for chaining commands. Python is better when you need structured logic, JSON parsing, reusable functions, or API calls.”

## Python in Real Jobs

A DevOps Engineer might use Python to:

- Validate pipeline inputs
- Generate deployment reports
- Check application versions
- Call GitLab or GitHub APIs
- Update release metadata

A Cloud Engineer might use Python to:

- List AWS resources
- Check missing tags
- Generate inventory reports
- Validate cloud configuration files
- Identify unused resources

An SRE might use Python to:

- Query monitoring APIs
- Create incident reports
- Automate health checks
- Reduce repetitive operational work
- Collect diagnostic data during incidents

## Common Misconceptions

### Misconception 1: “Python is only for developers.”

Correction:

Python is heavily used by infrastructure, cloud, DevOps, SRE, security, and operations teams.

### Misconception 2: “If the script works once, it is done.”

Correction:

A useful automation script should handle bad input, missing files, credential issues, and unexpected responses.

### Misconception 3: “Automation is always safe.”

Correction:

Automation can make mistakes faster than humans. That is why validation, logging, and error handling matter.

### Misconception 4: “Print statements are enough for production.”

Correction:

For beginner scripts, print statements are fine. In production, teams use structured logging, exit codes, monitoring, and alerting.

## Practical Enterprise Context

In an enterprise cloud team, Python scripts often become part of larger workflows:

```text
Developer submits request
  -> CI/CD pipeline runs validation script
  -> Script checks config, tags, naming, environment
  -> Pipeline allows or blocks deployment
  -> Results are stored as logs or artifacts
```

A small Python validator can prevent:

- Wrong region deployments
- Missing owners or tags
- Invalid environment names
- Unapproved cloud providers
- Bad JSON configuration
- Production deployment mistakes

---

# 11. Whiteboard Explanation

## Simple Whiteboard Diagram

```text
                 Input
       config.json / servers.json
                  |
                  v
        +-------------------+
        |   Python Script   |
        +-------------------+
          |       |       |
          |       |       |
          v       v       v
      Validate   Parse   Process
      Fields     JSON    Logic
          \       |       /
           \      |      /
            v     v     v
        +-------------------+
        |   Clean Output    |
        +-------------------+
                  |
                  v
        Report / Error Message
```

## Step-by-Step Flow

1. Script starts.
2. Script opens a JSON file.
3. Python converts JSON into Python data.
4. Script checks whether required fields exist.
5. Script processes the data.
6. Script prints a report or error message.
7. User fixes issues based on clear feedback.

## What Each Component Means

| Component | Meaning |
|---|---|
| Input | File, config, API response, or user argument |
| Python script | Automation logic |
| Validate | Check required data before continuing |
| Parse | Convert raw JSON into usable Python objects |
| Process | Loop, filter, check, or transform data |
| Output | Report, message, file, alert, or pipeline result |

## Enterprise Version of the Diagram

```text
Application Team
      |
      | submits config file
      v
Git Repository
      |
      | merge request triggers pipeline
      v
CI/CD Pipeline
      |
      | runs Python validation script
      v
Validation Result
      |
      +--> Pass: allow deployment
      |
      +--> Fail: block deployment and show error
```

## Enterprise Teaching Point

A Python script does not need to be large to be valuable. A 50-line validation script can prevent a production outage if it catches bad configuration before deployment.

---

# 12. Instructor Demo Script

## Demo Title

**Build a Basic Python Inventory Parser**

## Demo Objective

Show students how to build a Python script that:

- Reads a JSON file
- Parses structured data
- Uses functions
- Loops through records
- Handles common errors
- Prints a clean inventory report

## Required Setup

Instructor should have:

- Python 3 installed
- VS Code installed
- Terminal ready
- Project folder created

Create folder:

```bash
mkdir -p week-08-python-devops/class-02
cd week-08-python-devops/class-02
```

Create virtual environment:

```bash
python -m venv .venv
```

Activate virtual environment.

Linux/macOS:

```bash
source .venv/bin/activate
```

Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

Validate:

```bash
python --version
```

Expected output:

```text
Python 3.x.x
```

---

## Step 1: Create Sample JSON File

Create `servers.json`:

```json
[
  {
    "name": "web-01",
    "environment": "dev",
    "status": "running",
    "owner": "platform"
  },
  {
    "name": "api-01",
    "environment": "test",
    "status": "stopped",
    "owner": "devops"
  },
  {
    "name": "db-01",
    "environment": "prod",
    "status": "running",
    "owner": "database"
  }
]
```

Explain:

“This file represents server inventory data. In the `boto3` preview (Section 12A), similar data comes from a live AWS API call instead of a local file.”

---

## Step 2: Create Basic Script

Create `inventory_report.py`:

```python
import json

with open("servers.json", "r") as file:
    servers = json.load(file)

print(servers)
```

Run:

```bash
python inventory_report.py
```

Expected output:

```text
[{'name': 'web-01', 'environment': 'dev', 'status': 'running', 'owner': 'platform'}, ...]
```

Explain:

“Python converted JSON into Python data structures. This output is not pretty yet, but now the script can process it.”

---

## Step 3: Add Functions

Replace script with:

```python
import json

def load_servers(file_path):
    with open(file_path, "r") as file:
        return json.load(file)

def print_report(servers):
    print("Server Inventory Report")
    print("=======================")

    for server in servers:
        print(f"Name: {server['name']}")
        print(f"Environment: {server['environment']}")
        print(f"Status: {server['status']}")
        print(f"Owner: {server['owner']}")
        print("-----------------------")

servers = load_servers("servers.json")
print_report(servers)
```

Run:

```bash
python inventory_report.py
```

Expected output:

```text
Server Inventory Report
=======================
Name: web-01
Environment: dev
Status: running
Owner: platform
-----------------------
Name: api-01
Environment: test
Status: stopped
Owner: devops
-----------------------
Name: db-01
Environment: prod
Status: running
Owner: database
-----------------------
```

Explain:

“The script is now easier to read. One function loads data. Another function prints the report.”

---

## Step 4: Add Error Handling

Replace script with:

```python
import json

def load_servers(file_path):
    with open(file_path, "r") as file:
        return json.load(file)

def print_report(servers):
    print("Server Inventory Report")
    print("=======================")

    for server in servers:
        print(f"Name: {server['name']}")
        print(f"Environment: {server['environment']}")
        print(f"Status: {server['status']}")
        print(f"Owner: {server['owner']}")
        print("-----------------------")

try:
    servers = load_servers("servers.json")
    print_report(servers)
except FileNotFoundError:
    print("Error: servers.json file was not found.")
except json.JSONDecodeError:
    print("Error: servers.json contains invalid JSON.")
except KeyError as error:
    print(f"Error: Missing expected field: {error}")
```

Run:

```bash
python inventory_report.py
```

Expected output should remain successful.

---

## Step 5: Intentionally Break the Demo

Rename the file:

```bash
mv servers.json servers_backup.json
```

Run:

```bash
python inventory_report.py
```

Expected output:

```text
Error: servers.json file was not found.
```

Recover:

```bash
mv servers_backup.json servers.json
```

Now break JSON by removing a comma or quote.

Run:

```bash
python inventory_report.py
```

Expected output:

```text
Error: servers.json contains invalid JSON.
```

Recover by fixing the JSON.

Now remove the `owner` field from one server.

Expected output:

```text
Error: Missing expected field: 'owner'
```

## What to Explain During Each Step

| Step | Explanation |
|---|---|
| Create JSON | Config and inventory data are often structured |
| Read JSON | Python can convert JSON into usable objects |
| Add functions | Functions make automation maintainable |
| Add error handling | Good scripts fail clearly |
| Break the script | Troubleshooting is part of real automation work |
| Recover | Clear errors speed up recovery |

## Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| `python` not found | Python not installed or PATH issue | Try `python3 --version` |
| File not found | Wrong directory | Run `pwd` or `dir`, verify file location |
| JSON decode error | Invalid JSON syntax | Validate commas, quotes, brackets |
| KeyError | Missing expected field | Fix JSON or use safer `.get()` logic |
| Virtual environment not active | Forgot activation | Reactivate `.venv` |

## Cleanup Steps

No cloud resources are created.

Optional local cleanup:

```bash
cd ..
rm -rf class-02
```

On Windows PowerShell:

```powershell
Remove-Item -Recurse -Force .\class-02
```

---

# 12A. Preview: From Local JSON to Live AWS with `boto3` (Read-Only)

> **This is a preview, not a graded lab.** Its goal is to show students that the exact `load → validate → process → output` pattern they just practiced on a local JSON file is the *same* pattern used against live cloud APIs — the data source simply changes from a file to an AWS SDK call. Deep, write-capable AWS automation is developed later in the course (cloud operations and cost optimization). Keep this to a 10-minute instructor walkthrough.

## Why preview it now

The inventory report in Section 12 read `servers.json` from disk. In a real cloud team, that inventory comes from AWS itself. `boto3` is the AWS SDK for Python — the same kind of client you would reach for to list EC2 instances or S3 buckets. The script shape barely changes:

```text
Local file version:   open file  -> json.load -> loop/validate -> print report
boto3 version:        ec2 client -> describe_* -> loop/validate -> print report
```

## Setup (instructor demo only)

`boto3` is a third-party package, so install it into the virtual environment:

```bash
pip install boto3
```

Credentials are **not** hardcoded. `boto3` automatically uses the same credential chain as the AWS CLI — environment variables, an IAM Identity Center (SSO) profile, or an instance role on EC2. The modern, keyless approach is:

```bash
aws configure sso        # IAM Identity Center / SSO profile (no long-lived keys)
export AWS_PROFILE=my-sso-profile
```

> **Security and cost warning:** Use a sandbox or learning account, never production. Use read-only permissions only (e.g., the AWS-managed `ReadOnlyAccess` policy or a scoped `ec2:Describe*` policy). The calls below are read-only `Describe`/`List` operations and create **no** billable resources — but credentials must still be handled carefully and never committed to Git.

## Verify identity first (the safe habit)

Before any automation touches an account, confirm *which* account and identity you are using. This mirrors `aws sts get-caller-identity` on the CLI:

```python
import boto3

def whoami():
    sts = boto3.client("sts")
    identity = sts.get_caller_identity()
    print(f"Account: {identity['Account']}")
    print(f"ARN:     {identity['Arn']}")

whoami()
```

## Read-only EC2 inventory (same shape as the file version)

```python
import boto3
from botocore.exceptions import ClientError, NoCredentialsError

def list_running_instances(region="us-east-1"):
    ec2 = boto3.client("ec2", region_name=region)
    try:
        # Read-only call: describes instances, changes nothing.
        response = ec2.describe_instances(
            Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
        )
    except NoCredentialsError:
        print("Error: no AWS credentials found. Run 'aws configure sso' first.")
        return
    except ClientError as error:
        # Mirrors the try/except discipline from Section 12 — fail clearly.
        print(f"AWS API error: {error.response['Error']['Code']}")
        return

    print("Running EC2 instances")
    print("=====================")
    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            # .get() avoids KeyError when a field is absent — same pattern as the lab.
            name = next(
                (t["Value"] for t in instance.get("Tags", []) if t["Key"] == "Name"),
                "(no name tag)",
            )
            print(f"{instance['InstanceId']}  {instance['InstanceType']}  {name}")

if __name__ == "__main__":
    list_running_instances()
```

Point out to students:
- The error-handling reflex is identical to the file version — only the exception types changed (`ClientError`, `NoCredentialsError` instead of `FileNotFoundError`, `JSONDecodeError`).
- `.get("Tags", [])` is the same defensive pattern as `config.get()` in the lab.
- This script is safe to re-run and makes no changes — the read-only-first mindset from the Instructor Note in Section 6.

## Cleanup

No AWS resources are created by these read-only calls, so there is nothing to delete. If credentials were exported for the demo, clear them:

```bash
unset AWS_PROFILE
```

---

# 13. Student Lab Manual

## Lab Title

**Create a Python JSON Configuration Validator**

## Lab Objective

Create a Python script that reads a JSON configuration file, validates required fields, handles common errors, and prints a clean validation report.

## Estimated Time

45 to 60 minutes

## Student Prerequisites

Students should know:

- Basic terminal commands
- How to create files in VS Code
- Basic Python syntax
- Lists and dictionaries
- Basic JSON structure

## Workflow Overview

```text
app_config.json
      |
      v
validate_config.py
      |
      v
Check required fields
      |
      +--> Valid: print success report
      |
      +--> Invalid: print clear error
```

---

## Step 1: Create Lab Folder

```bash
mkdir -p week-08-python-devops/class-02-lab
cd week-08-python-devops/class-02-lab
```

---

## Step 2: Create Virtual Environment

```bash
python -m venv .venv
```

Activate it.

Linux/macOS:

```bash
source .venv/bin/activate
```

Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

Validate:

```bash
python --version
```

Expected output:

```text
Python 3.x.x
```

---

## Step 3: Create JSON Config File

Create `app_config.json`:

```json
{
  "application": "inventory-service",
  "environment": "dev",
  "owner": "cloud-team",
  "region": "us-east-1"
}
```

---

## Step 4: Create Python Script

Create `validate_config.py`.

Start with this skeleton:

```python
import json

REQUIRED_FIELDS = ["application", "environment", "owner", "region"]

def load_config(file_path):
    with open(file_path, "r") as file:
        return json.load(file)

def validate_config(config):
    missing_fields = []

    for field in REQUIRED_FIELDS:
        if field not in config:
            missing_fields.append(field)

    return missing_fields

def print_report(config):
    print("Configuration Validation Report")
    print("===============================")
    print(f"Application: {config['application']}")
    print(f"Environment: {config['environment']}")
    print(f"Owner: {config['owner']}")
    print(f"Region: {config['region']}")

def main():
    try:
        config = load_config("app_config.json")
        missing_fields = validate_config(config)

        if missing_fields:
            print("Configuration validation failed.")
            print("Missing fields:")
            for field in missing_fields:
                print(f"- {field}")
        else:
            print("Configuration validation passed.")
            print_report(config)

    except FileNotFoundError:
        print("Error: app_config.json file was not found.")
    except json.JSONDecodeError:
        print("Error: app_config.json contains invalid JSON.")

if __name__ == "__main__":
    main()
```

---

## Step 5: Run the Script

```bash
python validate_config.py
```

Expected output:

```text
Configuration validation passed.
Configuration Validation Report
===============================
Application: inventory-service
Environment: dev
Owner: cloud-team
Region: us-east-1
```

---

## Step 6: Test Missing Field

Edit `app_config.json` and remove `owner`:

```json
{
  "application": "inventory-service",
  "environment": "dev",
  "region": "us-east-1"
}
```

Run:

```bash
python validate_config.py
```

Expected output:

```text
Configuration validation failed.
Missing fields:
- owner
```

---

## Step 7: Test Invalid JSON

Break the JSON by removing a comma:

```json
{
  "application": "inventory-service"
  "environment": "dev",
  "owner": "cloud-team",
  "region": "us-east-1"
}
```

Run:

```bash
python validate_config.py
```

Expected output:

```text
Error: app_config.json contains invalid JSON.
```

Fix the JSON before continuing.

---

## Step 8: Optional Challenge

Add validation so `environment` must be one of:

```text
dev, test, staging, prod
```

Example solution logic:

```python
VALID_ENVIRONMENTS = ["dev", "test", "staging", "prod"]

def validate_environment(config):
    environment = config.get("environment")

    if environment not in VALID_ENVIRONMENTS:
        return False

    return True
```

Expected output for invalid environment:

```text
Configuration validation failed.
Invalid environment: sandbox
Allowed values: dev, test, staging, prod
```

---

## Validation Checklist

Students should confirm:

- [ ] Virtual environment was created
- [ ] Script runs successfully with valid JSON
- [ ] Script detects missing required fields
- [ ] Script detects invalid JSON
- [ ] Script prints readable output
- [ ] Script uses at least one function
- [ ] Script uses `try` and `except`
- [ ] Script is saved in the correct folder

---

## Troubleshooting Tips

| Problem | Likely Cause | Fix |
|---|---|---|
| `python` command not found | Python not installed or PATH issue | Try `python3`, verify install |
| File not found | Script is run from wrong folder | Run `pwd` or `dir`, verify file exists |
| JSON error | Missing comma, quote, or bracket | Validate JSON syntax |
| Script prints nothing | `main()` not called | Add `if __name__ == "__main__": main()` |
| KeyError | Script expects a missing field | Validate before reading field directly |
| Virtual environment not active | Activation skipped | Activate `.venv` |

---

## Cleanup Steps

No cloud resources are created.

Optional cleanup:

```bash
deactivate
```

Optional folder cleanup:

```bash
cd ..
rm -rf class-02-lab
```

---

## Reflection Questions

1. Why is JSON validation important before automation runs?
2. What could happen if a deployment script accepted a bad region or missing environment value?
3. Why should scripts give clear error messages?
4. How would this script be useful inside a CI/CD pipeline?
5. What changes would be needed to validate multiple application config files?

---

# 14. Troubleshooting Activity

## Incident Title

**Python Config Validator Fails During Pre-Deployment Check**

## Business Impact

A development team is trying to deploy a new internal service. The deployment pipeline uses a Python validation script before deployment. The script fails, so the deployment is blocked.

This prevents a potentially bad deployment, but the team needs to understand why it failed.

## Symptoms

The student sees this error:

```text
Traceback (most recent call last):
  File "validate_config.py", line 8, in <module>
    print(config["app_name"])
KeyError: 'app_name'
```

## Starting Evidence

Broken script:

```python
import json

with open("config.json", "r") as file:
    config = json.load(file)

print(config["app_name"])
print(config["region"])
print(config["environment"])
```

Broken JSON:

```json
{
  "application": "billing-api",
  "region": "us-east-1"
}
```

## Student Investigation Steps

Students should:

1. Read the error message.
2. Identify the line causing the failure.
3. Compare the expected key in the script with the actual JSON fields.
4. Notice that the script expects `app_name`.
5. Notice that JSON contains `application`.
6. Notice that `environment` is missing.
7. Explain why direct dictionary access can fail.
8. Add validation before printing values.
9. Add error handling for missing file and invalid JSON.

## Expected Root Cause

The script expects fields that are missing or named differently in the JSON file.

Specific issues:

- Script expects `app_name`, but JSON has `application`.
- Script expects `environment`, but JSON does not include it.
- Script does not validate required fields.
- Script does not handle errors safely.

## Correct Resolution

Update the script to validate fields first.

Example improved script:

```python
import json

REQUIRED_FIELDS = ["application", "region", "environment"]

try:
    with open("config.json", "r") as file:
        config = json.load(file)

    missing_fields = []

    for field in REQUIRED_FIELDS:
        if field not in config:
            missing_fields.append(field)

    if missing_fields:
        print("Config validation failed.")
        print("Missing required fields:")
        for field in missing_fields:
            print(f"- {field}")
    else:
        print("Config validation passed.")
        print(f"Application: {config['application']}")
        print(f"Region: {config['region']}")
        print(f"Environment: {config['environment']}")

except FileNotFoundError:
    print("Error: config.json was not found.")
except json.JSONDecodeError:
    print("Error: config.json contains invalid JSON.")
```

Corrected JSON:

```json
{
  "application": "billing-api",
  "region": "us-east-1",
  "environment": "dev"
}
```

## Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Rename the Python file | The file name is not the root cause |
| Reinstall Python | Python is working correctly |
| Ignore the error and continue | The deployment may use bad or incomplete config |
| Hardcode missing values in the script | This hides the real config problem |
| Remove error handling | This makes future failures harder to troubleshoot |

## Instructor Hints

Use these hints gradually:

1. “What key does the script ask for?”
2. “What keys exist in the JSON file?”
3. “Is the problem Python itself or the data being passed to Python?”
4. “How could the script check for missing fields before using them?”
5. “What error message would help a teammate fix this faster?”

## Preventive Action

To prevent this issue:

- Define required fields clearly
- Validate config files before deployment
- Use consistent naming standards
- Add schema validation for advanced workflows
- Add validation scripts into CI/CD pipelines
- Fail fast with clear errors
- Store examples of valid config files in the repo

---

# 15. Scenario-Based Discussion Questions

## Question 1

A deployment pipeline uses a JSON file to choose the target environment. What could go wrong if the file says `production` instead of `prod`?

Expected response themes:

- Script may not recognize the environment
- Deployment could fail
- Worse, logic may default incorrectly
- Standard values should be enforced

Follow-up:

“How would you validate allowed environment values before deployment?”

---

## Question 2

A cloud team manually checks resource ownership every Friday. How could Python help?

Expected response themes:

- Generate inventory reports
- Check missing owner fields
- Reduce manual effort
- Improve consistency

Follow-up:

“What fields would you require in an inventory report?”

---

## Question 3

When should you use Bash, and when should you use Python?

Expected response themes:

- Bash is good for quick shell commands
- Python is better for APIs, JSON, complex logic, and reports
- Both are useful in DevOps

Follow-up:

“Can you think of a workflow that uses both?”

---

## Question 4

Why is clear error handling important in production automation?

Expected response themes:

- Reduces troubleshooting time
- Helps teammates understand failures
- Prevents silent failures
- Supports incident response

Follow-up:

“What is an example of a bad error message?”

---

## Question 5

A script validates configs locally but fails in CI/CD. What might be different?

Expected response themes:

- Different working directory
- Missing files
- Different Python version
- Missing environment variables
- Different permissions

Follow-up:

“What validation steps should the pipeline run before executing the script?”

---

## Question 6

What risks exist when automation scripts are allowed to make cloud changes?

Expected response themes:

- Accidental deletion
- Wrong region
- Wrong account
- Permission misuse
- Cost impact
- Production outage

Follow-up:

“What safety checks should exist before write actions?”

---

## Question 7

Why might an enterprise require all cloud resources to have owner and environment metadata?

Expected response themes:

- Cost allocation
- Incident ownership
- Compliance
- Cleanup
- Support routing

Follow-up:

“How could a Python script help enforce this?”

---

## Question 8

How does this class connect to SRE toil reduction?

Expected response themes:

- Automates repeated checks
- Generates reports faster
- Reduces manual investigation
- Improves operational consistency

Follow-up:

“What repetitive operational task would you automate first?”

---

# 16. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

What is the main reason DevOps teams use Python?

A. To replace all cloud platforms  
B. To automate tasks, parse data, and call APIs  
C. To avoid using Git  
D. To manually click through consoles faster  

**Answer:** B  
**Explanation:** Python is commonly used for automation, data parsing, and API-driven workflows.

---

## Question 2: Multiple Choice

Which Python data type is best for key-value data such as server name, status, and owner?

A. String  
B. Integer  
C. Dictionary  
D. Boolean  

**Answer:** C  
**Explanation:** Dictionaries store key-value pairs.

---

## Question 3: Multiple Choice

Which module is commonly used to parse JSON in Python?

A. os  
B. json  
C. sys  
D. random  

**Answer:** B  
**Explanation:** Python’s built-in `json` module is used to read and write JSON.

---

## Question 4: True or False

A Python virtual environment helps isolate project dependencies.

**Answer:** True  
**Explanation:** Virtual environments prevent dependency conflicts between Python projects.

---

## Question 5: True or False

It is safe for automation scripts to assume all input files are valid.

**Answer:** False  
**Explanation:** Scripts should validate input files and handle errors safely.

---

## Question 6: Short Answer

Why is JSON important for DevOps and cloud automation?

**Answer:** JSON is commonly used by APIs, configuration files, cloud SDKs, CI/CD tools, and automation workflows.  
**Explanation:** Cloud platforms frequently return structured data in JSON-like formats.

---

## Question 7: Short Answer

What does `FileNotFoundError` usually mean?

**Answer:** The script tried to open a file that does not exist in the expected location.  
**Explanation:** This often happens when running a script from the wrong directory or using the wrong file name.

---

## Question 8: Troubleshooting

A script fails with:

```text
KeyError: 'environment'
```

What does this likely mean?

A. Python is not installed  
B. The JSON file is missing the `environment` key  
C. The terminal is broken  
D. The script needs AWS credentials  

**Answer:** B  
**Explanation:** A `KeyError` usually means the dictionary does not contain the requested key.

---

## Question 9: Troubleshooting

A student sees:

```text
json.decoder.JSONDecodeError
```

What should they check first?

A. IAM role permissions  
B. JSON syntax, including commas, quotes, and brackets  
C. AWS region  
D. Git branch name  

**Answer:** B  
**Explanation:** `JSONDecodeError` usually means the JSON file is malformed.

---

## Question 10: AWS-Related

In the Section 12A preview (and later cloud-automation work), which AWS SDK for Python do students use?

A. aws-shell  
B. boto3  
C. kubectl  
D. terraform-provider-aws  

**Answer:** B  
**Explanation:** `boto3` is the AWS SDK for Python.

---

## Question 11: AWS-Related

Why should beginner AWS automation start with read-only inventory tasks?

A. Read-only tasks are safer and reduce the risk of accidental changes  
B. AWS does not allow write actions  
C. Python cannot create resources  
D. Read-only tasks do not require credentials  

**Answer:** A  
**Explanation:** Read-only automation is safer for beginners and helps students learn API patterns without risking production changes.

---

## Question 12: Short Answer

Give one example of a real-world task that Python could automate for a cloud team.

**Answer:** Listing EC2 instances, checking missing tags, validating deployment config, generating inventory reports, or parsing logs.  
**Explanation:** These are common cloud and DevOps automation tasks.

---

# 17. Homework Assignment

## Assignment Title

**Build a Cloud Configuration Validation Script**

## Scenario

Your cloud platform team receives configuration files from application teams before creating cloud resources. The team wants a Python script that validates the config file before any deployment pipeline runs.

## Student Tasks

Create a Python script named:

```text
validate_cloud_config.py
```

Create a JSON file named:

```text
cloud_config.json
```

The script must:

1. Read `cloud_config.json`.
2. Validate these required fields:
   - `project_name`
   - `environment`
   - `cloud_provider`
   - `region`
   - `owner`
3. Print a clean validation report.
4. Handle missing file errors.
5. Handle invalid JSON errors.
6. Handle missing required fields.
7. Validate that `cloud_provider` is one of:
   - `aws`
   - `azure`
   - `gcp`
8. Validate that `environment` is one of:
   - `dev`
   - `test`
   - `staging`
   - `prod`

## Example JSON

```json
{
  "project_name": "orders-api",
  "environment": "dev",
  "cloud_provider": "aws",
  "region": "us-east-1",
  "owner": "platform-team"
}
```

## Expected Deliverables

Students submit:

1. `validate_cloud_config.py`
2. `cloud_config.json`
3. Screenshot or copied terminal output
4. Short explanation of:
   - What the script validates
   - What errors it handles
   - How this could be used in CI/CD

## Submission Format

Submit as a Git repo folder or zipped folder:

```text
week-08-class-02-homework/
  validate_cloud_config.py
  cloud_config.json
  output.txt
  README.md
```

## Estimated Completion Time

60 to 90 minutes

## Grading Criteria

| Criteria | Points |
|---|---:|
| Script reads JSON correctly | 20 |
| Required field validation works | 20 |
| Environment and cloud provider validation works | 20 |
| Error handling is clear | 20 |
| Output is readable and documented | 10 |
| README explanation is included | 10 |

## Optional Advanced Challenge

Add support for multiple config files in a folder:

```text
configs/
  app1.json
  app2.json
  app3.json
```

The script should validate each file and print a summary report.

---

# 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid It |
|---|---|---|
| Running script from wrong directory | Students are new to terminal paths | Use `pwd`, `ls`, or `dir` before running |
| Invalid JSON syntax | Missing comma, quote, or bracket | Use JSON formatter or carefully inspect syntax |
| Forgetting to activate virtual environment | Students skip setup steps | Look for `(.venv)` in terminal prompt |
| Using `config["key"]` before validation | Students assume data is always present | Check required fields first |
| Hardcoding values | Easier at first but not reusable | Put values in JSON config |
| No error handling | Script works only in happy path | Add `try` and `except` blocks |
| Confusing list and dictionary syntax | Python data structures are new | Draw the structure before coding |
| Naming mismatch like `app_name` vs `application` | No standard naming convention | Define required field names upfront |
| Ignoring error messages | Beginners may panic at tracebacks | Read from bottom of traceback first |
| Copying code without understanding | Students rush through lab | Ask them to explain each function |

---

# 19. Real-World Enterprise Scenario

## Scenario

A large company has multiple application teams requesting cloud environments. Each team submits a JSON file with project details:

```json
{
  "project_name": "claims-api",
  "environment": "prod",
  "cloud_provider": "aws",
  "region": "us-east-1",
  "owner": "claims-platform-team"
}
```

The cloud platform team wants to prevent bad requests from reaching the deployment pipeline.

## Constraints

- Production changes require approval.
- Every resource must have an owner.
- Only approved regions can be used.
- Only approved cloud providers are supported.
- Missing metadata causes cost allocation and support issues.
- Bad configuration can cause deployment failures or production incidents.

## How the Class Topic Applies

The Python validator created in this class could be used to:

- Validate required fields
- Enforce approved environment names
- Prevent unsupported cloud providers
- Block missing owner metadata
- Produce clear error messages for application teams
- Run as part of a CI/CD pipeline

## What Each Role Would Do

| Role | Responsibility |
|---|---|
| DevOps Engineer | Add the validation script to the pipeline |
| Cloud Engineer | Define required cloud fields and approved regions |
| SRE | Ensure bad configs cannot cause incidents or unreliable deployments |
| Security Engineer | Review whether required fields support audit and compliance |
| Platform Engineer | Turn the script into a reusable template for teams |

---

# 20. Instructor Tips

## Teaching Tips

- Keep Python examples tied to infrastructure and operations.
- Avoid teaching Python like a computer science course.
- Use simple scripts but real-world framing.
- Repeat the core pattern: input, validate, process, output.
- Show intentional failures so students become comfortable troubleshooting.

## Pacing Tips

- Do not over-teach advanced Python.
- Focus on practical fluency.
- Spend more time on JSON, dictionaries, and error handling.
- Keep functions simple.
- Keep the `boto3` preview (Section 12A) short; save deep AWS API work for later cloud-automation weeks.

## Lab Support Tips

- First check whether students are in the correct directory.
- Next check whether the JSON file exists.
- Then check JSON syntax.
- Then check Python indentation and field names.
- Pair students who finish early with students who need help.

## Helping Struggling Students

Give them this mental model:

```text
What file am I reading?
What data is inside it?
What fields do I expect?
What should happen if something is missing?
```

## Challenging Advanced Students

Ask advanced students to:

- Add command-line arguments
- Validate multiple files
- Export results to JSON
- Add logging
- Add unit tests
- Build a reusable validation function

---

# 21. Student Outcome Checklist

## Students Should Be Able to Explain

- [ ] Why Python is useful for DevOps and cloud automation
- [ ] Difference between Bash and Python automation use cases
- [ ] What JSON is and why it matters
- [ ] What lists and dictionaries are
- [ ] Why functions improve script organization
- [ ] Why error handling matters in production automation
- [ ] How this class prepares for AWS `boto3`

## Students Should Be Able to Build or Configure

- [ ] A Python virtual environment
- [ ] A basic Python script
- [ ] A JSON configuration file
- [ ] A script that reads JSON
- [ ] A script that validates required fields
- [ ] A script that prints a readable report
- [ ] A script with basic error handling

## Students Should Be Able to Troubleshoot

- [ ] Missing Python command
- [ ] Wrong working directory
- [ ] Missing JSON file
- [ ] Invalid JSON syntax
- [ ] Missing dictionary key
- [ ] Function not being called
- [ ] Virtual environment activation issues

---

# 22. Class Completion Checklist

## Instructor Checklist Before Ending Class

- [ ] Students understand Python’s role in DevOps automation
- [ ] Students created and activated a virtual environment
- [ ] Students created a JSON file
- [ ] Students ran a Python script successfully
- [ ] Students saw at least one intentional failure
- [ ] Students understand `FileNotFoundError`
- [ ] Students understand `JSONDecodeError`
- [ ] Students understand `KeyError`
- [ ] Students understand homework expectations
- [ ] Students saw the read-only `boto3` preview (Section 12A) and understand it is the AWS SDK for Python

## Student Checklist Before Leaving Class

- [ ] I can run `python --version`
- [ ] I can create a virtual environment
- [ ] I can activate a virtual environment
- [ ] I can create a JSON file
- [ ] I can read JSON using Python
- [ ] I can validate required fields
- [ ] I can explain why error handling matters
- [ ] I started or completed the config validator lab
- [ ] I understand the homework assignment

## Items to Verify Before Moving to Week 9 (CI/CD)

Students should have:

- Working Python installation
- Working terminal or PowerShell
- Basic comfort running Python scripts
- Understanding of JSON structure
- Understanding of dictionaries and lists
- Basic error handling knowledge
- Completed or mostly completed homework script

With both halves of Week 8 (Bash in Class 1, Python here in Class 2) complete, students can carry these skills into:

- Week 9 CI/CD, where validation scripts run as pipeline steps gated on exit codes
- Later cloud-automation work that expands the `boto3` preview into:
  - AWS credentials and STS identity checks
  - S3 bucket listing and EC2 inventory
  - AWS API error handling

---

# Class Artifacts & Validation

The runnable, on-disk artifacts for this class live in the [`labs/python-automation/`](../../labs/python-automation/) module — the production-shaped version of the `load → validate → process → output` pattern taught inline (pure, unit-testable business logic with the single AWS-touching call isolated behind a guarded-import wrapper, the same shape as the `boto3` preview in §12A). Every gate below was **run in this environment** (Python 3.10.12, no boto3); `./validate.sh` reports `3 passed, 0 failed`, exit 0.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/python-automation/solution/tag_audit.py | python (`.py`) | Pure `missing_tags`/`audit_resources` — find resources missing required tags (empty value = missing) | `python3 -m py_compile` + `unittest discover -s tests` | PASS — `Ran 42 tests ... OK` |
| 2 | labs/python-automation/solution/ec2_rightsize.py | python (`.py`) | Pure `recommend` — peak-based smaller/keep/larger (`>=` high inclusive, `<` low strict) | `python3 -m py_compile` + `unittest discover -s tests` | PASS — covered by the 42-test suite |
| 3 | labs/python-automation/solution/cost_report.py | python (`.py`) | Pure `summarize` — accumulate per-service Cost Explorer rows, sort, grand total | `python3 -m py_compile` + `unittest discover -s tests` | PASS — covered by the 42-test suite |
| 4 | labs/python-automation/solution/lib/awsclient.py | python (`.py`) | Thin AWS wrapper with a guarded `try/except ImportError` boto3 import — keeps pure logic + tests boto3-free | `python3 -c "from lib import awsclient; print(awsclient.boto3_available())"` (from `solution/`) | PASS — prints `False`, no crash |
| 5 | labs/python-automation/solution/requirements.txt | requirements | Pins `boto3>=1.34,<2.0` for the **live** read-only CLI paths only | `pip install -r requirements.txt` (live path) | DEFERRED — boto3 not installed in this build env; runs where boto3 + AWS creds exist |
| 6 | labs/python-automation/tests/ | python tests | stdlib `unittest` suite (no AWS/network): `test_tag_audit.py`, `test_ec2_rightsize.py`, `test_cost_report.py` | `PYTHONPATH=solution python3 -m unittest discover -s tests -p 'test_*.py'` | PASS — `Ran 42 tests ... OK`, exit 0 |
| 7 | labs/python-automation/validate.sh | shell (`.sh`) | Gate runner: py_compile all `.py` + run suite vs `solution/` + assert `starter/` is incomplete | `./validate.sh` | PASS — `3 passed, 0 failed`, exit 0 |

> Run all gates: `cd labs/python-automation && ./validate.sh`. The **starter is the reproducible broken state** — it compiles but its tests fail with concrete assertions until the three core-logic `TODO(student)` gaps are completed. The live boto3 CLI paths (and the §12A `boto3` preview shown inline) are honestly **DEFERRED**: they are read-only `Describe`/`Get` calls that run where boto3 + AWS credentials exist; no live AWS run is captured for this class.

---

# Definition of Done

Ticked honestly for **this class** (Python for DevOps automation, backed by `labs/python-automation/`):

- [x] Every technology taught ships at least one **runnable file on disk** — four `.py` tools/library + `requirements.txt` in `solution/`, not just fences.
- [x] Each artifact passes (or documents) its **validation gate** from §3 — `python3 -m py_compile` + stdlib `unittest` (the §3 "Python automation" row); output captured above and re-run live (`3 passed, 0 failed`; `Ran 42 tests ... OK`).
- [x] Lab has **starter** (intentionally incomplete — comparison/threshold logic `TODO`'d) and **solution** (reference) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, and cost notes (lab/tests `$0`; one live-path caveat: Cost Explorer `$0.01`/request).
- [x] **Cleanup/teardown** is provided and idempotent — only `__pycache__/` is created locally (removal command documented); the live CLIs are read-only and create nothing in AWS.
- [x] **Instructor answer key** exists — `solution/` plus the README "Instructor answer key" section, and an answer key for the in-class quiz (Section 16) and homework (Section 17).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — the **starter** compiles but fails its tests with diffable assertions until the three logic TODOs are done (documented in the README Troubleshooting table as the deliberate exercise).
- [x] **Expected outputs** are shown for the demo, lab, and every gate (sample tool output + captured `validate.sh`/`unittest` tail).
- [x] **Cost & security warnings** present — no-secrets/default-credential-chain, least-privilege read-only IAM, `pip-audit`, and the Cost Explorer per-request charge are all called out.
- [x] **Cross-references** to the module repo and to prior/next weeks are correct (Class 1 → Bash comparison; §12A `boto3` preview; Week 9 → CI/CD; later cloud-automation weeks reuse the wrapper pattern).
- [x] The **artifact manifest** (§4.2) is present above and every path resolves (verified with `ls`).
- [ ] **Mastered / live operation** — the pure logic is *built, validated, and unit-tested*, but the AWS path is **boto3-DEFERRED** with no captured live run, and the artifacts are not reused/operated in the capstone. No `LIVE-AWS-VALIDATION.txt` exists for this lab. This caps the class below the 8–10 band per §6.
