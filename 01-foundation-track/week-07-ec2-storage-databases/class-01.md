# Week 7: EC2, Storage, and Databases
# Class 1 Package: Launching and Managing AWS Compute with EC2

**Week:** 7
**Class:** 1
**Track:** Unified DevOps · Cloud · SRE Track

---

> **▶ Runnable lab for this class:** [`labs/aws-storage-databases/`](../../labs/aws-storage-databases/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## 1. Class Overview

### Class Title

**Class 1: Launching and Managing AWS Compute with EC2**

### Class Purpose

This class introduces students to AWS compute using **Amazon EC2**. Students learn how a virtual server is created, secured, accessed, configured, and used to host a simple web application.

The class focuses on practical infrastructure work. Students will launch an EC2 instance, connect to it over SSH, inspect its storage, install a web server, and troubleshoot why a web application may not be reachable.

### How This Class Connects to the Overall Course

This class builds on:

- Week 2: Linux commands, services, logs, SSH
- Week 4: AWS account, AWS CLI v2, regions, identity, billing awareness
- Week 5: Networking, VPC, subnets, route tables, internet gateway, security groups
- Week 6: IAM, roles, instance profiles, KMS, governance

This class prepares students for:

- S3, RDS, DynamoDB, and backup architecture in Class 2
- CI/CD deployments to EC2 (Week 9)
- Docker and container concepts (Week 10)
- Terraform provisioning of EC2 resources (Week 14)
- Observability and production troubleshooting (Week 16)

### What Students Will Build, Analyze, or Practice

Students will:

- Launch an EC2 instance
- Select an AMI and instance type
- Configure security group access
- Use an EBS root volume
- Use user data to bootstrap a web server
- Connect using SSH
- Validate Apache/httpd service status
- Access a web page from a browser
- Troubleshoot an unreachable EC2-hosted web application

---

## 2. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** what EC2 is and when it is used in real application environments.
2. **Compare** AMIs, instance types, key pairs, security groups, and EBS volumes.
3. **Configure** an EC2 instance in a public subnet with safe security group rules.
4. **Connect** to a Linux EC2 instance using SSH.
5. **Build** a simple web server using Apache/httpd on Amazon Linux.
6. **Validate** web server health using `systemctl`, `curl`, and browser testing.
7. **Troubleshoot** common EC2 web app access failures.
8. **Document** the basic compute architecture and explain the traffic flow.

---

## 3. Prerequisites Students Should Already Know

### Required Prior Concepts

Students should already understand:

- Basic AWS Console navigation
- AWS Regions and Availability Zones
- VPC, subnet, route table, and internet gateway basics
- Security group basics
- Public IP vs private IP
- Linux file navigation
- SSH concept
- HTTP on port 80
- Basic terminal commands

### Required Tools Already Installed

Students should have:

- VS Code
- Terminal or shell
- Git Bash, WSL, macOS Terminal, or Linux terminal
- AWS CLI
- SSH client
- Browser
- Text editor

### Required Accounts or Access

Students need:

- AWS account or classroom AWS sandbox
- Permission to create EC2 instances
- Permission to create or use security groups
- Permission to create or use key pairs
- Access to a VPC with a public subnet
- Permission to view EBS volumes

### Files, Repos, or Sample Code Needed

No application repository is required for this class.

Optional instructor-provided file:

```bash
index.html
```

Example content:

```html
<h1>Hello from Week 7 EC2 Web Server</h1>
<p>This page is running on Amazon EC2.</p>
```

---

## 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| EC2 | AWS service for running virtual machines | Used when teams need server-level control |
| Instance | A running virtual server in EC2 | Similar to a cloud-hosted Linux or Windows server |
| AMI | Template image used to create an EC2 instance | Companies often use approved hardened AMIs |
| Instance type | Defines CPU, memory, network, and performance size | Teams choose instance types based on workload needs |
| Key pair | SSH authentication method for Linux EC2 access | Used instead of password-based server login |
| Public IP | Internet-reachable IP address | Needed when connecting to an instance from the internet |
| Private IP | Internal network IP address | Used for communication inside a VPC |
| Security group | Virtual firewall attached to cloud resources | Controls allowed inbound and outbound traffic |
| EBS | Block storage attached to EC2 | Used as the server disk |
| Root volume | Main disk where the OS is installed | Similar to a root disk on a Linux server |
| User data | Startup script that runs when the instance first boots | Used to bootstrap servers automatically |
| Apache/httpd | Web server software | Used to serve HTTP web pages |
| Port 22 | Default SSH port | Used for admin access to Linux servers |
| Port 80 | Default HTTP port | Used for non-encrypted web traffic |
| Status checks | AWS health checks for EC2 instances | Helps identify infrastructure or instance-level problems |
| IAM instance profile | Container that lets an EC2 instance assume an IAM role | How EC2 gets AWS permissions without static keys |
| SSM Session Manager | Keyless, audited shell access via Systems Manager | Modern replacement for public SSH; no inbound port needed |
| IMDSv2 | Token-required Instance Metadata Service v2 | Security baseline that blocks SSRF credential theft |
| Launch template | Reusable definition of an instance's launch settings | Repeatable provisioning; consumed by Auto Scaling Groups |
| Graviton | AWS ARM-based processors (e.g. `t4g`, `c7g`) | ~20% better price/performance for many workloads |
| Spot instance | Spare EC2 capacity at deep discount, reclaimable | Cheap compute for fault-tolerant, interruptible work |

---

## 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| AWS Console | Launch and inspect EC2, security groups, key pairs, and EBS volumes |
| AWS CLI | Optional validation and command-line resource inspection |
| SSH | Connect to the Linux EC2 instance |
| curl | Test HTTP connectivity locally and remotely |
| systemctl | Check and manage the web server service |
| journalctl | Inspect Linux service logs |
| cloud-init logs | Troubleshoot user data execution |
| Browser | Validate web application access |
| VS Code or text editor | Review scripts or notes |

---

## 6. AWS Services Used

| AWS Service | How It Connects to the Class |
|---|---|
| EC2 | Main compute service used to launch a Linux virtual server |
| AMI | Provides the operating system image for the EC2 instance |
| EBS | Provides the root disk for the EC2 instance |
| Security Groups | Controls SSH and HTTP access to the EC2 instance |
| VPC | Network environment where the EC2 instance runs |
| Subnets | Determines whether the instance is placed in a public or private network segment |
| Internet Gateway | Allows internet traffic to reach resources in public subnets |
| AWS CLI | Optional way to inspect and validate AWS resources |
| IAM | Provides the instance profile/role EC2 uses for keyless AWS access |
| Systems Manager (SSM) | Provides keyless, audited Session Manager access to the instance |
| CloudWatch, optional preview | Mentioned as a future location for logs and metrics |

---

## 7. Azure and GCP Comparison Notes

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Virtual server | EC2 | Azure Virtual Machine | Compute Engine |
| Server image | AMI | VM Image | Machine Image |
| Block storage | EBS | Managed Disk | Persistent Disk |
| Firewall rule | Security Group | Network Security Group | Firewall Rule |
| Startup script | User Data | Custom Data | Startup Script |

Instructor note:

AWS EC2, Azure VMs, and GCP Compute Engine all provide virtual machines. The names and networking models differ, but the basic idea is the same: choose an image, choose a size, attach storage, configure networking, and connect securely.

---

## 8. Time-Boxed Instructor Agenda

| Time | Section | Instructor Activity | Student Activity |
|---:|---|---|---|
| 0:00 to 0:10 | Opening | Explain class goal and connect to Week 5 VPC | Listen and ask setup questions |
| 0:10 to 0:25 | Review | Review subnet, route table, internet gateway, security group | Answer review questions |
| 0:25 to 0:50 | EC2 Concepts | Teach EC2, AMI, instance type, key pair, public/private IP | Take notes |
| 0:50 to 1:10 | EBS Concepts | Explain root volume, block storage, snapshots preview | Compare EBS to local disk |
| 1:10 to 1:25 | Security Group Design | Explain SSH and HTTP access rules | Identify safe vs unsafe rules |
| 1:25 to 1:35 | Break | Short break | Short break |
| 1:35 to 2:05 | Instructor Demo | Launch EC2 and bootstrap Apache with user data | Follow along |
| 2:05 to 2:40 | Student Lab | Support students as they launch EC2 and deploy page | Complete hands-on lab |
| 2:40 to 2:55 | Troubleshooting Activity | Present broken web app scenario | Investigate root cause |
| 2:55 to 3:00 | Recap | Summarize, assign homework, preview Class 2 | Confirm cleanup and homework |

---

## 9. Instructor Lesson Plan

### Step 1: Open the Class

Start by saying:

> Today we move from cloud networking into actual compute. Last week we built the roads. Today we put a server on the road and make sure users can reach it.

Explain that students will launch a real EC2 instance and host a simple web page.

Pause and ask:

- What does a server need before users can reach it?
- What network components did we learn in Week 5?
- Which port is used for HTTP?

Expected answers:

- Public subnet
- Route to internet gateway
- Public IP
- Security group allowing port 80
- Running web server process

### Step 2: Review Week 5 Networking

Draw a simple VPC diagram.

Explain:

- EC2 lives inside a subnet.
- A public subnet has a route to an internet gateway.
- A security group must allow inbound traffic.
- The instance must have a public IP for direct internet access.

Teaching tip:

Beginners often think "instance running" means "application reachable." Make clear that these are different checks.

### Step 3: Teach EC2 Building Blocks

Explain each required decision when launching EC2:

1. Name
2. AMI
3. Instance type
4. Key pair
5. VPC and subnet
6. Public IP setting
7. Security group
8. EBS storage
9. User data

Use this phrase:

> Launching EC2 is not one decision. It is a set of infrastructure decisions.

Pause after AMI and instance type.

Ask:

- Why might a company standardize approved AMIs?
- Why should we not always choose the largest instance type?

Expected themes:

- Security hardening
- Compliance
- Cost control
- Performance needs
- Standard support process

### Step 4: Explain EBS

Explain that EC2 compute and EBS storage are separate.

Key points:

- EC2 is the virtual machine.
- EBS is the attached disk.
- The root volume stores the operating system.
- Snapshots can be used for backup and recovery.
- EBS is tied to an Availability Zone.

Teaching tip:

Use a laptop analogy:

- EC2 = laptop hardware
- AMI = installed OS image
- EBS = hard drive
- Security group = firewall
- User data = startup script

### Step 5: Explain Security Groups

Show a security group rule table.

Minimum rules for lab:

| Type | Protocol | Port | Source | Purpose |
|---|---|---:|---|---|
| SSH | TCP | 22 | Student IP only | Admin access |
| HTTP | TCP | 80 | 0.0.0.0/0 | Browser access |

Security warning:

Avoid opening SSH to `0.0.0.0/0` in real environments. For classroom labs, students should restrict SSH to their IP where possible.

Pause and ask:

- Why is port 22 more sensitive than port 80?
- What could happen if SSH is open to the world?

### Step 6: Run the Instructor Demo

Launch an instance using Amazon Linux 2023.

Use user data to install Apache.

Explain every major screen in the console:

- Instance name
- AMI
- Instance type
- Key pair
- Network settings
- Security group
- Storage
- Advanced details user data

### Step 7: Guide the Student Lab

During the lab, walk around or monitor students.

Common support checks:

- Are they in the correct AWS Region?
- Did they select a public subnet?
- Did they enable public IP?
- Did they use the correct key pair?
- Did they configure HTTP inbound rule?
- Did user data run?
- Is Apache running?

### Step 8: Troubleshooting Activity

Present this situation:

> Your EC2 instance says running. Status checks passed. But the web page does not load.

Have students troubleshoot in this order:

1. Browser error
2. Public IP
3. Security group
4. Subnet route
5. Web server process
6. User data logs

### Step 9: Wrap Up

Summarize:

- EC2 provides compute.
- AMI defines the starting image.
- Instance type defines capacity.
- EBS provides disk.
- Security groups control access.
- User data automates first boot.
- Running infrastructure does not guarantee a running application.

Preview Class 2:

> Next class we separate application responsibilities further: S3 for objects, RDS for relational data, and snapshots/backups for recovery.

---

## 10. Instructor Lecture Notes

### EC2 in Plain English

EC2 is the AWS service that gives you virtual machines. If a company has an application that needs a server, one option is to run it on EC2.

EC2 is commonly used for:

- Legacy applications
- Custom software
- Web servers
- Batch jobs
- Admin servers
- Jump boxes
- Migration from on-premises servers
- Learning infrastructure fundamentals

Talking point:

> EC2 gives you flexibility, but flexibility comes with responsibility. You manage the operating system, patches, services, disk, and application runtime.

### AMI

An AMI is the image used to create an EC2 instance. It is the starting point.

A company may use:

- Amazon Linux AMI
- Ubuntu AMI
- Windows Server AMI
- Custom hardened AMI
- Vendor-provided AMI

Common misconception:

Students may think AMI and instance type are the same. Clarify:

- AMI = what software image starts the server
- Instance type = how much compute capacity the server has

Talking point:

> The AMI decides what the server is. The instance type decides how powerful it is.

### Instance Type

Instance type controls CPU, memory, network performance, and sometimes processor architecture.

| Instance Family | Common Use |
|---|---|
| t family | Burstable general workloads and labs |
| m family | General purpose workloads |
| c family | Compute-heavy workloads |
| r family | Memory-heavy workloads |

The trailing letters and digits also encode the processor:

- `t3`, `m5`, `c5` — Intel/AMD x86
- `t4g`, `m7g`, `c7g` — AWS **Graviton** (ARM). Graviton typically delivers ~20% better price/performance and lower power for many workloads. Pick `t4g` over `t3` in the lab when the AMI is ARM-compatible (Amazon Linux 2023 has ARM images).

Enterprise context:

Teams usually choose instance types based on application CPU usage, memory usage, network throughput, cost, availability, vendor requirements, and performance testing.

Common misconception:

Students may think bigger is always better. Bigger instances cost more. Production sizing should be based on performance data, not guessing.

### Pricing Models and Cost-Aware Compute

Choosing the right *purchasing option* is as important as the instance size. This is a senior expectation and it shows up in interviews:

| Model | What it is | When to use |
|---|---|---|
| On-Demand | Pay per second, no commitment | Spiky/unpredictable workloads, dev/test, the default in this lab |
| Spot | Spare capacity at up to ~90% discount, can be reclaimed with 2-minute notice | Fault-tolerant, stateless, interruptible work — CI runners, batch, big-data, stateless web behind an ASG |
| Savings Plans / Reserved | 1- or 3-year commitment for ~30–70% off | Steady-state, always-on baseline capacity |

Right-sizing discipline:

- Start small (`t4g.micro`/`t3.micro`) and grow from measured CPU/memory, not guesses.
- Use **Compute Optimizer** and **Cost Explorer** rightsizing recommendations to catch oversized instances.
- A stopped instance still bills for its EBS volumes and any Elastic IP — terminate lab resources, do not just stop them.

> Cost note: Week 18 (Cost Optimization & Cloud Operations) goes deep on this. The point here is to build the instinct early: match the purchasing model to the workload's tolerance for interruption.

### EBS

EBS is block storage. It behaves like a disk attached to a server.

Important points:

- Root EBS volume stores the OS.
- EBS volume is independent from EC2 compute, but attached to it.
- You can create snapshots.
- EBS volumes exist in one Availability Zone.
- Volumes have size, type, and performance characteristics.

Talking point:

> EBS is not the same as S3. EBS is a server disk. S3 is object storage. We will compare that more in Class 2.

### User Data

User data is a script passed to EC2 during launch. It runs at first boot.

Common uses:

- Install packages
- Start services
- Add config files
- Register with monitoring
- Pull application code
- Bootstrap agents

Common misconception:

Students may expect user data to run every time the instance restarts. By default, user data runs on first boot.

Talking point:

> User data is our first taste of automation. Instead of clicking into the server and installing software manually, we define what should happen when the server starts.

### Security Groups

Security groups control network access to the instance.

For this class:

- SSH allows admin access.
- HTTP allows browser traffic.

Important security point:

SSH should not be open to the whole internet in real environments.

Better enterprise patterns:

- Use VPN
- Use bastion host
- Use AWS Systems Manager Session Manager
- Restrict source IPs
- Use temporary access
- Log administrative access

Talking point:

> A security group mistake can make a perfectly healthy server look broken.

### Status Checks vs Application Health

EC2 status checks may pass even when the app is down.

| Check | Meaning |
|---|---|
| EC2 instance running | VM is powered on |
| System status check passed | AWS host infrastructure is healthy |
| Instance status check passed | Instance OS appears reachable |
| App reachable | Web server and network path are working |

Talking point:

> Infrastructure health and application health are related, but not the same.

---

## 11. Whiteboard Explanation

### Simple Diagram

```text
User Browser
    |
    | HTTP request to public IP on port 80
    v
Internet
    |
    v
Internet Gateway
    |
    v
Route Table sends 0.0.0.0/0 to IGW
    |
    v
Public Subnet
    |
    v
Security Group allows TCP/80
    |
    v
EC2 Instance
    |
    v
Apache/httpd Web Server
    |
    v
index.html
```

### Component Meaning

| Component | Meaning |
|---|---|
| User Browser | Person trying to reach the web app |
| Internet Gateway | Allows internet connectivity into the VPC |
| Route Table | Controls where network traffic goes |
| Public Subnet | Subnet with route to internet gateway |
| Security Group | Firewall allowing or blocking traffic |
| EC2 Instance | Virtual server running Linux |
| Apache/httpd | Web server process |
| index.html | Web page being served |

### EC2 Building Block Diagram

```text
EC2 Instance: week7-web-server
├── AMI: Amazon Linux 2023
├── Instance Type: t3.micro or t4g.micro (Graviton/ARM)
├── Key Pair: lab-key.pem (or none, when using SSM Session Manager)
├── Network: VPC and Public Subnet
├── Public IP: Used by browser and SSH
├── Security Group:
│   ├── SSH 22 from student IP
│   └── HTTP 80 from internet
├── EBS Root Volume: Linux operating system disk
└── User Data:
    ├── install httpd
    ├── start httpd
    └── create index.html
```

### Enterprise Version of the Diagram

```text
Users
  |
  v
DNS Name
  |
  v
Application Load Balancer
  |
  v
EC2 Auto Scaling Group in Private Subnets
  |
  v
Application Service
  |
  v
Database or Internal APIs

Admin Access:
Engineer
  |
  v
VPN or SSM Session Manager
  |
  v
Private EC2 Access
```

### Instructor Explanation

In this class, students connect directly to a public EC2 instance for learning. In real enterprise environments, production workloads are usually not accessed this way.

A more mature setup would use:

- Load balancer instead of direct public IP
- Private subnets for app servers
- Auto Scaling Group for resilience
- Systems Manager Session Manager instead of direct SSH
- CloudWatch for logs and metrics
- IAM roles instead of hardcoded credentials
- Infrastructure as Code instead of manual console builds

---

## 12. Instructor Demo Script

### Demo Title

**Launch an EC2 Instance and Deploy a Simple Web Server**

### Demo Objective

Show students how to launch an Amazon Linux EC2 instance, install Apache using user data, connect with SSH, validate the service, and access the page from a browser.

### Required Setup

Instructor should have:

- AWS account or sandbox
- AWS Region selected
- VPC with public subnet
- Internet gateway attached
- Route table configured for internet access
- Existing key pair or permission to create one
- Local terminal with SSH
- Student IP available for security group source restriction

### Demo Step 1: Confirm Region and VPC

Console actions:

1. Open AWS Console.
2. Confirm region, for example `us-east-1`.
3. Open VPC console.
4. Confirm public subnet exists.
5. Confirm route table has:

```text
0.0.0.0/0 -> Internet Gateway
```

Explain:

> Before launching compute, we validate the network. If the network path is wrong, the server may be running but unreachable.

### Demo Step 2: Open EC2 Launch Wizard

Console actions:

1. Go to EC2.
2. Select **Instances**.
3. Click **Launch instances**.

Set:

| Setting | Value |
|---|---|
| Name | week7-web-server-demo |
| AMI | Amazon Linux 2023 |
| Instance type | t3.micro or t4g.micro (Graviton, free-tier eligible in many regions) |
| Key pair | Existing lab key pair (optional — SSM Session Manager needs no key) |
| VPC | Lab VPC |
| Subnet | Public subnet |
| Auto-assign public IP | Enabled |
| IAM instance profile | `week7-ec2-ssm-s3` (created in Demo Step 2a) |

### Demo Step 2a: Create the IAM Instance Profile (keyless access + S3)

This role gives the instance two capabilities without any long-lived keys:

1. **SSM Session Manager** keyless, audited shell access (replaces public SSH).
2. **Read/write to a specific S3 prefix** — the exact role Class 2's troubleshooting scenario assumes. We create it now so it is no longer a phantom.

Run the AWS CLI v2 commands (or build the equivalent role in the IAM console):

```bash
# Trust policy: only EC2 may assume this role
cat > ec2-trust.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "ec2.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}
EOF

aws iam create-role \
  --role-name week7-ec2-ssm-s3 \
  --assume-role-policy-document file://ec2-trust.json

# AWS-managed policy that enables SSM Session Manager (the modern, keyless path)
aws iam attach-role-policy \
  --role-name week7-ec2-ssm-s3 \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

# An instance profile is the wrapper EC2 attaches; the role goes inside it
aws iam create-instance-profile --instance-profile-name week7-ec2-ssm-s3
aws iam add-role-to-instance-profile \
  --instance-profile-name week7-ec2-ssm-s3 \
  --role-name week7-ec2-ssm-s3
```

We attach the least-privilege S3 inline policy in Class 2 once the bucket name exists. For now the role is ready and the SSM permissions are in place.

Teaching point:

> An IAM **role** is the set of permissions. An **instance profile** is the container that lets an EC2 instance assume that role. EC2 picks up temporary, auto-rotating credentials from the Instance Metadata Service — no access keys ever touch the disk.

In the launch wizard, under **Advanced details → IAM instance profile**, select `week7-ec2-ssm-s3`.

### Demo Step 2b: Enforce IMDSv2 and Encrypt the Root Volume

Two one-time security baselines that senior reviewers expect on every instance:

- **IMDSv2 (required):** the Instance Metadata Service serves the role's temporary credentials. IMDSv1 answers any local GET, which is exactly what SSRF attacks abuse to steal credentials. IMDSv2 requires a session token, blocking that class of attack. In the launch wizard, **Advanced details → Metadata version → V2 only (token required)**, and set **Metadata response hop limit → 1**.
- **EBS encryption:** in the Storage panel, tick **Encrypted** on the root volume (KMS, the `aws/ebs` key is fine for the lab). Encryption-by-default can also be enabled account-wide in EC2 → Settings.

CLI equivalents if launching from the command line:

```text
--metadata-options "HttpTokens=required,HttpPutResponseHopLimit=1,HttpEndpoint=enabled"
--block-device-mappings 'DeviceName=/dev/xvda,Ebs={Encrypted=true,VolumeType=gp3}'
```

> Why hop limit 1? It stops a containerized process one network hop away from reaching the metadata endpoint and harvesting the instance's credentials.

### Demo Step 3: Configure Security Group

Create or select a security group:

| Rule | Protocol | Port | Source |
|---|---|---:|---|
| HTTP | TCP | 80 | 0.0.0.0/0 |
| SSH (optional) | TCP | 22 | Instructor IP only |

Security warning:

> For classroom HTTP testing, port 80 can be open to the internet. **In 2026 the preferred admin path is SSM Session Manager, which needs NO inbound SSH rule at all** — the instance opens an outbound connection to AWS, so you can leave port 22 closed entirely. We keep an optional IP-restricted SSH rule only for students who want to compare the old pattern. Never open SSH to `0.0.0.0/0`.

### Demo Step 4: Configure Storage

Use a gp3 root volume.

| Setting | Value |
|---|---|
| Root volume size | 8 GiB or default |
| Volume type | gp3 (prefer over gp2) |
| Encryption | Enabled (see Step 2b) |
| Delete on termination | Enabled for lab |

EBS volume-type quick reference (cost/perf lever):

| Type | Use | Notes |
|---|---|---|
| gp3 | Default SSD | Baseline 3,000 IOPS / 125 MB/s, IOPS and throughput tunable independently of size; cheaper than gp2 |
| gp2 | Legacy SSD | IOPS scale with size; gp3 is the modern replacement |
| io2 / io2 Block Express | Latency-sensitive DBs | Provisioned IOPS, higher durability, higher cost |
| st1 / sc1 | Throughput / cold HDD | Large sequential workloads and archival |

> Default to gp3. It is cheaper than gp2 and lets you raise IOPS/throughput without growing the disk.

### Demo Step 5: Add User Data

In advanced details, paste:

```bash
#!/bin/bash
dnf update -y
dnf install -y httpd
systemctl enable httpd
systemctl start httpd
echo "<h1>Hello from Week 7 EC2 Web Server</h1>" > /var/www/html/index.html
echo "<p>Deployed using EC2 user data.</p>" >> /var/www/html/index.html
```

> The SSM agent is preinstalled on Amazon Linux 2023, so no extra install line is needed for Session Manager to work.

### Demo Step 6: Launch Instance

Console actions:

1. Review settings.
2. Click **Launch instance**.
3. Wait until instance state is **Running**.
4. Wait until status checks begin passing.
5. Copy public IPv4 address.

Expected console state:

```text
Instance state: Running
Status check: 2/2 checks passed
```

### Demo Step 7: Test Browser Access

Open:

```text
http://PUBLIC_IP
```

Expected result:

```text
Hello from Week 7 EC2 Web Server
Deployed using EC2 user data.
```

### Demo Step 8: Connect with SSM Session Manager (preferred, keyless)

This is the modern, audited, key-free way to get a shell. It works even with NO inbound SSH rule because the instance reaches out to AWS over the SSM endpoints.

Prerequisites (already satisfied by Step 2a): the instance has the `week7-ec2-ssm-s3` profile with `AmazonSSMManagedInstanceCore`, and outbound HTTPS is allowed (default). Within a minute or two the instance appears as **Managed** under Systems Manager → Fleet Manager.

Connect from your laptop using AWS CLI v2 (install the Session Manager plugin once):

```bash
# Find the instance ID
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=week7-web-server-demo" \
  --query "Reservations[].Instances[].InstanceId" --output text

# Open an audited shell — no key, no public IP, no port 22
aws ssm start-session --target i-0123456789abcdef0
```

Expected result:

```text
Starting session with SessionId: ...
sh-5.2$
```

Console alternative: EC2 → select instance → **Connect → Session Manager → Connect**.

Teaching point:

> Every Session Manager session can be logged to CloudWatch Logs or S3 for audit. There is no key to lose, no bastion to patch, and no inbound SSH port to scan. This is the access pattern senior reviewers expect in 2026.

### Demo Step 8b (optional, legacy comparison): SSH Into Instance

Only if you added the optional SSH rule and a key pair. From local terminal:

```bash
chmod 400 lab-key.pem
ssh -i lab-key.pem ec2-user@PUBLIC_IP
```

Expected result:

```text
[ec2-user@ip-10-x-x-x ~]$
```

Note the contrast: SSH needs an open inbound port, a private key on disk, and a public IP. SSM needs none of those.

### Demo Step 8c: Confirm the Instance Profile Works (IMDSv2)

From inside the instance (SSM or SSH), prove the role's temporary credentials are present and that IMDSv2 is enforced:

```bash
# IMDSv2 requires a token first; IMDSv1-style direct GET should fail
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Confirm which role the instance is actually using
aws sts get-caller-identity
```

The output of `get-caller-identity` should show an `assumed-role/week7-ec2-ssm-s3/...` ARN — no static keys anywhere.

### Demo Step 9: Validate Apache

Run:

```bash
sudo systemctl status httpd
```

Expected output includes:

```text
Active: active (running)
```

Run:

```bash
curl localhost
```

Expected output:

```html
<h1>Hello from Week 7 EC2 Web Server</h1>
<p>Deployed using EC2 user data.</p>
```

Run:

```bash
ss -tulnp | grep :80
```

Expected output should show a process listening on port 80.

### Demo Step 10: Review User Data Logs

Run:

```bash
sudo cat /var/log/cloud-init-output.log
```

Explain:

> If user data fails, this is one of the first logs to check.

### Common Demo Failure Points

| Failure | Likely Cause | Recovery |
|---|---|---|
| Browser timeout | Security group missing port 80 | Add inbound HTTP rule |
| SSH timeout | Port 22 blocked or wrong public IP | Fix SSH rule or confirm IP |
| Permission denied SSH | Wrong key pair or file permission | Use correct key and `chmod 400` |
| Apache not running | User data failed | Start service manually and inspect logs |
| Page shows default test page | index.html not created | Create file manually |
| Instance has no public IP | Public IP disabled or private subnet used | Relaunch or use proper subnet |

### Manual Recovery Commands

If user data fails:

```bash
sudo dnf install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
echo "<h1>Manual recovery successful</h1>" | sudo tee /var/www/html/index.html
curl localhost
```

### Cleanup Steps

Terminate lab instance when done unless needed later.

Console cleanup:

1. EC2
2. Instances
3. Select `week7-web-server-demo`
4. Instance state
5. Terminate instance

Confirm EBS root volume is deleted if delete-on-termination is enabled.

If the IAM role/instance profile is not reused in Class 2, remove it:

```bash
aws iam remove-role-from-instance-profile \
  --instance-profile-name week7-ec2-ssm-s3 --role-name week7-ec2-ssm-s3
aws iam delete-instance-profile --instance-profile-name week7-ec2-ssm-s3
aws iam detach-role-policy --role-name week7-ec2-ssm-s3 \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam delete-role --role-name week7-ec2-ssm-s3
```

> Keep the role if you are continuing to Class 2 — the S3 lab attaches a least-privilege policy to it. IAM roles cost nothing, but delete unused ones for hygiene.

Cost warning:

> Stopped instances may still keep EBS volumes. Terminated lab instances with delete-on-termination enabled usually clean up the root volume.

---

## 13. Student Lab Manual

### Lab Title

**Deploy a Simple Web Server on Amazon EC2**

### Lab Objective

Launch an EC2 instance, install a web server using user data, connect with SSH, validate the service, and access the web page from a browser.

### Estimated Time

35 to 40 minutes

### Student Prerequisites

Before starting, confirm you have:

- AWS account access
- Correct AWS Region selected
- Existing VPC with public subnet
- Key pair available
- SSH client installed
- Permission to create EC2 instances
- Permission to create or modify security groups

### Architecture Overview

```text
Your Browser
    |
    | HTTP on port 80
    v
EC2 Public IP
    |
    v
Security Group allows HTTP
    |
    v
Amazon Linux EC2 Instance
    |
    v
Apache Web Server
```

### Step 1: Launch EC2 Instance

1. Open AWS Console.
2. Go to **EC2**.
3. Click **Launch instance**.
4. Set name:

```text
week7-student-web-server
```

5. Select AMI:

```text
Amazon Linux 2023
```

6. Select instance type:

```text
t3.micro or classroom-approved small instance
```

7. Attach the IAM instance profile and configure access:
   - **Advanced details → IAM instance profile →** `week7-ec2-ssm-s3` (from the demo). This enables keyless SSM access and, in Class 2, S3 access.
   - **Advanced details → Metadata version → V2 only (token required)**, hop limit 1 (IMDSv2).
   - Key pair is **optional**. If you plan to use SSM Session Manager (recommended) you can choose **Proceed without a key pair**.

Important:

If you do create a key pair, download and store it safely. You cannot download the private key again later. With SSM you avoid managing keys entirely.

### Step 2: Configure Network

| Setting | Value |
|---|---|
| VPC | Lab VPC or default VPC |
| Subnet | Public subnet |
| Auto-assign public IP | Enabled |

### Step 3: Configure Security Group

Create a security group with:

| Rule | Type | Port | Source |
|---|---|---:|---|
| HTTP | TCP | 80 | Anywhere IPv4 |
| SSH (optional) | TCP | 22 | My IP |

Security warning:

The preferred admin path is **SSM Session Manager, which needs no inbound rule at all**. Only add the SSH rule if you want to practice the legacy pattern, and never leave SSH open to `0.0.0.0/0`. Set the root volume to **gp3 + Encrypted** in the Storage panel.

### Step 4: Add User Data

Under advanced details, paste:

```bash
#!/bin/bash
dnf update -y
dnf install -y httpd
systemctl enable httpd
systemctl start httpd
echo "<h1>Hello from Week 7 EC2 Lab</h1>" > /var/www/html/index.html
echo "<p>This page was created using EC2 user data.</p>" >> /var/www/html/index.html
```

Students can replace the page text with their own name or lab identifier.

### Step 5: Review and Launch

1. Review settings.
2. Click **Launch instance**.
3. Wait for instance state:

```text
Running
```

4. Copy the public IPv4 address.

### Step 6: Test Browser Access

Open:

```text
http://YOUR_PUBLIC_IP
```

Expected output:

```text
Hello from Week 7 EC2 Lab
This page was created using EC2 user data.
```

If the page does not load, continue with troubleshooting.

### Step 7: Connect Using SSM Session Manager (preferred)

This is the access method to learn first. It needs no key, no public IP exposure, and no inbound SSH rule, because the instance connects outbound to AWS.

```bash
# Find your instance ID
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=week7-student-web-server" \
  --query "Reservations[].Instances[].InstanceId" --output text

# Open an audited, keyless shell
aws ssm start-session --target i-0123456789abcdef0
```

Expected prompt:

```text
sh-5.2$
```

Console alternative: EC2 → select instance → **Connect → Session Manager → Connect**. If the instance does not appear as Managed, confirm the `week7-ec2-ssm-s3` instance profile is attached and wait ~2 minutes.

### Step 7b (optional): Connect Using SSH

Only if you created a key pair and the optional SSH rule. Move to the directory containing your key:

```bash
cd ~/Downloads
chmod 400 lab-key.pem
ssh -i lab-key.pem ec2-user@YOUR_PUBLIC_IP
```

Expected prompt:

```text
[ec2-user@ip-10-x-x-x ~]$
```

### Step 8: Validate Web Server

Run:

```bash
sudo systemctl status httpd
```

Expected:

```text
Active: active (running)
```

Run:

```bash
curl localhost
```

Expected:

```html
<h1>Hello from Week 7 EC2 Lab</h1>
<p>This page was created using EC2 user data.</p>
```

Run:

```bash
ss -tulnp | grep :80
```

Expected:

```text
LISTEN ... :80 ...
```

### Step 9: Inspect User Data Logs

Run:

```bash
sudo tail -50 /var/log/cloud-init-output.log
```

Look for:

- Package install success
- Apache started
- Any error messages

### Step 10: Record Lab Details

| Item | Your Value |
|---|---|
| Region |  |
| Instance ID |  |
| AMI |  |
| Instance type |  |
| Public IP |  |
| Private IP |  |
| Security group ID |  |
| EBS root volume size |  |
| Web server service |  |

### Step 11: Capture the Build as a Launch Template (repeatable provisioning)

Click-launching is fine to learn once, but production EC2 should be repeatable. A **launch template** captures the AMI, instance type, key/SSM, security group, user data, IMDSv2, and instance profile so every launch is identical — and it is exactly what an Auto Scaling Group consumes (Class 2).

Create one from your working instance (no extra cost — a template is just configuration):

```bash
# Base64-encode the same user data you used above.
# Note: `base64 -w0` is GNU coreutils (Linux/WSL). On macOS, drop -w0 and pipe
# through `tr` instead:  USER_DATA=$(base64 <<'EOF' ... EOF
# ) | tr -d '\n'  — i.e. use `base64 | tr -d '\n'` for portability.
USER_DATA=$(base64 -w0 <<'EOF'
#!/bin/bash
dnf install -y httpd
systemctl enable --now httpd
echo "<h1>Hello from a Week 7 launch template</h1>" > /var/www/html/index.html
EOF
)

aws ec2 create-launch-template \
  --launch-template-name week7-web-lt \
  --version-description "v1 - httpd, IMDSv2, SSM, gp3 encrypted" \
  --launch-template-data "{
    \"ImageId\": \"resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64\",
    \"InstanceType\": \"t4g.micro\",
    \"IamInstanceProfile\": {\"Name\": \"week7-ec2-ssm-s3\"},
    \"MetadataOptions\": {\"HttpTokens\": \"required\", \"HttpPutResponseHopLimit\": 1},
    \"BlockDeviceMappings\": [{\"DeviceName\": \"/dev/xvda\", \"Ebs\": {\"VolumeType\": \"gp3\", \"Encrypted\": true}}],
    \"UserData\": \"$USER_DATA\"
  }"
```

The `resolve:ssm:` reference pulls the latest Amazon Linux 2023 ARM AMI automatically, so the template never goes stale. You could now launch an instance from it with `aws ec2 run-instances --launch-template LaunchTemplateName=week7-web-lt`.

Cleanup:

```bash
aws ec2 delete-launch-template --launch-template-name week7-web-lt
```

> A launch template is the bridge between manual clicking and Auto Scaling / Terraform. Class 2 uses this same template idea when an ASG replaces a failed instance.

### Validation Checklist

Before submitting the lab, confirm:

- EC2 instance is running
- Instance is reachable via SSM Session Manager (no public SSH needed)
- IAM instance profile is attached and `aws sts get-caller-identity` shows the assumed role
- IMDSv2 is enforced (token required)
- Root EBS volume is gp3 and encrypted
- Security group allows HTTP on port 80; SSH (if present) only from your IP
- Apache/httpd is running
- `curl localhost` returns the page
- Browser can load the page
- User data log has no major error
- A launch template was created
- Lab notes are documented

### Troubleshooting Tips

| Problem | What to Check |
|---|---|
| Browser timeout | Security group, public IP, subnet, route table |
| SSH timeout | Port 22, source IP, public IP |
| SSH permission denied | Wrong key or key file permission |
| Apache not running | `systemctl status httpd` |
| User data did not work | `/var/log/cloud-init-output.log` |
| Page not found | `/var/www/html/index.html` |
| Wrong region | Confirm region in AWS Console |

### Cleanup Steps

After instructor approval:

1. Go to EC2 console.
2. Select your instance.
3. Choose **Instance state**.
4. Choose **Terminate instance**.
5. Confirm termination.
6. Verify the instance is terminated.

Optional CLI cleanup if allowed:

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=week7-student-web-server" \
  --query "Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]" \
  --output table
```

Cost warning:

Terminating the instance helps avoid charges. Stopping an instance may still leave EBS storage charges.

### Reflection Questions

1. What is the difference between EC2 and EBS?
2. Why does the instance need a public IP for browser access in this lab?
3. Why should SSH not be open to the whole internet?
4. What did user data automate?
5. What would change in a production architecture?

### Optional Challenge Task

Modify the web page to show:

- Hostname
- Private IP
- Current date and time

Example command:

```bash
echo "<h1>Server: $(hostname)</h1>" | sudo tee /var/www/html/index.html
echo "<p>Private IP: $(hostname -I)</p>" | sudo tee -a /var/www/html/index.html
echo "<p>Generated at: $(date)</p>" | sudo tee -a /var/www/html/index.html
```

---

## 14. Troubleshooting Activity

### Incident Title

**EC2 Instance Running, But Web App Is Unreachable**

### Business Impact

A small internal business application was deployed on EC2 for a department demo. The server appears to be running, but users cannot access the web page. The demo is scheduled soon, and the DevOps team must quickly identify whether the issue is network, security, server, or application related.

### Symptoms

```text
EC2 instance state: Running
Status checks: 2/2 passed
Browser result: Connection timed out
SSH access: Works
Application URL: http://PUBLIC_IP
```

### Starting Evidence

Sample command output:

```bash
curl http://PUBLIC_IP
```

Output:

```text
curl: (28) Failed to connect to PUBLIC_IP port 80 after 75000 ms: Connection timed out
```

SSH command works:

```bash
ssh -i lab-key.pem ec2-user@PUBLIC_IP
```

Inside the instance:

```bash
sudo systemctl status httpd
```

Output:

```text
Unit httpd.service could not be found.
```

Security group inbound rules:

```text
SSH TCP 22 from student-public-ip/32
```

There is no HTTP rule.

### Student Investigation Steps

Students should investigate:

1. Is the instance running?
2. Does it have a public IP?
3. Is it in a public subnet?
4. Does the security group allow port 80?
5. Is Apache installed?
6. Is Apache running?
7. Is anything listening on port 80?
8. Did user data run?
9. Are there errors in cloud-init logs?

Commands:

```bash
sudo systemctl status httpd
sudo dnf list installed httpd
sudo cat /var/log/cloud-init-output.log
ss -tulnp | grep :80
curl localhost
```

### Expected Root Cause

There are two issues:

1. Security group does not allow inbound HTTP on port 80.
2. Apache/httpd was not installed because the user data script was missing or failed.

### Correct Resolution

Add security group rule:

| Type | Protocol | Port | Source |
|---|---|---:|---|
| HTTP | TCP | 80 | 0.0.0.0/0 |

Then install and start Apache:

```bash
sudo dnf install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
echo "<h1>Recovered EC2 Web App</h1>" | sudo tee /var/www/html/index.html
curl localhost
```

Validate from browser:

```text
http://PUBLIC_IP
```

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Rebooting instance repeatedly | Does not fix missing security group or missing service |
| Recreating key pair | SSH already works, so key pair is not the issue |
| Changing AMI immediately | Too early without checking service and security group |
| Opening all ports | Unsafe and unnecessary |
| Making a new VPC | Not needed for this issue |
| Assuming status checks mean app is healthy | Status checks do not validate Apache |

### Instructor Hints

Use hints in stages:

Hint 1:

> Does AWS say the server is healthy, or does the application also prove it is healthy?

Hint 2:

> Which port does HTTP use?

Hint 3:

> Can the server answer itself using curl localhost?

Hint 4:

> What service should be listening on port 80?

### Preventive Action

Students should recommend:

- Use tested user data scripts
- Validate cloud-init logs after launch
- Use standard security group templates
- Add HTTP health checks
- Use launch templates for repeatable setup (see Step 11)
- Use SSM Session Manager for keyless, audited access
- Enforce IMDSv2 to block credential theft via SSRF
- Use Terraform later (Week 14) for consistent provisioning
- Document required ports
- Avoid manual one-off server builds in production

### Package This as a Portfolio Incident Write-Up

This exercise is interview-grade. Convert it into a one-page incident write-up for your portfolio using the course's evidence-first methodology:

| Section | Content |
|---|---|
| Symptom | Browser times out on `http://PUBLIC_IP`; status checks 2/2 passed |
| Evidence | `curl localhost` works; `systemctl status httpd` = not found; SG has no port 80 rule |
| Root cause | Two faults: missing inbound HTTP rule (network) AND failed/missing user data (service) |
| Fix | Add HTTP 80 SG rule; install + enable + start httpd |
| Validation | `curl localhost`, `ss -tulnp \| grep :80`, browser load all succeed |
| Prevention | Launch template + tested user data + health checks |

> The discipline — symptom → evidence → root cause → fix → validate — is what separates a senior engineer from someone who reboots and hopes.

---

## 15. Scenario-Based Discussion Questions

### Question 1

**Why might an enterprise still use EC2 instead of containers or serverless?**

Expected themes:

- Legacy workloads
- Custom OS dependencies
- Vendor software
- Migration from on-premises
- Need full control
- Long-running processes

Follow-up:

> What operational responsibilities come with that control?

### Question 2

**Should SSH be open to the internet for production EC2 instances?**

Expected themes:

- No, avoid broad SSH access
- Restrict by IP
- Use VPN or bastion
- Prefer Systems Manager Session Manager
- Log and audit access

Follow-up:

> What would Security or Audit ask for?

### Question 3

**If an EC2 instance is running but the app is down, who should investigate first: DevOps, Cloud Engineering, or SRE?**

Expected themes:

- Depends on ownership model
- Cloud team checks network and infrastructure
- DevOps checks deployment
- SRE checks service health and incident impact
- Collaboration is required

Follow-up:

> What evidence would each team bring?

### Question 4

**What is the risk of manually installing software on EC2 after launch?**

Expected themes:

- Configuration drift
- Not repeatable
- Hard to rebuild
- Missing documentation
- Manual errors

Follow-up:

> How do user data, AMIs, Terraform, or CI/CD reduce that risk?

### Question 5

**What should go into user data, and what should not?**

Expected themes:

Good for:

- Package install
- Service start
- Lightweight bootstrap

Avoid:

- Hardcoded secrets
- Complex fragile scripts
- Manual credentials
- Large application logic

Follow-up:

> Where should secrets be stored instead?

### Question 6

**Why should students care about EBS delete-on-termination in a lab?**

Expected themes:

- Cost control
- Cleanup
- Avoid orphaned storage
- Understand resource lifecycle

Follow-up:

> What other resources can be left behind and create cost?

### Question 7

**What is the difference between infrastructure health and application health?**

Expected themes:

- EC2 may be running
- OS may be healthy
- App service may be stopped
- Port may be blocked
- App may return errors

Follow-up:

> What monitoring would prove the app is healthy?

### Question 8

**How would this architecture change for production?**

Expected themes:

- Use load balancer
- Use private subnets
- Use Auto Scaling
- Use IAM roles
- Use monitoring
- Use patching strategy
- Use IaC
- Avoid direct public SSH

Follow-up:

> Which change improves reliability the most? Which improves security the most?

---

## 16. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple Choice

What does an AMI define when launching EC2?

A. Network firewall rules  
B. Operating system image and starting software  
C. Monthly billing limit  
D. Database backup policy  

**Answer:** B  
**Explanation:** The AMI provides the image used to launch the instance, including the OS and sometimes preinstalled software.

### Question 2: Multiple Choice

Which AWS service provides block storage for EC2?

A. S3  
B. RDS  
C. EBS  
D. Route 53  

**Answer:** C  
**Explanation:** EBS is block storage attached to EC2 instances.

### Question 3: Multiple Choice

Which port must be allowed for basic HTTP browser access?

A. 22  
B. 53  
C. 80  
D. 3306  

**Answer:** C  
**Explanation:** HTTP uses TCP port 80 by default.

### Question 4: True or False

If EC2 status checks pass, the web application is guaranteed to be working.

**Answer:** False  
**Explanation:** EC2 status checks validate infrastructure and instance health, not necessarily the application process.

### Question 5: True or False

Opening SSH to `0.0.0.0/0` is a recommended production practice.

**Answer:** False  
**Explanation:** SSH should be restricted. Better approaches include VPN, bastion hosts, or Systems Manager Session Manager.

### Question 6: Short Answer

What is user data used for in EC2?

**Answer:** User data is used to run startup commands when an instance first boots, such as installing packages, starting services, or creating configuration files.

### Question 7: Multiple Choice

Your EC2 instance is running and SSH works, but the browser cannot reach the web page. Which should you check first?

A. Whether port 80 is allowed in the security group  
B. Whether the AWS account has billing enabled  
C. Whether the key pair uses RSA  
D. Whether the instance name is correct  

**Answer:** A  
**Explanation:** If SSH works but HTTP fails, the HTTP security group rule or web server process is a likely issue.

### Question 8: Short Answer

Name two reasons user data might fail.

**Answer:** Possible answers include syntax error, wrong package manager, no internet access, bad command, missing permissions, or package repository issue.

### Question 9: Multiple Choice

Which command checks whether Apache/httpd is running?

A. `aws ec2 describe-instances`  
B. `sudo systemctl status httpd`  
C. `ssh-keygen`  
D. `aws s3 ls`  

**Answer:** B  
**Explanation:** `systemctl status httpd` checks the Linux service status.

### Question 10: Troubleshooting Short Answer

The browser times out when accessing `http://PUBLIC_IP`, but `curl localhost` on the server works. What is the likely issue?

**Answer:** The web server is running locally, so the likely issue is network access, most commonly the security group missing inbound port 80, subnet routing, public IP, or NACL issue.

### Question 11: AWS Short Answer

What is the difference between public IP and private IP on EC2?

**Answer:** The private IP is used inside the VPC. The public IP can be used from the internet if routing and security rules allow it.

### Question 12: Troubleshooting Multiple Choice

SSH fails with “Permission denied.” What is a likely cause?

A. The HTTP port is closed  
B. Wrong private key or incorrect key permissions  
C. Apache is not installed  
D. S3 bucket is private  

**Answer:** B  
**Explanation:** SSH permission denied often means the wrong key, wrong username, or insecure private key file permissions.

---

## 17. Homework Assignment

### Assignment Title

**EC2 Web Server Architecture and Troubleshooting Report**

### Scenario

Your team deployed a simple internal web application on EC2 for a business unit. The app works after troubleshooting, but the team needs documentation so another engineer can understand the architecture, access rules, and common failure points.

### Student Tasks

Create a short technical report that includes:

1. EC2 architecture diagram
2. Explanation of AMI, instance type, key pair, security group, public IP, and EBS
3. Screenshot or copied output showing web server validation
4. Explanation of user data script
5. Troubleshooting checklist for unreachable web app
6. Short comparison with Azure VM and GCP Compute Engine

### Expected Deliverables

Students submit:

- One PDF, Markdown file, or Word document
- Diagram included
- Commands and outputs included
- Troubleshooting checklist included

### Required Command Outputs

Include outputs from:

```bash
sudo systemctl status httpd
curl localhost
ss -tulnp | grep :80
aws sts get-caller-identity   # run on the instance: proves the role/instance profile works
```

Document how you connected (SSM Session Manager preferred) and confirm IMDSv2 is enforced.

Optional:

```bash
sudo tail -50 /var/log/cloud-init-output.log
```

### Submission Format

Recommended format:

```text
week7-class1-ec2-report-yourname.md
```

or

```text
week7-class1-ec2-report-yourname.pdf
```

### Estimated Completion Time

60 to 90 minutes

### Grading Criteria

| Criteria | Weight |
|---|---:|
| Correct EC2 architecture diagram | 20% |
| Accurate explanation of EC2 components | 20% |
| Lab validation evidence | 20% |
| Troubleshooting checklist quality | 20% |
| Cloud comparison and documentation clarity | 20% |

### Optional Advanced Challenge

Add a section explaining how this design would change in production using:

- Application Load Balancer
- Auto Scaling Group
- Private subnets
- Systems Manager Session Manager
- CloudWatch logs and metrics

---

## 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Launching in wrong region | Students forget region selection | Confirm region before starting lab |
| Choosing private subnet | Students do not connect subnet type to reachability | Use public subnet for this beginner lab |
| Forgetting public IP | Auto-assign public IP may be disabled | Enable public IP or use Elastic IP if required |
| Missing HTTP rule | Students only allow SSH | Add inbound TCP 80 rule |
| Opening SSH to everyone | Students want quick access | Use My IP for SSH source |
| Using wrong SSH username | Different AMIs use different users | Amazon Linux uses `ec2-user` |
| Wrong key file permissions | SSH rejects open private key files | Run `chmod 400 key.pem` |
| User data syntax error | Bash script copied incorrectly | Check cloud-init logs |
| Expecting user data to rerun after reboot | Misunderstanding boot behavior | Relaunch or manually run commands |
| Forgetting cleanup | Students assume stopped means free | Terminate lab resources and confirm EBS cleanup |
| Confusing EBS and S3 | Both are storage services | EBS is block disk, S3 is object storage |
| Trusting EC2 status checks only | Status checks do not verify app | Test service and app endpoint |

---

## 19. Real-World Enterprise Scenario

### Scenario

A logistics company needs to host a small internal dashboard for operations teams. The application is not yet containerized, and the team decides to run the first version on EC2.

### Constraints

- The app must be reachable by internal users.
- SSH access must be restricted.
- The app cannot expose unnecessary ports.
- The server must be documented.
- The build should be repeatable.
- Cost should stay low during the pilot.
- Security needs basic evidence of access controls.
- Operations wants a troubleshooting checklist.

### How the Class Topic Applies

This class teaches the foundation of that deployment:

- EC2 provides compute.
- AMI provides OS baseline.
- Instance type controls size and cost.
- EBS provides server disk.
- Security group controls access.
- User data makes setup repeatable.
- Linux commands validate the service.
- Troubleshooting confirms whether the issue is network, server, or application.

### What Each Role Would Do

| Role | Responsibility |
|---|---|
| DevOps Engineer | Automates server bootstrap and later adds CI/CD deployment |
| Cloud Engineer | Designs subnet, security group, IAM, and network access |
| SRE | Validates service health, monitoring, incident response, and runbook |
| Security Engineer | Reviews SSH exposure, IAM, patching, and audit controls |
| Application Team | Owns application code and runtime requirements |

### Enterprise Improvement Path

The pilot architecture may start with a public EC2 instance for learning, but production should move toward:

- Load balancer
- Private app servers
- Auto Scaling Group
- CloudWatch logs and alarms
- IAM role-based access
- SSM Session Manager
- Infrastructure as Code
- Patch management
- Backup and recovery plan

---

## 20. Instructor Tips

### Teaching Tips

- Keep the first explanation visual.
- Repeat that EC2 is compute, EBS is disk, and security group is firewall.
- Ask students to predict what will happen before testing the browser.
- Use failures as learning moments.
- Avoid going too deep into Auto Scaling or RDS in this class because Class 2 continues the architecture.

### Pacing Tips

- Do not spend more than 25 minutes on pure EC2 theory.
- Move to demo early so students see the full workflow.
- Reserve at least 35 minutes for student lab.
- Keep 15 minutes for troubleshooting.
- Use Class 2 for deeper storage, database, backup, and architecture tradeoffs.

### Lab Support Tips

When students get stuck, ask in this order:

1. What region are you in?
2. Is the instance running?
3. Does it have a public IP?
4. What subnet did you use?
5. What inbound security group rules exist?
6. Can you SSH?
7. Is httpd installed?
8. Is httpd running?
9. What does `curl localhost` return?
10. What does the cloud-init log say?

### Helping Struggling Students

Give them a simplified checklist:

```text
Instance running?
Public IP assigned?
Port 80 open?
SSH works?
httpd running?
curl localhost works?
Browser works?
```

### Challenging Advanced Students

Ask advanced students to:

- Use AWS CLI to inspect the instance
- Add tags to the EC2 instance
- Create a custom index page with metadata
- Explain how to move this behind an ALB
- Explain how Terraform would provision this later
- Compare public EC2 access vs SSM Session Manager

---

## 21. Student Outcome Checklist

### Students Should Be Able to Explain

- What EC2 is
- What an AMI is
- What an instance type is
- What a key pair is
- What EBS provides
- What user data does
- Why security groups matter
- Why an instance can be running but the app can still be down
- How public IP and private IP differ
- Why direct public SSH is risky

### Students Should Be Able to Build or Configure

- Launch an EC2 instance
- Select an AMI
- Select an instance type
- Configure a security group
- Enable public IP for a lab instance
- Add user data
- Connect using SSH
- Install and start Apache/httpd
- Create a basic web page
- Validate access from browser and terminal

### Students Should Be Able to Troubleshoot

- Browser timeout
- SSH connection timeout
- SSH permission denied
- Missing HTTP rule
- Failed user data
- Apache not running
- Wrong subnet
- No public IP
- Wrong region
- Missing or incorrect index.html

---

## 22. Class Completion Checklist

### Instructor Checklist Before Ending Class

Confirm:

- Students understand EC2, AMI, instance type, EBS, security group, and user data
- Students completed or observed successful EC2 launch
- Students understand HTTP port 80 and SSH port 22
- Students know how to check `systemctl status httpd`
- Students know how to inspect cloud-init logs
- Troubleshooting activity was reviewed
- Homework instructions were explained
- Cleanup expectations were clear
- Class 2 preview was given

### Student Checklist Before Leaving Class

Students should confirm:

- I launched an EC2 instance
- I selected an AMI and instance type
- I configured SSH and HTTP security group rules
- I used or reviewed user data
- I connected with SSH
- I validated Apache/httpd
- I loaded the web page in a browser
- I documented instance details
- I understand what to clean up
- I understand the homework

### Items to Verify Before Moving to Class 2

Before Class 2, students should understand:

- EC2 is compute
- EBS is attached block storage
- Security groups control access
- User data automates initial setup
- A web app can fail even when EC2 is running
- Basic AWS application architecture needs more than just compute

Class 2 can then build naturally into:

- S3 for object storage
- RDS for relational databases
- Snapshots and backups
- Auto Scaling concepts
- EC2, S3, and RDS architecture tradeoffs

---

## Class Artifacts & Validation

This class teaches EC2 compute manually (console/CLI). The runnable lab
[`labs/aws-storage-databases/`](../../labs/aws-storage-databases/) provides the
**Infrastructure-as-Code analog** of that workflow: a `t3.micro` instance with a
least-privilege instance profile and an encrypted root/EBS volume, expressed in
Terraform so it can be linted, validated, and security-scanned. The compute tier
is **gated behind `enable_compute` (default `false`)** so a default plan provisions
no billable EC2 — students read it as a reference for what they launched by hand.
All gates below were run in this environment; commands are run from
`labs/aws-storage-databases/`.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/aws-storage-databases/solution/main.tf | terraform | Gated EC2 `t3.micro` (IMDSv2 required, encrypted root) + least-privilege instance profile that reads S3/DynamoDB — the IaC form of the Class 1 manual launch | `terraform -chdir=solution validate` | PASS |
| 2 | labs/aws-storage-databases/solution/main.tf | terraform | `aws_ebs_volume.data` — encrypted gp3 8 GiB block storage (Class 1 "inspect your EBS" topic) | `terraform -chdir=solution validate` | PASS |
| 3 | labs/aws-storage-databases/solution/variables.tf | terraform | `enable_compute` toggle — keeps EC2 OFF by default so a default plan is ~$0 | `terraform -chdir=solution validate` | PASS |
| 4 | labs/aws-storage-databases/solution/ | terraform | Full module, security-scanned (IMDSv2, encryption-at-rest, no `*` IAM resources) | `checkov -d solution --compact --quiet` | PASS (46 passed, 0 failed, 9 documented skips) |
| 5 | labs/aws-storage-databases/tests/test_terraform_structure.py | python | Structural answer-key tests (asserts compute is `count`-gated, IMDSv2 required, instance role is least-privilege) | `python3 -m unittest discover -s tests` | PASS (18 tests) |
| 6 | labs/aws-storage-databases/validate.sh | shell | Runs every gate (fmt + validate + unittest + checkov) | `./validate.sh` | PASS (exit 0, 9/9 gates) |

> **Live status:** This is a **static-validated** lab. No `terraform apply` runs in
> this environment (no AWS credentials), and `labs/aws-storage-databases/LIVE-AWS-VALIDATION.txt`
> is currently **empty** — there is no captured live apply/destroy or running EC2.
> The manual EC2 launch in this class is done by students/instructors against a live
> AWS account; the Terraform compute tier above is validated statically only.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — the EC2/instance-profile/EBS Terraform lives in `labs/aws-storage-databases/solution/` (not just a fence). The console/CLI EC2 launch itself is a manual procedure with documented steps.
- [x] Each artifact passes its **validation gate** from §3 — `terraform validate` + `checkov` + unit tests all PASS; output captured above and in the lab README.
- [x] Lab has **starter** (S3 security blocks TODO'd) and **solution** (reference) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, and cost notes.
- [x] **Cleanup/teardown** is provided and idempotent — `terraform destroy` with `force_destroy` buckets; documented in README "Cleanup".
- [x] **Instructor answer key** exists — `solution/` plus `tests/test_terraform_structure.py` (18 reproducible checks) and the README "Instructor answer key" section.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `labs/aws-storage-databases/broken/` (a world-readable bucket that trips checkov; the EC2 web-app troubleshooting in §21 of this class is a separate manual fault list).
- [x] **Expected outputs** are shown — the EC2 launch/SSH/`systemctl status httpd` outputs in this class, plus `checkov`/`validate`/unittest outputs in the lab.
- [x] **Cost & security warnings** present — README "Cost considerations" (EC2 gated off because it bills while idle) and "Security considerations" (IMDSv2, least-privilege role).
- [x] **Cross-references** to the module repo and to prior/next weeks are correct (Weeks 2/4/5/6 prior; Weeks 8/9/10/14 next; verified).
- [x] The **artifact manifest** (§4.2) is present and every path resolves (`ls`-verified).
- [ ] **Not done — live op:** no live `terraform apply`/running EC2 captured; `LIVE-AWS-VALIDATION.txt` is empty. The lab is static-validated, not operated live in-repo.
