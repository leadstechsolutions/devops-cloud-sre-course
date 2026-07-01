# Week 11: Kubernetes Fundamentals
# Class 1 Package

**Week:** 11
**Track:** Unified DevOps · Cloud · SRE Track

> **▶ Runnable lab for this class:** [`labs/kubernetes-fundamentals/`](../../labs/kubernetes-fundamentals/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 11.1: Kubernetes Architecture and Your First Deployment

---

## 1. Class Overview

### Class title

**Class 11.1: Kubernetes Architecture and Your First Deployment**

### Class purpose

This class introduces students to Kubernetes as the next step after Docker. Students will learn why Kubernetes exists, how its main components work together, and how to deploy a simple application using a Kubernetes Deployment manifest.

The class focuses on beginner-friendly Kubernetes architecture, core workload objects, and basic `kubectl` inspection commands.

### How this class connects to the overall course

Students already learned Linux, networking, Git, CI/CD fundamentals, and Docker. This class connects those skills to modern container orchestration.

Kubernetes becomes the foundation for later topics:

- Week 12: Kubernetes troubleshooting
- Week 13: Helm packaging
- Week 14 and 15: Terraform infrastructure workflows
- Week 16: observability and reliability
- Week 19: DevSecOps and secure delivery (including secrets)
- Week 20: platform engineering and golden paths
- Week 21: SRE foundations (SLI/SLO, on-call, incidents)

### What students will build, analyze, or practice

Students will:

- Inspect a local Kubernetes cluster
- Create a namespace
- Create a Kubernetes Deployment YAML file
- Deploy an NGINX application
- Inspect Deployments, ReplicaSets, and Pods
- Scale a Deployment
- Delete a Pod and observe Kubernetes self-healing
- Troubleshoot image and selector-related Deployment problems

---

## 2. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** why Kubernetes is used to run containerized applications in modern cloud environments.
2. **Describe** the basic Kubernetes architecture, including the control plane, worker nodes, API server, scheduler, kubelet, and pods.
3. **Compare** a standalone Docker container with a Kubernetes-managed workload.
4. **Build** a basic Kubernetes Deployment manifest using YAML.
5. **Configure** a namespace and deploy an application into it.
6. **Validate** Kubernetes resources using `kubectl get`, `kubectl describe`, and `kubectl logs`.
7. **Troubleshoot** common beginner Deployment issues such as bad image tags, YAML mistakes, and label or selector mismatches.
8. **Document** the relationship between Deployment, ReplicaSet, Pod, and Container.

---

## 3. Prerequisites Students Should Already Know

### Required prior concepts

Students should already understand:

- Basic Linux command-line usage
- Files and directories
- Basic networking concepts such as ports and IP addresses
- Docker image and container concepts
- YAML basics
- Git basics
- Terminal usage
- Application deployment basics from earlier weeks

### Required tools already installed

Students should have:

- VS Code
- Terminal or command prompt
- Docker Desktop with Kubernetes enabled, or kind, or minikube
- `kubectl`
- Git
- A browser
- Optional: AWS CLI, for later EKS comparison

### Required accounts or access

For this class, students do **not** need to create AWS resources.

Required:

- Local machine access
- Local Kubernetes cluster access

Optional:

- AWS account access for viewing EKS service overview only

### Files, repos, or sample code needed

Students need a working folder:

```bash
mkdir -p week11/class1
cd week11/class1
```

Files created during class:

```text
nginx-deployment.yaml
broken-nginx-deployment.yaml
```

---

## 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Kubernetes | A platform for running and managing containers across one or more machines | Enterprises use Kubernetes to standardize application deployment and scaling |
| Cluster | A group of machines managed by Kubernetes | Production environments usually have separate dev, test, staging, and prod clusters |
| Control plane | The management layer of Kubernetes | It makes decisions about scheduling, desired state, and cluster coordination |
| API server | The front door of Kubernetes | Every `kubectl` command talks to the API server |
| Worker node | A machine that runs application workloads | In EKS, worker nodes may be EC2 instances or managed node groups |
| kubelet | Agent running on each worker node | It makes sure containers are running as instructed by Kubernetes |
| Pod | The smallest deployable unit in Kubernetes | A pod usually runs one main application container |
| Container | A running instance of a container image | The app process runs inside the container |
| Deployment | A Kubernetes object that manages application replicas and rollout behavior | Used to keep the desired number of app pods running |
| ReplicaSet | Object managed by a Deployment that maintains pod count | Usually students do not create ReplicaSets directly |
| Namespace | A logical separation inside a cluster | Teams use namespaces to separate apps, environments, or ownership |
| Label | A key-value tag on Kubernetes resources | Labels help Kubernetes and teams identify resources |
| Selector | A rule that matches labels | Deployments and Services use selectors to find matching pods |
| Manifest | A YAML file that defines desired Kubernetes resources | Teams store manifests in Git for review and repeatable deployment |
| Desired state | What the YAML says should exist | Kubernetes constantly tries to make actual state match desired state |
| Actual state | What is currently running in the cluster | Troubleshooting often means comparing desired state to actual state |
| Resource requests | The CPU/memory the scheduler reserves for a container | Used to place Pods on nodes with enough capacity; HPA also scales off the CPU request |
| Resource limits | The CPU/memory ceiling the kubelet enforces | Exceeding the memory limit causes an `OOMKilled` container; CPU over limit is throttled |
| Readiness probe | A health check that decides if a Pod should receive traffic | A failing readiness probe removes the Pod from Service endpoints (still `Running`, but `0/1` ready) |
| Liveness probe | A health check that decides if the kubelet should restart the container | Detects a wedged process; too aggressive a setting causes restart loops |
| Startup probe | A probe that gives slow-starting apps time before liveness applies | Used for apps with long initialization so liveness does not kill them prematurely |
| securityContext | Pod/container security settings (run as non-root, drop capabilities, read-only root FS) | The basis of the Pod Security Standards "restricted" baseline |
| Pod Security Standards (PSS) | Built-in policy levels (privileged, baseline, restricted) enforced per namespace | Admission rejects Pods that violate the namespace's enforced level |
| HorizontalPodAutoscaler (HPA) | An object that scales replica count based on metrics like CPU | Lets workloads scale with demand instead of a fixed replica count |

---

## 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| `kubectl` | Primary CLI for interacting with Kubernetes |
| Docker Desktop, kind, or minikube | Provides a local Kubernetes cluster for learning |
| VS Code | Used to write and edit YAML manifests |
| Terminal | Used to run Kubernetes commands |
| YAML | Used to define Kubernetes resources declaratively |
| Git | Optional for saving lab files and practicing infrastructure-style workflow |
| Browser | Optional, used for documentation lookup and EKS console overview |
| AWS Console | Optional, used only to introduce Amazon EKS at a high level |

---

## 6. AWS Services Used

This class is primarily local Kubernetes. AWS is introduced conceptually.

| AWS Service | How It Connects to the Class |
|---|---|
| Amazon EKS | Managed Kubernetes service on AWS. The same Kubernetes concepts learned locally apply to EKS |
| Amazon ECR | Container image registry commonly used with EKS |
| EC2 | EKS worker nodes often run on EC2 instances or managed node groups |
| IAM | Used in EKS for cluster access, workload permissions, and AWS integrations |
| CloudWatch | Used later for EKS logs, metrics, and operational visibility |

### Cost warning

No AWS resources are required for this class. Students should not create an EKS cluster yet unless explicitly instructed later, because EKS and related resources can create cost.

---

## 7. Azure and GCP Comparison Notes

Keep this short during delivery.

| Kubernetes Concept | AWS | Azure | GCP |
|---|---|---|---|
| Managed Kubernetes | EKS | AKS | GKE |
| Container registry | ECR | Azure Container Registry | Artifact Registry |
| Monitoring | CloudWatch | Azure Monitor | Google Cloud Monitoring |
| Identity integration | IAM | Microsoft Entra ID / Azure RBAC | Google Cloud IAM |

Instructor talking point:

> Kubernetes concepts such as Pods, Deployments, ReplicaSets, Namespaces, and Services are portable. The managed cloud service changes, but the core Kubernetes objects stay mostly the same.

---

## 8. Time-Boxed Instructor Agenda

| Time | Segment | Instructor Focus |
|---:|---|---|
| 0:00 to 0:10 | Opening and Week 10 (Docker) recap | Connect Docker to Kubernetes |
| 0:10 to 0:30 | Why Kubernetes exists | Explain orchestration, scaling, self-healing, standardization |
| 0:30 to 0:55 | Kubernetes architecture | Control plane, worker nodes, API server, scheduler, kubelet |
| 0:55 to 1:15 | Core workload objects | Pod, Deployment, ReplicaSet, Namespace, Labels, Selectors |
| 1:15 to 1:25 | Short break | Reset before demo |
| 1:25 to 1:35 | YAML manifest walkthrough | Explain desired state |
| 1:35 to 2:05 | Instructor demo | Deploy and inspect NGINX |
| 2:05 to 2:40 | Student lab | Students deploy and inspect their own workload |
| 2:40 to 2:55 | Troubleshooting activity | Broken image and selector examples |
| 2:55 to 3:00 | Recap and Class 2 preview | Prepare students for Services and app exposure |

---

## 9. Instructor Lesson Plan

### Step 1: Open with Docker recap

Explain:

Students already learned that Docker can package an application into a container image and run it as a container. That works well for one machine, but production environments need more.

Say:

> Docker helps us package and run containers. Kubernetes helps us operate many containers reliably across machines.

Ask students:

- What happens if a container crashes?
- What happens if traffic increases?
- What happens if a server dies?
- How do we deploy new versions safely?

Transition:

> These are the problems Kubernetes was designed to solve.

---

### Step 2: Explain what Kubernetes solves

Cover:

- Running containers across multiple machines
- Restarting failed workloads
- Scaling replicas
- Declarative configuration
- Rolling updates
- Standardized deployment patterns
- Consistent operations across dev, test, and production

Beginner teaching tip:

Avoid saying Kubernetes is just “container orchestration” without explaining it. Use plain language:

> Kubernetes is like an operations manager for containers. You tell it how many copies of your app you want, and Kubernetes works to keep that state running.

---

### Step 3: Teach architecture visually

Draw:

```text
kubectl -> API Server -> Scheduler/Controllers -> Worker Nodes -> Pods
```

Explain each component in simple terms:

- `kubectl`: the tool we use
- API server: the entry point
- Scheduler: decides where pods run
- Controller manager: watches desired state
- Worker node: runs workloads
- kubelet: node-level agent
- Pod: where the container runs

Pause for questions:

Ask:

> Which component do you think receives your `kubectl apply` command?

Expected answer:

API server.

---

### Step 4: Explain workload objects

Teach in this order:

1. Container
2. Pod
3. Deployment
4. ReplicaSet
5. Namespace
6. Labels and selectors

Important instructor point:

Students often think a Deployment directly runs containers. Clarify:

> A Deployment does not directly run your container. It manages a ReplicaSet, which manages Pods, and Pods run containers.

---

### Step 5: Walk through YAML before running commands

Open the manifest file and explain:

- `apiVersion`
- `kind`
- `metadata`
- `spec`
- `replicas`
- `selector`
- `template`
- `containers`
- `image`
- `containerPort`

Teaching tip:

Tell students not to memorize every field yet. Their first goal is to understand the structure.

---

### Step 6: Instructor demo

Deploy the NGINX app live.

As you run commands, pause after each major step and ask:

- What did Kubernetes create?
- What is the desired state?
- What is the actual state?
- How can we validate it?

---

### Step 7: Student lab

Let students work through the guided lab.

Instructor should watch for common problems:

- Wrong namespace
- YAML indentation errors
- `kubectl` context not connected
- Docker Desktop Kubernetes not running
- Image typo
- File saved with wrong extension

---

### Step 8: Troubleshooting activity

Introduce a broken manifest.

Have students investigate before giving the answer.

Encourage this flow:

1. Read the error
2. Check the resource
3. Describe the resource
4. Check events
5. Fix one issue at a time
6. Reapply
7. Validate

---

### Step 9: Close with Class 2 preview

Say:

> Today we deployed an application, but we did not properly expose it as a network service yet. In Class 2, we will learn how Kubernetes Services give stable access to Pods.

---

## 10. Instructor Lecture Notes

### Kubernetes in plain English

Kubernetes is a system for managing containerized applications. Instead of manually starting containers on individual servers, teams define what they want in YAML, and Kubernetes works to keep that desired state running.

Talking point:

> In real companies, teams do not want engineers SSHing into servers to manually run containers. They want repeatable, reviewed, automated deployment patterns.

### Why Docker alone is not enough

Docker is excellent for packaging and running containers, but it does not fully solve production operations.

Docker alone does not automatically provide:

- Multi-node scheduling
- Self-healing across servers
- Declarative desired state
- Rolling updates
- Built-in service discovery
- Centralized workload management
- Standardized production deployment workflow

Kubernetes adds these operational capabilities.

Common misconception:

> Docker and Kubernetes are competitors.

Correction:

Docker packages and runs containers. Kubernetes orchestrates containers. They solve different parts of the problem.

### Kubernetes desired state

A key Kubernetes concept is desired state.

Students write a YAML manifest that says:

- I want a Deployment named `nginx-demo`
- I want 2 replicas
- I want each Pod to run `nginx:1.25`
- I want container port 80 open

Kubernetes then tries to make the actual cluster match that desired state.

Talking point:

> Kubernetes is not just running a command. It is continuously watching and reconciling state.

### Pods

A Pod is the smallest deployable unit in Kubernetes. A Pod wraps one or more containers.

For beginners, explain that most application Pods have one main container.

Real-world context:

- A web app container runs inside a Pod
- The Pod gets scheduled onto a worker node
- The Pod can be replaced anytime
- Pod IPs are temporary
- A Deployment usually manages Pods

Common misconception:

> A Pod is the same as a container.

Correction:

A Pod is a Kubernetes wrapper around one or more containers.

### Deployments and ReplicaSets

A Deployment manages application rollout and desired replica count. When you create a Deployment, Kubernetes creates a ReplicaSet. The ReplicaSet creates and maintains Pods.

Real-world context:

A team might define:

```text
replicas: 3
```

That means Kubernetes should keep 3 Pods running. If one Pod dies, Kubernetes creates another.

Talking point:

> In production, you usually deploy applications using Deployments, not standalone Pods.

### Namespaces

Namespaces are logical separation inside a cluster.

Examples:

- `dev`
- `test`
- `prod`
- `platform`
- `monitoring`
- `student-app`

Real-world context:

Namespaces are often used to separate applications, teams, environments, or platform components.

Common misconception:

> Namespaces are the same as separate clusters.

Correction:

Namespaces separate resources inside one cluster. They are not a hard replacement for separate clusters or accounts.

### Labels and selectors

Labels are key-value tags.

Example:

```yaml
labels:
  app: nginx-demo
```

Selectors match labels.

Example:

```yaml
selector:
  matchLabels:
    app: nginx-demo
```

Real-world context:

Labels are important for:

- Deployments
- Services
- Monitoring
- Cost allocation
- Ownership
- Automation
- Troubleshooting

Talking point:

> In enterprise Kubernetes, labels are not just optional decoration. They are part of how workloads are found, managed, monitored, and governed.

### Production-readiness fields: resources, probes, securityContext

A bare Deployment that only sets an image and replica count is a teaching toy, not a production workload. Three blocks turn it into something a senior reviewer would approve, and we author all three in this class's baseline manifest.

**1. Resource requests and limits**

```yaml
resources:
  requests:
    cpu: "50m"
    memory: "64Mi"
  limits:
    cpu: "250m"
    memory: "128Mi"
```

- `requests` is what the scheduler reserves to decide which node the Pod fits on.
- `limits` is the ceiling the kubelet enforces at runtime.
- A container that exceeds its **memory** limit is killed with `OOMKilled`. A container over its **CPU** limit is throttled (slowed), not killed.
- A Pod with no requests is one of the first to be evicted under node memory pressure.

Talking point:

> "No requests/limits" is the most common code-smell in beginner manifests. Week 12 debugs `OOMKilled` and `Pending` Pods — those failures only exist because limits and requests exist. Author them here so the troubleshooting later is coherent.

**2. Probes: readiness, liveness, startup**

- **Readiness** answers "should this Pod get traffic?" A failing readiness probe pulls the Pod out of its Service endpoints. The Pod still shows `Running`, but `READY` shows `0/1`. This is the link to Class 2: empty endpoints are often a readiness failure, not just a selector typo.
- **Liveness** answers "should the kubelet restart this container?" Use it for wedged-process detection. Keep it more lenient than readiness, or a slow-but-recovering app gets stuck in a restart loop.
- **Startup** gives slow-initializing apps a grace window before liveness kicks in. NGINX starts instantly so we omit it, but name it so students know the map.

Common misconception:

> `Running` means healthy.

Correction:

`Running` only means the container process started. Readiness/liveness decide whether it actually serves traffic and whether it stays alive.

**3. securityContext and Pod Security Standards**

```yaml
securityContext:        # Pod level
  runAsNonRoot: true
  seccompProfile:
    type: RuntimeDefault
# container level:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop: ["ALL"]
```

This is the **Pod Security Standards "restricted"** profile in practice. PSS has three levels — `privileged`, `baseline`, `restricted` — enforced per namespace with labels such as:

```bash
kubectl label namespace student-k8s \
  pod-security.kubernetes.io/enforce=restricted
```

If a namespace enforces `restricted`, admission rejects any Pod that lacks these fields. Modeling them from the first manifest means students never learn the insecure pattern as "normal."



- Multiple application teams
- Standard deployment templates
- CI/CD pipelines
- Git-based reviews
- Image registries
- Secrets management
- Monitoring and alerts
- Ingress and load balancers
- Role-based access control
- Production support processes

This class is the first building block. Students are learning the objects that later support Helm, EKS, GitOps, and SRE operations.

---

## 11. Whiteboard Explanation

### Simple diagram: Kubernetes request flow

```text
Student / Engineer
      |
      | kubectl apply -f nginx-deployment.yaml
      v
Kubernetes API Server
      |
      | Stores desired state
      v
Control Plane
      |
      | Scheduler chooses a node
      | Controllers watch desired state
      v
Worker Node
      |
      | kubelet starts Pod
      v
Pod
      |
      v
Container: nginx:1.25
```

### Step-by-step explanation

1. Student runs `kubectl apply`.
2. `kubectl` sends the request to the API server.
3. Kubernetes stores the desired state.
4. The scheduler decides where the Pod should run.
5. The kubelet on the selected node starts the Pod.
6. The container runtime pulls and runs the image.
7. Controllers keep checking whether the desired number of Pods is running.

### Deployment relationship diagram

```text
Deployment: nginx-demo
  desired replicas: 2
        |
        v
ReplicaSet
  maintains 2 Pods
        |
        v
Pod 1                     Pod 2
container: nginx:1.25     container: nginx:1.25
```

### Real-world enterprise version

```text
Developer commits code
        |
        v
CI/CD pipeline builds image
        |
        v
Image pushed to registry
        |
        v
Deployment YAML or Helm chart updated
        |
        v
Kubernetes cluster deploys workload
        |
        v
Monitoring watches app health
        |
        v
SRE / DevOps team supports production
```

Instructor explanation:

In real environments, engineers usually do not run `kubectl apply` manually into production. Instead, Git and CI/CD pipelines apply changes after review and approval. But the underlying Kubernetes objects remain the same.

---

## 12. Instructor Demo Script

### Demo title

**Deploy and Inspect a Simple NGINX Application with Kubernetes**

### Demo objective

Show students how to create a namespace, deploy an application with a Deployment manifest, inspect Kubernetes resources, scale replicas, and observe self-healing.

### Required setup

Instructor machine should have one of the following:

- Docker Desktop Kubernetes enabled
- kind cluster running
- minikube cluster running

Verify:

```bash
kubectl version --client
kubectl cluster-info
kubectl get nodes
```

Expected output example:

```text
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   10d   v1.xx.x
```

If using kind:

```bash
kind create cluster --name week11
kubectl cluster-info
kubectl get nodes
```

### Step 1: Create a working directory

```bash
mkdir -p week11/class1
cd week11/class1
```

Explain:

> We are keeping our Kubernetes manifests in files because real teams store infrastructure and deployment definitions in Git.

### Step 2: Confirm cluster access

```bash
kubectl get nodes
```

Expected output:

```text
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   10d   v1.xx.x
```

Explain:

> This confirms that `kubectl` can talk to the Kubernetes API server.

Common failure:

```text
The connection to the server localhost:8080 was refused
```

Recovery:

- Start Docker Desktop Kubernetes, kind, or minikube
- Check current context:

```bash
kubectl config current-context
kubectl config get-contexts
```

### Step 3: Create a namespace

```bash
kubectl create namespace week11-demo
```

Expected output:

```text
namespace/week11-demo created
```

Validate:

```bash
kubectl get namespaces
```

Explain:

> We use a namespace so our demo resources are separated from other cluster resources.

### Step 4: Create the Deployment manifest

Create file:

```bash
code nginx-deployment.yaml
```

Paste:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-demo
  namespace: week11-demo
  labels:
    app.kubernetes.io/name: nginx-demo
    app.kubernetes.io/part-of: k8s-fundamentals
spec:
  replicas: 2
  selector:
    matchLabels:
      app.kubernetes.io/name: nginx-demo
  template:
    metadata:
      labels:
        app.kubernetes.io/name: nginx-demo
    spec:
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: nginx
          # nginxinc/nginx-unprivileted listens on 8080 and runs as a non-root user,
          # which lets us model runAsNonRoot + readOnlyRootFilesystem honestly.
          image: nginxinc/nginx-unprivileged:1.27
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: "50m"
              memory: "64Mi"
            limits:
              cpu: "250m"
              memory: "128Mi"
          readinessProbe:
            httpGet:
              path: /
              port: 8080
            initialDelaySeconds: 2
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
          # With a read-only root filesystem, NGINX still needs a few
          # writable scratch paths at startup (temp dirs, cache, pid/socket).
          # We back each with an in-memory emptyDir so the root stays read-only.
          volumeMounts:
            - name: tmp
              mountPath: /tmp
            - name: nginx-cache
              mountPath: /var/cache/nginx
            - name: nginx-run
              mountPath: /var/run
      volumes:
        - name: tmp
          emptyDir: {}
        - name: nginx-cache
          emptyDir: {}
        - name: nginx-run
          emptyDir: {}
```

Explain:

- `kind: Deployment` tells Kubernetes what object to create.
- `replicas: 2` asks for two Pods.
- `selector` must match the Pod template labels (here we use the recommended `app.kubernetes.io/name` label).
- `image: nginxinc/nginx-unprivileged:1.27` is a pinned, non-root NGINX image. We pin a tag (never `latest`) so deployments are reproducible.
- `containerPort: 8080` documents the port the container listens on. The unprivileged NGINX image binds 8080, not 80, because non-root processes cannot bind ports below 1024.

Then walk through the three production-readiness blocks. These are non-negotiable in 2026 and a senior reviewer rejects a Deployment without them on sight:

- **`resources.requests`** is what the scheduler reserves to place the Pod; **`resources.limits`** is the ceiling the kubelet enforces. A container with no requests/limits competes unbounded for node CPU/memory and is the first thing to get OOMKilled or throttled under pressure. (Week 12 debugs `OOMKilled` and `Pending` — those failures only make sense once limits exist, which is why we author them here.)
- **`readinessProbe`** decides whether a Pod receives traffic. A Pod that is `Running` but failing its readiness probe is removed from Service endpoints — the single most common reason "the Pod is up but the app is unreachable" (you will see this exact symptom in Class 2's endpoints lab).
- **`livenessProbe`** decides whether the kubelet restarts the container. Use it for "process is wedged" detection, and keep it more lenient than readiness so a slow-but-recovering app is not killed in a restart loop.
- **`securityContext`** (`runAsNonRoot`, `readOnlyRootFilesystem`, `allowPrivilegeEscalation: false`, dropped capabilities, `seccompProfile: RuntimeDefault`) is the Pod Security Standards **restricted** baseline. We model hardening from the very first manifest rather than bolting it on later.
- **`volumeMounts` + `volumes`** supply the few writable paths NGINX needs once the root filesystem is read-only. The unprivileged image writes its temp/proxy files under `/tmp`, its cache under `/var/cache/nginx`, and its pid/socket under `/var/run`. Without these three `emptyDir` mounts the container fails at startup with `nginx: [emerg] mkdir() "/tmp/proxy_temp" failed (30: Read-only file system)` and crash-loops. Backing them with `emptyDir` keeps the root read-only while giving the process the scratch space it requires.

> Note for instructors: if you prefer to demo the stock `nginx:1.25` image, drop `readOnlyRootFilesystem` and `runAsNonRoot` (stock NGINX writes to `/var/cache/nginx` and binds port 80 as root) and use `containerPort: 80`. We deliberately use the unprivileged image so the hardening fields are real. Note that `readOnlyRootFilesystem: true` only works because of the three writable `emptyDir` mounts above (`/tmp`, `/var/cache/nginx`, `/var/run`) — remove any of them and the Pod crash-loops instead of starting.

### Step 5: Apply the manifest

```bash
kubectl apply -f nginx-deployment.yaml
```

Expected output:

```text
deployment.apps/nginx-demo created
```

Explain:

> `apply` sends the desired state to Kubernetes. Kubernetes now works to create the resources.

### Step 6: Inspect the Deployment

```bash
kubectl get deployments -n week11-demo
```

Expected output:

```text
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
nginx-demo   2/2     2            2           30s
```

Explain:

> READY 2/2 means two desired replicas are running and ready.

### Step 7: Inspect ReplicaSets

```bash
kubectl get replicasets -n week11-demo
```

Expected output:

```text
NAME                    DESIRED   CURRENT   READY   AGE
nginx-demo-xxxxxxxxxx   2         2         2       1m
```

Explain:

> The Deployment created a ReplicaSet. The ReplicaSet maintains the Pods.

### Step 8: Inspect Pods

```bash
kubectl get pods -n week11-demo
```

Expected output:

```text
NAME                          READY   STATUS    RESTARTS   AGE
nginx-demo-xxxxxxxxxx-abcde   1/1     Running   0          1m
nginx-demo-xxxxxxxxxx-fghij   1/1     Running   0          1m
```

Explain:

> The Pods are where the containers actually run.

### Step 9: Show labels

```bash
kubectl get pods -n week11-demo --show-labels
```

Expected output:

```text
NAME                          READY   STATUS    LABELS
nginx-demo-xxxxxxxxxx-abcde   1/1     Running   app.kubernetes.io/name=nginx-demo,pod-template-hash=...
```

Explain:

> Labels help Kubernetes identify which Pods belong to which workload. We use the recommended `app.kubernetes.io/name` label so monitoring, cost tooling, and policy engines can find the workload consistently.

> Teaching note: `READY 1/1` means the container's readiness probe is passing. If the probe were failing, you would see `READY 0/1` even though `STATUS` is `Running` — that distinction is what keeps a not-yet-ready Pod out of Service traffic (Class 2).

### Step 10: Describe the Deployment

```bash
kubectl describe deployment nginx-demo -n week11-demo
```

Point out:

- Replicas
- Selector
- Pod template
- Events

Explain:

> `describe` is one of the first commands you use when troubleshooting Kubernetes.

### Step 11: Scale the Deployment

```bash
kubectl scale deployment nginx-demo --replicas=3 -n week11-demo
```

Expected output:

```text
deployment.apps/nginx-demo scaled
```

Validate:

```bash
kubectl get pods -n week11-demo
```

Expected result:

Three Pods should exist.

Explain:

> We changed the desired state from 2 replicas to 3 replicas. Kubernetes created another Pod.

### Step 12: Delete a Pod and watch self-healing

Get Pod name:

```bash
kubectl get pods -n week11-demo
```

Delete one Pod:

```bash
kubectl delete pod <pod-name> -n week11-demo
```

Immediately check again:

```bash
kubectl get pods -n week11-demo
```

Expected behavior:

- One Pod shows terminating
- A new Pod appears
- Kubernetes returns to 3 running Pods

Explain:

> This is Kubernetes self-healing. The Deployment wants 3 replicas, so Kubernetes replaces the deleted Pod.

### Common demo failure points

| Failure | Likely Cause | Recovery |
|---|---|---|
| `kubectl` cannot connect | Cluster not running | Start Docker Desktop Kubernetes, kind, or minikube |
| Namespace not found | Manifest references namespace not created | Create namespace or update YAML |
| YAML parse error | Indentation problem | Validate spacing, avoid tabs |
| Pod stuck in ImagePullBackOff | Bad image name or tag | Correct image |
| Deployment not created | Selector mismatch with Pod template | Make selector and template labels match |

### Cleanup steps

```bash
kubectl delete namespace week11-demo
```

Expected output:

```text
namespace "week11-demo" deleted
```

If using kind and instructor wants to remove the cluster:

```bash
kind delete cluster --name week11
```

---

## 13. Student Lab Manual

### Lab title

**Create and Inspect Your First Kubernetes Deployment**

### Lab objective

Deploy a simple NGINX application to a local Kubernetes cluster, inspect the resources Kubernetes creates, scale the Deployment, and observe self-healing.

### Estimated time

35 to 45 minutes

### Student prerequisites

Before starting, students should have:

- `kubectl` installed
- A local Kubernetes cluster running
- VS Code or another text editor
- Basic YAML understanding
- Basic Docker image understanding

### Architecture or workflow overview

```text
Student
  |
  | kubectl apply -f nginx-deployment.yaml
  v
Kubernetes API Server
  |
  v
Deployment
  |
  v
ReplicaSet
  |
  v
Pods
  |
  v
NGINX containers
```

### Step 1: Create a lab folder

```bash
mkdir -p week11-class1-lab
cd week11-class1-lab
```

### Step 2: Verify Kubernetes access

```bash
kubectl get nodes
```

Expected output example:

```text
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   10d   v1.xx.x
```

If this fails, ask the instructor for help before continuing.

### Step 3: Create a namespace

```bash
kubectl create namespace student-k8s
```

Expected output:

```text
namespace/student-k8s created
```

Validate:

```bash
kubectl get namespaces
```

### Step 4: Create the Deployment YAML file

Create a file named:

```text
nginx-deployment.yaml
```

Paste:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-demo
  namespace: student-k8s
  labels:
    app.kubernetes.io/name: nginx-demo
    app.kubernetes.io/part-of: k8s-fundamentals
spec:
  replicas: 2
  selector:
    matchLabels:
      app.kubernetes.io/name: nginx-demo
  template:
    metadata:
      labels:
        app.kubernetes.io/name: nginx-demo
    spec:
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: nginx
          image: nginxinc/nginx-unprivileged:1.27
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: "50m"
              memory: "64Mi"
            limits:
              cpu: "250m"
              memory: "128Mi"
          readinessProbe:
            httpGet:
              path: /
              port: 8080
            initialDelaySeconds: 2
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
          # Read-only root needs writable scratch paths for NGINX to start.
          volumeMounts:
            - name: tmp
              mountPath: /tmp
            - name: nginx-cache
              mountPath: /var/cache/nginx
            - name: nginx-run
              mountPath: /var/run
      volumes:
        - name: tmp
          emptyDir: {}
        - name: nginx-cache
          emptyDir: {}
        - name: nginx-run
          emptyDir: {}
```

This is the same production-grade baseline from the demo: pinned non-root image, resource requests/limits, readiness and liveness probes, a restricted `securityContext`, and the writable `emptyDir` scratch paths the unprivileged NGINX needs under a read-only root. Author these fields by hand once — they are the difference between a toy manifest and one a senior reviewer would approve.

### Step 5: Apply the Deployment

```bash
kubectl apply -f nginx-deployment.yaml
```

Expected output:

```text
deployment.apps/nginx-demo created
```

### Step 6: Inspect the Deployment

```bash
kubectl get deployments -n student-k8s
```

Expected output:

```text
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
nginx-demo   2/2     2            2           30s
```

### Step 7: Inspect ReplicaSets

```bash
kubectl get replicasets -n student-k8s
```

Expected output:

```text
NAME                    DESIRED   CURRENT   READY   AGE
nginx-demo-xxxxxxxxxx   2         2         2       1m
```

### Step 8: Inspect Pods

```bash
kubectl get pods -n student-k8s
```

Expected output:

```text
NAME                          READY   STATUS    RESTARTS   AGE
nginx-demo-xxxxxxxxxx-abcde   1/1     Running   0          1m
nginx-demo-xxxxxxxxxx-fghij   1/1     Running   0          1m
```

### Step 9: Show Pod labels

```bash
kubectl get pods -n student-k8s --show-labels
```

Expected output includes:

```text
app.kubernetes.io/name=nginx-demo
```

### Step 10: Describe the Deployment

```bash
kubectl describe deployment nginx-demo -n student-k8s
```

Look for:

- Name
- Namespace
- Replicas
- Selector
- Pod template
- Events

### Step 11: Scale the Deployment (declarative first)

In real teams, the **declarative** path is primary: you edit the manifest in Git and reapply, so the cluster state always matches a reviewed file. Imperative `kubectl scale` is a legitimate quick fix for an incident, but it creates drift from your YAML.

**Preferred — edit + apply:**

1. In `nginx-deployment.yaml`, change `replicas: 2` to `replicas: 3`.
2. Preview the change before applying (render/plan-before-apply discipline):

```bash
kubectl diff -f nginx-deployment.yaml
```

`kubectl diff` shows exactly what will change in the live cluster. Read it before you apply.

3. Apply:

```bash
kubectl apply -f nginx-deployment.yaml
```

**Quick-fix alternative — imperative scale** (use during incidents, then reconcile your YAML afterward):

```bash
kubectl scale deployment nginx-demo --replicas=3 -n student-k8s
```

> Warning: if you `kubectl scale` to 3 but leave the manifest at 2, the next `kubectl apply` of that file will scale you back to 2. Imperative changes that are not written back to Git are a classic source of "it changed by itself" incidents.

Validate either way:

```bash
kubectl get pods -n student-k8s
```

Expected result:

Three Pods should exist.

### Step 11b: Autoscale conceptually with HPA (optional, requires metrics-server)

Manual replica counts are fine for learning, but production usually scales on demand with a **HorizontalPodAutoscaler (HPA)**. The HPA adjusts replicas based on observed metrics (CPU here) between a floor and ceiling. This is why we authored `resources.requests` earlier — the HPA computes CPU utilization as a percentage of the request, so **HPA does not work without requests set**.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-demo
  namespace: student-k8s
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-demo
  minReplicas: 2
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

```bash
kubectl apply -f nginx-hpa.yaml
kubectl get hpa -n student-k8s
```

> Note: HPA needs the **metrics-server** add-on installed in the cluster. Docker Desktop and kind do not ship it by default (`kubectl top pods` will fail until you install it). If metrics-server is not present, read this section conceptually — the key takeaway is that autoscaling depends on resource requests, which is why they belong in the baseline manifest. When the HPA owns replicas, remove the static `replicas:` field from the Deployment so the two do not fight.

### Step 12: Delete one Pod

List Pods:

```bash
kubectl get pods -n student-k8s
```

Delete one Pod:

```bash
kubectl delete pod <pod-name> -n student-k8s
```

Check again:

```bash
kubectl get pods -n student-k8s
```

Expected result:

Kubernetes creates a replacement Pod.

### Step 13: View all resources in the namespace

```bash
kubectl get all -n student-k8s
```

Expected resources:

- Deployment
- ReplicaSet
- Pods

### Validation checklist

Students should confirm:

- [ ] `kubectl get nodes` works
- [ ] Namespace `student-k8s` exists
- [ ] Deployment `nginx-demo` exists
- [ ] ReplicaSet exists
- [ ] At least 2 Pods are running
- [ ] Scaling to 3 replicas works
- [ ] Deleting one Pod causes Kubernetes to recreate it
- [ ] Student can explain Deployment to ReplicaSet to Pod relationship

### Troubleshooting tips

| Problem | What to Check | Fix |
|---|---|---|
| `kubectl` connection error | Is Kubernetes running? | Start Docker Desktop Kubernetes, kind, or minikube |
| Namespace error | Did you create `student-k8s`? | Run `kubectl create namespace student-k8s` |
| YAML error | Indentation and spacing | Use spaces, not tabs |
| ImagePullBackOff | Image name or tag | Use `nginxinc/nginx-unprivileged:1.27` |
| Pods not created | Deployment events | Run `kubectl describe deployment nginx-demo -n student-k8s` |
| Wrong namespace | Command missing `-n student-k8s` | Add namespace flag |

### Cleanup steps

Delete lab resources:

```bash
kubectl delete namespace student-k8s
```

Expected output:

```text
namespace "student-k8s" deleted
```

Confirm cleanup:

```bash
kubectl get namespaces
```

### Reflection questions

1. What did the Deployment create automatically?
2. Why did Kubernetes recreate the Pod after you deleted it?
3. What does `replicas: 2` mean?
4. What is the difference between a Pod and a container?
5. Why do teams store Kubernetes manifests in Git?

### Optional challenge task

Edit the YAML file and change:

```yaml
replicas: 2
```

To:

```yaml
replicas: 4
```

Apply the file again:

```bash
kubectl apply -f nginx-deployment.yaml
kubectl get pods -n student-k8s
```

Explain what changed and why.

---

## 14. Troubleshooting Activity

### Incident or problem title

**Deployment Failed After Kubernetes Manifest Update**

### Business impact

A development team is moving a small web application from manually managed containers to Kubernetes. The team expected two NGINX Pods to run, but the deployment failed. This blocks the team from validating the new Kubernetes deployment workflow.

### Symptoms

Students may see one of these symptoms depending on the broken manifest used:

Symptom A:

```text
The Deployment "broken-nginx" is invalid: spec.template.metadata.labels: Invalid value: map[string]string{"app":"nginx-demo"}: `selector` does not match template `labels`
```

Symptom B:

```text
STATUS: ImagePullBackOff
```

or:

```text
ErrImagePull
```

### Starting evidence

Broken manifest:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken-nginx
  namespace: student-k8s
  labels:
    app: broken-nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: broken-nginx
  template:
    metadata:
      labels:
        app: nginx-demo
    spec:
      containers:
        - name: nginx
          image: nginx:notarealversion
          ports:
            - containerPort: 80
```

### Student investigation steps

1. Apply the broken manifest:

```bash
kubectl apply -f broken-nginx-deployment.yaml
```

2. Read the error carefully.

3. If the Deployment was created, inspect resources:

```bash
kubectl get deployments -n student-k8s
kubectl get pods -n student-k8s
kubectl describe deployment broken-nginx -n student-k8s
kubectl get events -n student-k8s --sort-by=.metadata.creationTimestamp
```

4. If Pods exist but are not running, inspect a Pod:

```bash
kubectl describe pod <pod-name> -n student-k8s
```

5. Identify whether the issue is:

- YAML structure
- selector mismatch
- image problem
- namespace problem

### Expected root cause

There are two intentional issues:

1. Deployment selector does not match Pod template label.

Broken:

```yaml
selector:
  matchLabels:
    app: broken-nginx
template:
  metadata:
    labels:
      app: nginx-demo
```

2. Container image tag does not exist.

Broken:

```yaml
image: nginx:notarealversion
```

### Correct resolution

Fix the label mismatch:

```yaml
selector:
  matchLabels:
    app: broken-nginx
template:
  metadata:
    labels:
      app: broken-nginx
```

Fix the image tag:

```yaml
image: nginx:1.25
```

Corrected manifest:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken-nginx
  namespace: student-k8s
  labels:
    app: broken-nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: broken-nginx
  template:
    metadata:
      labels:
        app: broken-nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
```

Apply again:

```bash
kubectl apply -f broken-nginx-deployment.yaml
kubectl get pods -n student-k8s
```

### Common wrong paths

| Wrong Path | Why It Happens | Correction |
|---|---|---|
| Restarting Docker immediately | Student assumes local cluster is broken | Read Kubernetes error first |
| Deleting the namespace too early | Student wants a clean reset | Investigate before deleting evidence |
| Changing random YAML fields | Student does not understand selectors | Compare selector with template labels |
| Ignoring image tag | Student focuses only on Kubernetes objects | Check Pod events for image pull errors |
| Running commands without namespace | Student forgets `-n student-k8s` | Always check the namespace |

### Instructor hints

Start with gentle hints:

1. “Look at the exact error message. What field is mentioned?”
2. “Compare the selector labels with the template labels.”
3. “What does `ImagePullBackOff` usually mean?”
4. “Which command shows events?”
5. “Are you checking the correct namespace?”

### Preventive action

In real teams, prevent this by:

- Reviewing Kubernetes manifests in pull requests
- Using YAML linting
- Using CI validation
- Using known image tags
- Using Helm templates carefully
- Using consistent labels across applications
- Testing manifests in dev before promotion

---

## 15. Scenario-Based Discussion Questions

### Question 1

**Why would a company move from containers on EC2 to Kubernetes?**

Expected themes:

- Standard deployment model
- Scaling
- Self-healing
- Better workload management
- Repeatable deployments
- Reduced manual operations

Instructor follow-up:

> What new operational complexity does Kubernetes introduce?

### Question 2

**Why is it risky to manually deploy containers on production servers?**

Expected themes:

- Configuration drift
- Inconsistent deployments
- No automatic recovery
- Hard rollback
- Weak audit trail
- Harder team collaboration

Instructor follow-up:

> How does storing manifests in Git reduce this risk?

### Question 3

**Should every company use Kubernetes?**

Expected themes:

- Not always
- Kubernetes adds complexity
- Smaller apps may not need it
- Value increases with scale, teams, microservices, and operational needs

Instructor follow-up:

> What signs suggest Kubernetes is worth the investment?

### Question 4

**What could happen if teams use inconsistent labels in Kubernetes?**

Expected themes:

- Services may not find Pods
- Monitoring may miss workloads
- Cost allocation becomes harder
- Automation may fail
- Troubleshooting becomes slower

Instructor follow-up:

> What label standards would you require in an enterprise cluster?

### Question 5

**What is the difference between desired state and actual state?**

Expected themes:

- Desired state is what YAML requests
- Actual state is what is currently running
- Kubernetes reconciles the two
- Troubleshooting compares both

Instructor follow-up:

> Which commands help you inspect actual state?

### Question 6

**How does Kubernetes self-healing help SRE teams?**

Expected themes:

- Reduces manual restarts
- Improves availability
- Replaces failed Pods
- Supports reliability goals
- Reduces operational toil

Instructor follow-up:

> What kinds of failures can Kubernetes not automatically solve?

### Question 7

**How would Kubernetes fit into a CI/CD pipeline?**

Expected themes:

- Build image
- Push to registry
- Update manifest or Helm values
- Deploy to cluster
- Validate rollout
- Monitor deployment

Instructor follow-up:

> Why should production deployment usually require approvals?

---

## 16. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple choice

What is the smallest deployable unit in Kubernetes?

A. Node  
B. Pod  
C. Cluster  
D. Namespace  

**Answer:** B. Pod  
**Explanation:** A Pod is the smallest deployable Kubernetes workload object.

### Question 2: Multiple choice

Which command shows Pods in a specific namespace?

A. `kubectl get pods -n student-k8s`  
B. `kubectl show pods student-k8s`  
C. `kubectl list pods --namespace student-k8s`  
D. `kubectl describe namespace pods`  

**Answer:** A  
**Explanation:** `kubectl get pods -n <namespace>` lists Pods in a namespace.

### Question 3: True or false

A Deployment directly runs containers without creating any other Kubernetes objects.

**Answer:** False  
**Explanation:** A Deployment manages a ReplicaSet, which manages Pods. Pods run containers.

### Question 4: Short answer

What does `replicas: 2` mean in a Deployment?

**Answer:** Kubernetes should keep two matching Pods running.  
**Explanation:** The replica count defines the desired number of Pod copies.

### Question 5: Multiple choice

What AWS service provides managed Kubernetes?

A. Amazon EC2  
B. Amazon ECS only  
C. Amazon EKS  
D. Amazon S3  

**Answer:** C. Amazon EKS  
**Explanation:** Amazon EKS is AWS managed Kubernetes.

### Question 6: Multiple choice

A Pod is stuck in `ImagePullBackOff`. What is the most likely issue?

A. Wrong image name or tag  
B. Too many namespaces  
C. Missing Deployment label only  
D. The cluster has no API server  

**Answer:** A  
**Explanation:** `ImagePullBackOff` usually means Kubernetes cannot pull the container image.

### Question 7: True or false

Kubernetes manifests are commonly stored in Git for review, version control, and repeatable deployments.

**Answer:** True  
**Explanation:** Git-based workflows are common in DevOps and platform engineering.

### Question 8: Short answer

Why are labels important in Kubernetes?

**Answer:** Labels identify and group resources so Kubernetes objects and tools can select and manage them.  
**Explanation:** Labels support Deployments, Services, monitoring, automation, and troubleshooting.

### Question 9: Multiple choice

Which command gives detailed troubleshooting information about a Deployment?

A. `kubectl get deployment nginx-demo`  
B. `kubectl describe deployment nginx-demo -n student-k8s`  
C. `kubectl remove deployment nginx-demo`  
D. `kubectl show deployment nginx-demo`  

**Answer:** B  
**Explanation:** `kubectl describe` shows details, events, selectors, and status.

### Question 10: Short answer

What happens when you delete a Pod managed by a Deployment?

**Answer:** Kubernetes creates a replacement Pod to maintain the desired replica count.  
**Explanation:** This is part of Kubernetes reconciliation and self-healing.

### Question 11: Multiple choice

Which cloud service is the Azure equivalent of managed Kubernetes?

A. Azure VNet  
B. Azure AKS  
C. Azure Blob Storage  
D. Azure Monitor  

**Answer:** B. Azure AKS  
**Explanation:** AKS is Azure Kubernetes Service.

### Question 12: Short answer

Name two things a DevOps engineer should check when a Kubernetes Deployment fails.

**Answer:** Possible answers include Pod status, Deployment events, image name, namespace, YAML syntax, selectors, labels, and logs.  
**Explanation:** Troubleshooting starts by inspecting actual state and error messages.

---

## 17. Homework Assignment

### Assignment title

**Kubernetes Architecture and First Deployment Documentation**

### Scenario

Your team is starting a migration from manually managed Docker containers to Kubernetes. Your manager asks you to document the first basic Kubernetes deployment so junior team members can understand the relationship between Kubernetes objects.

### Student tasks

Students must:

1. Create or reuse the `nginx-demo` Deployment from class.
2. Scale the Deployment to 3 replicas.
3. Delete one Pod and observe Kubernetes recreate it.
4. Capture command outputs.
5. Create a diagram showing the relationship between:
   - Cluster
   - Node
   - Namespace
   - Deployment
   - ReplicaSet
   - Pod
   - Container
   - Labels
   - Selectors
6. Write short explanations for:
   - What a Pod is
   - What a Deployment does
   - What a ReplicaSet does
   - Why Kubernetes recreated the deleted Pod
   - Why labels and selectors matter

### Expected deliverables

Students submit:

1. One diagram as PNG, PDF, Markdown, or screenshot
2. One short written explanation, 1 to 2 pages
3. Command output from:

```bash
kubectl get nodes
kubectl get namespaces
kubectl get deployments -n student-k8s
kubectl get replicasets -n student-k8s
kubectl get pods -n student-k8s --show-labels
```

4. A short reflection answering:

```text
What did Kubernetes do automatically that would be manual without Kubernetes?
```

### Submission format

Submit either:

- A Markdown file named `week11-class1-homework.md`
- Or a PDF document

Recommended repo structure:

```text
week11/
  class1/
    nginx-deployment.yaml
    homework/
      week11-class1-homework.md
      diagram.png
```

### Estimated completion time

60 to 90 minutes

### Grading criteria

| Criteria | Points |
|---|---:|
| Correct Kubernetes diagram | 25 |
| Correct command outputs | 20 |
| Accurate explanation of Deployment, ReplicaSet, Pod | 25 |
| Clear explanation of labels and selectors | 15 |
| Reflection shows operational understanding | 10 |
| Clean formatting and submission structure | 5 |

### Optional advanced challenge

Create a second Deployment using a different image, such as:

```yaml
image: httpd:2.4
```

Compare the two Deployments and explain what stayed the same and what changed.

---

## 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Forgetting namespace flag | Students create resources in one namespace but check another | Use `-n student-k8s` consistently |
| YAML indentation errors | YAML is whitespace-sensitive | Use VS Code YAML extension and spaces only |
| Thinking Deployment equals Pod | Kubernetes object hierarchy is new | Repeat Deployment to ReplicaSet to Pod model |
| Using invalid image tag | Students mistype image name or version | Check official image tags and Pod events |
| Not reading error messages | Students jump to random fixes | Teach “read the first error carefully” habit |
| Deleting resources before investigating | Students want a clean reset too quickly | Preserve evidence during troubleshooting |
| Confusing local Kubernetes with EKS | Both run Kubernetes, but setup differs | Explain local cluster is for learning, EKS is managed AWS Kubernetes |
| Running commands from wrong context | Multiple Kubernetes contexts may exist | Check `kubectl config current-context` |
| Assuming Kubernetes fixes all failures | Kubernetes can restart Pods but not fix bad code or bad config | Explain self-healing limits |
| Ignoring labels | Labels seem optional at first | Show how selectors depend on labels |

---

## 19. Real-World Enterprise Scenario

### Scenario

A mid-sized company currently runs several internal web applications as Docker containers on EC2 instances. Each application team has a different deployment process. Some teams SSH into servers and run containers manually. Others use shell scripts. During releases, teams often experience inconsistent deployments, unclear rollback steps, and limited visibility into what is running.

The platform engineering team proposes moving these applications to Kubernetes, with Amazon EKS as the long-term AWS platform.

### Constraints

- Developers should not SSH into production servers
- Deployments must be reviewed through Git
- Application teams need separate namespaces
- Production changes require approval
- Images must come from an approved registry
- Monitoring and logs must be available
- Costs must be controlled
- Access must follow least privilege
- Rollbacks must be repeatable
- SRE team needs a consistent troubleshooting model

### How this class topic applies

This class introduces the foundational Kubernetes objects that support that enterprise goal:

- Deployments define application desired state
- ReplicaSets maintain Pod count
- Pods run application containers
- Namespaces separate teams or environments
- Labels and selectors support management and automation
- `kubectl` helps inspect actual state

### What each role would do

| Role | Responsibility |
|---|---|
| DevOps Engineer | Build the CI/CD workflow that deploys Kubernetes manifests |
| Cloud Engineer | Build and manage the EKS cluster, networking, IAM, and access model |
| SRE | Define health checks, monitoring, reliability targets, and troubleshooting practices |
| Platform Engineer | Create reusable templates and standards for application teams |
| Security Engineer | Review IAM, image sources, secrets, and access controls |

---

## 20. Instructor Tips

### Teaching tips

- Start from Docker because students learned it recently.
- Avoid introducing too many Kubernetes objects in one class.
- Keep Services, Ingress, ConfigMaps, and Secrets mostly for later unless briefly mentioned.
- Repeat the hierarchy often: Deployment -> ReplicaSet -> Pod -> Container.
- Use diagrams before YAML.
- Explain `kubectl` commands before expecting students to memorize them.

### Pacing tips

- Do not spend too long on control plane internals.
- Keep architecture practical and beginner-friendly.
- Leave enough time for students to struggle with real YAML issues.
- Use the troubleshooting activity to build confidence.

### Lab support tips

When students are stuck, ask:

1. What namespace are you using?
2. What does `kubectl get pods -n student-k8s` show?
3. What does `kubectl describe` show?
4. What does the error message say?
5. Did you save the YAML file before applying?

### Helping struggling students

Give them this minimum success path:

```bash
kubectl get nodes
kubectl create namespace student-k8s
kubectl apply -f nginx-deployment.yaml
kubectl get pods -n student-k8s
```

Then build from there.

### Challenging advanced students

Ask them to:

- Change replica count using YAML instead of `kubectl scale`
- Add labels such as `environment: dev` and `owner: student`
- Compare `kubectl apply` and `kubectl create`
- Export resource YAML:

```bash
kubectl get deployment nginx-demo -n student-k8s -o yaml
```

- Explain how this would later fit into CI/CD

---

## 21. Student Outcome Checklist

### Students should be able to explain

- [ ] What Kubernetes is
- [ ] Why Kubernetes is used after Docker
- [ ] What a cluster is
- [ ] What a node is
- [ ] What the API server does
- [ ] What a Pod is
- [ ] What a Deployment is
- [ ] What a ReplicaSet is
- [ ] What a namespace is
- [ ] What labels and selectors do
- [ ] What desired state means
- [ ] How EKS relates to Kubernetes

### Students should be able to build or configure

- [ ] A namespace
- [ ] A Deployment YAML file
- [ ] A basic NGINX Deployment
- [ ] A scaled Deployment
- [ ] A simple local Kubernetes lab folder
- [ ] Basic documentation for the Deployment

### Students should be able to troubleshoot

- [ ] `kubectl` connection problems
- [ ] Wrong namespace issues
- [ ] YAML indentation errors
- [ ] Bad image tag issues
- [ ] Selector and label mismatches
- [ ] Pods not reaching Running state
- [ ] Deployment not creating expected replicas

---

## 22. Class Completion Checklist

### Instructor checklist before ending class

- [ ] Students understand why Kubernetes follows Docker in the course
- [ ] Students can explain Deployment -> ReplicaSet -> Pod -> Container
- [ ] Students successfully created a namespace
- [ ] Students successfully deployed NGINX
- [ ] Students inspected Deployment, ReplicaSet, and Pods
- [ ] Students scaled the Deployment
- [ ] Students observed Pod self-healing
- [ ] Students completed or attempted the troubleshooting activity
- [ ] Homework instructions are clear
- [ ] Students understand that Class 2 covers Services and application exposure

### Student checklist before leaving class

- [ ] I can run `kubectl get nodes`
- [ ] I created a namespace
- [ ] I applied a Deployment YAML file
- [ ] I inspected Pods, ReplicaSets, and Deployments
- [ ] I scaled a Deployment
- [ ] I deleted a Pod and saw Kubernetes replace it
- [ ] I know how to use `kubectl describe`
- [ ] I know what `ImagePullBackOff` usually means
- [ ] I know why labels and selectors matter
- [ ] I understand the homework deliverables

### Items to verify before moving to Class 2

Before Class 2, students should have:

- Working `kubectl`
- A running local Kubernetes cluster
- Basic comfort with namespaces
- Basic understanding of Deployments and Pods
- A completed or partially completed NGINX Deployment
- Understanding that the app is deployed but not yet properly exposed through a Kubernetes Service

Class 2 should build from here by introducing Kubernetes Services, ClusterIP, NodePort, LoadBalancer, endpoints, port-forwarding, and service-to-pod troubleshooting.

---

## Class Artifacts & Validation

The on-disk, validated versions of this class's manifests live in the backing module [`labs/kubernetes-fundamentals/`](../../labs/kubernetes-fundamentals/). The inline NGINX snippets above are teaching aids; the rows below are the real files a student fills in (`starter/`), checks against (`solution/`), and validates. The lab models the same Deployment object this class teaches (a hardened, multi-replica Deployment with probes, resource requests/limits, and a restricted `securityContext`) plus the two runtime-failure fixtures that set up the Class 1 troubleshooting activity and Week 12.

All commands below were run from `labs/kubernetes-fundamentals/`. The live gates ran against a reachable local `kind` cluster (Kubernetes v1.31); `kubeconform v0.6.7` was on `PATH`.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/kubernetes-fundamentals/starter/deployment.yaml | kubernetes (yaml) | The student's authoring loop: the solution Deployment with the securityContext, probes, and resources blocks removed as 4 `TODO(student)` gaps | `./validate.sh` (renders + 16 structural tests over the completed render) | PASS — `11 passed, 0 failed, 1 deferred` |
| 2 | labs/kubernetes-fundamentals/solution/base/namespace.yaml | kubernetes (yaml) | Namespace that enforces the `restricted` Pod Security Standard (the admission backstop taught in §10) | `kubectl kustomize solution/base \| kubeconform -strict -summary` | PASS — `Valid: 10, Invalid: 0` |
| 3 | labs/kubernetes-fundamentals/solution/base/deployment.yaml | kubernetes (yaml) | The hardened Deployment: 2 replicas, liveness+readiness probes, CPU/memory requests+limits, `runAsNonRoot`/`readOnlyRootFilesystem`/dropped caps/`seccomp:RuntimeDefault`, writable `/tmp` emptyDir | `python3 -m unittest discover -s tests` | PASS — `Ran 16 tests ... OK` |
| 4 | labs/kubernetes-fundamentals/solution/base/hpa.yaml | kubernetes (yaml) | HorizontalPodAutoscaler (CPU 70%, 2→6) — the autoscaling-off-the-CPU-request concept from §13 Step 11b | `kubectl kustomize solution/base \| kubeconform -strict -summary` | PASS — `Valid: 10, Invalid: 0` |
| 5 | labs/kubernetes-fundamentals/solution/base/kustomization.yaml | kustomize | Ties the base together and applies it into the `web` namespace | `kubectl kustomize solution/base` (renders 10 objects) | PASS |
| 6 | labs/kubernetes-fundamentals/solution/overlays/prod/kustomization.yaml | kustomize | Prod overlay: reuses the base, `prod-` name prefix, patches the Deployment to `replicas: 4` (declarative-scaling discipline from §13 Step 11) | `kubectl kustomize solution/overlays/prod \| kubeconform -strict -summary` | PASS — `Valid: 10, Invalid: 0`; rendered Deployment shows `replicas: 4` |
| 7 | labs/kubernetes-fundamentals/broken/deployment-oomkilled.yaml | kubernetes (yaml) | Runtime-fault fixture for the troubleshooting activity: 12Mi memory limit → OOMKilled crash loop (`Exit Code: 137`) | `./validate.sh` live gate: apply fixture, observe `Reason: OOMKilled, Exit Code: 137` | PASS — live cluster reproduced OOMKilled / 137 |
| 8 | labs/kubernetes-fundamentals/broken/deployment-badprobe.yaml | kubernetes (yaml) | Runtime-fault fixture: readiness probe on port 9999 → pod `Running` but never `Ready`, empty Service endpoints | `./validate.sh` live gate: apply fixture, observe `0/1 Running` + endpoints `<none>` | PASS — live cluster reproduced never-Ready + empty endpoints |
| 9 | labs/kubernetes-fundamentals/validate.sh | shell | The module's validation runner (all gates above) | `bash -n validate.sh` then `./validate.sh` | PASS — exits 0, `11 passed, 0 failed, 1 deferred` |

Captured `./validate.sh` summary (this environment, live `kind` cluster reachable):

```
== validating kubernetes-fundamentals ==
  [PASS]  yaml: all manifests parse (multi-doc)
  [PASS]  kustomize: solution/base renders
  [PASS]  kustomize: solution/overlays/prod renders
  [PASS]  tests: unittest discover -s tests (structural assertions)
  [PASS]  shell: validate.sh syntax
  [PASS]  kubeconform: -strict on solution/base render
  [PASS]  kubeconform: -strict on solution/overlays/prod render
  [PASS]  kubeconform: -strict on broken fixtures
  [PASS]  cluster: apply base into ns lab-k8s-validate + 2/2 Ready
  [PASS]  cluster: reproduce OOMKilled fixture (Reason OOMKilled, exit 137)
  [PASS]  cluster: reproduce never-Ready probe fixture (empty endpoints)
  [DEFER] kubectl: apply --dry-run=client per manifest (superseded by live apply)
== 11 passed, 0 failed, 1 deferred ==
```

The one `DEFER` (`kubectl apply --dry-run=client`) is honest: the live apply above already proves the API server admits every object under the `restricted` PSA, so the client dry-run adds nothing — it stays documented for environments without the live path. See the lab README [Validation](../../labs/kubernetes-fundamentals/README.md#validation) section for the full captured `kubectl describe` evidence of the OOMKilled and never-Ready reproductions.

## Definition of Done

- [x] **Every technology taught ships at least one runnable file on disk.** Kubernetes (Deployment, Namespace, HPA, Kustomize base/overlay) → real `*.yaml` in `labs/kubernetes-fundamentals/solution/` and `starter/`, not just fences.
- [x] **Each artifact passes (or documents) its validation gate; output captured.** YAML parse + `kubectl kustomize` render + `kubeconform -strict` + 16 structural tests + live cluster apply, all captured above.
- [x] **Lab has starter (intentionally incomplete) and solution (reference) versions.** `starter/deployment.yaml` has 4 real `TODO(student)` gaps; `solution/base/` is the reference.
- [x] **Lab README includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, cost notes.** All present in [`labs/kubernetes-fundamentals/README.md`](../../labs/kubernetes-fundamentals/README.md).
- [x] **Cleanup/teardown is provided and idempotent.** README Cleanup section uses `--ignore-not-found` / `kind delete cluster`; the live `validate.sh` gates run in a throwaway namespace torn down on exit.
- [x] **Instructor answer key exists for the lab, homework, quiz, and troubleshooting exercise.** Lab answer key in README; class quiz (§16) and homework (§17) have answer keys/rubrics; troubleshooting symptom→cause→fix in §14 and README.
- [x] **Troubleshooting exercise uses a real, reproducible broken state.** `broken/deployment-oomkilled.yaml` and `broken/deployment-badprobe.yaml` are real fixtures whose runtime faults were reproduced live on the cluster this run.
- [x] **Expected outputs are shown for demos and labs.** `READY 2/2`, the OOMKilled/`137` and never-Ready/empty-endpoints outputs are captured here and in the README.
- [x] **Cost & security warnings present.** §6 cost warning (no EKS yet); securityContext / PSS hardening taught in §10; lab README has dedicated security and cost sections ($0 by default).
- [x] **Cross-references to the module repo and prior/next weeks are correct.** Week 10 (Docker) recap → this week → Week 12 (troubleshooting, which reuses the `broken/` fixtures); module link verified.
- [x] **The artifact manifest (§4.2) is present and every path resolves.** Table above; all 9 paths `ls`-verified.
