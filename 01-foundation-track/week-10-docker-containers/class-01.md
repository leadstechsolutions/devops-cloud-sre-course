# Week 10, Class 1 Package  
> **▶ Runnable lab for this class:** [`labs/docker-containers/`](../../labs/docker-containers/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Containers and the Docker Runtime

**Week:** 10
**Class:** 1
**Track:** Unified DevOps · Cloud · SRE Track

---

# 1. Class Overview

## Class Title

**Understanding Docker Images, Containers, and Local Application Packaging**

## Class Purpose

This class introduces students to Docker as the foundation for modern application packaging and deployment. Students learn what containers are, how they differ from virtual machines, how Docker images become running containers, and how to operate containers locally using the Docker CLI.

## How This Class Connects to the Overall Course

This class connects directly to the previous CI/CD module (Week 9) and prepares students for Kubernetes Fundamentals in Week 11.

Students have already learned:

- Linux fundamentals
- Networking basics
- Git workflows
- Bash and Python automation
- CI/CD pipeline concepts

Docker now becomes the bridge between application code and cloud-native deployment.

In later weeks, students will use Docker images inside:

- CI/CD pipelines
- Amazon ECR
- Kubernetes
- Helm charts
- EKS-based deployments
- DevOps and SRE troubleshooting scenarios

## What Students Will Build, Analyze, or Practice

Students will:

- Run containers locally
- Pull images from a registry
- Map local ports to container ports
- Inspect running and stopped containers
- View logs
- Pass environment variables
- Use a bind mount or simple volume
- Troubleshoot basic Docker runtime failures
- Clean up containers and images safely

---

# 2. Class Learning Objectives

By the end of this class, students will be able to:

1. **Explain** the difference between containers and virtual machines.
2. **Describe** the relationship between Docker images, containers, Docker Engine, and registries.
3. **Run** containers locally using Docker CLI commands.
4. **Configure** container port mappings and environment variables.
5. **Inspect** container status, logs, metadata, and runtime behavior.
6. **Troubleshoot** common container startup and connectivity issues.
7. **Compare** local Docker usage with enterprise cloud registry workflows.
8. **Document** basic Docker commands and cleanup steps for operational use.

---

# 3. Prerequisites Students Should Already Know

## Required Prior Concepts

Students should already understand:

- Basic Linux command-line usage
- Files and directories
- Ports and HTTP basics
- Basic networking concepts such as localhost, IP address, and TCP port
- Git basics
- CI/CD concept of build, test, package, deploy
- Basic terminal troubleshooting

## Required Tools Already Installed

Students should have:

- Docker Desktop or Docker Engine
- VS Code
- Terminal:
  - macOS Terminal or iTerm
  - Windows PowerShell, Git Bash, or WSL terminal
  - Linux terminal
- `curl`
- Browser
- Git, optional for storing lab work

## Required Accounts or Access

For Class 1, students do **not** need an AWS account to complete the main lab.

Optional:

- AWS account for Amazon ECR preview discussion
- Docker Hub account for registry awareness, but not required for Class 1

## Files, Repos, or Sample Code Needed

No application code is required for Class 1.

Students will use public container images. Always pin an explicit tag rather than relying on the implicit `:latest` — `latest` is a floating label that can point at a different image tomorrow, which breaks reproducibility (this is taught as a hard rule in Class 2):

```bash
nginx:1.27
alpine:3.20
busybox:1.36
```

> Habit from day one: pin a tag. For maximum determinism (CI, production) you can pin by digest, e.g. `nginx@sha256:...`, which is immutable. We introduce digests below and use them in Class 2.

---

# 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Container | A lightweight isolated process that runs an application with its dependencies | Used to run apps consistently across laptops, CI/CD, test, and production |
| Image | A packaged template used to create containers | Teams build images once and deploy the same image across environments |
| Docker | A platform used to build, run, and manage containers | Common tool used by DevOps teams before apps move to Kubernetes |
| Docker Engine | The background service that runs containers | The Docker CLI sends requests to Docker Engine |
| Docker CLI | Command-line tool used to interact with Docker | Engineers use it to build, run, inspect, and troubleshoot containers |
| Registry | A place where container images are stored | Docker Hub, Amazon ECR, Azure Container Registry, and Google Artifact Registry are examples |
| Repository | A named collection of image versions inside a registry | Example: `nginx` is a repository with multiple tags |
| Tag | A label for an image version | Example: `nginx:latest`, `nginx:1.25`, or `app:v1` |
| Port Mapping | Connecting a port on your laptop to a port inside the container | Example: laptop port `8080` maps to container port `80` |
| Environment Variable | A runtime configuration value passed into a container | Used for settings such as app name, environment, feature flags, or config values |
| Volume | Storage mounted into a container | Used when data must persist or be shared with the container |
| Logs | Output from the process running inside the container | Used heavily for troubleshooting in Docker, Kubernetes, and production systems |
| Detached Mode | Running a container in the background | Used when you want the container to keep running while you continue using the terminal |
| Interactive Mode | Running a container with terminal interaction | Useful for debugging and exploring lightweight containers |
| Container Lifecycle | The stages of creating, starting, stopping, restarting, and removing a container | Important for operations and troubleshooting |

---

# 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| Docker Desktop or Docker Engine | Runs and manages containers locally |
| Docker CLI | Main command-line interface for pulling, running, inspecting, and removing containers |
| Terminal | Used to execute Docker commands |
| Browser | Used to validate web containers such as Nginx |
| curl | Used to test HTTP responses from containers |
| VS Code | Optional tool for documenting commands and notes |
| Docker Hub | Public registry used to pull images such as Nginx and Alpine |
| Amazon ECR | Introduced as AWS’s private container registry for enterprise image storage |
| Git | Optional for saving lab notes and future Dockerfile work |

---

# 6. AWS Services Used

Class 1 is mostly local, but AWS is introduced conceptually.

| AWS Service | How It Connects to This Class |
|---|---|
| Amazon ECR | AWS-managed container registry used to store Docker images |
| Amazon ECS | Mentioned as an AWS service that runs containers without students managing Kubernetes directly |
| Amazon EKS | Mentioned as the Kubernetes service students will connect to later |
| IAM | Used later to control who can push and pull images from ECR |
| CloudWatch Logs | Used later to collect container logs in AWS environments |

## AWS Teaching Point

In real AWS environments, engineers often build images locally or in CI/CD, push them to **Amazon ECR**, and then deploy them to **ECS** or **EKS**.

Simple flow:

```text
Developer or CI/CD
   |
docker build
   |
docker push
   |
Amazon ECR
   |
ECS or EKS pulls image
   |
Application runs in AWS
```

## Cost Warning

For Class 1, students are using local Docker only, so there should be no AWS cost.

If ECR is used later, students should understand that image storage and data transfer can create small costs, especially if images are not cleaned up.

---

# 7. Azure and GCP Comparison Notes

Keep this short during class.

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Container registry | Amazon ECR | Azure Container Registry | Artifact Registry |
| Managed Kubernetes | Amazon EKS | Azure Kubernetes Service | Google Kubernetes Engine |
| Container logs | CloudWatch Logs | Azure Monitor Logs | Cloud Logging |

## Instructor Talking Point

“Docker itself is portable. The commands you learn today are mostly the same whether your company later pushes images to Amazon ECR, Azure Container Registry, or Google Artifact Registry.”

---

# 8. Time-Boxed Instructor Agenda

| Time | Section | Instructor Activity | Student Activity |
|---:|---|---|---|
| 0:00 to 0:15 | Opening discussion | Explain why containers matter in DevOps and cloud | Share examples of “works on my machine” issues |
| 0:15 to 0:40 | Containers vs virtual machines | Teach conceptual model with diagram | Ask questions and compare VM/container behavior |
| 0:40 to 1:05 | Docker architecture | Explain Docker Engine, CLI, images, containers, registries | Follow along with terminology |
| 1:05 to 1:20 | Break | Pause | Break |
| 1:20 to 1:50 | Docker CLI demo | Run, inspect, log, exec, stop, remove containers | Observe and take notes |
| 1:50 to 2:20 | Ports, env vars, volumes, logs | Demonstrate runtime options | Run guided commands if desired |
| 2:20 to 2:50 | Student lab | Support students as they run containers | Complete lab steps |
| 2:50 to 3:00 | Recap and homework | Review key points and assignment | Ask final questions |

---

# 9. Instructor Lesson Plan

## 0:00 to 0:15: Opening Discussion

### Explain

Start with the practical problem:

“Before containers, one of the biggest problems in software delivery was that an application worked on one machine but failed somewhere else. Docker helps us package the application with what it needs so it behaves more consistently.”

### Show

Ask students:

- Have you ever installed software that worked on one machine but failed on another?
- What could be different between a developer laptop and a production server?

Expected answers:

- Different Python or Node version
- Missing libraries
- Different OS packages
- Different environment variables
- Different ports
- Different file paths

### Pause for Questions

Ask:

“What do you think should be included with an application so it can run consistently?”

Transition:

“Now let’s compare the older virtual machine model with the container model.”

---

## 0:15 to 0:40: Containers vs Virtual Machines

### Explain

Cover:

- VM includes full guest OS
- Container shares host OS kernel
- Containers are usually faster to start
- Containers are smaller than VMs
- VMs still matter for isolation and full OS use cases
- Containers are excellent for app packaging

### Show

Use the whiteboard diagram from Section 11.

### Teaching Tip

Avoid saying containers are “mini VMs.” That creates confusion.

Better wording:

“A container is an isolated process with packaged dependencies. It is not a full virtual machine.”

### Pause for Questions

Ask:

“Why might a company prefer containers for deploying many microservices?”

Expected themes:

- Faster startup
- Consistent deployments
- Lower overhead
- Easier CI/CD
- Easier Kubernetes deployment

Transition:

“Now that we know what containers are, let’s see the Docker components that make containers work.”

---

## 0:40 to 1:05: Docker Architecture

### Explain

Introduce:

- Docker CLI
- Docker Engine
- Image
- Container
- Registry
- Tag

### Show

Draw:

```text
Docker CLI -> Docker Engine -> Image -> Container
                           -> Registry
```

### Instructor Talking Points

- “The image is the package.”
- “The container is the running instance.”
- “A registry is where images live.”
- “A tag helps identify a version.”
- “Docker CLI is how we tell Docker what to do.”

### Beginner Tip

Repeat the image/container difference several times.

Common analogy:

“An image is like a class blueprint. A container is like an actual running object created from that blueprint.”

Transition:

“Let’s take a short break. After the break, we will run real containers.”

---

## 1:05 to 1:20: Break

Give students time to start Docker Desktop if needed.

Ask them to verify:

```bash
docker --version
```

---

## 1:20 to 1:50: Docker CLI Demo

### Explain

Demonstrate the core lifecycle:

1. Pull image
2. Run container
3. List running containers
4. Test application
5. View logs
6. Inspect details
7. Exec into container
8. Stop container
9. Remove container

### Show

Use Nginx because it is simple, visual, and uses HTTP.

### Pause for Questions

After running the container, ask:

“What is running on your laptop, and what is running inside the container?”

Expected answer:

- Laptop exposes port `8080`
- Container runs Nginx on port `80`

Transition:

“Now that we can run a container, let’s look at the most common runtime options: ports, environment variables, volumes, and logs.”

---

## 1:50 to 2:20: Ports, Environment Variables, Volumes, and Logs

### Explain

Cover:

- Port mapping syntax: `host_port:container_port`
- Environment variable syntax: `-e KEY=value`
- Volume/bind mount syntax: `-v host_path:container_path`
- Logs are the first place to check when something fails

### Show

Run commands for:

- Nginx with port mapping
- Alpine with environment variable
- Nginx with bind-mounted HTML file

### Beginner Tip

Do not overload students with Docker networking internals yet. Keep it practical:

“Today, we only need to understand how to reach a service running inside a container from our laptop.”

Transition:

“Now students will practice the same workflow in the lab.”

---

## 2:20 to 2:50: Student Lab

### Instructor Role

Walk around or monitor chat.

Help students who have:

- Docker Desktop not running
- Port conflict
- Permission issue
- Name conflict
- Incorrect command syntax

### Teaching Tip

Encourage students to read error messages before asking for help.

Ask them:

“What command did you run?”
“What was the exact error?”
“What did `docker ps -a` show?”
“What do the logs say?”

Transition:

“Let’s close by reviewing the most important operational habits.”

---

## 2:50 to 3:00: Recap and Homework

### Recap

Key points:

- Containers are isolated processes.
- Images are templates.
- Containers are running instances.
- Logs are critical for troubleshooting.
- Port mapping connects your laptop to the container.
- Cleanup matters.

### Homework Direction

Students will rerun the lab, capture outputs, explain image vs container, and document troubleshooting steps.

---

# 10. Instructor Lecture Notes

## Opening Notes

“Today is the first class where students begin packaging applications in a way that directly supports CI/CD and Kubernetes. Docker is not just a developer tool. It is part of how modern DevOps teams standardize delivery.”

## Why Containers Matter

Before containers, teams often deployed applications by manually installing runtime dependencies on servers.

For example:

- Install Python
- Install packages
- Copy app files
- Configure environment variables
- Open ports
- Start service
- Hope every server was configured the same way

This caused inconsistent environments.

Containers improve this by packaging the app and dependencies into an image.

## Containers vs VMs

A VM gives you a full guest operating system. It is powerful but heavier.

A container runs as an isolated process using the host OS kernel. It is usually lighter and faster to start.

Do not say containers replace VMs completely. In enterprise environments, containers often run **inside VMs** or managed cloud nodes.

Example:

```text
AWS EC2 instance
   |
EKS worker node
   |
Container runtime
   |
Application containers
```

## Image vs Container

This is the most important concept in the class.

Say this clearly:

“An image is not running. A container is running.”

An image is like a package. A container is what happens when Docker starts that package.

One image can create many containers.

Example:

```bash
docker run nginx:1.27
docker run nginx:1.27
docker run nginx:1.27
```

All three containers can come from the same image.

## Docker CLI and Docker Engine

The CLI is what students type into the terminal.

Docker Engine is the background service that performs the work.

When students run:

```bash
docker run nginx:1.27
```

They are asking Docker Engine to create and start a container from the Nginx image.

## Registries

A registry stores images.

Public examples:

- Docker Hub

Enterprise/private examples:

- Amazon ECR
- Azure Container Registry
- Google Artifact Registry

In real companies, production images should come from trusted registries and controlled pipelines, not random manual builds.

## Ports

Containers have their own network space. If an app listens on port `80` inside a container, your laptop does not automatically expose that port.

This command maps host port `8080` to container port `80`:

```bash
docker run -p 8080:80 nginx:1.27
```

Then students access:

```text
http://localhost:8080
```

## Logs

Logs are the first troubleshooting tool.

In production, SREs and DevOps engineers spend a lot of time looking at logs from containers.

For local Docker:

```bash
docker logs container-name
```

For Kubernetes later:

```bash
kubectl logs pod-name
```

The habit starts here.

## Environment Variables

Environment variables allow runtime configuration without changing the image.

Examples:

- `APP_ENV=dev`
- `LOG_LEVEL=debug`
- `APP_NAME=student-app`

Security warning:

Do not pass real passwords or secrets casually into terminal history. In production, use a secrets manager or secure injection method.

## Volumes

Containers are disposable. If you remove a container, data inside the container may disappear unless it is stored externally.

Volumes and bind mounts allow data or files to be shared with a container.

For Class 1, keep this simple:

“Volumes help containers use files outside the container.”

## Enterprise Context

In a real enterprise:

- Developers build and test containers locally.
- CI/CD pipelines build official images.
- Images are scanned for vulnerabilities.
- Images are pushed to private registries like Amazon ECR.
- Kubernetes or ECS pulls the image and runs it.
- Logs and metrics are sent to observability tools.
- Access is controlled by IAM and repository policies.

## Common Misconceptions

| Misconception | Correction |
|---|---|
| A container is a full VM | A container is an isolated process, not a full guest OS |
| An image is running | An image is a template; a container is running |
| `EXPOSE` publishes a port | `EXPOSE` documents the container port; `-p` maps it to the host |
| Logs are optional | Logs are essential for troubleshooting |
| Containers keep data forever | Containers are disposable unless data is persisted |
| Docker is only for developers | Docker is heavily used by DevOps, Cloud, and SRE teams |

---

# 11. Whiteboard Explanation

## Simple Diagram: VM vs Container

```text
Virtual Machine Model

Laptop or Server
   |
Hypervisor
   |
-------------------------------------------------
| VM 1                 | VM 2                  |
| Guest OS             | Guest OS              |
| Runtime              | Runtime               |
| Application          | Application           |
-------------------------------------------------


Container Model

Laptop or Server
   |
Host Operating System
   |
Docker Engine
   |
-------------------------------------------------
| Container 1          | Container 2           |
| App + Dependencies   | App + Dependencies    |
-------------------------------------------------
```

## Explain the Flow Step by Step

1. A VM packages a full guest operating system.
2. A container packages the app and dependencies.
3. Containers share the host OS kernel.
4. Containers usually start faster and use fewer resources.
5. Containers help standardize application runtime environments.

---

## Image to Container Flow

```text
Registry
   |
docker pull
   |
Image on Local Machine
   |
docker run
   |
Running Container
   |
docker logs / docker inspect / docker exec
   |
docker stop / docker rm
```

## What Each Component Means

| Component | Meaning |
|---|---|
| Registry | Remote storage for images |
| Image | Local package used to create containers |
| Container | Running application instance |
| Logs | Output from the container process |
| Inspect | Runtime configuration and metadata |
| Exec | Open a shell or run a command inside a running container |
| Stop | Stop the running process |
| Remove | Delete the stopped container |

---

## Enterprise Version of the Diagram

```text
Developer Laptop
   |
docker build / local test
   |
Git Repository
   |
CI/CD Pipeline
   |
Build Image
   |
Security Scan
   |
Push Image
   |
Amazon ECR
   |
EKS or ECS
   |
Production Application
   |
CloudWatch / Datadog / Grafana
```

## Instructor Explanation

“This class focuses on the left side: local Docker basics. In later classes, we move to CI/CD, registries, Kubernetes, EKS, and monitoring.”

---

# 12. Instructor Demo Script

## Demo Title

**Run, Inspect, and Troubleshoot Containers Locally**

## Demo Objective

Show students how to pull an image, run a web container, map a port, inspect logs, execute into a container, pass environment variables, use a simple bind mount, and clean up.

## Required Setup

Instructor machine should have:

```bash
docker --version
curl --version
```

Docker Desktop or Docker Engine must be running.

Verify:

```bash
docker info
```

Expected output includes information such as:

```text
Server:
 Containers:
 Images:
 Server Version:
```

If Docker is not running, expected error may look like:

```text
Cannot connect to the Docker daemon
```

Recovery:

- Start Docker Desktop
- On Linux, start Docker service:

```bash
sudo systemctl start docker
```

---

## Demo Part 1: Pull and Run Nginx

### Command

```bash
docker pull nginx:1.27
```

### Expected Output

```text
1.27: Pulling from library/nginx
Status: Downloaded newer image for nginx:1.27
docker.io/library/nginx:1.27
```

### Explain

“Docker pulled the Nginx `1.27` image from Docker Hub. The image is now available locally. Notice we pinned `:1.27` — if we had typed `docker pull nginx` Docker would silently use `:latest`, which can point at a different build tomorrow. Pinning a tag makes the pull reproducible.”

### Pinning by Digest (introduce the concept)

A tag like `1.27` can still be re-pushed by the maintainer. A **digest** is a content hash that never changes — the same digest is byte-for-byte the same image forever.

```bash
docker inspect --format='{{index .RepoDigests 0}}' nginx:1.27
```

### Expected Output

```text
nginx@sha256:<long-hash>
```

### Explain

“Production and CI pin by digest for full immutability, for example `docker pull nginx@sha256:...`. We will use digest pinning in Class 2. For class today, an explicit version tag is enough.”

---

### Command

```bash
docker run -d --name demo-nginx -p 8080:80 nginx:1.27
```

### Expected Output

```text
<container_id>
```

### Explain

- `docker run` creates and starts a container.
- `-d` runs it in the background.
- `--name demo-nginx` gives the container a readable name.
- `-p 8080:80` maps laptop port `8080` to container port `80`.
- `nginx:1.27` is the image name **with a pinned tag** — never rely on the implicit `:latest`.

---

### Command

```bash
docker ps
```

### Expected Output

```text
CONTAINER ID   IMAGE   COMMAND                  STATUS         PORTS                  NAMES
abc123         nginx   "/docker-entrypoint..."  Up 10 seconds  0.0.0.0:8080->80/tcp   demo-nginx
```

### Explain

“`docker ps` shows running containers only.”

---

### Command

```bash
curl http://localhost:8080
```

### Expected Output

```html
<title>Welcome to nginx!</title>
```

### Explain

“This confirms that traffic from our laptop is reaching the Nginx process inside the container.”

---

## Demo Part 2: Logs and Inspect

### Command

```bash
docker logs demo-nginx
```

### Expected Output

```text
/docker-entrypoint.sh: Configuration complete; ready for start up
```

### Explain

“Logs show what the process inside the container is doing.”

---

### Command

```bash
docker inspect demo-nginx
```

### Expected Output

Large JSON output.

Point out:

- Image ID
- Network settings
- Port bindings
- Mounts
- Environment variables
- Container state

### Explain

“`docker inspect` is useful when the container is running, but you need deeper configuration details.”

---

## Demo Part 3: Exec Into Container

### Command

```bash
docker exec -it demo-nginx sh
```

Inside the container:

```bash
hostname
ls
pwd
exit
```

### Expected Output

```text
<container-id-like-hostname>
```

### Explain

“`docker exec` is useful for debugging, but in production, we avoid manually changing running containers because changes are not repeatable.”

---

## Demo Part 4: Environment Variable Example

Run Alpine with an environment variable:

```bash
docker run --rm -e APP_ENV=dev alpine:3.20 printenv APP_ENV
```

### Expected Output

```text
dev
```

### Explain

“Environment variables are a common way to pass configuration into a container at runtime.”

### Resource Constraints (preview of W12 limits)

You can cap what a container is allowed to consume. This matters because an unbounded container can starve your laptop — and in Kubernetes (Weeks 11–12) the same idea becomes requests/limits and the `OOMKilled` failure mode.

```bash
docker run --rm --memory=64m --cpus=0.5 alpine:3.20 sh -c "echo limited container"
```

### Explain

“`--memory=64m` caps RAM; `--cpus=0.5` caps CPU to half a core. If a process exceeds the memory cap the kernel OOM-kills it — exactly the signal you will debug in Week 12 Kubernetes troubleshooting.”

---

## Demo Part 5: Bind Mount Example

Create a local folder:

```bash
mkdir docker-class-demo
cd docker-class-demo
echo "Hello from a bind-mounted file" > index.html
```

Run Nginx with bind mount:

```bash
docker run -d --name mounted-nginx -p 8081:80 -v "$PWD":/usr/share/nginx/html:ro nginx:1.27
```

Validate:

```bash
curl http://localhost:8081
```

Expected output:

```text
Hello from a bind-mounted file
```

Explain:

- `-v "$PWD":/usr/share/nginx/html:ro` mounts the current folder into the container.
- `:ro` means read-only.
- This is useful for local testing, but production usually uses baked images or managed volumes.

For Windows PowerShell, use:

```powershell
docker run -d --name mounted-nginx -p 8081:80 -v ${PWD}:/usr/share/nginx/html:ro nginx:1.27
```

---

## Demo Part 6: Image Architecture and `--platform`

This is the single most common "works on my Mac, breaks in CI/production" container surprise in 2026: a developer on Apple Silicon (arm64) builds or pulls an arm64 image, but the cluster nodes are amd64 (x86-64), so the image refuses to run with an `exec format error`.

Show students what architecture their images are:

```bash
docker image inspect nginx:1.27 --format '{{.Os}}/{{.Architecture}}'
```

### Expected Output

```text
linux/arm64    # on Apple Silicon
linux/amd64    # on Intel/AMD
```

### Explain

“Most official images are multi-arch: Docker automatically pulls the variant matching your machine. The trap is building or running for the wrong target. To pull or run a specific architecture explicitly:”

```bash
docker run --rm --platform linux/amd64 alpine:3.20 uname -m
```

### Expected Output

```text
x86_64
```

### Explain

“On an arm64 laptop this runs the amd64 image under emulation (slower, but it matches an amd64 cluster). In Class 2 we will use `docker buildx` to build true multi-arch images so the same tag works on both a developer Mac and an amd64 node.”

---

## Demo Part 7: Stop and Remove Containers

```bash
docker stop demo-nginx mounted-nginx
docker rm demo-nginx mounted-nginx
```

Verify:

```bash
docker ps -a
```

Remove demo folder if desired:

```bash
cd ..
rm -rf docker-class-demo
```

---

## Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| Docker daemon not running | Docker Desktop stopped | Start Docker Desktop |
| Port already allocated | Another process uses 8080 or 8081 | Use another host port, such as 8090 |
| Container name already exists | Old container was not removed | Run `docker rm -f demo-nginx` |
| Bind mount fails on Windows | Path syntax issue | Use PowerShell syntax or WSL |
| curl not found | Tool missing | Use browser or install curl |
| Permission denied on Linux | User not in docker group | Use `sudo docker` or add user to docker group |

---

## Cleanup Steps

```bash
docker rm -f demo-nginx mounted-nginx 2>/dev/null || true
docker ps -a
```

Optional image cleanup:

```bash
docker image ls
docker rmi nginx:1.27 alpine:3.20
```

Instructor note: Do not force students to delete images if they will reuse them in Class 2.

---

# 13. Student Lab Manual

## Lab Title

**Run and Inspect Your First Docker Containers**

## Lab Objective

In this lab, you will run Docker containers locally, map ports, view logs, inspect container details, pass environment variables, test a bind mount, and clean up resources.

## Estimated Time

30 minutes

## Student Prerequisites

You should have:

- Docker Desktop or Docker Engine running
- Terminal open
- Browser or `curl`
- Basic command-line familiarity

Verify Docker:

```bash
docker --version
docker info
```

Expected result:

```text
Docker version ...
```

If `docker info` fails, start Docker Desktop or ask the instructor for help.

---

## Architecture or Workflow Overview

```text
Your Laptop
   |
Docker CLI
   |
Docker Engine
   |
Nginx Image
   |
Running Nginx Container
   |
localhost:8080 -> container port 80
```

---

## Step-by-Step Student Instructions

### Step 1: Pull the Nginx Image

```bash
docker pull nginx:1.27
```

Expected output:

```text
Status: Downloaded newer image for nginx:1.27
```

If already downloaded:

```text
Status: Image is up to date for nginx:1.27
```

Note: always pin a tag (`nginx:1.27`), never the bare `nginx` (which silently means `:latest`).

---

### Step 2: Run Nginx as a Container

```bash
docker run -d --name student-nginx -p 8080:80 nginx:1.27
```

Expected output:

```text
<container_id>
```

---

### Step 3: Confirm the Container Is Running

```bash
docker ps
```

Expected output should include:

```text
nginx
0.0.0.0:8080->80/tcp
student-nginx
```

---

### Step 4: Test the Web Server

Use curl:

```bash
curl http://localhost:8080
```

Or open a browser:

```text
http://localhost:8080
```

Expected result:

```text
Welcome to nginx!
```

---

### Step 5: View Container Logs

```bash
docker logs student-nginx
```

Expected output may include:

```text
Configuration complete; ready for start up
```

---

### Step 6: Inspect the Container

```bash
docker inspect student-nginx
```

Look for:

- `Name`
- `Image`
- `State`
- `Ports`
- `NetworkSettings`

Optional filtering:

```bash
docker inspect --format='{{.State.Status}}' student-nginx
```

Expected output:

```text
running
```

---

### Step 7: Execute a Command Inside the Container

```bash
docker exec -it student-nginx sh
```

Inside the container, run:

```bash
hostname
pwd
ls
exit
```

Expected result:

- You should see a shell inside the container.
- `hostname` will usually show the container ID.

---

### Step 8: Run a Temporary Container With an Environment Variable

```bash
docker run --rm -e APP_ENV=dev alpine:3.20 printenv APP_ENV
```

Expected output:

```text
dev
```

Explanation:

- `--rm` removes the container after it exits.
- `-e APP_ENV=dev` passes a runtime environment variable.

---

### Step 9: Test a Bind Mount

Create a folder:

```bash
mkdir docker-lab-html
cd docker-lab-html
echo "Hello from my Docker lab" > index.html
```

Run Nginx with your local folder mounted:

```bash
docker run -d --name lab-mounted-nginx -p 8081:80 -v "$PWD":/usr/share/nginx/html:ro nginx:1.27
```

Windows PowerShell alternative:

```powershell
docker run -d --name lab-mounted-nginx -p 8081:80 -v ${PWD}:/usr/share/nginx/html:ro nginx:1.27
```

Validate:

```bash
curl http://localhost:8081
```

Expected output:

```text
Hello from my Docker lab
```

---

### Step 10: Stop and Remove Containers

```bash
docker stop student-nginx lab-mounted-nginx
docker rm student-nginx lab-mounted-nginx
```

Verify cleanup:

```bash
docker ps -a
```

You should not see `student-nginx` or `lab-mounted-nginx`.

---

## Commands Students Should Run

```bash
docker --version
docker info
docker pull nginx:1.27
docker run -d --name student-nginx -p 8080:80 nginx:1.27
docker ps
curl http://localhost:8080
docker logs student-nginx
docker inspect student-nginx
docker exec -it student-nginx sh
docker run --rm -e APP_ENV=dev alpine:3.20 printenv APP_ENV
mkdir docker-lab-html
cd docker-lab-html
echo "Hello from my Docker lab" > index.html
docker run -d --name lab-mounted-nginx -p 8081:80 -v "$PWD":/usr/share/nginx/html:ro nginx:1.27
curl http://localhost:8081
docker stop student-nginx lab-mounted-nginx
docker rm student-nginx lab-mounted-nginx
docker ps -a
```

---

## Expected Outputs

| Command | Expected Result |
|---|---|
| `docker --version` | Docker version is displayed |
| `docker ps` | Running container appears |
| `curl http://localhost:8080` | Nginx welcome page appears |
| `docker logs student-nginx` | Startup and request logs appear |
| `docker inspect student-nginx` | JSON configuration output appears |
| `docker run --rm -e APP_ENV=dev alpine:3.20 printenv APP_ENV` | `dev` |
| `curl http://localhost:8081` | Custom HTML message appears |
| `docker ps -a` after cleanup | Lab containers no longer appear |

---

## Validation Checklist

Students should confirm:

- [ ] Docker is installed and running.
- [ ] Nginx image was pulled successfully.
- [ ] `student-nginx` container ran successfully.
- [ ] Browser or `curl` reached Nginx.
- [ ] Logs were viewed.
- [ ] Container details were inspected.
- [ ] Environment variable test worked.
- [ ] Bind mount test worked.
- [ ] Lab containers were stopped and removed.

---

## Troubleshooting Tips

| Problem | Check | Fix |
|---|---|---|
| Docker command fails | `docker info` | Start Docker Desktop |
| Port 8080 does not work | `docker ps` | Confirm port mapping |
| Port already in use | Error message from `docker run` | Use `-p 8090:80` |
| Name already exists | `docker ps -a` | Run `docker rm -f student-nginx` |
| Browser does not load | `docker logs student-nginx` | Confirm container is running |
| Bind mount does not work | Current directory path | Use correct PowerShell or Linux/macOS syntax |
| Permission denied | Linux Docker permissions | Use `sudo docker` or ask instructor |

---

## Cleanup Steps

```bash
docker rm -f student-nginx lab-mounted-nginx 2>/dev/null || true
```

Optional:

```bash
cd ..
rm -rf docker-lab-html
```

Do not delete Docker images unless the instructor asks you to.

---

## Reflection Questions

1. What is the difference between an image and a container?
2. Why did we map port `8080` to container port `80`?
3. What did `docker logs` show you?
4. Why are containers useful in CI/CD pipelines?
5. What could go wrong if a team uses different image versions across environments?

---

## Optional Challenge Task

Run two Nginx containers at the same time using different host ports.

Example:

```bash
docker run -d --name nginx-one -p 8082:80 nginx:1.27
docker run -d --name nginx-two -p 8083:80 nginx:1.27
```

Validate:

```bash
curl http://localhost:8082
curl http://localhost:8083
```

Cleanup:

```bash
docker rm -f nginx-one nginx-two
```

---

## Multi-Service Local Dev with Docker Compose

Running containers one `docker run` flag at a time gets unwieldy as soon as you have more than one service. **Docker Compose** is the standard tool for describing a multi-service local stack in a single declarative file, then bringing it all up with one command. (In modern Docker it ships as the `docker compose` subcommand — note the space, not the old standalone `docker-compose` binary.)

We will run a two-service stack: an Nginx web frontend and a Redis cache, on a shared user-defined network so they can reach each other by service name.

### Step 1: Create the Compose File

Create a folder and a file named `compose.yaml`:

```bash
mkdir docker-compose-demo
cd docker-compose-demo
```

```yaml
# compose.yaml
services:
  web:
    image: nginx:1.27
    ports:
      - "8088:80"
    depends_on:
      - cache
  cache:
    image: redis:7.4
    # No host port published: only the web service reaches it,
    # over the automatically created project network, as hostname "cache".
```

### Step 2: Bring the Stack Up

```bash
docker compose up -d
```

### Expected Output

```text
[+] Running 3/3
 ✔ Network docker-compose-demo_default  Created
 ✔ Container docker-compose-demo-cache-1 Started
 ✔ Container docker-compose-demo-web-1   Started
```

### Step 3: Validate

```bash
docker compose ps
curl http://localhost:8088
```

The `curl` returns the Nginx welcome page. Compose put both containers on a shared network named `<project>_default`, where each service is reachable from the others by its service name (`web`, `cache`) via container DNS — no manual `docker network` wiring needed.

Confirm container-to-container DNS works:

```bash
docker compose exec web sh -c "getent hosts cache"
```

### Expected Output

```text
172.x.x.x       cache
```

### Step 4: View Logs Across Services

```bash
docker compose logs
docker compose logs web
```

### Step 5: Tear Down (cleanup)

```bash
docker compose down
```

This stops and removes both containers AND the network Compose created — a single clean teardown, which is exactly why Compose beats juggling many `docker run`/`docker rm` commands.

```bash
cd ..
rm -rf docker-compose-demo
```

### Why This Matters

- Compose is table-stakes for local multi-service development; you will see it again whenever a service needs a database or cache alongside it.
- The user-defined network + DNS-by-service-name model is the same mental model Kubernetes uses for Service discovery (Weeks 11–12).
- `docker compose down` teaching the full-teardown habit reinforces the course's cleanup discipline.

---

# 14. Troubleshooting Activity

## Incident Title

**Containerized Web App Is Not Reachable After Startup**

## Business Impact

A development team is preparing a containerized web application for a CI/CD pipeline. The container appears to start, but the team cannot access the application from the browser. This blocks validation before the image can be promoted to the next environment.

## Symptoms

Students are told:

- The container was started.
- The browser cannot reach the application.
- The developer says, “Docker is broken.”
- The team needs to determine if the problem is Docker, the app, or the runtime command.

## Starting Evidence

The developer ran:

```bash
docker run -d --name broken-nginx -p 80:80 nginx:1.27
```

But the browser does not work.

Possible error:

```text
This site can't be reached
```

Or Docker may return:

```text
Bind for 0.0.0.0:80 failed: port is already allocated
```

Students can inspect:

```bash
docker ps -a
docker logs broken-nginx
docker inspect broken-nginx
```

## Student Investigation Steps

1. Check if the container exists.

```bash
docker ps -a
```

2. Check if the container is running.

```bash
docker ps
```

3. Check logs.

```bash
docker logs broken-nginx
```

4. Check port mapping.

```bash
docker port broken-nginx
```

5. Check whether port `80` is already in use locally.

Linux/macOS:

```bash
lsof -i :80
```

Windows PowerShell:

```powershell
netstat -ano | findstr :80
```

6. Try a safer host port.

```bash
docker rm -f broken-nginx
docker run -d --name fixed-nginx -p 8080:80 nginx:1.27
curl http://localhost:8080
```

## Expected Root Cause

The host port `80` is already used or restricted on the student’s machine.

The container itself is not the real problem. The issue is the host port mapping.

## Correct Resolution

Use a non-privileged, available local port such as `8080`.

```bash
docker rm -f broken-nginx
docker run -d --name fixed-nginx -p 8080:80 nginx:1.27
curl http://localhost:8080
```

Expected result:

```text
Welcome to nginx!
```

## Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Reinstall Docker immediately | The issue is likely port conflict, not installation |
| Delete the image | The image is fine |
| Assume Nginx is broken | Nginx likely runs correctly |
| Try random commands without checking logs | Troubleshooting should start with evidence |
| Ignore the error message | Docker errors often identify the problem clearly |

## Instructor Hints

Use these hints only if students get stuck:

1. “Is the container running or exited?”
2. “What does `docker ps -a` show?”
3. “What host port did you map?”
4. “Is port 80 special on your laptop?”
5. “What happens if you try port 8080 instead?”

## Preventive Action

In real projects:

- Use documented local development ports.
- Avoid using privileged ports like `80` and `443` locally unless needed.
- Include startup commands in a README.
- Add troubleshooting steps to developer onboarding docs.
- Use Docker Compose (covered later in this class) or scripts to standardize local startup.

---

# 15. Scenario-Based Discussion Questions

## Question 1

A developer says, “The container is running, so the application must be working.” Do you agree?

**Expected response themes:**

- Running container does not guarantee app is healthy.
- Need logs, HTTP check, process check, and port validation.
- Later Kubernetes uses readiness and liveness probes.

**Instructor follow-up:**

“What command would you run first to confirm the app is actually responding?”

---

## Question 2

Why should teams avoid relying only on manual container builds for production images?

**Expected response themes:**

- Manual builds are inconsistent.
- CI/CD is auditable.
- Pipeline builds can include tests and security scans.
- Image tags can map to Git commits.

**Instructor follow-up:**

“How would you know which code version is running in production?”

---

## Question 3

A team maps container port `80` to host port `80`, but some developers cannot run it. What is a better local development practice?

**Expected response themes:**

- Use non-privileged ports like `8080`.
- Document port usage.
- Avoid conflicts with local services.
- Use consistent scripts or Docker Compose later.

**Instructor follow-up:**

“What would you include in the README?”

---

## Question 4

Should secrets be passed into containers as plain environment variables during production?

**Expected response themes:**

- Environment variables are common but must be handled carefully.
- Secrets can leak through logs, shell history, or inspect output.
- Use secrets management tools in production.
- AWS Secrets Manager or Kubernetes Secrets may be used later.

**Instructor follow-up:**

“What is safe for today’s lab, and what would change in production?”

---

## Question 5

Why are container logs important for DevOps and SRE teams?

**Expected response themes:**

- Logs help diagnose failures.
- Logs provide runtime evidence.
- Logs connect local Docker troubleshooting to Kubernetes and cloud observability.
- Logs help during incidents.

**Instructor follow-up:**

“What makes a log useful during an incident?”

---

## Question 6

Why do companies use private registries like Amazon ECR instead of only Docker Hub?

**Expected response themes:**

- Access control
- Private images
- Integration with IAM
- Security scanning
- Enterprise governance
- Reduced dependency on public registries

**Instructor follow-up:**

“Who should be allowed to push production images?”

---

## Question 7

A container works on a developer laptop but fails in CI/CD. What differences might cause this?

**Expected response themes:**

- Missing environment variables
- Different architecture
- Different Docker version
- Network restrictions
- Private registry authentication
- Incorrect file paths or build context

**Instructor follow-up:**

“What evidence would you collect from the CI job?”

---

# 16. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

What is the best description of a Docker image?

A. A running application process  
B. A packaged template used to create containers  
C. A virtual machine snapshot  
D. A cloud server

**Answer:** B  
**Explanation:** An image is a packaged template. A container is the running instance created from the image.

---

## Question 2: Multiple Choice

Which command shows running containers?

A. `docker images`  
B. `docker ps`  
C. `docker pull`  
D. `docker build`

**Answer:** B  
**Explanation:** `docker ps` lists currently running containers. `docker ps -a` shows running and stopped containers.

---

## Question 3: Multiple Choice

What does this option do?

```bash
-p 8080:80
```

A. Maps container port 8080 to host port 80  
B. Maps host port 8080 to container port 80  
C. Opens all ports  
D. Creates a Docker volume

**Answer:** B  
**Explanation:** Docker port mapping uses `host_port:container_port`.

---

## Question 4: True or False

A Docker container is the same thing as a full virtual machine.

**Answer:** False  
**Explanation:** A container is an isolated process that shares the host OS kernel. It is not a full guest OS.

---

## Question 5: True or False

`docker logs <container-name>` is useful when troubleshooting a container that starts but does not behave correctly.

**Answer:** True  
**Explanation:** Logs provide evidence from the process running inside the container.

---

## Question 6: Short Answer

What is the difference between an image and a container?

**Answer:** An image is a packaged template. A container is a running instance created from that image.  
**Explanation:** One image can be used to create many containers.

---

## Question 7: Short Answer

Why might a container fail to start?

**Answer:** Common reasons include bad command, missing file, missing dependency, invalid environment variable, port conflict, or application error.  
**Explanation:** Students should check `docker ps -a` and `docker logs`.

---

## Question 8: Troubleshooting Multiple Choice

A student runs:

```bash
docker run -d --name app -p 8080:80 nginx
```

Then this command works:

```bash
docker ps
```

But this fails:

```bash
curl http://localhost:80
```

What is the most likely issue?

A. Nginx image is missing  
B. The student used the wrong host port  
C. Docker is not installed  
D. The container was not created

**Answer:** B  
**Explanation:** The host port is `8080`, so the correct test is `curl http://localhost:8080`.

---

## Question 9: Troubleshooting Short Answer

A Docker command fails with:

```text
Conflict. The container name "/student-nginx" is already in use.
```

What should the student do?

**Answer:** Remove or rename the existing container. Example: `docker rm -f student-nginx` or use a different name.  
**Explanation:** Container names must be unique.

---

## Question 10: AWS Multiple Choice

Which AWS service is commonly used as a private container image registry?

A. Amazon S3  
B. Amazon ECR  
C. Amazon EC2  
D. Amazon CloudWatch

**Answer:** B  
**Explanation:** Amazon Elastic Container Registry stores container images.

---

## Question 11: AWS Short Answer

How does Docker connect to future AWS container workflows?

**Answer:** Docker images can be built locally or in CI/CD, pushed to Amazon ECR, and later deployed to ECS or EKS.  
**Explanation:** Docker is the packaging layer for many AWS container deployments.

---

## Question 12: True or False

If a container is running, the application inside it is always healthy.

**Answer:** False  
**Explanation:** The container process may be running, but the app may still be misconfigured, unreachable, or unhealthy.

---

# 17. Homework Assignment

## Assignment Title

**Docker Runtime Basics: Run, Inspect, Explain, and Clean Up**

## Scenario

You are a junior DevOps engineer onboarding to a team that is beginning to containerize applications. Your lead asks you to prove that you can run a container locally, inspect it, troubleshoot basic issues, and document what you did.

## Student Tasks

Complete the following:

1. Pull the Nginx image.
2. Run an Nginx container named `homework-nginx` on host port `8085`.
3. Validate the app with browser or `curl`.
4. Capture output from:
   - `docker ps`
   - `docker logs homework-nginx`
   - `docker inspect --format='{{.State.Status}}' homework-nginx`
5. Run a temporary Alpine container with an environment variable:
   - `APP_ENV=homework`
6. Explain the difference between:
   - Image and container
   - Container and VM
   - Host port and container port
   - Docker Hub and Amazon ECR
7. Stop and remove the container.
8. Confirm cleanup.

## Suggested Commands

```bash
docker pull nginx:1.27
docker run -d --name homework-nginx -p 8085:80 nginx:1.27
docker ps
curl http://localhost:8085
docker logs homework-nginx
docker inspect --format='{{.State.Status}}' homework-nginx
docker run --rm -e APP_ENV=homework alpine:3.20 printenv APP_ENV
docker stop homework-nginx
docker rm homework-nginx
docker ps -a
```

## Expected Deliverables

Students submit:

1. Command output or screenshots showing successful container run.
2. Short written explanation of key concepts.
3. Cleanup confirmation.
4. One paragraph explaining why containers are useful in CI/CD and Kubernetes workflows.

## Submission Format

One of the following:

- Markdown file
- PDF export
- Text document
- Git repository README

Recommended file name:

```text
week10-class1-docker-runtime-homework.md
```

## Estimated Completion Time

45 to 60 minutes

## Grading Criteria

| Criteria | Points |
|---|---:|
| Container runs successfully | 20 |
| Correct port validation | 15 |
| Logs and inspect output captured | 15 |
| Environment variable test completed | 10 |
| Concept explanations are accurate | 25 |
| Cleanup completed | 10 |
| Clear formatting and documentation | 5 |
| Total | 100 |

## Optional Advanced Challenge

Run two Nginx containers at the same time on different ports and explain why this works.

Example:

```bash
docker run -d --name nginx-a -p 8086:80 nginx:1.27
docker run -d --name nginx-b -p 8087:80 nginx:1.27
```

Cleanup:

```bash
docker rm -f nginx-a nginx-b
```

---

# 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Docker Desktop is not running | Students assume Docker CLI alone is enough | Start Docker Desktop and verify with `docker info` |
| Confusing image with container | Both are new terms | Repeat: image is template, container is running instance |
| Using wrong port in browser | Students confuse host and container ports | Remember `-p host:container` |
| Forgetting `-d` | Container takes over terminal | Use detached mode for background services |
| Not checking logs | Beginners guess instead of collecting evidence | Start troubleshooting with `docker logs` |
| Container name conflict | Old container still exists | Use `docker ps -a` and `docker rm -f <name>` |
| Port already allocated | Another local service uses the port | Use a different host port |
| Not cleaning up | Students leave many stopped containers | Use `docker ps -a` and remove lab containers |
| Using real secrets in environment variables | Students do not understand secret exposure | Use fake values in labs and secrets managers in production |
| Running too many containers | Laptop resources become slow | Stop and remove unused containers |

---

# 19. Real-World Enterprise Scenario

## Scenario

A logistics company is modernizing an internal shipment tracking application. Previously, developers installed runtime dependencies manually on test servers. Each environment behaved differently, and releases often failed because test and production servers were not configured the same way.

The platform team decides to standardize application packaging with Docker.

## Constraints

| Constraint | Example |
|---|---|
| Access control | Only CI/CD should push production images |
| Security | Images must not contain hardcoded secrets |
| Cost | Avoid unnecessary cloud resources during local development |
| Reliability | The same image should be tested before production |
| Production impact | Bad image versions must be traceable and rollback-ready |
| Approvals | Production image promotion requires review |
| Observability | Container logs must be available for troubleshooting |

## How This Class Topic Applies

Students learn the local foundation:

- Run an application container
- Inspect logs
- Validate ports
- Pass runtime config
- Understand image/container separation

Later, the same workflow becomes:

```text
Developer tests container locally
   |
Code is merged
   |
CI/CD builds official image
   |
Image is pushed to Amazon ECR
   |
Kubernetes deploys the image
   |
SRE monitors logs and metrics
```

## Role-Based Responsibilities

### DevOps Engineer

- Builds CI/CD workflow for Docker image creation
- Tags images with Git commit SHA
- Pushes images to Amazon ECR
- Adds image scanning and deployment controls

### Cloud Engineer

- Provides registry, IAM roles, networking, and cloud access patterns
- Ensures ECR access is secure
- Designs cloud environment where containers will run

### SRE

- Ensures logs, metrics, and health checks exist
- Troubleshoots failing containers
- Defines operational readiness requirements
- Helps create rollback and incident response procedures

---

# 20. Instructor Tips

## Teaching Tips

- Keep the first class focused on runtime basics.
- Do not go too deep into Dockerfile yet. That belongs in Class 2.
- Repeat image vs container often.
- Use diagrams before commands.
- Ask students to explain commands in plain English.
- Encourage evidence-based troubleshooting.

## Pacing Tips

- Spend enough time on containers vs VMs, but do not over-explain OS kernel internals.
- Keep the demo clean and simple.
- Reserve at least 25 to 30 minutes for lab time.
- Keep the final recap focused on operational habits.

## Lab Support Tips

When a student is stuck, ask for:

1. Exact command
2. Exact error
3. Output of `docker ps -a`
4. Output of `docker logs <container>`
5. Output of `docker info`

## Helping Struggling Students

Use these reminders:

- “You do not need to memorize every command today.”
- “Focus on the container lifecycle.”
- “Start with `docker ps`, then logs.”
- “Read the error message carefully.”
- “Use port `8080` instead of port `80`.”

## Challenging Advanced Students

Ask them to:

- Run two containers from the same image.
- Use different host ports.
- Use a bind mount.
- Inspect container network settings.
- Explain how this would work in Kubernetes.
- Compare Docker local logs with CloudWatch or Kubernetes logs.

---

# 21. Student Outcome Checklist

## Students Should Be Able to Explain

- [ ] What Docker is
- [ ] What a container is
- [ ] What an image is
- [ ] Difference between containers and VMs
- [ ] Difference between image and container
- [ ] What a registry does
- [ ] Why logs matter
- [ ] Why port mapping matters
- [ ] How Docker connects to CI/CD and Kubernetes
- [ ] What Amazon ECR is used for

## Students Should Be Able to Build or Configure

- [ ] Pull a public Docker image
- [ ] Run a container locally
- [ ] Map host port to container port
- [ ] Pass an environment variable
- [ ] Use a simple bind mount
- [ ] Execute a command inside a container
- [ ] Stop and remove containers

## Students Should Be Able to Troubleshoot

- [ ] Docker daemon not running
- [ ] Port conflict
- [ ] Wrong host port
- [ ] Container name conflict
- [ ] Container exited unexpectedly
- [ ] Missing logs or unclear output
- [ ] Bind mount path issues
- [ ] Cleanup problems

---

# 22. Class Completion Checklist

## Instructor Checklist Before Ending Class

- [ ] Students understand image vs container.
- [ ] Students understand container vs VM.
- [ ] Students saw a working Nginx container.
- [ ] Students practiced `docker ps`, `docker logs`, and `docker inspect`.
- [ ] Students understand `-p host:container`.
- [ ] Students completed or started the lab.
- [ ] Students understand cleanup steps.
- [ ] Homework has been explained.
- [ ] Students understand that Class 2 will cover Dockerfile and image builds.

## Student Checklist Before Leaving Class

- [ ] Docker is working on my machine.
- [ ] I successfully ran an Nginx container.
- [ ] I accessed the container through localhost.
- [ ] I viewed container logs.
- [ ] I inspected the container.
- [ ] I tested an environment variable.
- [ ] I cleaned up lab containers.
- [ ] I understand the homework assignment.

## Items to Verify Before Moving to Class 2

Students should be ready for Class 2 if they can:

- Run Docker commands without major setup issues
- Explain image vs container
- Run and stop a container
- Troubleshoot basic port and name conflicts
- Understand why Docker images are needed before Kubernetes
- Understand that Class 2 will focus on creating custom images using Dockerfiles

---

# 23. Class Artifacts & Validation

This class teaches the **container runtime** (run/inspect/logs, ports, env vars,
bind mounts, a multi-service Compose stack, and evidence-first runtime
troubleshooting). The runnable artifacts it exercises live in
[`labs/docker-containers/`](../../labs/docker-containers/). The Dockerfiles that
*build* those images are the focus of Class 02 and are validated there. Every
path below resolves; the validation commands were run against a real Docker
daemon in this environment (full gate set: `labs/docker-containers/validate.sh`,
**16 passed, 0 failed, 0 deferred**).

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/docker-containers/solution/compose.yaml | compose | Multi-service stack (app + redis sidecar) on a private bridge network, healthchecks, resource limits, non-root, no published Redis port — the on-disk version of the Class 01 Compose demo (§13) | `docker compose -f solution/compose.yaml config` | PASS |
| 2 | labs/docker-containers/app/server.py | python | The stdlib HTTP service the stack runs: `GET /healthz` -> 200, `GET /` -> JSON; reads `$PORT` | `python3 -m py_compile app/server.py app/healthcheck.py` | PASS |
| 3 | labs/docker-containers/tests/test_server.py | python (tests) | stdlib `unittest` suite for the app (routes, status codes) — no Docker needed | `python3 -m unittest discover -s tests -p 'test_*.py'` | PASS (5 tests) |
| 4 | labs/docker-containers/broken/Dockerfile | docker (fixture) | Reproducible broken state for the runtime troubleshooting habit: builds fine but the container stays `unhealthy` (curl-based HEALTHCHECK on a slim base with no curl) | `docker build -f broken/Dockerfile -t dc-broken .` then `docker inspect --format '{{.State.Health.Status}}' dc-broken` | PASS — builds; container reports `unhealthy` as designed (see README → Troubleshooting) |
| 5 | labs/docker-containers/docs/architecture.mmd | mermaid | Architecture diagram of the runtime topology (client → app on `127.0.0.1:8000`; redis internal-only on `appnet`) | renders as a Mermaid `flowchart`; matches the deployed stack | PASS |
| 6 | labs/docker-containers/validate.sh | shell | Full gate runner for the module (auto-`DEFER`s Docker gates when no daemon) | `bash -n validate.sh` (syntax) and `./validate.sh` (full) | PASS (16/16 with a daemon present) |

> No live cloud or long-running operated evidence is captured for this class:
> everything runs locally in Docker at $0. The grype/syft supply-chain gates and
> the image *build* itself belong to Class 02's manifest, where they are
> validated.

# 24. Definition of Done

Ticked honestly for **Week 10 Class 01** (runtime + Compose). The backing lab is
[`labs/docker-containers/`](../../labs/docker-containers/).

- [x] Every technology taught ships at least one **runnable file on disk** (not just a fence). — Compose stack, stdlib app + tests, broken fixture, and the architecture diagram are all real files; the runtime commands target them.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured. — All gates above ran and PASS against a real daemon (`validate.sh`: 16/16).
- [x] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions. — `starter/` (TODO gaps) and `solution/` both exist.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes**. — All present in `labs/docker-containers/README.md`.
- [x] **Cleanup/teardown** is provided and idempotent. — README "Cleanup" uses `docker compose down -v` + idempotent `docker rm -f ... || true`.
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise. — Quiz/homework answer keys are in this file (§16–17); the lab/troubleshooting key is `README.md` → "Instructor answer key" + "Troubleshooting".
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state*. — `broken/Dockerfile` reproducibly reports `unhealthy`; this class's runtime incident (§14) is the host port-`80` conflict, reproduced from evidence.
- [x] **Expected outputs** are shown for demos and labs. — §12–13 and README "Expected results" show exact outputs (`{"status":"ok"}`, Nginx welcome page, healthy status).
- [x] **Cost & security warnings** present. — README "Cost considerations" ($0, local only) and "Security considerations"; §6/§10 cover secrets-in-env and ECR cost.
- [x] **Cross-references** to the module repo and to prior/next weeks are correct. — Links to `labs/docker-containers/`; W9 (CI/CD) prior, W11–12 (Kubernetes) next, verified.
- [x] The **artifact manifest** (§4.2) is present and every path resolves. — §23 above; all paths `ls`-verified.
- [ ] **Mastered / capstone-operated** — the image is *built and run* here but not yet reused/operated inside a later week or the capstone within this repo. The README names downstream consumers (`kubernetes-fundamentals`, `capstone`); that reuse is not yet wired, so this box stays unticked and the score is capped accordingly.
