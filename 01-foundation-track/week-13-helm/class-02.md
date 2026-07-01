# Week 13, Class 2 Package: Helm Values, Upgrades, Rollbacks, and Releases
> **▶ Runnable lab for this class:** [`labs/helm-charts/`](../../labs/helm-charts/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Helm Values, Upgrades, Rollbacks, and Enterprise Deployment Patterns

**Week:** 13
**Track:** Unified DevOps · Cloud · SRE Track

---

# 1. Class Overview

## Class title

**Class 13.2: Helm Values, Upgrades, Rollbacks, and Releases**

## Class purpose

This class teaches students how to use Helm in a more realistic deployment workflow. In Class 1, students learned how to create, render, install, inspect, and uninstall a basic Helm chart. In Class 2, they extend that foundation by using separate values files for different environments, performing upgrades, checking release history, and rolling back failed releases.

## How this class builds from Class 1

Class 1 introduced:

- Helm chart structure
- `Chart.yaml`
- `values.yaml`
- `templates/`
- `helm lint`
- `helm template`
- `helm install`
- `helm status`
- `helm uninstall`

Class 2 builds on that by adding:

- `values-dev.yaml`
- `values-prod.yaml`
- `helm upgrade`
- `helm upgrade --install`
- `helm history`
- `helm rollback`
- troubleshooting failed upgrades
- enterprise deployment patterns for EKS, AKS, and GKE

## What students will build, analyze, or practice

Students will:

- Deploy the same Helm chart with different values for dev and prod
- Change image tags and replica counts through values
- Perform a Helm upgrade
- Review Helm release history
- Roll back a failed release
- Troubleshoot invalid values and failed Kubernetes validation
- Explain how Helm supports enterprise release workflows

---

# 2. Quick Review of Class 1

## Review points

1. Helm packages Kubernetes manifests into reusable charts.
2. A chart is the package. A release is the installed copy of that package.
3. `values.yaml` stores default configuration values.
4. `templates/` contains Kubernetes YAML templates.
5. `helm template` previews the rendered Kubernetes YAML.
6. `helm lint` checks the chart for common problems.
7. `helm install` creates a release in the cluster.
8. `helm uninstall` removes a release and its related Kubernetes resources.

## Quick recall questions

1. **What is the difference between a chart and a release?**  
   A chart is reusable package content. A release is an installed instance of that chart.

2. **Why should we run `helm template` before installing?**  
   It lets us inspect the final Kubernetes YAML before changing the cluster.

3. **What file usually stores default chart configuration?**  
   `values.yaml`

## Common gaps students may still have from Class 1

| Gap | Instructor Bridge |
|---|---|
| Confusing chart name with release name | Use one chart to install two releases: `app-dev` and `app-prod` |
| Thinking Helm replaces Kubernetes | Reinforce that Helm renders and submits Kubernetes manifests |
| Forgetting to validate before install | Make `helm lint` and `helm template` required before every lab install |
| Trouble with YAML indentation | Start Class 2 by showing values files slowly |
| Not understanding values | Show how `replicaCount` changes the rendered Deployment |

## How the instructor should bridge into Class 2

Say:

```text
In Class 1, we created one chart and installed one release. That is useful, but real teams rarely have only one environment. Today we will use the same chart to deploy dev and prod versions, upgrade a release, inspect release history, and roll back a bad deployment.
```

---

# 3. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** how Helm values files support multiple environments.
2. **Configure** separate dev and prod values files for the same chart.
3. **Build** two Helm releases from one chart using different values.
4. **Validate** rendered manifests before deploying changes.
5. **Perform** Helm upgrades using `helm upgrade` and `helm upgrade --install`.
6. **Troubleshoot** failed upgrades caused by invalid values or Kubernetes validation errors.
7. **Roll back** a Helm release using release history.
8. **Document** an enterprise Helm deployment and rollback workflow.

---

# 4. Prerequisites Students Should Already Know

## Required Class 1 knowledge

Students should already know:

- What Helm is
- Chart vs release
- Basic chart folder structure
- How to edit `values.yaml`
- How to run `helm lint`
- How to run `helm template`
- How to install and uninstall a release

## Required prior concepts

Students should understand:

- Kubernetes Deployments
- Kubernetes Services
- Pods
- Replica count
- Container image tags
- YAML syntax
- `kubectl get`
- `kubectl describe`
- `kubectl logs`

## Required tools already installed

```bash
helm version
kubectl version --client
kubectl get nodes
git --version
code --version
```

## Required files, repos, lab outputs, or setup from Class 1

Students should have either:

```text
week13-lab/
└── student-app/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
```

Or they should recreate it with:

```bash
mkdir -p week13-lab
cd week13-lab
helm create student-app
cd student-app
```

---

# 5. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Values override | A way to replace default chart settings during install or upgrade | Used when dev and prod need different settings |
| Values file | A YAML file containing environment-specific configuration | Teams often use `values-dev.yaml`, `values-test.yaml`, and `values-prod.yaml` |
| Helm upgrade | Updates an existing Helm release | Used when deploying a new version of an application |
| `upgrade --install` | Upgrades if a release exists, installs if it does not | Common in CI/CD pipelines |
| Revision | A numbered version of a Helm release | Each upgrade creates a new revision |
| Release history | List of revisions for a release | Used to understand what changed and roll back |
| Rollback | Returning a release to an earlier revision | Used when a deployment causes problems |
| Dev environment | Lower-risk environment for testing changes | Usually fewer replicas and smaller resources |
| Prod environment | Production environment serving real users | Usually more replicas, stricter approvals, and stronger monitoring |
| Rendered manifest | Final Kubernetes YAML generated by Helm | Should be reviewed before production deployment |
| `--atomic` | Upgrade flag that auto-rolls-back the whole release if it fails | The default safety flag in production CI/CD |
| `--wait` | Makes Helm block until all resources are Ready (or timeout) | Without it, Helm reports success the moment the API accepts the manifests |
| `--timeout` | How long `--wait`/`--atomic` waits before declaring failure | E.g. `--timeout 5m` |
| `--cleanup-on-fail` | Deletes new resources created during a failed upgrade | Prevents orphaned objects after a rollback |
| `helm diff` | Plugin that shows what an upgrade will change before applying | The Helm analog of `terraform plan` (Week 14) |
| Helm hook | An annotated resource run at a lifecycle point (`pre-upgrade`, etc.) | Mechanism behind ordered DB-migration jobs |
| Release storage | Where Helm 3 stores release state — a Secret per revision, in the release namespace | Grows over time; capped with `--history-max` |
| GitOps | Git is the source of truth; a controller (Argo CD/Flux) syncs the cluster to it | In GitOps, rollback = `git revert`, not `helm rollback` |

---

# 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| Helm | Deploys, upgrades, tracks, and rolls back Kubernetes releases |
| kubectl | Validates Kubernetes resources after Helm deploys them |
| Kubernetes | Runs the application workloads |
| YAML | Stores Helm values and Kubernetes templates |
| VS Code | Edits chart files and values files |
| Terminal | Runs Helm and Kubernetes commands |
| Git | Optional source control for chart and values files |
| Docker | Supports local Kubernetes environments such as kind, minikube, or Docker Desktop |

---

# 7. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| Amazon EKS | Target managed Kubernetes service for Helm deployments in AWS |
| Amazon ECR | Stores container images referenced in Helm values |
| IAM | Controls access for users and pipelines deploying Helm releases |
| CloudWatch | Used to monitor deployments after release |
| AWS CLI | Used to configure EKS cluster access when running on AWS |

## AWS-first deployment flow

```text
Git commit
  ↓
CI pipeline builds container image
  ↓
Image pushed to Amazon ECR
  ↓
Pipeline updates Helm image tag
  ↓
Helm upgrade deploys to Amazon EKS
  ↓
CloudWatch validates health
  ↓
Rollback if deployment fails
```

## Cost and security warning

For classroom use, local Kubernetes is preferred.

If using EKS:

- Do not create unnecessary LoadBalancer services.
- Watch for EKS cluster hourly cost.
- Watch for NAT Gateway cost.
- Avoid storing secrets directly in values files.
- Use IAM roles and least privilege for deployment access.
- Clean up all test releases.

---

# 8. Azure and GCP Comparison Notes

Helm itself is cloud-portable because it works with Kubernetes APIs.

| Capability | AWS | Azure | GCP |
|---|---|---|---|
| Managed Kubernetes | EKS | AKS | GKE |
| Container registry | ECR | Azure Container Registry | Artifact Registry |
| Monitoring | CloudWatch | Azure Monitor | Cloud Monitoring |
| Identity integration | IAM and EKS access | Entra ID and Azure RBAC | Google IAM |

Practical note:

```text
The same Helm chart can often deploy to EKS, AKS, and GKE, but cloud-specific annotations, ingress controllers, storage classes, and identity settings may need to change.
```

---

# 9. Time-Boxed Instructor Agenda

| Time | Section | Instructor Activity | Student Activity |
|---:|---|---|---|
| 0:00 to 0:15 | Class 1 review | Review chart, release, values, templates | Answer recall questions |
| 0:15 to 0:35 | Environment values | Explain dev vs prod values files | Compare sample YAML files |
| 0:35 to 0:55 | Helm upgrade workflow | Explain upgrade, revision, history | Observe command flow |
| 0:55 to 1:15 | Helm rollback workflow | Explain rollback and limitations | Discuss rollback risks |
| 1:15 to 1:25 | Break | Pause | Pause |
| 1:25 to 2:00 | Instructor demo | Deploy dev and prod, upgrade, rollback | Follow along or observe |
| 2:00 to 2:40 | Student lab | Support students through dev/prod deployment | Build and validate releases |
| 2:40 to 2:55 | Troubleshooting activity | Inject bad values issue | Debug failed upgrade |
| 2:55 to 3:00 | Recap and homework | Summarize week and explain assignment | Ask final questions |

---

# 10. Instructor Lesson Plan

## Step 1: Start with continuity from Class 1

Say:

```text
Last class, we created one Helm chart and installed one release. Today we will use the same chart in a more realistic way: one chart, multiple environments, upgrades, and rollback.
```

Ask:

```text
What usually changes between dev and prod?
```

Expected answers:

- replica count
- image tag
- environment variables
- resource requests
- service type
- ingress hostnames
- secrets references

## Step 2: Explain environment-specific values

Show:

```text
values.yaml
values-dev.yaml
values-prod.yaml
```

Explain:

```text
The chart gives us reusable structure. Values files let us change behavior without copying templates.
```

Beginner teaching tip:

Do not introduce too many values at once. Start with:

- `replicaCount`
- `image.tag`
- `service.port`

## Step 3: Explain Helm upgrade — and the safe path first

Say:

```text
Install is for the first deployment. Upgrade is for changing an existing release.
```

A bare upgrade is the *unsafe* manual version. Show it once, then immediately show what production actually uses:

```bash
# What NOT to do in CI: fire-and-forget. Helm returns "deployed" the instant
# the API server accepts the manifests, even if every pod then crash-loops.
helm upgrade student-app-dev . -f values-dev.yaml --set image.tag=1.27
```

```bash
# The production-safe default — make THIS the command students memorize:
helm upgrade --install student-app-dev . -f values-dev.yaml \
  --set image.tag=1.27 \
  --atomic --wait --timeout 5m --cleanup-on-fail
```

What each flag buys you:

- `--wait`: Helm blocks until Deployments/StatefulSets report Ready (or the timeout). Turns "the API accepted it" into "the app is actually up."
- `--atomic`: if the release fails (including the `--wait` health check failing), Helm automatically rolls back to the previous good revision. This is the manual `helm rollback` you would otherwise do at 3am, automated.
- `--timeout 5m`: how long to wait before declaring failure.
- `--cleanup-on-fail`: deletes resources newly created by the failed upgrade so you do not leave orphans.

Teaching point:

```text
Teaching upgrade/rollback without --atomic/--wait is teaching the manual version of what every production pipeline automates. The safe command IS the default.
```

## Step 3b: `helm diff` — plan before you apply

Before any upgrade, review the change. The community `helm-diff` plugin is the de-facto standard and is the direct analog of `terraform plan` (which the very next week, Week 14, makes central):

```bash
helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade student-app-dev . -f values-dev.yaml --set image.tag=1.27
```

It prints a colorized diff of the *currently deployed* manifests vs *what this upgrade would produce* — added/removed/changed lines only. Make `helm diff upgrade` a required step before every `helm upgrade` in the lab, mirroring the render/plan-before-apply discipline used across this course.

## Step 4: Explain `upgrade --install`

Say:

```text
In CI/CD pipelines, we often do not want to write separate logic for first deployment and later deployments. helm upgrade --install handles both cases.
```

Command (with the safety flags carried through):

```bash
helm upgrade --install student-app-dev . -f values-dev.yaml --atomic --wait --timeout 5m
```

## Step 5: Explain release history

Show:

```bash
helm history student-app-dev
```

Explain:

```text
Helm stores previous revisions. This gives us a path to rollback if a deployment fails.
```

## Step 6: Explain rollback

Show:

```bash
helm rollback student-app-dev 1
```

Important teaching point:

```text
Rollback can restore Kubernetes resources, but it does not automatically undo database migrations, external system changes, or broken data.
```

Also surface the lock state, because students will hit it:

```text
If a previous operation crashed, the release can be stuck "pending-upgrade" and
the next command fails with "another operation (install/upgrade/rollback) is in progress."
Inspect with `helm history`, and recover with `helm rollback <release> <last-good-rev>`
(or, as a last resort, `helm upgrade ... --force`). Do NOT just delete the release.
```

## Step 6b: GitOps reality — where `helm rollback` does NOT belong

By 2026, most Helm-in-production does not run from a laptop with `helm install`. It runs through a **GitOps controller** (Argo CD or Flux). The manual commands you are learning still matter — they are what the controller runs for you and what you reach for when debugging — but the operating model changes.

```text
Manual (this class)            GitOps (Argo CD / Flux)
--------------------           ------------------------------------------
edit values, run helm upgrade  commit values change to Git, open PR
helm rollback <rev>            git revert the commit; controller re-syncs
helm history                   Git history + Argo CD/Flux UI
you hold release state         Git is the source of truth
```

Key tension to state explicitly (this is a real senior interview topic):

```text
In a GitOps shop, running `helm rollback` by hand creates DRIFT: the cluster no
longer matches Git, and the controller will "self-heal" by re-applying the bad
version on the next sync. The correct rollback in GitOps is `git revert`. Use
`helm rollback` for break-glass emergencies, then reconcile Git afterward.
```

How the controller uses Helm: Argo CD and Flux both *render* your chart (effectively `helm template` with your values) and apply the result, reconciling continuously. Many shops even use Helm purely as a templating engine (`helm template | kubectl apply`) and let the GitOps controller own state. This is why the templating skills from Class 1 matter even where nobody types `helm install`.

## Step 7: Instructor demo

Demonstrate dev and prod releases from one chart.

Pause after installing both releases and ask:

```text
Are these two different charts or two releases from the same chart?
```

Expected answer:

```text
Two releases from the same chart.
```

## Step 8: Student lab

Students deploy:

- `student-app-dev`
- `student-app-prod`

Then upgrade dev and roll it back.

## Step 9: Troubleshooting activity

Introduce a bad value:

```yaml
replicaCount: three
```

Have students diagnose the issue with:

```bash
helm template
kubectl describe deployment
helm history
```

## Step 10: Wrap the week

Say:

```text
This week moved us from raw Kubernetes YAML to reusable Helm packaging. This is a major step toward CI/CD, GitOps, and enterprise Kubernetes delivery.
```

---

# 11. Instructor Lecture Notes

## Environment-specific deployment

In real companies, environments are not identical.

A dev environment may use:

```yaml
replicaCount: 1
image:
  tag: "1.27"
```

A prod environment may use:

```yaml
replicaCount: 3
image:
  tag: "1.27"
```

The important point is that the Kubernetes structure should stay consistent, while configuration changes by environment.

Talking point:

```text
We do not want four copied versions of deployment.yaml. We want one template with controlled values.
```

## Why values files matter

Values files reduce duplication. They allow a platform team to standardize templates while application teams provide environment-specific configuration.

Enterprise example:

- Platform team owns chart structure.
- Application team owns image tag and app settings.
- Security team reviews secret handling.
- SRE team reviews probes, resources, and alerts.
- DevOps team automates deployment through CI/CD.

## Helm upgrade

A Helm upgrade modifies an existing release. Each upgrade creates a new revision.

The safe, production-default form (teach this one):

```bash
helm upgrade --install student-app-dev . -f values-dev.yaml \
  --set image.tag=1.27 \
  --atomic --wait --timeout 5m --cleanup-on-fail
```

`--wait` blocks until resources are Ready; `--atomic` auto-rolls-back the entire release on any failure; `--cleanup-on-fail` removes orphaned new resources. A bare `helm upgrade` without these flags reports success the moment the API server accepts the manifests — which is why an upgrade can "succeed" while the app crash-loops.

Talking point:

```text
A Helm upgrade is a controlled change to a release. Validate it like code: helm diff upgrade to preview, then upgrade with --atomic --wait so failure auto-recovers.
```

## `upgrade --install`

This is common in pipelines:

```bash
helm upgrade --install student-app-dev . -f values-dev.yaml
```

It means:

- If the release exists, upgrade it.
- If it does not exist, install it.

This is useful because pipelines can use the same command repeatedly.

## Release history

Helm tracks revisions:

```bash
helm history student-app-dev
```

Example:

```text
REVISION    UPDATED                     STATUS      CHART
1           2026-04-26 10:00:00         superseded  student-app-0.1.0
2           2026-04-26 10:10:00         deployed    student-app-0.1.0
```

## Rollback

Rollback returns the release to a previous revision:

```bash
helm rollback student-app-dev 1
```

Talking point:

```text
Rollback is a safety tool, not a replacement for testing, monitoring, or careful release planning.
```

## Helm hooks (the mechanism behind ordered operations)

Sometimes resources must run in a defined order around an upgrade — most commonly a **database migration Job before the new pods start**. Helm models this with hooks: ordinary manifests annotated with a hook type and an optional weight (lower weights run first).

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ .Release.Name }}-db-migrate"
  annotations:
    "helm.sh/hook": pre-upgrade,pre-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: migrate
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          command: ["./migrate.sh"]
```

This is exactly *why* the rollback caveat exists: `helm rollback` reverts the Kubernetes objects, but a `pre-upgrade` migration that already ran against the database is not undone by rollback. Hooks plus the rollback caveat are the same lesson from two angles.

Common hook types: `pre-install`, `post-install`, `pre-upgrade`, `post-upgrade`, `pre-delete`, `post-delete`, and `test` (used by `helm test`).

## Release storage and history growth

Helm 3 stores release state as a **Secret per revision** in the release's namespace (named like `sh.helm.release.v1.<release>.v<n>`). There is no Tiller — Helm 3 is client-only. Two practical consequences:

- History accumulates one Secret per revision forever unless capped. Use `--history-max N` (e.g. `helm upgrade --install ... --history-max 10`) so old revisions are pruned.
- Because state lives in-cluster, anyone with read access to those Secrets can read rendered values — never put plaintext secrets in values (see secrets note below).

## Secrets in charts (name the real tools)

Plain Kubernetes Secrets are **base64-encoded, not encrypted**, and values you pass end up in release-history Secrets too. Do not hand-edit secrets into `values-prod.yaml`. The standard production options to name:

- **External Secrets Operator (ESO)** — syncs from AWS Secrets Manager / SSM Parameter Store into K8s Secrets (the AWS-first choice; ties back to Week 6).
- **Sealed Secrets** (Bitnami) — encrypts secrets so the *ciphertext* can live safely in Git.
- **SOPS + `helm secrets` plugin** — encrypts values files with KMS/age before commit.

Rotating a secret should never require putting its plaintext into a Helm value or `--set`.

## Common misconceptions

| Misconception | Correction |
|---|---|
| Rollback fixes every problem | It only restores Kubernetes resources managed by Helm |
| Dev and prod need separate charts | Usually they should use the same chart with different values |
| `--set` is always best | Values files are usually easier to review in Git |
| Successful Helm upgrade means app is healthy | Kubernetes accepted the change, but app health still needs validation |
| Helm history replaces Git history | Helm tracks deployed revisions, Git tracks source changes |

## Enterprise context

In enterprise deployments, Helm is often part of a controlled release process:

```text
Developer opens merge request
CI validates chart
Security scan runs
Helm template output is reviewed
Approval is required for prod
Pipeline runs helm upgrade
Monitoring checks deployment health
Rollback is available if needed
```

---

# 12. Whiteboard Explanation

## Simple Class 2 diagram

```text
                 One Helm Chart
              ┌─────────────────┐
              │ student-app     │
              │ templates/      │
              │ values.yaml     │
              └────────┬────────┘
                       │
          ┌────────────┴────────────┐
          │                         │
          ▼                         ▼
 values-dev.yaml              values-prod.yaml
 replicaCount: 1              replicaCount: 3
 image.tag: 1.27              image.tag: 1.27
          │                         │
          ▼                         ▼
 student-app-dev              student-app-prod
 Helm Release                 Helm Release
          │                         │
          ▼                         ▼
 Kubernetes resources         Kubernetes resources
```

## Step-by-step flow

1. Start with one Helm chart.
2. Create a dev values file.
3. Create a prod values file.
4. Install dev release using dev values.
5. Install prod release using prod values.
6. Upgrade one release.
7. Check release history.
8. Roll back if needed.

## How Class 2 extends Class 1

```text
Class 1:
One chart → one release → install and uninstall

Class 2:
One chart → multiple values files → multiple releases → upgrade → history → rollback
```

## Enterprise version

```text
Application Repository
       │
       │ merge request
       ▼
CI/CD Pipeline
       │
       ├── helm lint
       ├── helm template
       ├── security checks
       ├── manual approval for prod
       ▼
Amazon ECR image tag
       │
       ▼
Helm upgrade --install
       │
       ▼
Amazon EKS
       │
       ▼
CloudWatch, Prometheus, Grafana, or Datadog
       │
       ▼
Rollback decision if health checks fail
```

---

# 13. Instructor Demo Script

## Demo title

**Deploy Dev and Prod Releases, Perform Upgrade, and Roll Back**

## Demo objective

Demonstrate how one Helm chart can deploy multiple environments and how Helm supports release updates and rollback.

## Required setup

Instructor should be inside the Class 1 chart directory:

```bash
cd week13-lab/student-app
```

Validate:

```bash
helm version
kubectl get nodes
helm lint .
```

Expected:

```text
1 chart(s) linted, 0 chart(s) failed
```

## Step 1: Create dev values file

```bash
cat > values-dev.yaml <<'EOF'
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.27"

service:
  type: ClusterIP
  port: 80

# Probes and resources are REQUIRED, not optional — they make the chart production-grade.
resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    cpu: 100m
    memory: 128Mi

livenessProbe:
  httpGet:
    path: /
    port: http
readinessProbe:
  httpGet:
    path: /
    port: http
EOF
```

Explain:

```text
Dev has one replica and a pinned image tag. Even dev declares probes and resources so the chart is consistent across environments.
```

## Step 2: Create prod values file

```bash
cat > values-prod.yaml <<'EOF'
replicaCount: 3

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.27"

service:
  type: ClusterIP
  port: 80

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 250m
    memory: 256Mi

livenessProbe:
  httpGet:
    path: /
    port: http
readinessProbe:
  httpGet:
    path: /
    port: http
EOF
```

Explain:

```text
Prod uses more replicas and larger resource requests. Same pinned tag here for the demo; in real life prod is promoted from a tested dev tag, never "latest".
```

## Step 3: Render both environments

```bash
helm template student-app-dev . -f values-dev.yaml
```

```bash
helm template student-app-prod . -f values-prod.yaml
```

Expected output should include:

```text
kind: Deployment
kind: Service
```

Explain:

```text
We are checking what Kubernetes will receive before installing.
```

## Step 4: Install dev release

```bash
helm upgrade --install student-app-dev . -f values-dev.yaml --atomic --wait --timeout 5m
```

Expected output:

```text
Release "student-app-dev" does not exist. Installing it now.
NAME: student-app-dev
STATUS: deployed
REVISION: 1
```

Explain: with `--wait`, this command does not return until the pods are Ready — so "deployed" actually means "running."

## Step 5: Install prod release

```bash
helm upgrade --install student-app-prod . -f values-prod.yaml --atomic --wait --timeout 5m
```

Expected output:

```text
Release "student-app-prod" does not exist. Installing it now.
NAME: student-app-prod
STATUS: deployed
REVISION: 1
```

## Step 6: Validate releases

```bash
helm list
```

Expected:

```text
student-app-dev    default    1    deployed
student-app-prod   default    1    deployed
```

```bash
kubectl get pods
```

Expected:

```text
student-app-dev-xxxxx     1/1     Running
student-app-prod-xxxxx    1/1     Running
student-app-prod-yyyyy    1/1     Running
student-app-prod-zzzzz    1/1     Running
```

Explain:

```text
Same chart, different values, different releases.
```

## Step 7: Diff, then upgrade dev release

First preview the change (plan-before-apply):

```bash
helm diff upgrade student-app-dev . -f values-dev.yaml --set image.tag=1.27.1
```

Expected (abbreviated): a colorized diff showing only the changed image line, e.g.

```diff
- image: "nginx:1.27"
+ image: "nginx:1.27.1"
```

Then apply with the safe flags:

```bash
helm upgrade student-app-dev . -f values-dev.yaml --set image.tag=1.27.1 \
  --atomic --wait --timeout 5m --cleanup-on-fail
```

Expected:

```text
Release "student-app-dev" has been upgraded.
STATUS: deployed
REVISION: 2
```

Teaching aside: had the new tag been broken, `--atomic --wait` would have detected the unhealthy pods, auto-rolled back to revision 1, and returned a non-zero exit code — exactly what you want a CI job to do.

## Step 8: Check release history

```bash
helm history student-app-dev
```

Expected:

```text
REVISION    STATUS       CHART
1           superseded   student-app-0.1.0
2           deployed     student-app-0.1.0
```

Explain:

```text
Helm tracks revisions, which gives us a rollback path.
```

## Step 9: Roll back dev release

```bash
helm rollback student-app-dev 1
```

Expected:

```text
Rollback was a success! Happy Helming!
```

Validate:

```bash
helm history student-app-dev
helm status student-app-dev
```

## Step 10: Cleanup

```bash
helm uninstall student-app-dev
helm uninstall student-app-prod
```

Validate:

```bash
helm list
kubectl get pods
```

## Common demo failure points

| Failure | Cause | Recovery |
|---|---|---|
| Release already exists | Previous lab resources still exist | Run `helm list`, then uninstall old release |
| Pod stuck in ImagePullBackOff | Bad image tag | Use a valid pinned tag such as `nginx:1.27` |
| YAML parse error | Bad values file | Run `helm lint` and inspect values file |
| Upgrade fails | Invalid rendered Kubernetes spec | Run `helm template` and `kubectl describe` |
| Rollback revision not found | Wrong revision number | Run `helm history <release>` |

---

# 14. Student Lab Manual

## Lab title

**Deploy Dev and Prod Releases with Helm Values, Upgrade, and Roll Back**

## Lab objective

Use one Helm chart to deploy two environment-specific releases, perform an upgrade, inspect release history, and roll back a release.

## Estimated time

40 minutes

## Student prerequisites

Students need:

- Working Kubernetes cluster
- Helm installed
- Class 1 `student-app` chart
- Basic understanding of chart and release

## Starting point from Class 1

Use:

```bash
cd week13-lab/student-app
```

If missing:

```bash
mkdir -p week13-lab
cd week13-lab
helm create student-app
cd student-app
```

## Architecture or workflow overview

```text
student-app chart
   ├── values-dev.yaml  → student-app-dev release
   └── values-prod.yaml → student-app-prod release
```

## Step 1: Create `values-dev.yaml`

Probes and resources are part of the required values, not an afterthought.

```bash
cat > values-dev.yaml <<'EOF'
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.27"

service:
  type: ClusterIP
  port: 80

resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    cpu: 100m
    memory: 128Mi

livenessProbe:
  httpGet:
    path: /
    port: http
readinessProbe:
  httpGet:
    path: /
    port: http
EOF
```

## Step 2: Create `values-prod.yaml`

```bash
cat > values-prod.yaml <<'EOF'
replicaCount: 3

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.27"

service:
  type: ClusterIP
  port: 80

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 250m
    memory: 256Mi

livenessProbe:
  httpGet:
    path: /
    port: http
readinessProbe:
  httpGet:
    path: /
    port: http
EOF
```

## Step 3: Validate chart

```bash
helm lint .
```

Expected:

```text
1 chart(s) linted, 0 chart(s) failed
```

## Step 4: Render dev and prod

```bash
helm template student-app-dev . -f values-dev.yaml
```

```bash
helm template student-app-prod . -f values-prod.yaml
```

Expected output should include:

```text
kind: Service
kind: Deployment
```

## Step 5: Deploy dev release (with safety flags)

```bash
helm upgrade --install student-app-dev . -f values-dev.yaml --atomic --wait --timeout 5m
```

Expected:

```text
STATUS: deployed
REVISION: 1
```

## Step 6: Deploy prod release

```bash
helm upgrade --install student-app-prod . -f values-prod.yaml --atomic --wait --timeout 5m
```

Expected:

```text
STATUS: deployed
REVISION: 1
```

## Step 7: Validate releases

```bash
helm list
kubectl get pods
kubectl get svc
```

Expected:

```text
student-app-dev    deployed
student-app-prod   deployed
```

Expected pod pattern:

```text
student-app-dev-xxxxx      Running
student-app-prod-xxxxx     Running
student-app-prod-yyyyy     Running
student-app-prod-zzzzz     Running
```

## Step 8: Diff, then upgrade dev image tag

First install the `helm-diff` plugin once (skip if already installed):

```bash
helm plugin install https://github.com/databus23/helm-diff || true
```

Preview the change before applying it:

```bash
helm diff upgrade student-app-dev . -f values-dev.yaml --set image.tag=1.27.1
```

Then upgrade with the safe flags:

```bash
helm upgrade student-app-dev . -f values-dev.yaml --set image.tag=1.27.1 \
  --atomic --wait --timeout 5m --cleanup-on-fail
```

Expected:

```text
Release "student-app-dev" has been upgraded.
REVISION: 2
```

## Step 9: View release history

```bash
helm history student-app-dev
```

Expected:

```text
REVISION    STATUS
1           superseded
2           deployed
```

## Step 10: Roll back to revision 1

```bash
helm rollback student-app-dev 1
```

Expected:

```text
Rollback was a success
```

## Step 11: Validate rollback

```bash
helm history student-app-dev
helm status student-app-dev
kubectl get pods
```

## Step 12: Cleanup

```bash
helm uninstall student-app-dev
helm uninstall student-app-prod
```

Validate:

```bash
helm list
kubectl get pods
kubectl get svc
```

## Validation checklist

Students should confirm:

- [ ] `values-dev.yaml` exists.
- [ ] `values-prod.yaml` exists.
- [ ] Dev release has 1 replica.
- [ ] Prod release has 3 replicas.
- [ ] `helm upgrade` created a new revision.
- [ ] `helm history` shows revisions.
- [ ] `helm rollback` succeeded.
- [ ] Both releases were cleaned up.

## Troubleshooting tips

| Problem | What to Check |
|---|---|
| Bad YAML | Run `helm lint .` |
| Wrong rendered output | Run `helm template <release> . -f <file>` |
| Release already exists | Run `helm list` |
| No pod created | Check if Helm install actually succeeded |
| Pod not running | Use `kubectl describe pod` and `kubectl logs` |
| Rollback fails | Check revision number with `helm history` |

## Reflection questions

1. Why is one chart with multiple values files better than copying YAML?
2. What changed between dev and prod?
3. What does `helm upgrade --install` do?
4. What does Helm release history show?
5. What are the limits of Helm rollback?

## Optional challenge task: prove `--atomic` auto-recovers

Resources and probes are already in your values files (core, not a challenge). Instead, prove the safety flag works.

1. Upgrade dev to an image tag that does not exist, with the safe flags:

   ```bash
   helm upgrade student-app-dev . -f values-dev.yaml --set image.tag=does-not-exist \
     --atomic --wait --timeout 60s
   ```

2. Observe: the new pods enter `ImagePullBackOff`, `--wait` never sees them Ready, the timeout fires, and `--atomic` automatically rolls the release back. The command exits non-zero.

3. Confirm the release is still on the last good revision and the app is still serving:

   ```bash
   helm history student-app-dev
   helm status student-app-dev
   kubectl get pods
   ```

4. Discuss: this is exactly the behavior you want in a CI job — a bad deploy reverts itself and fails the pipeline, rather than leaving a half-broken release running.

---

# 15. Troubleshooting Activity

## Incident title

**Prod Helm Upgrade Fails Because of Invalid Replica Count**

## Business impact

A production deployment is blocked during a scheduled release window. The application team cannot deploy the new version, and the release manager needs a quick root cause and recovery plan.

## Symptoms

Student runs:

```bash
helm upgrade student-app-prod . -f values-prod.yaml
```

Error:

```text
Error: UPGRADE FAILED: cannot patch "student-app-prod" with kind Deployment:
Deployment.apps "student-app-prod" is invalid:
spec.replicas: Invalid value: "string": spec.replicas in body must be of type integer
```

## Starting evidence

Broken `values-prod.yaml`:

```yaml
replicaCount: three

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "stable"

service:
  type: ClusterIP
  port: 80
```

## Student investigation steps

1. Check release status:

```bash
helm status student-app-prod
```

2. Check release history:

```bash
helm history student-app-prod
```

3. Render the chart:

```bash
helm template student-app-prod . -f values-prod.yaml
```

4. Inspect rendered Deployment and look for:

```yaml
replicas: three
```

5. Correct the value:

```yaml
replicaCount: 3
```

6. Validate:

```bash
helm lint .
helm template student-app-prod . -f values-prod.yaml
```

7. Retry upgrade:

```bash
helm upgrade student-app-prod . -f values-prod.yaml
```

8. If needed, roll back:

```bash
helm rollback student-app-prod <previous-revision>
```

## Expected root cause

`replicaCount` was set to a string value, `three`, instead of an integer, `3`.

## Correct resolution

Correct:

```yaml
replicaCount: 3
```

Then run:

```bash
helm lint .
helm template student-app-prod . -f values-prod.yaml
helm upgrade student-app-prod . -f values-prod.yaml
```

## Common wrong paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Restarting Kubernetes | The cluster is not the root cause |
| Reinstalling Helm | Helm is working correctly |
| Changing image tag | Image tag is unrelated to replica count validation |
| Deleting the namespace | Too destructive for a simple values issue |
| Checking application logs first | The deployment failed before app runtime behavior matters |

## Instructor hints

Use these in sequence:

```text
Did Helm render the value you expected?
```

```text
What type does Kubernetes expect for replicas?
```

```text
Can you find the rendered replicas field in helm template output?
```

## Preventive action

Add validation to the release workflow:

```text
helm lint
helm template
schema validation
peer review of values files
manual approval for production
post-deployment health checks
```

In enterprise CI/CD, use:

```bash
helm lint .
helm template student-app-prod . -f values-prod.yaml
```

before production deployment.

---

# 16. Scenario-Based Discussion Questions

## Question 1

**Why should dev and prod use the same Helm chart but different values files?**

Expected themes:

- Reuse
- consistency
- fewer copy/paste mistakes
- controlled environment differences
- easier support

Follow-up:

```text
What settings should be different between dev and prod?
```

## Question 2

**When should a team use `helm upgrade --install` instead of `helm install`?**

Expected themes:

- CI/CD repeatability
- works for first deployment and future deployments
- reduces conditional pipeline logic

Follow-up:

```text
Could this command be dangerous without validation?
```

## Question 3

**What should happen before a Helm upgrade reaches production?**

Expected themes:

- lint
- template render
- code review
- approval
- security checks
- monitoring readiness
- rollback plan

Follow-up:

```text
Which checks would you automate in a pipeline?
```

## Question 4

**What are the limits of Helm rollback?**

Expected themes:

- does not undo database migrations
- does not fix bad data
- may not reverse external cloud resources
- depends on previous revision
- still requires monitoring

Follow-up:

```text
What should a release plan include besides rollback?
```

## Question 5

**Who should approve a production values file change?**

Expected themes:

- app owner
- DevOps/platform owner
- SRE for reliability-sensitive changes
- security for secret or permission changes

Follow-up:

```text
Should replica count changes require the same approval as image tag changes?
```

## Question 6

**How can Helm values create cost problems?**

Expected themes:

- too many replicas
- large resource limits
- LoadBalancer service type
- persistent volumes
- cloud-specific annotations

Follow-up:

```text
What values would you restrict or review in production?
```

## Question 7

**How does Helm fit into GitOps or platform engineering?**

Expected themes:

- charts as reusable packages
- values in Git
- reviewable deployment changes
- platform golden paths
- automated sync with tools like Argo CD or Flux

Follow-up:

```text
What should be owned by platform teams vs application teams?
```

---

# 17. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple choice

What is the main purpose of using separate `values-dev.yaml` and `values-prod.yaml` files?

A. To create two separate Kubernetes clusters  
B. To use the same chart with different environment settings  
C. To replace Helm templates  
D. To avoid using Kubernetes Services  

**Answer:** B  
**Explanation:** Separate values files allow one chart to deploy different environment configurations.

## Question 2: True or false

`helm upgrade --install` installs a release if it does not exist and upgrades it if it already exists.

**Answer:** True  
**Explanation:** This is why it is commonly used in CI/CD pipelines.

## Question 3: Short answer

How does Class 2 extend what students learned in Class 1?

**Answer:**  
Class 1 covered creating and installing a basic Helm chart. Class 2 adds environment-specific values, upgrades, release history, and rollback.

## Question 4: Multiple choice

Which command shows previous revisions of a Helm release?

A. `helm list --old`  
B. `helm history <release>`  
C. `helm versions <release>`  
D. `kubectl history <release>`  

**Answer:** B  
**Explanation:** `helm history` shows release revisions.

## Question 5: Troubleshooting

A Helm upgrade fails because `replicaCount` is set to `three`. What is the issue?

**Answer:**  
`replicaCount` should be an integer, such as `3`, not a string.

**Explanation:** Kubernetes expects `spec.replicas` to be a number.

## Question 6: Multiple choice

Which command rolls back a release to revision 1?

A. `helm undo app 1`  
B. `helm rollback app 1`  
C. `helm restore app 1`  
D. `kubectl rollback app 1`  

**Answer:** B  
**Explanation:** Helm uses `helm rollback <release> <revision>`.

## Question 7: AWS-related

In AWS, where would the container image referenced by Helm values commonly be stored?

A. Amazon S3  
B. Amazon ECR  
C. Amazon Route 53  
D. AWS CloudTrail  

**Answer:** B  
**Explanation:** Amazon ECR stores container images used by EKS workloads.

## Question 8: AWS-related

Which AWS service is the managed Kubernetes platform where Helm charts are commonly deployed?

A. Amazon EKS  
B. Amazon RDS  
C. Amazon SQS  
D. Amazon CloudFront  

**Answer:** A  
**Explanation:** EKS is AWS managed Kubernetes.

## Question 9: True or false

A successful Helm upgrade always means the application is healthy.

**Answer:** False  
**Explanation:** Helm may successfully apply resources, but the app could still fail at runtime.

## Question 10: Class 1 and Class 2 connection

Why should students still use `helm template` in Class 2 before upgrades?

**Answer:**  
Because it shows the final rendered Kubernetes YAML and helps catch values or template issues before changing the cluster.

## Question 11: Troubleshooting

A release upgrade fails and the previous revision was healthy. What Helm command can help restore the previous version?

**Answer:**  
`helm rollback <release-name> <previous-revision>`

**Explanation:** Helm rollback restores a previous release revision.

## Question 12: Short answer

Name two things Helm rollback may not fix.

**Answer:**  
Database migrations, corrupted data, external cloud resource changes, or manually changed resources outside Helm.

---

# 18. Homework Assignment

## Assignment title

**Design a Helm Deployment and Rollback Strategy for Dev and Prod**

## Scenario

Your company is moving Kubernetes deployments to Helm. The application team wants to deploy the same service to dev and prod using one chart. The DevOps team wants a repeatable upgrade process, and the SRE team wants a rollback plan if production health checks fail.

## Student tasks

Create a short deployment design document that includes:

1. Helm chart name
2. Dev release name
3. Prod release name
4. Example `values-dev.yaml`
5. Example `values-prod.yaml`
6. Upgrade command for dev
7. Upgrade command for prod
8. Rollback command
9. Pre-deployment validation steps
10. Post-deployment validation steps
11. Two possible failure scenarios
12. Preventive actions

## Expected deliverables

Submit:

```text
week13-class2-homework/
├── helm-deployment-strategy.md
├── values-dev.yaml
└── values-prod.yaml
```

## Submission format

Markdown plus YAML files.

## Estimated completion time

75 to 90 minutes

## Grading criteria

| Criteria | Points |
|---|---:|
| Clear dev and prod values design | 20 |
| Correct Helm upgrade commands | 15 |
| Correct rollback plan | 15 |
| Pre and post validation steps | 20 |
| Troubleshooting scenarios | 15 |
| Clear formatting and explanation | 15 |

## Optional advanced challenge

Add a production approval workflow:

```text
merge request
  ↓
helm lint
  ↓
helm template
  ↓
security scan
  ↓
manual approval
  ↓
helm upgrade --install
  ↓
health check
  ↓
rollback decision
```

---

# 19. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Creating separate charts for dev and prod | Students think each environment needs its own chart | Use same chart with different values |
| Using strings for numeric fields | YAML values can look valid but fail Kubernetes validation | Use `replicaCount: 3`, not `replicaCount: three` |
| Forgetting `-f values-prod.yaml` | Students run upgrade with defaults accidentally | Always review command before running |
| Using `--set` for everything | Quick for demos but hard to audit | Prefer values files for reviewable changes |
| Forgetting to check release history | Students do not know revision numbers | Run `helm history <release>` before rollback |
| Rolling back blindly | Rollback may not fix all problems | Check symptoms, history, and impact first |
| Assuming Helm success means app success | Helm only confirms resource application | Validate pods, services, logs, and metrics |
| Not cleaning up releases | Leaves resources running | Run `helm uninstall` during lab cleanup |
| Editing templates when only values need changing | Students overcomplicate changes | Change values first unless structure needs to change |
| Ignoring production approval | Beginners focus only on commands | Reinforce enterprise workflow and risk |

---

# 20. Real-World Enterprise Scenario

## Scenario

A logistics company runs several internal APIs on Amazon EKS. The platform team provides a standard Helm chart for web services. Application teams provide environment-specific values files.

The company has:

- dev environment for testing
- prod environment for real business traffic
- Amazon ECR for images
- EKS for workloads
- CloudWatch and Datadog for monitoring
- approval requirements for production

## Constraints

| Constraint | Example |
|---|---|
| Access control | Developers can deploy to dev, but production needs approval |
| Security | Secrets cannot be hardcoded in values files |
| Cost | Prod replica count must be justified |
| Reliability | Readiness probes and rollback plan required |
| Production impact | Failed release could affect business users |
| Auditability | All values changes must be reviewed in Git |

## How the class topic applies

Helm allows the company to:

- standardize deployment structure
- manage dev and prod differences cleanly
- track release history
- roll back failed application releases
- integrate deployment into CI/CD
- reduce manual YAML mistakes

## Role responsibilities

| Role | What They Would Do |
|---|---|
| DevOps Engineer | Build pipeline that runs Helm upgrade with validated values |
| Cloud Engineer | Ensure EKS, IAM, ECR, and networking are ready |
| SRE | Define health checks, rollback criteria, and monitoring |
| Security Engineer | Review secret handling and permissions |
| Application Developer | Provide app-specific values and confirm behavior |

---

# 21. Instructor Tips

## Teaching tips

- Use the phrase: “same chart, different values” repeatedly.
- Keep examples small: replica count and image tag are enough.
- Explain rollback carefully. Do not oversell it.
- Show `helm history` before rollback every time.
- Use `helm template` before every install or upgrade.

## Pacing tips

- Do not spend too much time reviewing Class 1.
- Keep the demo under 35 minutes.
- Leave enough time for students to break and fix values files.
- Cover the GitOps mapping (Section 10, Step 6b) at a conceptual level here; deep Argo CD/Flux labs come in the Platform Engineering week (Week 20). Do not skip the "rollback = git revert" point — it is a common interview question.

## Lab support tips

Use this troubleshooting sequence:

```text
Did helm lint pass?
Did helm template show expected YAML?
Did helm upgrade succeed?
Did Kubernetes accept the resources?
Are the pods healthy?
Does helm history show the expected revisions?
```

## Helping struggling students

For beginners:

- Give them working `values-dev.yaml` and `values-prod.yaml`.
- Ask them to change only `replicaCount`.
- Walk them through `helm history`.
- Explain rollback using a simple timeline.

## Challenging advanced students

Ask them to add:

- resource requests and limits
- readiness and liveness probes
- ConfigMap values
- namespace support
- image tag override through `--set`
- environment-specific ingress hostnames

---

# 22. Student Outcome Checklist

## Students should be able to explain

- [ ] Why values files are useful
- [ ] Difference between default values and environment values
- [ ] How one chart can create multiple releases
- [ ] What `helm upgrade` does
- [ ] Why `helm upgrade --install` is common in CI/CD
- [ ] What release history shows
- [ ] What rollback does and does not fix
- [ ] How Helm supports enterprise deployment patterns

## Students should be able to build or configure

- [ ] `values-dev.yaml`
- [ ] `values-prod.yaml`
- [ ] Dev Helm release
- [ ] Prod Helm release
- [ ] Helm upgrade command
- [ ] Helm rollback command
- [ ] Pre-deployment validation workflow

## Students should be able to troubleshoot

- [ ] Invalid values file
- [ ] Wrong replica count type
- [ ] Release already exists
- [ ] Failed upgrade
- [ ] Wrong revision number
- [ ] Pod failure after successful Helm upgrade
- [ ] Difference between Helm-level and Kubernetes-level failure

---

# 23. Class Completion Checklist

## Instructor checklist before ending class

- [ ] Reviewed Class 1 concepts.
- [ ] Explained environment-specific values.
- [ ] Demonstrated dev and prod values files.
- [ ] Demonstrated `helm upgrade --install`.
- [ ] Demonstrated `helm history`.
- [ ] Demonstrated `helm rollback`.
- [ ] Completed troubleshooting activity.
- [ ] Explained rollback limitations.
- [ ] Explained homework.
- [ ] Connected Helm to enterprise CI/CD and EKS workflows.

## Student checklist before leaving class

- [ ] Created `values-dev.yaml`.
- [ ] Created `values-prod.yaml`.
- [ ] Installed dev release.
- [ ] Installed prod release.
- [ ] Upgraded a release.
- [ ] Viewed release history.
- [ ] Rolled back a release.
- [ ] Cleaned up releases.
- [ ] Understands homework expectations.

## Items to verify before closing the week

Students should be ready to explain:

- Helm chart structure
- values files
- dev and prod differences
- install vs upgrade
- release history
- rollback
- common Helm troubleshooting commands

Students should be ready to move into the next module with:

- stronger Kubernetes deployment packaging skills
- better YAML discipline
- better release workflow understanding
- readiness for Terraform and enterprise automation connections

---

# 24. End-of-Week Summary

## What students learned this week

This week, students learned how Helm helps package Kubernetes applications into reusable deployment units. They moved from raw Kubernetes YAML to Helm charts, then from basic chart installation to environment-specific deployments, upgrades, release history, and rollback.

## How Class 1 and Class 2 connect

| Class | Focus | Outcome |
|---|---|---|
| Class 1 | Helm fundamentals and chart structure | Students created, rendered, installed, and removed a basic chart |
| Class 2 | Values, upgrades, rollback, and enterprise patterns | Students used one chart for dev and prod, upgraded releases, and rolled back changes |

## How this week prepares students for the next week

Week 13 prepares students for infrastructure automation and enterprise delivery workflows because Helm introduces the idea of reusable, version-controlled, parameterized deployment packages — and the `helm diff` / `--atomic` "plan and safely apply" discipline carries straight into Terraform next week.

This connects directly to:

- Terraform Foundations and Enterprise Workflows (Week 14, Week 15) — `helm diff upgrade` is the `terraform plan` habit
- CI/CD automation (Week 9) — `helm upgrade --install --atomic` is the deploy step
- DevSecOps secure delivery (Week 19) — chart scanning, secrets handling
- Platform Engineering golden paths (Week 20) — charts as reusable building blocks; GitOps with Argo CD/Flux
- EKS application delivery and production release management

## What students should review before the next module

Students should review:

```bash
helm create
helm lint --strict
helm template . --debug
helm install --dry-run --debug
helm diff upgrade            # plugin: plan before apply
helm upgrade --install --atomic --wait --timeout 5m --cleanup-on-fail
helm list
helm status
helm history
helm rollback
helm test
helm dependency update
helm uninstall
```

They should also review:

- YAML indentation
- Kubernetes Deployments
- Kubernetes Services
- container image tags
- replica count
- environment-specific configuration
- difference between Helm failure and Kubernetes runtime failure

## Class Artifacts & Validation

All artifacts are real on-disk files in the [`labs/helm-charts/`](../../labs/helm-charts/) module. This class uses the *environment-specific* and *release* surface of the chart: the `values-prod.yaml` override, the **conditional** resources it flips on (`Ingress`, `HorizontalPodAutoscaler`), and the `helm test` hook. The runner [`labs/helm-charts/validate.sh`](../../labs/helm-charts/validate.sh) executes all 17 gates and exits `0` (`17 passed, 0 failed, 0 deferred`) in this environment with `helm v3.16.3`, `kubeconform v0.6.7`, and `kubectl v1.34.2` against the live `kind-course` cluster.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/helm-charts/solution/chart/webapp/values-prod.yaml | helm | Prod override: Ingress+TLS on, HPA on, pinned tag, raised resources, anti-affinity | `helm template webapp solution/chart/webapp -f solution/chart/webapp/values-prod.yaml \| kubeconform -strict -summary` | PASS — `7 resources, Valid: 7` |
| 2 | labs/helm-charts/solution/chart/webapp/templates/ingress.yaml | helm | Conditional Ingress, gated on `.Values.ingress.enabled` (renders only in prod) | `helm template ... -f values-prod.yaml \| kubeconform -strict` | PASS |
| 3 | labs/helm-charts/solution/chart/webapp/templates/hpa.yaml | helm | Conditional HorizontalPodAutoscaler (`minReplicas 3 / maxReplicas 20`), gated on `.Values.autoscaling.enabled` | `helm template ... -f values-prod.yaml \| kubeconform -strict` | PASS |
| 4 | labs/helm-charts/solution/chart/webapp/templates/tests/test-connection.yaml | helm | `helm test` hook pod that `wget`s the Service (release smoke test) | `helm template webapp solution/chart/webapp \| kubeconform -strict` | PASS (rendered as part of the 5/7 objects) |
| 5 | labs/helm-charts/solution/chart/webapp/values.yaml | helm | Default (dev) values — the base the prod file overrides; proves the 5-vs-7 conditional diff | `helm template webapp solution/chart/webapp \| kubeconform -strict -summary` | PASS — `5 resources, Valid: 5` |
| 6 | labs/helm-charts/solution/chart/webapp/templates/deployment.yaml | helm | Deployment whose config-checksum annotation rolls pods on config change (upgrade behavior) | `helm template webapp solution/chart/webapp \| kubeconform -strict` | PASS |
| 7 | labs/helm-charts/broken/deployment.yaml | helm | Troubleshooting fixture: "Helm renders but the API rejects" — caught by schema gate, not `helm lint` | `helm template ... \| kubeconform -strict` (Errors: 1, exit 1) | PASS — correctly **rejected** as intended |
| 8 | labs/helm-charts/validate.sh | shell | Gate runner incl. **server-side dry-run** of both default and prod renders against `kind-course` | `./validate.sh` | PASS — `17 passed, 0 failed, 0 deferred` |

> The strongest gate here is `helm template ... \| kubectl --context kind-course apply --dry-run=server -f -`, run for both default (5 objects) and prod (7 objects) renders against the **live apiserver**. It validates admission/conditional logic against a real cluster and persists nothing. It is **not** a live release operation: this class teaches `helm upgrade`/`--atomic`/`rollback`/`helm test`/HPA as concepts and renders/validates their manifests, but no release is actually installed, upgraded, rolled back, or autoscaled live in the lab — so there is no `LIVE-*-EVIDENCE.txt` for this module.

## Definition of Done

- [x] Every technology taught (values overrides, conditional resources, release/test hooks) ships a **runnable file on disk** — `values-prod.yaml`, `ingress.yaml`, `hpa.yaml`, `tests/test-connection.yaml`.
- [x] Each artifact passes its **validation gate** (`helm template -f values-prod.yaml | kubeconform -strict`, server-side dry-run); output captured in the lab README.
- [x] Lab has **starter** and **solution** versions (shared chart; starter gaps are in the Deployment template).
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, and cost notes.
- [x] **Cleanup/teardown** is provided and idempotent (`helm uninstall`; render-only flow persists nothing — $0).
- [x] **Instructor answer key** exists (`README` → Instructor answer key; conditional-resource grading = render with/without `-f values-prod.yaml`, count 5 vs 7).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `broken/deployment.yaml` demonstrating the key lesson "`helm lint` passes but `kubeconform`/server dry-run hard-fails."
- [x] **Expected outputs** are shown (prod render = 7 objects adding Ingress+HPA; `minReplicas: 3`, TLS secret `webapp-prod-tls`, host `webapp.prod.example.com`).
- [x] **Cost & security warnings** present (no secrets in values/ConfigMap; TLS secret referenced out-of-band; pin tags in prod; never `--set password=`; $0).
- [x] **Cross-references** to the module repo, Class 1 (chart foundation), and the capstone (W23/W24) are correct.
- [x] The **artifact manifest** (§4.2) above is present and every path resolves.
- [ ] **Mastered** (operated/reused live, capstone-linked): the chart is consumed by the capstone (W23/W24), but in *this* class upgrade/rollback/HPA are rendered and server-side-validated, **not** operated live (no install→upgrade→rollback cycle, no real autoscaling event captured). Honest cap for Class 2 in isolation.
