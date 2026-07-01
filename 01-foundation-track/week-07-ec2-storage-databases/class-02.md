# Week 7: EC2, Storage, and Databases
# Class 2 Package: AWS Storage, Databases, Backups, and Application Architecture

**Week:** 7
**Class:** 2
**Track:** Unified DevOps · Cloud · SRE Track

---

> **▶ Runnable lab for this class:** [`labs/aws-storage-databases/`](../../labs/aws-storage-databases/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## 1. Class Overview

### Class Title

**Class 2: AWS Storage, Databases, Backups, and Application Architecture**

### Class Purpose

This class builds on the EC2 web server from Class 1 and expands the architecture into a more realistic application pattern using **S3 for object storage**, **RDS for relational data**, **EBS snapshots for server disk recovery**, and **Auto Scaling concepts** for availability.

Students will learn that a real application rarely uses only one service. Compute, storage, database, networking, security, backup, and scaling decisions all work together.

### How This Class Builds From Class 1

In Class 1, students launched an EC2 instance and deployed a simple web server.

Class 2 extends that model:

```text
Class 1:
User -> EC2 Web Server -> EBS root volume

Class 2:
User -> EC2 Web Server
              |
              |-> S3 for files, static assets, logs, backups
              |
              |-> RDS for relational application data
              |
              |-> EBS snapshots for server disk recovery
              |
              |-> Auto Scaling concept for resilient compute
```

### What Students Will Build, Analyze, or Practice

Students will:

- Create and use an S3 bucket
- Upload and download objects using AWS CLI
- Understand object storage vs block storage vs relational databases
- Review RDS architecture without necessarily creating costly databases
- Analyze where EC2, EBS, S3, and RDS fit in an application
- Design a basic AWS application architecture
- Troubleshoot S3 access and RDS connectivity issues
- Document backup and recovery considerations

---

## 2. Quick Review of Class 1

### Review Points

1. **EC2 provides compute** for running virtual machines.
2. **AMI defines the starting operating system image** for an EC2 instance.
3. **Instance type controls CPU, memory, network, and cost profile.**
4. **EBS is the attached block storage** used as the EC2 root disk.
5. **Security groups control inbound and outbound network access.**
6. **User data automates first-boot setup**, such as installing Apache.
7. **An EC2 instance can be running while the application is still broken.**
8. **HTTP access requires a running web service and network access on port 80.**

### Quick Recall Questions

1. What is the difference between EC2 and EBS?
2. Why can an EC2 instance pass status checks while the web page still fails?
3. Which security group rule is needed for browser access to a basic HTTP web server?

### Common Gaps Students May Still Have From Class 1

| Gap | Instructor Bridge |
|---|---|
| Students may confuse EC2 and EBS | Remind them EC2 is compute, EBS is disk |
| Students may think S3 is another disk | Explain S3 is object storage, not attached block storage |
| Students may think all data belongs on EC2 | Explain separation of responsibilities |
| Students may not understand private databases | Connect back to public/private subnet discussion |
| Students may over-trust status checks | Reinforce infrastructure health vs application health |

### How the Instructor Should Bridge Into Class 2

Start with:

> “In Class 1, we built the server. Today we ask a bigger design question: where should the application store files, structured data, backups, and recovery points?”

Then show the progression:

```text
EC2 runs the application.
EBS supports the server disk.
S3 stores objects and files.
RDS stores relational business data.
Snapshots and backups support recovery.
Auto Scaling helps maintain compute capacity.
```

---

## 3. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** the difference between EBS, S3, and RDS.
2. **Configure** a basic S3 bucket for private object storage.
3. **Upload and download** files using AWS CLI.
4. **Compare** object storage, block storage, and relational database storage.
5. **Describe** the purpose of RDS, database endpoints, subnet groups, backups, and snapshots.
6. **Analyze** where application data should live in an AWS architecture.
7. **Troubleshoot** common S3 access and database connectivity issues.
8. **Document** a basic EC2, S3, and RDS application architecture.

---

## 4. Prerequisites Students Should Already Know

### Required Class 1 Knowledge

Students should understand:

- EC2 instance basics
- AMI and instance type
- Security groups
- Public IP and private IP
- EBS root volume
- SSH basics
- Apache/httpd validation
- User data startup script

### Required Prior Concepts

Students should already understand:

- VPC and subnet basics
- Public vs private subnet
- Security group inbound rules
- HTTP and ports
- AWS CLI v2 basics (Week 4)
- IAM, roles, and instance profiles from Week 6

### Required Tools Already Installed

Students need:

- AWS CLI
- Terminal
- Browser
- Text editor or VS Code
- SSH client, if continuing from Class 1 EC2 instance

### Required Files, Repos, Lab Outputs, or Setup From Class 1

Helpful Class 1 outputs:

- EC2 instance ID
- Public IP
- Security group ID
- Region
- Web server validation output
- Architecture diagram from homework or lab notes

Class 2 can be completed even if Class 1 EC2 was terminated, but the architecture discussion should reference it.

---

## 5. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| S3 | AWS object storage service | Used for static files, logs, backups, artifacts, uploads |
| Bucket | Top-level container in S3 | Similar to a storage namespace with a globally unique name |
| Object | A file stored in S3 | Could be an image, log, PDF, backup, artifact, or data export |
| Object key | The path/name of an object in S3 | Example: `uploads/report.pdf` |
| Versioning | S3 feature that keeps previous versions of objects | Helps recover from accidental overwrite or delete |
| Bucket policy | Resource-based permission policy for an S3 bucket | Controls who can access bucket data |
| Block storage | Storage that behaves like a disk | EBS is block storage for EC2 |
| Object storage | Storage for files as objects | S3 is object storage, not mounted like a normal server disk |
| Relational database | Database storing structured data in tables | Used for users, orders, transactions, inventory |
| RDS | AWS managed relational database service | AWS handles database infrastructure tasks |
| Database endpoint | DNS name used by apps to connect to RDS | Applications use this instead of an IP |
| Snapshot | Point-in-time backup of a disk or database | Used for recovery |
| Backup retention | How long backups are kept | Important for compliance and recovery |
| Auto Scaling Group | Group of EC2 instances managed automatically | Helps replace failed instances and adjust capacity |
| Launch template | Template used to launch EC2 instances consistently | Used by Auto Scaling Groups |
| Storage class | S3 tier balancing storage cost vs retrieval cost | Standard, Intelligent-Tiering, IA, Glacier |
| Lifecycle policy | Rule that transitions/expires S3 objects automatically | Major S3 cost lever; expires old versions |
| SSE-KMS | Server-side S3 encryption using KMS keys | Auditable, controllable encryption (Week 6 KMS) |
| DynamoDB | Serverless NoSQL key-value/document database | Hot key lookups, sessions, carts at massive scale |
| EFS | Managed shared NFS filesystem across instances/AZs | Shared POSIX mount when S3 will not do |
| Instance profile | Lets EC2 assume an IAM role for keyless AWS access | How EC2 writes to S3 without keys |

---

## 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| AWS Console | Create and inspect S3, review RDS, snapshots, and Auto Scaling concepts |
| AWS CLI | Create buckets, upload files, list objects, download objects |
| Terminal | Run CLI commands |
| Browser | View AWS Console and optional S3 object behavior |
| Text editor or VS Code | Create sample files and architecture notes |
| curl, optional | Validate Class 1 EC2 web server if still running |
| Diagrams | Explain EC2, S3, RDS, and backup architecture |

---

## 7. AWS Services Used

| AWS Service | How It Connects to Class 2 |
|---|---|
| S3 | Stores objects such as static files, logs, backups, uploads, and artifacts; storage classes, lifecycle, SSE-KMS |
| EC2 | Represents the compute layer from Class 1 |
| EBS | Provides server disk storage and supports snapshots |
| EFS | Provides a shared NFS filesystem mountable by many instances across AZs |
| RDS | Provides managed relational database service (provisioned and connected in this class) |
| DynamoDB | Serverless NoSQL key-value/document database |
| Secrets Manager | Stores the RDS master password via `--manage-master-user-password` |
| IAM | Controls access to S3 and other AWS services via the EC2 instance profile |
| VPC | Provides networking boundary for EC2 and RDS |
| Security Groups | Controls EC2 and RDS connectivity |
| Auto Scaling | Introduces the concept of resilient compute capacity |
| CloudWatch, preview | Used later for logs, metrics, and alarms |
| AWS Backup, preview | Introduces centralized backup management |

---

## 8. Azure and GCP Comparison Notes

| AWS | Azure | GCP | Practical Meaning |
|---|---|---|---|
| S3 | Blob Storage | Cloud Storage | Object storage for files and unstructured data |
| EBS | Managed Disk | Persistent Disk | Block storage attached to virtual machines |
| RDS | Azure SQL or Azure Database for PostgreSQL | Cloud SQL | Managed relational database |
| EC2 | Azure VM | Compute Engine | Virtual server compute |
| Auto Scaling Group | Virtual Machine Scale Sets | Managed Instance Groups | Automatically manage VM capacity |

Instructor note:

Keep the comparison short. The main goal is for students to understand the pattern:

```text
Compute + Block Storage + Object Storage + Managed Database
```

This pattern exists across AWS, Azure, and GCP.

---

## 9. Time-Boxed Instructor Agenda

| Time | Section | Instructor Activity | Student Activity |
|---:|---|---|---|
| 0:00 to 0:15 | Class 1 review | Review EC2, EBS, user data, security groups | Answer recall questions |
| 0:15 to 0:40 | S3 fundamentals | Teach buckets, objects, keys, permissions, versioning | Take notes and ask questions |
| 0:40 to 1:05 | EBS vs S3 vs RDS | Compare storage types and use cases | Categorize sample data types |
| 1:05 to 1:25 | RDS fundamentals + DynamoDB intro | Teach managed DB concepts, endpoints, backups, subnet groups; relational vs NoSQL; optional RDS hands-on if budget allows | Review architecture examples / provision RDS |
| 1:25 to 1:35 | Break | Short break | Short break |
| 1:35 to 1:55 | Backups and snapshots | Explain EBS snapshots, RDS snapshots, S3 versioning | Identify recovery scenarios |
| 1:55 to 2:10 | Auto Scaling overview | Explain desired, min, max, launch template, health checks | Discuss resilience |
| 2:10 to 2:40 | Student lab | Guide students through S3 CLI lab and architecture mapping | Complete hands-on lab |
| 2:40 to 2:55 | Troubleshooting activity | Present S3 and RDS access failure scenario | Investigate and propose fix |
| 2:55 to 3:00 | Recap | Summarize Week 7 and assign homework | Confirm cleanup and next steps |

---

## 10. Instructor Lesson Plan

### Step 1: Open With Continuity From Class 1

Say:

> “Last class, we launched an EC2 instance and made it serve a simple web page. Today we ask: where should that application store files, relational data, and recovery backups?”

Show:

```text
EC2 = compute
EBS = server disk
S3 = object storage
RDS = managed relational database
```

Pause and ask:

- Should uploaded user files be stored only on the EC2 root disk?
- Should customer records be stored in flat files?
- What happens if the EC2 instance is terminated?

---

### Step 2: Teach S3 Fundamentals

Explain:

- S3 is object storage.
- S3 is not a normal Linux disk.
- S3 buckets must have globally unique names.
- Objects are stored using keys.
- S3 is commonly private by default.
- Access is controlled by IAM and bucket policies.
- Versioning can help recover from accidental changes.

Talking point:

> “S3 is where we put durable objects, not where we run applications.”

Show examples:

```text
Good S3 use cases:
- images
- logs
- backups
- static assets
- reports
- build artifacts

Poor S3 use cases:
- running an operating system
- storing active relational transactions
- replacing a database
```

---

### Step 3: Compare EBS, S3, and RDS

Draw a comparison table.

| Requirement | Best Fit |
|---|---|
| Linux root disk | EBS |
| Uploaded PDF files | S3 |
| Customer records | RDS |
| Static images | S3 |
| Database backup | RDS snapshot or AWS Backup |
| Web server runtime | EC2 |
| App logs | CloudWatch or S3 |

Pause and ask:

> “Where would you store an uploaded invoice PDF? Where would you store the invoice total, customer ID, and payment status?”

Expected answer:

- PDF file goes to S3.
- Structured invoice metadata goes to RDS.

---

### Step 4: Teach RDS Fundamentals

Explain:

RDS is AWS managed relational database service. Instead of manually installing PostgreSQL or MySQL on EC2, teams can use RDS and let AWS handle many operational tasks.

RDS helps with:

- Database provisioning
- Backups
- Snapshots
- Patching options
- Monitoring integration
- Multi-AZ option
- Database endpoint
- Managed storage

Important beginner point:

> “RDS is still your database. AWS manages the infrastructure, but your team still owns schema, queries, access, performance, and data safety decisions.”

---

### Step 5: Explain Backups and Recovery

Connect to Class 1:

- EC2 had EBS root volume.
- EBS can have snapshots.
- RDS can have automated backups and snapshots.
- S3 can use versioning.
- Backups must be tested.

Use this phrase:

> “A backup that has never been tested is only a hope, not a recovery plan.”

Explain basic recovery examples:

| Problem | Recovery Option |
|---|---|
| EC2 disk corrupted | EBS snapshot |
| Database accidentally changed | RDS snapshot or point-in-time restore |
| S3 object overwritten | S3 versioning |
| Region outage | Cross-region backup or replication strategy |

---

### Step 6: Explain Auto Scaling at a Beginner Level

Do not go too deep yet.

Explain:

- Auto Scaling does not fix bad code.
- Auto Scaling helps maintain compute capacity.
- It can replace unhealthy EC2 instances.
- It uses launch templates.
- It has min, desired, and max capacity.
- It is commonly used behind a load balancer.

Talking point:

> “One EC2 instance is simple, but it is also a single point of failure. Auto Scaling is one way AWS helps us move toward resilience.”

---

### Step 7: Instructor Demo

Perform S3 demo:

- Create bucket
- Upload object
- List object
- Download object
- Explain private access
- Optional versioning

Then RDS walkthrough:

- Show database engines
- Show public access setting
- Show subnet group
- Show security group
- Show backup retention
- Show snapshots

Do not create RDS unless the classroom sandbox allows cost.

---

### Step 8: Student Lab

Students create S3 bucket and upload/download objects using AWS CLI.

They also create an architecture diagram showing how EC2, EBS, S3, and RDS work together.

---

### Step 9: Troubleshooting Activity

Present:

> “The web page loads, but file uploads fail with S3 access denied. Database connection also times out.”

Students identify:

- IAM/S3 access issue
- RDS network/security group issue

---

### Step 10: Close the Week

Summarize:

- EC2 runs compute.
- EBS is server disk.
- S3 stores objects.
- RDS stores structured relational data.
- Backups and snapshots support recovery.
- Auto Scaling supports compute resilience.

Preview Week 8:

> "Next week, we start automating operational work with Bash and Python scripting."

---

## 11. Instructor Lecture Notes

### S3 Lecture Notes

S3 is one of the most common AWS services students will see in real jobs. It is used by DevOps teams, cloud engineers, data teams, application teams, security teams, and SRE teams.

S3 is not attached to one server. It is accessed over APIs. That makes it different from EBS, which behaves like a disk attached to EC2.

Say:

> “EBS is like a hard drive attached to one server. S3 is like a highly durable storage service for objects that applications and users can access through APIs.”

Common S3 use cases:

- Application uploads
- Static website assets
- Logs
- Backups
- Data exports
- CI/CD artifacts
- Terraform state storage later in the course

Common misconception:

Students may think making a file available means making the bucket public. Correct this early.

Say:

> “Private by default is the safe mindset. Public access should be intentional, reviewed, and justified.”

---

### EBS vs S3 Lecture Notes

EBS and S3 are both storage, but they solve different problems.

EBS is for server-attached storage. It is useful when the operating system or application needs disk-like behavior.

S3 is for objects. It is better for files that do not need to behave like a mounted operating system disk.

Example:

- The web server package and OS files live on EBS.
- Uploaded images or PDF files should go to S3.
- Customer records should go to a database such as RDS.

Say:

> “Do not store everything on the EC2 instance just because it is easy. That creates backup, scaling, and recovery problems.”

#### When you need a shared filesystem: EFS (and FSx)

EBS attaches to **one** instance in **one** AZ. So if an Auto Scaling Group replaces an instance, anything written to that instance's local/EBS disk is gone — and a second instance cannot read the first instance's EBS volume. This is the exact problem behind "what if ASG replaces the instance and the uploads were on local disk?"

Three answers, in order of preference:

- **S3** — best for application uploads/objects; durable, decoupled from any instance. This is usually the right answer.
- **Amazon EFS** — a managed NFS filesystem that **many EC2 instances across AZs can mount at the same time**. Use it when an app genuinely needs POSIX shared files (e.g. a legacy app expecting a shared mount, shared media, CMS content).
- **Amazon FSx** — managed Windows File Server / Lustre / NetApp ONTAP for Windows or HPC workloads.

```text
EBS  = one instance, one AZ, block disk
EFS  = many instances, multi-AZ, shared NFS filesystem
S3   = object storage via API, the default for uploads
FSx  = managed Windows/Lustre/ONTAP filesystems
```

> Rule of thumb: uploads and artifacts → S3. A truly shared POSIX mount across instances → EFS. Never rely on a single instance's local disk for data that must survive instance replacement.

---

### RDS Lecture Notes

RDS is AWS managed database service for relational databases.

Supported engines include:

- MySQL
- PostgreSQL
- MariaDB
- Oracle
- SQL Server
- Amazon Aurora

For beginner students, focus on concepts instead of database administration depth.

Key concepts:

- Database endpoint
- Database port
- Security group
- Private subnet
- Backup retention
- Snapshots
- Multi-AZ
- Storage autoscaling
- Maintenance windows

Say:

> “RDS reduces infrastructure management, but it does not remove database responsibility. Teams still need to manage users, schema, performance, backups, and application connectivity.”

---

### Backups and Snapshots Lecture Notes

Backups are not only a technical topic. They are a business continuity topic.

Explain:

- EBS snapshots protect disk state.
- RDS snapshots protect database state.
- S3 versioning protects object versions.
- AWS Backup can centralize backup management.
- Backups should align with recovery goals.

Introduce two terms lightly:

| Term | Meaning |
|---|---|
| RTO | How quickly the service must be restored |
| RPO | How much data loss is acceptable |

Say:

> “If the business says we can lose only 15 minutes of data, the backup strategy must support that requirement.”

---

### Auto Scaling Lecture Notes

Auto Scaling helps with EC2 availability and capacity.

Basic terms:

- Minimum capacity: lowest number of instances
- Desired capacity: target number of instances
- Maximum capacity: upper limit
- Launch template: how to create new instances
- Health check: determines whether instances are healthy

Say:

> “Auto Scaling is not magic. It does not fix broken AMIs, bad user data, missing dependencies, or database bottlenecks.”

Common misconception:

Students may think Auto Scaling means the whole application is highly available. Clarify that scaling compute is only one part of availability. Databases, load balancers, DNS, networking, and application design also matter.

---

## 12. Whiteboard Explanation

### How Class 2 Extends Class 1

```text
Class 1 Architecture:

User Browser
    |
    v
EC2 Web Server
    |
    v
EBS Root Volume
```

Class 2 adds storage and database responsibilities:

```text
Class 2 Architecture:

User Browser
    |
    v
EC2 Web Server
    |
    |-- Uses EBS for OS and local server disk
    |
    |-- Stores uploaded files in S3
    |
    |-- Reads/writes structured data in RDS
    |
    |-- Sends logs/metrics to monitoring later
```

### Simple Application Diagram

```text
Users
  |
  v
EC2 Web Server
  |
  | stores server files
  v
EBS Root Volume

EC2 Web Server
  |
  | uploads/downloads files
  v
S3 Bucket

EC2 Web Server
  |
  | database connection on DB port
  v
RDS Database
```

### More Realistic Enterprise Diagram

```text
Users
  |
  v
Route 53 DNS
  |
  v
Application Load Balancer
  |
  v
EC2 Auto Scaling Group
Private App Subnets
  |
  | stores objects
  v
Private S3 Bucket

EC2 App Layer
  |
  | connects on database port
  v
RDS Database
Private Database Subnets

Operations:
- EBS snapshots
- RDS automated backups
- S3 versioning
- CloudWatch logs and metrics
- IAM role-based access
```

### Step-by-Step Flow

1. User sends a request to the application.
2. EC2 runs the application code.
3. EBS supports the EC2 operating system and local disk.
4. If the user uploads a document, the app stores it in S3.
5. If the app saves user or transaction data, it stores it in RDS.
6. Backups and snapshots protect recovery points.
7. Auto Scaling can replace unhealthy EC2 instances or add capacity.

### What Each Component Means

| Component | Meaning |
|---|---|
| EC2 | Runs application logic |
| EBS | Supports the server disk |
| S3 | Stores durable objects and files |
| RDS | Stores relational business data |
| Security Group | Controls allowed network traffic |
| IAM Role | Allows EC2 or users to access AWS services securely |
| Snapshot | Recovery point |
| Auto Scaling | Maintains compute capacity |

---

## 13. Instructor Demo Script

### Demo Title

**Using S3 for Object Storage and Reviewing RDS Application Architecture**

### Demo Objective

Show how an EC2-based application can use S3 for file storage and RDS for structured relational data.

### Required Setup

Instructor needs:

- AWS account or sandbox
- AWS CLI configured
- Permission to create S3 bucket
- Permission to list and upload S3 objects
- Access to RDS console for walkthrough
- Optional running EC2 instance from Class 1
- Region selected, for example `us-east-1`

---

### Part 1: Create a Local Sample File

Run:

```bash
mkdir -p week7-class2-demo
cd week7-class2-demo

cat > app-upload-sample.txt <<'EOF'
This is a sample file that represents an application upload.
In a real application, this could be a PDF, image, report, or log file.
EOF
```

Expected:

```bash
ls -l
```

```text
app-upload-sample.txt
```

Explain:

> “This file represents something the application might need to store outside the EC2 instance.”

---

### Part 2: Create an S3 Bucket

Set a unique bucket name:

```bash
export AWS_REGION=us-east-1
export BUCKET_NAME=week7-class2-demo-$RANDOM-$RANDOM
echo $BUCKET_NAME
```

Create bucket:

```bash
aws s3 mb s3://$BUCKET_NAME --region $AWS_REGION
```

Expected:

```text
make_bucket: week7-class2-demo-12345-67890
```

Explain:

> “S3 bucket names are globally unique. That means nobody else in AWS can already be using the same bucket name.”

---

### Part 3: Upload Object to S3

Run:

```bash
aws s3 cp app-upload-sample.txt s3://$BUCKET_NAME/uploads/app-upload-sample.txt
```

Expected:

```text
upload: ./app-upload-sample.txt to s3://week7-class2-demo-xxxxx/uploads/app-upload-sample.txt
```

List objects:

```bash
aws s3 ls s3://$BUCKET_NAME/uploads/
```

Expected:

```text
app-upload-sample.txt
```

Explain:

> “The object key is `uploads/app-upload-sample.txt`. S3 keys often look like folders, but S3 is object storage.”

---

### Part 4: Download Object From S3

Run:

```bash
aws s3 cp s3://$BUCKET_NAME/uploads/app-upload-sample.txt downloaded-sample.txt
cat downloaded-sample.txt
```

Expected:

```text
This is a sample file that represents an application upload.
In a real application, this could be a PDF, image, report, or log file.
```

Explain:

> “This proves we can put objects into S3 and retrieve them later.”

---

### Part 5: Show Bucket Security

Console actions:

1. Open S3 console.
2. Open the bucket.
3. Show **Objects** tab.
4. Show **Permissions** tab.
5. Point out Block Public Access.

Explain:

> “For most enterprise workloads, buckets should stay private unless there is a specific approved public access pattern.”

---

### Part 6: Optional Versioning Demo

Enable versioning:

```bash
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled
```

Modify file:

```bash
echo "Second version of this file" >> app-upload-sample.txt
aws s3 cp app-upload-sample.txt s3://$BUCKET_NAME/uploads/app-upload-sample.txt
```

List versions:

```bash
aws s3api list-object-versions \
  --bucket $BUCKET_NAME \
  --prefix uploads/app-upload-sample.txt \
  --query "Versions[*].[Key,VersionId,IsLatest,LastModified]" \
  --output table
```

Explain:

> “Versioning helps recover from accidental overwrites, but it can increase storage cost if not managed.”

---

### Part 6b: Storage Classes, Lifecycle, and SSE-KMS Encryption

These are the two biggest senior levers on S3: **cost** (storage class + lifecycle) and **security** (encryption).

**Storage classes** trade retrieval speed/cost against storage cost:

| Class | Use | Note |
|---|---|---|
| S3 Standard | Hot, frequently accessed | Default |
| S3 Intelligent-Tiering | Unknown/changing access | Auto-moves objects between tiers; great default for mixed workloads |
| S3 Standard-IA / One Zone-IA | Infrequent access | Cheaper storage, retrieval fee |
| S3 Glacier Instant / Flexible / Deep Archive | Archive | Cheapest storage, longest/most-costly retrieval |

**Lifecycle policy** — automatically transition old objects to cheaper classes and expire noncurrent versions (controls the versioning cost risk above):

```bash
cat > lifecycle.json <<'EOF'
{
  "Rules": [
    {
      "ID": "archive-and-expire",
      "Filter": { "Prefix": "uploads/" },
      "Status": "Enabled",
      "Transitions": [
        { "Days": 30, "StorageClass": "STANDARD_IA" },
        { "Days": 90, "StorageClass": "GLACIER" }
      ],
      "NoncurrentVersionExpiration": { "NoncurrentDays": 30 }
    }
  ]
}
EOF

aws s3api put-bucket-lifecycle-configuration \
  --bucket $BUCKET_NAME \
  --lifecycle-configuration file://lifecycle.json

aws s3api get-bucket-lifecycle-configuration --bucket $BUCKET_NAME
```

**Default encryption with SSE-KMS** — encrypt every new object with a KMS key (ties back to Week 6 KMS):

```bash
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "alias/aws/s3"
      },
      "BucketKeyEnabled": true
    }]
  }'
```

Explain:

> "SSE-S3 (`AES256`) is the zero-config default. SSE-KMS adds auditable, controllable keys via CloudTrail and key policies. `BucketKeyEnabled` cuts KMS request costs. Use SSE-KMS when compliance requires key control."

Note for the troubleshooting scenario later: if a bucket enforces SSE-KMS, the EC2 role also needs `kms:GenerateDataKey` on the key, or `PutObject` fails with `AccessDenied` even when `s3:PutObject` is granted.

---

### Part 6c: Make the Instance Profile Real — EC2 Writes to S3 End-to-End

In Class 1 we created the `week7-ec2-ssm-s3` instance profile. Now we attach a **least-privilege** policy scoped to this bucket and prove the EC2 instance can write to S3 with no keys on disk. This closes the loop the troubleshooting scenario assumes.

Attach the inline policy to the role (run from your laptop):

```bash
cat > s3-write.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject"],
      "Resource": "arn:aws:s3:::$BUCKET_NAME/uploads/*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::$BUCKET_NAME",
      "Condition": { "StringLike": { "s3:prefix": "uploads/*" } }
    }
  ]
}
EOF

aws iam put-role-policy \
  --role-name week7-ec2-ssm-s3 \
  --policy-name week7-s3-uploads-rw \
  --policy-document file://s3-write.json
```

Now connect to the Class 1 instance via SSM and write to S3 using only the instance role:

```bash
# From your laptop
aws ssm start-session --target i-0123456789abcdef0

# Now inside the instance (no aws configure, no keys):
echo "Uploaded from EC2 via the instance profile" > /tmp/from-ec2.txt
aws s3 cp /tmp/from-ec2.txt s3://YOUR_BUCKET_NAME/uploads/from-ec2.txt
aws s3 ls s3://YOUR_BUCKET_NAME/uploads/
aws sts get-caller-identity   # shows assumed-role/week7-ec2-ssm-s3/...
```

Expected: the upload succeeds and `get-caller-identity` shows the assumed role, not a user. This is exactly the pattern that, when the policy is missing, produces the `AccessDenied` in the Section 15 incident.

Teaching point:

> No access keys ever existed. EC2 pulled temporary, auto-rotating credentials from IMDSv2 because the instance profile was attached. This is the production pattern for EC2-to-AWS access.

---

### Part 6d: DynamoDB / NoSQL Intro and the Relational-vs-NoSQL Decision

S3 (objects) and RDS (relational) are not the only data stores. **DynamoDB** is AWS's serverless NoSQL key-value/document database — a frequent senior interview topic.

| Dimension | RDS (relational) | DynamoDB (NoSQL) |
|---|---|---|
| Data model | Tables, rows, foreign keys, JOINs | Items keyed by partition (+ sort) key |
| Query | Flexible SQL, ad-hoc joins | Key/index access designed up front |
| Scale | Vertical + read replicas | Horizontal, virtually unlimited, single-digit-ms |
| Schema | Fixed schema | Schema-flexible per item |
| Best for | Transactions, complex relationships, reporting | High-throughput key lookups, sessions, carts, event/IoT data |
| Ops model | You size instances | Serverless, on-demand or provisioned capacity |

Quick hands-on (DynamoDB on-demand has no idle cost):

```bash
aws dynamodb create-table \
  --table-name week7-sessions \
  --attribute-definitions AttributeName=sessionId,AttributeType=S \
  --key-schema AttributeName=sessionId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

aws dynamodb put-item --table-name week7-sessions \
  --item '{"sessionId": {"S": "abc123"}, "user": {"S": "jdoe"}}'

aws dynamodb get-item --table-name week7-sessions \
  --key '{"sessionId": {"S": "abc123"}}'

# Cleanup
aws dynamodb delete-table --table-name week7-sessions
```

Decision rule of thumb:

> Reach for **RDS** when you need joins, transactions, and ad-hoc queries over related data. Reach for **DynamoDB** when access patterns are known, predictable, and need massive scale with low latency. Many real systems use both: RDS for the system of record, DynamoDB for hot key-value paths.

---

### Part 7: RDS Hands-On — Provision and Connect

> Cost warning: a `db.t3.micro` single-AZ PostgreSQL instance is free-tier eligible for new accounts (750 hrs/month for the first 12 months) and otherwise a few cents/hour. **Aurora Serverless v2** can scale to a low minimum ACU. Confirm your sandbox allows the cost, and DELETE the database at the end. Skip Multi-AZ for the lab to control cost.

This is the lab that makes the week end-to-end real: provision RDS in private subnets and connect to it from the Class 1 EC2 instance.

#### Step 7.1: Create a DB subnet group (two private subnets)

```bash
aws rds create-db-subnet-group \
  --db-subnet-group-name week7-db-subnets \
  --db-subnet-group-description "Week 7 lab private DB subnets" \
  --subnet-ids subnet-aaaa1111 subnet-bbbb2222
```

#### Step 7.2: Create an RDS security group that only allows the EC2 SG

```bash
# DB_SG = the RDS security group; APP_SG = the Class 1 EC2 security group
aws ec2 authorize-security-group-ingress \
  --group-id $DB_SG \
  --protocol tcp --port 5432 \
  --source-group $APP_SG
```

> Source the rule from the **EC2 security group**, never `0.0.0.0/0`. This is the "SG references, not CIDR" pattern.

#### Step 7.3: Create the database (not publicly accessible)

```bash
aws rds create-db-instance \
  --db-instance-identifier week7-appdb \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --allocated-storage 20 \
  --storage-type gp3 \
  --storage-encrypted \
  --master-username appadmin \
  --manage-master-user-password \
  --db-subnet-group-name week7-db-subnets \
  --vpc-security-group-ids $DB_SG \
  --no-publicly-accessible \
  --backup-retention-period 1

aws rds wait db-instance-available --db-instance-identifier week7-appdb
```

> `--manage-master-user-password` stores the password in Secrets Manager (ties to Week 6) instead of putting it on the command line. `--storage-encrypted` is the senior default. Retrieve the endpoint:

```bash
aws rds describe-db-instances --db-instance-identifier week7-appdb \
  --query "DBInstances[0].Endpoint.Address" --output text
```

#### Step 7.4: Retrieve the managed password from Secrets Manager

`--manage-master-user-password` created a secret named like `rds!db-xxxxxxxx`. Find it and read the password **from your laptop** (which already has admin credentials — we deliberately do *not* grant the EC2 role `secretsmanager:GetSecretValue`, keeping its instance profile scoped to S3 only):

```bash
# Find the secret ARN RDS created for this instance
SECRET_ARN=$(aws rds describe-db-instances \
  --db-instance-identifier week7-appdb \
  --query "DBInstances[0].MasterUserSecret.SecretArn" --output text)

# Read the password (the value is JSON: {"username":"appadmin","password":"..."})
aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --query "SecretString" --output text
```

> Alternatively, open the secret in the **Secrets Manager console** and click **Retrieve secret value**. In real systems the app would read this at runtime via its own scoped role — never paste DB passwords into shell history.

#### Step 7.5: Connect from the Class 1 EC2 instance

```bash
# On the EC2 instance (reached via SSM):
sudo dnf install -y postgresql15

psql "host=week7-appdb.xxxx.us-east-1.rds.amazonaws.com port=5432 user=appadmin dbname=postgres"
# Enter the password retrieved in Step 7.4 when prompted, then:
#   CREATE TABLE invoices (id serial PRIMARY KEY, total numeric, customer_id int);
#   INSERT INTO invoices (total, customer_id) VALUES (42.50, 1001);
#   SELECT * FROM invoices;
#   \q
```

Expected: the connection succeeds **only because** the RDS SG allows the EC2 SG on 5432. If you forget that rule, you get a timeout — exactly the Section 15 incident.

#### Step 7.6: Snapshot and point-in-time restore awareness

```bash
# Manual snapshot
aws rds create-db-snapshot \
  --db-instance-identifier week7-appdb \
  --db-snapshot-identifier week7-appdb-manual-1
```

Automated backups (retention set above) enable point-in-time restore to any second within the window via **Restore to point in time** in the console.

#### Step 7.7: Cleanup (do this — RDS bills hourly)

```bash
aws rds delete-db-instance \
  --db-instance-identifier week7-appdb \
  --skip-final-snapshot
aws rds wait db-instance-deleted --db-instance-identifier week7-appdb
aws rds delete-db-snapshot --db-snapshot-identifier week7-appdb-manual-1
aws rds delete-db-subnet-group --db-subnet-group-name week7-db-subnets
```

> Verify in the console that the instance is gone. A forgotten RDS instance is one of the most common surprise bills.

---

### Part 7b: RDS Console Walkthrough (conceptual reference)

If the sandbox does not allow RDS cost, use the console walkthrough instead of the hands-on above.

Console walkthrough:

1. Open RDS.
2. Click **Create database**.
3. Show engine options:
   - PostgreSQL
   - MySQL
   - MariaDB
   - SQL Server
   - Oracle
   - Aurora (including Aurora Serverless v2)
4. Show DB instance class.
5. Show storage.
6. Show connectivity:
   - VPC
   - DB subnet group
   - Public access setting
   - Security group
7. Show backup retention.
8. Show snapshots area.

Explain:

> “Most production databases should not be publicly accessible. Applications usually connect from private subnets or controlled network paths.”

---

### Part 8: Auto Scaling Console Walkthrough

Console actions:

1. Open EC2.
2. Open **Launch Templates**.
3. Open **Auto Scaling Groups**.
4. Explain desired, minimum, and maximum capacity.

Do not create resources unless approved.

Explain:

> “An Auto Scaling Group can create replacement EC2 instances when one becomes unhealthy, but only if the launch template and application bootstrap are correct.”

---

### Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| Bucket name already exists | S3 names are global | Generate a more unique name |
| Access denied on `aws s3 mb` | Missing IAM permissions | Use approved classroom role or ask instructor |
| Wrong region confusion | CLI and console differ | Confirm `aws configure get region` |
| Versioned bucket cleanup fails | Object versions still exist | Delete versions before deleting bucket |
| RDS creation screen differs | Console UI changes | Focus on concepts, not exact button names |
| Students ask why object URL fails | Object is private | Explain private bucket access |

---

### Cleanup Steps

If versioning was not enabled:

```bash
aws s3 rm s3://$BUCKET_NAME/uploads/app-upload-sample.txt
aws s3 rb s3://$BUCKET_NAME
rm -rf week7-class2-demo
```

If versioning was enabled, use:

```bash
aws s3api delete-objects \
  --bucket $BUCKET_NAME \
  --delete "$(aws s3api list-object-versions \
    --bucket $BUCKET_NAME \
    --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"
```

Then delete delete markers if present:

```bash
aws s3api delete-objects \
  --bucket $BUCKET_NAME \
  --delete "$(aws s3api list-object-versions \
    --bucket $BUCKET_NAME \
    --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"
```

Then remove bucket:

```bash
aws s3 rb s3://$BUCKET_NAME
```

Cost warning:

> “S3 is low-cost for small files, but forgotten buckets, old versions, logs, and backups can create long-term cost.”

---

## 14. Student Lab Manual

### Lab Title

**Use S3 Object Storage and Design an EC2, S3, and RDS Application Architecture**

### Lab Objective

Students will create an S3 bucket, upload and download files, validate object storage behavior, and design a simple AWS application architecture using EC2, EBS, S3, and RDS.

### Estimated Time

35 to 45 minutes

### Student Prerequisites

Students should have:

- AWS CLI configured
- AWS Console access
- Permission to create and delete S3 buckets
- Week 7 Class 1 EC2 notes (including the `week7-ec2-ssm-s3` instance profile)
- Understanding of EC2, EBS, security groups, and public IP

### Starting Point From Class 1

You may use your Class 1 EC2 web server as the compute layer in your architecture diagram.

You do not need to keep the EC2 instance running for the S3 lab unless your instructor says so.

---

### Architecture Overview

```text
EC2 Web Server
  |
  | uses EBS for OS and local files
  |
  | uploads/downloads objects
  v
S3 Bucket

EC2 Web Server
  |
  | connects using database endpoint
  v
RDS Database
```

---

### Step 1: Confirm AWS CLI Region

Run:

```bash
aws configure get region
```

Expected example:

```text
us-east-1
```

If empty, set your region:

```bash
aws configure set region us-east-1
```

---

### Step 2: Create a Lab Folder

```bash
mkdir -p week7-class2-lab
cd week7-class2-lab
```

Create a sample file:

```bash
cat > student-upload.txt <<'EOF'
This file represents an application upload for Week 7 Class 2.
It should be stored in S3, not only on the EC2 server disk.
EOF
```

Validate:

```bash
cat student-upload.txt
```

Expected:

```text
This file represents an application upload for Week 7 Class 2.
It should be stored in S3, not only on the EC2 server disk.
```

---

### Step 3: Create a Unique S3 Bucket

Set variables:

```bash
export AWS_REGION=$(aws configure get region)
export BUCKET_NAME=week7-class2-lab-$RANDOM-$RANDOM
echo $BUCKET_NAME
```

Create bucket:

```bash
aws s3 mb s3://$BUCKET_NAME --region $AWS_REGION
```

Expected:

```text
make_bucket: week7-class2-lab-xxxxx-yyyyy
```

If your region is not `us-east-1` and the command fails, ask your instructor for the correct region-specific command.

---

### Step 4: Upload the File

```bash
aws s3 cp student-upload.txt s3://$BUCKET_NAME/uploads/student-upload.txt
```

Expected:

```text
upload: ./student-upload.txt to s3://week7-class2-lab-xxxxx/uploads/student-upload.txt
```

---

### Step 5: List Objects

```bash
aws s3 ls s3://$BUCKET_NAME/
aws s3 ls s3://$BUCKET_NAME/uploads/
```

Expected:

```text
student-upload.txt
```

---

### Step 6: Download the File

```bash
aws s3 cp s3://$BUCKET_NAME/uploads/student-upload.txt downloaded-student-upload.txt
cat downloaded-student-upload.txt
```

Expected output should match your original file.

---

### Step 7: Validate Bucket Is Not Public

In AWS Console:

1. Go to S3.
2. Open your bucket.
3. Select **Permissions**.
4. Confirm **Block Public Access** is enabled.

Write down:

```text
Is Block Public Access enabled? Yes or No
```

Expected answer:

```text
Yes
```

Security warning:

Do not make the bucket public unless explicitly instructed.

---

### Step 8: Optional Versioning

Enable versioning:

```bash
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled
```

Modify and re-upload:

```bash
echo "Second version added during lab." >> student-upload.txt
aws s3 cp student-upload.txt s3://$BUCKET_NAME/uploads/student-upload.txt
```

List versions:

```bash
aws s3api list-object-versions \
  --bucket $BUCKET_NAME \
  --prefix uploads/student-upload.txt \
  --output table
```

---

### Step 8b: Add a Lifecycle Rule (cost lever)

Tell S3 to expire noncurrent versions and archive old objects automatically:

```bash
cat > lifecycle.json <<'EOF'
{
  "Rules": [{
    "ID": "expire-old-versions",
    "Filter": { "Prefix": "uploads/" },
    "Status": "Enabled",
    "Transitions": [{ "Days": 30, "StorageClass": "STANDARD_IA" }],
    "NoncurrentVersionExpiration": { "NoncurrentDays": 30 }
  }]
}
EOF

aws s3api put-bucket-lifecycle-configuration \
  --bucket $BUCKET_NAME --lifecycle-configuration file://lifecycle.json
aws s3api get-bucket-lifecycle-configuration --bucket $BUCKET_NAME
```

This directly controls the cost risk of versioning: old versions are removed after 30 days instead of accumulating forever.

---

### Step 8c (optional, requires running Class 1 EC2): Write to S3 From EC2 With No Keys

This proves the instance profile from Class 1 actually works end-to-end. Requires the `week7-ec2-ssm-s3` role with the `week7-s3-uploads-rw` policy (added in the instructor demo) attached to a running instance.

```bash
# From your laptop, open a keyless shell
aws ssm start-session --target i-0123456789abcdef0

# Inside the instance — note: no aws configure, no keys
echo "Written from EC2 via instance profile" > /tmp/from-ec2.txt
aws s3 cp /tmp/from-ec2.txt s3://YOUR_BUCKET_NAME/uploads/from-ec2.txt
aws s3 ls s3://YOUR_BUCKET_NAME/uploads/
aws sts get-caller-identity   # expect assumed-role/week7-ec2-ssm-s3/...
```

If the upload returns `AccessDenied`, the role is missing the S3 policy (or KMS permission if the bucket enforces SSE-KMS) — that is the exact Section 15 incident.

---

### Step 9: Create an Architecture Diagram

Create a simple diagram in your notes:

```text
User
 |
 v
EC2 Web Server
 |
 |-- EBS Root Volume: operating system and server files
 |
 |-- S3 Bucket: uploaded files and static objects
 |
 |-- RDS Database: structured application data
```

Add security notes:

- EC2 security group allows HTTP from users.
- RDS security group allows database traffic only from EC2 application security group.
- S3 access should use IAM permissions.
- S3 bucket should remain private.

---

### Step 10: Complete Service Selection Table

Fill this out:

| Requirement | Best AWS Service | Why |
|---|---|---|
| Run web application code |  |  |
| Store uploaded documents |  |  |
| Store customer records |  |  |
| Store high-throughput session/cart data by key |  |  |
| Shared files mounted by many instances |  |  |
| Store Linux root disk |  |  |
| Recover database from point in time |  |  |
| Keep previous versions of uploaded files |  |  |
| Archive old objects cheaply |  |  |

Expected direction:

- EC2 for application compute
- S3 for uploaded documents
- RDS for structured relational records
- DynamoDB for high-throughput key-based session/cart data
- EFS for a shared POSIX filesystem across instances
- EBS for root disk
- RDS backup or point-in-time restore for database recovery
- S3 versioning for object recovery
- S3 lifecycle to Glacier for cheap archival

---

### Step 11: Cleanup

If versioning was not enabled:

```bash
aws s3 rm s3://$BUCKET_NAME/uploads/student-upload.txt
aws s3 rb s3://$BUCKET_NAME
cd ..
rm -rf week7-class2-lab
```

If versioning was enabled, ask instructor before cleanup or use the version cleanup commands provided by instructor.

Cost warning:

Delete lab buckets after validation. Empty buckets may not cost much, but forgotten objects, versions, logs, and backups can create long-term cost.

---

### Validation Checklist

Confirm:

- AWS CLI region is correct
- S3 bucket was created
- File was uploaded
- File was listed
- File was downloaded
- Bucket is private
- Architecture diagram is completed
- EC2, EBS, S3, and RDS responsibilities are correctly explained
- Cleanup completed

---

### Troubleshooting Tips

| Problem | Check |
|---|---|
| `AccessDenied` | IAM permission issue |
| Bucket name error | Bucket name must be globally unique |
| Wrong region | Confirm CLI and console region |
| Upload fails | Confirm file path and bucket name |
| Download fails | Confirm object key |
| Bucket delete fails | Bucket may not be empty or versioning is enabled |
| Object URL does not open | Bucket/object is private, which is expected |

---

### Reflection Questions

1. Why should uploaded files usually go to S3 instead of only the EC2 server disk?
2. Why should relational customer records go to RDS instead of S3?
3. Why should most RDS databases not be publicly accessible?
4. What does S3 versioning protect against?
5. What is one cost risk with snapshots, object versions, or backups?

---

### Optional Challenge Task

Create a sample “application upload structure” in S3:

```bash
aws s3 cp student-upload.txt s3://$BUCKET_NAME/dev/uploads/student-upload.txt
aws s3 cp student-upload.txt s3://$BUCKET_NAME/prod/uploads/student-upload.txt
aws s3 ls s3://$BUCKET_NAME/ --recursive
```

Then answer:

- Why might teams separate dev and prod paths?
- What are the risks of mixing environments in one bucket?
- What IAM controls would be needed?

---

## 15. Troubleshooting Activity

### Incident Title

**Application Can Load, But File Uploads Fail and Database Connection Times Out**

### Business Impact

A small internal application demo is partially working. Users can load the home page on EC2, but they cannot upload files, and the application cannot save records to the database. The business team cannot complete user acceptance testing.

### Symptoms

```text
Home page loads successfully.
File upload fails with AccessDenied.
Database save fails with connection timeout.
EC2 instance is running.
Web server is healthy.
```

### Starting Evidence

Application log sample:

```text
ERROR upload failed: AccessDenied: User is not authorized to perform s3:PutObject on bucket internal-app-uploads
ERROR database connection failed: timeout connecting to appdb.abc123.us-east-1.rds.amazonaws.com:5432
```

AWS CLI from EC2 or local test environment:

```bash
aws s3 cp test.txt s3://internal-app-uploads/uploads/test.txt
```

Output:

```text
upload failed: ./test.txt to s3://internal-app-uploads/uploads/test.txt An error occurred (AccessDenied) when calling the PutObject operation: Access Denied
```

Database connection test:

```bash
nc -zv appdb.abc123.us-east-1.rds.amazonaws.com 5432
```

Output:

```text
Connection timed out
```

### Student Investigation Steps

Students should separate the issue into two paths.

#### S3 Investigation

1. What IAM identity is the application using?
2. Does the EC2 instance have an IAM role?
3. Does the role allow `s3:PutObject`?
4. Is the bucket name correct?
5. Is the object key path correct?
6. Is there a bucket policy explicit deny?
7. Is the bucket private, and is the app using authenticated access?

#### RDS Investigation

1. Is the RDS endpoint correct?
2. Is the database port correct?
3. Is the database running?
4. Is the RDS security group allowing inbound traffic?
5. Is the source the EC2 instance security group or subnet CIDR?
6. Is the RDS instance in private subnets?
7. Are network ACLs blocking traffic?
8. Are credentials correct after network connectivity is confirmed?

### Expected Root Cause

There are two independent root causes:

1. **S3 access failure:** The EC2 instance role is missing permission to write to the S3 bucket.
2. **RDS timeout:** The RDS security group does not allow inbound database traffic from the EC2 application security group.

### Correct Resolution

#### S3 Resolution

Attach or update the EC2 instance role's policy (this is the `week7-ec2-ssm-s3` role from Class 1) to allow the required access.

Example least-privilege direction:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject"],
      "Resource": "arn:aws:s3:::internal-app-uploads/uploads/*"
    }
  ]
}
```

> If the bucket enforces SSE-KMS, also grant `kms:GenerateDataKey` on the bucket's KMS key — otherwise `PutObject` still returns `AccessDenied` even with `s3:PutObject` allowed. This is a classic "the IAM policy looks right but uploads still fail" trap.

#### RDS Resolution

Update RDS security group:

| Type | Protocol | Port | Source |
|---|---|---:|---|
| PostgreSQL | TCP | 5432 | EC2 application security group |

or for MySQL:

| Type | Protocol | Port | Source |
|---|---|---:|---|
| MySQL/Aurora | TCP | 3306 | EC2 application security group |

Important:

Do not open RDS to `0.0.0.0/0`.

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Making S3 bucket public | File upload should use IAM, not public write access |
| Opening RDS to the internet | Major security risk |
| Rebooting EC2 | EC2 is not the root cause |
| Recreating the database | Too drastic before checking security group |
| Changing application code first | Access and network evidence points to AWS configuration |
| Using admin permissions permanently | Violates least privilege |

### Instructor Hints

Hint 1:

> “The home page loads. Which part of the architecture is already working?”

Hint 2:

> “AccessDenied usually points to what category of problem?”

Hint 3:

> “Timeout to a database usually points first to credentials or network?”

Hint 4:

> “Should RDS allow traffic from the whole internet or only from the app layer?”

### Preventive Action

Students should recommend:

- Use IAM roles for EC2, not hardcoded credentials
- Grant least privilege S3 access
- Keep S3 private by default
- Use security group references for database access
- Keep RDS in private subnets
- Document required ports
- Add application health checks
- Add CloudWatch logs
- Use Terraform later to standardize security groups and IAM policies
- Validate connectivity before application release

### Package This as a Portfolio Incident Write-Up

This dual-root-cause incident is interview-grade. Capture it using the evidence-first methodology:

| Section | Content |
|---|---|
| Symptom | Home page loads; file upload returns `AccessDenied`; DB save times out |
| Evidence | `aws s3 cp` → `AccessDenied` (authz); `nc -zv ...:5432` → timeout (network) |
| Root cause | Two independent faults: EC2 role missing `s3:PutObject` (IAM), and RDS SG does not allow the EC2 SG on 5432 (network) |
| Fix | Add least-privilege S3 policy to the instance role; add RDS SG ingress sourced from the EC2 SG |
| Validation | Re-run the upload (succeeds) and `psql`/`nc` to RDS (connects) |
| Prevention | IAM roles not keys, SG references not CIDRs, RDS private, connectivity tested pre-release |

> The key lesson: `AccessDenied` (authorization) and `timeout` (network) are different failure categories and must be diagnosed independently. Never "fix" a timeout by widening IAM, or an `AccessDenied` by opening a security group.

---

## 16. Scenario-Based Discussion Questions

### Question 1

**Why should uploaded user files usually go to S3 instead of the EC2 root disk?**

Expected themes:

- EC2 can be terminated
- Local disk does not scale well
- S3 is more durable for objects
- Easier backup and access patterns
- Decouples application from server

Follow-up:

> “What happens to user uploads if Auto Scaling replaces the instance?”

Expected answer: uploads on the instance's local/EBS disk are lost, and a replacement instance cannot read the old EBS volume. The fix is to store uploads in **S3** (preferred) or, when a shared POSIX mount is genuinely required, **EFS** mounted across instances — never the local disk.

---

### Question 2

**Why should customer records usually go to RDS instead of S3?**

Expected themes:

- Structured data
- Querying
- Transactions
- Relationships
- SQL access
- Data integrity

Follow-up:

> “What type of data would be acceptable in S3?”

---

### Question 3

**Should an RDS database be publicly accessible for a production application?**

Expected themes:

- Usually no
- Keep database private
- Allow only app layer access
- Use security groups
- Reduce attack surface

Follow-up:

> “How should developers access it for admin tasks?”

---

### Question 4

**What are the risks of making an S3 bucket public?**

Expected themes:

- Data exposure
- Compliance risk
- Accidental leaks
- Unauthorized downloads
- Reputation damage

Follow-up:

> “When is public S3 access acceptable?”

---

### Question 5

**What is the difference between backup and high availability?**

Expected themes:

- Backup is recovery from data loss
- High availability reduces downtime
- Both are needed
- Different design patterns

Follow-up:

> “Can a backup help if the service needs to recover within 5 minutes?”

---

### Question 6

**What does Auto Scaling solve, and what does it not solve?**

Expected themes:

Solves:

- Replace unhealthy EC2
- Add capacity
- Maintain desired count

Does not solve:

- Bad code
- Bad database design
- Missing user data
- Broken AMI
- Incorrect security groups

Follow-up:

> “What must be true for Auto Scaling to launch a useful replacement instance?”

---

### Question 7

**How should DevOps, Cloud Engineering, and SRE collaborate on this architecture?**

Expected themes:

- DevOps automates delivery
- Cloud Engineer designs AWS foundation
- SRE defines monitoring, reliability, and incident response
- Security reviews access
- App team owns code and data model

Follow-up:

> “Who owns the runbook when file uploads fail?”

---

### Question 8

**What cost risks exist with S3, snapshots, RDS, and EC2?**

Expected themes:

- Forgotten buckets
- Old object versions
- Unused snapshots
- Running RDS instances
- Oversized EC2
- NAT Gateway costs later
- Log retention

Follow-up:

> “What cleanup checklist should every lab or project include?”

---

## 17. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple Choice

Which AWS service is best for storing uploaded images or PDF files?

A. EC2  
B. S3  
C. IAM  
D. Route 53  

**Answer:** B  
**Explanation:** S3 is object storage and is commonly used for uploaded files, images, documents, logs, and artifacts.

---

### Question 2: Multiple Choice

Which AWS service provides block storage attached to EC2?

A. S3  
B. EBS  
C. RDS  
D. CloudTrail  

**Answer:** B  
**Explanation:** EBS provides disk-like block storage for EC2 instances.

---

### Question 3: True or False

S3 should be treated exactly like a Linux file system mounted to one EC2 instance.

**Answer:** False  
**Explanation:** S3 is object storage accessed through APIs. It is not the same as attached block storage.

---

### Question 4: Multiple Choice

Which service is best for storing relational customer records?

A. S3  
B. RDS  
C. EBS snapshot  
D. Security Group  

**Answer:** B  
**Explanation:** RDS is designed for managed relational databases such as PostgreSQL, MySQL, and others.

---

### Question 5: Short Answer

What is the difference between EBS and S3?

**Answer:**  
EBS is block storage attached to EC2 and behaves like a server disk. S3 is object storage used for files, backups, logs, static assets, and other objects.

---

### Question 6: Troubleshooting

An application can load its home page, but file uploads fail with `AccessDenied`. What category of issue is most likely?

**Answer:**  
An IAM or S3 permissions issue.

**Explanation:**  
`AccessDenied` usually means the application identity lacks permission, the bucket policy denies access, or the object path is not allowed.

---

### Question 7: Troubleshooting

An EC2 application times out when connecting to RDS. Name two things to check.

**Answer:**  
Check the RDS security group and whether it allows traffic from the EC2 security group on the database port. Also check the database endpoint, port, subnet routing, and whether RDS is available.

---

### Question 8: Class 1 and Class 2 Connection

In Class 1, the app ran on EC2. In Class 2, where should uploaded files be stored and why?

**Answer:**  
Uploaded files should usually be stored in S3 because S3 is durable object storage and is not tied to the lifecycle of one EC2 instance.

---

### Question 9: Class 1 and Class 2 Connection

What happens to files stored only on an EC2 root volume if the instance is terminated and the root volume is deleted?

**Answer:**  
The files are lost.

**Explanation:**  
That is why important application files should be stored in durable storage such as S3 or backed up properly.

---

### Question 10: True or False

RDS should usually be publicly accessible in production so developers can connect easily.

**Answer:** False  
**Explanation:** Production databases should usually be private and reachable only through controlled network paths.

---

### Question 11: Multiple Choice

What does S3 versioning help protect against?

A. CPU overload  
B. Accidental object overwrite or deletion  
C. SSH failure  
D. Database connection timeout  

**Answer:** B  
**Explanation:** Versioning keeps previous object versions so teams can recover earlier versions.

---

### Question 12: Short Answer

What is an Auto Scaling Group used for?

**Answer:**  
An Auto Scaling Group helps maintain EC2 capacity by launching, replacing, or scaling instances based on desired configuration and health checks.

---

### Question 13: Multiple Choice

An application needs single-digit-millisecond reads of user session data by a known key, at very high request volume, with no need for joins. Which service fits best?

A. RDS PostgreSQL  
B. S3  
C. DynamoDB  
D. EBS  

**Answer:** C  
**Explanation:** DynamoDB is a serverless NoSQL key-value store built for high-throughput, low-latency access by key. RDS fits relational data with joins and transactions; S3 is object storage; EBS is a single-instance disk.

---

### Question 14: Short Answer

Why would storing user uploads on the EC2 local disk break once an Auto Scaling Group is added, and what are two better options?

**Answer:**  
EBS/local disk is tied to one instance in one AZ, so a replacement instance cannot see the old data and the uploads are lost. Better: store uploads in **S3** (preferred), or use **EFS** for a shared filesystem mountable by all instances.

---

### Question 15: Troubleshooting

An EC2 instance role has `s3:PutObject` on the bucket, but uploads still fail with `AccessDenied`. The bucket uses SSE-KMS default encryption. What is missing?

**Answer:**  
The role also needs `kms:GenerateDataKey` (and usually `kms:Decrypt`) on the bucket's KMS key. Without KMS permission, S3 cannot encrypt the object and rejects the write even though `s3:PutObject` is allowed.

---

## 18. Homework Assignment

### Assignment Title

**AWS Application Architecture: EC2, EBS, S3, and RDS Design Report**

### Scenario

Your team is designing a small internal application for a business department. The application needs:

- A web server
- A place to store uploaded documents
- A relational database for user and transaction records
- Basic backup and recovery planning
- A path to improve availability later

### Student Tasks

Create a design report that includes:

1. Architecture diagram using:
   - EC2
   - EBS
   - S3
   - RDS
   - Security groups
   - Public/private subnet placement

2. Service responsibility table:

| Requirement | AWS Service | Reason |
|---|---|---|
| Run web application |  |  |
| Store OS disk |  |  |
| Store uploaded files |  |  |
| Store relational data |  |  |
| Store high-throughput session data by key |  |  |
| Share files across many instances |  |  |
| Recover server disk |  |  |
| Recover database to a point in time |  |  |
| Keep object history |  |  |
| Archive cold objects cheaply |  |  |

3. Security explanation:
   - Why S3 should remain private
   - Why RDS should not be publicly accessible
   - How EC2 should access S3
   - How EC2 should access RDS

4. Troubleshooting section:
   - File upload fails with `AccessDenied`
   - Database connection times out
   - Web server works locally but not from browser

5. Cloud comparison section:
   - AWS EC2, S3, EBS, RDS
   - Azure equivalents
   - GCP equivalents

### Expected Deliverables

Submit:

- One Markdown, Word, or PDF document
- One architecture diagram
- One service comparison table
- One troubleshooting checklist
- Optional CLI output from S3 lab

### Submission Format

```text
week7-class2-architecture-report-yourname.md
```

or

```text
week7-class2-architecture-report-yourname.pdf
```


### Estimated Completion Time

90 to 120 minutes

### Grading Criteria

| Criteria | Weight |
|---|---:|
| Correct architecture diagram | 25% |
| Correct EC2, EBS, S3, and RDS responsibilities | 25% |
| Security and access explanation | 20% |
| Troubleshooting checklist | 20% |
| Cloud comparison clarity | 10% |

### Optional Advanced Challenge

Add a production improvement section that includes:

- Application Load Balancer
- Auto Scaling Group
- Private subnets
- RDS Multi-AZ
- S3 versioning
- CloudWatch alarms
- Terraform as a future implementation method

---

## 19. Common Student Mistakes

| Mistake | Why It Happens | Fix or Avoidance |
|---|---|---|
| Confusing S3 with EBS | Both are storage services | Teach object vs block storage repeatedly |
| Making S3 bucket public | Students think public is required for access | Use IAM access instead |
| Storing uploads only on EC2 | Easy but unsafe pattern | Use S3 for durable objects |
| Putting RDS in a public subnet | Students want quick connectivity | Keep DB private and allow app security group |
| Opening database to `0.0.0.0/0` | Quick but dangerous troubleshooting | Use security group source references |
| Forgetting bucket name uniqueness | S3 names are global | Use random suffix or naming standard |
| Not cleaning up buckets | Students assume empty services cost nothing | Delete objects, versions, and buckets |
| Forgetting object versions | Versioned objects remain after delete | Delete versions and delete markers |
| Treating backups as automatic recovery | Backups must be tested | Include restore validation in plans |
| Thinking Auto Scaling fixes all failures | Scaling compute is only one layer | Discuss app, DB, network, and config dependencies |
| Confusing AccessDenied with network timeout | Different failure categories | AccessDenied is permissions. Timeout is network/connectivity |

---

## 20. Real-World Enterprise Scenario

### Scenario

A regional logistics company is building an internal shipment document portal. Employees log in, search shipment records, and upload supporting documents such as PDFs and images.

The first version ran on one EC2 instance. After the pilot, the platform team needs to make the design more reliable, secure, and supportable.

### Constraints

- Uploaded files must not disappear if EC2 is replaced.
- Database should not be publicly accessible.
- Developers should not hardcode AWS keys.
- Security requires least privilege.
- Finance wants predictable cost.
- Operations needs backup and recovery documentation.
- SRE wants clear troubleshooting paths.
- The design must later support CI/CD and Terraform.

### How the Class Topic Applies

The improved architecture uses:

- EC2 for application compute
- EBS for operating system and local disk
- S3 for uploaded shipment documents
- RDS for shipment records and user metadata
- IAM role for EC2 access to S3
- Security groups for controlled app-to-database traffic
- Snapshots and backups for recovery
- Auto Scaling concept for future resilience

### What Each Role Would Do

| Role | Responsibility |
|---|---|
| DevOps Engineer | Automates deployment and later creates pipeline for app releases |
| Cloud Engineer | Designs EC2, S3, RDS, security groups, backups, and network placement |
| SRE | Defines monitoring, runbooks, incident response, and reliability targets |
| Security Engineer | Reviews IAM, bucket access, encryption, and database exposure |
| Application Developer | Implements file upload logic and database connection handling |

---

## 21. Instructor Tips

### Teaching Tips

- Keep repeating the service responsibility model.
- Ask students where each type of data should live.
- Use simple examples like uploaded PDFs and customer records.
- Do not let the RDS section become deep database administration.
- Reinforce that private access is normal in enterprise environments.
- Connect every service back to the Class 1 EC2 web server.

### Pacing Tips

- Keep S3 hands-on and RDS mostly conceptual unless budget allows.
- Do not spend more than 25 minutes on RDS console options.
- Reserve enough time for the troubleshooting scenario.
- Use the architecture diagram as the main anchor for the class.

### Lab Support Tips

When students get stuck, ask:

1. What is your bucket name?
2. What region are you using?
3. What command failed?
4. Is it an AccessDenied error or not found error?
5. Did you copy the object key correctly?
6. Is the bucket empty before deletion?
7. Did you enable versioning?

### Helping Struggling Students

Give them this simple memory model:

```text
EC2 runs it.
EBS supports the server disk.
S3 stores files.
RDS stores relational records.
Snapshots help recovery.
Auto Scaling helps compute resilience.
```

### Challenging Advanced Students

Ask advanced students to:

- Write a sample IAM policy for S3 access
- Design a private RDS security group rule
- Add lifecycle rules to S3
- Explain RTO and RPO
- Add ALB and Auto Scaling to the diagram
- Describe how Terraform would provision the architecture

---

## 22. Student Outcome Checklist

### Students Should Be Able to Explain

- Difference between EBS, S3, and RDS
- Why S3 is object storage
- Why EBS is block storage
- Why RDS is used for relational data
- Why RDS should usually be private
- Why S3 buckets should not be public by default
- What snapshots and backups support
- What Auto Scaling does at a beginner level
- How Class 2 extends the EC2 server from Class 1

### Students Should Be Able to Build or Configure

- Create an S3 bucket
- Upload an object
- List S3 objects
- Download an object
- Validate private bucket settings
- Optionally enable versioning
- Create a basic architecture diagram
- Complete service selection table

### Students Should Be Able to Troubleshoot

- S3 `AccessDenied`
- Wrong bucket name
- Wrong object key
- Wrong AWS region
- Bucket cleanup failure
- RDS timeout
- RDS security group issue
- Confusion between application, storage, and database failures

---

## 23. Class Completion Checklist

### Instructor Checklist Before Ending Class

Confirm:

- Students understand EC2, EBS, S3, and RDS responsibilities
- Students completed the S3 upload/download lab
- Students understand why buckets should stay private
- Students understand why RDS is usually private
- Students can explain snapshot and backup basics
- Students understand Auto Scaling at a high level
- Troubleshooting activity was reviewed
- Homework expectations are clear
- Cleanup was completed or assigned

### Student Checklist Before Leaving Class

Students should confirm:

- I created an S3 bucket
- I uploaded a file
- I listed the file
- I downloaded the file
- I checked bucket privacy settings
- I cleaned up lab resources
- I completed or started my architecture diagram
- I understand where EC2, EBS, S3, and RDS fit
- I understand the homework assignment

### Items to Verify Before Closing the Week

Students should be able to answer:

1. What does EC2 do?
2. What does EBS do?
3. What does S3 do?
4. What does RDS do?
5. Why should RDS usually not be public?
6. Why are backups and snapshots important?
7. What would break if an app stores uploads only on EC2?
8. What is the first thing to check for S3 `AccessDenied`?
9. What is the first thing to check for RDS timeout?

---

## 23b. Appendix: This Architecture in Terraform (forward link to Week 14)

Throughout the week we built this stack by hand to understand each decision. In Week 14 you will provision it as code. Here is a preview so the through-line is concrete — read it, do not run it yet. (OpenTofu is a drop-in open-source alternative to Terraform; the same HCL works with either.)

```hcl
# A private S3 bucket with versioning, SSE-KMS, and lifecycle
resource "aws_s3_bucket" "uploads" {
  bucket = "week7-app-uploads-${data.aws_caller_identity.me.account_id}"
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket                  = aws_s3_bucket.uploads.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "aws:kms" }
    bucket_key_enabled = true
  }
}

# The EC2 instance profile that lets the app write to S3 with no keys
resource "aws_iam_role" "ec2_app" {
  name               = "week7-ec2-ssm-s3"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_app" {
  name = "week7-ec2-ssm-s3"
  role = aws_iam_role.ec2_app.name
}

# RDS reachable only from the app security group, never the internet
resource "aws_security_group_rule" "db_from_app" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.app.id
}
```

> Workflow discipline you will carry into Week 14: always run `terraform plan` (or `tofu plan`) and read the diff **before** `apply`. "Render/plan before apply" is the IaC equivalent of "validate evidence before acting" — never apply a change you have not previewed.

---

## 24. End-of-Week Summary

### What Students Learned This Week

In Week 7, students learned how basic AWS application infrastructure is assembled from multiple services:

- EC2 for compute (keyless SSM access, IMDSv2, instance profiles)
- AMI for server image
- Instance type for capacity (Graviton, spot, right-sizing awareness)
- EBS for server disk (gp3, encryption)
- Security group for access control
- User data and launch templates for server bootstrap
- S3 for object storage (lifecycle, storage classes, SSE-KMS)
- RDS for managed relational data (provisioned and connected end-to-end)
- DynamoDB for NoSQL key-value/document data
- EFS for shared file storage
- Snapshots and backups for recovery
- Auto Scaling for compute resilience

### How Class 1 and Class 2 Connect

Class 1 built the compute foundation:

```text
EC2 + EBS + Security Group + User Data + Web Server
```

Class 2 expanded that into application architecture:

```text
EC2 compute
+ EBS server disk
+ S3 object storage
+ RDS relational database
+ backups and snapshots
+ scaling concepts
```

### How This Week Prepares Students for the Next Week

Week 8 introduces **scripting and automation (Bash in Class 1, Python in Class 2)**.

Week 7 prepares students because they now understand manual AWS infrastructure workflows. In Week 8, students begin automating operational tasks such as:

- Health checks
- Log checks
- Disk checks
- Cleanup tasks
- Service validation
- Basic infrastructure reporting

### What Students Should Review Before the Next Module

Students should review:

- Linux commands from Week 2
- Networking and VPC troubleshooting from Week 5
- AWS CLI v2 basics from Week 4
- IAM, roles, and instance profiles from Week 6
- EC2 and security groups from Class 1
- S3 CLI commands from Class 2

Recommended review commands:

```bash
aws configure get region
aws s3 ls
curl localhost
systemctl status httpd
df -h
free -m
ps aux | head
```

Final Week 7 takeaway:

```text
A real cloud application is not just a server.
It is compute, storage, database, network, security, backup, monitoring, and operations working together.
```

---

## Class Artifacts & Validation

This class teaches AWS **storage and databases** — S3 object storage, a managed
database, EBS snapshots/backups, and the multi-service application architecture.
The runnable lab [`labs/aws-storage-databases/`](../../labs/aws-storage-databases/)
is the on-disk, validated form of this material: a security-hardened **S3 bucket**
(versioning, AES256 SSE, full public-access block, lifecycle, access logging,
deny-non-TLS/deny-unencrypted bucket policy), a **DynamoDB table** (`PAY_PER_REQUEST`,
SSE, point-in-time recovery as the managed-DB + backup pattern), and an **encrypted
gp3 EBS volume**. All gates below were run in this environment; commands are run
from `labs/aws-storage-databases/`.

> **Note on RDS vs DynamoDB:** the class narrative uses **RDS** as its relational
> example; the runnable lab provisions **DynamoDB** as the near-$0 managed-database
> stand-in (an idle RDS instance bills continuously, an idle on-demand DynamoDB
> table is $0). Both teach the same managed-database concepts — SSE at rest,
> point-in-time recovery / automated backups, and least-privilege access — without
> a billing trap. Point-in-time recovery on the table is the lab's "automated
> backup" artifact mapping to this class's snapshot/backup topic.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/aws-storage-databases/solution/main.tf | terraform | Hardened `aws_s3_bucket.data` — versioning, AES256 SSE, public-access block, lifecycle, access logging, deny-non-TLS/deny-unencrypted policy | `terraform -chdir=solution validate` | PASS |
| 2 | labs/aws-storage-databases/solution/main.tf | terraform | `aws_dynamodb_table.app` — `PAY_PER_REQUEST`, SSE, point-in-time recovery (managed DB + automated backup) | `terraform -chdir=solution validate` | PASS |
| 3 | labs/aws-storage-databases/solution/main.tf | terraform | `aws_ebs_volume.data` — encrypted gp3 8 GiB (server disk for snapshot/recovery topic) | `terraform -chdir=solution validate` | PASS |
| 4 | labs/aws-storage-databases/solution/ | terraform | Full module security-scanned (no public buckets, encryption at rest, TLS-only) | `checkov -d solution --compact --quiet` | PASS (46 passed, 0 failed, 9 documented skips) |
| 5 | labs/aws-storage-databases/starter/main.tf | terraform | Lab exercise — the S3 security blocks are TODO'd for students to complete | `terraform -chdir=starter validate` | PASS (validate); checkov intentionally fails until TODOs are completed |
| 6 | labs/aws-storage-databases/broken/main.tf | terraform | Troubleshooting fixture — a world-readable, unencrypted bucket | `checkov -d broken --compact --quiet` | FAILS as expected (15 findings; this is the exercise) |
| 7 | labs/aws-storage-databases/tests/test_terraform_structure.py | python | Structural answer-key tests | `python3 -m unittest discover -s tests` | PASS (18 tests) |
| 8 | labs/aws-storage-databases/validate.sh | shell | Runs every gate (fmt + validate + unittest + checkov) | `./validate.sh` | PASS (exit 0, 9/9 gates) |

> **Live status:** This is a **static-validated** lab. No `terraform apply` runs in
> this environment (no AWS credentials), and `labs/aws-storage-databases/LIVE-AWS-VALIDATION.txt`
> is currently **empty** — there is no captured live `apply`/`destroy`, no real bucket
> or table created, and no live backup/restore. The S3/DynamoDB/EBS stack is validated
> statically (fmt, validate, checkov, unit tests) only; a live apply/destroy is run
> separately by the orchestrator and is not yet recorded here.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — S3, DynamoDB, and EBS are real Terraform in `labs/aws-storage-databases/solution/` (not just fences).
- [x] Each artifact passes its **validation gate** from §3 — `terraform validate` + `checkov` (46/0/9) + 18 unit tests all PASS; output captured above and in the lab README.
- [x] Lab has **starter** (S3 security blocks intentionally TODO'd) and **solution** (reference) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, and cost notes.
- [x] **Cleanup/teardown** is provided and idempotent — `terraform destroy` with `force_destroy` buckets; verification commands in README "Cleanup".
- [x] **Instructor answer key** exists — `solution/` plus `tests/test_terraform_structure.py` (18 reproducible checks) and the README "Instructor answer key" section.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `labs/aws-storage-databases/broken/` (world-readable bucket; `validate` passes but `checkov` reports 15 findings, teaching "validate checks syntax, not security").
- [x] **Expected outputs** are shown — checkov `46 passed, 0 failed`, checkov-broken `15 failed`, unittest `Ran 18 tests ... OK`, all captured in the README "Expected results".
- [x] **Cost & security warnings** present — README "Cost considerations" (DynamoDB chosen over RDS to avoid idle billing; destroy immediately) and "Security considerations" (TLS-only, encryption at rest, least privilege).
- [x] **Cross-references** to the module repo and to prior/next weeks are correct (Class 1 EC2 prior; Week 8 scripting next; verified).
- [x] The **artifact manifest** (§4.2) is present and every path resolves (`ls`-verified).
- [ ] **Not done — live op:** no live `terraform apply`, no created bucket/table, no live backup/restore captured; `LIVE-AWS-VALIDATION.txt` is empty. The lab is static-validated, not operated live in-repo.
