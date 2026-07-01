# Week 5: Networking and VPC
> **▶ Runnable lab for this class:** [`labs/terraform-aws-foundations/`](../../labs/terraform-aws-foundations/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 2 Complete Instructor-Ready and Student-Ready Package

**Week:** 5 — Networking and VPC
**Track:** Unified DevOps · Cloud · SRE Track

---

# 1. Class Overview

## Class title

**Class 2: AWS Networking with VPC, Subnets, Routing, and Security**

## Class purpose

This class takes students from the conceptual networking of Class 1 into a real AWS Virtual Private Cloud. Students first build the VPC foundation — CIDR, subnets, route tables, and Internet Gateways — then go deeper into the security and connectivity layers that define production VPC work: **Security Groups vs NACLs (stateful vs stateless), NAT Gateway and egress-only IGW for private egress, VPC Endpoints (Gateway and Interface/PrivateLink), VPC Flow Logs, and hybrid connectivity (VPC peering, Transit Gateway, VPN, and Direct Connect).**

The goal is to help students move from a vague understanding of “cloud networking” to the ability to reason about traffic flow, filtering, private egress, and on-prem connectivity the way a cloud or platform engineer must.

## How this class connects to the overall course

This class builds directly on:

- Week 5 Class 1 networking fundamentals (IP, CIDR, subnet math, ports, DNS)
- Week 4 AWS Cloud Foundations (accounts, identity, CLI, cost)

It prepares students for:

- Week 6 Cloud Security & IAM, which deepens the identity and KMS/Secrets/governance layer (note: IAM comes *after* this week — this class only uses the lab-scoped permissions it lists, it does not assume the full IAM week)
- Week 7 EC2, storage, and databases, which run inside the VPC patterns built here
- Terraform-based VPC provisioning in Week 14 and Week 15
- Week 17 AWS Landing Zones & Multi-Account, which scales the peering/Transit Gateway/hybrid patterns introduced here to an organization
- Week 16 Observability & Reliability, which consumes the VPC Flow Logs enabled here
- Kubernetes and EKS networking concepts later in the course

## What students will build, analyze, or practice

Students will:

- Build a multi-AZ AWS VPC (2 public + 2 private subnets) as the baseline
- Attach an Internet Gateway and create/associate route tables
- Explain why a subnet is public or private
- Add a NAT Gateway so private subnets get outbound internet without inbound exposure
- Configure and contrast Security Groups (stateful) and NACLs (stateless), proving the difference in a lab
- Add a Gateway VPC Endpoint for S3 and reason about Interface Endpoints / PrivateLink
- Enable VPC Flow Logs and read them during troubleshooting
- Reason about hybrid connectivity (peering, Transit Gateway, VPN, Direct Connect) at a senior level
- Troubleshoot a public subnet that is not actually internet-routable, using Flow Logs as evidence

---

# 2. Class Learning Objectives

By the end of this class, students will be able to:

1. **Explain** what an AWS VPC is and why enterprises use isolated cloud networks.
2. **Interpret** a basic CIDR block and explain how it applies to VPCs and subnets.
3. **Differentiate** between public and private subnets based on route table behavior.
4. **Configure** an Internet Gateway and public route table for internet access.
5. **Build** a basic VPC with public and private subnet structure.
6. **Validate** route table associations and identify whether a subnet is public.
7. **Configure** a NAT Gateway (and explain the egress-only IGW for IPv6) so private subnets reach the internet outbound without inbound exposure.
8. **Differentiate** Security Groups (stateful) from NACLs (stateless) and predict traffic behavior in a worked example.
9. **Create** a Gateway VPC Endpoint for S3 and explain when to use Interface Endpoints / PrivateLink.
10. **Enable** VPC Flow Logs and use them as troubleshooting evidence.
11. **Troubleshoot** an EC2 internet access issue caused by missing or incorrect routing, using Flow Logs.
12. **Compare** hybrid-connectivity options (VPC peering, Transit Gateway, VPN, Direct Connect) and AWS VPC vs Azure VNet / GCP VPC Network at a high level.

---

# 3. Prerequisites Students Should Already Know

## Required prior concepts

Students should already understand:

- Basic AWS account, region, CLI, and cost concepts from Week 4
- IP addresses, CIDR, subnet math, ports, and DNS from Week 5 Class 1
- Difference between public and private networks
- What DNS, HTTP, SSH, and ports are
- Basic AWS Console navigation
- Basic AWS CLI profile concept

> **Sequencing note:** Full IAM (Week 6) comes *after* this week. This class does **not** assume the IAM week. It uses only the small, lab-scoped permission set listed below, which an instructor or admin grants for the lab. Deep IAM (policies, KMS, Secrets Manager, governance) is taught in Week 6.

## Required tools already installed

Students should have:

- Web browser
- AWS account access
- AWS CLI installed
- Terminal available
- VS Code installed
- Git installed
- Diagram tool optional, such as draw.io, Lucidchart, Excalidraw, or plain text diagrams

## Required accounts or access

Students need:

- AWS Console access
- Permission to create and delete VPC resources
- Permission to create:
  - VPC
  - Subnets
  - Route tables
  - Internet Gateway
  - EC2 instance optional
  - Security Group optional

Recommended IAM permissions for the lab:

```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:CreateVpc",
    "ec2:DeleteVpc",
    "ec2:CreateSubnet",
    "ec2:DeleteSubnet",
    "ec2:CreateInternetGateway",
    "ec2:AttachInternetGateway",
    "ec2:DetachInternetGateway",
    "ec2:DeleteInternetGateway",
    "ec2:CreateRouteTable",
    "ec2:DeleteRouteTable",
    "ec2:CreateRoute",
    "ec2:DeleteRoute",
    "ec2:AssociateRouteTable",
    "ec2:DisassociateRouteTable",
    "ec2:AllocateAddress",
    "ec2:ReleaseAddress",
    "ec2:CreateNatGateway",
    "ec2:DeleteNatGateway",
    "ec2:CreateSecurityGroup",
    "ec2:DeleteSecurityGroup",
    "ec2:AuthorizeSecurityGroupIngress",
    "ec2:AuthorizeSecurityGroupEgress",
    "ec2:RevokeSecurityGroupIngress",
    "ec2:RevokeSecurityGroupEgress",
    "ec2:CreateNetworkAcl",
    "ec2:DeleteNetworkAcl",
    "ec2:CreateNetworkAclEntry",
    "ec2:DeleteNetworkAclEntry",
    "ec2:ReplaceNetworkAclAssociation",
    "ec2:CreateVpcEndpoint",
    "ec2:DeleteVpcEndpoints",
    "ec2:CreateFlowLogs",
    "ec2:DeleteFlowLogs",
    "ec2:Describe*",
    "ec2:CreateTags",
    "logs:CreateLogGroup",
    "logs:DescribeLogGroups",
    "iam:PassRole"
  ],
  "Resource": "*"
}
```

> **Lab-scoping warning:** `"Resource": "*"` and `iam:PassRole` are broad and acceptable **only** in a throwaway training account. In production these would be scoped to specific ARNs and conditions — that least-privilege discipline is taught in Week 6 (IAM). `iam:PassRole` is needed only so Flow Logs can use a delivery role; if your instructor pre-creates that role, you can drop `iam:PassRole`.

## Files, repos, or sample code needed

No code repository is required for this class.

Optional instructor-provided files:

```text
week-05/
  class-02/
    README.md
    vpc-diagram-template.txt
    student-lab-checklist.md
```

---

# 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| VPC | A private network space inside AWS where you place cloud resources | Similar to a private network in a corporate data center |
| CIDR block | A range of IP addresses assigned to a VPC or subnet | Used by network teams to plan address space and avoid overlap |
| Subnet | A smaller section of a VPC IP range | Used to separate public, private, app, and database workloads |
| Public subnet | A subnet with a route to an Internet Gateway | Often used for load balancers, bastion hosts, or public-facing services |
| Private subnet | A subnet without a direct route to the internet | Commonly used for application servers, databases, internal services |
| Route table | A set of rules that tells traffic where to go | Cloud equivalent of routing decisions in enterprise networks |
| Route | A rule inside a route table | Example: send internet-bound traffic to an Internet Gateway |
| Internet Gateway | AWS-managed component that allows internet access for public subnets | Required for public internet routing in a VPC |
| Availability Zone | A physically separate data center location inside an AWS Region | Enterprises use multiple AZs for high availability |
| Local route | Default route inside every VPC that allows resources in the VPC CIDR to communicate | Enables internal communication between subnets |
| Public IP | An IP address reachable from the internet | Required for direct internet access to an EC2 instance |
| Private IP | An IP address used inside the VPC | Used for internal communication between cloud resources |

---

# 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| AWS Console | Beginner-friendly way to create and inspect VPC resources visually |
| AWS CLI | Shows how engineers validate cloud resources from the terminal |
| Terminal | Used to run AWS CLI commands and basic network checks |
| Diagram tool | Helps students draw and explain network architecture |
| Browser | Used for AWS Console access |
| Optional SSH client | Used only if instructor chooses to launch an EC2 instance |
| Optional curl | Used to test HTTP access if an EC2 web server is created |

---

# 6. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| Amazon VPC | Main service used to create isolated cloud networks |
| Subnets | Used to divide the VPC into public and private network zones |
| Route Tables | Used to control traffic flow from subnets |
| Internet Gateway | Used to allow public subnet internet access |
| EC2 | Optional resource used to test public subnet access |
| Security Groups | Stateful instance-level firewall; taught in depth in this class alongside NACLs |
| Network ACLs (NACLs) | Stateless subnet-level filter; contrasted with Security Groups in this class |
| NAT Gateway | Provides outbound internet for private subnets without inbound exposure |
| VPC Endpoints (Gateway + Interface/PrivateLink) | Private access to AWS services without traversing the internet |
| VPC Flow Logs | Records ACCEPT/REJECT traffic for troubleshooting and security |
| IAM | Required for permissions to create and manage VPC resources |
| CloudShell optional | Can be used if students do not have AWS CLI configured locally |

---

# 7. Azure and GCP Comparison Notes

Keep this section brief during class. The goal is awareness, not deep multi-cloud networking.

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Private cloud network | VPC | Virtual Network, VNet | VPC Network |
| Subnet | Subnet inside a VPC and AZ-specific | Subnet inside a VNet and region-specific | Subnet inside a VPC Network and region-specific |
| Internet access component | Internet Gateway | Internet access through public IP and routing model | Internet Gateway behavior is built into routes and external IP usage |
| Firewall concept | Security Groups, NACLs | Network Security Groups | Firewall Rules |
| Route tables | Route Tables | Route Tables and User Defined Routes | Routes |

Teaching note:

AWS subnet design is Availability Zone based. Azure and GCP subnet behavior differs, so avoid saying all clouds work exactly the same.

---

# 8. Time-Boxed Instructor Agenda

| Time | Activity |
|---:|---|
| 0:00 to 0:10 | Welcome, class goal, and Week 5 Class 2 context |
| 0:10 to 0:20 | Recap Week 5 Class 1 networking fundamentals |
| 0:20 to 0:35 | What is a VPC and why enterprises use network isolation; multi-AZ baseline |
| 0:35 to 0:50 | CIDR/subnet recap applied to AWS; route tables and Internet Gateway |
| 0:50 to 1:10 | Instructor demo: build multi-AZ VPC (2 public + 2 private), IGW, route tables |
| 1:10 to 1:20 | Break |
| 1:20 to 1:45 | NAT Gateway and egress-only IGW: private outbound without inbound |
| 1:45 to 2:10 | Security Groups vs NACLs — stateful vs stateless, worked example + lab |
| 2:10 to 2:30 | VPC Endpoints (Gateway + Interface/PrivateLink) and VPC Flow Logs |
| 2:30 to 2:50 | Student lab: add NAT, SG/NACL, S3 Gateway Endpoint, Flow Logs |
| 2:50 to 3:05 | Troubleshooting activity: public EC2 unreachable (Flow Logs as evidence) |
| 3:05 to 3:15 | Senior section: hybrid connectivity decision matrix; recap and Week 6 preview |

Note: If strict 3-hour timing is required, treat the hybrid-connectivity section (Section 9 Step 12 / Section 10.5) as assigned reading and keep the live time on NAT, SG vs NACL, and endpoints.

---

# 9. Instructor Lesson Plan

## Step 1: Open the class with the business reason for VPCs

Explain:

A VPC is not just an AWS exam topic. It is the foundation for how applications are isolated, secured, and connected in AWS.

Say:

“Before we deploy EC2, databases, Kubernetes, or load balancers, we need a network foundation. If the network is wrong, the application may be unreachable, insecure, or unreliable.”

Pause and ask:

“What could go wrong if a database is placed directly on the public internet?”

Expected responses:

- Security risk
- Data exposure
- Attack surface increases
- Compliance concerns

## Step 2: Connect to prior weeks

Explain how this class builds on earlier topics:

- Week 5 Class 1: IP, CIDR, subnet math, routing, firewalls, DNS
- Week 4: AWS account, region, CLI, and cost basics

Transition:

“Now we are going to apply the networking concepts from Class 1 inside AWS.”

## Step 3: Explain VPC as a network boundary

Show:

- AWS Console VPC dashboard
- Region selector
- Existing default VPC, if present

Explain:

A VPC belongs to one AWS Region. It does not span multiple regions. Inside the VPC, we create subnets in Availability Zones.

Teaching tip:

Beginners often think a VPC is a server. Clarify that it is a network container, not a compute resource.

## Step 4: Teach CIDR with practical examples

Use simple examples:

```text
10.0.0.0/16  = large VPC range
10.0.1.0/24  = smaller subnet range
10.0.2.0/24  = another subnet range
```

Explain:

- The VPC gets the larger range.
- Subnets get smaller ranges inside the VPC.
- Subnet ranges must not overlap.
- Enterprises plan CIDR carefully to avoid conflicts with other networks.

Pause and ask:

“Why might overlapping CIDR ranges become a problem when connecting VPCs or on-prem networks?”

Expected response:

Routing becomes ambiguous because two networks claim the same IP range.

## Step 5: Teach public vs private subnet

Explain:

A subnet is public because of routing, not because of its name.

Say:

“A subnet named public-subnet is not automatically public. It becomes public when its route table sends internet-bound traffic to an Internet Gateway.”

Write:

```text
0.0.0.0/0 -> Internet Gateway
```

Explain:

That means all destinations not known locally should go to the Internet Gateway.

## Step 6: Teach route tables and local route

Explain:

Every VPC route table has a local route for communication inside the VPC.

Example:

```text
10.0.0.0/16 -> local
```

That allows resources inside the VPC CIDR range to communicate, assuming security controls allow it.

## Step 7: Instructor demo

Create the VPC, subnets, Internet Gateway, and route table.

Pause after each major component and ask:

- “What did we create?”
- “What problem does this component solve?”
- “What would break if this component was missing?”

## Step 8: Student lab

Students repeat the build using their own VPC name and CIDR.

Instructor circulates and checks:

- VPC CIDR
- Subnet CIDRs
- Internet Gateway attachment
- Route table route
- Route table association

## Step 9: Troubleshooting activity

Present a broken public subnet scenario.

Guide students to check in this order:

1. Internet Gateway attached?
2. Route table has default route?
3. Subnet associated with correct route table?
4. EC2 has public IP?
5. Security group allows traffic?

## Step 11: NAT Gateway and egress-only IGW

Explain the core asymmetry that confuses beginners:

- An **Internet Gateway** allows **both** inbound and outbound for public subnets (subject to security controls).
- A private subnet must often reach **out** (OS updates, pulling container images, calling external APIs) without being reachable **in** from the internet.
- A **NAT Gateway** solves exactly this: instances in a private subnet send outbound traffic to the NAT Gateway (which lives in a *public* subnet and has an Elastic IP); the NAT does source translation and the return traffic comes back. The internet **cannot initiate** a connection inward.

Draw the path:

```text
Private subnet instance
   |  default route 0.0.0.0/0 -> NAT Gateway
   v
NAT Gateway (in a PUBLIC subnet, has Elastic IP)
   |  default route 0.0.0.0/0 -> Internet Gateway
   v
Internet Gateway -> Internet
```

Key teaching points:

- The NAT Gateway lives in a **public** subnet but **serves** the private subnets. The private subnet's route table points `0.0.0.0/0` at the NAT, not the IGW.
- NAT is **IPv4 only**. For IPv6 private egress you use an **egress-only Internet Gateway (EIGW)** — same "outbound + return, no inbound" behavior, route `::/0 -> eigw-...`.
- **Cost warning:** A NAT Gateway bills **per hour AND per GB processed**. It is one of the most common surprise charges on AWS. For high-volume same-region traffic to AWS services (like S3), a **VPC Endpoint is cheaper** because it bypasses the NAT entirely (see Step 13). Always delete lab NAT Gateways and release their Elastic IPs.

## Step 12: Security Groups vs NACLs (stateful vs stateless)

This is the single most-asked VPC interview question. Teach it explicitly, not as a preview.

Say:

> "Both filter traffic, but they live at different places and behave differently. A Security Group is **stateful** and wraps an **instance/ENI**. A Network ACL is **stateless** and wraps a **subnet**."

Walk the worked example in Section 10 Concept "Security Groups vs NACLs." Have students predict, for a request arriving on TCP 443 and the reply going back out on an ephemeral port, what each control needs configured. The punchline:

- Security Group: allow inbound 443. The reply is **automatically allowed** out because SGs track connection state.
- NACL: allow inbound 443 **and** explicitly allow **outbound on the ephemeral port range** (1024–65535), because NACLs do not track state — each direction is evaluated independently.

Then the second discriminator:

- Security Group rules are **allow-only** (you cannot write a deny rule).
- NACL rules have both **allow and deny**, are **numbered/ordered** (lowest number wins), and end in an implicit deny.

## Step 13: VPC Endpoints and PrivateLink

Explain why endpoints exist: reaching AWS services (S3, DynamoDB, SQS, ECR, Secrets Manager...) from a private subnet would otherwise require a NAT Gateway and send the traffic out to the public AWS endpoints. Endpoints keep that traffic **on the AWS network** — cheaper, more secure, no internet exposure.

Two kinds:

- **Gateway Endpoint** — only for **S3 and DynamoDB**. It is a *route table entry*, free, and adds a route like `pl-xxxx (S3 prefix list) -> vpce-...`. No ENI, no hourly charge.
- **Interface Endpoint (powered by PrivateLink)** — for most other services and for your own services. It creates an **ENI with a private IP** in your subnet; you reach the service via that private IP/private DNS name. Bills per hour and per GB. PrivateLink is also how SaaS vendors expose a service into your VPC privately.

Say:

> "If a private instance only needs S3, do not stand up a NAT Gateway — add an S3 Gateway Endpoint. It is free and keeps traffic off the internet."

## Step 14: VPC Flow Logs

Explain Flow Logs as the network equivalent of an audit trail: they record accepted and rejected traffic at the VPC, subnet, or ENI level to CloudWatch Logs or S3. They are the primary evidence source when "the packet seems to vanish" — an `ACCEPT` vs `REJECT` in the log tells you whether a Security Group/NACL dropped it. This forward-links to Week 16 (observability) and Week 19 (DevSecOps).

## Step 15: Recap and Week 6 preview

Close by explaining:

This class delivered the full VPC: public inbound, private outbound via NAT, stateful vs stateless filtering, private service access via endpoints, Flow Logs for evidence, and the hybrid-connectivity decision matrix. Week 6 (Cloud Security & IAM) deepens the identity, KMS, Secrets Manager, and governance controls that sit on top of this network.

---

# 10. Instructor Lecture Notes

## Opening notes

Today’s class is about AWS networking foundations. Students often struggle with VPCs because there are several pieces that only make sense when connected together: VPCs, subnets, route tables, Internet Gateways, public IPs, and firewall rules.

The most important idea for this class is:

A subnet becomes public because its route table has a route to an Internet Gateway.

Students do not need to master advanced networking today. They need to understand how traffic flows in a basic VPC.

## Concept: What is a VPC?

A VPC is a logically isolated network inside AWS. It gives us control over:

- IP ranges
- Subnets
- Routing
- Internet access
- Private network segmentation
- Security boundaries

Talking point:

“In an enterprise, teams rarely deploy resources randomly into AWS. They usually deploy into controlled network zones. A web tier may be public or behind a load balancer. An app tier is usually private. A database tier should almost always be private.”

## Concept: CIDR

CIDR defines the IP range.

Example:

```text
VPC: 10.0.0.0/16
Subnet A: 10.0.1.0/24
Subnet B: 10.0.2.0/24
```

Explain:

- `/16` is larger than `/24`.
- The VPC range must be large enough for future growth.
- Subnets must fit inside the VPC range.
- Subnet ranges cannot overlap.

Common misconception:

Students may think `/24` is bigger than `/16` because 24 is a larger number. Clarify that a larger prefix means fewer usable IP addresses.

## Concept: Public subnet

A public subnet has a route to an Internet Gateway.

Required pieces for internet access:

1. VPC
2. Subnet
3. Internet Gateway attached to VPC
4. Route table with `0.0.0.0/0 -> Internet Gateway`
5. Subnet associated with that route table
6. Public IP on the resource, if directly accessing an EC2 instance
7. Security group allowing the required traffic

Talking point:

“Public subnet does not mean everything inside is automatically open to the world. Routing gives a path. Security groups still control access.”

## Concept: Private subnet

A private subnet has no direct route to the Internet Gateway.

Private subnets are commonly used for:

- Application servers
- Databases
- Internal APIs
- Kubernetes worker nodes in many enterprise designs
- Background workers
- Batch jobs

In Class 2, students will learn how private resources can reach the internet through NAT Gateway without allowing the internet to initiate direct inbound traffic.

## Concept: Route table

A route table is a list of decisions.

Example:

```text
10.0.0.0/16 -> local
0.0.0.0/0  -> Internet Gateway
```

Explain:

- The local route allows VPC-internal communication.
- The default route sends all other traffic to the target.
- Route table association determines which subnet uses which route table.

Common misconception:

Students often add the correct route but forget to associate the subnet with the route table.

## Concept: Internet Gateway

An Internet Gateway is an AWS-managed component that allows internet connectivity for resources in public subnets.

It must be:

- Created
- Attached to the VPC
- Referenced in a route table
- Used by a subnet through route table association

Talking point:

“Creating an Internet Gateway alone does nothing unless the route table points to it.”

## Enterprise context

In real companies, VPC design is often standardized by cloud platform teams. Application teams may not create VPCs directly. They may consume prebuilt networking patterns.

Common enterprise patterns:

- Shared services VPC
- Separate dev, test, and prod VPCs
- Public subnets for load balancers
- Private subnets for applications
- Isolated database subnets
- Centralized firewall or inspection VPC
- Hybrid connectivity to on-prem data centers

## Common misconceptions to call out

1. “A subnet is public because I named it public.”
   - Incorrect. It is public because of route table behavior.

2. “An Internet Gateway automatically gives every subnet internet access.”
   - Incorrect. Subnet route tables must point to it.

3. “A public subnet means all instances are open.”
   - Incorrect. Public routing and security group permissions are separate.

4. “Private subnets cannot communicate with anything.”
   - Incorrect. They can communicate internally and can use NAT or VPC endpoints for outbound.

## Concept: NAT Gateway and private egress

A private subnet often needs **outbound** internet access (patching, pulling images, calling APIs) but must never accept **inbound** connections from the internet. A NAT Gateway provides exactly that asymmetry.

```text
10.0.10.0/24 (private)  route table:
  10.0.0.0/16 -> local
  0.0.0.0/0   -> nat-xxxxxxxx     (NAT Gateway)

10.0.1.0/24 (public)    route table:
  10.0.0.0/16 -> local
  0.0.0.0/0   -> igw-xxxxxxxx     (Internet Gateway)
```

The NAT Gateway is **placed in a public subnet** (so its own `0.0.0.0/0` route reaches the IGW) and is referenced by the **private** subnet's route table. It has an Elastic IP and performs source NAT.

| Property | NAT Gateway | Egress-only IGW (EIGW) |
|---|---|---|
| Protocol | IPv4 | IPv6 |
| Direction | Outbound + return only | Outbound + return only |
| Cost | Per hour + per GB | Free |
| Lives in | A public subnet | Attached to VPC (like IGW) |

> **Cost call-out:** NAT Gateway is a top-3 source of surprise AWS bills (hourly + data-processing). High-availability designs put one NAT Gateway **per AZ** (so an AZ failure does not break egress), which multiplies the cost. For S3/DynamoDB traffic, prefer a Gateway Endpoint and skip the NAT entirely. **Always delete lab NAT Gateways and release their Elastic IPs** — since Feb 2024 every public IPv4 address (Elastic IP) bills hourly whether attached or idle, so releasing it is the only way to stop the charge.

## Concept: Security Groups vs NACLs (the most-asked VPC question)

| | Security Group | Network ACL (NACL) |
|---|---|---|
| Attached to | Instance / ENI | Subnet |
| State | **Stateful** (return traffic auto-allowed) | **Stateless** (each direction evaluated separately) |
| Rules | **Allow only** | **Allow and Deny** |
| Evaluation | All rules evaluated together (any match = allow) | **Numbered, in order**, lowest number wins, implicit deny at end |
| Default | New SG: deny all inbound, allow all outbound | Default NACL: allow all; custom NACL: deny all until you add rules |
| Typical use | Primary, everyday control | Coarse subnet-wide guardrail / explicit block (e.g. ban an IP range) |

### Worked example: a browser hits a web server on 443

A client at `203.0.113.50` opens `https://` to an EC2 web server in subnet `10.0.1.0/24`. The OS picks an ephemeral source port (say `52000`); the server listens on `443`.

**Security Group on the instance (stateful):**

```text
Inbound:  ALLOW TCP 443 from 0.0.0.0/0
Outbound: (default) ALLOW all
```

That is all you need. The reply from `443 -> 52000` is **automatically allowed** outbound because the SG remembers the connection. You do **not** write an outbound rule for the ephemeral port.

**NACL on the subnet (stateless) — must allow BOTH directions:**

```text
Inbound rule  100: ALLOW TCP  443        from 0.0.0.0/0   -> the request
Outbound rule 100: ALLOW TCP  1024-65535 to   0.0.0.0/0   -> the reply (ephemeral)
```

If you forget the **outbound ephemeral-port** rule on the NACL, the request arrives but the **reply is dropped** and the client sees a timeout. This is the classic "SG looks fine but it still times out" NACL bug — and it is exactly what Flow Logs reveal (you will see an `ACCEPT` inbound and a `REJECT` outbound).

Teaching punchline:

> "Security Groups think in **connections**. NACLs think in **packets**. Stateful = you describe the conversation once. Stateless = you must describe every packet in every direction."

## Concept: VPC Endpoints and PrivateLink

| Type | Services | Mechanism | Cost |
|---|---|---|---|
| **Gateway Endpoint** | S3, DynamoDB only | Route-table entry (prefix list) | **Free** |
| **Interface Endpoint (PrivateLink)** | Most AWS services + your/SaaS services | ENI with private IP + private DNS | Per hour + per GB |

Why it matters: a private instance that only needs S3 should use an **S3 Gateway Endpoint** instead of a NAT Gateway — it is free, keeps traffic on the AWS backbone, and removes an internet egress path. Interface Endpoints/PrivateLink let you reach services (and third-party SaaS) by a **private IP inside your VPC**, so no traffic ever touches the public internet. Endpoint policies can further restrict *which* buckets/resources are reachable.

## Concept: VPC Flow Logs

Flow Logs capture metadata about IP traffic (source/dest IP and port, protocol, bytes, and **ACCEPT/REJECT**) at the VPC, subnet, or ENI level, delivered to CloudWatch Logs or S3. They are the first evidence source for "the connection silently fails":

- `REJECT` on the inbound flow → a Security Group or NACL blocked the request.
- `ACCEPT` inbound but `REJECT` outbound → a stateless NACL is missing the ephemeral-port return rule.
- No flow at all → traffic never reached the ENI (routing/IGW/NAT problem upstream).

This is the network application of the course's evidence-first methodology, and it feeds Week 16 observability and Week 19 DevSecOps.

---

# 10.5 Senior Section: Hybrid and Inter-VPC Connectivity

This section gives the senior-level mental model for connecting a VPC to **other VPCs** and to **on-premises** networks. It was previously orphaned to a specialization that no longer exists; it now lives here as required senior content. Most of it is conceptual/decision-level — students are not expected to build a Direct Connect circuit in a lab.

## The four core options

| Option | Connects | How it works | Use when |
|---|---|---|---|
| **VPC Peering** | Two VPCs (1:1) | Private, non-transitive link between two VPCs | A small number of VPCs need to talk; simple, low cost |
| **Transit Gateway (TGW)** | Many VPCs + on-prem (hub) | Regional hub-and-spoke router; transitive | You have many VPCs/accounts — avoids the N² peering mesh |
| **Site-to-Site VPN** | VPC ↔ on-prem | IPsec tunnels over the public internet | Quick, cheap on-prem connectivity; encrypted but internet-dependent |
| **Direct Connect (DX)** | VPC ↔ on-prem | Dedicated private physical circuit | Consistent low latency / high bandwidth / data-sovereignty; not over the internet |

## The non-negotiable prerequisite: non-overlapping CIDRs

Every one of these breaks if the connected networks have **overlapping CIDR ranges** — routing becomes ambiguous because two networks claim the same addresses. This is why the Class 1 subnet-math lab stressed planning address space up front, and why enterprises run **IPAM** (IP Address Management, e.g. AWS VPC IPAM) to hand out non-overlapping ranges across accounts. A senior engineer plans CIDRs *before* the first VPC is built, anticipating future peering/TGW/on-prem connections.

## Key properties to internalize

- **VPC Peering is not transitive.** If A peers with B and B peers with C, A still cannot reach C. This is the main reason large estates move to Transit Gateway.
- **Transit Gateway is transitive and scales.** N VPCs need N peering attachments to one TGW instead of N×(N−1)/2 peering connections. TGW also attaches VPN and Direct Connect, making it the central hybrid hub. It bills per attachment + per GB.
- **VPN rides the public internet** (encrypted), so latency/throughput vary; DX is a **private circuit** with predictable performance but lead time and cost to provision. A common pattern is **DX as primary with VPN as encrypted backup**.

## Decision matrix (say this in an interview)

```text
2-3 VPCs, simple, no on-prem .......... VPC Peering
Many VPCs / many accounts ............. Transit Gateway
On-prem connectivity, fast/cheap ...... Site-to-Site VPN
On-prem, predictable perf / high BW ... Direct Connect (often + VPN backup)
Reach an AWS service privately ........ VPC Endpoint / PrivateLink (not peering)
Expose a SaaS/your service privately .. PrivateLink
```

> **Scaling note:** Week 17 (AWS Landing Zones & Multi-Account) builds directly on this — a landing zone typically centralizes egress and inspection behind a Transit Gateway in a shared-network account.

---

# 11. Whiteboard Explanation

## Simple diagram

```text
AWS Region: us-east-1

VPC: 10.0.0.0/16
----------------------------------------------------

Public Subnet: 10.0.1.0/24
  Route Table:
    10.0.0.0/16 -> local
    0.0.0.0/0  -> Internet Gateway

Private Subnet: 10.0.2.0/24
  Route Table:
    10.0.0.0/16 -> local
    No direct route to Internet Gateway
```

## Traffic flow for public subnet

```text
User on Internet
      |
      v
Internet Gateway
      |
      v
Public Route Table
      |
      v
Public Subnet
      |
      v
EC2 Web Server
```

## What each component means

| Component | Meaning |
|---|---|
| VPC | Network boundary |
| Public subnet | Subnet with route to Internet Gateway |
| Private subnet | Subnet without direct internet route |
| Internet Gateway | Internet access target |
| Route table | Decides where traffic goes |
| Local route | Allows internal VPC communication |
| Default route | Sends unknown destinations to a target |

## Enterprise version of the diagram

```text
Internet Users
      |
      v
Public Load Balancer
      |
      v
Public Subnets
      |
      v
Private App Subnets
      |
      v
Private Database Subnets

Shared controls:
- Route tables
- Security groups
- Logging
- IAM permissions
- Change approval
- Cost controls
```

Explain:

In many enterprise designs, EC2 instances are not directly public. Instead, a public load balancer receives traffic, then forwards to private application servers.

---

# 12. Instructor Demo Script

## Demo title

**Create a Basic AWS VPC with Public and Private Subnets**

## Demo objective

Demonstrate how VPC, subnets, route tables, and Internet Gateway work together to create public and private network zones.

## Required setup

Instructor needs:

- AWS Console access
- AWS Region selected, for example `us-east-1`
- IAM permission to create VPC resources
- Optional AWS CLI configured
- A clean naming prefix

Recommended prefix:

```text
week5-class2-demo
```

## Demo option A: AWS Console actions

### Step 1: Open VPC service

Console actions:

1. Sign in to AWS Console.
2. Select region, for example `us-east-1`.
3. Search for **VPC**.
4. Open **Your VPCs**.

Explain:

“VPC resources are regional. Always check your selected region before creating networking resources.”

### Step 2: Create VPC

Create:

```text
Name: week5-class2-demo-vpc
CIDR: 10.0.0.0/16
```

Expected result:

VPC appears in the VPC list with CIDR `10.0.0.0/16`.

Explain:

“This is our private network boundary. Every subnet we create must fit inside this CIDR.”

### Step 3: Create public subnet

Create subnet:

```text
Name: week5-class2-demo-public-subnet
VPC: week5-class2-demo-vpc
Availability Zone: us-east-1a
CIDR: 10.0.1.0/24
```

Expected result:

Subnet appears with CIDR `10.0.1.0/24`.

Explain:

“We are calling this public, but it is not public yet. It needs routing to the Internet Gateway.”

### Step 4: Create private subnet

Create subnet:

```text
Name: week5-class2-demo-private-subnet
VPC: week5-class2-demo-vpc
Availability Zone: us-east-1a
CIDR: 10.0.2.0/24
```

Expected result:

Subnet appears with CIDR `10.0.2.0/24`.

Explain:

“This subnet will remain private because we will not give it a direct route to the Internet Gateway.”

### Step 5: Create Internet Gateway

Create:

```text
Name: week5-class2-demo-igw
```

Then attach it to:

```text
VPC: week5-class2-demo-vpc
```

Expected result:

Internet Gateway state shows attached.

Explain:

“An Internet Gateway must be attached to a VPC before it can be used in a route.”

### Step 6: Create public route table

Create:

```text
Name: week5-class2-demo-public-rt
VPC: week5-class2-demo-vpc
```

Add route:

```text
Destination: 0.0.0.0/0
Target: week5-class2-demo-igw
```

Expected result:

Route table contains:

```text
10.0.0.0/16 -> local
0.0.0.0/0  -> igw-xxxxxxxx
```

Explain:

“The local route is created automatically. The default route to the Internet Gateway is what makes this route table useful for public subnet traffic.”

### Step 7: Associate public subnet

Associate:

```text
Subnet: week5-class2-demo-public-subnet
Route table: week5-class2-demo-public-rt
```

Expected result:

The public subnet appears under explicit subnet associations.

Explain:

“This is the moment the subnet becomes public from a routing perspective.”

### Step 8: Inspect private subnet route behavior

Show the main route table or private route table.

Expected route:

```text
10.0.0.0/16 -> local
```

No route:

```text
0.0.0.0/0 -> Internet Gateway
```

Explain:

“This private subnet can talk inside the VPC, but it does not have direct internet access.”

## Demo option B: AWS CLI commands

Use this only if students are comfortable enough with CLI.

### Set variables

```bash
AWS_REGION="us-east-1"
PREFIX="week5-class2-demo"
VPC_CIDR="10.0.0.0/16"
PUBLIC_SUBNET_CIDR="10.0.1.0/24"
PRIVATE_SUBNET_CIDR="10.0.2.0/24"
AZ="us-east-1a"
```

### Create VPC

```bash
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --region $AWS_REGION \
  --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=${PREFIX}-vpc}]" \
  --query 'Vpc.VpcId' \
  --output text)

echo $VPC_ID
```

Expected output:

```text
vpc-xxxxxxxxxxxxxxxxx
```

### Enable DNS support and hostnames

```bash
aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-support "{\"Value\":true}" \
  --region $AWS_REGION

aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-hostnames "{\"Value\":true}" \
  --region $AWS_REGION
```

Explain:

“DNS support and DNS hostnames are commonly enabled in VPCs so resources can use AWS DNS behavior properly.”

### Create public subnet

```bash
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $PUBLIC_SUBNET_CIDR \
  --availability-zone $AZ \
  --region $AWS_REGION \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${PREFIX}-public-subnet}]" \
  --query 'Subnet.SubnetId' \
  --output text)

echo $PUBLIC_SUBNET_ID
```

Expected output:

```text
subnet-xxxxxxxxxxxxxxxxx
```

### Create private subnet

```bash
PRIVATE_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $PRIVATE_SUBNET_CIDR \
  --availability-zone $AZ \
  --region $AWS_REGION \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${PREFIX}-private-subnet}]" \
  --query 'Subnet.SubnetId' \
  --output text)

echo $PRIVATE_SUBNET_ID
```

Expected output:

```text
subnet-xxxxxxxxxxxxxxxxx
```

### Create and attach Internet Gateway

```bash
IGW_ID=$(aws ec2 create-internet-gateway \
  --region $AWS_REGION \
  --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=${PREFIX}-igw}]" \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID \
  --region $AWS_REGION

echo $IGW_ID
```

Expected output:

```text
igw-xxxxxxxxxxxxxxxxx
```

### Create public route table

```bash
PUBLIC_RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --region $AWS_REGION \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=${PREFIX}-public-rt}]" \
  --query 'RouteTable.RouteTableId' \
  --output text)

echo $PUBLIC_RT_ID
```

Expected output:

```text
rtb-xxxxxxxxxxxxxxxxx
```

### Add default route to Internet Gateway

```bash
aws ec2 create-route \
  --route-table-id $PUBLIC_RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID \
  --region $AWS_REGION
```

Expected output:

```json
{
  "Return": true
}
```

### Associate public subnet with public route table

```bash
aws ec2 associate-route-table \
  --subnet-id $PUBLIC_SUBNET_ID \
  --route-table-id $PUBLIC_RT_ID \
  --region $AWS_REGION
```

Expected output:

```json
{
  "AssociationId": "rtbassoc-xxxxxxxxxxxxxxxxx",
  "AssociationState": {
    "State": "associated"
  }
}
```

### Validate route table

```bash
aws ec2 describe-route-tables \
  --route-table-ids $PUBLIC_RT_ID \
  --region $AWS_REGION \
  --query 'RouteTables[0].Routes'
```

Expected output should include:

```json
[
  {
    "DestinationCidrBlock": "10.0.0.0/16",
    "GatewayId": "local",
    "State": "active"
  },
  {
    "DestinationCidrBlock": "0.0.0.0/0",
    "GatewayId": "igw-xxxxxxxxxxxxxxxxx",
    "State": "active"
  }
]
```

### Add a NAT Gateway for private egress

First allocate an Elastic IP, then create the NAT Gateway **in the public subnet**:

```bash
EIP_ALLOC_ID=$(aws ec2 allocate-address \
  --domain vpc \
  --region $AWS_REGION \
  --tag-specifications "ResourceType=elastic-ip,Tags=[{Key=Name,Value=${PREFIX}-nat-eip}]" \
  --query 'AllocationId' \
  --output text)

NAT_GW_ID=$(aws ec2 create-nat-gateway \
  --subnet-id $PUBLIC_SUBNET_ID \
  --allocation-id $EIP_ALLOC_ID \
  --region $AWS_REGION \
  --tag-specifications "ResourceType=natgateway,Tags=[{Key=Name,Value=${PREFIX}-nat}]" \
  --query 'NatGateway.NatGatewayId' \
  --output text)

# NAT Gateways take ~1-2 minutes to become available. Wait before adding the route:
aws ec2 wait nat-gateway-available \
  --nat-gateway-ids $NAT_GW_ID \
  --region $AWS_REGION

echo $NAT_GW_ID
```

Create a **private** route table and point its default route at the NAT Gateway, then associate the private subnet:

```bash
PRIVATE_RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --region $AWS_REGION \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=${PREFIX}-private-rt}]" \
  --query 'RouteTable.RouteTableId' \
  --output text)

aws ec2 create-route \
  --route-table-id $PRIVATE_RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --nat-gateway-id $NAT_GW_ID \
  --region $AWS_REGION

aws ec2 associate-route-table \
  --subnet-id $PRIVATE_SUBNET_ID \
  --route-table-id $PRIVATE_RT_ID \
  --region $AWS_REGION
```

Explain:

“The private subnet now reaches the internet **outbound** through the NAT Gateway, but nothing on the internet can initiate a connection inward.”

### Add an S3 Gateway Endpoint (free, keeps S3 traffic off the NAT)

```bash
aws ec2 create-vpc-endpoint \
  --vpc-id $VPC_ID \
  --service-name com.amazonaws.${AWS_REGION}.s3 \
  --vpc-endpoint-type Gateway \
  --route-table-ids $PRIVATE_RT_ID \
  --region $AWS_REGION \
  --tag-specifications "ResourceType=vpc-endpoint,Tags=[{Key=Name,Value=${PREFIX}-s3-endpoint}]"
```

Explain:

“This adds an S3 prefix-list route to the private route table. Now S3 traffic from private instances goes straight to S3 over the AWS network instead of out through the (billed) NAT Gateway.”

### Demonstrate Security Group vs NACL statefulness

Create a Security Group that allows inbound HTTPS — note we do **not** add an outbound rule for the reply:

```bash
SG_ID=$(aws ec2 create-security-group \
  --group-name ${PREFIX}-web-sg \
  --description "Lab web SG (stateful)" \
  --vpc-id $VPC_ID \
  --region $AWS_REGION \
  --query 'GroupId' \
  --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp --port 443 --cidr 0.0.0.0/0 \
  --region $AWS_REGION
```

Explain: the reply to an inbound 443 connection is allowed automatically — the SG is stateful, so no outbound rule is needed.

Now show the stateless NACL equivalent. A custom NACL must allow **both** the inbound request **and** the outbound ephemeral-port reply:

```bash
NACL_ID=$(aws ec2 create-network-acl \
  --vpc-id $VPC_ID \
  --region $AWS_REGION \
  --query 'NetworkAcl.NetworkAclId' \
  --output text)

# Inbound: allow the HTTPS request
# NOTE: create-network-acl-entry requires the IP protocol NUMBER, not a name.
# 6 = TCP (17 = UDP, 1 = ICMP, -1 = all). Passing "tcp" returns InvalidParameterValue.
aws ec2 create-network-acl-entry \
  --network-acl-id $NACL_ID --rule-number 100 \
  --protocol 6 --port-range From=443,To=443 \
  --cidr-block 0.0.0.0/0 --rule-action allow --ingress \
  --region $AWS_REGION

# Outbound: MUST allow the ephemeral-port reply, or the request times out
aws ec2 create-network-acl-entry \
  --network-acl-id $NACL_ID --rule-number 100 \
  --protocol 6 --port-range From=1024,To=65535 \
  --cidr-block 0.0.0.0/0 --rule-action allow --egress \
  --region $AWS_REGION
```

Teaching point: comment out the outbound rule and the connection times out even though the inbound rule looks correct — the canonical stateless-NACL bug.

### Enable VPC Flow Logs

This assumes a CloudWatch Logs delivery role exists (your instructor may pre-create `flowlogsRole`; otherwise create a role that `vpc-flow-logs.amazonaws.com` can assume with permission to write to CloudWatch Logs).

```bash
aws logs create-log-group \
  --log-group-name /vpc/${PREFIX}-flowlogs \
  --region $AWS_REGION

aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids $VPC_ID \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name /vpc/${PREFIX}-flowlogs \
  --deliver-logs-permission-arn arn:aws:iam::<ACCOUNT_ID>:role/flowlogsRole \
  --region $AWS_REGION
```

Explain: with `--traffic-type ALL` the log records both `ACCEPT` and `REJECT` flows — exactly the evidence you need when a connection "silently" fails.

## Common demo failure points

| Failure | Cause | Recovery |
|---|---|---|
| CIDR overlap error | Another VPC or subnet uses overlapping range | Choose a different CIDR |
| UnauthorizedOperation | Missing IAM permission | Use correct lab role or instructor account |
| InvalidInternetGatewayID.NotFound | Wrong region or variable value | Check region and echo variable |
| Route already exists | Default route was already created | Inspect route table before creating |
| Subnet does not appear public | Missing route table association | Associate subnet to public route table |
| CLI returns empty output | Wrong profile or region | Run `aws sts get-caller-identity` and verify region |

## Cleanup steps

If continuing into Class 2, do **not** delete these resources.

If this was only a demo and not needed later:

1. Delete route table associations if needed.
2. Delete custom route table.
3. Detach Internet Gateway.
4. Delete Internet Gateway.
5. Delete subnets.
6. Delete VPC.

CLI cleanup example (delete the billed resources FIRST, then the free ones):

```bash
# 1. NAT Gateway (billed hourly + per GB) — delete first, then wait for it to vanish
aws ec2 delete-nat-gateway \
  --nat-gateway-id $NAT_GW_ID \
  --region $AWS_REGION
aws ec2 wait nat-gateway-deleted \
  --nat-gateway-ids $NAT_GW_ID \
  --region $AWS_REGION

# 2. Release the Elastic IP (an UNATTACHED EIP still bills hourly)
aws ec2 release-address \
  --allocation-id $EIP_ALLOC_ID \
  --region $AWS_REGION

# 3. Flow Logs + log group
aws logs delete-log-group \
  --log-group-name /vpc/${PREFIX}-flowlogs \
  --region $AWS_REGION

# 4. (Interface endpoints, if any, are billed too — delete with delete-vpc-endpoints.
#    The S3 Gateway endpoint is free but should still be removed before deleting the VPC.)

# 5. Now the free networking pieces
aws ec2 detach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID \
  --region $AWS_REGION

aws ec2 delete-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --region $AWS_REGION

aws ec2 delete-subnet \
  --subnet-id $PUBLIC_SUBNET_ID \
  --region $AWS_REGION

aws ec2 delete-subnet \
  --subnet-id $PRIVATE_SUBNET_ID \
  --region $AWS_REGION

aws ec2 delete-vpc \
  --vpc-id $VPC_ID \
  --region $AWS_REGION
```

Cost warning:

VPCs, subnets, route tables, Internet Gateways, Security Groups, NACLs, and S3 **Gateway** Endpoints are **free**. The resources that cost money in this class are: **NAT Gateway** (per hour + per GB — a top source of surprise bills), **Elastic IP / public IPv4 addresses** (since Feb 2024 AWS bills **every** public IPv4 address at ~$0.005/hr — whether the Elastic IP is attached *or* idle — so the only way to stop the charge is to release it), **Interface Endpoints / PrivateLink** (per hour + per GB), any **EC2** instances, and **data transfer**. Delete the NAT Gateway and **release its Elastic IP** as soon as the lab ends. In production, prefer an S3 Gateway Endpoint over routing S3 traffic through a NAT.

---

# 13. Student Lab Manual

## Lab title

**Build a Basic AWS VPC with Public and Private Subnets**

## Lab objective

Create a **production-shaped, multi-AZ** AWS VPC network foundation with:

- One VPC
- **Two public subnets** (one per AZ)
- **Two private subnets** (one per AZ)
- One Internet Gateway
- One public route table (shared by the public subnets)
- One private route table
- Correct route table associations

> **Why multi-AZ is the baseline, not a stretch goal:** real production VPCs are *always* spread across at least two Availability Zones so that the loss of one AZ does not take the whole application down. Building single-AZ first and "adding AZ2 later" teaches a habit you will have to unlearn. We build two AZs from the start.

## Estimated time

45 to 60 minutes

## Student prerequisites

Students should have:

- AWS Console access
- AWS CLI installed, optional
- Basic knowledge of CIDR and subnets
- Permission to create VPC resources
- Region selected consistently, recommended `us-east-1`

## Architecture overview

```text
VPC: student-vpc
CIDR: 10.10.0.0/16

Public Subnet AZ-a:   10.10.1.0/24  -> public route table  (0.0.0.0/0 -> IGW)
Public Subnet AZ-b:   10.10.2.0/24  -> public route table  (0.0.0.0/0 -> IGW)
Private Subnet AZ-a:  10.10.11.0/24 -> private route table (0.0.0.0/0 -> NAT GW)
Private Subnet AZ-b:  10.10.12.0/24 -> private route table (0.0.0.0/0 -> NAT GW)

NAT Gateway: in Public Subnet AZ-a (has Elastic IP)
S3 Gateway Endpoint: attached to the private route table
```

> Note: the two private subnets share one NAT Gateway here to keep lab cost down. In production you would run **one NAT Gateway per AZ** (one private route table per AZ) so an AZ outage does not break egress for the other AZ — but that doubles NAT cost, so we do not do it in the lab.

## Step-by-step student instructions

### Step 1: Choose your region

Use:

```text
us-east-1
```

or the region assigned by your instructor.

Write your region here:

```text
Region: ______________________
```

### Step 2: Create the VPC

In AWS Console:

1. Go to **VPC**.
2. Select **Your VPCs**.
3. Select **Create VPC**.
4. Choose **VPC only**.
5. Enter:

```text
Name tag: student-vpc
IPv4 CIDR: 10.10.0.0/16
```

6. Create the VPC.

Expected result:

You should see a new VPC named:

```text
student-vpc
```

with CIDR:

```text
10.10.0.0/16
```

### Step 3: Create the public subnet

1. Go to **Subnets**.
2. Select **Create subnet**.
3. Choose your `student-vpc`.
4. Enter:

```text
Subnet name: student-public-a
Availability Zone: us-east-1a
IPv4 subnet CIDR block: 10.10.1.0/24
```

5. Create the subnet, using AZ **us-east-1a** and name **student-public-a**.

6. Repeat to create the **second public subnet** in a different AZ:

```text
Subnet name: student-public-b
Availability Zone: us-east-1b
IPv4 subnet CIDR block: 10.10.2.0/24
```

Expected result:

```text
student-public-a  10.10.1.0/24  us-east-1a
student-public-b  10.10.2.0/24  us-east-1b
```

### Step 4: Create the two private subnets

1. Go to **Subnets** → **Create subnet**, choose `student-vpc`.
2. Create the first private subnet:

```text
Subnet name: student-private-a
Availability Zone: us-east-1a
IPv4 subnet CIDR block: 10.10.11.0/24
```

3. Create the second private subnet in the other AZ:

```text
Subnet name: student-private-b
Availability Zone: us-east-1b
IPv4 subnet CIDR block: 10.10.12.0/24
```

Expected result:

```text
student-private-a  10.10.11.0/24  us-east-1a
student-private-b  10.10.12.0/24  us-east-1b
```

### Step 5: Create the Internet Gateway

1. Go to **Internet Gateways**.
2. Select **Create internet gateway**.
3. Enter:

```text
Name tag: student-igw
```

4. Create the Internet Gateway.
5. Select the Internet Gateway.
6. Choose **Actions**.
7. Choose **Attach to VPC**.
8. Select:

```text
student-vpc
```

Expected result:

The Internet Gateway should show as attached.

### Step 6: Create the public route table

1. Go to **Route Tables**.
2. Select **Create route table**.
3. Enter:

```text
Name: student-public-rt
VPC: student-vpc
```

4. Create the route table.

Expected result:

You should see a route table named:

```text
student-public-rt
```

### Step 7: Add internet route

1. Select `student-public-rt`.
2. Go to **Routes**.
3. Select **Edit routes**.
4. Add route:

```text
Destination: 0.0.0.0/0
Target: Internet Gateway
Target value: student-igw
```

5. Save changes.

Expected route table:

```text
10.10.0.0/16 -> local
0.0.0.0/0   -> student-igw
```

### Step 8: Associate both public subnets with the public route table

1. Select `student-public-rt`.
2. Go to **Subnet associations** → **Edit subnet associations**.
3. Select **both** `student-public-a` and `student-public-b`.
4. Save association.

Expected result:

Both public subnets are now explicitly associated with the public route table (a single public route table is shared across AZs).

### Step 9: Add a NAT Gateway and a private route table

This gives the private subnets **outbound** internet without inbound exposure.

1. Go to **NAT Gateways** → **Create NAT gateway**. Place it in **student-public-a**, connectivity type **Public**, and **Allocate Elastic IP**. Name it `student-nat`. Wait until its state is **Available** (1–2 min).
2. Go to **Route Tables** → **Create route table**, name `student-private-rt`, VPC `student-vpc`.
3. On `student-private-rt`, **Edit routes** → add `Destination 0.0.0.0/0`, `Target: NAT Gateway → student-nat`.
4. On `student-private-rt`, **Edit subnet associations** → select **both** `student-private-a` and `student-private-b`.

Expected private route table:

```text
10.10.0.0/16 -> local
0.0.0.0/0    -> nat-xxxxxxxx
```

### Step 10: Add an S3 Gateway Endpoint (free)

1. Go to **Endpoints** → **Create endpoint**.
2. Service category **AWS services**; search `s3`; choose the **Gateway** type endpoint `com.amazonaws.us-east-1.s3`.
3. Select VPC `student-vpc`; under **Route tables**, check `student-private-rt`.
4. Create. A prefix-list route for S3 now appears in the private route table.

Why: private instances reach S3 directly over the AWS network instead of through the (billed) NAT Gateway.

### Step 11: Enable VPC Flow Logs

1. Select `student-vpc` → **Actions** → **Create flow log**.
2. Filter **All**, destination **CloudWatch Logs**, log group `/vpc/student-flowlogs` (create it first in CloudWatch if needed), and select/PassRole the Flow Logs delivery role your instructor provided.
3. Create. You will use these logs as evidence in the troubleshooting activity.

### Step 12: Draw the final traffic flow

Create a diagram like this:

```text
Internet
   |
   v
Internet Gateway  <-----------------------+
   |                                       |
   v                                       |
Public Route Table                  NAT Gateway (in public subnet, Elastic IP)
   |                                       ^
   v                                       | 0.0.0.0/0
Public Subnets (a, b)              Private Route Table
                                           ^
                                           |
                                   Private Subnets (a, b)
                                     - 0.0.0.0/0 -> NAT (outbound only)
                                     - S3 prefix list -> S3 Gateway Endpoint
                                     - local VPC traffic
```

## Optional AWS CLI validation commands

### Confirm identity

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "UserId": "...",
  "Account": "...",
  "Arn": "..."
}
```

### List VPCs

```bash
aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=student-vpc" \
  --query 'Vpcs[*].[VpcId,CidrBlock,State]' \
  --output table
```

Expected output:

```text
----------------------------------------
|             DescribeVpcs             |
+----------------------+---------------+----------+
|  vpc-xxxxxxxxxxxxxxx |  10.10.0.0/16 | available|
+----------------------+---------------+----------+
```

### List subnets

```bash
aws ec2 describe-subnets \
  --filters "Name=tag:Name,Values=student-*" \
  --query 'Subnets[*].[Tags[?Key==`Name`].Value|[0],SubnetId,CidrBlock,AvailabilityZone]' \
  --output table
```

Expected output:

```text
student-public-a    subnet-xxxx   10.10.1.0/24    us-east-1a
student-public-b    subnet-yyyy   10.10.2.0/24    us-east-1b
student-private-a   subnet-zzzz   10.10.11.0/24   us-east-1a
student-private-b   subnet-wwww   10.10.12.0/24   us-east-1b
```

### Inspect route tables

```bash
aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=<your-vpc-id>" \
  --query 'RouteTables[*].[RouteTableId,Routes[*].DestinationCidrBlock,Routes[*].GatewayId]' \
  --output json
```

## Validation checklist

Students should verify:

- [ ] VPC created with CIDR `10.10.0.0/16`
- [ ] Two public subnets (`10.10.1.0/24` AZ-a, `10.10.2.0/24` AZ-b)
- [ ] Two private subnets (`10.10.11.0/24` AZ-a, `10.10.12.0/24` AZ-b)
- [ ] Internet Gateway created and attached to VPC
- [ ] Public route table has `0.0.0.0/0 -> Internet Gateway`; both public subnets associated
- [ ] NAT Gateway created in a public subnet with an Elastic IP
- [ ] Private route table has `0.0.0.0/0 -> NAT Gateway`; both private subnets associated
- [ ] S3 Gateway Endpoint added to the private route table
- [ ] VPC Flow Logs enabled
- [ ] Private subnets do NOT have a direct route to the Internet Gateway
- [ ] Student can explain why the public subnet is public and the private subnet is private
- [ ] Student can explain stateful (SG) vs stateless (NACL) filtering

## Troubleshooting tips

| Problem | Likely Cause | Fix |
|---|---|---|
| Cannot create VPC | IAM permission issue | Ask instructor to verify role permissions |
| CIDR block rejected | Invalid or overlapping CIDR | Use assigned CIDR exactly |
| Internet Gateway not available as route target | IGW not attached to VPC | Attach IGW to VPC first |
| Subnet still not public | Route table not associated | Associate public subnet with public route table |
| Route missing | Route was not saved | Edit route table and add route again |
| Working in wrong VPC | Multiple VPCs exist | Verify VPC ID and Name tag |
| Cannot find resource | Wrong region selected | Confirm AWS Region |

## Cleanup steps

If a later session (Week 7 EC2 lab) will reuse your VPC, your instructor may tell you to keep it. Otherwise, clean up the **billed** resources first.

1. Delete any EC2 instances if created.
2. **Delete the NAT Gateway and wait for it to finish deleting; then release its Elastic IP** (an idle Elastic IP still bills).
3. Delete VPC Flow Logs and the CloudWatch log group.
4. Delete any Interface Endpoints (billed); the S3 Gateway Endpoint is free but remove it too.
5. Detach any custom NACL (subnet reverts to the default NACL) and delete it; delete lab Security Groups.
6. Remove route table associations if needed.
7. Delete custom route tables.
8. Detach and delete the Internet Gateway.
9. Delete subnets.
10. Delete the VPC.

## Reflection questions

1. What makes a subnet public?
2. Why is the private subnet not directly reachable from the internet?
3. What does the Internet Gateway do?
4. What does the route table control?
5. What would happen if the public subnet was not associated with the public route table?
6. Why would an enterprise use separate public and private subnets?

## Graded mini-lab: prove stateful vs stateless filtering

This is the lab that makes the SG-vs-NACL distinction stick. You will deliberately create the classic stateless-NACL failure and then fix it.

Setup (instructor may provide a running web server on TCP 80/443 in the public subnet, or use any reachable test instance):

1. On the **instance's Security Group**, add only:

```text
Inbound: ALLOW TCP 443 from your IP
(leave outbound at the default ALLOW all)
```

Confirm you can reach the server (`curl -I https://<public-ip>`). The reply works with no outbound SG rule — **that is statefulness**. Record this.

2. Create a **custom NACL** on the public subnet and associate it. Add only:

```text
Inbound rule 100: ALLOW TCP 443 from 0.0.0.0/0
```

(Do **not** add any outbound rule yet.) Retry `curl -I https://<public-ip>`.

- [ ] Predict before testing: will it work?
- [ ] Observed result: ______ (expected: **timeout** — the request gets in, but the ephemeral-port reply is blocked outbound by the stateless NACL).

3. Add the missing outbound rule to the NACL:

```text
Outbound rule 100: ALLOW TCP 1024-65535 to 0.0.0.0/0
```

Retry. It now works.

4. Record your conclusion in one sentence: *why* did step 2 fail when the Security Group was correct?

Expected answer: NACLs are **stateless**, so the return traffic on the ephemeral port must be explicitly allowed outbound; the Security Group succeeded because it is **stateful** and auto-allows the reply.

> Cleanup: detach the custom NACL (the subnet reverts to the default NACL) and delete it, and delete the test SG, when done.

## Appendix: the same VPC in Terraform (forward-link to Week 14/15)

The labs above used the Console/CLI to build intuition. In real work you would never click this by hand — you would define it as code. Here is the **equivalent** VPC foundation in Terraform/OpenTofu so students see where Week 14/15 goes. Do **not** apply this in class unless your instructor directs; read it to connect the concepts.

```hcl
# providers.tf — works with both Terraform and OpenTofu (`tofu`)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# main.tf
resource "aws_vpc" "main" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "student-vpc" }
}

resource "aws_subnet" "public" {
  for_each          = { a = "10.10.1.0/24", b = "10.10.2.0/24" }
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "us-east-1${each.key}"
  tags              = { Name = "student-public-${each.key}" }
}

resource "aws_subnet" "private" {
  for_each          = { a = "10.10.11.0/24", b = "10.10.12.0/24" }
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "us-east-1${each.key}"
  tags              = { Name = "student-private-${each.key}" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "student-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "student-public-rt" }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
```

Discipline reminder (the course's "render/plan before apply" rule): **always** run `terraform plan` (or `tofu plan`) and read the planned changes before `terraform apply`. Never apply a VPC change you have not read in the plan output.

---

# 14. Troubleshooting Activity

## Incident title

**Public EC2 Instance Is Unreachable After VPC Build**

## Business impact

A development team deployed a test web server in what they believe is a public subnet. The application is supposed to be available for internal testing over HTTP, but users cannot reach it from their browser.

This delays testing and blocks the team from validating the application.

## Symptoms

Users report:

```text
The browser times out when accessing the public IP.
```

Instructor-provided evidence:

```text
VPC exists: student-vpc
Subnet name: student-public-subnet
Internet Gateway exists: student-igw
EC2 instance state: running
EC2 has public IPv4: yes
Security group allows HTTP from 0.0.0.0/0: yes
```

Failed command:

```bash
curl http://<public-ip>
```

Output:

```text
curl: (28) Failed to connect to <public-ip> port 80 after 10000 ms: Connection timed out
```

## Starting evidence

Route table currently associated with the subnet:

```text
Routes:
10.10.0.0/16 -> local
```

Missing route:

```text
0.0.0.0/0 -> Internet Gateway
```

## Student investigation steps

Students should investigate:

1. Is the EC2 instance running?
2. Does the EC2 instance have a public IPv4 address?
3. Is the security group allowing HTTP or SSH?
4. Is there an Internet Gateway?
5. Is the Internet Gateway attached to the VPC?
6. Does the route table have a default route to the Internet Gateway?
7. Is the public subnet associated with the correct route table?
8. Is the network ACL blocking traffic? (Recall from this class: a stateless NACL missing the outbound ephemeral-port rule causes a timeout even when the Security Group is correct.)
9. Is the application actually running on the expected port?
10. **Check VPC Flow Logs as evidence.** A `REJECT` inbound points to an SG/NACL block; an `ACCEPT` inbound with a `REJECT` outbound points to the stateless-NACL return-traffic bug; **no flow record at all** points to a routing problem (missing IGW/route/association) upstream of any filtering.

## Expected root cause

The subnet is named `student-public-subnet`, but it is not associated with a route table that has:

```text
0.0.0.0/0 -> Internet Gateway
```

The subnet is not public from a routing perspective.

## Correct resolution

1. Create or select the public route table.
2. Add route:

```text
Destination: 0.0.0.0/0
Target: student-igw
```

3. Associate `student-public-subnet` with the public route table.
4. Retry connectivity.

Expected successful result:

```bash
curl http://<public-ip>
```

Example output:

```html
<h1>Hello from Week 5 VPC Lab</h1>
```

## Common wrong paths

| Wrong Path | Why It Happens | Correction |
|---|---|---|
| Recreate the EC2 instance | Students assume compute is the problem | Check network routing first |
| Open all security group ports | Students think firewall is always the issue | Verify route table and IGW first |
| Rename the subnet to public | Students think naming changes behavior | Routing determines public/private behavior |
| Create another Internet Gateway | Students do not realize existing IGW is unattached or unused | Attach and route to the correct IGW |
| Change VPC CIDR | Students misdiagnose the issue as IP range problem | CIDR is not the issue here |

## Instructor hints

Use these hints gradually:

1. “What makes a subnet public?”
2. “Does the subnet have a route to the Internet Gateway?”
3. “Which route table is the subnet actually associated with?”
4. “Is naming enough to make a subnet public?”
5. “What does `0.0.0.0/0` mean?”

## Preventive action

In real environments:

- Use standard VPC modules or templates.
- Require architecture review for network changes.
- Use naming standards and tagging.
- Document subnet purpose.
- Validate route table associations after changes.
- Use infrastructure as code to avoid manual drift.
- Add automated checks for expected routes.

---

# 15. Scenario-Based Discussion Questions

## Question 1

A database team asks to place an RDS database in a public subnet for easier access. What should the cloud team recommend?

Expected response themes:

- Avoid placing databases in public subnets.
- Use private subnets.
- Use controlled access paths such as VPN, bastion, Systems Manager, or application access.
- Reduce attack surface.

Instructor follow-up:

“What is the difference between convenience and secure access?”

## Question 2

A subnet is named `prod-public-subnet`, but it has no route to an Internet Gateway. Is it public?

Expected response themes:

- No.
- The route table determines public subnet behavior.
- Naming is only metadata.

Instructor follow-up:

“What would you check in the AWS Console to prove this?”

## Question 3

Why do enterprises usually separate public and private subnets?

Expected response themes:

- Security segmentation
- Reduced exposure
- Tiered architecture
- Better control of traffic flow
- Compliance and audit expectations

Instructor follow-up:

“How would this apply to web, app, and database tiers?”

## Question 4

A team wants one large subnet for everything because it is simpler. What are the risks?

Expected response themes:

- Poor segmentation
- Security risk
- Harder troubleshooting
- Less flexibility
- Poor production design

Instructor follow-up:

“What may be acceptable in a demo but not acceptable in production?”

## Question 5

What is the business impact of incorrect route table configuration?

Expected response themes:

- Application downtime
- Failed deployments
- Blocked testing
- Security exposure
- Delayed releases

Instructor follow-up:

“How could a DevOps pipeline validate network assumptions before deployment?”

## Question 6

When should students use diagrams in cloud networking work?

Expected response themes:

- Before implementation
- During troubleshooting
- During architecture reviews
- For handoff to operations
- For explaining traffic flow

Instructor follow-up:

“What should every useful network diagram include?”

## Question 7

How does IAM relate to VPC work?

Expected response themes:

- IAM controls who can create or modify network resources.
- Incorrect permissions can block network work.
- Too much permission can create security risk.
- Cloud teams should use least privilege.

Instructor follow-up:

“What permissions should a junior engineer have in production?”

## Question 8

Why is it dangerous to troubleshoot cloud networking only by guessing?

Expected response themes:

- Wastes time
- Can introduce new problems
- May open security holes
- May increase cost
- Can make root cause harder to find

Instructor follow-up:

“What is a safe troubleshooting order for public subnet access?”

---

# 16. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple choice

What is an AWS VPC?

A. A virtual server used to run applications  
B. A logically isolated network in AWS  
C. A public IP address range owned by AWS  
D. A database subnet group  

**Answer:** B  
**Explanation:** A VPC is a logically isolated network where AWS resources are deployed.

## Question 2: Multiple choice

What makes a subnet public?

A. The subnet name includes the word public  
B. The subnet has a large CIDR block  
C. The subnet route table has a route to an Internet Gateway  
D. The subnet is in us-east-1  

**Answer:** C  
**Explanation:** Public subnet behavior depends on route table configuration, not name.

## Question 3: True or false

An Internet Gateway must be attached to a VPC before it can be used for routing.

**Answer:** True  
**Explanation:** The Internet Gateway must be attached to the VPC and referenced in a route table.

## Question 4: Multiple choice

Which route usually allows internet-bound traffic from a public subnet?

A. `10.0.0.0/16 -> local`  
B. `0.0.0.0/0 -> Internet Gateway`  
C. `127.0.0.1/32 -> local`  
D. `10.0.1.0/24 -> subnet`  

**Answer:** B  
**Explanation:** `0.0.0.0/0` represents the default route for destinations not otherwise matched.

## Question 5: Short answer

What is the purpose of the local route in a VPC route table?

**Answer:** It allows resources within the VPC CIDR range to communicate with each other.  
**Explanation:** AWS creates the local route automatically for internal VPC traffic.

## Question 6: Multiple choice

An EC2 instance has a public IP and a security group allowing HTTP. Users still cannot reach it. What should you check next?

A. Whether the subnet has a route to an Internet Gateway  
B. Whether the VPC name is correct  
C. Whether the instance has an IAM role  
D. Whether S3 is enabled  

**Answer:** A  
**Explanation:** Public IP and security group are not enough. The subnet needs proper routing to the Internet Gateway.

## Question 7: True or false

A private subnet cannot communicate with any resources inside the VPC.

**Answer:** False  
**Explanation:** A private subnet can communicate inside the VPC through the local route if security controls allow it.

## Question 8: Short answer

Why should databases usually be placed in private subnets?

**Answer:** To prevent direct internet exposure and reduce attack surface.  
**Explanation:** Databases should be accessed through controlled private paths, usually from application servers.

## Question 9: Multiple choice

Which Azure service is closest to AWS VPC?

A. Azure Blob Storage  
B. Azure Virtual Network  
C. Azure Monitor  
D. Azure Key Vault  

**Answer:** B  
**Explanation:** Azure Virtual Network, or VNet, is the closest Azure equivalent to AWS VPC.

## Question 10: Multiple choice

Which GCP service is closest to AWS VPC?

A. Cloud Storage  
B. Cloud SQL  
C. VPC Network  
D. Cloud Build  

**Answer:** C  
**Explanation:** GCP VPC Network is the closest GCP equivalent.

## Question 11: Troubleshooting short answer

A subnet has an Internet Gateway attached to the VPC, but no default route in the subnet route table. Is the subnet public?

**Answer:** No.  
**Explanation:** The subnet route table must route `0.0.0.0/0` to the Internet Gateway.

## Question 12: Troubleshooting multiple choice

A student created a public route table but forgot to associate the public subnet with it. What happens?

A. The subnet automatically becomes public  
B. The subnet continues using its current associated route table  
C. The VPC is deleted  
D. The Internet Gateway becomes detached  

**Answer:** B  
**Explanation:** Creating a route table does not affect a subnet until it is associated.

---

# 17. Homework Assignment

## Assignment title

**Design and Explain a Public and Private Subnet AWS VPC**

## Scenario

A small company is deploying a web application in AWS. The company needs:

- A public-facing web tier
- A private application tier
- A private database tier later
- Controlled internet access
- Clear network documentation for the cloud team

For this assignment, focus only on the VPC foundation from Class 1.

## Student tasks

Students must create a written design that includes:

1. VPC CIDR block
2. At least one public subnet
3. At least one private subnet
4. Internet Gateway
5. Public route table
6. Private route table
7. Explanation of public vs private subnet behavior
8. Basic traffic flow diagram
9. Short AWS, Azure, and GCP comparison section

## Expected deliverables

Students submit:

1. Network diagram
2. CIDR plan
3. Route table explanation
4. 1-page written explanation
5. Screenshot or CLI output showing their VPC resources, if lab resources were created
6. Reflection answers

## Submission format

Accepted formats:

- Markdown file
- PDF
- Word document
- Git repository README

Recommended file name:

```text
week-05-class-02-vpc-design.md
```

## Estimated completion time

1.5 to 2 hours

## Grading criteria

| Criteria | Points |
|---|---:|
| Correct VPC and subnet CIDR plan | 20 |
| Correct public and private subnet explanation | 20 |
| Correct route table explanation | 20 |
| Clear diagram | 15 |
| Security reasoning | 10 |
| Azure/GCP comparison | 5 |
| Writing clarity | 10 |
| Total | 100 |

## Optional advanced challenge

Extend your design across two Availability Zones:

```text
Public Subnet AZ1:  10.10.1.0/24
Private Subnet AZ1: 10.10.2.0/24
Public Subnet AZ2:  10.10.3.0/24
Private Subnet AZ2: 10.10.4.0/24
```

Explain how this improves availability.

---

# 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Thinking subnet name controls public/private behavior | Names feel meaningful in the console | Teach that route tables control behavior |
| Creating Internet Gateway but not attaching it | Students think create means active | Always verify IGW attachment |
| Adding route but forgetting subnet association | Route table concepts are new | Check subnet associations after route changes |
| Using overlapping CIDR blocks | CIDR planning is unfamiliar | Use assigned CIDRs and diagram first |
| Working in wrong region | AWS Console region can change | Confirm region before every lab |
| Building resources in default VPC by mistake | Default VPC is already present | Verify VPC ID and Name tag |
| Opening security group too broadly | Students want quick success | Explain least privilege and lab-only exceptions |
| Confusing route tables and security groups | Both affect connectivity | Route tables define path, security groups allow or deny traffic |
| Deleting resources needed for Class 2 | Students rush cleanup | Tell students not to delete unless instructed |
| Assuming private subnet means isolated from everything | Private means no direct internet route | Explain local VPC communication |

---

# 19. Real-World Enterprise Scenario

## Scenario

A company is launching an internal order management application in AWS. The application has:

- A web interface used by employees
- An application backend
- A database
- Integration with internal enterprise systems
- Security and compliance requirements

The cloud platform team is asked to design the first version of the AWS network.

## Constraints

- Databases must not be internet-facing.
- Application servers should not be directly exposed.
- Public access should be limited to approved entry points.
- Network design must support future growth.
- CIDR ranges must not overlap with existing corporate networks.
- Changes must go through review and approval.
- Costs should be controlled.
- The design must be documented for operations handoff.

## How this class topic applies

Students learn the first layer of this design:

- VPC defines the network boundary.
- Public subnet can host public entry points such as load balancers.
- Private subnet can host application or database resources.
- Route tables define traffic paths.
- Internet Gateway enables internet routing for public subnets.

## What a DevOps Engineer would do

- Use the VPC design in CI/CD deployment workflows.
- Make sure app deployment targets the correct subnets.
- Document subnet IDs and environment-specific variables.
- Avoid deploying private workloads into public subnets by mistake.

## What a Cloud Engineer would do

- Design the VPC and subnet architecture.
- Coordinate CIDR allocation.
- Implement route tables and gateways.
- Prepare Terraform modules for repeatable deployment.
- Validate routing and security controls.

## What an SRE would do

- Understand the traffic path during incidents.
- Troubleshoot reachability problems.
- Review whether network design supports reliability.
- Document runbooks for connectivity failures.
- Identify monitoring needs for network-dependent services.

---

# 20. Instructor Tips

## Teaching tips

- Start with diagrams before opening the console.
- Repeat the key idea: “Routing determines whether a subnet is public.”
- Avoid going too deep into binary subnet math unless the class is ready.
- Use the same CIDR examples throughout the class.
- Ask students to explain traffic flow out loud.
- Make students point to the route table that makes the subnet public.

## Pacing tips

- Do not spend more than 25 minutes on CIDR.
- Keep advanced networking topics as previews only.
- Save NAT Gateway, NACLs, and VPC Endpoints for Class 2.
- If students are struggling, do the lab in guided mode.
- If students are advanced, ask them to add a second AZ.

## Lab support tips

When helping students, check in this order:

1. Region
2. VPC ID
3. CIDR values
4. Internet Gateway attachment
5. Route table route
6. Subnet association
7. Tags and naming

## Helping struggling students

Use simple language:

- “VPC is the house.”
- “Subnets are rooms.”
- “Route tables are directions.”
- “Internet Gateway is the front door to the internet.”
- “Private subnet is a room with no direct outside door.”

Have them draw the diagram before touching AWS Console again.

## Challenging advanced students

Ask them to:

- Create two public and two private subnets across two AZs
- Explain high availability benefits
- Write AWS CLI commands to describe their VPC
- Draft a Terraform-style variable map for subnet CIDRs
- Compare AWS subnet behavior with Azure and GCP

---

# 21. Student Outcome Checklist

## Students should be able to explain

- [ ] What an AWS VPC is
- [ ] What a CIDR block represents
- [ ] What a subnet is
- [ ] Difference between public and private subnet
- [ ] What an Internet Gateway does
- [ ] What a route table does
- [ ] Meaning of `0.0.0.0/0`
- [ ] Why databases should normally be private
- [ ] Difference between naming a subnet public and routing it publicly
- [ ] AWS VPC vs Azure VNet vs GCP VPC Network at a high level

## Students should be able to build or configure

- [ ] VPC
- [ ] Public subnet
- [ ] Private subnet
- [ ] Internet Gateway
- [ ] Public route table
- [ ] Default route to Internet Gateway
- [ ] Subnet association
- [ ] Basic VPC diagram

## Students should be able to troubleshoot

- [ ] Missing Internet Gateway
- [ ] Internet Gateway not attached
- [ ] Missing default route
- [ ] Wrong route table association
- [ ] Wrong AWS Region
- [ ] Wrong VPC selected
- [ ] Misleading subnet names
- [ ] Basic public subnet reachability issue

---

# 22. Class Completion Checklist

## Instructor checklist before ending class

- [ ] Students understand that route tables determine public/private subnet behavior.
- [ ] Students created a multi-AZ VPC (2 public + 2 private subnets) successfully.
- [ ] Students attached an Internet Gateway and associated the public route table.
- [ ] Students added a NAT Gateway and pointed the private route table at it.
- [ ] Students can explain stateful (Security Group) vs stateless (NACL) filtering.
- [ ] Students added an S3 Gateway Endpoint and can explain when to use Interface Endpoints/PrivateLink.
- [ ] Students enabled VPC Flow Logs and can read ACCEPT/REJECT as evidence.
- [ ] Students can name the hybrid-connectivity options (peering, TGW, VPN, DX) and when to use each.
- [ ] Students deleted (or were told to keep) the NAT Gateway and released its Elastic IP.
- [ ] Students completed or started the homework diagram.

## Student checklist before leaving class

- [ ] I can explain what a VPC is.
- [ ] I can explain what a subnet is.
- [ ] I can identify my VPC CIDR.
- [ ] I can identify my public and private subnet CIDRs.
- [ ] I can find my route table.
- [ ] I can explain why my public subnet is public.
- [ ] I can explain why my private subnet is private.
- [ ] I can find my Internet Gateway and my NAT Gateway.
- [ ] I can draw the traffic flow for both a public and a private subnet.
- [ ] I can explain why a stateless NACL needs an outbound ephemeral-port rule.
- [ ] I deleted the NAT Gateway and released its Elastic IP (or was told to keep them).

## Items to verify before moving on

Students should record (and, if cleaning up, confirm deletion of the billed items):

```text
AWS Region:
VPC ID:
VPC CIDR:
Public Subnet IDs (AZ-a, AZ-b):
Private Subnet IDs (AZ-a, AZ-b):
Internet Gateway ID:
NAT Gateway ID + Elastic IP allocation:
Public Route Table ID:
Private Route Table ID:
S3 Gateway Endpoint ID:
Flow Logs log group:
```

This week's networking foundation feeds directly into:

- Week 6 Cloud Security & IAM (identity, KMS, Secrets Manager, governance on top of this network)
- Week 7 EC2, storage, and databases deployed into these subnets
- Week 14/15 Terraform, which codifies this VPC (see the Terraform appendix in Section 13)
- Week 16 Observability, which consumes the Flow Logs enabled here
- Week 17 Landing Zones, which scales the hybrid/Transit Gateway patterns to many accounts

---

## Class Artifacts & Validation

This class **owns and operates** the VPC foundation in the backing lab `labs/terraform-aws-foundations/`: a reusable Terraform root module that calls a `modules/vpc` child to stand up a multi-AZ VPC (public + private subnets carved with `cidrsubnet()`), an Internet Gateway with a public route table and associations, an optional NAT Gateway gated behind `enable_nat_gateway`, a locked-down default Security Group, and VPC Flow Logs to an encrypted CloudWatch log group. This same module is **applied to and destroyed from a real AWS account** (see the live-evidence row) and is **reused in the Week 23/24 capstone**. The Console/CLI walkthroughs in this class (NACLs, S3 Gateway Endpoint, Flow Logs) build the same topology the module codifies. All gates below were run live in this environment: `./validate.sh` reports **10 passed, 0 failed** (exit 0).

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/terraform-aws-foundations/solution/main.tf` | terraform | VPC root module (calls `modules/vpc`, default tags, remote-state wiring) | `terraform -chdir=labs/terraform-aws-foundations/solution validate` | PASS — `Success! The configuration is valid.` |
| 2 | `labs/terraform-aws-foundations/solution/modules/vpc/main.tf` | terraform | the VPC child module: VPC, public/private subnets (`cidrsubnet`), IGW, route tables + associations, NAT gateway (flag-gated), deny-all default SG, VPC flow logs | `terraform -chdir=labs/terraform-aws-foundations/solution/modules/vpc validate` | PASS — `Success! The configuration is valid.` |
| 3 | `labs/terraform-aws-foundations/solution/variables.tf` + `outputs.tf` | terraform | inputs (`vpc_cidr`, `az_count`, `enable_nat_gateway`) and outputs (`vpc_id`, public/private `subnet_ids`) | covered by `terraform validate` on the root (#1) | PASS |
| 4 | `labs/terraform-aws-foundations/docs/architecture.mmd` | Mermaid diagram | the traffic-flow / public-vs-private-subnet diagram for the VPC this class builds | renders in any Mermaid viewer; matches the deployed VPC | PASS (renders; matches live VPC) |
| 5 | `labs/terraform-aws-foundations/tests/test_terraform_structure.py` | python (stdlib) | 18 structural tests — incl. `test_private_subnet_offset_avoids_overlap` (non-colliding subnet CIDRs) and the NAT-gating asserts | `python3 -m unittest discover -s labs/terraform-aws-foundations/tests` | PASS — `Ran 18 tests ... OK` |
| 6 | `labs/terraform-aws-foundations/broken/main.tf` | terraform fixture | reproducible defect: `aws_route.private_nat` references a counted `aws_nat_gateway.this.id` without `[0]` — the troubleshooting exercise | `terraform -chdir=labs/terraform-aws-foundations/broken validate` | PASS (gate) — **fails by design**: `Error: Missing resource instance key` (exit 1 = expected) |
| 7 | `labs/terraform-aws-foundations/starter/modules/vpc/main.tf` | terraform | starter with 4 `TODO(student)` blocks (subnets, associations, NAT gating) — the student build target | `terraform -chdir=labs/terraform-aws-foundations/starter validate` (after completing TODOs) | PASS once completed (incomplete by design until then) |
| 8 | `labs/terraform-aws-foundations/LIVE-AWS-VALIDATION.txt` | live evidence | real `apply` → API-verified VPC (4 subnets, 1 IGW, 3 route tables, CIDR `10.77.0.0/16`) → `destroy` on account 071146695791, us-east-1; confirmed clean; total cost $0 | `terraform apply` / `terraform destroy` (run against a real AWS account) | PASS — **LIVE**, see `labs/terraform-aws-foundations/LIVE-AWS-VALIDATION.txt` (`Apply complete! Resources: 19 added` … `Destroy complete! Resources: 19 destroyed`) |
| 9 | `labs/terraform-aws-foundations/validate.sh` | shell | aggregate gate runner (fmt, validate ×3, unittest, broken-fixture negative gate, checkov ×3, starter-fails negative gate) | `./labs/terraform-aws-foundations/validate.sh` | PASS — `== 10 passed, 0 failed ==` (exit 0) |

> The NACL / S3-Gateway-Endpoint / Flow-Logs Console + AWS-CLI walkthroughs in Sections 9–12 are taught as live AWS operations (with cost/cleanup warnings). The Terraform module above is the codified, idempotent, and **independently apply/destroy-verified** form of the same VPC; the NACL statefulness demo is intentionally a live CLI exercise (the classic stateless-return-traffic bug) rather than committed IaC.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — the VPC root + child module (`*.tf`); the NACL/endpoint/flow-log Console steps are taught as live AWS ops over that same topology.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured — `terraform fmt -check` + `init -backend=false` + `validate` pass on root and module; full `./validate.sh` = `10 passed, 0 failed` (verified live this session).
- [x] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions — `starter/modules/vpc/main.tf` (4 `TODO(student)` blocks) and `solution/`.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, cost notes — `labs/terraform-aws-foundations/README.md`.
- [x] **Cleanup/teardown** is provided and idempotent — README ships idempotent local cleanup + `terraform destroy`; this class repeatedly warns to delete the NAT Gateway and **release its Elastic IP**; the live run confirmed a clean destroy (no remaining VPC).
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise — README "Instructor answer key" (Lab B + troubleshooting fix) and this class file (quiz/homework answer keys).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `broken/main.tf` (the counted-NAT `[0]` defect) fails `terraform validate` deterministically; plus the live NACL ephemeral-port return-traffic bug.
- [x] **Expected outputs** are shown for demos and labs — `terraform validate` success strings, expected resource counts (18 default / 21 with NAT), and the SG-vs-NACL "timeout then fixed" results are shown.
- [x] **Cost & security warnings** present wherever cloud resources or secrets are involved — explicit NAT/EIP/public-IPv4/Interface-Endpoint cost warnings; deny-all default SG, flow logs, no committed `tfvars`/state (`.gitignore`).
- [x] **Cross-references** to the module repo and to prior/next weeks are correct (numbers verified) — links to the backing lab, Week 4, Week 5 Class 1, Weeks 14/15 (Terraform), 16, 17, 23/24 capstone.
- [x] The **artifact manifest** (§4.2) is present and every path resolves — verified with `ls`; all nine paths exist, and the live-evidence and validate.sh gates were re-run this session.
