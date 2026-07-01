# Week 23 — Capstone Build
> **▶ Runnable lab for this class:** [`labs/capstone/`](../../labs/capstone/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 2 Package: Capstone Build — Kubernetes Deployment and Observability

**Week:** 23
**Class:** 2
**Track:** Unified DevOps · Cloud · SRE Track

---

## 1. Class Overview

### Class Title

**Deploying the DevOps Capstone to EKS with Helm, Terraform, and Monitoring**

### Class Purpose

This class continues from Class 1 by taking the Docker image that students built and pushed to Amazon ECR, then deploying it to Amazon EKS using Helm. Students also add deployment validation, rollback documentation, and basic monitoring/logging checks.

Class 1 focused on:

```text
Git repository → Docker build → image scan → Amazon ECR push
```

Class 2 extends that into:

```text
Amazon ECR image → Helm deployment → EKS workload → validation → monitoring → rollback
```

### How This Class Builds From Class 1

In Class 1, students created the capstone foundation:

- Git repository structure
- Application folder
- Dockerfile
- Docker image
- Amazon ECR repository
- Image pushed to ECR
- Initial CI/CD pipeline stages
- Documentation draft

In Class 2, students use that work to complete the first end-to-end DevOps delivery workflow:

- Deploy the ECR image to EKS
- Package Kubernetes manifests with Helm
- Validate pods, services, and logs
- Add a deploy stage to the pipeline
- Document rollback and monitoring steps
- Prepare for Week 24 final presentation

### What Students Will Build, Analyze, or Practice

Students will build or complete:

- A Helm chart for the capstone application
- Environment-specific Helm values
- A Kubernetes namespace
- A Deployment and Service in EKS
- A Helm install or upgrade workflow
- A deployment validation checklist
- A rollback procedure
- Basic monitoring/logging notes
- A CI/CD deploy stage draft
- Updated capstone documentation

---

## 2. Quick Review of Class 1

### Review Points

1. The capstone repository should have clear folders for `app`, `helm`, `terraform`, `docs`, and pipeline files.
2. The Dockerfile packages the application into a container image.
3. The image must be pushed to a registry before Kubernetes can pull it.
4. Amazon ECR is the AWS image registry used by the capstone.
5. Image tags should be traceable, preferably using a Git commit SHA.
6. The pipeline should include validate, test, build, scan, and push stages.
7. ECR push failures are often caused by authentication, permissions, wrong region, or incorrect tagging.
8. Class 2 depends on the image repository and image tag created in Class 1.

### 3 Quick Recall Questions

1. **Why can’t EKS pull an image directly from your laptop?**  
   Because EKS nodes pull images from a container registry, not from a developer’s local machine.

2. **What AWS service stores the container image for this capstone?**  
   Amazon ECR.

3. **Why is a commit SHA image tag better than only using `latest`?**  
   It makes the deployed version traceable to a specific Git commit.

### Common Gaps Students May Still Have From Class 1

| Gap | Instructor Bridge |
|---|---|
| Image was not pushed to ECR | Provide an instructor image temporarily so they can continue the EKS deployment lab |
| Students only used `latest` tag | Show how to pass a specific image tag into Helm |
| Pipeline is incomplete | Let students deploy manually first, then add the deploy stage draft |
| ECR login failed | Review ECR auth quickly, then move forward |
| Dockerfile builds locally but app fails | Use `/health` endpoint and container logs before deploying |
| Students did not document image URI | Have them write it down before starting Helm deployment |

### How the Instructor Should Bridge Into Class 2

Instructor transition:

> Class 1 produced the deployment artifact: the Docker image in ECR. Today we are going to use that artifact in Kubernetes. The main question now is: how do we safely and repeatably deploy that image into EKS, validate it, monitor it, and roll it back if something breaks?

---

## 3. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** how an ECR image becomes a running workload in EKS.
2. **Build** a basic Helm chart for the capstone application.
3. **Configure** Helm values for image repository, image tag, service port, probes, and resources.
4. **Deploy** the capstone application to EKS using `helm upgrade --install`.
5. **Provision** EKS (VPC + node group + IRSA) as code with Terraform/OpenTofu using plan-before-apply discipline.
6. **Expose** the app through a real entry point: Ingress + AWS Load Balancer Controller + TLS (ACM), with port-forward kept as the cheap lab fallback.
7. **Validate** Kubernetes pods, services, events, and logs after deployment.
8. **Deploy** observability — a Prometheus/Grafana (or CloudWatch Container Insights) dashboard and at least one alert wired to a Week 21 SLO/error budget.
9. **Automate** deployment with GitOps (Argo CD) instead of a push-based `manual` job.
10. **Troubleshoot** deployment failures such as `ImagePullBackOff`, readiness probe failures, Helm template errors, and service selector issues.
11. **Document** rollback commands, an SLO-backed runbook, and an ADR for the deployment-mechanism trade-off.
12. **Compare** the AWS EKS deployment pattern with AKS and GKE at a high level.

---

## 4. Prerequisites Students Should Already Know

### Required Class 1 Knowledge

Students should already know:

- How the Docker image was built
- Where the image was pushed in ECR
- Which AWS region was used
- Which image tag should be deployed
- Basic pipeline stage flow
- Basic AWS identity validation

### Required Prior Concepts

Students should understand:

- Kubernetes Pods, Deployments, and Services
- Kubernetes namespaces
- Basic `kubectl` commands
- Helm chart basics
- Docker image tags
- AWS IAM role or user access basics
- Basic CI/CD pipeline structure

### Required Tools Already Installed

| Tool | Required For |
|---|---|
| AWS CLI | Updating EKS kubeconfig and validating AWS identity |
| kubectl | Managing Kubernetes resources |
| Helm | Installing and upgrading the application |
| Docker | Optional local image validation |
| Git | Updating the capstone repository |
| VS Code | Editing Helm and pipeline files |
| Terminal | Running commands |

### Required Files, Repos, Lab Outputs, or Setup From Class 1

Students should have:

```text
devops-capstone/
├── app/
├── helm/
├── terraform/
├── docs/
└── .gitlab-ci.yml or .github/workflows/deploy.yml
```

Required Class 1 outputs:

- ECR repository name
- ECR image URI
- Image tag
- AWS region
- Git repository
- Documentation draft

Example values:

```bash
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="123456789012"
ECR_REPOSITORY="devops-capstone-app"
IMAGE_TAG="a1b2c3d"
ECR_URI="123456789012.dkr.ecr.us-east-1.amazonaws.com/devops-capstone-app"
EKS_CLUSTER_NAME="devops-capstone-cluster"
NAMESPACE="devops-capstone"
```

Infrastructure as Code requirement (senior bar):

The cluster's most expensive and architecturally significant pieces — VPC, EKS control plane, managed node group, IRSA — must be **provisioned as code**, not handed over as a black box. Two supported paths:

- **Recommended:** students `terraform apply` the cluster from the module in Section 13B before class, or in a guided session, using `terraform plan` review first. Because an EKS cluster + NAT + nodes costs roughly $5–$10/day, the class shares ONE cluster and each student deploys into their own namespace; the cluster is `terraform destroy`-ed at the end of the week.
- **Fallback (time-boxed):** an instructor-provisioned cluster, but the Terraform that built it is committed to the repo and walked through, so the infrastructure is still code students can read and reproduce.

Either way, IRSA (pods getting AWS permissions via an OIDC-federated IAM role, no static keys) is taught and used — see Section 13B.

---

## 5. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| EKS | AWS-managed Kubernetes service | Used to run containerized applications on AWS |
| Helm | Kubernetes package manager | Helps teams deploy reusable application templates |
| Helm chart | A package of Kubernetes templates | Standard way to deploy applications consistently |
| Helm values | Configuration inputs for a Helm chart | Used to set image tag, replicas, ports, and environment settings |
| Release | A Helm-managed deployment instance | Allows upgrade, history, and rollback |
| Namespace | Logical space inside Kubernetes | Separates applications, teams, or environments |
| Deployment | Kubernetes object that manages Pods | Controls replicas and rolling updates |
| Pod | Smallest deployable unit in Kubernetes | Runs one or more containers |
| Service | Stable network endpoint for Pods | Allows traffic to reach changing Pods |
| Readiness probe | Check that decides if a Pod can receive traffic | Prevents traffic from going to unhealthy Pods |
| Liveness probe | Check that decides if a Pod should be restarted | Helps recover stuck applications |
| Resource requests | Minimum CPU/memory requested by a container | Helps Kubernetes schedule workloads |
| Resource limits | Maximum CPU/memory a container can use | Prevents one workload from consuming too much |
| Rollback | Returning to a previous working version | Critical during failed production releases |
| CloudWatch | AWS monitoring and logging service | Used for logs, metrics, alarms, and visibility |
| ImagePullBackOff | Kubernetes cannot pull the container image | Common issue with wrong tag, registry, or permissions |

---

## 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| Git | Stores capstone code, Helm chart, pipeline, and documentation |
| AWS CLI | Authenticates to AWS and configures EKS kubeconfig |
| kubectl | Validates and troubleshoots Kubernetes resources |
| Helm | Deploys and upgrades the capstone application |
| EKS | Runs the Kubernetes workload |
| ECR | Provides the container image built in Class 1 |
| CloudWatch | Provides logs and monitoring visibility |
| VS Code | Edits Helm templates and docs |
| GitLab CI or GitHub Actions | Adds deploy automation stage |
| Terraform / OpenTofu | Provisions the EKS cluster, VPC, node group, and IRSA roles as code (Section 13B) |
| Argo CD | GitOps controller that reconciles the app from Git (Section 13C) |
| Prometheus / Grafana / Alertmanager | Deployed observability: metrics, dashboard, and SLO-backed alert (Section 13D) |
| AWS Load Balancer Controller | Turns the Kubernetes Ingress into an ALB with TLS |

---

## 7. AWS Services Used

| AWS Service | How It Connects to Class 2 |
|---|---|
| Amazon EKS | Runs the Kubernetes workload for the capstone |
| Amazon ECR | Stores the Docker image built in Class 1 |
| AWS IAM | Controls access to EKS, ECR, and pipeline deployment permissions |
| AWS STS | Validates active identity |
| Amazon CloudWatch | Used for logs, metrics, and monitoring documentation |
| S3 backend concept | Used as a Terraform remote state concept for capstone infrastructure |
| Elastic Load Balancing | May appear if Service type `LoadBalancer` or ingress is used |

### Cost Warning

EKS clusters, load balancers, NAT gateways, and running compute resources can create ongoing cost. In a training environment, prefer:

- Instructor-provided EKS cluster
- Shared sandbox cluster
- Short-lived namespaces
- Cleanup at the end of the lab
- Avoid creating new LoadBalancers unless required

---

## 8. Azure and GCP Comparison Notes

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Managed Kubernetes | Amazon EKS | Azure Kubernetes Service | Google Kubernetes Engine |
| Container registry | Amazon ECR | Azure Container Registry | Artifact Registry |
| Monitoring | CloudWatch | Azure Monitor | Cloud Monitoring |
| Identity to cluster | IAM and aws-auth/access entries | Azure RBAC and managed identity | Cloud IAM and Workload Identity |

Practical explanation:

```text
Container registry → managed Kubernetes → Helm deployment → monitoring/logging
```

The main differences are identity, registry authentication, cluster access, and monitoring integration.

---

## 9. Time-Boxed Instructor Agenda

| Time | Activity |
|---:|---|
| 0:00 to 0:10 | Opening and Class 1 review |
| 0:10 to 0:25 | Review ECR image, image tag, and EKS deployment goal |
| 0:25 to 0:45 | Whiteboard: ECR to Helm to EKS to CloudWatch flow |
| 0:45 to 1:10 | Helm chart structure and values strategy |
| 1:10 to 1:25 | Kubernetes deployment validation flow |
| 1:25 to 1:35 | Break |
| 1:35 to 2:05 | Instructor demo: deploy to EKS with Helm |
| 2:05 to 2:30 | Student lab: deploy capstone app and validate |
| 2:30 to 2:45 | Add deploy stage draft and rollback documentation |
| 2:45 to 2:55 | Troubleshooting activity |
| 2:55 to 3:00 | Recap, homework, Week 24 readiness checklist |

---

## 10. Instructor Lesson Plan

### Step 1: Open With Continuity From Class 1

Say:

> In Class 1, we created the artifact: a Docker image stored in Amazon ECR. Today we are turning that artifact into a running application on EKS using Helm.

Ask:

- What image tag did you push?
- What is your ECR URI?
- Why does Kubernetes need a registry?

### Step 2: Confirm Starting Point

Have students write these values at the top of their notes:

```bash
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="<ACCOUNT_ID>"
ECR_REPOSITORY="devops-capstone-app"
IMAGE_TAG="<YOUR_IMAGE_TAG>"
EKS_CLUSTER_NAME="<CLUSTER_NAME>"
NAMESPACE="devops-capstone"
```

Teaching tip:

Before moving into Helm, confirm students know their image URI. Many deployment failures start with the wrong image path.

### Step 3: Whiteboard the Deployment Flow

Draw:

```text
ECR image
  ↓
Helm chart
  ↓
EKS Deployment
  ↓
Pod
  ↓
Service
  ↓
Logs and metrics
  ↓
Rollback if needed
```

Explain:

- ECR stores the image.
- Helm renders Kubernetes manifests.
- EKS runs the workload.
- Kubernetes Service exposes the Pods.
- CloudWatch or Kubernetes logs provide visibility.
- Helm history allows rollback.

### Step 4: Explain Helm Chart Structure

Show the files:

```text
helm/capstone-app/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment.yaml
    └── service.yaml
```

Explain:

- `Chart.yaml` describes the chart.
- `values.yaml` contains configurable settings.
- `templates/` contains Kubernetes YAML with variables.
- Helm combines templates and values to create Kubernetes manifests.

Pause and ask:

“What values should change between dev and prod?”

Expected answers:

- image tag
- replica count
- resource settings
- environment variables
- ingress or service type

### Step 5: Explain Deployment Validation

Teach students to validate in layers:

```text
Cluster access → Namespace → Helm render → Helm release → Pod status → Logs → Service → App health
```

Key commands:

```bash
kubectl get nodes
kubectl get ns
helm lint
helm template
helm upgrade --install
kubectl get pods
kubectl logs
kubectl get svc
curl /health
```

### Step 6: Instructor Demo

Deploy a known image to EKS with Helm. Show at least one successful path and one troubleshooting example.

### Step 7: Student Lab

Students create/update their Helm chart and deploy their Class 1 image.

Instructor should circulate and check:

- Correct ECR image URI
- Correct image tag
- Correct namespace
- Helm chart syntax
- Container port matches app port
- Readiness probe path is correct
- Service selector matches Deployment labels

### Step 8: Add Deploy Stage Draft

Have students add a deploy stage to the pipeline. It may be a working deploy stage or a documented draft depending on environment access.

### Step 9: Troubleshooting Activity

Give students a failed deployment scenario. Ask them to identify the failing layer.

### Step 10: Close With Week 24 Readiness

Say:

> Week 24 is not for building from zero. It is for final polish, demo readiness, documentation, and presentation. Your Class 2 output should be a working deployment or a clearly documented deployment workflow with known blockers.

---

## 11. Instructor Lecture Notes

### Big Idea: Class 2 Completes the Delivery Loop

In Class 1, students created the artifact. In Class 2, they deploy and validate it.

Talking point:

> A DevOps workflow is not complete when the image is built. It becomes useful when that image can be deployed, validated, monitored, and rolled back.

### Why Helm Is Used

Raw Kubernetes YAML works for simple cases, but real teams need reuse and configuration. Helm helps package Kubernetes manifests so teams can deploy the same app to multiple environments.

Beginner explanation:

> Think of Helm as a template system for Kubernetes. Instead of copying and editing YAML for every environment, you create one chart and pass different values.

Enterprise example:

A platform team may provide a standard Helm chart that includes:

- Deployment
- Service
- Ingress
- probes
- resource requests
- labels
- annotations
- monitoring defaults

Application teams only change values.

### Why Readiness and Liveness Probes Matter

Without readiness probes, Kubernetes may send traffic to a Pod before the app is ready.

Without liveness probes, a stuck app may stay broken without restart.

Talking point:

> A Pod being `Running` does not always mean the application is healthy.

### Why Resource Requests and Limits Matter

Resource requests help Kubernetes schedule Pods. Limits prevent containers from consuming too many resources.

Common misconception:

> If I do not set requests and limits, Kubernetes will just handle it.

Correction:

> Kubernetes can run the Pod, but scheduling, scaling, and stability become less predictable.

### Why Rollback Must Be Practiced

A rollback plan that is never tested is only a theory. Helm gives release history and rollback commands, but students must know when and how to use them.

Talking point:

> In production, rollback speed matters. During an incident, you do not want to discover your rollback command for the first time.

### Why Monitoring Is Included

A deployment is not complete just because Helm says it succeeded. Students must validate:

- Pod status
- logs
- service endpoint
- application health endpoint
- basic metrics or monitoring plan

Talking point:

> Deployment success means the application is running and observable, not just that the command returned zero.

---

## 12. Whiteboard Explanation

### Simple Class 2 Diagram

```text
Class 1 Output:
[Amazon ECR Image]
        |
        | image.repository + image.tag
        v
[Helm Chart]
        |
        | helm upgrade --install
        v
[Amazon EKS Cluster]
        |
        v
[Kubernetes Deployment]
        |
        v
[Pods]
        |
        v
[Kubernetes Service]
        |
        v
[Application Health Check]
        |
        v
[Logs / Metrics / Rollback]
```

### Step-by-Step Flow

1. Student identifies the ECR image from Class 1.
2. Student places image repository and tag into Helm values.
3. Helm renders Kubernetes manifests.
4. Helm installs or upgrades the release in EKS.
5. Kubernetes creates the Deployment.
6. Deployment creates Pods.
7. Pods pull the image from ECR.
8. Service routes traffic to matching Pods.
9. Student validates logs and health endpoint.
10. Student documents rollback and monitoring checks.

### What Each Component Means

| Component | Meaning |
|---|---|
| ECR image | Built artifact from Class 1 |
| Helm chart | Reusable deployment package |
| EKS cluster | Kubernetes platform running on AWS |
| Deployment | Controls desired Pod state |
| Pod | Runs the app container |
| Service | Stable network endpoint |
| Logs/metrics | Visibility into app behavior |
| Rollback | Recovery path if deployment fails |

### Enterprise Version

```text
[Merge Request Approved]
        |
        v
[Pipeline Build + Scan]
        |
        v
[Amazon ECR]
        |
        v
[Deploy to Dev with Helm]
        |
        v
[Automated Smoke Test]
        |
        v
[Approval Gate]
        |
        v
[Deploy to Staging/Prod]
        |
        v
[CloudWatch / Datadog / Grafana]
        |
        v
[Runbook + Rollback + Incident Process]
```

### How Class 2 Extends Class 1

```text
Class 1 answered:
Can we build and publish the application image?

Class 2 answers:
Can we deploy, validate, observe, and roll back that image safely?
```

---

## 13. Instructor Demo Script

### Demo Title

**Deploy the Capstone Application to EKS Using Helm**

### Demo Objective

Show students how to deploy the Class 1 ECR image to EKS using Helm, validate the deployment, inspect logs, and perform a rollback.

### Required Setup

Instructor needs:

- Existing EKS cluster
- AWS CLI configured
- kubectl installed
- Helm installed
- ECR image already pushed
- IAM permissions for EKS access
- Sample Helm chart folder

Set variables:

```bash
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID="<ACCOUNT_ID>"
export EKS_CLUSTER_NAME="<EKS_CLUSTER_NAME>"
export NAMESPACE="devops-capstone"
export ECR_REPOSITORY="devops-capstone-app"
export IMAGE_TAG="<IMAGE_TAG_FROM_CLASS_1>"
export ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"
```

### Step 1: Validate AWS Identity

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:role/DevOpsInstructorRole"
}
```

Explain:

“Before touching a cluster, confirm which AWS identity you are using.”

### Step 2: Configure kubeconfig for EKS

```bash
aws eks update-kubeconfig   --region $AWS_REGION   --name $EKS_CLUSTER_NAME
```

Expected output:

```text
Updated context arn:aws:eks:us-east-1:123456789012:cluster/devops-capstone-cluster in kubeconfig
```

Explain:

“This command updates local Kubernetes configuration so kubectl can talk to the EKS cluster.”

### Step 3: Validate Cluster Access

```bash
kubectl get nodes
```

Expected output:

```text
NAME                            STATUS   ROLES    AGE   VERSION
ip-10-0-1-10.ec2.internal       Ready    <none>   2d    v1.29.x
```

If this fails, explain:

“This is an access or kubeconfig issue, not a Helm issue yet.”

### Step 4: Create Namespace

```bash
kubectl create namespace $NAMESPACE
```

If namespace already exists:

```text
Error from server (AlreadyExists): namespaces "devops-capstone" already exists
```

Recovery:

```bash
kubectl get ns $NAMESPACE
```

Explain:

“Namespaces help separate applications, teams, or environments.”

### Step 5: Create Helm Chart Files

If chart does not already exist:

```bash
mkdir -p helm/capstone-app/templates
```

Create `helm/capstone-app/Chart.yaml`:

```yaml
apiVersion: v2
name: capstone-app
description: Helm chart for the DevOps capstone application
type: application
version: 0.1.0
appVersion: "1.0.0"
```

Create `helm/capstone-app/values.yaml`:

```yaml
replicaCount: 2

image:
  repository: ""
  tag: ""
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

container:
  port: 8080

resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"

probes:
  readinessPath: /health
  livenessPath: /health
```

Create `helm/capstone-app/templates/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
  labels:
    app: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
        - name: capstone-app
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.container.port }}
          readinessProbe:
            httpGet:
              path: {{ .Values.probes.readinessPath }}
              port: {{ .Values.container.port }}
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: {{ .Values.probes.livenessPath }}
              port: {{ .Values.container.port }}
            initialDelaySeconds: 15
            periodSeconds: 20
          resources:
{{ toYaml .Values.resources | indent 12 }}
```

Create `helm/capstone-app/templates/service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}
  labels:
    app: {{ .Release.Name }}
spec:
  type: {{ .Values.service.type }}
  selector:
    app: {{ .Release.Name }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      protocol: TCP
```

### Step 6: Lint Helm Chart

```bash
helm lint ./helm/capstone-app
```

Expected output:

```text
1 chart(s) linted, 0 chart(s) failed
```

Explain:

“Linting catches chart structure and syntax problems before deployment.”

### Step 7: Render the Chart Before Deploying

```bash
helm template devops-capstone-app ./helm/capstone-app   --namespace $NAMESPACE   --set image.repository=$ECR_URI   --set image.tag=$IMAGE_TAG
```

Expected output should include:

```yaml
kind: Deployment
metadata:
  name: devops-capstone-app
...
image: "123456789012.dkr.ecr.us-east-1.amazonaws.com/devops-capstone-app:a1b2c3d"
```

Explain:

“Always check the rendered manifest when troubleshooting Helm.”

### Step 8: Deploy With Helm

```bash
helm upgrade --install devops-capstone-app ./helm/capstone-app   --namespace $NAMESPACE   --set image.repository=$ECR_URI   --set image.tag=$IMAGE_TAG
```

Expected output:

```text
Release "devops-capstone-app" does not exist. Installing it now.
NAME: devops-capstone-app
NAMESPACE: devops-capstone
STATUS: deployed
REVISION: 1
```

### Step 9: Validate Kubernetes Resources

```bash
kubectl get pods -n $NAMESPACE
```

Expected output:

```text
NAME                                  READY   STATUS    RESTARTS   AGE
devops-capstone-app-xxxxxxx-yyyyy     1/1     Running   0          30s
```

```bash
kubectl get svc -n $NAMESPACE
```

Expected output:

```text
NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)
devops-capstone-app   ClusterIP   172.20.x.x      <none>        80/TCP
```

### Step 10: Validate Logs

```bash
kubectl logs -n $NAMESPACE deployment/devops-capstone-app
```

Expected output:

```text
App listening on port 8080
```

### Step 11: Port Forward and Test Health

```bash
kubectl port-forward -n $NAMESPACE svc/devops-capstone-app 8080:80
```

In another terminal:

```bash
curl http://localhost:8080/health
```

Expected output:

```json
{"status":"healthy"}
```

Explain:

“Port forwarding is a safe lab method when we do not want to create a cloud load balancer.”

### Step 12: Show Helm History

```bash
helm history devops-capstone-app -n $NAMESPACE
```

Expected output:

```text
REVISION UPDATED                  STATUS    CHART              APP VERSION DESCRIPTION
1        ...                      deployed  capstone-app-0.1.0 1.0.0       Install complete
```

### Step 13: Simulate a Bad Deployment

Deploy a bad image tag:

```bash
helm upgrade devops-capstone-app ./helm/capstone-app   --namespace $NAMESPACE   --set image.repository=$ECR_URI   --set image.tag=bad-tag
```

Check pods:

```bash
kubectl get pods -n $NAMESPACE
```

Expected output:

```text
ImagePullBackOff
```

Explain:

“This is one of the most common Kubernetes deployment failures.”

### Step 14: Roll Back

```bash
helm rollback devops-capstone-app 1 -n $NAMESPACE
```

Expected output:

```text
Rollback was a success
```

Validate:

```bash
kubectl get pods -n $NAMESPACE
curl http://localhost:8080/health
```

### Common Demo Failure Points

| Failure | Likely Cause | Recovery |
|---|---|---|
| `kubectl get nodes` fails | kubeconfig or IAM access issue | Re-run `aws eks update-kubeconfig`, verify IAM |
| Helm lint fails | Chart syntax problem | Fix YAML indentation or template |
| `ImagePullBackOff` | Wrong image tag or ECR access issue | Check image URI, tag, node permissions |
| Pod not ready | Probe path or port mismatch | Check app port and `/health` endpoint |
| Service unreachable | Selector or targetPort mismatch | Compare Service selector to Pod labels |
| Port-forward fails | Service or Pod not running | Check `kubectl get svc` and `kubectl get pods` |

### Cleanup Steps

For class cleanup, remove only the app release and namespace if no longer needed:

```bash
helm uninstall devops-capstone-app -n $NAMESPACE
kubectl delete namespace $NAMESPACE
```

Do not delete the ECR repository or image unless instructed, because Week 24 may need them.

---

## 14. Student Lab Manual

### Lab Title

**Deploy the DevOps Capstone Application to EKS Using Helm**

### Lab Objective

Deploy the Docker image created in Class 1 to Amazon EKS using Helm, validate the application, document rollback, and prepare the project for Week 24 finalization.

### Estimated Time

60 to 75 minutes

### Student Prerequisites

You must have:

- ECR image from Class 1
- Image repository URI
- Image tag
- AWS CLI configured
- kubectl installed
- Helm installed
- EKS cluster access
- Capstone repo open in VS Code

### Starting Point From Class 1

You should know:

```bash
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="<ACCOUNT_ID>"
ECR_REPOSITORY="devops-capstone-app"
IMAGE_TAG="<YOUR_IMAGE_TAG>"
ECR_URI="<ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/devops-capstone-app"
EKS_CLUSTER_NAME="<EKS_CLUSTER_NAME>"
NAMESPACE="devops-capstone"
```

### Architecture or Workflow Overview

```text
Class 1:
App code → Docker image → ECR

Class 2:
ECR → Helm chart → EKS Deployment → Pod → Service → Health check → Logs → Rollback
```

### Step 1: Set Environment Variables

```bash
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID="<ACCOUNT_ID>"
export ECR_REPOSITORY="devops-capstone-app"
export IMAGE_TAG="<YOUR_IMAGE_TAG>"
export ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"
export EKS_CLUSTER_NAME="<EKS_CLUSTER_NAME>"
export NAMESPACE="devops-capstone"
```

Validate:

```bash
echo $ECR_URI
echo $IMAGE_TAG
```

Expected output:

```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/devops-capstone-app
a1b2c3d
```

### Step 2: Confirm AWS Identity

```bash
aws sts get-caller-identity
```

Expected output should show your AWS account.

### Step 3: Connect kubectl to EKS

```bash
aws eks update-kubeconfig   --region $AWS_REGION   --name $EKS_CLUSTER_NAME
```

Validate:

```bash
kubectl get nodes
```

Expected output:

```text
NAME                            STATUS   ROLES    AGE   VERSION
ip-10-0-1-10.ec2.internal       Ready    <none>   2d    v1.29.x
```

### Step 4: Create Namespace

```bash
kubectl create namespace $NAMESPACE
```

If it already exists:

```bash
kubectl get ns $NAMESPACE
```

### Step 5: Create Helm Chart Structure

```bash
mkdir -p helm/capstone-app/templates
```

Create `helm/capstone-app/Chart.yaml`:

```yaml
apiVersion: v2
name: capstone-app
description: Helm chart for the DevOps capstone application
type: application
version: 0.1.0
appVersion: "1.0.0"
```

Create `helm/capstone-app/values.yaml`:

```yaml
replicaCount: 2

image:
  repository: ""
  tag: ""
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

container:
  port: 8080

resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"

probes:
  readinessPath: /health
  livenessPath: /health
```

Create `helm/capstone-app/templates/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
  labels:
    app: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
        - name: capstone-app
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.container.port }}
          readinessProbe:
            httpGet:
              path: {{ .Values.probes.readinessPath }}
              port: {{ .Values.container.port }}
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: {{ .Values.probes.livenessPath }}
              port: {{ .Values.container.port }}
            initialDelaySeconds: 15
            periodSeconds: 20
          resources:
{{ toYaml .Values.resources | indent 12 }}
```

Create `helm/capstone-app/templates/service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}
  labels:
    app: {{ .Release.Name }}
spec:
  type: {{ .Values.service.type }}
  selector:
    app: {{ .Release.Name }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      protocol: TCP
```

### Step 6: Lint Helm Chart

```bash
helm lint ./helm/capstone-app
```

Expected output:

```text
1 chart(s) linted, 0 chart(s) failed
```

### Step 7: Render Helm Template

```bash
helm template devops-capstone-app ./helm/capstone-app   --namespace $NAMESPACE   --set image.repository=$ECR_URI   --set image.tag=$IMAGE_TAG
```

Confirm the rendered image line shows your ECR URI and tag.

### Step 8: Deploy Application

```bash
helm upgrade --install devops-capstone-app ./helm/capstone-app   --namespace $NAMESPACE   --set image.repository=$ECR_URI   --set image.tag=$IMAGE_TAG
```

Expected output:

```text
STATUS: deployed
REVISION: 1
```

### Step 9: Validate Pods

```bash
kubectl get pods -n $NAMESPACE
```

Expected output:

```text
READY   STATUS    RESTARTS
1/1     Running   0
```

If status is not `Running`, run:

```bash
kubectl describe pod -n $NAMESPACE <POD_NAME>
```

### Step 10: Validate Service

```bash
kubectl get svc -n $NAMESPACE
```

Expected output:

```text
devops-capstone-app   ClusterIP   172.20.x.x   <none>   80/TCP
```

### Step 11: Validate Logs

```bash
kubectl logs -n $NAMESPACE deployment/devops-capstone-app
```

Expected output:

```text
App listening on port 8080
```

### Step 12: Test the App With Port Forward

```bash
kubectl port-forward -n $NAMESPACE svc/devops-capstone-app 8080:80
```

In another terminal:

```bash
curl http://localhost:8080/health
```

Expected output:

```json
{"status":"healthy"}
```

### Step 13: Document Rollback

Run:

```bash
helm history devops-capstone-app -n $NAMESPACE
```

Add this to `docs/rollback-plan.md`:

```markdown
# Rollback Plan

## Application
devops-capstone-app

## Namespace
devops-capstone

## View release history
helm history devops-capstone-app -n devops-capstone

## Roll back to previous revision
helm rollback devops-capstone-app <REVISION_NUMBER> -n devops-capstone

## Validate rollback
kubectl get pods -n devops-capstone
kubectl logs -n devops-capstone deployment/devops-capstone-app
curl http://localhost:8080/health
```

### Step 14: Add Monitoring Notes

Add this to `docs/runbook.md`:

```markdown
# Basic Monitoring and Validation

## Check pod status
kubectl get pods -n devops-capstone

## Check deployment
kubectl get deploy -n devops-capstone

## Check logs
kubectl logs -n devops-capstone deployment/devops-capstone-app

## Check service
kubectl get svc -n devops-capstone

## Health endpoint
curl http://localhost:8080/health

## AWS monitoring notes
- Review EKS logs and workload metrics through CloudWatch if enabled.
- In a production environment, create dashboards and alerts for error rate, latency, pod restarts, and unavailable replicas.
```

> This step writes *commands into a runbook* — that is documentation, not observability. A senior capstone must **deploy** monitoring (a real dashboard and a real alert tied to a Week 21 SLO). Do not stop here: complete Section 13D to close the observability loop.

### Step 15: Automate the Deploy with GitOps (Argo CD)

The headline promise of a DevOps capstone is "git push → running in EKS." A `when: manual` push-based `helm upgrade` from CI is the pattern the industry is moving *away* from (CI needs cluster-admin credentials; drift is invisible). Instead, CI's job ends at producing a signed image + bumping the desired tag in Git, and a **GitOps controller (Argo CD) running in the cluster pulls and reconciles** the desired state. See Section 13C for the full Argo CD setup; here is how CI hands off to it.

Replace the manual deploy job with a job that only updates the Git-declared desired tag (CI never touches the cluster):

```yaml
# .gitlab-ci.yml — promote stage (runs after image is built, scanned, signed)
promote_dev:
  stage: promote
  image: alpine:latest
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
  before_script:
    - apk add --no-cache git yq
  script:
    # Update the desired image tag in the env values that Argo CD watches.
    - yq -i '.image.tag = strenv(CI_COMMIT_SHORT_SHA)' gitops/envs/dev/values.yaml
    - git config user.email "ci@capstone"
    - git config user.name "capstone-ci"
    - git add gitops/envs/dev/values.yaml
    - git commit -m "promote dev to $CI_COMMIT_SHORT_SHA"
    - git push "https://oauth2:${GITOPS_PUSH_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git" HEAD:main
```

Argo CD (installed in the cluster) detects the commit and reconciles the new tag — no cluster credentials in CI. This is the production-grade alternative the rubric now expects; document the choice in an ADR (Section 13C).

> If GitOps is out of scope for your cohort's time budget, the **only** acceptable push-based fallback is one that authenticates via OIDC (assume-role-with-web-identity) and `aws eks update-kubeconfig` — never long-lived keys. But present GitOps as the target state.

### Validation Checklist

Students should confirm:

- [ ] `kubectl get nodes` works
- [ ] Namespace exists
- [ ] Helm chart exists
- [ ] Helm lint passes
- [ ] Rendered Helm template has correct ECR image URI
- [ ] Helm release is deployed
- [ ] Pods are running
- [ ] Service exists
- [ ] Logs are visible
- [ ] Health endpoint works
- [ ] EKS provisioned via Terraform (cluster/VPC/IRSA) — plan/apply output saved
- [ ] Ingress + ALB Controller + TLS reachable (or documented with cost rationale)
- [ ] Monitoring stack deployed; one SLO-backed alert and one dashboard exist
- [ ] GitOps (Argo CD) Application reconciles the app from Git
- [ ] Rollback command is documented
- [ ] ADR for deployment mechanism (GitOps vs push) written

### Troubleshooting Tips

| Problem | What to Check |
|---|---|
| `kubectl get nodes` fails | EKS cluster name, region, IAM access |
| Helm lint fails | YAML indentation, missing template values |
| `ImagePullBackOff` | image URI, tag, ECR permissions |
| Pod not ready | readiness path, target port, app startup |
| Service unreachable | selector labels, service port, targetPort |
| Logs are empty | app may not be starting or wrong container selected |
| Port-forward fails | service or pod may not exist |

### Cleanup Steps

If instructed to clean up:

```bash
helm uninstall devops-capstone-app -n $NAMESPACE
kubectl delete namespace $NAMESPACE
```

Do not delete the ECR image unless the instructor confirms it is no longer needed for Week 24.

### Reflection Questions

1. How does Class 2 extend the image workflow from Class 1?
2. Why is Helm useful compared with copying raw Kubernetes YAML?
3. What is the difference between a Pod being `Running` and an app being healthy?
4. What deployment evidence would you show during a final capstone presentation?
5. What should be monitored before calling this deployment production-ready?

### Optional Challenge Task

Add a `values-dev.yaml` file:

```yaml
replicaCount: 1

image:
  repository: ""
  tag: ""
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

container:
  port: 8080

resources:
  requests:
    cpu: "50m"
    memory: "64Mi"
  limits:
    cpu: "250m"
    memory: "256Mi"

probes:
  readinessPath: /health
  livenessPath: /health
```

Deploy using:

```bash
helm upgrade --install devops-capstone-app ./helm/capstone-app   --namespace $NAMESPACE   --values ./helm/capstone-app/values-dev.yaml   --set image.repository=$ECR_URI   --set image.tag=$IMAGE_TAG
```

---

## 13B. Provision EKS as Code (VPC + Node Group + IRSA)

The cluster is the capstone's most significant infrastructure — it must be **code**. Use the community-maintained `terraform-aws-modules` so the module stays correct and current. Create `terraform/cluster/main.tf`:

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  # backend "s3" { ... }   # use a remote state backend for team use
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "devops-capstone-cluster"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true   # cost control for a lab; HA NAT for prod
  enable_dns_hostnames = true

  # Tags required so the AWS Load Balancer Controller can discover subnets.
  public_subnet_tags  = { "kubernetes.io/role/elb" = 1 }
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = 1 }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true
  enable_irsa                    = true   # OIDC provider for pod IAM roles (IRSA)

  # Modern access control: the creating principal gets admin (no aws-auth editing).
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 3
      desired_size   = 2
    }
  }
}

output "cluster_name"     { value = module.eks.cluster_name }
output "cluster_endpoint" { value = module.eks.cluster_endpoint }
output "oidc_provider_arn" { value = module.eks.oidc_provider_arn }
```

Render-before-apply discipline:

```bash
cd terraform/cluster
terraform init
terraform validate
terraform plan -out tfplan      # review every resource BEFORE creating it
terraform apply tfplan
aws eks update-kubeconfig --name "$(terraform output -raw cluster_name)" --region us-east-1
cd ../..
```

### IRSA: give the app pod AWS permissions without static keys

IRSA lets a Kubernetes ServiceAccount assume an IAM role via the cluster's OIDC provider — the pattern that replaces baked-in access keys. Example: a role the app uses to read a parameter from SSM. Create `terraform/cluster/irsa.tf`:

```hcl
module "app_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "capstone-app"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["devops-capstone:capstone-app"]
    }
  }
}

output "app_role_arn" { value = module.app_irsa.iam_role_arn }
```

The Helm chart then annotates its ServiceAccount with that role ARN (see Section 13C values). No keys anywhere.

> Cost & cleanup (CRITICAL): this cluster (EKS control plane ~$0.10/hr + 2× t3.medium + 1 NAT gateway) costs roughly **$5–$10/day**. Share one cluster across the cohort, deploy per-student namespaces, and run `terraform destroy` in `terraform/cluster` (and `terraform/registry`) at the end of the week. Always confirm with `terraform plan -destroy` first.

> OpenTofu: swap `terraform` for `tofu` throughout; the modules are provider-compatible.

---

## 13C. Real Entry Point (Ingress + AWS Load Balancer Controller + TLS) and GitOps

### Install the AWS Load Balancer Controller (via IRSA)

Port-forward is a lab fallback, not a user-facing entry point. The AWS Load Balancer Controller turns a Kubernetes `Ingress` into an AWS Application Load Balancer. Install it with its own IRSA role:

```bash
# 1. Create the IAM policy + IRSA role (Terraform-managed in terraform/cluster/alb.tf,
#    using the iam-role-for-service-accounts-eks module with the official ALB policy).
# 2. Install the controller via Helm:
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=devops-capstone-cluster \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=$ALB_CONTROLLER_ROLE_ARN
```

### Add an Ingress to the chart with TLS

Add to `helm/capstone-app/values.yaml`:

```yaml
serviceAccount:
  create: true
  name: capstone-app
  # IRSA: lets the app pod assume an IAM role without static keys.
  roleArn: ""   # set to terraform output app_role_arn

ingress:
  enabled: true
  host: capstone.example.com           # a domain/subdomain you control in Route 53
  certificateArn: ""                   # an ACM cert ARN for that host (TLS)
```

Create `helm/capstone-app/templates/ingress.yaml`:

```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    alb.ingress.kubernetes.io/certificate-arn: {{ .Values.ingress.certificateArn }}
    alb.ingress.kubernetes.io/healthcheck-path: /health
    # Redirect HTTP -> HTTPS at the ALB.
    alb.ingress.kubernetes.io/ssl-redirect: '443'
spec:
  rules:
    - host: {{ .Values.ingress.host }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ .Release.Name }}
                port:
                  number: {{ .Values.service.port }}
{{- end }}
```

Also add a ServiceAccount template so IRSA works (`helm/capstone-app/templates/serviceaccount.yaml`):

```yaml
{{- if .Values.serviceAccount.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ .Values.serviceAccount.name }}
  {{- if .Values.serviceAccount.roleArn }}
  annotations:
    eks.amazonaws.com/role-arn: {{ .Values.serviceAccount.roleArn }}
  {{- end }}
{{- end }}
```

And reference it from the Deployment pod spec (`spec.template.spec.serviceAccountName: {{ .Values.serviceAccount.name }}`).

> Cost & cleanup: each ALB costs ~$0.0225/hr + LCU. Create ONE ingress (shared or instructor demo), and delete it (`helm uninstall` removes the Ingress, which deletes the ALB) when done. Port-forward remains the zero-cost fallback for individual students.

### GitOps with Argo CD (replaces the manual push deploy)

Install Argo CD and point an `Application` at the repo so the cluster pulls desired state:

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Create `gitops/application.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: capstone-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://gitlab.com/<you>/devops-capstone.git
    targetRevision: main
    path: helm/capstone-app
    helm:
      valueFiles:
        - ../../gitops/envs/dev/values.yaml   # CI bumps image.tag here
  destination:
    server: https://kubernetes.default.svc
    namespace: devops-capstone
  syncPolicy:
    automated:
      prune: true
      selfHeal: true            # reverts manual drift back to Git state
    syncOptions:
      - CreateNamespace=true
```

Now the flow is: CI builds/scans/signs the image and commits the new tag to `gitops/envs/dev/values.yaml` (Section 15 promote stage) → Argo CD detects the commit → reconciles the cluster. No cluster credentials in CI; drift self-heals.

Write an ADR (`docs/adr/0004-why-gitops-over-push-deploy.md`) covering: pull vs push, where credentials live, drift detection, and the trade-off (extra controller to operate vs. auditable, credential-free, self-healing delivery).

---

## 13D. Deployed Observability (Dashboard + Alert tied to a Week 21 SLO)

A deployment is not done when `helm upgrade` returns 0 — it is done when it is **observable** and tied to a reliability target. This closes the loop from Week 16 (observability) and Week 21 (SLI/SLO/error budgets).

### Define the SLO (from Week 21)

For the capstone app, declare an availability SLO in `docs/runbook.md`:

| SLI | Target (SLO) | Window | Error budget |
|---|---|---|---|
| Request success rate (non-5xx / total) on `/` and `/sum` | 99.5% | 28 days | 0.5% (~3h 20m/28d) |
| p95 latency | < 300 ms | 28 days | — |

### Deploy the monitoring stack

Install kube-prometheus-stack (Prometheus + Grafana + Alertmanager) into the shared cluster:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace
```

> AWS-native alternative: enable **CloudWatch Container Insights** on the node group (an EKS add-on) and build the dashboard/alarm in CloudWatch. Either path is acceptable; the requirement is *deployed* monitoring with a real dashboard and a real alert — not commands in a runbook.

### Instrument the app and scrape it

Expose Prometheus metrics from the app (add `prom-client`, a `/metrics` endpoint, and a request counter/histogram), then tell Prometheus to scrape the pod with a `ServiceMonitor` (`helm/capstone-app/templates/servicemonitor.yaml`):

```yaml
{{- if .Values.monitoring.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ .Release.Name }}
  labels:
    release: monitoring          # matches the kube-prometheus-stack selector
spec:
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  endpoints:
    - port: http
      path: /metrics
      interval: 15s
{{- end }}
```

### One alert wired to the SLO (error-budget burn)

Create a `PrometheusRule` that fires when the success-rate SLO is being violated (fast burn). `helm/capstone-app/templates/prometheusrule.yaml`:

```yaml
{{- if .Values.monitoring.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: {{ .Release.Name }}-slo
  labels:
    release: monitoring
spec:
  groups:
    - name: capstone-slo
      rules:
        - alert: CapstoneAvailabilitySLOBurn
          # 1h success rate below the 99.5% SLO target.
          expr: |
            (
              sum(rate(http_requests_total{app="{{ .Release.Name }}",code!~"5.."}[1h]))
              /
              sum(rate(http_requests_total{app="{{ .Release.Name }}"}[1h]))
            ) < 0.995
          for: 5m
          labels:
            severity: page
          annotations:
            summary: "Capstone availability SLO burning"
            description: "1h success rate is below the 99.5% SLO; error budget is burning."
{{- end }}
```

### One dashboard

Provision a Grafana dashboard (request rate, success rate vs the 99.5% line, p95 latency, pod restarts) via a `grafana_dashboard`-labeled ConfigMap, or import a JSON dashboard. Capture a screenshot as a capstone deliverable.

### Prove the loop (demo)

Trigger the alert deliberately: set `STORE_READY=false` (the `/ready` dependency-failure switch from the Class 1 app) or send load to a failing endpoint, watch the success rate drop below 99.5%, confirm the alert fires in Alertmanager, then recover and watch it clear. This demonstrates the full reliability loop — SLI → SLO → alert → response — that a hiring manager probes hardest.

Add `monitoring: { enabled: true }` to `values.yaml` to gate these templates.

---

## 15. Troubleshooting Activity

### Incident Title

**Capstone Deployment Fails After Helm Upgrade**

### Business Impact

The team successfully built and pushed the application image in Class 1, but the application is not running correctly in EKS. The deployment cannot be accepted for Week 24 final presentation until the failure is diagnosed and resolved.

### Symptoms

Students see:

```text
helm upgrade --install devops-capstone-app ./helm/capstone-app --namespace devops-capstone ...
STATUS: deployed
```

But pods show:

```text
NAME                                  READY   STATUS             RESTARTS
devops-capstone-app-6d8f9c9f8-zx2mn   0/1     ImagePullBackOff   0
```

or:

```text
NAME                                  READY   STATUS    RESTARTS
devops-capstone-app-6d8f9c9f8-zx2mn   0/1     Running   0
```

With describe output:

```text
Readiness probe failed: HTTP probe failed with statuscode: 404
```

### Starting Evidence

Evidence set A:

```text
Failed to pull image "123456789012.dkr.ecr.us-east-1.amazonaws.com/devops-capstone-app:bad-tag":
not found
```

Evidence set B:

```text
Readiness probe failed: Get "http://10.0.2.25:8080/healthz": dial tcp 10.0.2.25:8080: connect: connection refused
```

Evidence set C:

```text
Service has no active endpoints
```

### Student Investigation Steps

Students should run:

```bash
kubectl get pods -n devops-capstone
kubectl describe pod -n devops-capstone <POD_NAME>
kubectl logs -n devops-capstone <POD_NAME>
kubectl get svc -n devops-capstone
kubectl describe svc -n devops-capstone devops-capstone-app
kubectl get endpoints -n devops-capstone
helm status devops-capstone-app -n devops-capstone
helm history devops-capstone-app -n devops-capstone
helm template devops-capstone-app ./helm/capstone-app   --namespace devops-capstone   --set image.repository=$ECR_URI   --set image.tag=$IMAGE_TAG
```

### Expected Root Cause

| Evidence | Expected Root Cause |
|---|---|
| `ImagePullBackOff` and `not found` | Wrong image tag or image not pushed to ECR |
| Readiness probe fails with 404 | Probe path does not match app endpoint |
| Service has no endpoints | Service selector does not match Pod labels |
| Connection refused | Wrong container port or app not listening on expected port |

### Correct Resolution

#### If image tag is wrong

Update Helm deployment with correct tag:

```bash
helm upgrade devops-capstone-app ./helm/capstone-app   --namespace devops-capstone   --set image.repository=$ECR_URI   --set image.tag=$IMAGE_TAG
```

#### If readiness path is wrong

Set correct readiness path:

```bash
helm upgrade devops-capstone-app ./helm/capstone-app   --namespace devops-capstone   --set image.repository=$ECR_URI   --set image.tag=$IMAGE_TAG   --set probes.readinessPath=/health
```

#### If Service selector is wrong

Fix Service selector to match Deployment Pod labels:

```yaml
selector:
  app: {{ .Release.Name }}
```

Then redeploy.

#### If rollback is needed

```bash
helm history devops-capstone-app -n devops-capstone
helm rollback devops-capstone-app <REVISION_NUMBER> -n devops-capstone
```

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Rebuilding the Docker image without checking tag | The pushed image may exist, but Helm is using the wrong tag |
| Deleting the whole cluster | The issue is app-level deployment, not cluster infrastructure |
| Changing IAM first for readiness failures | Readiness failures are usually app/probe/port issues |
| Editing live resources manually | Helm may overwrite manual changes |
| Ignoring `kubectl describe` | Events usually show the direct failure reason |

### Instructor Hints

Use layered questions:

1. Did Helm fail, or did Kubernetes fail after Helm succeeded?
2. Can the Pod pull the image?
3. Is the container starting?
4. Is the app listening on the expected port?
5. Does the Service selector match the Pod labels?
6. What does Helm history show?

### Preventive Action

Students should add a deployment checklist:

```text
Before deployment:
- Confirm image exists in ECR
- Confirm image tag is correct
- Run helm lint
- Run helm template
- Confirm container port
- Confirm readiness path
- Confirm Service selector
- Confirm namespace

After deployment:
- Check pods
- Check logs
- Check service
- Check health endpoint
- Document rollback
```

---

## 16. Scenario-Based Discussion Questions

### Question 1

Why is a Helm deployment not automatically production-ready just because `helm upgrade` succeeded?

Expected response themes:

- The app may still fail readiness checks.
- The Pod may not be healthy.
- Service may not route traffic.
- Monitoring and rollback must be validated.

Instructor follow-up:

“What evidence would prove the deployment is actually healthy?”

### Question 2

Should the CI/CD pipeline deploy automatically to production after every successful image push?

Expected response themes:

- Usually no for production.
- Dev may be automatic.
- Prod may require approvals.
- Regulated environments need change control.
- Automated tests and rollback reduce risk.

Instructor follow-up:

“What environments should be automatic, and where should approvals be required?”

### Question 3

What is the risk of using a LoadBalancer service for every student lab?

Expected response themes:

- It can create cloud cost.
- It may create unnecessary external exposure.
- Shared cluster resources can become messy.
- Port-forward or ClusterIP is safer for labs.

Instructor follow-up:

“How would this change in a real production environment?”

### Question 4

Why should probes be included in a capstone deployment?

Expected response themes:

- They help Kubernetes understand app health.
- Readiness prevents traffic to unready Pods.
- Liveness can restart stuck apps.
- They improve reliability.

Instructor follow-up:

“What happens if the readiness path is wrong?”

### Question 5

What should be included in a rollback plan?

Expected response themes:

- Helm history command
- rollback command
- validation steps
- owner or approver
- conditions for rollback
- communication steps

Instructor follow-up:

“How would this rollback plan change for production?”

### Question 6

What is the relationship between Class 1 image tags and Class 2 Helm values?

Expected response themes:

- The image tag from Class 1 becomes the deployed version in Class 2.
- Helm values pass repository and tag to Kubernetes.
- Wrong tag causes deployment failure.

Instructor follow-up:

“How can a team prove which commit is running in EKS?”

### Question 7

What monitoring is enough for a student capstone, and what would be needed in enterprise production?

Expected response themes:

- Student capstone: pod status, logs, health endpoint, basic metrics notes.
- Enterprise: dashboards, alerts, SLOs, traces, incident runbooks, log retention.

Instructor follow-up:

“What would an SRE ask before approving production readiness?”

---

## 17. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple Choice

What does Helm primarily help with?

A. Building Docker images  
B. Packaging and deploying Kubernetes resources  
C. Creating AWS accounts  
D. Scanning container vulnerabilities  

**Answer:** B  
**Explanation:** Helm packages Kubernetes manifests into reusable charts.

### Question 2: Multiple Choice

Which Class 1 output is required for the Helm deployment in Class 2?

A. EC2 key pair  
B. ECR image URI and image tag  
C. S3 bucket policy only  
D. CloudWatch dashboard only  

**Answer:** B  
**Explanation:** Helm needs the image repository and tag to deploy the correct container image.

### Question 3: True or False

A Pod with status `Running` always means the application is healthy.

**Answer:** False  
**Explanation:** The container may be running, but the app may fail readiness checks or return errors.

### Question 4: Multiple Choice

Which command checks Helm chart syntax and basic chart structure?

A. `helm lint`  
B. `helm delete-all`  
C. `kubectl scan`  
D. `aws eks lint`  

**Answer:** A  
**Explanation:** `helm lint` checks a chart for common issues.

### Question 5: Troubleshooting

A Pod is stuck in `ImagePullBackOff`. List two likely causes.

**Answer:** Wrong image tag, image not pushed to ECR, incorrect image URI, or missing ECR pull permissions.  
**Explanation:** `ImagePullBackOff` means Kubernetes cannot pull the image.

### Question 6: Troubleshooting

A Service has no endpoints. What should you check first?

**Answer:** Check whether the Service selector matches the labels on the Pods.  
**Explanation:** If selectors do not match, the Service cannot route to Pods.

### Question 7: AWS-Related

Which AWS service is used to run Kubernetes workloads in this class?

**Answer:** Amazon EKS.  
**Explanation:** EKS is AWS’s managed Kubernetes service.

### Question 8: AWS-Related

Which AWS service stores the Docker image deployed to EKS?

**Answer:** Amazon ECR.  
**Explanation:** ECR stores container images that EKS can pull.

### Question 9: Class 1 to Class 2 Connection

How does the Docker image tag from Class 1 get used in Class 2?

**Answer:** It is passed into Helm values and becomes the image tag used by the Kubernetes Deployment.  
**Explanation:** Helm renders the Deployment manifest with the selected image repository and tag.

### Question 10: Class 1 to Class 2 Connection

Why should the image tag be documented before deployment?

**Answer:** So the team can trace which application version is deployed and roll back if needed.  
**Explanation:** Traceability is important for troubleshooting and production support.

### Question 11: Short Answer

What command shows Helm release history?

**Answer:** `helm history <release-name> -n <namespace>`  
**Explanation:** Release history is needed to understand revisions and perform rollback.

### Question 12: True or False

For student labs, using `kubectl port-forward` can be safer and cheaper than creating a public LoadBalancer.

**Answer:** True  
**Explanation:** Port-forwarding avoids creating external cloud load balancers and reduces cost and exposure.

---

## 18. Homework Assignment

### Assignment Title

**Complete the Week 23 DevOps Capstone Deployment Draft**

### Scenario

Your DevOps team has successfully built and published a container image to ECR. Now the team must prove that the image can be deployed to EKS using Helm, validated, monitored at a basic level, and rolled back if needed.

### Student Tasks

Complete the following:

1. Finalize Helm chart structure (incl. Ingress + ServiceAccount/IRSA templates).
2. Provision/confirm EKS via Terraform (cluster/VPC/IRSA) and save plan/apply output.
3. Deploy the capstone image to EKS and reach it via Ingress + TLS (port-forward fallback documented).
4. Wire deployment through GitOps (Argo CD) so the cluster reconciles from Git.
5. Deploy observability: one dashboard and one alert tied to a Week 21 SLO; capture a screenshot.
6. Validate Pod, Service, logs, and health endpoint; document the image repository and tag used.
7. Create or update rollback documentation and the SLO-backed runbook.
8. Write ADRs for the deployment mechanism (GitOps vs push) and EKS vs ECS.
9. Capture known issues or blockers.
10. Prepare a Week 24 presentation outline and commit all changes to Git.

### Expected Deliverables

Students submit:

```text
1. Git repository link or exported folder
2. Helm chart files (incl. ingress.yaml, serviceaccount.yaml, servicemonitor.yaml, prometheusrule.yaml)
3. terraform/cluster (and terraform/registry) with plan/apply output
4. Screenshot or command output showing Helm release deployed and running Pods
5. Screenshot showing the app reachable via Ingress/TLS (or documented port-forward fallback)
6. Argo CD Application reconciling the app (screenshot/CLI output)
7. Grafana (or CloudWatch) dashboard screenshot + the SLO alert definition
8. docs/rollback-plan.md and docs/runbook.md (with the SLO table)
9. docs/adr/ with the deployment-mechanism and EKS-vs-ECS ADRs
10. Known issues list and Week 24 presentation outline
```

### Submission Format

Submit one of:

- Git repository link
- Zip file of project
- Markdown document with command outputs and screenshots

### Estimated Completion Time

2 to 3 hours

### Grading Criteria

| Criteria | Points |
|---|---:|
| EKS/VPC/IRSA provisioned as Terraform code (plan/apply evidence) | 15 |
| Helm chart is complete and valid (incl. Ingress + ServiceAccount/IRSA) | 15 |
| Application deployed to EKS and reachable via Ingress/TLS (port-forward fallback documented) | 15 |
| GitOps (Argo CD) reconciles the app from Git | 15 |
| Deployed observability: SLO-backed alert + dashboard tied to a Week 21 SLO | 15 |
| Kubernetes validation + rollback evidence | 10 |
| ADRs (deployment mechanism, EKS vs ECS) clear and defensible | 10 |
| Documentation is presentation-ready | 5 |
| Total | 100 |

### Optional Advanced Challenge

Add one of the following (these go beyond the now-core ingress/GitOps/observability work):

- A multi-window, multi-burn-rate SLO alert (fast + slow burn) per Google SRE guidance
- Argo CD progressive delivery (Argo Rollouts) with a canary step
- `cosign verify` enforced at admission (e.g., a policy controller) so only signed images run
- External Secrets Operator pulling app config from AWS Secrets Manager via IRSA
- HorizontalPodAutoscaler driven by the Prometheus request-rate metric
- `values-prod.yaml` with HA NAT, larger node group, and stricter resource limits

---

## 19. Common Student Mistakes

| Mistake | Why It Happens | Fix or Avoidance |
|---|---|---|
| Using wrong image tag | Students forget Class 1 tag | Confirm with `aws ecr list-images` |
| Using wrong ECR URI | Account ID or region copied incorrectly | Build URI from variables |
| Forgetting namespace | Helm deploys to default namespace | Always use `--namespace` |
| Skipping `helm lint` | Students rush to deploy | Lint before upgrade |
| Not running `helm template` | Students cannot see rendered YAML | Render before troubleshooting |
| Wrong container port | App listens on 8080 but Service targets another port | Match app, container, and Service ports |
| Bad readiness path | Probe uses `/healthz` while app exposes `/health` | Validate endpoint locally and in Pod |
| Service selector mismatch | Labels differ between Deployment and Service | Compare selectors and Pod labels |
| Creating public LoadBalancer unnecessarily | Students want easy browser access | Use port-forward for lab unless instructed |
| Not documenting rollback | Students focus only on deployment | Add rollback before calling work complete |

---

## 20. Real-World Enterprise Scenario

### Scenario

A business application team has finished containerizing a shipment tracking service. The DevOps team built the CI/CD pipeline and published the image to ECR. Now leadership wants the application deployed to an EKS-based non-production environment for validation.

The platform team requires Helm-based deployments. The security team requires traceable image tags. The SRE team requires logs, health checks, rollback steps, and a basic runbook before the app can move toward production.

### Constraints

| Constraint | Example |
|---|---|
| Access control | Pipeline must use controlled AWS permissions |
| Security | Images must come from approved ECR repository |
| Cost | Avoid unnecessary public LoadBalancers in lab and non-prod |
| Reliability | Probes and resource settings must be defined |
| Auditability | Image tag must map back to Git commit |
| Production impact | Rollback steps must be documented before release |
| Team workflow | Deployment should be repeatable through Helm and pipeline |

### What Each Role Would Do

| Role | Responsibility |
|---|---|
| DevOps Engineer | Build Helm deployment workflow and pipeline deploy stage |
| Cloud Engineer | Provide EKS cluster, IAM access, registry, and network foundation |
| SRE | Review health checks, logs, runbook, rollback, and monitoring readiness |

### How the Class Topic Applies

This class teaches students how DevOps delivery moves beyond build automation into deployment reliability. A production-style workflow must be deployable, observable, recoverable, and documented.

---

## 21. Instructor Tips

### Teaching Tips

- Keep connecting every Class 2 step back to Class 1.
- Repeat the layered troubleshooting model: image, Helm, Kubernetes, Service, health, monitoring.
- Do not let students treat `helm deployed` as final success.
- Make students validate with `kubectl`, logs, and health endpoint.
- Reinforce that rollback and documentation are part of deployment, not optional extras.

### Pacing Tips

- Keep the review short, but confirm everyone has an image URI and tag.
- Spend enough time on Helm values because that is where many mistakes happen.
- Avoid deep EKS cluster creation details unless the cluster already exists.
- Keep monitoring lightweight for Class 2, focused on logs, health checks, and runbook notes.
- Save final polish and presentation depth for Week 24.

### Lab Support Tips

When students are stuck, ask:

1. Is kubectl connected to the right cluster?
2. Is Helm rendering the expected image?
3. Does the image exist in ECR?
4. Are Pods pulling the image?
5. Are Pods becoming ready?
6. Does the Service point to the right Pods?
7. Can we see logs?
8. Can we test `/health`?

### Helping Struggling Students

Give them a minimum success path:

1. Use instructor-provided image if their ECR image is missing.
2. Create Helm chart.
3. Deploy to namespace.
4. Validate Pod status.
5. Port-forward and test health endpoint.
6. Document rollback and known blockers.

### Challenging Advanced Students

Ask them to add:

- Separate dev/prod values files
- Manual approval before deploy
- Canary-style deployment discussion
- Helm rollback test
- Kubernetes resource tuning
- Ingress with AWS Load Balancer Controller, if available
- CloudWatch Container Insights investigation
- Pipeline OIDC deployment pattern

---

## 22. Student Outcome Checklist

### Students Should Be Able to Explain

- [ ] How Class 1 image build connects to Class 2 deployment
- [ ] What Helm does
- [ ] Why EKS needs the ECR image URI and tag
- [ ] What a Helm release is
- [ ] Why readiness and liveness probes matter
- [ ] Why rollback planning matters
- [ ] What basic monitoring evidence is needed
- [ ] How AWS EKS, ECR, IAM, and CloudWatch connect in this workflow

### Students Should Be Able to Build or Configure

- [ ] Helm chart structure
- [ ] `Chart.yaml`
- [ ] `values.yaml`
- [ ] Deployment template
- [ ] Service template
- [ ] Kubernetes namespace
- [ ] Helm release
- [ ] Port-forward validation
- [ ] Rollback documentation
- [ ] Monitoring/runbook notes
- [ ] Pipeline deploy stage draft

### Students Should Be Able to Troubleshoot

- [ ] kubeconfig or EKS access failure
- [ ] Helm syntax error
- [ ] Wrong image tag
- [ ] `ImagePullBackOff`
- [ ] Readiness probe failure
- [ ] Service selector mismatch
- [ ] Port mismatch
- [ ] Failed health endpoint
- [ ] Rollback procedure

---

## 23. Class Completion Checklist

### Instructor Checklist Before Ending Class

Confirm students understand:

- [ ] How ECR image becomes an EKS workload
- [ ] Why Helm is used
- [ ] How to validate deployment health
- [ ] How to troubleshoot image pull failures
- [ ] How to troubleshoot probe failures
- [ ] How to use Helm history and rollback
- [ ] What must be completed before Week 24
- [ ] Homework expectations

### Student Checklist Before Leaving Class

Students should have:

- [ ] EKS access validated or blocker documented
- [ ] Helm chart created
- [ ] Helm lint passing
- [ ] Image repository and tag configured
- [ ] Application deployed or deployment blocker documented
- [ ] Pod status checked
- [ ] Logs reviewed
- [ ] Health endpoint tested
- [ ] Rollback plan started
- [ ] Runbook/monitoring notes started
- [ ] Deploy stage draft added
- [ ] Git changes committed

### Items to Verify Before Closing the Week

```text
Required before Week 24:
- Capstone repo is organized
- ECR image exists
- Helm chart exists
- Deployment workflow is tested or clearly documented
- Rollback plan exists
- Basic monitoring/runbook notes exist
- Known issues are listed
- Presentation outline is started
```

---

## 24. End-of-Week Summary

### What Students Learned This Week

Students learned how to connect the core DevOps delivery workflow:

```text
Code → Pipeline → Docker image → ECR → Helm → EKS → Validation → Rollback
```

They practiced:

- Structuring a capstone repository
- Building and pushing a Docker image
- Creating a Helm chart
- Deploying to EKS
- Validating Kubernetes resources
- Troubleshooting deployment failures
- Documenting rollback and monitoring steps

### How Class 1 and Class 2 Connect

| Class | Focus | Output |
|---|---|---|
| Class 1 | Build and publish application artifact | Docker image in ECR |
| Class 2 | Deploy, validate, monitor, and roll back artifact | Running app in EKS with Helm workflow |

Class 1 answered:

```text
Can we package and publish the application?
```

Class 2 answered:

```text
Can we deploy and operate the application?
```

### How This Week Prepares Students for the Next Week

Week 24 will focus on:

- Final capstone cleanup
- Demo readiness
- Documentation polish
- Architecture explanation
- Troubleshooting defense
- Final presentation

Students should enter Week 24 with a working or clearly documented DevOps capstone draft.

### What Students Should Review Before the Next Module

Students should review:

- Their ECR image URI and tag
- Helm chart files
- Kubernetes validation commands
- Rollback procedure
- Pipeline stage flow
- Known blockers
- Final presentation outline
- How they will explain their architecture and tradeoffs

Final reminder for students:

> Your Week 24 presentation should not just show that something works. It should show that you understand how it works, how to troubleshoot it, how to recover it, and how a real team would operate it.

---

## Class Artifacts & Validation

This class is the **deploy-validate-operate** half of the capstone. The on-disk, validated
artifacts live in [`labs/capstone/`](../../labs/capstone/) and the sibling modules it *reuses*
(Helm chart, k8s manifests, EKS Terraform, observability rules/SLO, the on-call runbook).
The rows below are the artifacts **this class uses** to deploy, expose, observe, and roll
back the app. Every path was `ls`-verified and every command was run in this environment.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/capstone/validate.sh` | shell | Capstone gate runner (YAML parse, reference check, shell syntax, compose config ×2) | `cd labs/capstone && ./validate.sh` | PASS — `7 passed, 0 failed, 0 deferred`, exit 0 |
| 2 | `labs/helm-charts/solution/chart/webapp/` | helm | The chart the capstone deploys with (`helm upgrade --install`) — Deployment/Service/Ingress/HPA | `helm lint labs/helm-charts/solution/chart/webapp` | PASS — `1 chart(s) linted, 0 failed` (only an `icon` INFO) |
| 3 | `labs/kubernetes-fundamentals/solution/base/deployment.yaml` | k8s | The Deployment (probes, non-root, resource limits) the chart renders | `kubeconform` / `kubectl apply --dry-run=client` | PASS — manifest present; enforced by capstone gate 3 (path-exists) |
| 4 | `labs/kubernetes-fundamentals/solution/base/networkpolicy.yaml` | k8s | Default-deny NetworkPolicy guarding the workload | `kubeconform` / `kubectl apply --dry-run=client` | PASS — present; enforced by capstone reference checker |
| 5 | `labs/terraform-aws-foundations/solution/main.tf` | terraform | EKS/VPC the workload runs on (Section 13B provisions EKS as code) | `terraform init -backend=false && terraform validate` | PASS — `Success! The configuration is valid.` |
| 6 | `labs/observability/solution/prometheus/rules/alerting.rules.yml` | promql | Multi-burn-rate SLO alert rules wired to the dashboard (Section 13D) | `promtool check rules <file>` | PASS — `SUCCESS: 3 rules found` |
| 7 | `labs/observability/solution/slo/slo.yaml` | yaml | The availability/latency SLO + error budget the alert burns against | YAML parse: `python3 -c "import yaml;list(yaml.safe_load_all(open(f)))"` | PASS (parses); enforced by capstone gate 3 |
| 8 | `labs/observability/solution/grafana/dashboards/service-overview.json` | json | The deployed service-overview dashboard (Section 13D requirement) | `python3 -m json.tool < <file>` | PASS (valid JSON); enforced by capstone gate 3 |
| 9 | `labs/capstone/prometheus/prometheus.demo.yml` | promql | The minimal scrape config the local demo mounts (Class-2 metrics profile) | `promtool check config <file>` | PASS — `is valid prometheus config file syntax` |
| 10 | `labs/capstone/runbook.md` | markdown | On-call runbook: ≥5 alert→action playbooks (error-budget burn, CrashLoop, dependency-down, OOM, latency) with copy-pasteable `helm rollback`/`kubectl` commands | manual review vs. README acceptance check | PASS — required playbooks present, commands runnable |

> **Honesty note.** The Helm/k8s/observability artifacts are **static-validated** here
> (`helm lint`, `promtool`, `terraform validate`, JSON/YAML parse all PASS) — they are
> **not** applied to a live EKS cluster or live `kind` in this environment, and **no
> captured live-rollout, rollback, or alert-firing evidence file** is committed in
> `labs/capstone`. The runbook's `helm rollback`/`kubectl rollout` commands are
> documented operations, not a recorded live operation. The cloud profile is plan-only;
> `terraform apply`/`destroy` against EKS is the student/instructor's own step.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk**: Helm chart, k8s manifests (Deployment/NetworkPolicy/HPA), EKS Terraform, Prometheus rules + SLO + Grafana dashboard, demo scrape config, runbook.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured: `helm lint` PASS, `promtool check rules` (3 rules) + `check config` PASS, `terraform validate` Success, JSON/YAML parse PASS, `./validate.sh` 7/7.
- [x] Lab has **starter** (`starter/capstone-brief.md`) and a reference **solution** (the committed integration files + the reused sibling-module `solution/` trees the chart/manifests live in).
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes**.
- [x] **Cleanup/teardown** is provided and idempotent: `docker compose … down -v` locally; for the cloud profile `terraform destroy` + `terraform plan` "No changes" check is documented.
- [x] **Instructor answer key** exists: README §"Instructor answer key", the in-class mini-quiz answer key (Section 17), and the troubleshooting resolution (Section 15).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state*: the dangling-reference detector (gate 3), and the per-component OOM fixture referenced from the runbook (`labs/kubernetes-fundamentals/broken/`).
- [x] **Expected outputs** shown for deploy/validate steps (pod `Ready`, `/healthz` 200, `helm history`/`rollback`, alert rules count).
- [x] **Cost & security warnings** present: plan-only EKS (NAT/EKS cost noted), localhost-only demo ports, non-root/read-only/cap-drop, default-deny NetworkPolicy, no committed secrets.
- [x] **Cross-references** to the module repo and to prior/next weeks are correct: builds on Class 1 (ECR image), reuses Week-21 SLO/observability, hands off to Week 24 finalization.
- [x] The **artifact manifest** (§4.2) is present and every cited path resolves (verified with `ls` and `check_references.sh`).
- [ ] **Live operation evidence** committed (real EKS rollout/rollback, live alert firing, or `kind` autoscale/netpol) — *not done*: all gates here are static (`helm lint`/`promtool`/`terraform validate`/parse); no captured live-operation log is committed. This is the honest gap that caps the score (see scoring).
