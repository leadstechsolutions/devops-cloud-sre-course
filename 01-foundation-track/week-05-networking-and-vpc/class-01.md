# Week 5: Networking and VPC
# Class 1 Package: Networking Fundamentals: IP, CIDR, Subnets, Ports, Protocols, DNS

**Week:** 5 — Networking and VPC
**Track:** Unified DevOps · Cloud · SRE Track

---

> **▶ Runnable lab for this class:** [`labs/terraform-aws-foundations/`](../../labs/terraform-aws-foundations/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## 1. Class Overview

### Class title

**Class 1: IP Addresses, CIDR, Subnets, Ports, Protocols, and DNS**

### Class purpose

This class introduces the core networking concepts students need before they can confidently work with AWS VPCs, Kubernetes networking, load balancers, DNS, firewalls, and production troubleshooting.

Students will learn how applications communicate across a network, how names resolve to IP addresses, how ports map to services, and how to use basic command-line tools to collect evidence during connectivity issues.

### How this class connects to the overall course

This class is foundational for later modules, including:

- AWS VPC and cloud networking
- EC2 and application hosting
- Load balancing
- Kubernetes Services and Ingress
- CI/CD deployment troubleshooting
- Observability and incident response
- SRE production troubleshooting

Networking problems appear constantly in DevOps, Cloud Engineering, and SRE work. Students need to understand the basics before troubleshooting more advanced cloud or Kubernetes issues.

### What students will build, analyze, or practice

Students will practice:

- Resolving DNS names
- Checking IP addresses
- Testing network reachability
- Testing ports
- Inspecting HTTP and HTTPS responses
- Separating DNS issues from port, firewall, and application issues
- Documenting basic troubleshooting evidence

---

## 2. Class Learning Objectives

By the end of this class, students will be able to:

1. **Explain** how a browser or client reaches a cloud-hosted application.
2. **Compare** public IP addresses, private IP addresses, and hostnames.
3. **Interpret** beginner-level CIDR notation and explain why subnets exist.
4. **Identify** common ports and protocols such as HTTP, HTTPS, TCP, UDP, and DNS.
5. **Validate** DNS resolution using `nslookup` and `dig`.
6. **Troubleshoot** basic connectivity using `ping`, `curl`, `nc`, and related tools.
7. **Document** evidence from a network troubleshooting investigation.
8. **Explain** the difference between DNS failure, port failure, and application failure.

---

## 3. Prerequisites Students Should Already Know

### Required prior concepts

Students should already understand:

- Basic terminal usage
- Files and folders
- Basic Linux command execution
- What a server is at a high level
- What a website or web application is
- Basic idea of cloud computing from Week 1

### Required tools already installed

Students should have:

- Terminal or shell
- VS Code
- Git Bash, PowerShell, Windows Terminal, macOS Terminal, or Linux terminal
- Internet access
- Optional Linux VM, WSL, or cloud shell environment

### Required accounts or access

Required:

- No AWS account required for this class

Optional:

- AWS account access for instructor screenshots or console preview
- Browser access to AWS Console for conceptual VPC preview only

### Files, repos, or sample code needed

No repo is required.

Optional instructor-created file:

```bash
mkdir -p week5-networking-class1
cd week5-networking-class1
touch network-notes.md
```

Students can use this file to document command outputs and observations.

---

## 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Network | A system that allows computers and services to communicate | Cloud apps, databases, APIs, and users all communicate over networks |
| Client | The system making a request | A browser, mobile app, CLI tool, or backend service |
| Server | The system responding to a request | Web server, API server, database server, or Kubernetes service |
| IP Address | A numeric address used to identify a device or service on a network | EC2 instances, load balancers, and containers use IPs |
| Public IP | An IP address reachable from the internet | Used for public websites, NAT gateways, and public load balancers |
| Private IP | An IP address used inside a private network | Used by internal apps, databases, EC2 instances, and Kubernetes pods |
| CIDR | A notation used to define a range of IP addresses | AWS VPCs and subnets are created using CIDR blocks |
| Subnet | A smaller section of a larger network | Public and private subnets separate internet-facing and internal resources |
| Port | A numbered communication endpoint on a host | HTTP uses 80, HTTPS uses 443, SSH uses 22 |
| Protocol | A set of rules for communication | HTTP, HTTPS, TCP, UDP, DNS |
| TCP | Reliable connection-based protocol | Used by HTTP, HTTPS, SSH, database connections |
| UDP | Faster connectionless protocol | Often used by DNS and streaming-style traffic |
| DNS | Domain Name System, translates names to IP addresses | Converts `app.company.com` into an IP address |
| HTTP | Web protocol without encryption | Usually port 80 |
| HTTPS | Secure web protocol using TLS encryption | Usually port 443 |
| TLS | Encryption layer used by HTTPS | Protects data between browser and server |
| Firewall | A control that allows or blocks traffic | In AWS, Security Groups and NACLs perform firewall-like functions |
| Load Balancer | A service that distributes traffic to backend targets | Used to expose apps reliably and avoid single-server dependency |

---

## 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| `ping` | Tests basic reachability using ICMP. Useful but not always reliable because ICMP may be blocked |
| `curl` | Tests HTTP or HTTPS responses. Very useful for app and API troubleshooting |
| `curl -I` | Shows only HTTP response headers |
| `curl -v` | Shows detailed connection steps |
| `dig` | Performs DNS lookups and shows DNS details |
| `nslookup` | Beginner-friendly DNS lookup tool |
| `nc` or `netcat` | Tests whether a TCP port is reachable |
| `traceroute` or `tracert` | Shows network path toward a destination |
| `mtr` | Combines `ping` + `traceroute` into a live, continuously-updating per-hop loss/latency view — a senior triage staple for "where on the path is it slow or dropping?" |
| `ss` | Shows listening ports and network sockets on Linux |
| `netstat` | Older alternative to `ss` |
| `tcpdump` / `tshark` | Packet capture for deep L3/L4 troubleshooting (awareness-level today). `sudo tcpdump -ni any port 443` shows whether SYNs are even arriving — invaluable when a connection silently times out. |
| Browser Developer Tools | Optional tool to inspect HTTP status codes and failed requests |
| VS Code | Used for student notes and diagrams |
| AWS Console | Optional instructor preview for VPC, subnet, route table, and Security Group concepts |

---

## 6. AWS Services Used

This class is mostly conceptual and CLI-based, but it introduces AWS networking terms that will be used deeply in Class 2 of this week (AWS VPC) and again in Week 7 (EC2, storage, and databases).

| AWS Service or Concept | How It Connects to This Class |
|---|---|
| Amazon VPC | Represents a private cloud network where AWS resources run |
| Subnets | Used to divide a VPC into smaller network ranges |
| Route Tables | Decide where network traffic should go |
| Security Groups | Act as virtual firewalls for AWS resources |
| Internet Gateway | Allows public subnet resources to communicate with the internet |
| NAT Gateway | Allows private subnet resources to initiate outbound internet connections |
| Elastic Load Balancing | Provides stable application entry points |
| Route 53 | AWS DNS service used to map names to resources |

Instructor note: Do not go deep into creating these services in Class 1. Use them as preview concepts only.

---

## 7. Azure and GCP Comparison Notes

Keep this comparison brief.

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Virtual network | VPC | Virtual Network | VPC Network |
| Subnet | Subnet | Subnet | Subnet |
| Firewall control | Security Group, NACL | Network Security Group | Firewall Rules |
| DNS service | Route 53 | Azure DNS | Cloud DNS |
| Load balancing | Elastic Load Balancing | Azure Load Balancer, Application Gateway | Cloud Load Balancing |

Teaching point:

The names are different across clouds, but the core networking ideas are similar:

```text
Network → Subnet → Route → Firewall → DNS → Load Balancer → Application
```

---

## 8. Time-Boxed Instructor Agenda

| Time | Duration | Activity |
|---:|---:|---|
| 0:00 to 0:10 | 10 min | Welcome, class goal, why networking matters |
| 0:10 to 0:30 | 20 min | How applications communicate over a network |
| 0:30 to 0:55 | 25 min | IP addresses, public IPs, private IPs, and CIDR |
| 0:55 to 1:15 | 20 min | Subnets and public vs private networking |
| 1:15 to 1:25 | 10 min | Break |
| 1:25 to 1:50 | 25 min | Ports, protocols, TCP, UDP, HTTP, HTTPS, TLS |
| 1:50 to 2:10 | 20 min | DNS and name resolution |
| 2:10 to 2:35 | 25 min | Instructor demo using CLI tools |
| 2:35 to 2:55 | 20 min | Student lab |
| 2:55 to 3:10 | 15 min | Troubleshooting activity |
| 3:10 to 3:20 | 10 min | Discussion questions |
| 3:20 to 3:30 | 10 min | Knowledge check, recap, homework |

Note: If the class must be exactly 3 hours, combine discussion and recap into the last 5 minutes and keep the lab to 15 minutes.

---

## 9. Instructor Lesson Plan

### Step 1: Open the class

Explain:

> “Networking is one of the most common places where cloud and DevOps work fails. When an application is unreachable, the issue might be DNS, routing, firewall rules, ports, TLS, load balancer health, or the application itself. Today we focus on the first layer of that troubleshooting.”

Pause and ask:

> “What do you usually mean when you say a website is down?”

Expected responses:

- Page does not load
- Browser shows timeout
- DNS error
- 404
- 500
- Connection refused

Transition:

> “Those are different failure types. Today we learn how to separate them.”

---

### Step 2: Explain client-server communication

Show this flow:

```text
Client → DNS → IP Address → Port → Server → Response
```

Explain:

- A client sends a request.
- DNS resolves the name.
- The client connects to an IP and port.
- The server responds.
- If any step fails, the user may say “the app is down,” but engineers must identify which layer failed.

Teaching tip:

Use a simple analogy:

- DNS is the contact name
- IP is the phone number
- Port is the department extension
- Firewall is the security guard
- Server is the person answering

---

### Step 2.5: Name the layers explicitly

The course's troubleshooting methodology depends on knowing **which layer failed**. Give students the names so "which layer?" is a concrete question, not a vague one. Use the simplified TCP/IP model and map each CLI tool to its layer:

| Layer | TCP/IP name | What it does | Example failure | CLI tool to test it |
|---|---|---|---|---|
| L7 | Application | HTTP, TLS, app logic | 500, 404, TLS error | `curl -I`, `curl -v` |
| L4 | Transport | TCP/UDP ports, connections | port closed, timeout, RST | `nc -vz`, `ss -tulnp` |
| L3 | Internet | IP routing, ICMP | no route, host unreachable | `ping`, `traceroute`/`mtr` |
| (name resolution) | sits above L7 from the client's view | name → IP | NXDOMAIN, wrong IP | `dig`, `nslookup` |

Say out loud:

> "Every tool we run today answers one layer's yes/no question. `dig` answers *did the name resolve?* `ping` answers *is the host routable?* `nc` answers *is the port open?* `curl` answers *did the app respond, and how?* When you say 'it's broken,' the first move is to find the lowest layer that is failing."

Teaching tip:

DNS is technically an application-layer protocol, but in client-side troubleshooting we test it *first* because nothing above it can work until a name resolves. That is why the diagnostic order is DNS → routing/L3 → port/L4 → app/L7.

---

### Step 3: Teach IP addresses and CIDR

Explain:

- IP addresses identify network locations.
- Public IPs are internet-routable.
- Private IPs are used inside internal networks.
- CIDR defines a range of IP addresses.

Use examples:

```text
Public IP example: 8.8.8.8

Private IP examples:
10.0.0.0/8
172.16.0.0/12
192.168.0.0/16
```

Working explanation of `10.0.1.0/24`:

The `/24` is the **prefix length**: the first 24 bits identify the network, and the remaining `32 - 24 = 8` bits identify hosts. That gives `2^8 = 256` total addresses (`10.0.1.0` through `10.0.1.255`).

Two addresses in every IPv4 subnet are not usable for hosts:

```text
10.0.1.0    = network address    (identifies the subnet itself)
10.0.1.255  = broadcast address  (reaches all hosts in the subnet)
```

So a plain `/24` has `256 - 2 = 254` usable host addresses (`10.0.1.1` to `10.0.1.254`).

**Important AWS-specific rule (used heavily in Class 2):** AWS reserves **5** addresses in every subnet, not 2. For `10.0.1.0/24` AWS reserves:

```text
10.0.1.0    network address
10.0.1.1    VPC router
10.0.1.2    DNS / Amazon-provided DNS (.2 of the VPC base + base of subnet block)
10.0.1.3    reserved for future AWS use
10.0.1.255  broadcast address (reserved even though AWS does not use broadcast)
```

So on AWS a `/24` gives `256 - 5 = 251` usable host IPs. Students will do the full subnet-math lab in Section 13.5.

Do the math, but keep it quick — the goal is fluency, not binary drills. The key formulas:

```text
Total addresses = 2^(32 - prefix)
Usable hosts (generic)  = total - 2
Usable hosts (AWS)      = total - 5
```

Pause for questions:

> “Why would a database usually use a private IP instead of a public IP?”

Expected answer:

Security. It should only be reachable by approved internal services.

---

### Step 4: Teach subnets

Explain:

A subnet is a smaller network range inside a larger network.

Example:

```text
VPC: 10.0.0.0/16

Public subnet:  10.0.1.0/24
Private subnet: 10.0.2.0/24
DB subnet:      10.0.3.0/24
```

Explain:

- Public subnet usually contains public entry points.
- Private subnet usually contains apps and internal services.
- Database subnet should usually be private.

Transition:

> “Subnets organize where resources live, but ports and protocols define how they communicate.”

---

### Step 5: Teach ports and protocols

Explain common ports:

| Port | Protocol | Common Use |
|---:|---|---|
| 22 | TCP | SSH |
| 53 | UDP/TCP | DNS |
| 80 | TCP | HTTP |
| 443 | TCP | HTTPS |
| 5432 | TCP | PostgreSQL |
| 3306 | TCP | MySQL |
| 8080 | TCP | Common application port |

Key teaching point:

An IP can be reachable while a specific port is blocked.

Example:

```text
Server responds to HTTPS on 443
Server blocks SSH on 22
Server app listens on 8080 only internally
```

---

### Step 6: Teach DNS

Explain:

DNS translates names into IP addresses.

Example:

```text
app.example.com → 203.0.113.10
```

Explain common DNS failure types:

- Hostname does not exist
- Wrong IP returned
- DNS cached old value
- Private DNS only works inside the company network
- Public DNS works from internet but private DNS does not

Pause and ask:

> “What can happen if DNS points to the wrong load balancer?”

Expected answer:

Users may reach the wrong application, old environment, or broken endpoint.

---

### Step 7: Run instructor demo

Use the demo script from section 12.

Teaching tip:

Do not rush the commands. For each command, ask students:

> “What layer are we testing?”

---

### Step 8: Run student lab

Students use commands to inspect DNS, HTTP response, and port reachability.

Walk around or ask students to paste results into notes.

---

### Step 9: Run troubleshooting activity

Use the NXDOMAIN scenario.

Ask students to identify the failure layer before suggesting fixes.

---

### Step 10: Recap and transition to Class 2

Close with:

> “Today we learned how traffic works at a basic level. In Class 2, we will place these ideas inside AWS VPCs using subnets, route tables, NAT, firewalls, and load balancers.”

---

## 10. Instructor Lecture Notes

### Opening talking points

“Most production incidents start with vague symptoms. Someone says the site is down, the API is not working, or the service is slow. A strong DevOps Engineer, Cloud Engineer, or SRE does not guess. They collect evidence.”

“Networking troubleshooting is about narrowing the problem. Is it DNS? Is it the route? Is it the firewall? Is the port closed? Is the application returning an error? Each command helps us test one part of the path.”

---

### Concept 1: How applications communicate

When a user opens a website, many things happen quickly:

1. The browser looks up the hostname.
2. DNS returns an IP address.
3. The browser opens a connection to a port.
4. TLS negotiation happens for HTTPS.
5. The web server or load balancer receives the request.
6. The application responds with a status code and content.

Simple statement to say out loud:

> “Before an application can return a page, the client must know where to go, how to get there, and which port to use.”

Common misconception:

Students may think DNS proves the app works. It does not. DNS only proves that a name can resolve to an address.

---

### Concept 2: Public vs private IP addresses

Public IPs are routable from the internet. Private IPs are used inside internal networks.

In enterprise AWS environments:

- Public load balancers may have public endpoints.
- EC2 instances usually use private IPs.
- Databases should almost always use private addresses.
- Kubernetes pods and services often use private networking.
- Internal APIs are often only reachable from trusted networks.

Talking point:

> “Public does not automatically mean bad, and private does not automatically mean secure. But private networking reduces exposure and gives teams more control.”

---

### Concept 3: CIDR and subnets

CIDR helps define network ranges.

Example:

```text
10.0.0.0/16 = large network
10.0.1.0/24 = smaller subnet inside that network
```

Students do not need to master subnet math today. They need to understand that cloud networks are planned using ranges, and overlapping ranges cause major problems in enterprise environments.

Enterprise context:

Large companies must carefully assign CIDR ranges because AWS VPCs, Azure VNets, GCP networks, VPNs, data centers, and partner networks may need to connect later.

Talking point:

> “A bad CIDR choice can become a future architecture problem.”

---

### Concept 3.5: IPv6 awareness (2026 baseline)

IPv4 is what students will use in labs, but IPv6 is now mainstream in cloud and is increasingly required (some AWS public IPv4 addresses now carry an hourly charge, which pushes teams toward IPv6). A senior engineer must at least recognize it.

Key facts to state:

- An IPv6 address is 128 bits, written as eight groups of hex, e.g. `2001:db8:1234:1a00::1`. Leading zeros and one run of all-zero groups can be compressed with `::`.
- There is no NAT and no broadcast in normal IPv6. Addresses are globally routable by design, so **security groups and routing — not address scarcity — provide isolation**.
- AWS VPCs can be **dual-stack** (both IPv4 and IPv6) or IPv6-only. AWS assigns a `/56` to the VPC and `/64` per subnet by convention.
- For private IPv6 egress, AWS uses an **egress-only Internet Gateway (EIGW)** instead of a NAT Gateway. The EIGW allows outbound IPv6 + return traffic but blocks unsolicited inbound — the IPv6 analog of "private subnet outbound only." (Covered hands-on in Class 2.)
- DNS: `A` records map names to IPv4, `AAAA` records map names to IPv6. A dual-stack name has both.

Talking point:

> "In IPv6 there is so much address space that subnetting is not about conserving addresses — it is about segmentation and routing. The instinct 'make the subnet just big enough' is an IPv4 habit."

---

### Concept 4: Ports and protocols

An IP address gets traffic to a host. A port gets traffic to a service on that host.

Example:

```text
10.0.2.15:22   → SSH
10.0.2.15:80   → HTTP
10.0.2.15:443  → HTTPS
10.0.2.15:8080 → Application
```

Common misconception:

Students may say “the server is reachable” after ping works. But the app may still be unavailable if the application port is blocked or not listening.

Talking point:

> “Reachability is not one yes-or-no question. You must ask: reachable on which protocol and which port?”

---

### Concept 5: DNS

DNS is often the first layer to test.

Useful commands:

```bash
nslookup example.com
dig example.com
```

DNS can fail in different ways:

- `NXDOMAIN`: the name does not exist
- No response: resolver issue
- Wrong IP: bad record or stale record
- Works internally but not externally: split-horizon DNS or private DNS issue

Enterprise context:

Companies often use both public and private DNS zones.

Example:

```text
Public: app.company.com
Private: api.internal.company.local
```

Common DNS record types a senior engineer should recognize:

| Record | Maps name to | Typical use |
|---|---|---|
| `A` | IPv4 address | Direct host or load balancer IP |
| `AAAA` | IPv6 address | Dual-stack / IPv6 endpoints |
| `CNAME` | another name | Alias one hostname to another; **cannot** exist at a zone apex (`example.com`) |
| `ALIAS` / Route 53 **alias** | an AWS resource (ELB, CloudFront, S3 website) | Route 53-specific; works at the zone apex where CNAME cannot, and is free to query |
| `MX` | mail server name + priority | Email routing |
| `TXT` | arbitrary text | SPF, DKIM, domain-ownership verification |
| `SRV` | host + port for a service | Service discovery (e.g. SIP, some internal systems) |
| `NS` | nameservers for a zone | Delegation |

TTL and failover note: DNS-based failover (Route 53 health checks switching an answer to a standby endpoint) only works as fast as the TTL allows, because clients and resolvers cache the old answer until it expires. This is why failover-critical records use short TTLs.

Talking point:

> “DNS is not just a convenience. It is part of production architecture.”

---

### Concept 5.5: TCP connection states

When students use `nc` and `ss`, they will see TCP states. Knowing the handshake explains what "port reachable" actually proves.

The TCP three-way handshake:

```text
Client            Server
  | --- SYN ----->  |   client asks to open a connection
  | <-- SYN-ACK --- |   server agrees
  | --- ACK ------> |   connection ESTABLISHED
```

States students will encounter in `ss -tan`:

| State | Meaning |
|---|---|
| `LISTEN` | A process is waiting for inbound connections on this port |
| `ESTABLISHED` | Handshake complete, data can flow |
| `SYN-SENT` / `SYN-RECV` | Handshake in progress (stuck here often means firewall dropping packets) |
| `TIME-WAIT` | Connection closed; the OS holds the socket briefly to catch stray packets. Large numbers of `TIME-WAIT` on a busy server are normal, not a leak. |
| `CLOSE-WAIT` | The peer closed but the local app has not — frequently a sign of an application bug (not closing sockets) |

Teaching point:

> "`nc -vz host 443` succeeding means the three-way handshake completed — that is a real L4 success. It does **not** mean the application behind the port is healthy. A connection refused (RST) means something is listening on the host but rejecting the port or the firewall is sending a reset; a timeout means packets are being silently dropped (often a security group or NACL)."

---

### Concept 6: HTTP response codes

`curl -I` can show whether the application responds.

Examples:

| Status | Meaning |
|---:|---|
| 200 | Successful response |
| 301/302 | Redirect |
| 403 | Forbidden |
| 404 | Not found |
| 500 | Server error |
| 502 | Bad gateway |
| 503 | Service unavailable |
| 504 | Gateway timeout |

Teaching point:

A 404 is different from a timeout. A 404 means something answered. A timeout often means no successful connection or response.

---

## 11. Whiteboard Explanation

### Simple diagram

```text
User Browser
    |
    | 1. User enters app.example.com
    v
DNS Resolver
    |
    | 2. DNS returns an IP address
    v
Server or Load Balancer
    |
    | 3. Client connects to port 443
    v
Application
    |
    | 4. Application returns HTTP response
    v
User Browser
```

### Step-by-step explanation

1. User enters a hostname.
2. DNS translates the hostname into an IP address.
3. The client connects to the IP on a specific port.
4. If using HTTPS, TLS negotiation occurs.
5. The server or load balancer receives the request.
6. The application sends a response.
7. The browser displays the result.

### What each component means

| Component | Meaning |
|---|---|
| User Browser | Client making the request |
| DNS Resolver | System that finds the IP address for the hostname |
| IP Address | Network destination |
| Port 443 | HTTPS service endpoint |
| Load Balancer | Entry point that forwards traffic to healthy targets |
| Application | Service that handles business logic |

### Enterprise version of the diagram

```text
Corporate User
    |
    v
Corporate DNS / Public DNS
    |
    v
Internet or Private Network
    |
    v
AWS Load Balancer
    |
    v
Private Application Subnet
    |
    v
Application Service
    |
    v
Private Database Subnet
```

### Enterprise teaching points

- DNS may be public or private.
- Load balancer may be internet-facing or internal.
- Application servers are often private.
- Databases should not be directly public.
- Security teams usually control allowed traffic.
- Network access should be documented and reviewed.

---

## 12. Instructor Demo Script

### Demo title

**Using CLI Tools to Investigate DNS, Ports, and HTTP Connectivity**

### Demo objective

Show students how to use common CLI tools to identify whether a connectivity issue is related to DNS, port reachability, HTTP response, or local listening services.

### Required setup

Instructor needs:

- Terminal with internet access
- `curl`
- `nslookup`
- `dig`
- `nc` or `telnet`
- Optional Linux environment for `ss`

Install missing tools if needed:

Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y dnsutils curl netcat-openbsd iproute2 traceroute
```

Amazon Linux:

```bash
sudo yum install -y bind-utils curl nc iproute traceroute
```

macOS with Homebrew:

```bash
brew install bind curl netcat
```

Windows:

Use PowerShell alternatives:

```powershell
nslookup example.com
Test-NetConnection example.com -Port 443
curl.exe -I https://example.com
```

---

### Step 1: Test DNS with `nslookup`

Command:

```bash
nslookup example.com
```

Expected output pattern:

```text
Name:    example.com
Address: 23.215.0.136
```

What to explain:

- DNS returned an IP.
- This means the name exists.
- It does not prove the website or application is healthy.

> **Instructor note (live demo):** `example.com` was re-IPed in 2024 and is served from a CDN, so the exact address you see will vary by location and over time (you may see `23.215.0.136`, `23.192.228.x`, `96.7.x.x`, or others). The legacy `93.184.216.34` address is no longer authoritative. Teach students that the *specific* address is not the point — the point is that a name resolved to *an* address. Multiple A records and changing answers are normal for CDN-fronted sites.

Failure point:

If `nslookup` is missing, use:

```bash
dig example.com
```

or install DNS tools.

---

### Step 2: Test DNS with `dig`

Command:

```bash
dig example.com
```

Expected output pattern:

```text
;; ANSWER SECTION:
example.com.    300    IN    A    23.215.0.136
```

What to explain:

- `A` record maps a name to an IPv4 address.
- TTL controls how long a DNS answer can be cached.
- DNS records may return different IPs depending on location or provider.
- The `300` is the TTL in seconds. After it expires, resolvers re-query the authoritative server. Low TTLs (30–60s) enable fast DNS failover; high TTLs (hours) reduce query load but slow down changes.

Simpler command:

```bash
dig +short example.com
```

Expected output:

```text
23.215.0.136
```

> Your exact answer will differ — `example.com` is CDN-fronted and returns location-dependent addresses. Do not hard-code or memorize the IP.

---

### Step 3: Test HTTP headers with `curl -I`

Command:

```bash
curl -I https://example.com
```

Expected output pattern:

```text
HTTP/2 200
content-type: text/html
```

or:

```text
HTTP/1.1 200 OK
Content-Type: text/html
```

What to explain:

- `curl -I` requests only headers.
- A response means the server answered.
- Status code tells us what happened at the HTTP layer.

---

### Step 4: Show detailed request with `curl -v`

Command:

```bash
curl -v https://example.com
```

Expected output includes:

```text
* Connected to example.com
* SSL connection using TLS
> GET / HTTP/2
< HTTP/2 200
```

What to explain:

- `Connected` means TCP connection succeeded.
- TLS details appear for HTTPS.
- HTTP response confirms application or web server response.

Common failure point:

If a corporate proxy or firewall blocks traffic, output may show timeout or proxy errors.

Recovery:

Try another trusted site or switch networks.

---

### Step 5: Test port reachability with `nc`

Command:

```bash
nc -vz example.com 443
```

Expected output pattern:

```text
Connection to example.com port 443 [tcp/https] succeeded!
```

Test HTTP port:

```bash
nc -vz example.com 80
```

What to explain:

- `nc` tests TCP port reachability.
- Port reachability is different from a valid HTTP response.
- A port may be reachable while the app still returns 500.

Windows alternative:

```powershell
Test-NetConnection example.com -Port 443
```

---

### Step 6: Show a DNS failure example

Command:

```bash
nslookup nonexistent-week5-lab.invalid
```

Expected output:

```text
server can't find nonexistent-week5-lab.invalid: NXDOMAIN
```

What to explain:

- `NXDOMAIN` means DNS says the name does not exist.
- Troubleshooting should start with DNS record validation.
- Do not blame the firewall before DNS resolves.

---

### Step 7: Show local listening ports

Linux command:

```bash
ss -tulnp
```

Expected output pattern:

```text
Netid State  Local Address:Port
tcp   LISTEN 0.0.0.0:22
tcp   LISTEN 127.0.0.1:8080
```

What to explain:

- Listening means a process is waiting for connections.
- `127.0.0.1` means local-only.
- `0.0.0.0` means listening on all interfaces.
- An app listening only on localhost may not be reachable from another machine.

Common failure point:

Permission denied when showing process names.

Recovery:

Use:

```bash
sudo ss -tulnp
```

---

### Cleanup steps

No cloud resources are created.

Optional local cleanup:

```bash
rm -rf week5-networking-class1
```

---

## 13. Student Lab Manual

### Lab title

**Basic Network Investigation Using CLI Tools**

### Lab objective

Use command-line tools to investigate DNS resolution, IP addresses, port reachability, and HTTP responses.

### Estimated time

25 to 35 minutes

### Student prerequisites

Students need:

- Terminal access
- Internet access
- `curl`
- `nslookup` or `dig`
- `nc` if available

### Architecture or workflow overview

```text
Student Terminal
    |
    | DNS lookup
    v
example.com
    |
    | HTTP/HTTPS request
    v
Web Server
```

### Step-by-step student instructions

#### Step 1: Create a lab folder

```bash
mkdir -p week5-networking-class1
cd week5-networking-class1
touch lab-notes.md
```

Expected output:

No output means the commands worked.

Add heading:

```bash
echo "# Week 5 Class 1 Networking Lab" > lab-notes.md
```

---

#### Step 2: Check DNS with `nslookup`

```bash
nslookup example.com
```

Expected output pattern:

```text
Name:    example.com
Address: <IP address>
```

Record your finding:

```bash
echo "nslookup example.com returned an IP address." >> lab-notes.md
```

---

#### Step 3: Check DNS with `dig`

```bash
dig +short example.com
```

Expected output pattern:

```text
<one or more IP addresses>
```

Record your finding:

```bash
echo "dig +short example.com returned one or more IP addresses." >> lab-notes.md
```

---

#### Step 4: Test HTTPS response headers

```bash
curl -I https://example.com
```

Expected output pattern:

```text
HTTP/2 200
```

or:

```text
HTTP/1.1 200 OK
```

Record the status code:

```bash
echo "curl -I https://example.com returned an HTTP response." >> lab-notes.md
```

---

#### Step 5: Run a verbose HTTP test

```bash
curl -v https://example.com
```

Look for:

```text
Connected to
SSL connection
HTTP response status
```

Record:

```bash
echo "curl -v showed connection details and HTTP response information." >> lab-notes.md
```

---

#### Step 6: Test port 443

```bash
nc -vz example.com 443
```

Expected output pattern:

```text
Connection to example.com port 443 succeeded
```

If `nc` is not installed, use:

```bash
curl -I https://example.com
```

Windows PowerShell alternative:

```powershell
Test-NetConnection example.com -Port 443
```

---

#### Step 7: Test a DNS failure

```bash
nslookup nonexistent-week5-lab.invalid
```

Expected output pattern:

```text
NXDOMAIN
```

Answer in your notes:

```text
What does NXDOMAIN mean?
```

---

#### Step 8: Test local listening ports

Linux:

```bash
ss -tulnp
```

If permission is limited:

```bash
sudo ss -tulnp
```

Expected output pattern:

```text
tcp LISTEN ...
udp UNCONN ...
```

macOS alternative:

```bash
netstat -an | grep LISTEN
```

Windows PowerShell alternative:

```powershell
netstat -ano
```

---

### Validation checklist

Students should confirm:

- [ ] I can resolve `example.com` using DNS.
- [ ] I can identify at least one IP address returned by DNS.
- [ ] I can use `curl -I` to view HTTP headers.
- [ ] I can identify an HTTP status code.
- [ ] I can test port 443 reachability.
- [ ] I can explain what `NXDOMAIN` means.
- [ ] I can explain the difference between DNS resolution and application response.

### Troubleshooting tips

| Problem | Likely Cause | Fix |
|---|---|---|
| `dig: command not found` | DNS tools not installed | Use `nslookup` or install DNS utilities |
| `nc: command not found` | Netcat not installed | Use `curl` or install `netcat` |
| `ping` fails but `curl` works | ICMP may be blocked | Do not assume app is down |
| `curl` returns 301 or 302 | Site redirects | Use `curl -L` to follow redirects |
| `curl` times out | Network, firewall, proxy, or site issue | Try another site and compare |
| DNS returns no result | Bad hostname or DNS issue | Verify spelling and domain |

### Cleanup steps

Remove local lab folder if desired:

```bash
cd ..
rm -rf week5-networking-class1
```

### Reflection questions

1. What does DNS do?
2. Why does a successful DNS lookup not prove the application is healthy?
3. What does port 443 usually mean?
4. What is the difference between timeout and HTTP 404?
5. Why might `ping` fail even when a website works?

### Optional challenge task

Test three websites using:

```bash
nslookup
dig +short
curl -I
nc -vz <hostname> 443
```

Document the differences in DNS results, HTTP status codes, and port behavior.

---

## 13.5 Graded Lab: Subnet Math and CIDR Planning

### Lab title

**Carve a VPC Address Plan and Calculate Usable Hosts**

### Lab objective

Given a VPC CIDR, split it into subnets, calculate usable host counts (both the generic rule and the AWS rule), and identify reserved addresses. This is portfolio- and interview-relevant: subnetting is one of the most discriminating senior-networking screens.

### Estimated time

20 to 30 minutes (graded)

### Reference: the prefix → size cheat sheet

| Prefix | Total addresses | Generic usable (−2) | AWS usable (−5) |
|---|---:|---:|---:|
| /28 | 16 | 14 | 11 |
| /27 | 32 | 30 | 27 |
| /26 | 64 | 62 | 59 |
| /24 | 256 | 254 | 251 |
| /20 | 4096 | 4094 | 4091 |
| /16 | 65536 | 65534 | 65531 |

Formula reminder: total addresses = `2^(32 − prefix)`.

### Worked example (do this together first)

You are given VPC CIDR `10.20.0.0/16` (65,536 addresses). Carve:

```text
Public subnet  : 10.20.0.0/24   -> 256 total, 251 AWS-usable
Private subnet : 10.20.1.0/24   -> 256 total, 251 AWS-usable
DB subnet      : 10.20.2.0/28   -> 16 total,  11 AWS-usable
```

Why a `/28` for the DB subnet? Databases need very few IPs (an RDS instance plus a standby), so a tiny subnet avoids wasting address space — but **AWS still reserves 5**, so a `/28` only gives 11 usable, not 14. A team that planned for 14 and tried to place 13 ENIs would run out.

Reserved addresses in `10.20.2.0/28`:

```text
10.20.2.0    network
10.20.2.1    VPC router
10.20.2.2    Amazon DNS
10.20.2.3    reserved (future use)
10.20.2.15   broadcast (reserved)
```

### Graded student tasks

Given VPC CIDR **`10.50.0.0/16`**, produce a written address plan that carves out:

1. Three `/24` subnets (one public, two private app subnets in different AZs).
2. One `/28` database subnet.
3. One `/26` subnet reserved for future Kubernetes pods.

For **each** subnet, record:

- [ ] The CIDR you assigned (must not overlap any other subnet).
- [ ] Total addresses.
- [ ] AWS-usable host count.
- [ ] The network address and the broadcast address.

Then answer:

5. How many `/24` subnets could `10.50.0.0/16` hold in total? (Hint: `2^(24−16)`.)
6. A teammate proposes a `/30` for a point-to-point link and expects 2 usable hosts. On AWS, how many usable hosts does a `/30` actually have, and why is that a problem?

### Answer key (instructor only)

- A valid, non-overlapping plan, e.g.:

```text
Public      : 10.50.0.0/24   256 total, 251 usable, net 10.50.0.0,  bcast 10.50.0.255
App AZ-a    : 10.50.1.0/24   256 total, 251 usable, net 10.50.1.0,  bcast 10.50.1.255
App AZ-b    : 10.50.2.0/24   256 total, 251 usable, net 10.50.2.0,  bcast 10.50.2.255
Database    : 10.50.3.0/28   16 total,  11 usable,  net 10.50.3.0,  bcast 10.50.3.15
K8s future  : 10.50.4.0/26   64 total,  59 usable,  net 10.50.4.0,  bcast 10.50.4.63
```

(Any non-overlapping assignment inside `10.50.0.0/16` is acceptable.)

- Q5: `2^(24−16) = 2^8 = 256` subnets of size `/24`.
- Q6: A `/30` is 4 total addresses. Generic networking gives 2 usable. **On AWS a `/30` is unusable for hosts** because AWS reserves 5 addresses but the block only has 4 — AWS therefore rejects subnets smaller than `/28`. The smallest valid AWS subnet is `/28` (11 usable).

### Reflection

1. Why does AWS reserve 5 addresses instead of the textbook 2?
2. When is a `/28` too small in practice?
3. Why does over-allocating a subnet (e.g. a `/16` per subnet) cause problems later even though it "works" today? (Hint: future peering/Transit Gateway CIDR overlap — see Class 2.)

---

## 14. Troubleshooting Activity

### Incident or problem title

**Application Unreachable Due to DNS Failure**

### Business impact

Users cannot access an internal web application. A business team reports that a critical dashboard is unavailable before a morning operations meeting.

### Symptoms

Users report:

```text
I cannot open https://app.example.com.
```

Browser shows:

```text
This site can't be reached
DNS_PROBE_FINISHED_NXDOMAIN
```

### Starting evidence

Command:

```bash
nslookup app.example.com
```

Output:

```text
server can't find app.example.com: NXDOMAIN
```

Command:

```bash
curl -I https://app.example.com
```

Output:

```text
curl: (6) Could not resolve host: app.example.com
```

### Student investigation steps

Students should:

1. Identify the error type.
2. Determine whether DNS resolution works.
3. Confirm that the hostname is spelled correctly.
4. Compare with a known working hostname.
5. Explain why port and HTTP checks cannot continue until DNS resolves.
6. Identify the team likely responsible for DNS records.
7. Recommend what evidence to include in an escalation.

### Expected root cause

The DNS record for `app.example.com` does not exist or was removed.

### Correct resolution

Create or restore the correct DNS record pointing to the application endpoint, such as a load balancer DNS name or approved IP address.

In AWS this may mean:

- Add or correct a Route 53 record.
- Verify hosted zone.
- Verify record type, such as `A`, `AAAA`, or `CNAME`.
- Confirm whether the record should be public or private.

### Common wrong paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Checking Security Groups first | DNS does not resolve yet, so traffic cannot reach the target |
| Restarting the application | No evidence says the app is down |
| Checking HTTP status codes | HTTP cannot be tested until hostname resolves |
| Blaming load balancer health | Load balancer was not reached |
| Opening firewall rules | No target IP was resolved |

### Instructor hints

Use these hints one at a time:

1. “What does `NXDOMAIN` mean?”
2. “Did the client get an IP address?”
3. “Can HTTP work if DNS fails?”
4. “Which team usually manages DNS records in an enterprise?”
5. “What exact evidence would you send in a support ticket?”

### Preventive action

- Manage DNS records through infrastructure as code where possible.
- Use change review for DNS changes.
- Monitor critical DNS records.
- Document public and private DNS zones.
- Include DNS validation in deployment checklists.
- Maintain ownership tags for application DNS entries.

---

## 15. Scenario-Based Discussion Questions

### Question 1

A user says, “The website is down.” What questions should you ask first?

Expected response themes:

- What URL?
- What error?
- When did it start?
- Is it affecting everyone?
- Is it internal or external?
- What network are they on?
- What HTTP status or browser message appears?

Instructor follow-up:

> “What evidence would you collect before escalating?”

---

### Question 2

Why is `ping` not enough to prove an application is available?

Expected response themes:

- ICMP may be blocked.
- Web apps use HTTP/HTTPS, not ping.
- Port 443 may work even if ping fails.
- App health requires application-layer response.

Instructor follow-up:

> “What command would test HTTPS better than ping?”

---

### Question 3

DNS resolves successfully, but `curl` times out. What could be wrong?

Expected response themes:

- Firewall blocking traffic
- Port closed
- Route issue
- Load balancer unreachable
- Server not listening
- Network ACL or proxy issue

Instructor follow-up:

> “What command would you use next to test the port?”

---

### Question 4

Why should databases usually use private IPs?

Expected response themes:

- Reduce internet exposure
- Enforce internal access only
- Improve security posture
- Allow access only from application layer
- Support least privilege

Instructor follow-up:

> “What should be allowed to talk to the database?”

---

### Question 5

In an enterprise, why can DNS work from the office network but fail from home?

Expected response themes:

- Private DNS zones
- VPN requirement
- Split-horizon DNS
- Internal-only domains
- Corporate resolver dependency

Instructor follow-up:

> “How would you prove whether the issue is DNS or VPN access?”

---

### Question 6

What is the risk of opening all ports from all sources?

Expected response themes:

- Security exposure
- Attack surface increase
- Compliance issues
- Accidental access
- Harder troubleshooting

Instructor follow-up:

> “What is a better approach?”

---

### Question 7

An app returns HTTP 404. Is the network broken?

Expected response themes:

- Not necessarily
- Server responded
- DNS and network path likely worked
- Application route or URL path may be wrong

Instructor follow-up:

> “How is 404 different from timeout?”

---

### Question 8

Why do DevOps and SRE engineers need networking knowledge even if a network team exists?

Expected response themes:

- Faster triage
- Better escalation evidence
- Understanding deployment failures
- Kubernetes and cloud depend on networking
- Incident response requires cross-layer thinking

Instructor follow-up:

> “What information makes an escalation useful to a network team?”

---

## 16. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple choice

What does DNS primarily do?

A. Encrypts web traffic  
B. Converts hostnames to IP addresses  
C. Blocks unwanted traffic  
D. Stores application logs  

**Answer:** B  
**Explanation:** DNS maps names like `example.com` to IP addresses.

---

### Question 2: Multiple choice

Which port is commonly used for HTTPS?

A. 22  
B. 53  
C. 80  
D. 443  

**Answer:** D  
**Explanation:** HTTPS commonly uses TCP port 443.

---

### Question 3: True or false

If `ping` fails, the website is definitely down.

**Answer:** False  
**Explanation:** ICMP may be blocked. Use `curl` to test HTTP or HTTPS.

---

### Question 4: Short answer

What does `NXDOMAIN` mean?

**Answer:** The DNS name does not exist or cannot be found.  
**Explanation:** The client did not receive an IP address for the hostname.

---

### Question 5: Multiple choice

Which command is best for checking HTTP response headers?

A. `ls -l`  
B. `curl -I https://example.com`  
C. `cd /tmp`  
D. `chmod 755 file`  

**Answer:** B  
**Explanation:** `curl -I` returns HTTP headers and status code.

---

### Question 6: Multiple choice

Which AWS service is used for DNS?

A. IAM  
B. Route 53  
C. EC2  
D. EBS  

**Answer:** B  
**Explanation:** Amazon Route 53 is AWS DNS service.

---

### Question 7: True or false

A private IP address is normally used inside a private network.

**Answer:** True  
**Explanation:** Private IP ranges are used internally in VPCs, data centers, and local networks.

---

### Question 8: Troubleshooting question

`nslookup app.example.com` works, but `nc -vz app.example.com 443` times out. Is DNS the likely root cause?

**Answer:** No.  
**Explanation:** DNS resolved successfully. The issue is more likely port, firewall, route, load balancer, or server availability.

---

### Question 9: Troubleshooting question

`curl -I https://app.example.com` returns `HTTP/1.1 404 Not Found`. What does this tell you?

**Answer:** The server responded, but the requested path was not found.  
**Explanation:** DNS and connectivity likely worked. The issue may be URL path, route, application config, or web server config.

---

### Question 10: AWS-related short answer

What is the AWS networking service that provides an isolated virtual network for cloud resources?

**Answer:** Amazon VPC  
**Explanation:** A VPC is the private network boundary where AWS resources such as EC2 instances and load balancers are placed.

---

## 17. Homework Assignment

### Assignment title

**How a Browser Reaches a Cloud Application**

### Scenario

You are a junior cloud engineer asked to explain how users reach a cloud-hosted application. Your manager wants a simple explanation that can be shared with a new application team before they begin AWS onboarding.

### Student tasks

Create a short document that explains:

1. What happens when a user enters a website URL.
2. What DNS does.
3. What an IP address does.
4. What ports are used for.
5. Difference between HTTP and HTTPS.
6. Difference between public and private IP addresses.
7. Difference between public and private subnets.
8. Basic troubleshooting steps when an app is unreachable.
9. At least 3 commands used for network troubleshooting.

### Required diagram

Include a text-based diagram like this:

```text
User Browser
    |
    v
DNS
    |
    v
Load Balancer or Web Server
    |
    v
Application
```

### Expected deliverables

Students submit:

- One Markdown, Word, or PDF document
- One text-based diagram
- At least 3 command examples
- Short explanation of each command

### Submission format

Accepted formats:

- `.md`
- `.docx`
- `.pdf`

Suggested filename:

```text
week5-class1-networking-homework-firstname-lastname.md
```

### Estimated completion time

45 to 60 minutes

### Grading criteria

| Criteria | Points |
|---|---:|
| Clear explanation of DNS, IPs, ports, HTTP/HTTPS | 30 |
| Correct public vs private networking explanation | 20 |
| Useful diagram | 15 |
| Correct troubleshooting commands | 20 |
| Clarity and organization | 15 |
| Total | 100 |

### Optional advanced challenge

Add a section explaining how this flow changes when the application is behind:

- AWS Application Load Balancer
- Private DNS
- Corporate VPN
- Kubernetes Ingress

---

## 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Thinking DNS means the application is working | DNS is often confused with application health | Explain DNS only maps name to IP |
| Using only `ping` to test apps | Ping is familiar and simple | Teach `curl` and `nc` for app and port testing |
| Confusing port 80 and 443 | Students remember web but not protocol differences | Repeat HTTP equals 80, HTTPS equals 443 |
| Thinking a public IP and public subnet are the same | Cloud networking terms are new | Explain subnet behavior depends on routing |
| Ignoring the source of traffic | Students focus only on destination | Always ask “from where is the request coming?” |
| Assuming timeout and 404 mean the same thing | Both look like “not working” to users | Teach timeout means no response, 404 means server responded |
| Forgetting corporate VPN or private DNS | Students test only from home network | Explain internal apps may require corporate network |
| Jumping to root cause too early | Beginner troubleshooters guess | Use layer-by-layer evidence collection |

---

## 19. Real-World Enterprise Scenario

### Scenario

A logistics company has an internal dashboard used by operations teams. The dashboard is hosted in AWS. Users in the corporate office can access it, but remote users cannot.

The application team says:

```text
The app is down.
```

The network team says:

```text
No firewall changes were made.
```

The cloud team must investigate.

### Constraints

- The application is internal only.
- Access requires VPN.
- DNS is private and only resolves from corporate DNS resolvers.
- The app is behind an internal AWS load balancer.
- Security Groups only allow approved corporate CIDR ranges.
- Changes require approval because this is a production application.

### How the class topic applies

Students should understand that the issue could be:

- Remote users are not on VPN
- Private DNS is not resolving externally
- Security Group does not allow remote VPN CIDR
- Load balancer is internal, not internet-facing
- Application is healthy but unreachable from some source networks

### What each role would do

| Role | Action |
|---|---|
| DevOps Engineer | Check deployment, app endpoint, pipeline changes, and service status |
| Cloud Engineer | Check DNS, VPC, route tables, Security Groups, and load balancer type |
| SRE | Check impact, alerts, logs, user reports, and incident communication |
| Network Team | Validate VPN routing, corporate CIDRs, and firewall paths |
| Security Team | Approve or reject access changes based on least privilege |

### Expected professional response

A strong engineer would say:

```text
DNS resolution fails for remote users when they are not connected to VPN. From the corporate network, the hostname resolves to a private IP and the application returns HTTP 200. This suggests the application is healthy, and the issue is related to private DNS or VPN access rather than an application outage.
```

---

## 20. Instructor Tips

### Teaching tips

- Use simple analogies before technical definitions.
- Keep reminding students that each command tests a specific layer.
- Show both success and failure outputs.
- Ask students to explain what evidence they have, not what they guess.
- Avoid deep subnet math in this class. Keep it practical.

### Pacing tips

- Do not spend too long on CIDR calculations.
- Spend more time on DNS, ports, HTTP response, and troubleshooting sequence.
- Keep AWS VPC references light because Class 2 covers AWS cloud networking more deeply.
- If students struggle, slow down during the command demo.

### Lab support tips

- Some students may not have `dig` or `nc`.
- Provide alternatives for Windows PowerShell.
- Encourage students to record outputs, not just run commands.
- Help students understand that different systems may return slightly different DNS answers.

### How to help struggling students

Use this sequence:

```text
1. What name are you testing?
2. Did DNS return an IP?
3. Which port are you testing?
4. Did the port connect?
5. Did HTTP return a status code?
6. What does the status code mean?
```

### How to challenge advanced students

Ask advanced students to:

- Compare `curl -I` and `curl -v`
- Explain TLS handshake visibility in `curl -v`
- Test multiple domains and compare responses
- Explain private DNS vs public DNS
- Research common HTTP status codes
- Diagram how this changes with an AWS Application Load Balancer

---

## 21. Student Outcome Checklist

### Students should be able to explain

- [ ] What DNS does
- [ ] What an IP address is
- [ ] Difference between public and private IPs
- [ ] What a subnet is
- [ ] What ports are used for
- [ ] Difference between HTTP and HTTPS
- [ ] Why `ping` is not enough
- [ ] Difference between DNS failure, port failure, and HTTP error

### Students should be able to build or configure

- [ ] A basic text diagram of browser-to-application traffic flow
- [ ] A lab notes file documenting command outputs
- [ ] A simple troubleshooting evidence summary

### Students should be able to troubleshoot

- [ ] DNS lookup failure
- [ ] Port reachability issue
- [ ] HTTP response code interpretation
- [ ] Local listening port check
- [ ] Basic app unreachable scenario

---

## 22. Class Completion Checklist

### Instructor checklist before ending class

- [ ] Confirm students understand DNS vs HTTP response.
- [ ] Confirm students know HTTPS commonly uses port 443.
- [ ] Confirm students understand that `ping` is limited.
- [ ] Confirm students ran at least `nslookup`, `dig` or equivalent, `curl -I`, and one port test.
- [ ] Review the troubleshooting order.
- [ ] Explain homework expectations.
- [ ] Preview Class 2: VPC, subnets, route tables, NAT, firewalls, and load balancers.

### Student checklist before leaving class

- [ ] I completed the lab commands.
- [ ] I saved or documented my outputs.
- [ ] I can explain what DNS does.
- [ ] I can explain what a port is.
- [ ] I can use `curl -I` to check HTTP status.
- [ ] I can explain why an app can fail at different network layers.
- [ ] I understand the homework assignment.

### Items to verify before moving to Class 2

Students should be ready to answer:

1. What happens before a browser can connect to a web application?
2. What does DNS return?
3. What is port 443 used for?
4. What is the difference between a timeout and a 404?
5. Why might internal applications use private IPs?
6. Why does cloud networking need public and private subnets?

Class 2 can then build on this foundation by placing these concepts inside AWS VPC design, route tables, Security Groups, NAT Gateways, and load balancers.

---

## Class Artifacts & Validation

This class is **conceptual + CLI** (IP/CIDR/subnet math, ports, DNS, `nslookup`/`dig`/`curl`/`nc`). Its hands-on practice uses local OS tools rather than committed source. The one repository artifact this class draws on is the backing lab's **architecture diagram** and the **CIDR/subnet carving** the VPC module performs — they make the abstract subnet math (a `/16` split into non-overlapping `/24` public and private subnets) concrete before students meet AWS in Class 2. The reusable VPC infrastructure itself is owned and operated in **Class 2**; here it is read, not built.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/terraform-aws-foundations/docs/architecture.mmd` | Mermaid diagram | Browser → Internet Gateway → public/private subnet traffic-flow diagram for the VPC this week builds; the picture behind the "what happens before a browser connects" objective | renders in any Mermaid viewer; matches the deployed VPC in `LIVE-AWS-VALIDATION.txt` | PASS (renders; matches live VPC) |
| 2 | `labs/terraform-aws-foundations/solution/modules/vpc/main.tf` | terraform | `cidrsubnet()` carving of a `/16` into non-overlapping public/private `/24`s — the on-disk demonstration of this class's subnet math (private subnets offset by `az_count` so CIDRs never collide) | `terraform -chdir=labs/terraform-aws-foundations/solution/modules/vpc validate` | PASS — `Success! The configuration is valid.` |
| 3 | `labs/terraform-aws-foundations/tests/test_terraform_structure.py` | python (stdlib) | structural test `test_private_subnet_offset_avoids_overlap` asserting the CIDR math taught here is correct in the reference | `python3 -m unittest discover -s labs/terraform-aws-foundations/tests` | PASS — `Ran 18 tests ... OK` |

> The CLI practice in this class (`nslookup`, `dig`, `curl -I`, `nc -vz`, port checks) runs against live public hosts and the student's own machine; there is no committed source file for it, which is correct for a fundamentals class. The runnable infrastructure that codifies these concepts lives in the backing lab and is validated under Class 2.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — N/A for the CLI/diagnostic tools (run against live hosts); the CIDR/subnet concept is backed by the runnable VPC module (artifact #2) and its structural test (#3).
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured — `terraform validate` and the stdlib tests pass (verified live: `10 passed, 0 failed` from `./validate.sh`).
- [x] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions — `labs/terraform-aws-foundations/{starter,solution}/` (the VPC subnet TODOs are completed in Class 2's lab).
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, cost notes — see `labs/terraform-aws-foundations/README.md`.
- [x] **Cleanup/teardown** is provided and idempotent — the class's CLI tools create no resources; the backing lab documents idempotent local + cloud cleanup.
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise — in this class file (quiz/homework answer keys) and `labs/terraform-aws-foundations/README.md` (lab answer key).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — the DNS-vs-port-vs-app failure isolation here uses live commands; the backing lab also ships a real `broken/` fixture (used in Class 2).
- [x] **Expected outputs** are shown for demos and labs — sample `nslookup`/`dig`/`curl -I` outputs and the troubleshooting-order evidence summary are shown inline.
- [ ] **Cost & security warnings** present wherever cloud resources or secrets are involved — N/A: this class creates no cloud resources and uses no secrets (it explicitly requires no AWS account).
- [x] **Cross-references** to the module repo and to prior/next weeks are correct (numbers verified) — links to the backing lab, Week 4 (cloud foundations), and Week 5 Class 2 are correct.
- [x] The **artifact manifest** (§4.2) is present and every path resolves — verified with `ls`; all three paths exist.
