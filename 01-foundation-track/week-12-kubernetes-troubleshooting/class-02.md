# Week 12, Class 2: Kubernetes Networking, Service Discovery, and Production Troubleshooting

**Week:** Week 12  
**Track:** Unified DevOps · Cloud · SRE Track  
**Week topic:** Kubernetes Operations and Troubleshooting  
**Class duration:** 3 hours  
**Audience:** Beginner to intermediate  
**Primary production context:** AWS EKS  
**Class type:** Instructor-led with demo, guided lab, troubleshooting challenge, and end-of-week validation  

---

# SECTION A: Instructor Teaching Guide

---

> **▶ Runnable lab for this class:** [`labs/kubernetes-fundamentals/`](../../labs/kubernetes-fundamentals/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## 1. Class Snapshot

| Item | Details |
|---|---|
| Class title | Kubernetes Networking, Service Discovery, and Production Troubleshooting |
| Week | Week 12 |
| Class | Class 2 of 2 |
| Duration | 3 hours |
| Main focus | Troubleshooting Kubernetes Services, selectors, endpoints, DNS, ports, probes, and traffic flow |
| Primary tools | `kubectl`, Services, endpoints, pod labels, `exec`, `port-forward`, temporary test pods |
| AWS context | EKS workload troubleshooting, AWS Load Balancer Controller, CloudWatch Container Insights, security group awareness |
| Class 1 connection | Class 1 fixed failed pods. Class 2 handles the next issue: pods are running, but the application is still unreachable |
| Main scenario | A production deployment is now running, but users cannot reach the application through the Kubernetes Service |
| Student deliverable | Fixed Service/DNS/probe issues and a Kubernetes service troubleshooting checklist |

---

## 2. Teaching Storyline

Use this single storyline throughout the class:

> In Class 1, the team fixed broken pods after a failed deployment. The pods are now running. However, users still cannot reach the application. The application team says, “Kubernetes says the pods are running, so why is the service still down?” The DevOps/SRE team must investigate traffic flow from Service to Pod, validate labels and selectors, check endpoints, test DNS, inspect ports, and confirm readiness behavior.

The class should follow this natural troubleshooting path:

```text
Pods are running
→ Application still unreachable
→ Check Service
→ Check selector and pod labels
→ Check endpoints
→ Check service port and targetPort
→ Test with port-forward
→ Test from inside the cluster
→ Check DNS resolution
→ Check readiness and liveness probes
→ Validate application reachability
→ Connect findings to EKS production troubleshooting
```

Core lesson:

```text
Running pod does not always mean reachable application.
```

---

## 3. Learning Objectives

By the end of this class, students will be able to:

1. Troubleshoot Kubernetes Service routing issues.
2. Explain labels, selectors, target ports, and service ports.
3. Use `exec`, `port-forward`, and temporary test pods for connectivity testing.
4. Diagnose DNS and service discovery problems, including a *broken* DNS scenario (wrong FQDN / wrong namespace / NXDOMAIN).
5. Reproduce a liveness-probe restart loop and distinguish it from an application crash.
6. Diagnose a `NetworkPolicy` as the cause of "endpoints exist, DNS resolves, but traffic is still blocked."
7. Understand how readiness probes, liveness probes, requests, and limits impact production reliability.
8. Connect local Kubernetes troubleshooting concepts to EKS, CloudWatch Container Insights, service meshes, AKS, and GKE.

---

## 4. Quick Review of Class 1

Keep this review short. The goal is continuity, not reteaching.

### Ask students

1. What command helped us identify the pod state?
2. What did `ImagePullBackOff` mean?
3. What did `CrashLoopBackOff` mean?
4. Why do we check events?
5. Why do we check logs?
6. What does successful pod recovery look like?

### Expected review summary

Class 1 taught:

```text
Status → Describe → Events → Logs → Manifest → Fix → Validate
```

Class 2 extends that flow:

```text
Pod health → Service → Labels/selectors → Endpoints → Ports → DNS → Probes → Traffic validation
```

Instructor transition statement:

> Last class, we focused on getting pods healthy. Today we focus on what happens after pods are healthy but users still cannot reach the application.

---

## 5. Prerequisite Review

Students should already know:

| Concept | What students should remember |
|---|---|
| Pod | Runs the application container |
| Deployment | Manages pods and rollout behavior |
| Labels | Key-value metadata attached to Kubernetes objects |
| Selector | A rule used to match objects by label |
| Service | Stable network entry point for pods |
| Namespace | Logical boundary for Kubernetes resources |
| Container port | Port the app listens on inside the container |
| `kubectl describe` | Shows details and events |
| `kubectl logs` | Shows container logs |
| `kubectl get pods --show-labels` | Shows pod labels for selector troubleshooting |

The instructor should confirm students understand this relationship:

```text
Service selector must match pod labels.
If the selector does not match, the Service has no endpoints.
If the Service has no endpoints, traffic has nowhere to go.
```

---

## 6. Time-Boxed Agenda

| Time | Segment | Teaching Purpose |
|---:|---|---|
| 0:00 to 0:15 | Review of Class 1 troubleshooting flow | Connect pod troubleshooting to traffic troubleshooting |
| 0:15 to 0:40 | Kubernetes Services, selectors, ports, and endpoints | Explain how Service traffic reaches pods |
| 0:40 to 1:05 | Service discovery and Kubernetes DNS | Teach internal service names and cluster DNS troubleshooting |
| 1:05 to 1:25 | Probes, readiness, liveness, requests, and limits | Explain why running pods may still not receive traffic |
| 1:25 to 1:35 | Break | Short reset |
| 1:35 to 2:05 | Instructor demo: pod running but service unreachable | Model evidence-based Service troubleshooting |
| 2:05 to 2:45 | Student lab: reproduce and fix Service, probe, NetworkPolicy, and DNS faults | Students climb the layered model through six reachability failures |
| 2:45 to 2:55 | AWS EKS troubleshooting comparison | Connect local Kubernetes troubleshooting to production EKS |
| 2:55 to 3:00 | Wrap-up and final checklist | Close Week 12 with operational readiness summary |

---

## 7. Concept-by-Concept Teaching Guide

---

### Segment 1: From Pod Troubleshooting to Traffic Troubleshooting  
**Time:** 0:00 to 0:15

Start with this statement:

> In Class 1, we learned how to troubleshoot pods that fail to start. Today, we assume the pods are running. The question is: can users or other services reach the application?

Use this simple comparison:

| Class 1 Focus | Class 2 Focus |
|---|---|
| Is the pod starting? | Can traffic reach the pod? |
| Image, command, config, logs | Service, selectors, endpoints, DNS, ports |
| `ImagePullBackOff`, `CrashLoopBackOff` | No endpoints, wrong targetPort, DNS failure, readiness failure |
| Workload health | Application reachability |

Instructor point:

A Kubernetes workload can pass one layer of health and fail another.

```text
Pod Running = process exists
Pod Ready = Kubernetes can send traffic
Service Reachable = clients can reach the app
Application Healthy = app returns correct response
```

---

### Segment 2: Kubernetes Services, Selectors, Ports, and Endpoints  
**Time:** 0:15 to 0:40

Teach the Service traffic path:

```text
Client
  |
  v
Kubernetes Service
  |
  v
Service selector matches pod labels
  |
  v
Endpoints are created
  |
  v
Traffic goes to pod IP and targetPort
  |
  v
Application container receives request
```

Explain each part:

| Component | Role |
|---|---|
| Service | Provides stable access to changing pods |
| Selector | Finds matching pods by labels |
| Pod label | Metadata used by Service selector |
| Endpoint | Actual backend pod IP and port behind the Service |
| `port` | Port exposed by the Service |
| `targetPort` | Port on the container/pod where traffic is sent |
| `ClusterIP` | Internal-only Service type |

Important instructor point:

When a Service has no endpoints, the Service exists but does not send traffic to any pod.

Command sequence:

```bash
kubectl get svc
kubectl describe svc <service-name>
kubectl get endpoints <service-name>
kubectl get pods --show-labels
```

Explain why:

- `get svc` confirms the Service exists.
- `describe svc` shows selector and ports.
- `get endpoints` confirms whether the Service found matching pods.
- `get pods --show-labels` lets you compare selector and pod labels.

---

### Segment 3: Service Discovery and Kubernetes DNS  
**Time:** 0:40 to 1:05

Explain that Kubernetes Services get internal DNS names.

For a Service named `inventory-service` in namespace `week12-class2-lab`, the common names are:

```text
inventory-service
inventory-service.week12-class2-lab
inventory-service.week12-class2-lab.svc
inventory-service.week12-class2-lab.svc.cluster.local
```

Teach the practical version first:

Inside the same namespace, students can usually use:

```text
http://inventory-service
```

From a different namespace, they may need:

```text
http://inventory-service.week12-class2-lab
```

Useful test pod:

```bash
kubectl run net-test --image=busybox:1.36 --rm -it -- sh
```

Inside the pod:

```sh
nslookup inventory-service
wget -qO- http://inventory-service
```

Instructor point:

DNS success means the Service name resolves. It does not always mean the application is healthy. DNS, routing, ports, and app response are separate checks.

---

### Segment 4: Probes, Readiness, Liveness, Requests, and Limits  
**Time:** 1:05 to 1:25

Keep this practical and tied to troubleshooting.

### Readiness probe

Readiness answers:

```text
Should this pod receive traffic?
```

If readiness fails:

- pod may be running
- pod may not be ready
- Service may not send traffic to it
- deployment may not become fully available

### Liveness probe

Liveness answers:

```text
Should Kubernetes restart this container?
```

If liveness is too aggressive:

- Kubernetes may restart a slow-starting app
- the app may enter a restart loop
- students may confuse it with application failure

### Resource requests and limits

Requests affect scheduling.

Limits affect runtime behavior.

Common symptoms:

| Symptom | Possible Cause |
|---|---|
| Pod stuck `Pending` | Request too high for node capacity |
| Pod restarts | Memory limit too low, app killed |
| Slow response | CPU throttling or insufficient resources |
| Not ready | App startup slow or readiness probe too strict |

Instructor point:

Do not teach probes as pure YAML. Teach probes as production traffic-control mechanisms.

---

### Segment 5: When Everything Looks Right but Traffic Is Still Blocked  
**Time:** woven into the lab block

By the time students reach this point they can prove: pod Running, pod Ready, Service has endpoints, DNS resolves. So why might traffic *still* fail? Two production-common causes that the previous layers do not catch:

#### NetworkPolicy (the silent blocker)

A `NetworkPolicy` is a firewall for pod-to-pod traffic. The critical rule:

```text
A pod with NO NetworkPolicy selecting it = all traffic allowed (default-open).
The moment ANY NetworkPolicy selects a pod, that pod switches to
default-DENY for the direction(s) the policy covers (ingress/egress),
and ONLY the explicitly allowed traffic gets through.
```

So a "default-deny ingress" policy (very common in 2026 zero-trust clusters and service meshes) makes a perfectly healthy Service unreachable: endpoints exist, DNS resolves, `kubectl get pods` is green — but every connection times out. The evidence is not in `describe pod` or logs; it is in `kubectl get networkpolicy` and reading which pods each policy selects.

> Critical caveat: NetworkPolicy is only enforced if the cluster's **CNI plugin supports it** (Calico, Cilium, AWS VPC CNI with policy enforcement enabled). On a plain kind/minikube cluster with the default CNI, policies are *accepted but not enforced*, so the lab below includes a way to confirm enforcement. On EKS, NetworkPolicy enforcement requires the VPC CNI policy feature (or Calico/Cilium) to be turned on.

Diagnostic flow when endpoints + DNS are healthy but traffic times out:

```bash
kubectl get networkpolicy
kubectl describe networkpolicy <name>   # read podSelector + ingress/egress rules
```

#### Service mesh / sidecar interference (conceptual)

In meshed clusters (Istio, Linkerd) every pod gets an injected **sidecar proxy** that intercepts all traffic and often enforces **mTLS**. Symptoms a senior should recognize:

- A pod shows `2/2 Ready` instead of `1/1` (app container + sidecar).
- Traffic fails with TLS / `503 UC`/`upstream connect error` even though the app is fine — usually mTLS or a missing/strict `PeerAuthentication`/`AuthorizationPolicy`.
- A pod that was *not* injected (missing namespace label) can't talk to meshed pods that require mTLS.

You will not configure a mesh in this course, but you must be able to say: "this cluster is meshed, so before blaming the app I check the sidecar, mesh policies, and mTLS." This is increasingly the environment seniors are hired into.

---

## 8. Instructor Talking Points

Use these throughout class:

- “A running pod is not the same as a reachable application.”
- “The Service does not magically know which pods to route to. It uses selectors.”
- “If a Service has no endpoints, traffic has nowhere to go.”
- “Labels and selectors are small fields with big production impact.”
- “`port` is the Service port. `targetPort` is where the pod receives traffic.”
- “DNS tells us whether the name resolves, not whether the application is healthy.”
- “Readiness controls traffic. Liveness controls restarts.”
- “In EKS, after Kubernetes checks, we may need to check AWS Load Balancer Controller, target groups, security groups, and CloudWatch.”
- “Do not jump to AWS load balancer troubleshooting before checking Services and endpoints.”
- “If endpoints exist and DNS resolves but traffic still times out, suspect a NetworkPolicy — selecting a pod with any policy flips it to default-deny.”
- “A NetworkPolicy only does anything if the CNI enforces it. On plain minikube/kind it may be silently ignored.”
- “If the cluster has a service mesh, every pod has a sidecar and probably mTLS — check the mesh before blaming the app.”
- “DNS that returns NXDOMAIN usually means a wrong name or wrong namespace, not a broken app. Test the short name, then the FQDN.”

---

## 9. Whiteboard Explanation

### Whiteboard Title

**Why a Running Pod Can Still Be Unreachable**

```text
User says:
"The app is still down"
        |
        v
Check pod:
kubectl get pods
Pod = Running
        |
        v
Question:
Can traffic reach the pod?
        |
        v
Check Service:
kubectl get svc
kubectl describe svc <service>
        |
        v
Check selector:
Does Service selector match pod labels?
kubectl get pods --show-labels
        |
        v
Check endpoints:
kubectl get endpoints <service>
Endpoints exist?
        |
        v
Check ports:
Service port → targetPort → container port
        |
        v
Check DNS:
Test from another pod
nslookup <service>
wget/curl http://<service>
        |
        v
Check readiness:
Is the pod ready to receive traffic?
        |
        v
Endpoints + DNS OK but STILL blocked?
Check NetworkPolicy (and mesh/mTLS if meshed)
kubectl get networkpolicy
        |
        v
Validate:
port-forward, internal test pod, rollout status
```

### Whiteboard Summary

```text
Pod Running    = container process exists
Pod Ready      = Kubernetes allows traffic
Service Endpoint = Service found matching pods
DNS Resolution = Service name resolves
NetworkPolicy  = traffic is permitted between pods (default-deny once selected)
Successful Response = application is actually reachable
```

---

## 10. Instructor Demo Guide

# Demo: Pod Running but Service Unreachable

## Demo Goal

Show students that a pod can be `Running` while the application is unreachable because the Service selector does not match pod labels.

## Demo Story

> In Class 1, we fixed the failed deployment. The pod is now running. But the application team still cannot reach the service. We need to investigate the traffic path.

---

## Demo Setup

Create namespace:

```bash
kubectl create namespace week12-class2-demo
kubectl config set-context --current --namespace=week12-class2-demo
```

Expected:

```text
namespace/week12-class2-demo created
Context modified.
```

Create `demo-app.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inventory-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: inventory-api
  template:
    metadata:
      labels:
        app: inventory-api
    spec:
      containers:
      - name: inventory-api
        image: nginx:1.25
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: inventory-service
spec:
  type: ClusterIP
  selector:
    app: inventory-web
  ports:
  - port: 80
    targetPort: 80
```

Apply:

```bash
kubectl apply -f demo-app.yaml
```

Expected:

```text
deployment.apps/inventory-api created
service/inventory-service created
```

---

## Demo Step 1: Confirm Pod Is Running

Run:

```bash
kubectl get pods
```

Expected:

```text
NAME                             READY   STATUS    RESTARTS   AGE
inventory-api-xxxxxxxxxx-xxxxx   1/1     Running   0          1m
```

Instructor says:

> Class 1 taught us to get pods healthy. This pod is healthy. Now we need to prove whether traffic can reach it.

---

## Demo Step 2: Check Service

Run:

```bash
kubectl get svc
```

Expected:

```text
NAME                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
inventory-service   ClusterIP   10.96.100.25    <none>        80/TCP    1m
```

Instructor says:

> The Service exists. But existence does not mean it has backends.

---

## Demo Step 3: Check Endpoints

Run:

```bash
kubectl get endpoints inventory-service
```

Expected:

```text
NAME                ENDPOINTS   AGE
inventory-service   <none>      1m
```

Instructor says:

> This is the key evidence. The Service has no endpoints. That means it is not matching any pods.

---

## Demo Step 4: Compare Selector and Labels

Run:

```bash
kubectl describe svc inventory-service
```

Point out:

```text
Selector: app=inventory-web
```

Run:

```bash
kubectl get pods --show-labels
```

Expected:

```text
NAME                             READY   STATUS    LABELS
inventory-api-xxxxxxxxxx-xxxxx   1/1     Running   app=inventory-api
```

Instructor says:

> The Service is looking for `app=inventory-web`, but the pod is labeled `app=inventory-api`. No match means no endpoints.

---

## Demo Step 5: Fix the Service Selector

Edit Service selector:

```yaml
selector:
  app: inventory-api
```

Apply:

```bash
kubectl apply -f demo-app.yaml
```

> Instructor gotcha — Deployment selectors are immutable: Here we are only changing the **Service** selector, which is safe to re-apply. Do **not** "fix" a label mismatch by editing the **Deployment**'s `spec.selector.matchLabels` and re-applying — `spec.selector` on a Deployment is immutable, and `kubectl apply` will fail with `field is immutable`. To change a Deployment's labels/selector you must delete and recreate the Deployment. The safe fix for a Service/pod mismatch is almost always to change the Service selector (or the pod template labels via a new Deployment), not the Deployment selector.

Validate endpoints:

```bash
kubectl get endpoints inventory-service
```

Expected:

```text
NAME                ENDPOINTS          AGE
inventory-service   10.244.0.12:80     4m
```

Instructor says:

> Now the Service has an endpoint. That means traffic has a backend.

---

## Demo Step 6: Validate with Port Forward

Run:

```bash
kubectl port-forward svc/inventory-service 8080:80
```

In another terminal:

```bash
curl http://localhost:8080
```

Expected output includes:

```html
Welcome to nginx!
```

Instructor says:

> Port-forward is useful for local validation. It bypasses external ingress and load balancers, so it helps isolate whether the Service and pod are working inside Kubernetes.

---

## Demo Step 7: Optional Internal DNS Test

Run:

```bash
kubectl run net-test --image=busybox:1.36 --rm -it -- sh
```

Inside the pod:

```sh
nslookup inventory-service
wget -qO- http://inventory-service
```

Expected DNS behavior:

```text
Name: inventory-service
Address: <cluster-ip>
```

Expected HTTP behavior:

```html
Welcome to nginx!
```

---

## Demo Cleanup

```bash
kubectl delete namespace week12-class2-demo
```

---

## 11. Instructor Facilitation Notes

During the demo and lab, keep asking:

- “The pod is running, so what is the next layer?”
- “Does the Service exist?”
- “Does the Service have endpoints?”
- “Do selector and labels match?”
- “Are the Service port and targetPort correct?”
- “Can we reach it with port-forward?”
- “Can another pod resolve the Service name?”
- “Is readiness allowing traffic?”
- “Where would this issue appear in EKS?”

Give hints in this order:

1. Check pod status.
2. Check Service.
3. Check endpoints.
4. Compare selector and labels.
5. Check ports.
6. Test from inside the cluster.
7. Check readiness.
8. Only then move to cloud-provider layer.

---

## 12. Common Student Confusion Points

| Confusion | Instructor Correction |
|---|---|
| “The pod is running, so the app must be working.” | Running only means the process exists. Reachability requires Service, endpoints, ports, readiness, and sometimes ingress/load balancer. |
| “The Service exists, so traffic should work.” | A Service with no endpoints has no backend pods. |
| “Labels are just metadata.” | Labels are routing-critical. Services use selectors to find pods. |
| “`port` and `targetPort` are the same thing.” | `port` is exposed by the Service. `targetPort` is where the pod receives traffic. |
| “DNS failure means the app is broken.” | DNS failure may mean wrong Service name, namespace issue, or CoreDNS issue. |
| “Readiness and liveness are the same.” | Readiness controls traffic. Liveness controls restarts. |
| “EKS load balancer is always the problem.” | Start inside Kubernetes before troubleshooting AWS load balancer or security groups. |
| “No endpoints means DNS is broken.” | No endpoints usually means selector/label mismatch or pods not ready. |

---

## 13. Enterprise Context

In enterprise EKS environments, Class 2 maps to incidents like:

- A deployment is healthy, but the Service has no endpoints due to label mismatch.
- A Service points to the wrong `targetPort`.
- Readiness probe fails after a new release, so pods do not receive traffic.
- Internal service discovery fails because teams use the wrong namespace or DNS name.
- ALB health checks fail because the Kubernetes Service or targetPort is wrong.
- AWS security groups are blamed, but the actual issue is a Kubernetes selector mismatch.
- CloudWatch shows healthy nodes, but application traffic still fails due to a Service routing issue.
- A default-deny `NetworkPolicy` (or zero-trust mesh) silently blocks a healthy Service whose endpoints and DNS are both fine.
- A service-mesh sidecar enforces mTLS, so an un-injected pod cannot reach a meshed Service even though the Service itself is healthy.
- A teammate calls a Service by its short name from another namespace and gets NXDOMAIN, mistaking it for an outage.

Sample incident communication students should learn:

```text
Impact:
Users cannot reach the inventory-api service.

Symptom:
Pods are Running 1/1, but the Service has no endpoints.

Evidence:
kubectl get endpoints inventory-service shows <none>.
kubectl describe svc shows selector app=inventory-web.
kubectl get pods --show-labels shows pods have app=inventory-api.

Root cause:
Service selector does not match pod labels.

Fix:
Updated Service selector to app=inventory-api.

Validation:
Service endpoints appeared and curl through port-forward returned HTTP 200.
```

---

# SECTION B: Student Class Packet

---

## 1. Student-Facing Class Overview

In Class 1, you learned how to troubleshoot pods that fail to start.

In this class, you will troubleshoot the next common production problem:

```text
Pods are running, but users still cannot reach the application.
```

You will learn how Kubernetes routes traffic using:

- Services
- labels
- selectors
- endpoints
- ports
- targetPorts
- DNS
- readiness probes

By the end of class, you should be able to explain why “pod running” does not always mean “application reachable.”

---

## 2. Key Terms

| Term | Meaning |
|---|---|
| Service | Stable Kubernetes network object used to access pods |
| ClusterIP | Internal-only Service type available inside the cluster |
| Selector | Service rule used to find matching pods |
| Label | Key-value metadata attached to pods and other objects |
| Endpoint | Actual pod IP and port behind a Service |
| Service port | Port exposed by the Service |
| targetPort | Port on the pod/container that receives traffic |
| Service discovery | How applications find other applications in Kubernetes |
| Kubernetes DNS | Internal DNS system that resolves Service names |
| Readiness probe | Determines whether a pod should receive traffic |
| Liveness probe | Determines whether Kubernetes should restart a container |
| `port-forward` | Local test method for reaching a pod or Service |
| Test pod | Temporary pod used to test DNS and connectivity from inside the cluster |

---

## 3. Kubernetes Service Troubleshooting Mental Model

Use this flow when pods are running but the app is unreachable:

```text
1. Confirm pods are running
2. Check the Service exists
3. Check Service selector
4. Check pod labels
5. Check endpoints
6. Check Service port and targetPort
7. Test with port-forward
8. Test DNS from inside the cluster
9. Check readiness probe
10. If endpoints + DNS are fine but traffic still times out: check NetworkPolicy (and mesh/mTLS if meshed)
11. Validate application response
```

The fastest clue is often:

```bash
kubectl get endpoints <service-name>
```

If endpoints are `<none>`, check selectors, labels, and readiness.

---

## 4. Command Reference Table

| Command | Why You Use It |
|---|---|
| `kubectl get pods` | Confirm pods are running and ready |
| `kubectl get pods --show-labels` | Compare pod labels with Service selector |
| `kubectl get svc` | Confirm the Service exists and see Service type/ports |
| `kubectl describe svc <service>` | Inspect selector, ports, and Service details |
| `kubectl get endpoints <service>` | Confirm whether Service has backend pods |
| `kubectl port-forward svc/<service> 8080:80` | Test Service locally without ingress/load balancer |
| `kubectl exec -it <pod> -- sh` | Run commands from inside an existing pod |
| `kubectl run net-test --image=busybox:1.36 --rm -it -- sh` | Start temporary test pod for DNS/connectivity |
| `nslookup <service>` | Test DNS resolution inside the cluster |
| `nslookup <service>.<namespace>` | Test cross-namespace DNS using the namespaced name |
| `wget -qO- http://<service>` | Test HTTP access inside the cluster |
| `kubectl describe pod <pod>` | Check readiness/liveness probe failures |
| `kubectl get networkpolicy` | List NetworkPolicies (suspect when endpoints + DNS are fine but traffic times out) |
| `kubectl describe networkpolicy <name>` | Read the podSelector and ingress/egress allow rules |
| `kubectl get pods -n kube-system -l k8s-app=kube-dns` | Confirm CoreDNS is running before blaming a name |
| `kubectl get events --sort-by=.metadata.creationTimestamp` | View recent Kubernetes events |

---

## 5. Guided Lab

# Lab 12.2: Troubleshoot Kubernetes Service, DNS, and Probe Failures

## Lab Goal

You will **reproduce and then fix** six common reachability failures, climbing the layered model from selector all the way down to network policy and DNS:

1. Easy: Service selector mismatch (empty endpoints)  
2. Medium: wrong Service `targetPort` (endpoints exist, app not listening)  
3. Challenge: readiness probe prevents traffic (pod Running 0/1)  
4. Liveness restart loop (too-aggressive liveness probe restarts a healthy app)  
5. NetworkPolicy blocks traffic (endpoints exist, DNS resolves, still blocked)  
6. Broken DNS (wrong namespace / wrong FQDN → NXDOMAIN)  

## Estimated Time

55 minutes

---

## Lab Setup

Create namespace:

```bash
kubectl create namespace week12-class2-lab
kubectl config set-context --current --namespace=week12-class2-lab
```

Expected:

```text
namespace/week12-class2-lab created
Context modified.
```

---

## Part 1: Easy Issue, Service Selector Mismatch

### Create the broken manifest

Create `easy-selector-mismatch.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inventory-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: inventory-api
  template:
    metadata:
      labels:
        app: inventory-api
    spec:
      containers:
      - name: inventory-api
        image: nginx:1.25
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: inventory-service
spec:
  type: ClusterIP
  selector:
    app: inventory-web
  ports:
  - port: 80
    targetPort: 80
```

Apply:

```bash
kubectl apply -f easy-selector-mismatch.yaml
```

Check pods:

```bash
kubectl get pods
```

Expected:

```text
inventory-api-xxxxxxxxxx-xxxxx   1/1   Running   0
```

Check Service:

```bash
kubectl get svc
```

Check endpoints:

```bash
kubectl get endpoints inventory-service
```

Expected clue:

```text
NAME                ENDPOINTS   AGE
inventory-service   <none>      1m
```

### Investigate

Run:

```bash
kubectl describe svc inventory-service
kubectl get pods --show-labels
```

Compare:

```text
Service selector: app=inventory-web
Pod label:        app=inventory-api
```

### Fix

Update the Service selector:

```yaml
selector:
  app: inventory-api
```

Apply:

```bash
kubectl apply -f easy-selector-mismatch.yaml
```

Validate:

```bash
kubectl get endpoints inventory-service
```

Expected:

```text
inventory-service   <pod-ip>:80
```

Test with port-forward:

```bash
kubectl port-forward svc/inventory-service 8080:80
```

In another terminal:

```bash
curl http://localhost:8080
```

Expected response includes:

```text
Welcome to nginx!
```

---

## Part 2: Medium Issue, Wrong targetPort

### Create the broken manifest

Create `medium-wrong-targetport.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: catalog-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: catalog-api
  template:
    metadata:
      labels:
        app: catalog-api
    spec:
      containers:
      - name: catalog-api
        image: nginx:1.25
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: catalog-service
spec:
  type: ClusterIP
  selector:
    app: catalog-api
  ports:
  - port: 80
    targetPort: 8080
```

Apply:

```bash
kubectl apply -f medium-wrong-targetport.yaml
```

Check pod:

```bash
kubectl get pods
```

Expected:

```text
catalog-api-xxxxxxxxxx-xxxxx   1/1   Running   0
```

Check endpoints:

```bash
kubectl get endpoints catalog-service
```

Expected:

```text
catalog-service   <pod-ip>:8080
```

This looks like there is an endpoint, but the app is not listening on `8080`.

### Test with port-forward

```bash
kubectl port-forward svc/catalog-service 8081:80
```

In another terminal:

```bash
curl http://localhost:8081
```

Likely result:

```text
Empty reply from server
```

or connection failure.

### Investigate

Run:

```bash
kubectl describe svc catalog-service
kubectl get pods --show-labels
kubectl describe pod <catalog-pod-name>
```

Look for:

```text
Service targetPort: 8080
Container port: 80
```

### Fix

Change:

```yaml
targetPort: 8080
```

To:

```yaml
targetPort: 80
```

Apply:

```bash
kubectl apply -f medium-wrong-targetport.yaml
```

Validate:

```bash
kubectl port-forward svc/catalog-service 8081:80
```

In another terminal:

```bash
curl http://localhost:8081
```

Expected response includes:

```text
Welcome to nginx!
```

---

## Part 3: Challenge Issue, Readiness Probe Failure

### Create the broken manifest

Create `challenge-readiness.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: billing-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: billing-api
  template:
    metadata:
      labels:
        app: billing-api
    spec:
      containers:
      - name: billing-api
        image: nginx:1.25
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /healthz
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: billing-service
spec:
  type: ClusterIP
  selector:
    app: billing-api
  ports:
  - port: 80
    targetPort: 80
```

Apply:

```bash
kubectl apply -f challenge-readiness.yaml
```

Check pod:

```bash
kubectl get pods
```

Expected:

```text
billing-api-xxxxxxxxxx-xxxxx   0/1   Running   0
```

Important:

The pod is running but not ready.

Check endpoints:

```bash
kubectl get endpoints billing-service
```

Possible expected clue:

```text
billing-service   <none>
```

### Investigate

Run:

```bash
kubectl describe pod <billing-pod-name>
```

Look for readiness probe failure:

```text
Readiness probe failed: HTTP probe failed with statuscode: 404
```

Explanation:

Nginx is running, but `/healthz` does not exist, so readiness fails. Kubernetes does not consider the pod ready for traffic.

### Fix Option 1

Change readiness probe path from:

```yaml
path: /healthz
```

To:

```yaml
path: /
```

Apply:

```bash
kubectl apply -f challenge-readiness.yaml
```

Validate:

```bash
kubectl get pods
kubectl get endpoints billing-service
```

Expected:

```text
billing-api-xxxxxxxxxx-xxxxx   1/1   Running   0
```

```text
billing-service   <pod-ip>:80
```

Test:

```bash
kubectl port-forward svc/billing-service 8082:80
```

In another terminal:

```bash
curl http://localhost:8082
```

Expected response includes:

```text
Welcome to nginx!
```

---

## Part 4: Liveness Restart Loop (Too-Aggressive Liveness Probe)

> How this object works (1-minute primer): A **liveness probe** asks "should Kubernetes *restart* this container?" If the probe fails enough times, the kubelet kills and restarts the container. This is different from readiness (which only controls traffic). A liveness probe that points at a path the app does not serve — or that fires before a slow app has started — will restart a perfectly healthy container over and over, producing a restart loop that looks like an application crash but is actually a misconfigured probe.

This lab points a liveness probe at `/healthz` (which nginx does not serve → 404) so Kubernetes keeps restarting a healthy nginx.

Create `liveness-loop.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shipping-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: shipping-api
  template:
    metadata:
      labels:
        app: shipping-api
    spec:
      containers:
      - name: shipping-api
        image: nginx:1.25
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /healthz
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 5
          failureThreshold: 1
```

Apply:

```bash
kubectl apply -f liveness-loop.yaml
```

Watch the restart count climb over ~60 seconds:

```bash
kubectl get pods -w
```

Expected clue (RESTARTS keeps increasing; the app itself is fine):

```text
NAME                            READY   STATUS    RESTARTS      AGE
shipping-api-xxxxxxxxxx-xxxxx   1/1     Running   3 (10s ago)   70s
```

Investigate — this is the key distinction: the app is *not* crashing. Read the events:

```bash
kubectl describe pod <pod-name>
```

Look for:

```text
Warning  Unhealthy  Liveness probe failed: HTTP probe failed with statuscode: 404
Normal   Killing    Container shipping-api failed liveness probe, will be restarted
```

Question:

Is the application broken, or is Kubernetes killing a healthy app because the liveness probe is wrong? (Contrast with the readiness lab: readiness made the pod `0/1` with no restarts; liveness *restarts* the container.)

### Fix

Point the liveness probe at a path nginx actually serves (and give it sane timing):

```yaml
livenessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 10
  failureThreshold: 3
```

Apply and validate:

```bash
kubectl apply -f liveness-loop.yaml
kubectl get pods
```

Success: `RESTARTS` stops climbing and stabilizes.

```text
shipping-api-xxxxxxxxxx-xxxxx   1/1   Running   0
```

---

## Part 5: NetworkPolicy Blocks Traffic (Endpoints Exist, DNS Resolves, Still Blocked)

> How this object works (1-minute primer): A `NetworkPolicy` controls which traffic is allowed to/from the pods it selects. A pod with no policy is open. The instant *any* ingress policy selects a pod, that pod becomes **default-deny for ingress** — only explicitly allowed sources can connect. This is the classic "everything is green but nothing connects" failure.

> Enforcement check FIRST: NetworkPolicy only takes effect if your CNI enforces it. On plain minikube/kind with the default CNI it is often ignored. If you are on kind, recreate the cluster with a policy-capable CNI (e.g. Calico) or use minikube with `--cni=calico`. If your cluster does not enforce policy, treat this part as a read-along: the manifest and diagnostic flow are exactly what you would run, but the block will not happen.

### Set up a working Service first

Create `np-target.yaml`:

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
      - name: orders-api
        image: nginx:1.25
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: orders-service
spec:
  type: ClusterIP
  selector:
    app: orders-api
  ports:
  - port: 80
    targetPort: 80
```

Apply and confirm it works BEFORE adding the policy:

```bash
kubectl apply -f np-target.yaml
kubectl get endpoints orders-service          # should show <pod-ip>:80
kubectl run net-test --image=busybox:1.36 --rm -it -- \
  wget -qO- -T 5 http://orders-service
```

Expected: `Welcome to nginx!` — baseline reachability confirmed.

### Now break it with a default-deny ingress policy

Create `np-deny.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: orders-default-deny-ingress
spec:
  podSelector:
    matchLabels:
      app: orders-api
  policyTypes:
  - Ingress
  # No ingress rules listed = deny ALL ingress to selected pods
```

Apply:

```bash
kubectl apply -f np-deny.yaml
```

Reproduce the failure — note that endpoints and DNS are still perfectly healthy:

```bash
kubectl get endpoints orders-service          # STILL shows <pod-ip>:80
kubectl run net-test --image=busybox:1.36 --rm -it -- \
  sh -c "nslookup orders-service; wget -qO- -T 5 http://orders-service"
```

Expected clue: DNS resolves fine, but the `wget` hangs and then fails:

```text
Name:      orders-service
Address 1: 10.96.x.x orders-service...
wget: download timed out
```

Investigate — this is the lesson: the previous layers (pod, endpoints, DNS) all pass, so the cause must be network policy:

```bash
kubectl get networkpolicy
kubectl describe networkpolicy orders-default-deny-ingress
```

Read the `PodSelector` and the (empty) `Allowing ingress traffic` section — it confirms all ingress to `app=orders-api` is denied.

### Fix

Allow ingress from the pods that legitimately need it. For the lab, allow traffic from any pod carrying `role: client` (least-privilege beats "allow all"):

Create `np-allow.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: orders-allow-client-ingress
spec:
  podSelector:
    matchLabels:
      app: orders-api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: client
    ports:
    - protocol: TCP
      port: 80
```

Apply, then test from a labeled client pod:

```bash
kubectl apply -f np-allow.yaml
kubectl run net-test --image=busybox:1.36 --rm -it --labels="role=client" -- \
  wget -qO- -T 5 http://orders-service
```

Success: `Welcome to nginx!` returns again — but only because the test pod now carries `role: client`. A pod without that label is still (correctly) denied.

> Senior takeaway: NetworkPolicy is intentionally invisible to the pod/Service/DNS layers. When all of those are green and traffic still times out, `kubectl get networkpolicy` is the next move — and the *fix* is an explicit allow rule, not deleting the deny (default-deny is the secure baseline you want to keep).

---

## Part 6: Broken DNS (Wrong Namespace / Wrong FQDN → NXDOMAIN)

> How this works (1-minute primer): Inside a pod, a bare Service name like `orders-service` only resolves if the *calling* pod is in the *same namespace* as the Service. Across namespaces you must use the namespaced name `orders-service.<namespace>` or the full FQDN `orders-service.<namespace>.svc.cluster.local`. Using the wrong name (or wrong namespace) produces an NXDOMAIN — the DNS query itself fails, before any connection is attempted.

This lab reproduces the single most common DNS failure students hit in production: a service in another namespace called by its short name.

### Create a service in its own namespace

```bash
kubectl create namespace orders-prod
kubectl create deployment orders-api --image=nginx:1.25 -n orders-prod
kubectl expose deployment orders-api --name=orders-service --port=80 -n orders-prod
```

### Reproduce the failure from the lab namespace

From a test pod in the *default lab* namespace, the short name will NOT resolve (the Service lives in `orders-prod`):

```bash
kubectl run net-test --image=busybox:1.36 --rm -it -- \
  nslookup orders-service
```

Expected clue (NXDOMAIN — the name does not exist in this namespace's search domain):

```text
Server:    10.96.0.10
Address:   10.96.0.10:53

** server can't find orders-service: NXDOMAIN
```

Investigate — confirm CoreDNS itself is healthy (so this is a *name*, not a *CoreDNS*, problem):

```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl get svc -n orders-prod orders-service
```

CoreDNS pods are Running, and the Service exists — just in a different namespace.

### Fix

Use the namespaced name or full FQDN:

```bash
kubectl run net-test --image=busybox:1.36 --rm -it -- \
  sh -c "nslookup orders-service.orders-prod; wget -qO- http://orders-service.orders-prod.svc.cluster.local"
```

Expected: the name resolves to the ClusterIP and `Welcome to nginx!` is returned.

> Recognize the other broken-DNS modes: if even the FQDN returns NXDOMAIN/SERVFAIL for *every* name, suspect CoreDNS itself — check `kubectl get pods -n kube-system -l k8s-app=kube-dns` and `kubectl logs -n kube-system -l k8s-app=kube-dns`. A working name from one pod but not another can be a per-pod `dnsPolicy`/`resolv.conf` issue.

### Cleanup for this part

```bash
kubectl delete namespace orders-prod
```

---

## Optional DNS Test

Start a temporary test pod:

```bash
kubectl run net-test --image=busybox:1.36 --rm -it -- sh
```

Inside the pod:

```sh
nslookup inventory-service
nslookup catalog-service
nslookup billing-service
wget -qO- http://inventory-service
wget -qO- http://catalog-service
wget -qO- http://billing-service
```

Expected:

- Service names resolve to ClusterIP addresses.
- HTTP requests succeed after fixes.

---

## Final Lab Validation

Run:

```bash
kubectl get pods
kubectl get svc
kubectl get endpoints
```

Success criteria:

```text
All pods are Running and Ready
All Services exist
All Services have endpoints
Port-forward or internal test pod returns successful HTTP response
```

---

## Cleanup

```bash
kubectl delete namespace week12-class2-lab
```

Expected:

```text
namespace "week12-class2-lab" deleted
```

---

## 6. Independent Troubleshooting Challenge

## Scenario

A production deployment was fixed after Class 1 style issues. The pod is now running.

However, users still cannot access the service.

Starting evidence:

```text
kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
payments-api-xxxxxxxx-xxxxx   1/1     Running   0          10m
```

```text
kubectl get svc
NAME               TYPE        CLUSTER-IP      PORT(S)
payments-service   ClusterIP   10.96.55.100    80/TCP
```

```text
kubectl get endpoints payments-service
NAME               ENDPOINTS   AGE
payments-service   <none>      10m
```

Your task:

1. Identify the most likely root cause.
2. List the commands you would run next.
3. Explain what each command tells you.
4. Describe the fix.
5. Describe how you would validate recovery.
6. Write a short status update for the application team.

Suggested commands:

```bash
kubectl describe svc payments-service
kubectl get pods --show-labels
kubectl describe pod <pod-name>
kubectl get endpoints payments-service
kubectl port-forward svc/payments-service 8080:80
```

Expected root cause:

The Service selector does not match the pod labels, or the pod is not ready.

---

## 7. Reflection Questions

Answer after the lab:

1. Why can a pod be running while the application is unreachable?
2. What does it mean when a Service has no endpoints?
3. How do labels and selectors affect Service routing?
4. What is the difference between `port` and `targetPort`?
5. When would you use `kubectl port-forward`?
6. Why do we test from inside the cluster with a temporary pod?
7. What does a readiness probe control?
8. How would this troubleshooting process change in EKS with an ALB?
9. Why should you check Kubernetes Services before blaming AWS security groups?
10. What would you include in a production incident update?

---

## 8. Homework Assignment

# Homework: Kubernetes Service Troubleshooting Checklist

Create a Markdown file named:

```text
week12-class2-service-troubleshooting-checklist.md
```

Your checklist must include:

1. How to confirm pods are running.
2. How to inspect Services.
3. How to compare Service selectors and pod labels.
4. How to check endpoints.
5. How to troubleshoot wrong `port` and `targetPort`.
6. How to test with `port-forward`.
7. How to test DNS from inside the cluster, including the namespaced name / FQDN and how to spot NXDOMAIN.
8. How to troubleshoot readiness probe failures.
9. How to recognize a liveness restart loop and distinguish it from an app crash.
10. How to suspect and confirm a NetworkPolicy when endpoints and DNS are healthy but traffic is blocked (and the CNI-enforcement caveat).
11. How to decide whether the issue is Kubernetes-level or AWS/EKS-level.
12. One short section comparing EKS, AKS, and GKE troubleshooting, plus a note on service-mesh/sidecar (mTLS) interference.

Required command examples:

```bash
kubectl get pods
kubectl get pods --show-labels
kubectl get svc
kubectl describe svc <service-name>
kubectl get endpoints <service-name>
kubectl port-forward svc/<service-name> 8080:80
kubectl run net-test --image=busybox:1.36 --rm -it -- sh
kubectl describe pod <pod-name>
kubectl get networkpolicy
kubectl describe networkpolicy <name>
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl get events --sort-by=.metadata.creationTimestamp
```

Suggested format:

```markdown
# Kubernetes Service Troubleshooting Checklist

## Step 1: Confirm pod health

## Step 2: Check Service

## Step 3: Check endpoints

## Step 4: Compare labels and selectors

## Step 5: Check ports and targetPorts

## Step 6: Test DNS and connectivity (short name, namespaced name, FQDN)

## Step 7: Check readiness and liveness (traffic vs restarts)

## Step 8: Check NetworkPolicy when endpoints + DNS are healthy but traffic is blocked

## Step 9: Validate recovery

## EKS production notes

## AKS/GKE comparison notes

## Service-mesh / sidecar (mTLS) notes
```

---

## 9. End-of-Week Summary for Students

This week, you learned how to troubleshoot Kubernetes application failures in two layers.

Class 1 focused on workload startup issues:

```text
ImagePullBackOff
CrashLoopBackOff
CreateContainerConfigError
Pending
Logs
Events
Pod describe output
```

Class 2 focused on traffic and reachability issues:

```text
Services
Labels
Selectors
Endpoints
Ports
targetPorts
DNS (including broken DNS / NXDOMAIN)
Readiness
Liveness restart loops
NetworkPolicy (default-deny)
Service-mesh / mTLS awareness
Port-forward
Internal connectivity testing
```

The most important Week 12 lesson:

```text
A healthy Kubernetes application requires both workload health and traffic health.
```

---

# SECTION C: Assessment and Validation

---

## 1. Knowledge Check With Answer Key

### Question 1

A pod is `1/1 Running`, but users cannot reach the application. What should you check next?

A. Delete the pod immediately  
B. Check the Service, endpoints, labels, and selectors  
C. Reinstall Kubernetes  
D. Delete the namespace

**Answer:** B  
**Explanation:** A running pod does not prove Service routing works. Check Service configuration and endpoints next.

---

### Question 2

What does it usually mean when `kubectl get endpoints my-service` shows `<none>`?

A. The Service has no matching ready pods  
B. The cluster has no nodes  
C. The namespace is deleted  
D. DNS is always broken

**Answer:** A  
**Explanation:** No endpoints usually means selector mismatch, pods not ready, or no matching pods.

---

### Question 3

Which command helps compare pod labels with a Service selector?

A. `kubectl get pods --show-labels`  
B. `kubectl version`  
C. `kubectl get nodes`  
D. `kubectl delete svc`

**Answer:** A  
**Explanation:** This command shows pod labels so you can compare them with the Service selector.

---

### Question 4

In a Service, what does `targetPort` represent?

A. The port exposed by the Service only  
B. The port on the pod/container where traffic is sent  
C. The node SSH port  
D. The DNS port

**Answer:** B  
**Explanation:** `targetPort` is where the Service forwards traffic on the backend pod.

---

### Question 5

What does a readiness probe control?

A. Whether Kubernetes sends traffic to a pod  
B. Whether the image is pulled  
C. Whether DNS exists  
D. Whether the namespace is created

**Answer:** A  
**Explanation:** Readiness determines if a pod should receive traffic.

---

### Question 6

What does a liveness probe control?

A. Whether Kubernetes restarts a container  
B. Whether a Service has a ClusterIP  
C. Whether a pod has a label  
D. Whether a container image exists

**Answer:** A  
**Explanation:** Liveness determines if Kubernetes should restart the container.

---

### Question 7

Why is `kubectl port-forward` useful?

A. It deletes broken Services  
B. It lets you test access to a pod or Service locally without external ingress/load balancer  
C. It changes DNS records  
D. It modifies IAM permissions

**Answer:** B  
**Explanation:** Port-forward helps isolate internal Kubernetes reachability from external networking issues.

---

### Question 8

Why might a Service exist but still not work?

A. It may have no endpoints  
B. It may have a wrong selector  
C. It may have a wrong targetPort  
D. All of the above

**Answer:** D  
**Explanation:** Service existence does not guarantee correct routing.

---

### Question 9

In EKS, after confirming Kubernetes Service and endpoints are healthy, what might you check next for external traffic issues?

A. AWS Load Balancer Controller, ALB/NLB target groups, security groups, and CloudWatch  
B. Local laptop wallpaper  
C. Git commit author only  
D. Browser theme

**Answer:** A  
**Explanation:** Once Kubernetes internals are healthy, external exposure may involve AWS load balancers, target groups, and security groups.

---

### Question 10

What is the best summary of Class 2?

A. Running pods always mean the app works  
B. Service routing depends on selectors, endpoints, ports, DNS, and readiness  
C. DNS fixes every issue  
D. EKS troubleshooting never uses `kubectl`

**Answer:** B  
**Explanation:** Class 2 focuses on how Kubernetes routes traffic to healthy pods.

---

### Question 11

A Service has endpoints, `nslookup` resolves the name to the ClusterIP, the pod is `1/1 Running`, but every connection from another pod times out. What should you check next?

A. The image tag  
B. A NetworkPolicy selecting the target pod (default-deny once any policy selects it)  
C. The container's exit code  
D. The deployment revision history

**Answer:** B  
**Explanation:** When pod, endpoints, and DNS are all healthy but traffic still times out, a NetworkPolicy is the classic cause — selecting a pod with any ingress policy switches it to default-deny. Check `kubectl get networkpolicy`. (Note: enforcement requires a policy-capable CNI.)

---

### Question 12

A pod's `RESTARTS` count keeps climbing every few seconds, but `kubectl describe pod` shows `Liveness probe failed: statuscode 404` and the app logs look normal. What is happening?

A. The application is crashing on startup  
B. A too-aggressive/misconfigured liveness probe is restarting a healthy container  
C. The image cannot be pulled  
D. The Service selector is wrong

**Answer:** B  
**Explanation:** Liveness controls restarts. A liveness probe pointed at a path the app does not serve (or firing before a slow app is ready) restarts a healthy container in a loop. The fix is to correct the probe path/timing, not the app. Contrast with readiness, which would leave the pod `0/1` with no restarts.

---

## 2. Lab Success Criteria

Students successfully complete the lab when they can show:

| Requirement | Success Criteria |
|---|---|
| Namespace created | `week12-class2-lab` exists during lab |
| Easy issue fixed | `inventory-service` has endpoints and returns response |
| Medium issue fixed | `catalog-service` uses correct `targetPort` and returns response |
| Challenge issue fixed | `billing-api` becomes `1/1 Running` and `billing-service` has endpoints |
| Liveness loop reproduced and fixed | `shipping-api` showed climbing `RESTARTS` + `Liveness probe failed`, then stabilized at 0 restarts |
| NetworkPolicy block reproduced and fixed | `orders-api` was reachable, blocked by default-deny ingress (endpoints/DNS still healthy), then reachable again via an explicit allow rule (CNI permitting) |
| Broken DNS reproduced and fixed | Short name returned NXDOMAIN cross-namespace; resolved using `.<namespace>` / FQDN |
| DNS tested | Student can resolve Service names from inside the cluster |
| Evidence captured | Student notes include commands and findings |
| Root cause explained | Student explains selector, port, or readiness issue clearly |
| Validation completed | Student uses endpoints, port-forward, or internal test pod |
| Cleanup completed | Lab namespace deleted |

---

## 3. Troubleshooting Rubric

| Criteria | Excellent | Good | Needs Improvement |
|---|---|---|---|
| Troubleshooting flow | Follows pod → Service → endpoints → labels → ports → DNS → readiness | Misses one or two steps | Randomly tries fixes |
| Service understanding | Clearly explains Service, selector, endpoint relationship | Understands most pieces | Confuses Service and pod behavior |
| Command usage | Uses commands with clear purpose | Uses commands but explanation is limited | Runs commands without understanding |
| Root cause analysis | Identifies exact selector, port, DNS, or readiness issue | Identifies general area | Misidentifies issue |
| Fix quality | Applies minimal correct fix | Fix works but explanation is weak | Fix is accidental |
| Validation | Validates with endpoints and actual traffic test | Checks only pod status | Does not validate |
| Enterprise communication | Explains impact, evidence, root cause, fix, validation | Explains most items | Explanation is unclear |

---

## 4. Student Outcome Checklist

By the end of Class 2, students should be able to:

- [ ] Explain why a running pod may still be unreachable.
- [ ] Use `kubectl get svc` to inspect Services.
- [ ] Use `kubectl describe svc` to inspect selectors and ports.
- [ ] Use `kubectl get endpoints` to check Service backends.
- [ ] Use `kubectl get pods --show-labels` to compare labels and selectors.
- [ ] Explain the difference between `port` and `targetPort`.
- [ ] Use `kubectl port-forward` to test Service reachability.
- [ ] Use a temporary test pod to test DNS and connectivity.
- [ ] Explain basic Kubernetes DNS naming.
- [ ] Diagnose readiness probe failures.
- [ ] Reproduce and diagnose a liveness-probe restart loop, and explain why it differs from an app crash.
- [ ] Explain the difference between readiness and liveness.
- [ ] Diagnose a NetworkPolicy as the cause of blocked traffic when endpoints and DNS are healthy.
- [ ] Diagnose a broken-DNS failure (NXDOMAIN) caused by a wrong namespace / wrong name, and confirm CoreDNS health.
- [ ] Recognize service-mesh / sidecar (mTLS) interference conceptually.
- [ ] Connect Kubernetes troubleshooting to EKS production environments.
- [ ] Explain when to check AWS Load Balancer Controller, CloudWatch, and security groups.

---

## 5. Class Completion Checklist

## Instructor Checklist

- [ ] Reviewed Class 1 troubleshooting flow.
- [ ] Explained the Class 2 continuation scenario.
- [ ] Taught Services, selectors, labels, and endpoints.
- [ ] Explained `port` vs `targetPort`.
- [ ] Explained ClusterIP and internal Service access.
- [ ] Taught Kubernetes DNS basics.
- [ ] Explained readiness vs liveness.
- [ ] Explained NetworkPolicy default-deny and CNI enforcement caveat.
- [ ] Explained broken-DNS modes (wrong namespace/FQDN vs CoreDNS down) and service-mesh/mTLS awareness.
- [ ] Ran instructor demo.
- [ ] Guided student lab (selector, targetPort, readiness, liveness, NetworkPolicy, DNS).
- [ ] Reviewed lab findings.
- [ ] Connected troubleshooting to EKS production context.
- [ ] Assigned homework checklist.
- [ ] Closed Week 12 with summary.

## Student Checklist

- [ ] Reviewed Class 1 troubleshooting flow.
- [ ] Completed selector mismatch lab.
- [ ] Completed wrong targetPort lab.
- [ ] Completed readiness probe lab.
- [ ] Completed liveness restart-loop lab.
- [ ] Completed NetworkPolicy block lab (or read-along if CNI does not enforce policy).
- [ ] Completed broken-DNS lab.
- [ ] Tested endpoints.
- [ ] Tested Service access with port-forward.
- [ ] Tested DNS from inside the cluster.
- [ ] Captured root causes and fixes.
- [ ] Cleaned up lab resources.
- [ ] Started homework checklist.

---

## 6. End-of-Week Completion Checklist

By the end of Week 12, students should be able to troubleshoot:

## Workload startup issues from Class 1

- [ ] `ImagePullBackOff`
- [ ] `CrashLoopBackOff`
- [ ] `CreateContainerConfigError`
- [ ] `Pending`
- [ ] Pod logs
- [ ] Kubernetes events
- [ ] Rollout status

## Traffic and reachability issues from Class 2

- [ ] Service selector mismatch
- [ ] Missing endpoints
- [ ] Wrong `targetPort`
- [ ] DNS/service discovery issue (including NXDOMAIN from wrong namespace/FQDN)
- [ ] Readiness probe failure
- [ ] Liveness probe restart loop
- [ ] NetworkPolicy blocking traffic (endpoints + DNS healthy)
- [ ] Service-mesh / sidecar mTLS awareness (conceptual)
- [ ] Port-forward testing
- [ ] Internal test pod connectivity

## Production readiness skill

Students should be able to explain a Kubernetes issue using this structure:

```text
Impact:
Who or what is affected?

Symptom:
What is failing?

Evidence:
What command output proves the issue?

Root cause:
What actually caused the failure?

Fix:
What was changed?

Validation:
How do we know the issue is resolved?
```

## Final Instructor Wrap-Up

Close Week 12 with:

> This week, you moved from basic Kubernetes deployment knowledge into real operational troubleshooting. In Class 1, you learned how to diagnose pods that fail to start. In Class 2, you learned that even running pods can be unreachable if Services, selectors, endpoints, ports, DNS, or readiness are wrong. These are exactly the kinds of issues DevOps Engineers, Cloud Engineers, and SREs troubleshoot in real EKS, AKS, and GKE environments.

---

## Class Artifacts & Validation

This class is backed by two on-disk modules. The Service/endpoints/readiness-probe
fault (running pod, empty endpoints, Service routes nowhere) is the never-Ready
fixture and the Service/NetworkPolicy manifests in
[`labs/kubernetes-fundamentals/`](../../labs/kubernetes-fundamentals/); the
"endpoints exist, DNS resolves, but traffic is still blocked" NetworkPolicy lesson is
**operated and enforcement-proven** by Drill 4 in
[`labs/k8s-production-ops/`](../../labs/k8s-production-ops/). All commands below were
run in this environment (kubectl v1.34.2, a live `kind` cluster, `kubeconform` on
`PATH`); the NetworkPolicy enforcement drill ran on a dedicated Calico kind cluster.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/kubernetes-fundamentals/broken/deployment-badprobe.yaml | kubernetes | Troubleshooting fixture: `readinessProbe.httpGet.port: 9999` → pod **Running but never Ready**, empty Service endpoints; the class's Service-reachability lab | `./validate.sh` (live: reproduce never-Ready + empty endpoints) | PASS — `cluster: reproduce never-Ready probe fixture (empty endpoints)` |
| 2 | labs/kubernetes-fundamentals/solution/base/service.yaml | kubernetes | ClusterIP Service (port 80 → targetPort `http`/8000) — the selector/endpoints/port object students diagnose | `kubectl kustomize solution/base \| kubeconform -strict` (run by `./validate.sh`) | PASS — `kubeconform: -strict on solution/base render` |
| 3 | labs/kubernetes-fundamentals/solution/base/networkpolicy.yaml | kubernetes | `default-deny-all` + `allow-from-ingress` + `allow-dns-egress` — the "silent blocker" the class teaches | `kubectl kustomize solution/base \| kubeconform -strict` (run by `./validate.sh`) | PASS — `kubeconform: -strict on solution/base render` |
| 4 | labs/k8s-production-ops/solution/manifests/netpol/default-deny.yaml | kubernetes | `default-deny-ingress` policy — graded TODO; proven to **block** traffic on an enforcing CNI | `kubeconform -strict` (via `./validate.sh`); live Drill 4 on Calico | PASS — see labs/k8s-production-ops/evidence/LIVE-NETPOL-EVIDENCE.txt (STEP B: `curl_exit=28` BLOCKED) |
| 5 | labs/k8s-production-ops/solution/manifests/netpol/allow-client-to-server.yaml | kubernetes | `allow-client-to-server` policy — graded TODO; re-opens exactly the one flow | `kubeconform -strict` (via `./validate.sh`); live Drill 4 on Calico | PASS — see labs/k8s-production-ops/evidence/LIVE-NETPOL-EVIDENCE.txt (STEP C: `curl_exit=0` ALLOWED) |
| 6 | labs/k8s-production-ops/solution/drills/networkpolicy.sh | shell | Operates the NetworkPolicy proof: ALLOWED → default-deny BLOCKED → allow ALLOWED on a Calico cluster (kindnet does not enforce) | `bash -n` + `shellcheck` (via `./validate.sh`); live `RUN_LIVE=1 ./solution/drills/run-drills.sh` | PASS (static) — see labs/k8s-production-ops/evidence/LIVE-NETPOL-EVIDENCE.txt (`RESULT: PASS — enforcement proven`) |

Live enforcement evidence (real curl exit codes, not prose) is committed at
[`labs/k8s-production-ops/evidence/LIVE-NETPOL-EVIDENCE.txt`](../../labs/k8s-production-ops/evidence/LIVE-NETPOL-EVIDENCE.txt):
`STEP A curl_exit=0 (ALLOWED) → STEP B curl_exit=28 (BLOCKED) → STEP C curl_exit=0
(ALLOWED)` on a Calico kind cluster that is torn down on exit. The never-Ready /
empty-endpoints fault is reproduced live by `kubernetes-fundamentals/validate.sh`.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** (Service / NetworkPolicy manifests, a broken probe fixture, and shell drill scripts — not just fences).
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured (`kubeconform -strict`, `kubectl kustomize`, live `kind`/Calico apply, `bash -n`/`shellcheck`).
- [x] Lab has **starter** (graded `netpol/*` and `pdb.yaml` TODO stubs; `starter/deployment.yaml`) and **solution** (`solution/manifests/`, `solution/base/`) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes**.
- [x] **Cleanup/teardown** is provided and idempotent (each drill creates a unique namespace deleted on exit; Drill 4's Calico cluster is torn down on exit).
- [x] **Instructor answer key** exists (the README "Instructor answer key" with the netpol grading points and selector-inversion gotchas; symptom→cause→fix troubleshooting tables in both module READMEs).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `broken/deployment-badprobe.yaml` (never-Ready, empty endpoints) and the live default-deny block (`curl_exit=28`).
- [x] **Expected outputs** are shown for demos and labs (README "Expected results" + captured live curl exit codes in the evidence file).
- [x] **Cost & security warnings** present (both READMEs' "Security considerations" / "Cost considerations"; $0, local `kind`/Calico only; zero-trust NetworkPolicy baseline).
- [x] **Cross-references** to the module repos and to Week 12 Class 1 (workload faults) / Week 11 (deploy) / Week 21 (senior K8s) are correct.
- [x] The **artifact manifest** (§4.2) above is present and every path resolves (verified with `ls`).
