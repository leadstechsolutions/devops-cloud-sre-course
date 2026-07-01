# Week 10, Class 2 Package  
> **▶ Runnable lab for this class:** [`labs/docker-containers/`](../../labs/docker-containers/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Dockerfiles, Images, Registries, and Image Security

**Week:** 10
**Class:** 2
**Track:** Unified DevOps · Cloud · SRE Track

---

# 1. Class Overview

## Class Title

**Building Docker Images and Pushing to a Container Registry**

## Class Purpose

This class teaches students how to move from simply running existing containers to building their own container images. Students will learn how Dockerfiles work, how images are built, how to tag images, how registries fit into real delivery workflows, and how to troubleshoot common build-time and runtime failures.

## How This Class Builds From Class 1

Class 1 focused on running and inspecting containers locally. Students learned:

- What containers are
- What images are
- How to run containers
- How to map ports
- How to check logs
- How to inspect containers
- How to troubleshoot basic runtime issues

Class 2 extends that foundation by showing students how images are created.

Class 1 question:

```text
How do I run a container from an existing image?
```

Class 2 question:

```text
How do I create my own image so my application can run as a container?
```

## What Students Will Build, Analyze, or Practice

Students will:

- Create a simple web application
- Write a Dockerfile
- Build a custom Docker image
- Run the custom container locally
- Pass an environment variable into the container
- View logs and validate application response
- Tag an image
- Learn the conceptual Amazon ECR push workflow
- Troubleshoot a broken Dockerfile and failed container startup

---

# 2. Quick Review of Class 1

## Review Points

1. A **Docker image** is a packaged template.
2. A **container** is a running instance of an image.
3. `docker run` creates and starts a container.
4. `docker ps` shows running containers.
5. `docker ps -a` shows running and stopped containers.
6. `docker logs` is one of the first troubleshooting commands.
7. Port mapping uses the format `host_port:container_port`.
8. Containers are disposable, so cleanup is important.

## Quick Recall Questions

### Question 1

What is the difference between an image and a container?

Expected answer:

```text
An image is the package or template. A container is the running instance created from that image.
```

### Question 2

What does this do?

```bash
-p 8080:80
```

Expected answer:

```text
It maps host port 8080 to container port 80.
```

### Question 3

Which command would you run first if a container exits immediately?

Expected answer:

```bash
docker ps -a
docker logs <container-name>
```

## Common Gaps Students May Still Have From Class 1

| Gap | Instructor Response |
|---|---|
| Students still confuse image and container | Reuse the blueprint vs running instance analogy |
| Students confuse host port and container port | Repeat `host:container` using `8080:80` |
| Students skip logs when troubleshooting | Reinforce evidence-first troubleshooting |
| Students forget to clean up containers | Show `docker rm -f <name>` again |
| Students think Docker is only local | Explain how Docker connects to CI/CD, ECR, ECS, and EKS |

## Bridge Into Class 2

Instructor transition:

```text
In Class 1, we pulled images that someone else already created, like nginx and alpine. Today we will create our own image. This is what DevOps teams do when they package application code for CI/CD, Kubernetes, and cloud deployments.
```

---

# 3. Class Learning Objectives

By the end of this class, students will be able to:

1. **Explain** the purpose of a Dockerfile in the container build process.
2. **Build** a hardened custom image using a **multi-stage build** with a minimal base, a **non-root** user, and a `HEALTHCHECK`.
3. **Describe** how Docker image layers are created and cached from Dockerfile instructions.
4. **Run** and **validate** a custom application container locally.
5. **Configure** runtime behavior using environment variables and build-time `ARG` values.
6. **Tag and pin** a container image (version tag and immutable digest) for registry upload.
7. **Scan** a built image for vulnerabilities (Trivy) and **gate** the build on HIGH/CRITICAL findings; generate an SBOM (syft) and understand image signing (cosign).
8. **Troubleshoot** Dockerfile, image build, port, command, and dependency issues using evidence-first methodology.

---

# 4. Prerequisites Students Should Already Know

## Required Class 1 Knowledge

Students should already understand:

- Image vs container
- Container vs VM
- Docker CLI basics
- Port mapping
- Container logs
- `docker ps`
- `docker ps -a`
- `docker logs`
- `docker inspect`
- Basic cleanup commands

## Required Prior Concepts

Students should understand:

- Basic terminal commands
- Files and folders
- Simple HTTP request and response
- Basic environment variables
- Basic Git workflow
- Basic CI/CD packaging concept

## Required Tools Already Installed

Students need:

- Docker Desktop or Docker Engine
- Terminal
- VS Code or another code editor
- `curl`
- Python is optional locally because Python will run inside the container
- AWS CLI is optional for the ECR preview flow
- Trivy (or `docker scout`, bundled with Docker Desktop) for the image scan step; syft is optional for the SBOM step

## Required Files, Repos, Lab Outputs, or Setup From Class 1

Students should have:

- Docker running successfully
- Ability to run `docker info`
- Ability to run Nginx locally
- No required containers still running from Class 1

Recommended cleanup before starting Class 2:

```bash
docker ps -a
docker rm -f student-nginx lab-mounted-nginx homework-nginx 2>/dev/null || true
```

Windows PowerShell alternative:

```powershell
docker ps -a
docker rm -f student-nginx lab-mounted-nginx homework-nginx
```

If no containers exist, Docker may show an error for the remove command. That is acceptable.

---

# 5. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Dockerfile | A text file containing instructions to build a Docker image | DevOps teams use Dockerfiles to package applications consistently |
| Base Image | The starting image used by a Dockerfile | Example: `python:3.13-slim` provides Python runtime |
| Build Context | The files Docker can access during image build | Usually the current folder where `docker build` is run |
| Layer | A reusable image change created by a Dockerfile instruction | Layers help Docker cache builds and reduce rebuild time |
| `FROM` | Dockerfile instruction that sets the base image | Every normal Dockerfile starts with `FROM` |
| `WORKDIR` | Sets the working directory inside the image | Keeps app files organized inside the container |
| `COPY` | Copies files from local machine into the image | Used to add app code and dependency files |
| `RUN` | Runs a command during image build | Used to install packages or dependencies |
| `EXPOSE` | Documents the port the containerized app listens on | It does not publish the port by itself |
| `CMD` | Default command that runs when the container starts | Often starts the application process |
| Image Tag | A label for an image version | Example: `app:v1`, `app:dev`, or Git commit SHA |
| Registry | Remote location for storing container images | Amazon ECR is commonly used in AWS environments |
| Repository | A named image collection inside a registry | Example: `student-docker-app` |
| Build-Time | Actions that happen when the image is created | Example: installing Python packages |
| Runtime | Actions that happen when the container starts | Example: passing environment variables |
| `.dockerignore` | File that excludes unnecessary files from build context | Helps prevent secrets or large folders from entering the image build |
| Multi-stage build | A Dockerfile with more than one `FROM`; a heavy "build" stage produces artifacts that are copied into a small "runtime" stage | The standard way to ship small, low-attack-surface images in 2026 |
| Minimal / distroless base | A base image containing only what the app needs to run — no shell, no package manager | Smaller images, far fewer CVEs; e.g. `python:3.13-slim`, Google distroless, Chainguard |
| Non-root user (`USER`) | Running the container process as an unprivileged user instead of root | A baseline hardening control; required by most Kubernetes security policies |
| `HEALTHCHECK` | Dockerfile instruction that tells the runtime how to test whether the app is healthy | Maps directly to Kubernetes liveness/readiness probes in Weeks 11–12 |
| `ARG` vs `ENV` | `ARG` is a build-time variable (not present at runtime); `ENV` persists into the running container | Use `ARG` for build inputs like version; never bake secrets into either |
| Image digest | An immutable content hash (`@sha256:...`) identifying an exact image | Pin by digest for reproducible, tamper-evident deployments |
| Image scanning | Inspecting an image's packages for known CVEs | Trivy, grype, docker scout, ECR scan-on-push; a baseline CI gate |
| SBOM | Software Bill of Materials — a machine-readable inventory of everything in the image | Generated with syft; required for supply-chain compliance (bridges to W19 DevSecOps) |
| BuildKit / buildx | Docker's modern build engine and the multi-platform build CLI | Faster builds, cache mounts, secret mounts, multi-arch images |

---

# 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| Docker CLI | Build, run, tag, inspect, and troubleshoot images and containers |
| Docker Engine or Docker Desktop | Executes Docker build and container runtime operations |
| Dockerfile | Defines how the custom image is built |
| VS Code | Used to create and edit app files and Dockerfile |
| Terminal | Runs all Docker commands |
| curl | Validates the application HTTP response |
| Python Flask | Simple web app framework used for demonstration |
| Docker Hub | Optional registry for image push practice |
| Amazon ECR | AWS private registry introduced as the enterprise target |
| AWS CLI | Optional for demonstrating ECR login and push flow |
| Git | Optional for saving the lab application files |
| Trivy | Open-source image vulnerability scanner used to fail the build on HIGH/CRITICAL CVEs |
| syft | Generates a Software Bill of Materials (SBOM) from the built image |
| docker scout | Docker's built-in CVE scanner (alternative to Trivy), bundled with Docker Desktop |
| cosign | Sigstore tool for signing images (introduced conceptually; deepened in W19 DevSecOps) |
| docker buildx / BuildKit | Modern build engine for cache mounts, build secrets, and multi-arch images |

---

# 7. AWS Services Used

| AWS Service | How It Connects to Class 2 |
|---|---|
| Amazon ECR | Stores Docker images in AWS for ECS, EKS, and CI/CD workflows |
| IAM | Controls who can push and pull images from ECR |
| Amazon EKS | Later pulls images from ECR to run Kubernetes workloads |
| Amazon ECS | AWS-native container service that can run images from ECR |
| CloudWatch Logs | Later stores logs from containers running in AWS |

## AWS Primary Flow

```text
Application Code
   |
Dockerfile
   |
docker build
   |
Docker Image
   |
docker tag
   |
docker push
   |
Amazon ECR
   |
EKS or ECS pulls the image
   |
Application runs in AWS
```

## Cost and Security Notes

- Local Docker builds do not create AWS cost.
- ECR can create small storage costs if images are pushed and left there.
- Do not place secrets inside Docker images.
- Do not copy `.env` files containing real credentials into images.
- In enterprise environments, CI/CD should push images to ECR using controlled IAM roles.

---

# 8. Azure and GCP Comparison Notes

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Container registry | Amazon ECR | Azure Container Registry | Artifact Registry |
| Managed Kubernetes | Amazon EKS | Azure Kubernetes Service | Google Kubernetes Engine |
| Image scanning | ECR image scanning | Microsoft Defender for Cloud | Artifact Analysis |
| IAM integration | AWS IAM | Microsoft Entra ID and Azure RBAC | Google Cloud IAM |

## Instructor Talking Point

```text
The Dockerfile and Docker image concepts are portable. The registry changes by cloud provider, but the build, tag, push, and pull workflow is very similar across AWS, Azure, and GCP.
```

---

# 9. Time-Boxed Instructor Agenda

| Time | Section | Instructor Activity | Student Activity |
|---:|---|---|---|
| 0:00 to 0:15 | Class 1 review | Review image, container, ports, logs | Answer recall questions |
| 0:15 to 0:40 | Dockerfile concepts | Explain Dockerfile structure, multi-stage builds, non-root, HEALTHCHECK | Follow along and ask questions |
| 0:40 to 1:10 | Instructor demo | Build a hardened multi-stage image, scan it (Trivy gate), generate SBOM | Observe commands and outputs |
| 1:10 to 1:20 | Break | Pause | Break |
| 1:20 to 1:40 | Registries and tagging | Explain Docker Hub, ECR, tags, image promotion | Discuss enterprise image workflows |
| 1:40 to 2:25 | Student lab | Support students building their image | Build, run, validate, and tag custom image |
| 2:25 to 2:50 | Troubleshooting activity | Inject broken Dockerfile scenario | Diagnose and fix failure |
| 2:50 to 3:00 | Recap and homework | Review outcomes and assignment | Ask final questions |

---

# 10. Instructor Lesson Plan

## 0:00 to 0:15 - Review and Bridge

### Explain

Start by reviewing Class 1:

```text
Last class, we ran containers from existing images. Today, we become the team that creates the image. This is the step that connects application code to CI/CD, registries, and Kubernetes.
```

### Show

Run:

```bash
docker images
docker ps -a
```

Explain that existing images such as `nginx` and `alpine` were created by someone else.

### Pause for Questions

Ask:

```text
If nginx is an image someone else created, what would we need in order to create an image for our own application?
```

Expected answers:

- Application code
- Runtime
- Dependencies
- Startup command
- Port information

Transition:

```text
Those requirements become instructions inside a Dockerfile.
```

---

## 0:15 to 0:40 - Dockerfile Concepts

### Explain

Introduce each Dockerfile instruction:

- `FROM`
- `WORKDIR`
- `COPY`
- `RUN`
- `EXPOSE`
- `CMD`

### Show

Start by showing the *naive* single-stage Dockerfile so students can see what we are improving on:

```dockerfile
# Naive starter Dockerfile (we will harden this)
FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
```

This works, but it has three problems that a 2026 senior screen will flag immediately:

1. **It runs as root.** Anything that escapes the app runs with root inside the container.
2. **It ships build tooling and pip caches** into the runtime image, enlarging the attack surface.
3. **It has no health signal.**

### Multi-stage builds (CORE concept — teach this, do not defer it)

A **multi-stage build** uses more than one `FROM`. A heavy "builder" stage compiles/installs dependencies; a small "runtime" stage copies in *only* the artifacts needed to run. The build tooling never reaches the final image.

This is the **baseline modern Dockerfile** for this class:

```dockerfile
# syntax=docker/dockerfile:1

#############################
# Stage 1: builder
#############################
FROM python:3.13-slim AS builder
WORKDIR /app

# Install dependencies into an isolated prefix so we can copy just that out.
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

#############################
# Stage 2: runtime (small, non-root)
#############################
FROM python:3.13-slim AS runtime

# Create an unprivileged user; do NOT run as root.
RUN useradd --create-home --uid 10001 appuser
WORKDIR /app

# Copy only the installed packages from the builder stage.
COPY --from=builder /install /usr/local
# Copy application code last so code changes don't bust the dependency cache layer.
COPY app.py .

# Drop privileges.
USER appuser

EXPOSE 5000

# Tell the runtime how to check health (maps to K8s probes in Weeks 11-12).
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:5000/health').status==200 else 1)"

CMD ["python", "app.py"]
```

### Teaching Tip

Walk through *why each line earns its place*:

- **Two `FROM`s.** `builder` has pip and build deps; `runtime` is lean. `COPY --from=builder` pulls only the installed packages forward — build tooling stays behind.
- **`python:3.13-slim`** is a current, small base. Note the trade-off ladder: `slim` (has a shell, easy to debug) → **distroless** (`gcr.io/distroless/python3` — no shell, no package manager, far fewer CVEs) → `scratch` (nothing at all, for static binaries). Smaller base = smaller attack surface, but harder to debug. For this class `slim` is the teaching default; we discuss distroless as the next step.
- **`USER appuser`** (uid 10001) makes root the exception, not the default. Most Kubernetes admission policies *reject* root containers.
- **`HEALTHCHECK`** gives the runtime a real liveness signal — the same idea you wire into Kubernetes liveness/readiness probes in Weeks 11–12. A `/health` endpoint already exists in our app, so we use it.
- **Layer ordering** (`COPY requirements.txt` → install → `COPY app.py`) still matters: changing app code does not re-run the dependency install.

### Pause for Questions

Ask:

```text
Which instruction runs during build time, and which instruction runs when the container starts?
Why does the builder stage never end up in the final image?
```

Expected answer:

- `RUN` happens at build time; `CMD` runs at container startup.
- Only what we explicitly `COPY --from=builder` is carried into the runtime stage; everything else in the builder is discarded.

Transition:

```text
Now let’s build this hardened image and run it just like we ran nginx in Class 1 — then we will scan it.
```

---

## 0:40 to 1:10 - Instructor Demo

### Explain

The demo has four parts:

1. Create simple app files
2. Write a Dockerfile
3. Build image
4. Run and validate container

### Show

Use the demo script in Section 13.

### Pause for Questions

After the image runs successfully, ask:

```text
Which part came from Class 1, and which part is new today?
```

Expected response:

- Class 1: running, logs, ports, cleanup
- Class 2: Dockerfile, build, tag

Transition:

```text
Now that we can build locally, let’s talk about where images go in real companies.
```

---

## 1:10 to 1:20 - Break

Ask students to keep Docker Desktop running.

---

## 1:20 to 1:40 - Registries and Tagging

### Explain

A local image is useful for testing. A registry makes the image available to other systems.

In enterprise:

- CI/CD builds image
- Image is tagged
- Image is scanned
- Image is pushed to private registry
- Kubernetes or ECS pulls image

### Show

Tagging syntax:

```bash
docker tag docker-demo-app:v1 your-repo/docker-demo-app:v1
```

ECR conceptual syntax:

```bash
docker tag docker-demo-app:v1 <account-id>.dkr.ecr.us-east-1.amazonaws.com/docker-demo-app:v1
```

### Security Note

Warn students:

```text
Never copy secrets into container images. If a secret enters an image layer, removing it later is not as simple as deleting a line from the Dockerfile.
```

Transition:

```text
Now students will build and run their own custom image.
```

---

## 1:40 to 2:25 - Student Lab

### Instructor Role

Help students with:

- Incorrect folder location
- Incorrect Dockerfile capitalization
- Missing `requirements.txt`
- Flask app not listening on `0.0.0.0`
- Port mismatch
- Container exits immediately
- Image tag mismatch

### Support Questions

Ask students:

```text
What folder are you in?
What files are in the folder?
What command did you run?
Did the image build successfully?
Is the container running or exited?
What do the logs show?
```

Transition:

```text
Now we will intentionally break the Dockerfile and troubleshoot it like an engineer.
```

---

## 2:25 to 2:50 - Troubleshooting Activity

### Explain

Students receive a broken Dockerfile or broken command.

They must use:

```bash
docker build
docker ps -a
docker logs
docker inspect
```

### Teaching Tip

Do not give the answer immediately. Make them collect evidence.

Transition:

```text
This troubleshooting method is the same method we will use in Kubernetes next week, but with kubectl instead of docker.
```

---

## 2:50 to 3:00 - Recap and Homework

### Recap Points

Students should remember:

- Dockerfile defines image build steps.
- `RUN` happens during build.
- `CMD` happens when the container starts.
- Images need tags.
- Registries store images.
- ECR is AWS’s private registry.
- Logs and container status are still key troubleshooting tools.

### Homework Direction

Students will write their own Dockerfile, build the image, run it, explain each instruction, and document troubleshooting steps.

---

# 11. Instructor Lecture Notes

## Opening Notes

```text
Today is where Docker becomes real for application delivery. In Class 1, students used containers created by others. In Class 2, they learn to package their own application as a container image.
```

## Why Dockerfiles Matter

A Dockerfile is a repeatable recipe. Instead of telling someone to manually install Python, copy files, install dependencies, and run the app, the team writes those steps once as code.

This supports DevOps because:

- Builds become repeatable
- CI/CD can automate image creation
- Kubernetes can run the same image
- Rollbacks can use previous image tags
- Security tools can scan the image

## Build-Time vs Runtime

This is one of the most important Class 2 concepts.

Build-time happens when the image is created:

```dockerfile
RUN pip install --no-cache-dir -r requirements.txt
```

Runtime happens when a container starts:

```dockerfile
CMD ["python", "app.py"]
```

Instructor phrasing:

```text
Build-time prepares the package. Runtime starts the process.
```

## Docker Image Layers

Each Dockerfile instruction creates a layer. Docker can cache layers to speed up future builds.

Example:

```dockerfile
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
```

This is better than copying all files first because dependency installation can be cached when only app code changes.

Beginner-friendly explanation:

```text
Docker remembers previous steps when possible. If your dependency file did not change, Docker may reuse that layer instead of reinstalling everything.
```

## Why `0.0.0.0` Matters

Many beginner container apps fail because they listen only on `127.0.0.1` inside the container.

For Flask, this is important:

```python
app.run(host="0.0.0.0", port=5000)
```

Explain:

```text
Inside a container, binding to 127.0.0.1 can prevent traffic from reaching the app from outside the container. Binding to 0.0.0.0 allows the app to listen on all container interfaces.
```

## `EXPOSE` vs `-p`

Common misconception:

```text
EXPOSE 5000 does not publish the port to your laptop.
```

`EXPOSE` documents the container port.

This publishes it:

```bash
docker run -p 5000:5000 image-name
```

## Image Tags

Bad practice:

```text
latest
```

Better examples:

```text
v1
dev
2026-04-26
git-sha-abc123
```

Enterprise recommendation:

- Use immutable tags for production.
- Tag images with Git commit SHA.
- **Pin by digest** (`image@sha256:...`) in deployment manifests for full immutability and tamper-evidence — a re-pushed tag cannot silently change what runs.
- Use promotion strategies instead of rebuilding differently per environment.

Find an image's digest:

```bash
docker inspect --format='{{index .RepoDigests 0}}' docker-demo-app:v1
```

## Registries

A registry is how other systems access the image.

Local image:

```text
Only your machine can use it.
```

Pushed image:

```text
CI/CD, Kubernetes, ECS, or other engineers can pull it.
```

## Amazon ECR Context

Amazon ECR is the AWS-native place to store container images.

DevOps connection:

- CI/CD logs in to ECR
- Pipeline builds image
- Pipeline tags image
- Pipeline pushes image

Cloud Engineering connection:

- IAM roles allow push and pull
- VPC endpoints may allow private access
- Repository policies can restrict access

SRE connection:

- Image version is tied to incidents
- Rollback may use previous known-good image
- Runtime issues may be traced to a specific image tag

## Common Misconceptions

| Misconception | Correction |
|---|---|
| Dockerfile runs every time the container starts | Dockerfile is used to build the image. `CMD` runs when the container starts |
| `EXPOSE` publishes a port | `EXPOSE` documents a port. `-p` publishes it |
| `latest` always means newest correct image | `latest` is just a tag and can be risky |
| If the image builds, the app must work | Build success does not guarantee runtime success |
| Local image is available to Kubernetes automatically | Kubernetes needs access to a registry |
| Removing a secret from a later Dockerfile line removes it from all image history | Secrets can remain in layers. Do not put secrets in images |

---

# 12. Whiteboard Explanation

## Class 1 to Class 2 Flow

```text
Class 1:
Pull existing image
   |
Run container
   |
Inspect logs and ports


Class 2:
Write application code
   |
Write Dockerfile
   |
Build custom image
   |
Run custom container
   |
Tag image
   |
Push to registry
```

## Simple Dockerfile Build Flow

```text
Application Folder
   |
   |-- app.py
   |-- requirements.txt
   |-- Dockerfile
   |
docker build
   |
Custom Image: docker-demo-app:v1
   |
docker run
   |
Running Container
   |
curl localhost:5000
```

## What Each Component Means

| Component | Meaning |
|---|---|
| `app.py` | Application source code |
| `requirements.txt` | Python dependencies |
| `Dockerfile` | Instructions for building the image |
| `docker build` | Creates the image |
| `docker run` | Starts the container from the image |
| `docker tag` | Adds a registry-ready name/version |
| Registry | Stores image for CI/CD or Kubernetes |

## Enterprise Version

```text
Developer Git Commit
   |
Merge Request / Pull Request
   |
CI/CD Pipeline
   |
docker build
   |
Unit Tests
   |
Security Scan
   |
docker tag
   |
docker push
   |
Amazon ECR
   |
EKS Deployment
   |
CloudWatch / Datadog / Grafana
```

## How Class 2 Extends Class 1

Class 1 taught:

```text
How to operate a container
```

Class 2 teaches:

```text
How to package an application into an image so containers can be created consistently
```

---

# 13. Instructor Demo Script

## Demo Title

**Build and Run a Custom Docker Image**

## Demo Objective

Show students how to create a simple Flask application, write a Dockerfile, build a custom image, run the container, validate the app, pass an environment variable, tag the image, and explain the ECR push flow.

## Required Setup

Instructor machine needs:

```bash
docker --version
docker info
curl --version
```

Optional:

```bash
aws --version
```

Create a working folder:

```bash
mkdir week10-class2-demo
cd week10-class2-demo
```

---

## Step 1: Create the Sample Application

Create `app.py`:

```python
from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def home():
    app_name = os.getenv("APP_NAME", "Docker Demo App")
    app_env = os.getenv("APP_ENV", "local")
    return f"Hello from {app_name}! Environment: {app_env}"

@app.route("/health")
def health():
    return "healthy", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

Create `requirements.txt`:

```text
flask
```

### Explain

- Flask creates a simple web app.
- `/` returns a message.
- `/health` simulates a health endpoint.
- Environment variables customize runtime behavior.
- `host="0.0.0.0"` is important inside containers.

---

## Step 2a: Create the `.dockerignore` (mandatory, not optional)

Before writing the Dockerfile, create a `.dockerignore`. This keeps secrets, VCS metadata, and junk *out* of the build context — and out of any image layer. Treat it as required, not a nice-to-have, because the class repeatedly warns that anything that enters a layer is hard to remove later.

Create `.dockerignore`:

```text
.git
.gitignore
__pycache__/
*.pyc
*.log
.env
.venv/
README.md
Dockerfile
.dockerignore
```

## Step 2b: Create the Dockerfile (hardened, multi-stage)

Create `Dockerfile`:

```dockerfile
# syntax=docker/dockerfile:1

# Stage 1: build dependencies
FROM python:3.13-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: minimal, non-root runtime
FROM python:3.13-slim AS runtime
RUN useradd --create-home --uid 10001 appuser
WORKDIR /app
COPY --from=builder /install /usr/local
COPY app.py .
USER appuser
EXPOSE 5000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:5000/health').status==200 else 1)"
CMD ["python", "app.py"]
```

### Explain Each Instruction

| Instruction | Explanation |
|---|---|
| `# syntax=docker/dockerfile:1` | Opts into the modern BuildKit frontend (cache mounts, build secrets, etc.) |
| `FROM python:3.13-slim AS builder` | Heavy build stage on a current, small base; named `builder` |
| `RUN pip install --prefix=/install ...` | Installs deps into an isolated prefix so only that is copied forward |
| `FROM python:3.13-slim AS runtime` | Fresh, lean runtime stage — build tooling is left behind |
| `RUN useradd ... appuser` | Creates an unprivileged user (uid 10001) |
| `COPY --from=builder /install /usr/local` | Brings in only the installed packages, not the build layers |
| `COPY app.py .` | Application code copied last to preserve dependency-layer caching |
| `USER appuser` | Drops root — baseline hardening, required by most K8s policies |
| `EXPOSE 5000` | Documents app port |
| `HEALTHCHECK` | Runtime liveness probe against `/health`; maps to K8s probes later |
| `CMD` | Starts the app when the container runs |

---

## Step 3: Build the Image (BuildKit)

Modern Docker uses BuildKit by default. The `--platform` flag and `buildx` enable multi-arch builds when needed (e.g. building amd64 images from an Apple Silicon laptop for an amd64 cluster):

```bash
docker build -t docker-demo-app:v1 .
```

Expected output (BuildKit format) includes:

```text
[+] Building 12.3s (14/14) FINISHED
 => => naming to docker.io/library/docker-demo-app:v1
```

### Explain

- `-t docker-demo-app:v1` names and tags the image (an explicit tag, never bare `:latest`).
- `.` means use the current directory as the build context (filtered by `.dockerignore`).
- Docker reads the file named `Dockerfile`.

Validate the image and inspect its layers/size — multi-stage should be noticeably smaller than a single-stage build:

```bash
docker images docker-demo-app
docker history docker-demo-app:v1
```

Expected output:

```text
REPOSITORY        TAG       IMAGE ID       CREATED          SIZE
docker-demo-app   v1        abc123         few seconds ago  ~130MB
```

> Optional multi-arch build (requires `docker buildx`): `docker buildx build --platform linux/amd64,linux/arm64 -t docker-demo-app:v1 .` produces one tag that runs on both architectures.

---

## Step 3b: Scan the Image for Vulnerabilities (gate the build)

A 2026 image author scans every image before it leaves their machine or CI. We use **Trivy**; `docker scout cves docker-demo-app:v1` or ECR scan-on-push are equivalent alternatives.

Run an informational scan first:

```bash
trivy image docker-demo-app:v1
```

### Expected Output (abridged)

```text
docker-demo-app:v1 (debian 12)
Total: 23 (UNKNOWN: 0, LOW: 18, MEDIUM: 4, HIGH: 1, CRITICAL: 0)
```

Now run it as a **gate** — exit non-zero (fail the build/pipeline) on HIGH or CRITICAL:

```bash
trivy image --severity HIGH,CRITICAL --exit-code 1 docker-demo-app:v1
```

### Explain

- A non-zero exit code is what makes this a *gate*: in CI this fails the pipeline so a vulnerable image is never pushed.
- This is exactly why we chose a `slim`/minimal base and a multi-stage build — fewer packages means fewer CVEs to triage. Moving to a distroless base typically drops the count further.
- `docker scout quickview docker-demo-app:v1` gives the same idea using Docker's bundled scanner.

> If Trivy reports a fixable HIGH/CRITICAL, the fix is usually: bump the base image tag (e.g. a newer `python:3.13-slim` patch), rebuild, and re-scan — the evidence-first loop applied to CVEs.

## Step 3c: Generate an SBOM (supply-chain bridge to W19)

A Software Bill of Materials lists everything inside the image. It is increasingly required for compliance and is the input modern scanners and signers consume.

```bash
syft docker-demo-app:v1 -o spdx-json > sbom.spdx.json
```

### Explain

- `syft` enumerates OS packages and Python dependencies into a standard SBOM (SPDX or CycloneDX).
- In Week 19 (DevSecOps) this SBOM is attached to the image and the image is **signed** with `cosign` so consumers can verify provenance:

```bash
# Conceptual — covered fully in W19:
cosign sign <account-id>.dkr.ecr.us-east-1.amazonaws.com/docker-demo-app:v1
```

---

## Step 4: Run the Custom Container

```bash
docker run -d --name docker-demo -p 5000:5000 docker-demo-app:v1
```

Expected output:

```text
<container_id>
```

Validate:

```bash
docker ps
curl http://localhost:5000
curl http://localhost:5000/health
```

Expected outputs:

```text
Hello from Docker Demo App! Environment: local
```

```text
healthy
```

Because the Dockerfile declares a `HEALTHCHECK`, `docker ps` now shows a health state — wait a few seconds and look at the `STATUS` column:

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}'
```

### Expected Output

```text
NAMES         STATUS
docker-demo   Up 15 seconds (healthy)
```

### Explain

This is the same runtime workflow from Class 1, but now the image is custom-built, runs as a non-root user, and reports `(healthy)` because of the `HEALTHCHECK`. That `healthy`/`unhealthy` signal is the local equivalent of a Kubernetes readiness/liveness probe. Confirm the process is non-root:

```bash
docker exec docker-demo id
```

### Expected Output

```text
uid=10001(appuser) gid=10001(appuser) groups=10001(appuser)
```

---

## Step 5: View Logs

```bash
docker logs docker-demo
```

Expected output may include:

```text
* Running on all addresses (0.0.0.0)
```

### Explain

Logs confirm the Flask app started and is listening.

---

## Step 6: Run With Environment Variables

Stop and remove previous container:

```bash
docker rm -f docker-demo
```

Run again:

```bash
docker run -d --name docker-demo -p 5000:5000 \
  -e APP_NAME="Student Demo App" \
  -e APP_ENV="dev" \
  docker-demo-app:v1
```

Windows PowerShell version:

```powershell
docker run -d --name docker-demo -p 5000:5000 `
  -e APP_NAME="Student Demo App" `
  -e APP_ENV="dev" `
  docker-demo-app:v1
```

Validate:

```bash
curl http://localhost:5000
```

Expected output:

```text
Hello from Student Demo App! Environment: dev
```

### Explain

The image did not change. Runtime configuration changed through environment variables.

---

## Step 7: Tag the Image

Docker Hub style:

```bash
docker tag docker-demo-app:v1 your-dockerhub-username/docker-demo-app:v1
```

ECR style:

```bash
docker tag docker-demo-app:v1 <account-id>.dkr.ecr.us-east-1.amazonaws.com/docker-demo-app:v1
```

### Explain

Tags identify where the image should be pushed and what version it represents.

---

## Step 8: Amazon ECR Conceptual Push Flow

Do not require all students to run this unless accounts are ready.

```bash
aws ecr create-repository --repository-name docker-demo-app
```

```bash
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

```bash
docker tag docker-demo-app:v1 <account-id>.dkr.ecr.us-east-1.amazonaws.com/docker-demo-app:v1
```

```bash
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/docker-demo-app:v1
```

### Explain

In enterprise delivery, a CI/CD pipeline usually performs this workflow using an IAM role, not a human user with long-lived credentials.

---

## Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| `docker build` cannot find Dockerfile | Wrong directory or wrong file name | Run `ls` and confirm `Dockerfile` exists |
| Flask import error | Missing `requirements.txt` or failed install | Check Dockerfile and rebuild |
| Container exits immediately | Bad `CMD` or app error | Use `docker ps -a` and `docker logs` |
| Browser cannot reach app | Wrong port mapping or app not listening on `0.0.0.0` | Check `-p` and Flask host |
| Image tag not found | Wrong image name or tag | Run `docker images` |
| ECR login fails | AWS auth or region issue | Check AWS profile, region, IAM permissions |
| Push denied | Missing ECR repository or permission | Create repo and verify IAM access |

---

## Cleanup Steps

```bash
docker rm -f docker-demo 2>/dev/null || true
```

Optional image cleanup:

```bash
docker rmi docker-demo-app:v1
```

Optional folder cleanup:

```bash
cd ..
rm -rf week10-class2-demo
```

Instructor note:

Do not force students to remove images if they will use them for homework or Kubernetes preparation.

---

# 14. Student Lab Manual

## Lab Title

**Build, Run, and Tag Your Own Docker Image**

## Lab Objective

You will create a simple web application, write a Dockerfile, build a Docker image, run the image as a container, validate the application, pass environment variables, and tag the image for a registry workflow.

## Estimated Time

45 minutes

## Student Prerequisites

You should already be able to:

- Run Docker commands
- Explain image vs container
- Use `docker ps`
- Use `docker logs`
- Map ports with `-p`
- Clean up containers

## Starting Point From Class 1

In Class 1, you ran containers from existing images like `nginx`.

In this lab, you will create your own image.

---

## Architecture or Workflow Overview

```text
Local App Files
   |
Dockerfile
   |
docker build
   |
Custom Docker Image
   |
docker run
   |
Running Web Container
   |
curl localhost:5000
```

---

## Step 1: Create a Lab Folder

```bash
mkdir week10-class2-lab
cd week10-class2-lab
```

Expected result:

```text
You are now inside the week10-class2-lab folder.
```

Check location:

```bash
pwd
```

Windows PowerShell:

```powershell
Get-Location
```

---

## Step 2: Create the Application File

Create a file named `app.py`.

```python
from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def home():
    app_name = os.getenv("APP_NAME", "Student Docker App")
    app_env = os.getenv("APP_ENV", "local")
    return f"Hello from {app_name}! Environment: {app_env}"

@app.route("/health")
def health():
    return "healthy", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

Verify:

```bash
ls
```

Expected output includes:

```text
app.py
```

---

## Step 3: Create the Dependency File

Create a file named `requirements.txt`.

```text
flask
```

Verify:

```bash
ls
```

Expected output:

```text
app.py
requirements.txt
```

---

## Step 4a: Create the `.dockerignore` (required)

Create a file named `.dockerignore` so secrets and junk never enter the build context:

```text
.git
.gitignore
__pycache__/
*.pyc
*.log
.env
.venv/
README.md
Dockerfile
.dockerignore
```

## Step 4b: Create the Dockerfile

Create a file named exactly:

```text
Dockerfile
```

Important: no file extension.

Add the hardened, multi-stage Dockerfile (this is the baseline, not an advanced option):

```dockerfile
# syntax=docker/dockerfile:1

# Stage 1: build dependencies
FROM python:3.13-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: minimal, non-root runtime
FROM python:3.13-slim AS runtime
RUN useradd --create-home --uid 10001 appuser
WORKDIR /app
COPY --from=builder /install /usr/local
COPY app.py .
USER appuser
EXPOSE 5000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:5000/health').status==200 else 1)"
CMD ["python", "app.py"]
```

Verify:

```bash
ls -a
```

Expected output:

```text
.dockerignore
Dockerfile
app.py
requirements.txt
```

---

## Step 5: Build the Docker Image

```bash
docker build -t student-docker-app:v1 .
```

Expected output includes:

```text
Successfully tagged student-docker-app:v1
```

Validate:

```bash
docker images student-docker-app
docker history student-docker-app:v1
```

Expected output includes:

```text
student-docker-app   v1
```

---

## Step 5b: Scan the Image (gate on HIGH/CRITICAL)

Scan before you run anything in a real workflow. Informational scan:

```bash
trivy image student-docker-app:v1
```

Now as a gate (non-zero exit fails a pipeline):

```bash
trivy image --severity HIGH,CRITICAL --exit-code 1 student-docker-app:v1
```

If you do not have Trivy installed, the Docker-bundled equivalent is:

```bash
docker scout quickview student-docker-app:v1
```

Reflect: a multi-stage build on a `slim` base should report far fewer findings than a fat single-stage image. If a HIGH/CRITICAL is fixable, bump the base tag and rebuild.

---

## Step 6: Run the Container

```bash
docker run -d --name student-app -p 5000:5000 student-docker-app:v1
```

Validate that it is running:

```bash
docker ps
```

Expected output includes:

```text
student-app
0.0.0.0:5000->5000/tcp
```

---

## Step 7: Test the Application

```bash
curl http://localhost:5000
```

Expected output:

```text
Hello from Student Docker App! Environment: local
```

Test health endpoint:

```bash
curl http://localhost:5000/health
```

Expected output:

```text
healthy
```

Confirm the container's own HEALTHCHECK reports healthy, and that the process is non-root:

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}'
docker exec student-app id
```

Expected output:

```text
NAMES        STATUS
student-app  Up 20 seconds (healthy)
uid=10001(appuser) gid=10001(appuser) groups=10001(appuser)
```

---

## Step 8: View Logs

```bash
docker logs student-app
```

Expected output includes something similar to:

```text
Running on all addresses (0.0.0.0)
```

---

## Step 9: Re-Run With Environment Variables

Remove the existing container:

```bash
docker rm -f student-app
```

Run it again with environment variables:

```bash
docker run -d --name student-app -p 5000:5000 \
  -e APP_NAME="My Containerized App" \
  -e APP_ENV="dev" \
  student-docker-app:v1
```

Windows PowerShell version:

```powershell
docker run -d --name student-app -p 5000:5000 `
  -e APP_NAME="My Containerized App" `
  -e APP_ENV="dev" `
  student-docker-app:v1
```

Validate:

```bash
curl http://localhost:5000
```

Expected output:

```text
Hello from My Containerized App! Environment: dev
```

---

## Step 10: Tag the Image

Local tag example:

```bash
docker tag student-docker-app:v1 student-docker-app:dev
```

Validate:

```bash
docker images
```

Expected output includes:

```text
student-docker-app   v1
student-docker-app   dev
```

Docker Hub tag example:

```bash
docker tag student-docker-app:v1 your-dockerhub-username/student-docker-app:v1
```

Amazon ECR tag pattern:

```bash
docker tag student-docker-app:v1 <account-id>.dkr.ecr.us-east-1.amazonaws.com/student-docker-app:v1
```

Do not run the ECR command unless your instructor provides AWS account details.

---

## Step 11: Optional Docker Hub Push

Only do this if you have a Docker Hub account.

```bash
docker login
docker push your-dockerhub-username/student-docker-app:v1
```

---

## Step 12: Cleanup

Stop and remove the container:

```bash
docker rm -f student-app
```

Verify:

```bash
docker ps -a
```

Optional image cleanup:

```bash
docker rmi student-docker-app:v1 student-docker-app:dev
```

If the image is tagged multiple ways, Docker may ask you to remove all related tags first.

---

## Commands Students Should Run

```bash
mkdir week10-class2-lab
cd week10-class2-lab
ls
docker build -t student-docker-app:v1 .
docker images
docker run -d --name student-app -p 5000:5000 student-docker-app:v1
docker ps
curl http://localhost:5000
curl http://localhost:5000/health
docker logs student-app
docker rm -f student-app
docker run -d --name student-app -p 5000:5000 -e APP_NAME="My Containerized App" -e APP_ENV="dev" student-docker-app:v1
curl http://localhost:5000
docker tag student-docker-app:v1 student-docker-app:dev
docker images
docker rm -f student-app
```

---

## Expected Outputs

| Command | Expected Result |
|---|---|
| `docker build -t student-docker-app:v1 .` | Image builds successfully |
| `docker images` | `student-docker-app` appears |
| `docker ps` | `student-app` appears as running |
| `curl http://localhost:5000` | App greeting appears |
| `curl http://localhost:5000/health` | `healthy` |
| `docker logs student-app` | Flask startup logs appear |
| `docker tag ...` | New tag appears in `docker images` |

---

## Validation Checklist

Students should confirm:

- [ ] Lab folder contains `app.py`, `requirements.txt`, and `Dockerfile`.
- [ ] Docker image builds successfully.
- [ ] Image appears in `docker images`.
- [ ] Container runs successfully.
- [ ] App responds on `localhost:5000`.
- [ ] Health endpoint returns `healthy`.
- [ ] Logs show the app started.
- [ ] Environment variables change the app response.
- [ ] Image is tagged successfully.
- [ ] Container cleanup is complete.

---

## Troubleshooting Tips

| Problem | Likely Cause | Fix |
|---|---|---|
| `failed to read dockerfile` | Not in correct folder or Dockerfile is misspelled | Run `ls` and check file name |
| `ModuleNotFoundError: flask` | Flask not installed or requirements file not copied | Check `requirements.txt` and `RUN pip install` |
| Container exits immediately | App crash or bad `CMD` | Run `docker ps -a` and `docker logs student-app` |
| Browser cannot connect | Wrong port or app not listening on `0.0.0.0` | Check `-p 5000:5000` and Flask app |
| Image not found | Wrong image name or tag | Run `docker images` |
| Port already allocated | Something else uses port 5000 | Use `-p 5050:5000` |
| Environment variable did not change output | Container was not recreated | Remove and rerun container with `-e` |

---

## Reflection Questions

1. What does the Dockerfile do?
2. Which Dockerfile instruction installs dependencies?
3. Which Dockerfile instruction starts the app?
4. Why does the Flask app use `host="0.0.0.0"`?
5. What is the difference between build-time and runtime?
6. Why is tagging important before pushing images to a registry?
7. Why would an enterprise prefer Amazon ECR over a public registry for internal apps?

---

## Optional Challenge Task: Shrink the Attack Surface with Distroless

You already built a multi-stage, non-root image on `python:3.13-slim`. Push it further: swap the runtime stage to a **distroless** base, which has no shell and no package manager, then compare scan results.

Create `Dockerfile.distroless`. Important: the builder's Python minor version must match the distroless runtime's Python (the `gcr.io/distroless/python3-debian12` image ships Python 3.11), so build deps with a 3.11 base and copy them onto a matching path:

```dockerfile
# syntax=docker/dockerfile:1
# Match the distroless runtime's Python minor (3.11) so site-packages line up.
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
# Install into a target dir we control, then copy it to a path on the runtime's sys.path.
RUN pip install --no-cache-dir --target=/packages -r requirements.txt

# Distroless python runtime: no shell, no apt, minimal CVEs, non-root by default.
FROM gcr.io/distroless/python3-debian12:nonroot AS runtime
WORKDIR /app
COPY --from=builder /packages /packages
COPY app.py .
ENV PYTHONPATH=/packages
EXPOSE 5000
# distroless 'nonroot' already runs as a non-root user; ENTRYPOINT is the python interpreter.
CMD ["app.py"]
```

Note: the distroless `python3` image sets `python3` as the `ENTRYPOINT`, so `CMD ["app.py"]` runs `python3 app.py`. Using `--target=/packages` + `PYTHONPATH=/packages` avoids depending on the exact site-packages directory name.

Build, scan, and compare:

```bash
docker build -f Dockerfile.distroless -t student-docker-app:distroless .
docker images student-docker-app
trivy image --severity HIGH,CRITICAL student-docker-app:distroless
```

Reflection:

```text
1. How did the image size and the HIGH/CRITICAL count change versus the slim build?
2. Distroless has no shell — how would you debug it? (Hint: ephemeral debug containers / docker debug.)
3. Why should .env files and secrets never be copied into any image layer?
```

---

# 15. Troubleshooting Activity

## Incident Title

**Custom Container Exits Immediately After Deployment**

## Business Impact

A team is preparing a container image for CI/CD and Kubernetes deployment. The image builds successfully, but when the team runs the container, it exits immediately. This blocks the team from pushing the image to Amazon ECR and deploying it to Kubernetes.

## Symptoms

Students are told:

- `docker build` succeeds.
- `docker run` returns a container ID.
- `docker ps` does not show the container running.
- `docker ps -a` shows the container exited.
- The app is not reachable on `localhost:5000`.

## Starting Evidence

Broken Dockerfile:

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.13-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.13-slim AS runtime
RUN useradd --create-home --uid 10001 appuser
WORKDIR /app
COPY --from=builder /install /usr/local
COPY app.py .
USER appuser
EXPOSE 5000
CMD ["python", "main.py"]
```

Actual file:

```text
app.py
```

Student command:

```bash
docker build -t broken-student-app:v1 .
docker run -d --name broken-app -p 5000:5000 broken-student-app:v1
```

Evidence:

```bash
docker ps
```

Expected result:

```text
No broken-app container is running.
```

```bash
docker ps -a
```

Expected result:

```text
broken-app   Exited
```

```bash
docker logs broken-app
```

Expected error:

```text
python: can't open file '/app/main.py': [Errno 2] No such file or directory
```

## Student Investigation Steps

1. Check running containers.

```bash
docker ps
```

2. Check stopped containers.

```bash
docker ps -a
```

3. Check logs.

```bash
docker logs broken-app
```

4. Inspect the image and command.

```bash
docker inspect broken-app
```

5. Compare Dockerfile `CMD` with actual file names.

```bash
ls
```

6. Fix Dockerfile.

```dockerfile
CMD ["python", "app.py"]
```

7. Rebuild image.

```bash
docker build -t fixed-student-app:v1 .
```

8. Remove broken container.

```bash
docker rm -f broken-app
```

9. Run fixed container.

```bash
docker run -d --name fixed-app -p 5000:5000 fixed-student-app:v1
```

10. Validate.

```bash
curl http://localhost:5000
```

## Expected Root Cause

The Dockerfile uses the wrong startup command:

```dockerfile
CMD ["python", "main.py"]
```

But the application file is named:

```text
app.py
```

## Correct Resolution

Change:

```dockerfile
CMD ["python", "main.py"]
```

To:

```dockerfile
CMD ["python", "app.py"]
```

Then rebuild and rerun.

## Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Reinstall Docker | Docker is working because the image built |
| Change port mapping first | The app is not running, so port mapping is not the first issue |
| Push to registry anyway | A broken image should not be promoted |
| Delete all images randomly | This destroys evidence and slows troubleshooting |
| Ignore logs | Logs clearly show the file name mismatch |

## Instructor Hints

Use these only if students are stuck:

1. “Is the container running or exited?”
2. “What does `docker logs` say?”
3. “Which file does the Dockerfile try to start?”
4. “What files actually exist in the folder?”
5. “After changing the Dockerfile, did you rebuild the image?”

## Preventive Action

In real teams:

- Validate container startup in CI/CD before pushing to ECR.
- Add a health endpoint.
- Run a smoke test after `docker run`.
- Use meaningful image tags.
- Review Dockerfile changes in merge requests.
- Avoid pushing untested images to shared registries.

---

# 16. Scenario-Based Discussion Questions

## Question 1

Your image builds successfully. Does that guarantee your container will run successfully?

**Expected response themes:**

- No.
- Build-time and runtime are different.
- App can fail due to bad `CMD`, missing environment variable, port issue, or runtime error.

**Instructor follow-up:**

```text
What command helps confirm why the container exited?
```

---

## Question 2

Why should production images usually be built by CI/CD instead of manually from a laptop?

**Expected response themes:**

- CI/CD is repeatable.
- Builds are auditable.
- Pipeline can run tests and scans.
- Image tags can map to Git commits.
- Avoids laptop-specific mistakes.

**Instructor follow-up:**

```text
What information should be included in a production image tag?
```

---

## Question 3

Why is using `latest` risky in production?

**Expected response themes:**

- It is not specific.
- It can change over time.
- Rollbacks are harder.
- Incident investigation is harder.

**Instructor follow-up:**

```text
What tag would be better for a production deployment?
```

---

## Question 4

What should not be copied into a Docker image?

**Expected response themes:**

- Secrets
- `.env` files
- SSH keys
- Cloud credentials
- Large unnecessary folders
- Local cache files

**Instructor follow-up:**

```text
How can .dockerignore help?
```

---

## Question 5

Why would an enterprise team use Amazon ECR instead of only Docker Hub?

**Expected response themes:**

- Private images
- IAM integration
- Access control
- Security scanning
- AWS-native integration with EKS and ECS
- Governance and auditability

**Instructor follow-up:**

```text
Who should be allowed to push images to the production repository?
```

---

## Question 6

A developer says, “The image works locally, so it is ready for production.” What else should be checked?

**Expected response themes:**

- Security scan
- Tagging
- Logging
- Health endpoint
- Resource needs
- Environment variables
- Runtime user
- Registry access
- Deployment test

**Instructor follow-up:**

```text
What would an SRE want before approving production readiness?
```

---

## Question 7

How does today’s Dockerfile work prepare students for Kubernetes next week?

**Expected response themes:**

- Kubernetes runs container images.
- Pods pull images from registries.
- Logs and ports still matter.
- Bad image tags cause deployment failures.
- Health checks connect to readiness and liveness probes.

**Instructor follow-up:**

```text
What might happen in Kubernetes if the image tag is wrong?
```

---

# 17. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

What is the purpose of a Dockerfile?

A. To run Kubernetes pods  
B. To define instructions for building a Docker image  
C. To store container logs  
D. To create an AWS account

**Answer:** B  
**Explanation:** A Dockerfile defines the build steps used to create a Docker image.

---

## Question 2: Multiple Choice

Which Dockerfile instruction sets the base image?

A. `CMD`  
B. `COPY`  
C. `FROM`  
D. `EXPOSE`

**Answer:** C  
**Explanation:** `FROM` specifies the starting image, such as `python:3.13-slim`.

---

## Question 3: Multiple Choice

Which instruction runs during image build time?

A. `RUN`  
B. `CMD`  
C. `docker ps`  
D. `docker logs`

**Answer:** A  
**Explanation:** `RUN` executes commands while the image is being built.

---

## Question 4: True or False

`EXPOSE 5000` automatically maps container port `5000` to your laptop.

**Answer:** False  
**Explanation:** `EXPOSE` documents the port. `docker run -p 5000:5000` maps the port.

---

## Question 5: True or False

An image can build successfully but still fail when the container starts.

**Answer:** True  
**Explanation:** Build-time success does not guarantee runtime success.

---

## Question 6: Short Answer

What is the difference between `RUN` and `CMD` in a Dockerfile?

**Answer:** `RUN` executes during image build. `CMD` defines the default command that runs when the container starts.  
**Explanation:** This is the build-time vs runtime distinction.

---

## Question 7: Troubleshooting Multiple Choice

A container exits immediately. Which command should you run to see the error?

A. `docker images`  
B. `docker logs <container-name>`  
C. `docker pull`  
D. `docker tag`

**Answer:** B  
**Explanation:** `docker logs` shows output from the container process.

---

## Question 8: Troubleshooting Short Answer

Your Dockerfile says:

```dockerfile
CMD ["python", "main.py"]
```

But your app file is named `app.py`. What will likely happen?

**Answer:** The container will exit because Python cannot find `main.py`.  
**Explanation:** The startup command points to a file that does not exist.

---

## Question 9: AWS Multiple Choice

Which AWS service stores private container images?

A. Amazon ECR  
B. Amazon EC2  
C. Amazon Route 53  
D. Amazon CloudWatch

**Answer:** A  
**Explanation:** Amazon ECR is AWS’s managed container registry.

---

## Question 10: AWS Short Answer

How does Amazon ECR connect to Kubernetes on AWS?

**Answer:** Images are pushed to ECR, and EKS workloads can pull those images to run containers in Kubernetes pods.  
**Explanation:** ECR acts as the image source for EKS deployments.

---

## Question 11: Class 1 and Class 2 Connection

In Class 1, students used `docker run nginx:1.27`. In Class 2, students use `docker build`. How are these related?

**Answer:** `docker build` creates an image. `docker run` starts a container from an image.  
**Explanation:** Class 2 teaches how images are created before they are run.

---

## Question 12: Class 1 and Class 2 Connection

Why are `docker ps`, `docker logs`, and port mapping still important after building a custom image?

**Answer:** After building an image, students still need to run, validate, and troubleshoot the container.  
**Explanation:** Building and operating containers are connected skills.

---

# 18. Homework Assignment

## Assignment Title

**Create, Build, Run, and Explain a Custom Docker Image**

## Scenario

You are a junior DevOps engineer supporting a team that wants to containerize a small web application before adding it to a CI/CD pipeline. Your lead asks you to create a working Dockerfile, build the image, run the container locally, validate it, and explain each Dockerfile instruction.

## Student Tasks

1. Create a folder named:

```text
week10-docker-homework
```

2. Create a simple application file named `app.py`.

3. Create a `requirements.txt` file.

4. Create a `.dockerignore` (must exclude `.git`, `.env`, `__pycache__`, logs).

5. Create a **multi-stage, hardened** Dockerfile that includes:

- A `builder` stage and a separate `runtime` stage (`FROM ... AS ...` + `COPY --from=builder`)
- A current minimal base (`python:3.13-slim`)
- A non-root `USER`
- A `HEALTHCHECK` against `/health`
- `WORKDIR`, `COPY`, `RUN`, `EXPOSE`, `CMD`

6. Build the image with tag:

```text
homework-docker-app:v1
```

7. **Scan the image and gate on HIGH/CRITICAL:**

```bash
trivy image --severity HIGH,CRITICAL --exit-code 1 homework-docker-app:v1
```

(or `docker scout quickview homework-docker-app:v1`)

8. Run the container on host port `5050`.

9. Validate the app and the health state:

```bash
curl http://localhost:5050
docker ps --format 'table {{.Names}}\t{{.Status}}'   # should show (healthy)
docker exec <container> id                             # should NOT be uid 0/root
```

10. Run the container with at least one environment variable.

11. Capture output from:

```bash
docker build
docker images
docker history homework-docker-app:v1
docker ps
docker logs
curl
trivy image homework-docker-app:v1
```

12. Tag the image as:

```text
homework-docker-app:dev
```

13. Write a short explanation of each Dockerfile instruction, including why the build is multi-stage and why the container runs as non-root.

14. Explain how this image could later be pushed to Amazon ECR, and what an SBOM (syft) and image signing (cosign) add in W19.

15. Clean up the container.

## Expected Deliverables

Students submit:

1. `app.py`
2. `requirements.txt`
3. `Dockerfile`
4. Command outputs or screenshots
5. Written explanation of each Dockerfile instruction
6. Short paragraph explaining Dockerfile to ECR to Kubernetes flow
7. Cleanup confirmation

## Submission Format

Preferred:

```text
Git repository or zipped folder with README.md
```

README should include:

```text
# Week 10 Docker Homework
## Build Command
## Run Command
## Validation Output
## Dockerfile Explanation
## Troubleshooting Notes
## Cleanup Steps
```

## Estimated Completion Time

60 to 90 minutes

## Grading Criteria

| Criteria | Points |
|---|---:|
| App files + `.dockerignore` created correctly | 10 |
| Multi-stage Dockerfile (builder + runtime) works | 15 |
| Non-root `USER` + `HEALTHCHECK` present and verified | 15 |
| Image builds and scan gate runs (Trivy/scout) | 15 |
| Container runs and reports `(healthy)` | 10 |
| App + env-var validation works | 10 |
| Dockerfile explanation accurate (incl. why multi-stage / non-root) | 10 |
| ECR + SBOM/signing explanation accurate | 10 |
| Cleanup completed | 5 |
| Total | 100 |

## Optional Advanced Challenge

Swap the runtime stage to a **distroless** base (e.g. `gcr.io/distroless/python3-debian12:nonroot`), rebuild, re-scan, and report how the image size and HIGH/CRITICAL CVE count changed versus the `slim` build.

For reference, your mandatory `.dockerignore` should look like:

```text
.git
__pycache__
*.log
.env
node_modules
README.md
```

Advanced reflection:

```text
Why should secrets never be copied into Docker images?
```

---

# 19. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Naming the file `Dockerfile.txt` | Windows may hide file extensions | Ensure file is exactly named `Dockerfile` |
| Running `docker build` from wrong folder | Students are not in the app directory | Run `pwd` or `ls` before build |
| Forgetting the final `.` in `docker build` | Students do not understand build context | Explain `.` means current folder |
| Missing `requirements.txt` | File not created or misspelled | Confirm with `ls` |
| Using `CMD ["python", "main.py"]` when file is `app.py` | Copy/paste mismatch | Match `CMD` to actual file |
| App listens on `127.0.0.1` | Common Flask default confusion | Use `host="0.0.0.0"` |
| Confusing `EXPOSE` with port publishing | Misunderstanding Dockerfile vs runtime | Use `-p host:container` |
| Using wrong image tag in `docker run` | Tag mismatch | Check `docker images` |
| Not rebuilding after Dockerfile change | Students edit file but run old image | Re-run `docker build` |
| Pushing untested images | Students skip validation | Always run local smoke test first |
| Putting secrets into image files | Lack of security awareness | Use fake values and `.dockerignore` |

---

# 20. Real-World Enterprise Scenario

## Scenario

A retail company is moving from manual server deployments to containerized deployments. The application team has a Python web service that currently runs directly on an EC2 instance. The DevOps team wants to package it as a Docker image so it can later be deployed through CI/CD to Amazon EKS.

## Constraints

| Constraint | Example |
|---|---|
| Access control | Only CI/CD can push production images to ECR |
| Security | No secrets can be included in the image |
| Reliability | Image must pass a smoke test before promotion |
| Cost | Local testing should happen before cloud deployment |
| Traceability | Image tags must map to Git commits |
| Approvals | Production promotion requires review |
| Observability | App must provide logs and a health endpoint |
| Rollback | Previous image tags must remain available |

## How Class 2 Applies

This class teaches the first packaging step:

```text
Application Code
   |
Multi-stage Dockerfile (non-root, HEALTHCHECK)
   |
Docker Image (BuildKit)
   |
Vulnerability Scan (Trivy gate) + SBOM (syft)
   |
Local Container Test
   |
Registry Tag (+ digest pin)
   |
Amazon ECR
   |
EKS Deployment
```

## Role-Based Responsibilities

### DevOps Engineer

- Writes or reviews Dockerfile
- Builds CI/CD pipeline for image build and push
- Tags images with version or commit SHA
- Adds scanning before image promotion

### Cloud Engineer

- Creates ECR repository
- Defines IAM access for push and pull
- Supports networking and registry access patterns
- Ensures EKS or ECS can pull images securely

### SRE

- Reviews runtime behavior
- Validates health endpoint
- Ensures logs are useful
- Helps define rollback process
- Investigates incidents tied to bad image versions

---

# 21. Instructor Tips

## Teaching Tips

- Keep the focus on Dockerfile fundamentals, but teach the multi-stage / non-root / HEALTHCHECK baseline as the *normal* way to write a Dockerfile in 2026 — it is not advanced, it is expected.
- Show the naive single-stage version first only to motivate why we harden it, then move to the multi-stage baseline.
- Repeatedly connect build-time and runtime.
- Show that build success does not equal app success.
- Use errors as teaching moments.
- Explain every Dockerfile line slowly.

## Pacing Tips

- Do not let the review exceed 15 minutes.
- Keep the demo under 30 minutes.
- Preserve at least 40 minutes for student build time.
- Use the troubleshooting exercise even if some students are still finishing the lab.
- Keep registry discussion conceptual if AWS accounts are not ready.

## Lab Support Tips

When a student is stuck, ask:

1. What folder are you in?
2. What files are present?
3. What command did you run?
4. Did the build fail or the container fail?
5. What does `docker logs` show?
6. What does `docker images` show?

## Helping Struggling Students

Use these simplified anchors:

```text
Dockerfile creates image.
Image creates container.
Container runs app.
Logs explain failures.
```

Give struggling students a working Dockerfile and ask them to explain each line.

## Challenging Advanced Students

Ask advanced students to:

- Swap the runtime stage to a **distroless** base and compare scan results
- Build a **multi-arch** image with `docker buildx build --platform linux/amd64,linux/arm64`
- Add a BuildKit **cache mount** for pip (`RUN --mount=type=cache,target=/root/.cache/pip ...`)
- Pin the base image **by digest** instead of tag
- Generate an SBOM with `syft` and diff it across two builds
- Tag the image with a fake Git SHA
- Write a short CI/CD stage that builds, scans (Trivy gate), and pushes to ECR

Example advanced tag:

```bash
docker tag student-docker-app:v1 student-docker-app:git-abc123
```

---

# 22. Student Outcome Checklist

## Students Should Be Able to Explain

- [ ] What a Dockerfile does
- [ ] What a base image is
- [ ] What build context means
- [ ] What image layers are at a beginner level
- [ ] Difference between `RUN` and `CMD`
- [ ] Difference between build-time and runtime
- [ ] Difference between `EXPOSE` and `-p`
- [ ] Why a multi-stage build produces a smaller, safer image
- [ ] Why containers should run as a non-root `USER`
- [ ] What a `HEALTHCHECK` does and how it maps to K8s probes
- [ ] Why image tags matter, and why digest pinning is stronger
- [ ] What image scanning / an SBOM / image signing are for
- [ ] What a registry does
- [ ] What Amazon ECR is used for

## Students Should Be Able to Build or Configure

- [ ] Create a simple app file
- [ ] Create a `requirements.txt` file
- [ ] Create a mandatory `.dockerignore`
- [ ] Write a multi-stage, non-root Dockerfile with a `HEALTHCHECK`
- [ ] Build a Docker image (BuildKit)
- [ ] Scan the image and gate on HIGH/CRITICAL (Trivy or docker scout)
- [ ] Run a custom container and confirm it reports `(healthy)` as non-root
- [ ] Pass environment variables
- [ ] Validate app response with `curl`
- [ ] Tag an image (and find its digest)
- [ ] Explain conceptual ECR push flow

## Students Should Be Able to Troubleshoot

- [ ] Dockerfile not found
- [ ] Build context issues
- [ ] Missing dependency file
- [ ] Bad `CMD`
- [ ] Container exits immediately
- [ ] Wrong port mapping
- [ ] App not listening on `0.0.0.0`
- [ ] Image tag mismatch
- [ ] Registry login or push concept issues

---

# 23. Class Completion Checklist

## Instructor Checklist Before Ending Class

- [ ] Students reviewed Class 1 concepts.
- [ ] Students understand Dockerfile purpose.
- [ ] Students saw a multi-stage, non-root image build with a HEALTHCHECK.
- [ ] Students ran a custom app container and saw it report `(healthy)`.
- [ ] Students scanned an image and saw the HIGH/CRITICAL gate.
- [ ] Students used environment variables.
- [ ] Students understand image tagging and digest pinning.
- [ ] Students understand registry purpose.
- [ ] Amazon ECR was introduced as AWS registry.
- [ ] Students completed or started troubleshooting exercise.
- [ ] Homework has been explained.
- [ ] Students understand how this prepares them for Kubernetes.

## Student Checklist Before Leaving Class

- [ ] I created `app.py`.
- [ ] I created `requirements.txt`.
- [ ] I created a `.dockerignore`.
- [ ] I wrote a multi-stage, non-root Dockerfile with a HEALTHCHECK.
- [ ] I built a custom image.
- [ ] I scanned the image (Trivy or docker scout).
- [ ] I ran a container from my image and confirmed it was healthy and non-root.
- [ ] I tested the app with `curl` or browser.
- [ ] I checked container logs.
- [ ] I passed an environment variable.
- [ ] I tagged an image.
- [ ] I cleaned up my running container.

## Items to Verify Before Closing the Week

Students should be able to:

- Explain Docker runtime basics from Class 1
- Explain Docker image build basics from Class 2
- Build and run a custom container locally
- Troubleshoot failed containers using logs
- Understand why images are pushed to registries
- Understand how Docker prepares them for Kubernetes

---

# 24. End-of-Week Summary

## What Students Learned This Week

In Week 10, students learned how Docker supports modern DevOps, Cloud Engineering, and SRE workflows.

They learned how to:

- Explain containers vs virtual machines
- Pull and run existing images (with pinned tags, not bare `:latest`)
- Inspect containers, run multi-service stacks with Docker Compose
- View logs
- Map ports and understand image architecture (`--platform`, amd64 vs arm64)
- Pass environment variables
- Write a hardened, multi-stage Dockerfile (minimal base, non-root `USER`, `HEALTHCHECK`)
- Build a custom image with BuildKit
- Scan an image for CVEs and gate on HIGH/CRITICAL (Trivy / docker scout)
- Generate an SBOM (syft) and understand image signing (cosign)
- Run a custom application container
- Tag and pin an image (version tag and immutable digest)
- Understand container registries
- Explain Amazon ECR at a beginner level
- Troubleshoot common Docker issues using evidence-first methodology

## How Class 1 and Class 2 Connect

Class 1 focused on operating containers:

```text
Pull image -> Run container -> Inspect logs -> Troubleshoot runtime
```

Class 2 focused on creating images:

```text
Write app -> Write Dockerfile -> Build image -> Run container -> Tag image -> Prepare for registry
```

Together, students now understand both sides of Docker:

```text
Build the image and run the container
```

## How This Week Prepares Students for the Next Week

Week 11 introduces Kubernetes Fundamentals.

Kubernetes does not build applications by itself. It runs containers from images.

Students will use Week 10 knowledge to understand:

- Why Kubernetes needs an image
- Why image tags matter
- Why container ports matter
- Why logs are important
- Why health endpoints matter
- Why registries like ECR matter
- Why a bad Dockerfile can break Kubernetes deployments

## What Students Should Review Before the Next Module

Students should review:

1. Image vs container
2. Dockerfile instructions
3. `docker build`
4. `docker run`
5. Port mapping
6. `docker logs`
7. `docker ps -a`
8. Environment variables
9. Image tags
10. Registry concepts
11. Amazon ECR overview
12. Basic troubleshooting flow

Recommended review commands:

```bash
docker images
docker ps -a
docker build -t review-app:v1 .
docker run -d --name review-app -p 5000:5000 review-app:v1
docker logs review-app
docker rm -f review-app
```

By the end of Week 10, students are ready to begin **Week 11: Kubernetes Fundamentals**, where they will deploy containerized applications into Kubernetes workloads.

---

# 25. Class Artifacts & Validation

This class builds and hardens **custom images**: a multi-stage Dockerfile on a
slim base, a non-root `USER`, a stdlib `HEALTHCHECK`, a mandatory
`.dockerignore`, then **scans** the image (grype/Trivy) and produces an **SBOM**
(syft). The reference artifacts live in
[`labs/docker-containers/`](../../labs/docker-containers/). The lecture's Flask
app maps to `solution/Dockerfile.flask` (installs Flask + gunicorn from PyPI so
the CVE-scan/SBOM steps run against a real third-party dependency tree); the
`solution/Dockerfile` stdlib variant is the offline default. Every path below
resolves; commands were run against a real Docker daemon here — the full gate
set (`labs/docker-containers/validate.sh`) reports **16 passed, 0 failed, 0
deferred**.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/docker-containers/solution/Dockerfile.flask | docker | **W10 lecture variant** — multi-stage build that installs Flask + gunicorn from PyPI into an isolated prefix, copies only that into a slim non-root runtime, stdlib HEALTHCHECK, EXPOSE, gunicorn as PID 1 | `hadolint solution/Dockerfile.flask` and `docker build -f solution/Dockerfile.flask -t dc-flask .` | PASS — hadolint: no findings; builds; **45 MB < 80 MB** |
| 2 | labs/docker-containers/solution/app-flask/app.py | python | The lecture Flask app: `GET /` and `GET /health`; the dependency tree the scan/SBOM cover | `python3 -m py_compile solution/app-flask/app.py solution/app-flask/healthcheck.py` | PASS |
| 3 | labs/docker-containers/solution/app-flask/requirements.txt | requirements | Pinned Flask + gunicorn — the third-party tree grype/syft inventory | scanned via the grype/syft gates below (dependency tree adds 0 HIGH/CRITICAL) | PASS |
| 4 | labs/docker-containers/solution/Dockerfile | docker | Stdlib (offline-default) multi-stage image: slim base, non-root UID 10001, stdlib HEALTHCHECK, EXPOSE, no build tooling in runtime | `hadolint solution/Dockerfile` and `docker build -f solution/Dockerfile -t dc-test .` then `docker image inspect dc-test --format '{{.Size}}'` | PASS — hadolint: no findings; builds; **43 MB < 60 MB** |
| 5 | labs/docker-containers/.dockerignore | dockerignore | Keeps secrets/VCS/docs out of the build context and image layers (the mandatory `.dockerignore` taught in §10/§13) | build-context filter exercised by the `docker build` gates above | PASS |
| 6 | (built image `dc-test:validate`) ← labs/docker-containers/solution/Dockerfile | grype scan | CVE scan that fails on CRITICAL; HIGH reported (all in the `python:3.12-slim` base, Debian `won't fix`) — the base-image-CVE teaching point | `grype dc-test:validate` | PASS — **0 CRITICAL, 7 HIGH** (base image) |
| 7 | (built image `dc-flask:validate`) ← labs/docker-containers/solution/Dockerfile.flask | grype scan | CVE scan of the Flask image; Flask/Werkzeug/gunicorn/Jinja2 add **0** HIGH/CRITICAL on top of the base | `grype dc-flask:validate` | PASS — **0 CRITICAL, 7 HIGH** (base image; deps add 0) |
| 8 | labs/docker-containers/solution/sbom.spdx.json (generated) | sbom | Real SPDX-2.3 SBOM of the built image (96 packages); regenerated by `validate.sh`/`syft` on each run (gitignored generated artifact, not a committed source file) | `syft dc-test:validate -o spdx-json > solution/sbom.spdx.json` | PASS — SPDX-2.3, 96 packages |
| 9 | labs/docker-containers/broken/Dockerfile | docker (fixture) | The §15 broken-startup teaching pattern's sibling fixture: builds fine but the container stays `unhealthy` (curl HEALTHCHECK on a curl-less slim base) | `docker build -f broken/Dockerfile -t dc-broken .` then `docker inspect --format '{{.State.Health.Status}}' dc-broken` | PASS — builds; reports `unhealthy` by design (README → Troubleshooting) |
| 10 | labs/docker-containers/validate.sh | shell | Full gate runner (compile, unittest, YAML, compose config, hadolint, build+size, grype, syft, Flask build+scan); `command -v`-guards each tool and `DEFER`s where absent | `bash -n validate.sh` and `./validate.sh` | PASS (16/16 with daemon + hadolint/grype/syft present) |

> **Honest scope of evidence:** all of the above runs **locally in Docker at $0**
> — real `docker build`/`docker run`, real `grype`/`syft` scans — but there is
> **no live cloud (ECR push), no committed `LIVE-*EVIDENCE*.txt`, and no committed
> SBOM** (it is gitignored and regenerated). The ECR push, `cosign` signing, and
> `docker scout` are taught conceptually (§10/§13), not executed. The image is
> built and operated here but **not yet reused/operated inside a later week or
> the capstone** within this repo, so this is a fully *Practiced* (starter +
> solution + validated + answer key), not yet *Mastered*, artifact.

# 26. Definition of Done

Ticked honestly for **Week 10 Class 02** (Dockerfiles, image hardening, scanning,
SBOM, registries). The backing lab is
[`labs/docker-containers/`](../../labs/docker-containers/).

- [x] Every technology taught ships at least one **runnable file on disk** (not just a fence). — Two real Dockerfiles (`solution/Dockerfile`, `solution/Dockerfile.flask`), the Flask app, `.dockerignore`, and the broken fixture are all on disk.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured. — hadolint (clean), `docker build` (both images), size budgets, grype (0 CRITICAL), syft (SPDX SBOM) all PASS; full `validate.sh` = 16/16.
- [x] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions. — `starter/Dockerfile` + `starter/compose.yaml` (TODO gaps) and `solution/` reference both exist.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes**. — All present in `labs/docker-containers/README.md` (incl. the "Image scanning & SBOM" section).
- [x] **Cleanup/teardown** is provided and idempotent. — README "Cleanup": `down -v` + idempotent `docker rm -f`/`image rm ... || true` + `image prune -f`.
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise. — Quiz/homework keys in this file (§17–18); lab + grading notes in `README.md` → "Instructor answer key"; broken-Dockerfile resolution in §15 and README → "Troubleshooting".
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state*. — `broken/Dockerfile` reproducibly reports `unhealthy`; §15's broken-`CMD` (`main.py` vs `app.py`) is a concrete, reproducible fault with the exact log shown.
- [x] **Expected outputs** are shown for demos and labs. — §13–14 show exact build/run/scan outputs; README "Expected results" shows sizes (43/45 MB), `uid=10001`, `healthy`, and the grype CVE table.
- [x] **Cost & security warnings** present. — README "Cost considerations" ($0 local) and "Security considerations" (non-root, no curl, no secrets in layers, scan gate); §7/§10 cover ECR cost and secrets-in-image.
- [x] **Cross-references** to the module repo and to prior/next weeks are correct. — Links to `labs/docker-containers/`; forward to W11–12 (K8s probes), W19 (DevSecOps SBOM/signing), W23–24 (capstone), verified.
- [x] The **artifact manifest** (§4.2) is present and every path resolves. — §25 above; every committed path is `ls`-verified (row 8 is an explicitly-marked *generated* SBOM).
- [ ] **Mastered / capstone-operated** — images are built, scanned, and run here, but **not yet consumed by a downstream week or the capstone** within this repo, and there is no committed live-cloud (ECR/cosign) evidence. The README forecasts that reuse; it is not yet wired, so this box stays unticked and the score is capped at the *Practiced* tier.
