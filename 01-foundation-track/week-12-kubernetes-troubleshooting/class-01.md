# Week 12, Class 1: Kubernetes Workload Troubleshooting Fundamentals

**Week:** Week 12  
**Track:** Unified DevOps · Cloud · SRE Track  
**Week topic:** Kubernetes Operations and Troubleshooting  
**Class duration:** 3 hours  
**Audience:** Beginner to intermediate  
**Primary production context:** AWS EKS  
**Class type:** Instructor-led with guided demo, hands-on lab, and troubleshooting challenge  

---

# SECTION A: Instructor Teaching Guide

---

> **▶ Runnable lab for this class:** [`labs/kubernetes-fundamentals/`](../../labs/kubernetes-fundamentals/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## 1. Class Snapshot

| Item | Details |
|---|---|
| Class title | Kubernetes Workload Troubleshooting Fundamentals |
| Week | Week 12 |
| Class | Class 1 of 2 |
| Duration | 3 hours |
| Main focus | Troubleshooting pods, deployments, logs, events, and common workload failure states |
| Primary tools | `kubectl`, Kubernetes events, pod logs, deployment status |
| AWS context | EKS workload troubleshooting, ECR image pulls, CloudWatch Container Insights overview |
| Main scenario | A production deployment fails after a new container image release |
| Student deliverable | Fixed Kubernetes workloads and a pod troubleshooting checklist |

---

## 2. Teaching Storyline

Use one storyline throughout the class:

> A development team pushed a new container image for an internal web application. The CI/CD pipeline completed, but the Kubernetes deployment is unhealthy. The app team says, “The deployment failed, but we do not know why.” The DevOps/SRE team must investigate using Kubernetes evidence, identify the root cause, fix the issue, and validate recovery.

The class should move through this sequence:

```text
Deployment failed
→ Check current Kubernetes status
→ Identify the failure state
→ Inspect pod details
→ Read events
→ Read logs if the container started
→ Find the root cause
→ Apply the smallest safe fix
→ Validate recovery
→ Explain the issue clearly
```

This gives the class a practical production-support feel instead of becoming a list of commands.

---

## 3. Learning Objectives

By the end of this class, students will be able to:

1. Use `kubectl get`, `describe`, `logs`, and `events` to investigate workload failures.
2. Explain common pod states such as `Pending`, `Running`, `CrashLoopBackOff`, and `ImagePullBackOff`.
3. Diagnose failed deployments caused by bad images, bad commands, missing environment variables, and failed container startup.
4. Reproduce and diagnose an unschedulable `Pending` pod caused by an oversized resource request.
5. Reproduce and diagnose an `OOMKilled` container (exit code 137) caused by a memory limit that is too low.
6. Use `kubectl debug` ephemeral containers and `kubectl top` to investigate pods that have no shell and to read live resource usage.
7. Understand how readiness and liveness probes affect application availability.
8. Identify basic resource request and limit issues.

---

## 4. Prerequisite Review

Before starting the new material, quickly verify students remember these Week 11 (Kubernetes Fundamentals) concepts:

| Concept | Quick Review Question |
|---|---|
| Pod | What actually runs the container? |
| Deployment | What object manages replicas and rollout behavior? |
| ReplicaSet | What object maintains the desired number of pods? |
| Image | What does Kubernetes pull to start a container? |
| YAML manifest | Where is the desired configuration defined? |
| Namespace | How do we logically separate Kubernetes resources? |
| `kubectl apply` | What does this command do? |
| `kubectl get pods` | What information does this show? |

Instructor checkpoint:

Ask students to explain this relationship:

```text
Deployment → ReplicaSet → Pod → Container
```

Expected answer:

A Deployment manages a ReplicaSet. The ReplicaSet creates and maintains Pods. Each Pod runs one or more containers.

---

## 5. Time-Boxed Agenda

| Time | Segment | Teaching Purpose |
|---:|---|---|
| 0:00 to 0:15 | Review Week 11 Kubernetes fundamentals | Reactivate prior knowledge before troubleshooting |
| 0:15 to 0:35 | Kubernetes troubleshooting mindset | Teach evidence-first investigation |
| 0:35 to 1:00 | Pod lifecycle, pod phases, and common failure states | Help students understand what pod statuses mean |
| 1:00 to 1:25 | `kubectl get`, `describe`, `logs`, and `events` | Teach the core troubleshooting commands and when to use each |
| 1:25 to 1:35 | Break | Short reset |
| 1:35 to 2:00 | Instructor demo | Model a real troubleshooting flow |
| 2:00 to 2:45 | Student lab | Students reproduce and fix five workload faults: bad image, CrashLoop, missing config, Pending, OOMKilled |
| 2:45 to 2:55 | Group review | Students explain evidence, root cause, and fix; introduce `kubectl debug` / `kubectl top` |
| 2:55 to 3:00 | Wrap-up and homework | Reinforce mental model and assign checklist |

---

## 6. Concept-by-Concept Teaching Guide

### Segment 1: Review Kubernetes Workload Basics  
**Time:** 0:00 to 0:15

Teach this briefly. Do not reteach all of Week 11.

Core explanation:

A Kubernetes Deployment describes the desired state of an application. Kubernetes continuously tries to make the actual state match that desired state. Troubleshooting starts when the actual state does not match what we expected.

Use this diagram:

```text
Desired state:
Deployment says: "Run 2 replicas of this app"

Actual state:
Only 0/2 pods are ready

Troubleshooting question:
Why can Kubernetes not reach the desired state?
```

Ask:

- Is this a Kubernetes platform issue?
- Is this an application issue?
- Is this an image/registry issue?
- Is this a configuration issue?

---

### Segment 2: Kubernetes Troubleshooting Mindset  
**Time:** 0:15 to 0:35

Teach students not to jump straight into editing YAML.

Use this investigation flow:

```text
1. Observe the symptom
2. Gather Kubernetes evidence
3. Gather application evidence
4. Identify the root cause
5. Make the smallest safe fix
6. Validate the result
7. Communicate clearly
```

Explain the difference between symptom and root cause:

| Symptom | Possible Root Cause |
|---|---|
| Pod is `ImagePullBackOff` | Wrong image tag, missing registry permissions, private registry auth issue |
| Pod is `CrashLoopBackOff` | App starts then exits, bad command, missing config, runtime error |
| Pod is `Pending` | No node capacity, scheduling constraint, resource request too high |
| Pod is running but not ready | Readiness probe failure, app not listening, dependency unavailable |

Instructor talking point:

> In production, we do not want engineers guessing. We want them to collect evidence and make a safe, minimal fix.

---

### Segment 3: Pod Lifecycle and Failure States  
**Time:** 0:35 to 1:00

Teach these as operational signals.

| Pod State | Meaning | First Place to Look |
|---|---|---|
| `Pending` | Pod has not been scheduled or started | `kubectl describe pod` |
| `Running` | Container process is running | Check readiness, logs, and app behavior |
| `ImagePullBackOff` | Kubernetes cannot pull the image | Events in `kubectl describe pod` |
| `CrashLoopBackOff` | Container starts, fails, and restarts repeatedly | `kubectl logs` and `kubectl logs --previous` |
| `CreateContainerConfigError` | Kubernetes cannot create the container config | `kubectl describe pod` |
| `ErrImagePull` | Initial image pull failed | Events in `kubectl describe pod` |
| `OOMKilled` (often inside `CrashLoopBackOff`) | Container exceeded its memory limit and the kernel killed it (exit code 137) | `kubectl describe pod` → `Last State: Terminated, Reason: OOMKilled` |

Key teaching point:

`OOMKilled` is sneaky: at the top level the pod usually shows `CrashLoopBackOff` (the symptom), but the *root cause* only appears in `kubectl describe pod` under `Last State: Terminated → Reason: OOMKilled → Exit Code: 137`. Always read `Last State`, not just `STATUS`. Exit code 137 = 128 + signal 9 (SIGKILL).

A pod status is not the full diagnosis. It tells the engineer where to investigate next.

---

### Segment 4: Core Commands and Decision Logic  
**Time:** 1:00 to 1:25

Do not teach commands as memorization. Teach them as questions.

| Question | Command | Why We Use It |
|---|---|---|
| What is failing? | `kubectl get pods` | Shows status, readiness, restarts, and age |
| What does Kubernetes know about the pod? | `kubectl describe pod <pod>` | Shows config, node placement, events, probes, and errors |
| What did the application say before it failed? | `kubectl logs <pod>` | Shows container stdout/stderr |
| What did the previous crashed container say? | `kubectl logs <pod> --previous` | Useful for `CrashLoopBackOff` |
| What happened recently in the namespace? | `kubectl get events --sort-by=.metadata.creationTimestamp` | Shows recent cluster activity and error timeline |
| Did the deployment finish? | `kubectl rollout status deployment/<name>` | Confirms rollout progress |
| What changed across rollouts? | `kubectl rollout history deployment/<name>` | Shows deployment revision history |
| How much CPU/memory is the pod actually using? | `kubectl top pod <pod>` | Live resource usage (requires metrics-server; on EKS it is an add-on) |
| Why can't I exec into this pod (no shell, distroless)? | `kubectl debug -it <pod> --image=busybox:1.36 --target=<container>` | Attaches an ephemeral debug container that shares the target's process namespace |

Instructor note:

Make students explain the “why” behind each command before running it.

> 2026 note — debugging shell-less images: Many modern images are distroless or `scratch`-based and ship **no shell**, so `kubectl exec -it <pod> -- sh` fails with `exec: "sh": executable file not found`. The current answer is `kubectl debug`, which injects an *ephemeral container* (its own image, e.g. `busybox`) into the running pod without restarting it. With `--target=<container>` and process-namespace sharing you can inspect the target's `/proc`, sockets, and environment. Ephemeral containers are GA and are the senior-level way to troubleshoot minimal images.

> 2026 note — `kubectl top` and metrics-server: `kubectl top pod` / `kubectl top node` read from **metrics-server**, which is not installed by default on kind/minikube and is an add-on on EKS. If `kubectl top` returns `error: Metrics API not available`, install metrics-server first (`kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml`; on kind/minikube you may need `--kubelet-insecure-tls`). Resource diagnosis still works without it via `kubectl describe pod` (shows requests/limits and `OOMKilled`/`Reason`), but `kubectl top` is the fastest live read.

---

## 7. Instructor Talking Points

Use these throughout the class:

- A failed deployment is not always a Kubernetes platform failure.
- `kubectl get pods` tells you where to start, not where to stop.
- Events explain what Kubernetes tried to do.
- Logs explain what the application did.
- If the image never pulled, there may be no application logs.
- If the container starts and crashes, logs are usually very important.
- A fix is not complete until we validate recovery.
- In EKS, start with Kubernetes evidence first, then move to AWS services such as ECR, IAM, or CloudWatch if needed.
- Good troubleshooting produces a clear explanation, not just a fixed pod.

---

## 8. Whiteboard Explanation

### Whiteboard Title

**Evidence-Based Kubernetes Troubleshooting**

```text
Production symptom:
"New deployment failed"
        |
        v
Step 1: What is failing?
kubectl get pods
kubectl get deployments
        |
        v
Step 2: What state is the pod in?
ImagePullBackOff?
CrashLoopBackOff?
Pending?
CreateContainerConfigError?
Running but not Ready?
        |
        v
Step 3: What does Kubernetes say?
kubectl describe pod <pod-name>
Check Events
        |
        v
Step 4: What does the app say?
kubectl logs <pod-name>
kubectl logs <pod-name> --previous
        |
        v
Step 5: What does the YAML say?
Image, tag, command, env vars, probes, resources
        |
        v
Step 6: Fix the smallest confirmed issue
kubectl apply -f fixed.yaml
        |
        v
Step 7: Validate
kubectl rollout status deployment/<name>
kubectl get pods
kubectl logs <pod-name>
```

### Whiteboard Summary

```text
Status = symptom
Events = Kubernetes evidence
Logs = application evidence
Manifest = intended configuration
Validation = proof of recovery
```

---

## 9. Instructor Demo Guide

# Instructor Demo: Failed Deployment After New Image Release

## Demo Goal

Model a realistic troubleshooting process using one main failure: a bad image tag causing `ImagePullBackOff`.

This demo should be instructor-facing and guided. Students observe the decision-making process.

## Demo Story

> The app team released a new image tag called `v2.0.1`. The pipeline deployed the manifest, but the pod is not becoming ready. We are the DevOps/SRE team asked to investigate.

---

## Demo Setup

Create namespace:

```bash
kubectl create namespace week12-demo
kubectl config set-context --current --namespace=week12-demo
```

Create `demo-bad-image.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payments-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: payments-api
  template:
    metadata:
      labels:
        app: payments-api
    spec:
      containers:
      - name: payments-api
        image: nginx:not-a-real-release
        ports:
        - containerPort: 80
```

Apply:

```bash
kubectl apply -f demo-bad-image.yaml
```

Expected:

```text
deployment.apps/payments-api created
```

---

## Demo Step 1: Check Current State

Run:

```bash
kubectl get pods
```

Expected:

```text
NAME                            READY   STATUS             RESTARTS   AGE
payments-api-xxxxxxxxxx-xxxxx   0/1     ImagePullBackOff   0          1m
```

Instructor says:

> We now have our first signal. The pod is not crashing. It is not pending. Kubernetes is telling us it cannot pull the image.

---

## Demo Step 2: Inspect Pod Details

Run:

```bash
kubectl describe pod <payments-api-pod-name>
```

Point students to the Events section.

Expected clue:

```text
Failed to pull image "nginx:not-a-real-release"
manifest for nginx:not-a-real-release not found
```

Instructor says:

> This is Kubernetes evidence. It tells us the image tag does not exist. This is not a CPU issue, not a Service issue, and not a pod scheduling issue.

---

## Demo Step 3: Explain AWS/EKS Connection

In EKS, a similar issue may happen with Amazon ECR.

Possible EKS causes:

- Wrong ECR image URI
- Wrong image tag
- Image was not pushed
- Node cannot authenticate to ECR
- IAM permissions are missing
- Image pull secret missing for non-ECR private registry

Instructor says:

> In a real EKS environment, after seeing `ImagePullBackOff`, we may check ECR, IAM permissions, image tag, and whether the pipeline pushed the image successfully.

---

## Demo Step 4: Fix the Manifest

Edit:

```yaml
image: nginx:1.25
```

Apply:

```bash
kubectl apply -f demo-bad-image.yaml
```

Validate:

```bash
kubectl rollout status deployment/payments-api
kubectl get pods
```

Expected:

```text
deployment "payments-api" successfully rolled out
```

```text
NAME                            READY   STATUS    RESTARTS   AGE
payments-api-xxxxxxxxxx-xxxxx   1/1     Running   0          1m
```

Instructor says:

> We fixed the confirmed root cause. Now we validate. In production, we would also run a smoke test and check monitoring.

---

## Demo Cleanup

```bash
kubectl delete namespace week12-demo
```

---

## 10. Instructor Facilitation Notes

During the demo and lab, ask these questions repeatedly:

- What is the symptom?
- What evidence do we have?
- Is this Kubernetes-level evidence or application-level evidence?
- Which command should we run next?
- What root cause does the output suggest?
- What is the smallest safe fix?
- How do we validate that the issue is resolved?

When students get stuck, do not immediately give the answer. Point them back to the troubleshooting flow.

---

## 11. Common Student Confusion Points

| Confusion | Instructor Correction |
|---|---|
| “The pod is broken, so I should check logs first.” | Not always. If the image never pulled, there are no app logs. Start with status and describe. |
| “`Running` means healthy.” | Not always. A pod can run but fail readiness or serve errors. |
| “`CrashLoopBackOff` is a Kubernetes bug.” | Usually the app or startup command is failing. Kubernetes is just restarting it. |
| “`ImagePullBackOff` means Docker is broken.” | Usually the image name, tag, registry auth, or permissions are wrong. |
| “Applying YAML means the issue is fixed.” | No. Always validate with rollout status, pod readiness, and logs if needed. |
| “Events and logs are the same.” | Events are Kubernetes platform messages. Logs are application/container output. |
| “`Pending` means app code failed.” | Usually scheduling or resource constraints, not app code. |

---

## 12. Enterprise Context

In an enterprise EKS environment, this class maps to real incidents like:

- CI/CD pipeline deploys an image tag that was never pushed to ECR.
- A developer changes a startup command and the app enters `CrashLoopBackOff`.
- A Secret or ConfigMap is renamed and pods fail with configuration errors.
- A deployment has resource requests too high for available nodes.
- A readiness probe blocks traffic after a release.
- On-call engineers need to determine if the issue belongs to the app team, platform team, or cloud team.

Students should learn to communicate findings in this format:

```text
Impact:
The payments-api deployment is unavailable in the test namespace.

Symptom:
Pods are in ImagePullBackOff.

Evidence:
kubectl describe pod shows the image tag does not exist.

Root cause:
The deployment references nginx:not-a-real-release.

Fix:
Updated the image tag to nginx:1.25 and reapplied the manifest.

Validation:
Deployment rolled out successfully and pod is Running 1/1.
```

---

# SECTION B: Student Class Packet

---

## 1. Student-Facing Class Overview

Today you will learn how to troubleshoot Kubernetes workload failures using a repeatable process.

You will investigate:

- failed pods
- failed deployments
- image pull problems
- crashing containers
- missing configuration
- Kubernetes events
- container logs
- rollout status

The goal is not just to fix a broken pod. The goal is to explain what happened, why it happened, how you fixed it, and how you confirmed recovery.

---

## 2. Key Terms

| Term | Meaning |
|---|---|
| Pod | Runs one or more containers |
| Deployment | Manages pod replicas and rollout behavior |
| Image | Container package used to start the app |
| Image tag | Version label for an image |
| Event | Kubernetes message showing what happened to a resource |
| Logs | Output from the application/container |
| `ImagePullBackOff` | Kubernetes cannot pull the image |
| `CrashLoopBackOff` | Container starts, crashes, and restarts repeatedly |
| `Pending` | Pod cannot be scheduled or started yet |
| `CreateContainerConfigError` | Kubernetes cannot create the container due to bad or missing config |
| Readiness probe | Decides whether a pod should receive traffic |
| Liveness probe | Decides whether Kubernetes should restart a container |

---

## 3. Kubernetes Troubleshooting Mental Model

Use this model during every lab and production issue:

```text
1. What is the current status?
2. What does Kubernetes say happened?
3. What does the application log say?
4. What does the manifest say should happen?
5. What is the smallest safe fix?
6. How do I prove it is fixed?
```

Do not guess. Follow the evidence.

---

## 4. Command Reference Table

| Command | Why You Use It |
|---|---|
| `kubectl get pods` | See pod status, readiness, restarts, and age |
| `kubectl get pods -o wide` | See node placement and pod IPs |
| `kubectl get deployments` | Check deployment readiness |
| `kubectl describe pod <pod>` | View pod details and Kubernetes events |
| `kubectl logs <pod>` | View current container logs |
| `kubectl logs <pod> --previous` | View logs from a previously crashed container |
| `kubectl get events --sort-by=.metadata.creationTimestamp` | View recent Kubernetes events in order |
| `kubectl rollout status deployment/<name>` | Check deployment rollout progress |
| `kubectl rollout history deployment/<name>` | View rollout revision history |
| `kubectl top pod <pod>` | Live CPU/memory usage (needs metrics-server) |
| `kubectl debug -it <pod> --image=busybox:1.36 --target=<container>` | Attach an ephemeral debug container to a shell-less pod |
| `kubectl delete namespace <name>` | Clean up lab resources |

---

## 4b. Debugging Pods With No Shell (`kubectl debug`)

Modern production images are often **distroless** or `scratch`-based and contain no shell, so this fails:

```bash
kubectl exec -it <pod> -- sh
# error: exec: "sh": executable file not found in $PATH
```

The current way to get a shell *next to* that container is an **ephemeral container** injected with `kubectl debug`:

```bash
kubectl debug -it <pod> --image=busybox:1.36 --target=<container-name>
```

What this does:

- Adds a temporary `busybox` container to the running pod (no restart of your app).
- `--target=<container-name>` shares the target container's process namespace, so you can see its processes and, on many setups, its `/proc/<pid>/root` filesystem.
- The ephemeral container disappears when you exit; it never becomes part of the Deployment spec.

Inside, you can use the tools from the debug image (not the app image):

```sh
ps aux
wget -qO- http://localhost:80
nslookup my-service
```

Use this in the OOMKilled and Pending labs only conceptually (those images have a shell), but practice it now so you can troubleshoot the distroless images you will build in the container week.

---

## 5. Guided Lab

# Lab 12.1: Troubleshooting Broken Kubernetes Workloads

## Lab Goal

You will **reproduce and then fix** five broken Kubernetes workloads. The point is not just to apply a fix — it is to *cause* each failure, gather the evidence that proves the root cause, then make the smallest safe change:

1. Easy: bad image tag (`ImagePullBackOff`)  
2. Medium: crashing container (`CrashLoopBackOff`)  
3. Challenge: missing configuration (`CreateContainerConfigError`)  
4. Scheduling: unschedulable pod (`Pending` from an oversized resource request)  
5. Runtime: out-of-memory kill (`OOMKilled`, exit code 137)  

## Estimated Time

50 minutes

---

## Lab Setup

Create a namespace:

```bash
kubectl create namespace week12-lab
kubectl config set-context --current --namespace=week12-lab
```

Expected:

```text
namespace/week12-lab created
Context modified.
```

---

## Part 1: Easy Issue, Bad Image Tag

Create `easy-bad-image.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inventory-web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: inventory-web
  template:
    metadata:
      labels:
        app: inventory-web
    spec:
      containers:
      - name: web
        image: nginx:not-a-real-tag
        ports:
        - containerPort: 80
```

Apply:

```bash
kubectl apply -f easy-bad-image.yaml
```

Check status:

```bash
kubectl get pods
```

Expected clue:

```text
STATUS             RESTARTS
ImagePullBackOff   0
```

Investigate:

```bash
kubectl describe pod <pod-name>
```

Look for:

```text
Failed to pull image
manifest unknown
```

### Fix

Change:

```yaml
image: nginx:not-a-real-tag
```

To:

```yaml
image: nginx:1.25
```

Apply and validate:

```bash
kubectl apply -f easy-bad-image.yaml
kubectl rollout status deployment/inventory-web
kubectl get pods
```

Success looks like:

```text
inventory-web-xxxxxxxxxx-xxxxx   1/1   Running   0
```

---

## Part 2: Medium Issue, Crashing Container

Create `medium-crashloop.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: reports-worker
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reports-worker
  template:
    metadata:
      labels:
        app: reports-worker
    spec:
      containers:
      - name: worker
        image: busybox:1.36
        command: ["sh", "-c", "echo Starting report worker; exit 1"]
```

Apply:

```bash
kubectl apply -f medium-crashloop.yaml
```

Check status:

```bash
kubectl get pods
```

Expected clue:

```text
STATUS             RESTARTS
CrashLoopBackOff   3
```

Investigate:

```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs <pod-name> --previous
```

Question:

Why is the container restarting?

### Fix

Change the command to keep the container running:

```yaml
command: ["sh", "-c", "echo Report worker is running; sleep 3600"]
```

Apply and validate:

```bash
kubectl apply -f medium-crashloop.yaml
kubectl rollout status deployment/reports-worker
kubectl get pods
```

---

## Part 3: Challenge Issue, Missing ConfigMap

> How this object works (1-minute primer): A **ConfigMap** is a Kubernetes object that holds non-secret configuration as key/value pairs. A pod can read a key as an environment variable using `valueFrom.configMapKeyRef` (name = the ConfigMap, key = the entry inside it). If the ConfigMap or key does not exist when the container is created, Kubernetes cannot build the container's environment and the pod stops at `CreateContainerConfigError` — the container never even starts, so there are no application logs to read. The evidence lives in `kubectl describe pod` and the namespace events, not in `kubectl logs`.

Create `challenge-missing-config.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: orders-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: orders-api
  template:
    metadata:
      labels:
        app: orders-api
    spec:
      containers:
      - name: api
        image: busybox:1.36
        command: ["sh", "-c", "echo APP_ENV=$APP_ENV; sleep 3600"]
        env:
        - name: APP_ENV
          valueFrom:
            configMapKeyRef:
              name: orders-config
              key: APP_ENV
```

Apply:

```bash
kubectl apply -f challenge-missing-config.yaml
```

Check status:

```bash
kubectl get pods
```

Expected clue:

```text
STATUS
CreateContainerConfigError
```

Investigate:

```bash
kubectl describe pod <pod-name>
kubectl get events --sort-by=.metadata.creationTimestamp
```

Look for:

```text
configmap "orders-config" not found
```

### Fix

Create the missing ConfigMap:

```bash
kubectl create configmap orders-config --from-literal=APP_ENV=dev
```

Validate:

```bash
kubectl rollout status deployment/orders-api
kubectl get pods
```

---

## Part 4: Scheduling Issue, Pending Pod (Oversized Resource Request)

> How this object works (1-minute primer): Every container can declare `resources.requests` — the amount of CPU/memory the scheduler must *reserve* on a node before the pod can be placed. The scheduler looks for a node with that much **allocatable** capacity free. If no node qualifies, the pod stays `Pending` forever and the container never starts. This is a *scheduling* failure, not an application failure, so there are no logs — the evidence is in the pod's Events.

This lab forces a Pending pod by requesting far more memory than any lab node has. `1000Gi` is intentionally absurd so it fails on any cluster (kind, minikube, or a small EKS node group).

Create `pending-too-big.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: analytics-job
spec:
  replicas: 1
  selector:
    matchLabels:
      app: analytics-job
  template:
    metadata:
      labels:
        app: analytics-job
    spec:
      containers:
      - name: analytics
        image: busybox:1.36
        command: ["sh", "-c", "echo analytics running; sleep 3600"]
        resources:
          requests:
            memory: "1000Gi"
            cpu: "500m"
```

Apply:

```bash
kubectl apply -f pending-too-big.yaml
```

Check status:

```bash
kubectl get pods
```

Expected clue:

```text
NAME                             READY   STATUS    RESTARTS   AGE
analytics-job-xxxxxxxxxx-xxxxx   0/1     Pending   0          30s
```

Investigate — note that `kubectl logs` is useless here (no container started). Use describe and events:

```bash
kubectl describe pod <pod-name>
kubectl get events --sort-by=.metadata.creationTimestamp
```

Look for the scheduler verdict in the Events section:

```text
Warning  FailedScheduling  default-scheduler
0/1 nodes are available: 1 Insufficient memory.
preemption: 0/1 nodes are available: 1 No preemption victims found.
```

Question:

Is this an application bug, a node problem, or a request that no node can satisfy?

### Fix

Lower the memory request to something the node can actually grant (start small and raise only if needed):

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "100m"
```

Apply and validate:

```bash
kubectl apply -f pending-too-big.yaml
kubectl rollout status deployment/analytics-job
kubectl get pods
```

Success looks like:

```text
analytics-job-xxxxxxxxxx-xxxxx   1/1   Running   0
```

> Other Pending causes to recognize (table → lab next time): a `nodeSelector` or `affinity` rule that matches no node, an unsatisfied `taint` with no matching toleration, or no nodes Ready at all. The diagnostic is always the same: `kubectl describe pod` → read the `FailedScheduling` event, then `kubectl get nodes` / `kubectl describe node` to see why the node was rejected.

---

## Part 5: Runtime Issue, OOMKilled Container (Exit Code 137)

> How this object works (1-minute primer): `resources.limits.memory` is a **hard ceiling** enforced by the Linux kernel cgroup. If the container tries to use more memory than its limit, the kernel kills the process with SIGKILL. Kubernetes records this as `Reason: OOMKilled` and exit code `137` (128 + signal 9). At the top level you usually see `CrashLoopBackOff` — the *symptom* — because the deployment keeps restarting the killed container. The *root cause* is only visible in `kubectl describe pod` under `Last State`.

This lab sets a tiny 32Mi memory limit and then runs a process that tries to allocate ~250MB, guaranteeing an OOM kill.

Create `oom-killed.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memory-hog
spec:
  replicas: 1
  selector:
    matchLabels:
      app: memory-hog
  template:
    metadata:
      labels:
        app: memory-hog
    spec:
      containers:
      - name: hog
        image: polinux/stress:1.0.4
        command: ["stress"]
        args: ["--vm", "1", "--vm-bytes", "250M", "--vm-hang", "0"]
        resources:
          requests:
            memory: "32Mi"
          limits:
            memory: "32Mi"
```

> Image note: `polinux/stress` ships the `stress` tool and is the standard image used in the upstream Kubernetes "Assign Memory Resources" docs to demonstrate OOMKills. If your environment blocks Docker Hub pulls, any image that allocates memory (or a `python:3.12-slim` running `python -c "x='a'*300_000_000; input()"`) works the same way.

Apply:

```bash
kubectl apply -f oom-killed.yaml
```

Check status (you may need to wait ~30s and re-run; the container is killed and restarted repeatedly):

```bash
kubectl get pods
```

Expected clue:

```text
NAME                          READY   STATUS             RESTARTS   AGE
memory-hog-xxxxxxxxxx-xxxxx   0/1     CrashLoopBackOff   3          90s
```

Investigate — the top-level status says CrashLoop, so read `Last State` to find the real cause:

```bash
kubectl describe pod <pod-name>
```

Look for:

```text
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
```

If metrics-server is installed, confirm pressure live (it may show usage near the limit just before the kill):

```bash
kubectl top pod <pod-name>
```

Question:

The app didn't "crash" in the normal sense — what actually killed it, and is the fix more memory or less memory usage?

### Fix

There are two legitimate fixes; choose based on what the app *actually* needs. For this lab the app genuinely needs ~250MB, so raise the limit to fit it (right-sizing):

```yaml
resources:
  requests:
    memory: "300Mi"
  limits:
    memory: "300Mi"
```

Apply and validate:

```bash
kubectl apply -f oom-killed.yaml
kubectl get pods
kubectl describe pod <pod-name>
```

Success: the pod stays `1/1 Running`, `RESTARTS` stops climbing, and `Last State` no longer shows `OOMKilled`.

> Production judgment: raising the limit is correct only when the workload truly needs the memory. If a process is leaking, raising the limit just delays the kill — the right fix is to cap the workload's usage (tune the app, set `--vm-bytes` lower, add `GOMEMLIMIT`/JVM `-Xmx`, etc.). Seniors decide between "give it more headroom" and "stop it using so much" using evidence from `kubectl top` and app metrics, not by reflexively bumping limits.

---

## Final Lab Validation

Run:

```bash
kubectl get deployments
kubectl get pods
```

Expected:

```text
NAME             READY   UP-TO-DATE   AVAILABLE
inventory-web    1/1     1            1
reports-worker   1/1     1            1
orders-api       1/1     1            1
analytics-job    1/1     1            1
memory-hog       1/1     1            1
```

---

## Cleanup

```bash
kubectl delete namespace week12-lab
```

---

## 6. Independent Troubleshooting Challenge

## Scenario

The application team says:

> “The new deployment finished, but the application is not healthy. We only changed the container startup behavior.”

Starting evidence:

```text
NAME                           READY   STATUS             RESTARTS   AGE
customer-api-xxxxxxxxxx-xxxxx  0/1     CrashLoopBackOff   6          5m
```

Your task:

1. Identify the root cause.
2. List the commands you would run.
3. Explain what output you expect from each command.
4. Describe the fix.
5. Describe how you would validate recovery.
6. Write a short incident update for the application team.

Suggested command set:

```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs <pod-name> --previous
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl rollout status deployment/<deployment-name>
```

---

## 7. Reflection Questions

Answer these after the lab:

1. Which command gave you the first clue?
2. Which command gave you the root cause?
3. When are logs useful?
4. When are logs not useful?
5. What is the difference between Kubernetes events and container logs?
6. How would this troubleshooting process apply in EKS?
7. How would you explain `CrashLoopBackOff` to a developer?
8. Why is validation important after applying a fix?

---

## 8. Homework Assignment

# Homework: Kubernetes Pod Troubleshooting Checklist

Create a Markdown file named:

```text
week12-class1-troubleshooting-checklist.md
```

Your checklist must include:

1. Troubleshooting flow from symptom to validation
2. Commands for checking pod status
3. Commands for checking deployment status
4. Commands for checking pod details
5. Commands for checking logs
6. Commands for checking previous logs
7. Commands for checking events
8. Common causes of `ImagePullBackOff`
9. Common causes of `CrashLoopBackOff`
10. Common causes of `Pending` (and the `FailedScheduling` evidence)
11. Common causes of `CreateContainerConfigError`
12. How to recognize `OOMKilled` (where to look: `Last State`, exit code 137) and how to decide between raising the limit and reducing usage
13. When and how to use `kubectl debug` for shell-less (distroless) images
14. How to validate a fixed workload
15. One short paragraph explaining how this applies to AWS EKS

Example structure:

```markdown
# Kubernetes Pod Troubleshooting Checklist

## Step 1: Check status
Command:
Explanation:

## Step 2: Describe the pod
Command:
Explanation:

## Step 3: Check logs
Command:
Explanation:

## Step 4: Check events
Command:
Explanation:

## Step 5: Identify root cause

## Step 6: Fix and validate

## EKS notes
```

---

# SECTION C: Assessment and Validation

---

## 1. Knowledge Check With Answer Key

### Question 1

Which command should you usually run first when investigating unhealthy pods?

A. `kubectl delete pod`  
B. `kubectl get pods`  
C. `kubectl create deployment`  
D. `kubectl config view`

**Answer:** B  
**Explanation:** `kubectl get pods` gives the first view of pod status, readiness, restarts, and age.

---

### Question 2

A pod shows `ImagePullBackOff`. What is the most likely category of issue?

A. Container image or registry issue  
B. Service selector issue  
C. DNS issue  
D. Ingress path issue

**Answer:** A  
**Explanation:** `ImagePullBackOff` usually means Kubernetes cannot pull the image due to image name, tag, registry, or permissions.

---

### Question 3

Why might `kubectl logs` not show useful output for `ImagePullBackOff`?

A. Logs are disabled by default  
B. The container never started  
C. The namespace is missing  
D. The pod is running normally

**Answer:** B  
**Explanation:** If Kubernetes cannot pull the image, the container never starts, so application logs are unavailable.

---

### Question 4

What does `CrashLoopBackOff` mean?

A. Kubernetes cannot pull the image  
B. The pod is scheduled but has no Service  
C. The container starts, exits, and restarts repeatedly  
D. The node is deleted

**Answer:** C  
**Explanation:** `CrashLoopBackOff` means the container keeps failing after startup.

---

### Question 5

Which command is especially useful for seeing why Kubernetes could not create or run a pod?

A. `kubectl describe pod <pod-name>`  
B. `kubectl version`  
C. `kubectl get namespaces`  
D. `kubectl config current-context`

**Answer:** A  
**Explanation:** `kubectl describe pod` shows pod details and events.

---

### Question 6

When is `kubectl logs <pod> --previous` useful?

A. When checking previous crashed container logs  
B. When creating a ConfigMap  
C. When exposing a Service  
D. When changing namespace

**Answer:** A  
**Explanation:** `--previous` shows logs from the previous instance of a restarted container.

---

### Question 7

A pod is stuck in `Pending`. What should you suspect first?

A. Wrong HTTP path  
B. Scheduling or resource issue  
C. Wrong Service type  
D. Bad DNS record

**Answer:** B  
**Explanation:** `Pending` commonly points to scheduling constraints, unavailable nodes, or insufficient resources.

---

### Question 8

What is the purpose of validating after a fix?

A. To prove the workload recovered  
B. To delete old logs  
C. To skip postmortems  
D. To avoid using Git

**Answer:** A  
**Explanation:** A fix is not complete until recovery is confirmed.

---

### Question 9

In EKS, if a pod cannot pull an image from ECR, what should you check after confirming `ImagePullBackOff`?

A. IAM permissions, image URI, image tag, and ECR repository  
B. Route 53 hosted zone only  
C. S3 lifecycle policy  
D. CloudFront cache

**Answer:** A  
**Explanation:** ECR image pull issues can involve image tag, URI, repository, authentication, or IAM permissions.

---

### Question 10

What is the best troubleshooting mindset?

A. Edit YAML until the pod works  
B. Delete the namespace immediately  
C. Follow evidence from status, events, logs, and manifests  
D. Assume Kubernetes is broken

**Answer:** C  
**Explanation:** Production troubleshooting should be evidence-based.

---

### Question 11

A pod shows `CrashLoopBackOff`. In `kubectl describe pod` you see `Last State: Terminated, Reason: OOMKilled, Exit Code: 137`. What is the root cause?

A. The image tag does not exist  
B. The container exceeded its memory limit and the kernel killed it  
C. The Service selector does not match  
D. DNS resolution failed

**Answer:** B  
**Explanation:** `OOMKilled` with exit code 137 (128 + SIGKILL) means the container hit its `limits.memory` ceiling. The top-level `CrashLoopBackOff` is only the symptom; the cause is in `Last State`.

---

### Question 12

A pod is stuck in `Pending` and `kubectl describe pod` shows `FailedScheduling: 0/1 nodes are available: 1 Insufficient memory`. Why does `kubectl logs` return nothing useful?

A. Logs are disabled in Pending  
B. The container was never scheduled or started, so there is no application output  
C. The namespace is wrong  
D. metrics-server is not installed

**Answer:** B  
**Explanation:** `Pending` is a scheduling failure — the container never started, so there are no logs. The evidence is the scheduler's `FailedScheduling` event, not logs.

---

## 2. Lab Success Criteria

Students successfully complete the lab when they can show:

| Requirement | Success Criteria |
|---|---|
| Namespace created | `week12-lab` exists during lab |
| Bad image issue fixed | `inventory-web` is `1/1 Running` |
| CrashLoop issue fixed | `reports-worker` is `1/1 Running` |
| Missing ConfigMap issue fixed | `orders-api` is `1/1 Running` |
| Pending issue reproduced and fixed | `analytics-job` went `Pending` (saw `FailedScheduling`) then `1/1 Running` after lowering the request |
| OOMKilled issue reproduced and fixed | `memory-hog` showed `Reason: OOMKilled` / exit 137, then `1/1 Running` after right-sizing memory |
| Evidence captured | Student notes include command outputs or summarized findings |
| Root cause identified | Student explains what broke and why |
| Validation completed | Student runs `kubectl get pods` and `kubectl rollout status` |
| Cleanup completed | Lab namespace deleted after completion |

---

## 3. Troubleshooting Rubric

| Criteria | Excellent | Good | Needs Improvement |
|---|---|---|---|
| Uses troubleshooting flow | Follows status → describe → events/logs → fix → validate | Uses most steps but misses one | Randomly tries fixes |
| Understands pod states | Correctly explains all major states | Explains most states | Confuses pod states |
| Uses commands correctly | Uses commands with clear purpose | Uses commands but explanation is limited | Runs commands without understanding |
| Identifies root cause | Clearly identifies exact cause | Identifies general issue area | Misidentifies root cause |
| Applies safe fix | Makes minimal correct change | Fix works but explanation is weak | Fix is accidental or unsafe |
| Validates recovery | Confirms rollout and pod health | Checks only pod status | Does not validate |
| Communicates clearly | Explains symptom, evidence, root cause, fix, validation | Explains most items | Explanation is unclear |

---

## 4. Student Outcome Checklist

By the end of class, students should be able to:

- [ ] Explain the Kubernetes troubleshooting flow.
- [ ] Use `kubectl get pods` to identify workload status.
- [ ] Use `kubectl describe pod` to find Kubernetes-level evidence.
- [ ] Use `kubectl logs` to inspect application output.
- [ ] Use `kubectl logs --previous` for restarted containers.
- [ ] Use `kubectl get events` to view recent Kubernetes events.
- [ ] Diagnose `ImagePullBackOff`.
- [ ] Diagnose `CrashLoopBackOff`.
- [ ] Diagnose `CreateContainerConfigError`.
- [ ] Reproduce and diagnose a `Pending` pod from an oversized resource request (read the `FailedScheduling` event).
- [ ] Reproduce and diagnose an `OOMKilled` container (read `Last State`, recognize exit code 137).
- [ ] Use `kubectl debug` to attach an ephemeral container to a shell-less pod.
- [ ] Use `kubectl top` (with metrics-server) to read live resource usage.
- [ ] Fix simple YAML or configuration issues.
- [ ] Validate that a deployment recovered.
- [ ] Explain a workload issue using symptom, evidence, root cause, fix, and validation.
- [ ] Connect local troubleshooting flow to AWS EKS scenarios.

---

## 5. Class Completion Checklist

## Instructor Checklist

- [ ] Reviewed Deployment, ReplicaSet, Pod, and Container relationship.
- [ ] Introduced the enterprise failed-deployment scenario.
- [ ] Taught the troubleshooting mental model.
- [ ] Explained common pod failure states.
- [ ] Demonstrated `kubectl get pods`.
- [ ] Demonstrated `kubectl describe pod`.
- [ ] Demonstrated `kubectl logs`.
- [ ] Demonstrated `kubectl get events`.
- [ ] Ran the instructor demo.
- [ ] Guided students through the progressive lab (including Pending and OOMKilled reproduction).
- [ ] Demonstrated reading `Last State` / exit code 137 for OOMKilled and the `FailedScheduling` event for Pending.
- [ ] Introduced `kubectl debug` ephemeral containers and `kubectl top`.
- [ ] Reviewed lab findings as a group.
- [ ] Connected the class to EKS, ECR, IAM, and CloudWatch context.
- [ ] Assigned the homework checklist.

## Student Checklist

- [ ] Participated in prerequisite review.
- [ ] Understood the troubleshooting flow.
- [ ] Completed easy lab issue: bad image tag.
- [ ] Completed medium lab issue: crashing container.
- [ ] Completed challenge lab issue: missing ConfigMap.
- [ ] Completed Pending lab: oversized resource request.
- [ ] Completed OOMKilled lab: memory limit too low (exit 137).
- [ ] Captured root cause notes.
- [ ] Validated all workloads are healthy.
- [ ] Cleaned up lab resources.
- [ ] Started homework troubleshooting checklist.

---

# Final Instructor Wrap-Up

Close the class with this message:

> Today you learned the first production-grade Kubernetes troubleshooting skill: follow the evidence. You started with pod status, used events to understand what Kubernetes was doing, used logs to understand what the application was doing, fixed the confirmed problem, and validated recovery. In the next class, we will continue from workload troubleshooting into Services, endpoints, DNS, probes, and traffic-routing issues.

---

## Class Artifacts & Validation

This class is backed by two on-disk modules. Workload-failure diagnosis (OOMKilled,
never-Ready, hardened reference) comes from [`labs/kubernetes-fundamentals/`](../../labs/kubernetes-fundamentals/);
the failed-image-release storyline (a new image release breaks the rollout) is the
rollout/rollback drill in [`labs/k8s-production-ops/`](../../labs/k8s-production-ops/).
All commands below were run in this environment (kubectl v1.34.2, a live `kind`
cluster, `kubeconform` on `PATH`).

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/kubernetes-fundamentals/solution/base/deployment.yaml | kubernetes | Healthy reference Deployment (probes, requests+limits, hardened securityContext) — the "good" state students restore broken workloads to | `./validate.sh` (kustomize render + kubeconform -strict + live apply → 2/2 Ready) | PASS — `cluster: apply base into ns lab-k8s-validate + 2/2 Ready` |
| 2 | labs/kubernetes-fundamentals/broken/deployment-oomkilled.yaml | kubernetes | Troubleshooting fixture: `limits.memory: 12Mi` → OOMKilled crash loop (exit 137); the class's OOMKilled lab | `./validate.sh` (live: reproduce on cluster) | PASS — `cluster: reproduce OOMKilled fixture (Reason OOMKilled, exit 137)` |
| 3 | labs/kubernetes-fundamentals/tests/test_manifests.py | python (unittest) | Structural answer key: asserts probes, requests+limits, hardening, and that the broken fixtures carry their documented defects | `python3 -m unittest discover -s tests` (run by `./validate.sh`) | PASS — `tests: unittest discover -s tests (structural assertions)` |
| 4 | labs/kubernetes-fundamentals/validate.sh | shell | The module's validation gate (parse, render, tests, kubeconform, live apply + fixture reproduction) | `bash -n validate.sh` then `./validate.sh` | PASS — `== 11 passed, 0 failed, 1 deferred ==` |
| 5 | labs/k8s-production-ops/solution/drills/rollout-rollback.sh | shell | Operates the failed-image-release scenario: ships a bad image tag → `ImagePullBackOff`, `rollout status` fails while old pods keep serving, then `rollout undo` recovers | `bash -n solution/drills/rollout-rollback.sh` + `shellcheck`; live `RUN_LIVE=1 ./solution/drills/run-drills.sh` | PASS (static) — see labs/k8s-production-ops/evidence/LIVE-OPS-EVIDENCE.txt (Drill 1, live) |

Live operation evidence (real cluster output, not prose) is committed at
[`labs/k8s-production-ops/evidence/LIVE-OPS-EVIDENCE.txt`](../../labs/k8s-production-ops/evidence/LIVE-OPS-EVIDENCE.txt)
(Drill 1: `ImagePullBackOff` then `rollout undo` → 3/3) and reproduced for the
OOMKilled fixture by `kubernetes-fundamentals/validate.sh` (`Reason: OOMKilled, Exit Code: 137`).

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** (Kubernetes manifests, a Python test suite, and shell drill scripts — not just fences).
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured (`kubeconform -strict`, `kubectl kustomize`, live `kind` apply, `unittest`, `bash -n`/`shellcheck`).
- [x] Lab has **starter** (intentionally incomplete `starter/deployment.yaml`) and **solution** (`solution/base/`) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes**.
- [x] **Cleanup/teardown** is provided and idempotent (live gates run in a throwaway namespace torn down on exit; `--ignore-not-found` deletes documented).
- [x] **Instructor answer key** exists (the structural `tests/test_manifests.py`, the README "Instructor answer key" + symptom→cause→fix troubleshooting, and the in-class homework/quiz keys).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `broken/deployment-oomkilled.yaml` reproduces OOMKilled/137 live, and the rollout drill injects a real bad-image fault.
- [x] **Expected outputs** are shown for demos and labs (README "Expected results" + captured `validate.sh` and live-evidence output).
- [x] **Cost & security warnings** present (README "Security considerations" / "Cost considerations"; $0, local `kind` only).
- [x] **Cross-references** to the module repos and to Week 11 (deploy) / Week 12 Class 2 (networking) are correct.
- [x] The **artifact manifest** (§4.2) above is present and every path resolves (verified with `ls`).

