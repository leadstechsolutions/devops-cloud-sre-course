# Week 11: Kubernetes Fundamentals
# Class 2 Package

**Week:** 11
**Track:** Unified DevOps · Cloud · SRE Track

> **▶ Runnable lab for this class:** [`labs/kubernetes-fundamentals/`](../../labs/kubernetes-fundamentals/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 11.2: Exposing and Troubleshooting Kubernetes Services

---

## 1. Class Overview

### Class title

**Class 11.2: Exposing and Troubleshooting Kubernetes Services**

### Class purpose

This class teaches students how Kubernetes Services provide stable access to Pods. In Class 1, students deployed an application using a Deployment. In this class, they will learn how to expose that application, validate traffic flow, inspect endpoints, and troubleshoot common Service-related issues.

### How this class builds from Class 1

Class 1 focused on:

- Kubernetes architecture
- Namespaces
- Deployments
- ReplicaSets
- Pods
- Labels and selectors
- Basic `kubectl` inspection

Class 2 continues from there by answering the next practical question:

> “The application is running in Pods, but how do users or other applications reach it?”

Students will connect a Service to the Pods created by a Deployment and learn why labels, selectors, ports, and endpoints matter.

### What students will build, analyze, or practice

Students will:

- Review their Class 1 Deployment
- Create a Kubernetes Service manifest
- Connect a Service to Pods using labels and selectors
- Validate Service endpoints
- Use `kubectl port-forward` to test the application locally
- Troubleshoot broken Service selectors and port mappings
- Compare local Kubernetes Service behavior with EKS, AKS, and GKE concepts

---

## 2. Quick Review of Class 1

### Review points

1. Kubernetes runs and manages containerized applications.
2. A Cluster contains Nodes.
3. Nodes run Pods.
4. Pods run containers.
5. A Deployment manages ReplicaSets and Pods.
6. A ReplicaSet maintains the desired number of Pods.
7. Labels identify resources.
8. Selectors match resources based on labels.

### Quick recall questions

1. **What happens when you delete a Pod managed by a Deployment?**  
   Expected answer: Kubernetes creates a replacement Pod to maintain the desired replica count.

2. **What command shows Pods in a namespace?**  
   Expected answer: `kubectl get pods -n <namespace>`

3. **Why do labels and selectors matter?**  
   Expected answer: Kubernetes objects use selectors to find matching resources based on labels.

### Common gaps students may still have from Class 1

| Gap | How It Shows Up | Instructor Bridge |
|---|---|---|
| Confusing Pod and Deployment | Student says “I deployed a Pod” when they created a Deployment | Reinforce Deployment -> ReplicaSet -> Pod |
| Forgetting namespaces | Student runs commands and sees no resources | Remind them to use `-n student-app` or check all namespaces |
| Treating labels as optional | Student does not understand Service selector problems | Explain that labels become critical when Services need to find Pods |
| Thinking Pod IPs are stable | Student wants to connect directly to a Pod IP | Explain Pods are replaceable and need a stable access layer |
| Not reading `kubectl describe` output | Student guesses instead of using evidence | Reinforce evidence-first troubleshooting |

### Bridge into Class 2

Instructor transition:

> “In Class 1, we got the application running. But running is not the same as reachable. Today we will add the Kubernetes networking object that gives stable access to Pods: the Service.”

---

## 3. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** why Kubernetes Services are needed when Pods already exist.
2. **Compare** ClusterIP, NodePort, and LoadBalancer Service types at a beginner level.
3. **Configure** a Kubernetes Service manifest for an existing Deployment.
4. **Validate** that a Service is connected to Pods using endpoints.
5. **Troubleshoot** selector, label, port, and targetPort issues.
6. **Use** `kubectl port-forward` to test an application locally.
7. **Build** a ConfigMap and a Secret and wire them into a Deployment (volume mount and env var).
8. **Expose** an application through an Ingress so it is reachable without port-forward, and **describe** how the Gateway API extends this.
9. **Document** the traffic flow from client to Service to Pod.
10. **Compare** how Services map to AWS EKS, Azure AKS, and Google GKE concepts.

---

## 4. Prerequisites Students Should Already Know

### Required Class 1 knowledge

Students should already understand:

- Cluster
- Node
- Namespace
- Deployment
- ReplicaSet
- Pod
- Container
- Labels
- Selectors
- Basic `kubectl get` and `kubectl describe`

### Required prior concepts

Students should know:

- Basic TCP ports
- Basic HTTP request flow
- Basic YAML formatting
- Basic Docker image concepts
- Basic terminal commands

### Required tools already installed

Students need:

- `kubectl`
- Docker Desktop Kubernetes, kind, or minikube
- VS Code or another text editor
- Terminal
- Browser or `curl`

### Required files, repos, lab outputs, or setup from Class 1

Students should have either:

1. The Class 1 Deployment still running, or
2. The ability to recreate it quickly.

Expected namespace:

```bash
student-app
```

Expected Deployment:

```bash
student-nginx
```

Expected image (the hardened, non-root baseline authored in Class 1):

```yaml
nginxinc/nginx-unprivileged:1.27
```

Expected label:

```yaml
app: student-nginx
```

Note: this lab recreates its own Deployment from scratch in Step 4, so you do not need the exact Class 1 resources still running.

---

## 5. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Service | A Kubernetes object that provides stable access to Pods | Used so apps and users do not connect directly to temporary Pod IPs |
| ClusterIP | Default Service type that exposes the app inside the cluster | Common for internal service-to-service communication |
| NodePort | Exposes a Service on a port of each node | Useful for learning and simple testing, less common as a direct production pattern |
| LoadBalancer | Requests an external cloud load balancer | In EKS, this can create an AWS load balancer |
| Endpoint | The actual Pod IP and port targets behind a Service | Empty endpoints usually mean selector or readiness problems |
| Port | The port exposed by the Service | Example: Service listens on port 80 |
| TargetPort | The port on the Pod or container where traffic is sent | Example: NGINX container listens on targetPort 80 |
| Selector | Matching rule used by a Service to find Pods | If selector does not match Pod labels, traffic has nowhere to go |
| Label | Key-value metadata attached to Pods and other resources | Used for routing, ownership, monitoring, automation, and governance |
| Port-forward | A `kubectl` feature that forwards local traffic to a Kubernetes resource | Useful for local testing without creating a cloud load balancer |
| EndpointSlice | Modern Kubernetes object that tracks network endpoints for Services | Used internally by Kubernetes for scalable Service endpoint tracking |
| ConfigMap | An object holding non-sensitive configuration as key-value data | Mounted as files or injected as env vars so config is decoupled from the image |
| Secret | An object holding sensitive data (base64-encoded, not encrypted by default) | Used for tokens/passwords; enable encryption-at-rest or an external manager in production |
| Ingress | An object that routes external HTTP(S) traffic to Services by host/path | Needs an ingress controller; the standard production exposure path beyond port-forward |
| Ingress controller | The component that implements Ingress rules (e.g. ingress-nginx) | Runs in the cluster and provisions/serves the actual routing |
| Gateway API | The modern, role-oriented successor to Ingress (GatewayClass/Gateway/HTTPRoute) | The 2026 direction for richer routing; expect it in senior interviews |
| NetworkPolicy | A rule that allows/denies pod-to-pod and pod-to-external traffic | Network segmentation; a baseline security control (introduced later) |
| RBAC | Role-based access control: ServiceAccount, Role, RoleBinding | Controls who/what can act in the cluster; least privilege (introduced later) |
| cert-manager | An add-on that issues and renews TLS certificates automatically | Provides the TLS in DNS → LB → Ingress → TLS (introduced later) |

---

## 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| `kubectl` | Main CLI for creating, inspecting, and troubleshooting Kubernetes resources |
| VS Code | Used to edit YAML manifests |
| Terminal | Used to run commands and validate resources |
| Docker Desktop, kind, or minikube | Provides local Kubernetes cluster |
| `curl` | Used to test HTTP response from the application |
| Browser | Optional way to test the local forwarded application |
| YAML | Used to define Deployment and Service desired state |
| Git | Optional for saving manifests and documenting lab work |

---

## 7. AWS Services Used

This class can be completed locally. AWS is introduced conceptually.

| AWS Service | How It Connects |
|---|---|
| Amazon EKS | Managed Kubernetes service where the same Service concepts apply |
| Elastic Load Balancing | Kubernetes `LoadBalancer` Services in EKS can provision AWS load balancers depending on controller and configuration |
| Amazon ECR | Common image registry for workloads deployed to EKS |
| IAM | Controls access to EKS clusters and AWS resources used by workloads |
| CloudWatch | Used later for EKS logs, metrics, and operational visibility |

### Cost warning

Students should not create an AWS EKS cluster or LoadBalancer Service in AWS during this class unless specifically instructed. Cloud load balancers, NAT gateways, and EKS clusters can create cost.

---

## 8. Azure and GCP Comparison Notes

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Managed Kubernetes | EKS | AKS | GKE |
| Cloud load balancer integration | Elastic Load Balancing | Azure Load Balancer / Application Gateway | Google Cloud Load Balancing |
| Container registry | ECR | Azure Container Registry | Artifact Registry |
| Monitoring | CloudWatch | Azure Monitor | Cloud Monitoring |

Instructor note:

> The Service object is Kubernetes-native. EKS, AKS, and GKE all support Services, but each cloud handles external load balancers and identity integration differently.

---

## 9. Time-Boxed Instructor Agenda

| Time | Segment | Focus |
|---:|---|---|
| 0:00 to 0:15 | Review Class 1 | Deployment, Pods, labels, selectors, namespace |
| 0:15 to 0:35 | Why Services exist | Pod IP problem, stable access, internal traffic |
| 0:35 to 1:00 | Service types | ClusterIP, NodePort, LoadBalancer |
| 1:00 to 1:20 | Ports, targetPorts, endpoints | How traffic reaches Pods |
| 1:20 to 1:30 | Break | Short reset |
| 1:30 to 2:00 | Instructor demo | Create Service and test with port-forward |
| 2:00 to 2:35 | Student lab | Deploy app and expose it with a Service |
| 2:35 to 2:50 | Troubleshooting activity | Broken selector and wrong targetPort |
| 2:50 to 3:00 | Discussion, recap, next week preview | Connect to Week 12 troubleshooting |

---

## 10. Instructor Lesson Plan

### Step 1: Start with the Class 1 application

Ask students:

> “At the end of Class 1, we had Pods running. Could a user reliably access those Pods directly?”

Expected answer:

No. Pod IPs are temporary and change when Pods are recreated.

Explain:

> Kubernetes treats Pods as replaceable. A Deployment can delete and recreate Pods anytime. Because of that, we need a stable network object in front of the Pods.

### Step 2: Introduce Kubernetes Services

Explain:

A Service gives a stable name and IP inside the cluster and forwards traffic to matching Pods.

Say:

> “A Service is like a stable front desk for a group of changing Pods.”

Show this simple flow:

```text
Client -> Service -> Pods
```

Then add:

```text
Service uses selector -> Pod labels
```

### Step 3: Teach Service types

Introduce only the beginner-level purpose of each type.

| Type | Beginner Explanation |
|---|---|
| ClusterIP | Internal-only Service inside Kubernetes |
| NodePort | Exposes the Service through a port on each node |
| LoadBalancer | Asks the cloud provider for an external load balancer |

Instructor caution:

Teach Service types first and keep them clear before moving on. We do reach Ingress in the lab (Step 12) so students expose the app for real, not only via port-forward — but keep the controller install mechanical and save deep Ingress/Gateway internals and cloud load balancer specifics for later weeks.

### Step 4: Explain Service selector and endpoints

Show:

```yaml
selector:
  app: student-nginx
```

Then show Pod label:

```yaml
labels:
  app: student-nginx
```

Explain:

> “If these do not match, the Service exists, but it does not know where to send traffic.”

Run or show:

```bash
kubectl get endpoints -n student-app
```

Explain:

Empty endpoints are a major troubleshooting clue.

### Step 5: Walk through Service YAML

Explain each field:

- `apiVersion`
- `kind`
- `metadata.name`
- `metadata.namespace`
- `spec.type`
- `spec.selector`
- `spec.ports.port`
- `spec.ports.targetPort`

Beginner tip:

Tell students to focus on three key connections:

1. Service selector must match Pod labels.
2. Service port is what clients use.
3. targetPort is where the container receives traffic.

### Step 6: Instructor demo

Use the existing Class 1 Deployment or recreate it. Create a Service and validate endpoints.

Pause after creating the Service and ask:

> “How can we tell whether the Service found the Pods?”

Expected answer:

Check endpoints.

### Step 7: Student lab

Students create:

- Namespace
- Deployment
- Service
- Port-forward test

Instructor should watch for:

- Namespace mismatches
- Wrong selector
- Wrong targetPort
- App not running
- Port-forward already in use

### Step 8: Troubleshooting activity

Give students a broken Service manifest.

Let them investigate with:

```bash
kubectl get pods --show-labels
kubectl describe service
kubectl get endpoints
```

Do not immediately tell them the selector is wrong.

### Step 9: Close with production connection

Explain:

> “In production, teams usually do not use port-forward for users. They use Services, Ingress, load balancers, DNS, TLS, and monitoring. But Service-to-Pod routing is one of the first building blocks.”

Bridge to Week 12:

> “Next week, we go deeper into Kubernetes operations and troubleshooting. The same commands from today will become part of your production debugging toolkit.”

---

## 11. Instructor Lecture Notes

### Why Pods need Services

Pods are temporary. Kubernetes may delete and recreate them during:

- Scaling
- Rollouts
- Node failures
- Health check failures
- Manual deletion
- Resource pressure

Each new Pod can receive a new IP address. That means direct Pod IP access is not reliable.

Talking point:

> “If your application depends on a specific Pod IP, your design is fragile.”

A Service solves this by providing a stable access point.

### How a Service finds Pods

A Service does not automatically know which Pods belong to it. It uses selectors.

Example Service selector:

```yaml
selector:
  app: student-nginx
```

Example Pod label:

```yaml
labels:
  app: student-nginx
```

If they match, the Service routes traffic to the Pods.

If they do not match, the Service has no endpoints.

Talking point:

> “Most beginner Kubernetes networking issues are not deep networking issues. They are often label, selector, or port mismatches.”

### ClusterIP

ClusterIP is the default Service type. It exposes the Service inside the cluster.

Use cases:

- App talks to API
- API talks to database proxy
- Internal microservices communicate
- Internal platform services

Talking point:

> “ClusterIP is for inside-the-cluster communication. It is not meant for direct public user traffic.”

### NodePort

NodePort exposes the Service on a high port across nodes.

Use cases:

- Local learning
- Simple testing
- Bare-metal clusters
- Temporary access patterns

Caution:

NodePort is usually not the cleanest enterprise production access model by itself.

Talking point:

> “NodePort helps us learn, but in cloud production environments, teams usually rely on LoadBalancer, Ingress, or gateway patterns.”

### LoadBalancer

LoadBalancer Service type asks the cloud provider to create an external load balancer.

In AWS EKS, this may integrate with AWS load balancing, depending on cluster setup and controllers.

Important cost note:

Cloud load balancers can create cost. Students should avoid creating real cloud load balancers unless the lab specifically requires it.

Talking point:

> “LoadBalancer is where Kubernetes starts connecting directly to cloud infrastructure.”

### Ports and targetPorts

Example:

```yaml
ports:
  - port: 80
    targetPort: 80
```

`port` is the port exposed by the Service.

`targetPort` is where traffic goes on the Pod.

Common error:

Service sends traffic to `targetPort: 8080`, but the container listens on `80`.

Talking point:

> “When the Service exists and endpoints exist but the app still fails, check the port mapping.”

### Endpoints

Endpoints show the actual backend Pod IPs and ports connected to a Service.

Command:

```bash
kubectl get endpoints -n student-app
```

If endpoints are empty:

```text
<none>
```

Possible causes:

- Selector does not match Pod labels
- Pods are not running
- Pods are not ready
- Wrong namespace
- Readiness probe failing, in more advanced cases

Talking point:

> “Endpoints are one of the fastest ways to confirm whether a Service is connected to Pods.”

### Port-forward

`kubectl port-forward` allows local testing without exposing the app publicly.

Example:

```bash
kubectl port-forward service/student-nginx-service 8080:80 -n student-app
```

Then:

```bash
curl http://localhost:8080
```

Talking point:

> “Port-forward is useful for engineers. It is not a production user access pattern.”

### Enterprise context

In real enterprise Kubernetes environments:

- Developers deploy workloads into namespaces
- Services provide stable internal access
- Ingress or load balancers expose apps externally
- DNS maps names to load balancers
- TLS secures traffic
- IAM/RBAC controls who can deploy and inspect resources
- Monitoring watches Service health and traffic
- SRE teams troubleshoot from Service to Pod to container logs

This class teaches the Service-to-Pod foundation used in all of those patterns.

---

## 12. Whiteboard Explanation

### How Class 2 extends Class 1

Class 1:

```text
Deployment
  |
  v
ReplicaSet
  |
  v
Pods
  |
  v
Containers
```

Class 2 adds access:

```text
Client
  |
  v
Service
  |
  | selector: app=student-nginx
  v
Pods
  |
  v
Containers
```

### Simple Service flow

```text
Client request
    |
    v
Kubernetes Service
    |
    | Looks for Pods with matching label
    | selector: app=student-nginx
    v
Pod 1                 Pod 2
app=student-nginx     app=student-nginx
    |                     |
    v                     v
nginx container        nginx container
targetPort: 80         targetPort: 80
```

### Port explanation

```text
Client talks to:
Service port 80
    |
    v
Service forwards to:
Pod targetPort 80
    |
    v
Container listens on:
containerPort 80
```

### Broken selector diagram

```text
Service selector:
app=wrong-label
    |
    v
No matching Pods

Existing Pods have:
app=student-nginx

Result:
Service exists, but endpoints are empty.
```

### Enterprise version

```text
User
 |
 v
DNS
 |
 v
Cloud Load Balancer
 |
 v
Ingress / Gateway
 |
 v
Kubernetes Service
 |
 v
Pods
 |
 v
Application containers
 |
 v
Logs, metrics, traces, alerts
```

Instructor explanation:

> “Today we are focusing on the Service-to-Pod part. Later, we will connect this to Ingress, cloud load balancers, DNS, TLS, and monitoring.”

---

## 13. Instructor Demo Script

### Demo title

**Expose an NGINX Deployment Using a Kubernetes Service**

### Demo objective

Show how to expose an existing Deployment with a Service, validate endpoints, and test access using port-forward.

### Required setup

Instructor should have a running Kubernetes cluster.

Validate:

```bash
kubectl get nodes
```

Create demo namespace:

```bash
kubectl create namespace week11-demo
```

Create or reuse Deployment (same production-grade baseline authored in Class 1 — pinned non-root image on port 8080, with resources, probes, and a restricted `securityContext`):

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

Apply:

```bash
kubectl apply -f nginx-deployment.yaml
kubectl get pods -n week11-demo --show-labels
```

Expected output:

```text
NAME                          READY   STATUS    LABELS
nginx-demo-xxxxxxxxxx-abcde   1/1     Running   app.kubernetes.io/name=nginx-demo,...
nginx-demo-xxxxxxxxxx-fghij   1/1     Running   app.kubernetes.io/name=nginx-demo,...
```

> Tie-in to the readiness probe: a Pod only becomes a Service endpoint once its **readiness probe passes**. `READY 1/1` here means the probe is green. If the probe were failing, the Pod would stay `Running` but `0/1`, and its IP would be excluded from the Service endpoints below — a key debugging signal in this class.

### Step 1: Explain current state

Run:

```bash
kubectl get deployment,pods -n week11-demo
```

Explain:

> “The app is running, but we do not yet have a stable Kubernetes networking object in front of it.”

### Step 2: Create Service manifest

Create file:

```bash
code nginx-service.yaml
```

Paste:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: week11-demo
spec:
  type: ClusterIP
  selector:
    app.kubernetes.io/name: nginx-demo
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

Explain each field:

- `kind: Service`
- `type: ClusterIP`
- `selector: app.kubernetes.io/name: nginx-demo` (must match the Pod labels)
- `port: 80` — the port clients use to reach the Service
- `targetPort: 8080` — the container port traffic is forwarded to. Note this is **8080**, the unprivileged NGINX port, not 80. This is exactly the `port` vs `targetPort` distinction: clients still talk to Service port 80, but the Service forwards to the container's 8080.

### Step 3: Apply the Service

```bash
kubectl apply -f nginx-service.yaml
```

Expected output:

```text
service/nginx-service created
```

### Step 4: Inspect the Service

```bash
kubectl get service -n week11-demo
```

Expected output:

```text
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
nginx-service   ClusterIP   10.x.x.x        <none>        80/TCP    10s
```

Explain:

> “ClusterIP means this Service is reachable inside the cluster. It does not create a public endpoint.”

### Step 5: Describe the Service

```bash
kubectl describe service nginx-service -n week11-demo
```

Point out:

- Selector
- IP
- Port
- TargetPort
- Endpoints

Expected endpoints example:

```text
Endpoints: 10.1.0.12:8080,10.1.0.13:8080
```

Explain:

> “Endpoints tell us which Pods the Service found. The port shown is the `targetPort` (8080), the port on the Pod — not the Service `port` (80).”

### Step 6: Inspect endpoints directly

```bash
kubectl get endpoints nginx-service -n week11-demo
```

Expected output:

```text
NAME            ENDPOINTS                         AGE
nginx-service   10.1.0.12:8080,10.1.0.13:8080     1m
```

Explain:

> “If this says `<none>`, the Service is not connected to Pods.”

### Step 7: Test with port-forward

```bash
kubectl port-forward service/nginx-service 8080:80 -n week11-demo
```

Expected output:

```text
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

In another terminal:

```bash
curl http://localhost:8080
```

Expected output includes:

```html
Welcome to nginx!
```

Explain:

> “We are forwarding traffic from our laptop to the Kubernetes Service.”

### Step 8: Demonstrate endpoint failure

Edit the Service selector:

```yaml
selector:
  app: wrong-label
```

Apply:

```bash
kubectl apply -f nginx-service.yaml
kubectl get endpoints nginx-service -n week11-demo
```

Expected output:

```text
NAME            ENDPOINTS   AGE
nginx-service   <none>      5m
```

Explain:

> “The Service exists, but it has no matching Pods.”

Fix selector:

```yaml
selector:
  app.kubernetes.io/name: nginx-demo
```

Apply again:

```bash
kubectl apply -f nginx-service.yaml
kubectl get endpoints nginx-service -n week11-demo
```

### Common demo failure points

| Failure | Likely Cause | Recovery |
|---|---|---|
| Port 8080 already in use | Another process uses local port | Use `8081:80` instead |
| Empty endpoints | Selector does not match Pod labels | Compare Service selector and Pod labels |
| Service not found | Wrong namespace | Use `-n week11-demo` |
| Pod not running | Deployment issue from Class 1 | Check `kubectl get pods` and `kubectl describe pod` |
| `curl` fails | Port-forward not running or wrong port | Restart port-forward and verify local port |
| YAML error | Indentation mistake | Fix YAML spacing |

### Cleanup steps

```bash
kubectl delete namespace week11-demo
```

If using a temporary kind cluster:

```bash
kind delete cluster --name week11
```

---

## 14. Student Lab Manual

### Lab title

**Expose a Kubernetes Deployment with a Service**

### Lab objective

Students will expose an NGINX Deployment using a Kubernetes ClusterIP Service, validate endpoints, and test access using port-forward.

### Estimated time

40 to 50 minutes

### Student prerequisites

Students should have:

- Working `kubectl`
- Running local Kubernetes cluster
- Basic understanding of Deployments and Pods
- VS Code or text editor
- Terminal
- `curl` or browser

### Starting point from Class 1

Students may reuse the Deployment from Class 1. If it no longer exists, they will recreate it.

Expected namespace:

```bash
student-app
```

### Architecture or workflow overview

```text
Local terminal/browser
        |
        | kubectl port-forward
        v
Kubernetes Service
        |
        | selector: app=student-nginx
        v
Pods from Deployment
        |
        v
NGINX containers
```

### Step 1: Create lab folder

```bash
mkdir -p week11-class2-lab
cd week11-class2-lab
```

### Step 2: Verify cluster access

```bash
kubectl get nodes
```

Expected output:

```text
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   ...   v1.xx.x
```

### Step 3: Create namespace

```bash
kubectl create namespace student-app
```

If namespace already exists, you may see:

```text
Error from server (AlreadyExists): namespaces "student-app" already exists
```

That is fine. Continue.

### Step 4: Create Deployment manifest

Create file:

```text
student-nginx-deployment.yaml
```

Paste:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: student-nginx
  namespace: student-app
  labels:
    app: student-nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: student-nginx
  template:
    metadata:
      labels:
        app: student-nginx
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

This is the same hardened baseline you authored in Class 1 (non-root image on 8080, resources, readiness probe, restricted `securityContext`, and the writable `emptyDir` scratch paths the unprivileged NGINX needs under a read-only root). We keep the short `app: student-nginx` label here so the selector/label matching is easy to read in the troubleshooting activity.

Apply:

```bash
kubectl apply -f student-nginx-deployment.yaml
```

Validate:

```bash
kubectl get pods -n student-app --show-labels
```

Expected output:

```text
NAME                             READY   STATUS    LABELS
student-nginx-xxxxxxxxxx-abcde   1/1     Running   app=student-nginx,...
student-nginx-xxxxxxxxxx-fghij   1/1     Running   app=student-nginx,...
```

### Step 5: Create Service manifest

Create file:

```text
student-nginx-service.yaml
```

Paste:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: student-nginx-service
  namespace: student-app
spec:
  type: ClusterIP
  selector:
    app: student-nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

The Service listens on `port: 80` (what clients use) and forwards to `targetPort: 8080` (the container's port). Mapping a clean external 80 to a non-root internal 8080 is a common real-world pattern.

Apply:

```bash
kubectl apply -f student-nginx-service.yaml
```

Expected output:

```text
service/student-nginx-service created
```

### Step 6: Inspect the Service

```bash
kubectl get service -n student-app
```

Expected output:

```text
NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
student-nginx-service   ClusterIP   10.x.x.x        <none>        80/TCP    10s
```

### Step 7: Validate endpoints

```bash
kubectl get endpoints -n student-app
```

Expected output:

```text
NAME                    ENDPOINTS                        AGE
student-nginx-service   10.x.x.x:8080,10.x.x.x:8080       30s
```

The endpoint port is `8080` (the `targetPort` / container port), not the Service `port` of 80. If endpoints show `<none>`, go to the troubleshooting tips section.

### Step 8: Describe the Service

```bash
kubectl describe service student-nginx-service -n student-app
```

Look for:

- Selector
- Port
- TargetPort
- Endpoints

### Step 9: Test with port-forward

Run this command and keep the terminal open:

```bash
kubectl port-forward service/student-nginx-service 8080:80 -n student-app
```

Expected output:

```text
Forwarding from 127.0.0.1:8080 -> 80
```

Open a second terminal and run:

```bash
curl http://localhost:8080
```

Expected output includes:

```html
Welcome to nginx!
```

Or open in browser:

```text
http://localhost:8080
```

### Step 10: Document traffic flow

In your notes, write this flow:

```text
localhost:8080
  -> kubectl port-forward
  -> student-nginx-service:80   (Service port)
  -> Pods matching app=student-nginx
  -> container port 8080        (targetPort)
```

### Step 11: Add a ConfigMap and a Secret (authored, not just debugged)

A "fundamentals" student who cannot mount a ConfigMap or a Secret is missing a core object — and Week 12 will have you *debug* a missing ConfigMap, so you must learn to *author* one first. We will serve a custom page from a ConfigMap and inject a Secret as an environment variable.

**1. ConfigMap — non-sensitive configuration.**

Create `student-config.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: student-web-content
  namespace: student-app
data:
  index.html: |
    <html><body><h1>Hello from a ConfigMap</h1></body></html>
```

```bash
kubectl apply -f student-config.yaml
```

**2. Secret — sensitive values.**

Create the Secret imperatively so the value is not committed to Git in plaintext:

```bash
kubectl create secret generic student-app-secret \
  --from-literal=API_TOKEN='demo-not-a-real-secret' \
  -n student-app
```

> Security note: Kubernetes Secrets are only **base64-encoded**, not encrypted, by default. `kubectl get secret -o yaml` reveals the value to anyone with read access. In real clusters you enable **encryption at rest** for Secrets and/or use an external manager (AWS Secrets Manager, External Secrets Operator, Sealed Secrets). Never commit real Secret values to Git. (Week 19 goes deeper on secrets management.)

**3. Wire both into the Deployment.** Add a volume mount for the ConfigMap and an env var from the Secret. Edit `student-nginx-deployment.yaml` so the container block reads:

```yaml
      containers:
        - name: nginx
          image: nginxinc/nginx-unprivileged:1.27
          ports:
            - containerPort: 8080
          env:
            - name: API_TOKEN
              valueFrom:
                secretKeyRef:
                  name: student-app-secret
                  key: API_TOKEN
          volumeMounts:
            - name: web-content
              mountPath: /usr/share/nginx/html
            - name: tmp
              mountPath: /tmp
            - name: nginx-cache
              mountPath: /var/cache/nginx
            - name: nginx-run
              mountPath: /var/run
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
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
      volumes:
        - name: web-content
          configMap:
            name: student-web-content
        - name: tmp
          emptyDir: {}
        - name: nginx-cache
          emptyDir: {}
        - name: nginx-run
          emptyDir: {}
```

```bash
kubectl diff -f student-nginx-deployment.yaml   # plan before apply
kubectl apply -f student-nginx-deployment.yaml
```

Re-run the port-forward and `curl http://localhost:8080`. You should now see **"Hello from a ConfigMap"** instead of the default NGINX page — proof the ConfigMap is mounted. Confirm the Secret is injected:

```bash
kubectl exec -n student-app deploy/student-nginx -- printenv API_TOKEN
```

> Note: because we set `readOnlyRootFilesystem: true`, every path the container writes to must be supplied by a mounted volume. The ConfigMap provides the static content at `/usr/share/nginx/html`, and the three `emptyDir` mounts (`/tmp`, `/var/cache/nginx`, `/var/run`) provide the scratch/cache/pid space the unprivileged NGINX needs at startup — those temp mounts carry over from the baseline Deployment and must stay even after adding the ConfigMap. Drop any of them and the Pod crash-loops with `nginx: [emerg] mkdir() "/tmp/proxy_temp" failed (30: Read-only file system)`.

### Step 12: Expose the app for real with Ingress (beyond port-forward)

`port-forward` is an engineer-only debugging tool — the material has said all week it is "not a production access pattern." Production traffic enters through an **Ingress** (HTTP routing by host/path) backed by an ingress controller, or increasingly through the **Gateway API**. Let's expose the app the way production does.

**1. Make sure an ingress controller exists.** Local clusters do not ship one by default. For NGINX ingress controller on kind/Docker Desktop/minikube:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=Ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

> minikube users can instead run `minikube addons enable ingress`.

**2. Create the Ingress resource** (`student-ingress.yaml`). It routes a hostname to the ClusterIP Service from Step 5 — the Ingress does not target Pods directly, it targets the Service:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: student-nginx-ingress
  namespace: student-app
spec:
  ingressClassName: nginx
  rules:
    - host: student-app.localdev.me
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: student-nginx-service
                port:
                  number: 80
```

```bash
kubectl apply -f student-ingress.yaml
kubectl get ingress -n student-app
```

**3. Reach the app through the Ingress** (no port-forward). The host `*.localdev.me` resolves to `127.0.0.1` publicly, so on a kind cluster mapped to localhost:

```bash
curl http://student-app.localdev.me
```

You should see the "Hello from a ConfigMap" page — served through controller → Ingress → Service → Pod, the real production path. This is the first time in the week the app is reached without `port-forward`.

> **Gateway API note (2026):** Ingress is stable and ubiquitous, but the **Gateway API** (`gateway.networking.k8s.io`) is its more expressive successor and the direction the ecosystem is moving. It splits responsibilities across `GatewayClass`, `Gateway` (owned by platform/infra), and `HTTPRoute` (owned by app teams), and handles traffic splitting, header routing, and cross-namespace delegation that Ingress annotations handled awkwardly. You do not need it for this lab, but expect Gateway API in senior interviews — know that `HTTPRoute` is roughly "the Ingress rule, done properly."

> Cost and cleanup note: the local ingress controller is free. On a **cloud** cluster (EKS/AKS/GKE), an Ingress backed by a cloud load balancer provisions a billable LB — clean it up (`kubectl delete ingress`/`svc`) when done. TLS on a real Ingress is normally automated with **cert-manager** (issues and renews certificates, e.g. from Let's Encrypt) — that is the "TLS" box in the enterprise diagram, taught conceptually here and used for real in later weeks.

### Step 13: The objects you will meet next (the map)

You have now authored Deployments, Services, ConfigMaps, Secrets, an Ingress, probes, resources, and a securityContext. A few core objects are intentionally left for later weeks — know they exist so the map is not blank:

- **NetworkPolicy** — default-deny / allow-list pod-to-pod traffic (network segmentation). A baseline security control and a common senior-interview topic.
- **RBAC: ServiceAccount, Role, RoleBinding** — who/what can do what in the cluster. Every Pod runs as a ServiceAccount; least-privilege RBAC is core security.
- **cert-manager** — automated TLS certificate issuance/renewal for Ingress/Gateway.
- **Gateway API** — the modern successor to Ingress (see note above).

You are not expected to write these today, but you should be able to say what each one is for.

### Validation checklist

Students should verify:

- [ ] Namespace `student-app` exists
- [ ] Deployment `student-nginx` exists
- [ ] Pods are Running
- [ ] Pods show label `app=student-nginx`
- [ ] Service `student-nginx-service` exists
- [ ] Service endpoints are not empty
- [ ] Port-forward works
- [ ] `curl http://localhost:8080` returns NGINX HTML
- [ ] Student can explain `port` vs `targetPort`
- [ ] Student can explain how Service selector matches Pod labels
- [ ] ConfigMap is mounted (page shows "Hello from a ConfigMap")
- [ ] Secret value is injected (`printenv API_TOKEN` shows the value)
- [ ] App is reachable through the Ingress without `port-forward`
- [ ] Student can name what NetworkPolicy, RBAC, cert-manager, and Gateway API are for

### Troubleshooting tips

| Problem | Check | Fix |
|---|---|---|
| No Pods found | Wrong namespace | Use `kubectl get pods -n student-app` |
| Empty endpoints | Selector does not match labels | Compare `kubectl get pods --show-labels` with Service selector |
| Port-forward fails | Port already in use | Use `8081:80` |
| `curl` fails | Port-forward stopped | Keep port-forward terminal running |
| Service missing | YAML not applied or wrong namespace | Reapply Service YAML |
| Pods not Running | Deployment issue | Use `kubectl describe pod` |
| YAML error | Bad indentation | Fix spacing and reapply |

### Cleanup steps

Delete the namespace and all resources:

```bash
kubectl delete namespace student-app
```

Confirm:

```bash
kubectl get namespaces
```

If your instructor wants you to keep resources for Week 12, do not delete them yet.

### Reflection questions

1. What problem does a Service solve?
2. Why is it risky to connect directly to a Pod IP?
3. What happens when a Service selector does not match Pod labels?
4. What does it mean when endpoints show `<none>`?
5. Why is port-forward useful for engineers but not a production access pattern?
6. How would this look different in AWS EKS?

### Optional challenge task

Create a NodePort Service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: student-nginx-nodeport
  namespace: student-app
spec:
  type: NodePort
  selector:
    app: student-nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

Apply:

```bash
kubectl apply -f student-nginx-nodeport.yaml
kubectl get service -n student-app
```

Observe the assigned NodePort.

Note: Behavior varies depending on Docker Desktop, kind, or minikube. This is for learning only.

---

## 15. Troubleshooting Activity

### Incident or problem title

**Service Exists but Application Is Unreachable**

### Business impact

A development team deployed an application to Kubernetes. The Pods are running, but the application cannot be reached through the Service. This blocks testing and prevents the team from promoting the application to the next environment.

### Symptoms

Pods are running:

```bash
kubectl get pods -n student-app
```

Output:

```text
NAME                             READY   STATUS    RESTARTS   AGE
student-nginx-xxxxxxxxxx-abcde   1/1     Running   0          5m
student-nginx-xxxxxxxxxx-fghij   1/1     Running   0          5m
```

Service exists:

```bash
kubectl get service -n student-app
```

Output:

```text
NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
student-nginx-service   ClusterIP   10.x.x.x        <none>        80/TCP    3m
```

Endpoints are empty:

```bash
kubectl get endpoints -n student-app
```

Output:

```text
NAME                    ENDPOINTS   AGE
student-nginx-service   <none>      3m
```

### Starting evidence

Broken Service manifest:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: student-nginx-service
  namespace: student-app
spec:
  type: ClusterIP
  selector:
    app: wrong-label
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

Deployment labels:

```yaml
template:
  metadata:
    labels:
      app: student-nginx
```

### Student investigation steps

1. Confirm Pods are running:

```bash
kubectl get pods -n student-app
```

2. Show Pod labels:

```bash
kubectl get pods -n student-app --show-labels
```

3. Inspect the Service:

```bash
kubectl describe service student-nginx-service -n student-app
```

4. Check endpoints:

```bash
kubectl get endpoints student-nginx-service -n student-app
```

5. Compare:

```text
Service selector vs Pod labels
```

6. Fix the Service selector.

7. Reapply the Service:

```bash
kubectl apply -f student-nginx-service.yaml
```

8. Validate endpoints again:

```bash
kubectl get endpoints -n student-app
```

9. Test with port-forward:

```bash
kubectl port-forward service/student-nginx-service 8080:80 -n student-app
curl http://localhost:8080
```

### Expected root cause

The Service selector is wrong.

Broken:

```yaml
selector:
  app: wrong-label
```

Actual Pod label:

```yaml
app: student-nginx
```

Because the selector does not match the Pod labels, the Service has no endpoints.

### Correct resolution

Update the Service selector:

```yaml
selector:
  app: student-nginx
```

Correct Service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: student-nginx-service
  namespace: student-app
spec:
  type: ClusterIP
  selector:
    app: student-nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

Apply:

```bash
kubectl apply -f student-nginx-service.yaml
kubectl get endpoints -n student-app
```

Expected output:

```text
NAME                    ENDPOINTS                        AGE
student-nginx-service   10.x.x.x:8080,10.x.x.x:8080       5m
```

### Optional second fault: wrong targetPort

This fault is subtle because the Service **will still show endpoints** — the selector matches — but `curl` returns a connection error because traffic is forwarded to a port nothing is listening on.

Broken (container listens on 8080, but Service forwards to 80):

```yaml
ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

Correct:

```yaml
ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

Teaching point: empty endpoints point at a **selector/label/readiness** problem; populated endpoints but failing connections point at a **port mapping** problem. Use that split to decide where to look.

### Common wrong paths

| Wrong Path | Why Students Try It | Better Approach |
|---|---|---|
| Restarting the cluster | Assumes Kubernetes is broken | Check endpoints first |
| Deleting Pods | Thinks Pods need restart | Pods are already running |
| Recreating Deployment | Focuses on workload, not Service | Compare Service selector with Pod labels |
| Changing random ports | Guesses instead of validating | Confirm containerPort and targetPort |
| Ignoring namespace | Commands show no resources | Always check `-n student-app` |
| Using LoadBalancer locally | Thinks Service must be public | Start with ClusterIP and port-forward |

### Instructor hints

Use progressive hints:

1. “Are the Pods running?”
2. “Does the Service exist?”
3. “Does the Service have endpoints?”
4. “What labels do the Pods have?”
5. “What selector does the Service use?”
6. “Do the selector and labels match?”

### Preventive action

In real teams, prevent this with:

- Standard labels
- YAML review in pull requests
- CI validation
- Helm chart templates
- Namespace standards
- Pre-deployment checks
- Automated smoke tests after deployment

---

## 16. Scenario-Based Discussion Questions

### Question 1

**Why should applications not depend directly on Pod IPs?**

Expected response themes:

- Pod IPs are temporary
- Pods can be replaced
- Scaling changes backend Pods
- Services provide stable access

Instructor follow-up:

> How does this support reliability?

### Question 2

**What should an engineer check first when a Service exists but traffic does not reach Pods?**

Expected response themes:

- Pod status
- Pod labels
- Service selector
- Endpoints
- targetPort

Instructor follow-up:

> Why are endpoints such a useful clue?

### Question 3

**When would a team use ClusterIP instead of LoadBalancer?**

Expected response themes:

- Internal app communication
- Microservices inside cluster
- No public exposure needed
- Reduced cost and smaller attack surface

Instructor follow-up:

> What security benefit does internal-only access provide?

### Question 4

**Why might a LoadBalancer Service create cost in AWS?**

Expected response themes:

- It may provision AWS load balancer resources
- Load balancers are billed
- Public exposure can add security considerations
- Cloud resources must be cleaned up

Instructor follow-up:

> What approval or review process should exist before exposing production apps?

### Question 5

**How do labels support enterprise operations beyond just routing traffic?**

Expected response themes:

- Ownership
- Environment
- Cost allocation
- Monitoring
- Automation
- Policy
- Troubleshooting

Instructor follow-up:

> What labels would you require for production workloads?

### Question 6

**Why is port-forward useful, and why is it not a production pattern?**

Expected response themes:

- Useful for debugging and local testing
- Tied to engineer session
- Not scalable
- Not suitable for users
- Not managed by DNS or load balancer

Instructor follow-up:

> What would replace port-forward in production?

### Question 7

**How does today’s Service concept connect to future Helm and EKS lessons?**

Expected response themes:

- Helm templates Services
- EKS runs the same Service objects
- LoadBalancer connects Kubernetes to AWS
- CI/CD deploys manifests or charts
- Troubleshooting still uses `kubectl`

Instructor follow-up:

> Why is it valuable to learn this locally before EKS?

---

## 17. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple choice

What Kubernetes object provides stable network access to Pods?

A. Deployment  
B. ReplicaSet  
C. Service  
D. Namespace  

**Answer:** C. Service  
**Explanation:** A Service provides stable access to matching Pods.

### Question 2: True or false

A Service sends traffic to Pods by matching its selector to Pod labels.

**Answer:** True  
**Explanation:** The Service selector must match Pod labels for endpoints to exist.

### Question 3: Short answer

What does it usually mean if a Service has endpoints listed as `<none>`?

**Answer:** The Service is not matching any ready Pods.  
**Explanation:** This commonly happens because the selector does not match Pod labels, Pods are not running, or Pods are not ready.

### Question 4: Multiple choice

Which Service type is the default internal-only Service type?

A. NodePort  
B. ClusterIP  
C. LoadBalancer  
D. ExternalName  

**Answer:** B. ClusterIP  
**Explanation:** ClusterIP exposes the Service inside the cluster.

### Question 5: Multiple choice

In this mapping, what does `targetPort` refer to?

```yaml
ports:
  - port: 80
    targetPort: 8080
```

A. The local laptop port  
B. The port exposed by the Service  
C. The port on the Pod or container receiving traffic  
D. The cloud load balancer port  

**Answer:** C  
**Explanation:** `targetPort` is where the Service sends traffic on the backend Pod.

### Question 6: Troubleshooting

Pods are Running, but the Service has no endpoints. What two things should you compare?

**Answer:** Compare the Service selector and the Pod labels.  
**Explanation:** If they do not match, the Service cannot find Pods.

### Question 7: Troubleshooting

`kubectl port-forward service/student-nginx-service 8080:80 -n student-app` fails because port 8080 is already in use. What can you do?

**Answer:** Use a different local port, such as `8081:80`.  
**Explanation:** The left side is the local machine port and can be changed.

### Question 8: AWS-related

In AWS EKS, what can a Kubernetes `LoadBalancer` Service provision?

A. S3 bucket  
B. AWS load balancer  
C. IAM user  
D. RDS database  

**Answer:** B. AWS load balancer  
**Explanation:** In managed Kubernetes environments, `LoadBalancer` Services can integrate with cloud load balancers.

### Question 9: AWS-related

Why should students avoid creating real LoadBalancer Services in AWS labs without instruction?

**Answer:** They can create billable cloud resources.  
**Explanation:** AWS load balancers can create cost and should be managed carefully.

### Question 10: Class 1 and Class 2 connection

How does a Service connect to the Pods created by a Deployment?

**Answer:** The Deployment creates Pods with labels, and the Service selector matches those labels.  
**Explanation:** Class 1 introduced Deployment and Pod labels. Class 2 uses those labels for Service routing.

### Question 11: Class 1 and Class 2 connection

What happens if a Deployment replaces a Pod? Does the Service need to be recreated?

**Answer:** Usually no. The Service continues routing to Pods that match its selector.  
**Explanation:** New Pods with the same labels become part of the Service endpoints.

### Question 12: Short answer

Why is port-forward useful during development or troubleshooting?

**Answer:** It lets engineers test access to a Kubernetes Service or Pod from their local machine without exposing it publicly.  
**Explanation:** It is useful for debugging, but not for production user traffic.

---

## 18. Homework Assignment

### Assignment title

**Kubernetes Service Traffic Flow and Troubleshooting Documentation**

### Scenario

Your application team successfully deployed an app to Kubernetes, but another junior engineer does not understand how traffic reaches the Pods. Your manager asks you to document the Service flow and include a basic troubleshooting checklist.

### Student tasks

Students must:

1. Create or reuse the `student-nginx` Deployment.
2. Create a `student-nginx-service` ClusterIP Service.
3. Validate that the Service has endpoints.
4. Test access using `kubectl port-forward`.
5. Create a diagram showing traffic flow:
   - Local browser or curl
   - Port-forward
   - Service
   - Endpoints
   - Pods
   - Containers
6. Explain:
   - What a Service does
   - Why Pods need a Service
   - What labels and selectors do
   - What endpoints mean
   - Difference between `port` and `targetPort`
   - Difference between ClusterIP, NodePort, and LoadBalancer
7. Create a troubleshooting checklist for:
   - Empty endpoints
   - Wrong namespace
   - Wrong selector
   - Wrong targetPort
   - Port-forward failure

### Expected deliverables

Students submit:

1. `student-nginx-deployment.yaml`
2. `student-nginx-service.yaml`
3. Diagram of traffic flow
4. Short written explanation
5. Command output from:

```bash
kubectl get pods -n student-app --show-labels
kubectl get service -n student-app
kubectl get endpoints -n student-app
kubectl describe service student-nginx-service -n student-app
```

6. Screenshot or copied output showing successful:

```bash
curl http://localhost:8080
```

### Submission format

Recommended structure:

```text
week11/
  class2/
    student-nginx-deployment.yaml
    student-nginx-service.yaml
    homework/
      service-traffic-flow.md
      diagram.png
```

### Estimated completion time

60 to 90 minutes

### Grading criteria

| Criteria | Points |
|---|---:|
| Correct Deployment YAML | 15 |
| Correct Service YAML | 20 |
| Valid endpoint evidence | 15 |
| Successful port-forward test | 15 |
| Clear traffic flow diagram | 15 |
| Accurate troubleshooting checklist | 15 |
| Clean formatting and submission | 5 |

### Optional advanced challenge

Create two Services for the same Deployment:

1. A ClusterIP Service
2. A NodePort Service

Compare their behavior and explain why ClusterIP is safer for internal-only access.

---

## 19. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Service selector does not match Pod labels | Students copy YAML without checking labels | Always compare `kubectl get pods --show-labels` with Service selector |
| Forgetting namespace | Resources are in `student-app`, but command checks default namespace | Use `-n student-app` consistently |
| Confusing `port` and `targetPort` | Both fields look similar | Remember: client uses `port`, Pod receives on `targetPort` |
| Expecting ClusterIP to work from browser directly | Students think every Service is public | Explain ClusterIP is internal only |
| Closing port-forward terminal | Port-forward only works while command is running | Keep that terminal open |
| Port 8080 already in use | Another app is using the local port | Use another local port like `8081` |
| Creating LoadBalancer in cloud without approval | Student wants public access | Warn about cost and security |
| Deleting Pods to fix Service issue | Student focuses on workload instead of routing | Check endpoints first |
| Not checking endpoints | Student uses only `get service` | Teach endpoints as key validation step |
| Treating local Kubernetes and EKS as identical | Concepts match, infrastructure differs | Explain cloud integration differences |

---

## 20. Real-World Enterprise Scenario

### Scenario

A company is modernizing its internal applications by moving from EC2-hosted containers to Amazon EKS. The first application team has successfully deployed Pods using a Deployment, but the app is not reachable by other services.

The platform team investigates and finds that the Kubernetes Service selector does not match the Pod labels. As a result, the Service exists but has no endpoints.

### Constraints

- Developers should not connect directly to Pod IPs
- All manifests must be reviewed through Git
- Each team must deploy into its own namespace
- Services must use approved labels
- Production exposure requires security review
- Public load balancers require approval because of cost and risk
- Monitoring must identify which app, team, and environment own each workload
- SRE team needs a repeatable troubleshooting flow

### How the class topic applies

This class teaches the core routing pattern:

```text
Service -> selector -> Pod labels -> endpoints -> application container
```

If this chain breaks, the app may be running but unreachable.

### What each role would do

| Role | Action |
|---|---|
| DevOps Engineer | Add Service YAML to the deployment repo and pipeline |
| Cloud Engineer | Ensure EKS networking and load balancer integration are correctly configured |
| SRE | Validate endpoints, health, alerts, and runbook troubleshooting steps |
| Platform Engineer | Provide standard Helm chart or Service template |
| Security Engineer | Review exposure type, namespace access, and public traffic risk |

---

## 21. Instructor Tips

### Teaching tips

- Keep the focus on Service-to-Pod routing first; reach Ingress only after endpoints are solid.
- When you do the Ingress step, keep the controller install mechanical and the routing concrete (host → Service → Pod). Save Gateway API internals for a name-drop.
- Use endpoints as the main troubleshooting anchor.
- Repeat: selector must match labels.
- Use Class 1 Deployment as the foundation.
- Draw the traffic flow before showing YAML.

### Pacing tips

- Keep review to 15 minutes.
- Do not over-explain every Service type.
- Spend more time on ClusterIP and troubleshooting.
- Keep LoadBalancer conceptual unless using a local-only example.
- Leave enough time for students to debug broken selectors.

### Lab support tips

When students are stuck, ask:

1. What namespace are you in?
2. Are the Pods running?
3. What labels do the Pods have?
4. What selector does the Service use?
5. Does the Service have endpoints?
6. Is port-forward still running?

### How to help struggling students

Give them this minimum path:

```bash
kubectl get pods -n student-app --show-labels
kubectl get service -n student-app
kubectl get endpoints -n student-app
kubectl describe service student-nginx-service -n student-app
```

Then help them compare labels and selectors.

### How to challenge advanced students

Ask advanced students to:

- Create ClusterIP and NodePort Services
- Explain why LoadBalancer can cost money in AWS
- Add labels like `environment: dev` and `owner: student`
- Create a Markdown runbook for Service troubleshooting
- Explain how Helm would template the Service
- Explain how CI/CD would deploy this YAML

---

## 22. Student Outcome Checklist

### Students should be able to explain

- [ ] Why Pods need Services
- [ ] Why Pod IPs are not reliable access points
- [ ] What a ClusterIP Service does
- [ ] What a NodePort Service does
- [ ] What a LoadBalancer Service does
- [ ] What endpoints represent
- [ ] How Service selectors match Pod labels
- [ ] Difference between `port` and `targetPort`
- [ ] How EKS, AKS, and GKE relate to Kubernetes Services

### Students should be able to build or configure

- [ ] A Kubernetes Deployment
- [ ] A Kubernetes ClusterIP Service
- [ ] Correct Service selector
- [ ] Correct Service port and targetPort
- [ ] Port-forward access for local testing
- [ ] A ConfigMap mounted into a Pod
- [ ] A Secret injected as an environment variable
- [ ] An Ingress that exposes the app without port-forward
- [ ] Basic traffic flow documentation

### Students should be able to troubleshoot

- [ ] Empty Service endpoints
- [ ] Wrong namespace
- [ ] Wrong selector
- [ ] Wrong targetPort
- [ ] Port-forward failure
- [ ] Pods running but app unreachable
- [ ] Difference between workload issue and Service routing issue

---

## 23. Class Completion Checklist

### Instructor checklist before ending class

- [ ] Students reviewed Class 1 Deployment and Pod concepts
- [ ] Students understand why Services are needed
- [ ] Students can explain ClusterIP, NodePort, and LoadBalancer at a beginner level
- [ ] Students created a Service manifest
- [ ] Students validated endpoints
- [ ] Students tested access with port-forward
- [ ] Students completed the selector troubleshooting activity
- [ ] Students understand cost risk of cloud LoadBalancer Services
- [ ] Students know homework deliverables
- [ ] Students understand how Week 11 prepares them for Week 12

### Student checklist before leaving class

- [ ] I can create a Service YAML file
- [ ] I can connect a Service to Pods using labels and selectors
- [ ] I can check Service endpoints
- [ ] I can use `kubectl port-forward`
- [ ] I can test the app with `curl`
- [ ] I can troubleshoot empty endpoints
- [ ] I understand `port` vs `targetPort`
- [ ] I understand why LoadBalancer Services can create cloud cost
- [ ] I can explain how Class 1 Deployments connect to Class 2 Services

### Items to verify before closing the week

Students should have:

- Working local Kubernetes cluster
- Completed Deployment YAML
- Completed Service YAML
- Successful endpoint validation
- Successful port-forward test
- Completed or started traffic flow diagram
- Basic troubleshooting checklist
- Cleaned up resources if instructed

---

## 24. End-of-Week Summary

### What students learned this week

In Week 11, students learned the foundation of Kubernetes application deployment.

They learned how to:

- Explain Kubernetes architecture
- Deploy a production-grade application with a Deployment (pinned non-root image, resource requests/limits, readiness/liveness probes, and a restricted securityContext)
- Understand Deployment, ReplicaSet, Pod, and Container relationships
- Use namespaces, labels, and selectors (including recommended `app.kubernetes.io/*` labels)
- Scale declaratively (edit + `kubectl apply`, with `kubectl diff` to plan) and understand HPA conceptually
- Create a Kubernetes Service
- Author a ConfigMap and a Secret and wire them into a Deployment
- Expose a Deployment internally, and externally through an Ingress (with a Gateway API note)
- Validate endpoints
- Test access with port-forward
- Troubleshoot image, selector, namespace, port, and readiness issues

### How Class 1 and Class 2 connect

Class 1 answered:

> “How do I run an application in Kubernetes?”

Class 2 answered:

> “How do I provide stable access to that application?”

Together, the two classes form the minimum Kubernetes application pattern:

```text
Deployment -> ReplicaSet -> Pods -> Service -> Traffic access
```

### How this week prepares students for the next week

Week 12 will focus on Kubernetes operations and troubleshooting. Students will use the same concepts and commands from Week 11, but with more realistic failures:

- Pods stuck in bad states
- Services not routing traffic
- DNS issues
- Readiness and liveness probe problems
- Resource request and limit issues
- Deployment rollout failures

### What students should review before the next module

Students should review:

- `kubectl get`
- `kubectl describe`
- `kubectl logs`
- `kubectl get events`
- Namespace usage
- Deployment structure
- Service structure
- Labels and selectors
- Endpoints
- `port` vs `targetPort`
- Common Pod and Service troubleshooting flow

---

## Class Artifacts & Validation

The on-disk, validated versions of this class's manifests live in the backing module [`labs/kubernetes-fundamentals/`](../../labs/kubernetes-fundamentals/). The inline Service/ConfigMap/Secret/Ingress snippets above are teaching aids; the rows below are the real files. This class's exposure-and-config objects map 1:1 to the lab: a ClusterIP Service whose `port: 80` forwards to a named `targetPort`, a ConfigMap and a (clearly fake) Secret wired into the Deployment, an Ingress that routes to the Service, and the NetworkPolicies that lock the app down — the same objects authored in §13–14.

All commands below were run from `labs/kubernetes-fundamentals/`. The live gates ran against a reachable local `kind` cluster (Kubernetes v1.31); `kubeconform v0.6.7` was on `PATH`.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/kubernetes-fundamentals/solution/base/service.yaml | kubernetes (yaml) | ClusterIP Service: `port: 80` → named `targetPort: http` (container 8000); selects pods by `app.kubernetes.io/name: web` — the selector/label + port/targetPort lesson from §13 | `kubectl kustomize solution/base \| kubeconform -strict -summary` | PASS — `Valid: 10, Invalid: 0` |
| 2 | labs/kubernetes-fundamentals/solution/base/configmap.yaml | kubernetes (yaml) | Non-sensitive config (the authored ConfigMap from §14 Step 11) | `kubectl kustomize solution/base \| kubeconform -strict -summary` | PASS — `Valid: 10, Invalid: 0` |
| 3 | labs/kubernetes-fundamentals/solution/base/secret.yaml | kubernetes (yaml) | A clearly **FAKE**, labelled example Secret (the security-note object from §14 Step 11) | `kubectl kustomize solution/base \| kubeconform -strict -summary` | PASS — `Valid: 10, Invalid: 0` |
| 4 | labs/kubernetes-fundamentals/solution/base/ingress.yaml | kubernetes (yaml) | Ingress (`ingressClassName: nginx`) routing a host to the ClusterIP Service — the "expose beyond port-forward" path from §14 Step 12 | `kubectl kustomize solution/base \| kubeconform -strict -summary` | PASS — `Valid: 10, Invalid: 0` |
| 5 | labs/kubernetes-fundamentals/solution/base/networkpolicy.yaml | kubernetes (yaml) | 3 NetworkPolicies: `default-deny-all` + `allow-from-ingress` + `allow-dns-egress` — the NetworkPolicy object named in §14 Step 13's "objects you'll meet next" | `python3 -m unittest discover -s tests` (asserts default-deny + allow-from-ingress) | PASS — `Ran 16 tests ... OK` |
| 6 | labs/kubernetes-fundamentals/solution/base/deployment.yaml | kubernetes (yaml) | The Deployment this Service fronts (2 replicas, readiness probe gating endpoints — the "ready pods only become endpoints" point from §13) | `./validate.sh` live gate: apply base, `2/2 Ready`, populated endpoints | PASS — live cluster, endpoints `10.244.0.5:8000,10.244.0.6:8000` |
| 7 | labs/kubernetes-fundamentals/solution/overlays/prod/kustomization.yaml | kustomize | Prod overlay (`prod-` prefix, `replicas: 4`) showing the same Service/Ingress set renamed per environment | `kubectl kustomize solution/overlays/prod \| kubeconform -strict -summary` | PASS — `Valid: 10, Invalid: 0` |
| 8 | labs/kubernetes-fundamentals/validate.sh | shell | The module's validation runner (all gates above + live apply) | `bash -n validate.sh` then `./validate.sh` | PASS — exits 0, `11 passed, 0 failed, 1 deferred` |

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

The live apply proves the Service-to-pod chain this class teaches is real: the base applies, both pods reach `2/2 Ready` only after their readiness probe passes, and the Service endpoints populate (`10.244.0.5:8000,10.244.0.6:8000`). The never-Ready fixture's empty endpoints (`<none>`) — the exact "endpoints-first debugging" symptom from §15 — was also reproduced live this run. See the lab README [Validation](../../labs/kubernetes-fundamentals/README.md#validation) section for the captured output. The single `DEFER` (`kubectl apply --dry-run=client`) is superseded by the live apply.

## Definition of Done

- [x] **Every technology taught ships at least one runnable file on disk.** Kubernetes Service, ConfigMap, Secret, Ingress, NetworkPolicy → real `*.yaml` in `labs/kubernetes-fundamentals/solution/base/`, not just fences.
- [x] **Each artifact passes (or documents) its validation gate; output captured.** `kubeconform -strict` on the rendered base (10 objects valid) + 16 structural tests + live cluster apply with populated/empty endpoints, all captured above.
- [x] **Lab has starter (intentionally incomplete) and solution (reference) versions.** `starter/deployment.yaml` (4 `TODO(student)` gaps); `solution/base/` is the reference for the Service/ConfigMap/Secret/Ingress/NetworkPolicy set.
- [x] **Lab README includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, cost notes.** All present in [`labs/kubernetes-fundamentals/README.md`](../../labs/kubernetes-fundamentals/README.md).
- [x] **Cleanup/teardown is provided and idempotent.** README Cleanup section (`kubectl delete -k ... --ignore-not-found`, `kind delete cluster`); live gates use a throwaway namespace torn down on exit.
- [x] **Instructor answer key exists for the lab, homework, quiz, and troubleshooting exercise.** Lab answer key in README; class quiz (§17) and homework (§18) have answer keys/rubrics; the wrong-selector and wrong-targetPort troubleshooting (§15) has symptom→cause→fix.
- [x] **Troubleshooting exercise uses a real, reproducible broken state.** The never-Ready `broken/deployment-badprobe.yaml` (empty Service endpoints) was reproduced live this run; the §15 wrong-selector fault is a real, applyable manifest.
- [x] **Expected outputs are shown for demos and labs.** Populated endpoints `10.x.x.x:8080`, the `<none>` empty-endpoints state, and the `curl` results are captured here and in the README.
- [x] **Cost & security warnings present.** §7 LoadBalancer/Ingress cost warning; Secret base64-not-encryption security note (§14 Step 11); lab README has dedicated security and cost sections.
- [x] **Cross-references to the module repo and prior/next weeks are correct.** Class 1 (Deployment) → this class (Service/exposure/config) → Week 12 (the `broken/` fixtures); Gateway API / NetworkPolicy / RBAC / cert-manager correctly forward-referenced.
- [x] **The artifact manifest (§4.2) is present and every path resolves.** Table above; all 8 paths `ls`-verified.
