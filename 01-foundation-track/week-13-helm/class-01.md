# Week 13, Class 1 Package: Helm Fundamentals and Chart Structure
> **▶ Runnable lab for this class:** [`labs/helm-charts/`](../../labs/helm-charts/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Helm and Application Packaging

**Week:** 13
**Track:** Unified DevOps · Cloud · SRE Track

# 1. Class Overview

## Class title

**Class 13.1: Helm Fundamentals and Chart Structure**

## Class purpose

This class introduces Helm as the package manager for Kubernetes applications. Students learn why raw Kubernetes YAML becomes difficult to manage at scale and how Helm charts help teams create reusable, configurable, and repeatable application deployments.

## How this class connects to the overall course

This class builds directly from:

- **Week 11 (Kubernetes Fundamentals):** pods, deployments, services, labels, selectors, YAML manifests
- **Week 12 (Kubernetes Troubleshooting):** logs, events, service troubleshooting, DNS, failed deployments
- **Week 10 (Docker/Containers):** building and tagging the container images Helm references

Students already know how to deploy Kubernetes objects manually. This class teaches them how to package those objects into a reusable deployment unit using Helm, and — critically — how to *author* and *read* the Go templates that make a chart configurable.

This prepares students for:

- Helm values, upgrades, and rollbacks in Class 2
- Terraform foundations and enterprise workflows (Week 14, Week 15) — the same "render/plan before apply" discipline
- DevSecOps secure delivery (Week 19)
- Platform Engineering golden paths (Week 20), where charts become the reusable building blocks
- GitOps delivery (Argo CD / Flux render the very charts authored here)

## What students will build, analyze, or practice

Students will:

- Inspect the structure of a Helm chart
- Render Helm templates locally
- Install a Helm release into Kubernetes
- Convert a basic Kubernetes app into a Helm chart
- Troubleshoot YAML and Helm rendering errors
- Understand how Helm supports enterprise application delivery

---

# 2. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** what Helm is and why it is used in Kubernetes deployments.
2. **Compare** raw Kubernetes manifests with reusable Helm charts.
3. **Identify** the purpose of `Chart.yaml`, `values.yaml`, and the `templates/` directory.
4. **Build** a basic Helm chart from an existing Kubernetes application.
5. **Render** Helm templates locally before applying them to a cluster.
6. **Install** and **validate** a Helm release using `helm` and `kubectl`.
7. **Troubleshoot** common Helm chart issues such as YAML syntax errors and missing values.
8. **Document** how Helm improves application deployment standardization in enterprise environments.

---

# 3. Prerequisites Students Should Already Know

## Required prior concepts

Students should already understand:

- Kubernetes pods
- Deployments
- Services
- Namespaces
- Labels and selectors
- Basic YAML syntax
- `kubectl apply`
- `kubectl get`
- `kubectl describe`
- `kubectl logs`
- Container image basics from the Docker/Containers week (Week 10)

## Required tools already installed

Students should have:

```bash
kubectl version --client
helm version
docker version
git --version
code --version
```

Recommended local Kubernetes options:

- `kind`
- `minikube`
- Docker Desktop Kubernetes
- Existing classroom Kubernetes cluster

## Required accounts or access

For this class, students can use a local Kubernetes cluster.

AWS account is optional for Class 1. If using EKS, students need:

- AWS account access
- AWS CLI configured
- EKS cluster access
- `kubectl` configured for the EKS cluster

## Files, repos, or sample code needed

Students should have access to the Week 11 / Week 12 sample Kubernetes app, or use the sample manifests below.

Recommended folder:

```text
week13-helm/
├── raw-k8s/
│   ├── deployment.yaml
│   └── service.yaml
└── charts/
```

The sample app can be a simple NGINX-based app from the Kubernetes weeks (Week 11/12).

---

# 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Helm | A package manager for Kubernetes | Similar to how `apt` installs Linux packages, Helm installs Kubernetes applications |
| Chart | A Helm package containing Kubernetes templates and default values | Platform teams create charts so app teams do not rewrite YAML from scratch |
| Release | A running installation of a Helm chart in a cluster | One chart can create many releases, such as `app-dev` and `app-prod` |
| `Chart.yaml` | Metadata file for the Helm chart | Defines chart name, version, and description |
| `values.yaml` | Default configuration file for the chart | Stores image tag, replica count, service port, and environment-specific settings |
| `templates/` | Folder containing Kubernetes YAML templates | Helm renders these templates into normal Kubernetes manifests |
| Template | A Kubernetes manifest with placeholders | Lets one deployment file work for multiple environments |
| Render | The process of converting templates and values into final Kubernetes YAML | Useful before deploying so teams can catch mistakes early |
| Release name | The name given to an installed chart | Helps track and manage installed applications |
| `helm install` | Command used to install a chart for the first time | Creates a release in Kubernetes |
| `helm uninstall` | Command used to remove a release | Cleans up Kubernetes resources created by the chart |
| `helm lint` | Command used to check chart quality and syntax | Helps catch mistakes before deployment; use `--strict` in CI to fail on warnings |
| `helm template` | Command used to preview rendered Kubernetes YAML | Very useful for troubleshooting before installing |
| `_helpers.tpl` | A template file holding reusable named template snippets (labels, names) | Avoids repeating the same label block in every manifest |
| `NOTES.txt` | A template rendered and printed after `helm install`/`upgrade` | Tells the user how to reach the app they just deployed |
| Named template / `define` | A reusable block declared with `{{- define "name" }}` and pulled in with `include` | The DRY mechanism for chart authors |
| `include` | Function that renders a named template and returns a string | Preferred over `template` because its output can be piped (e.g. `\| nindent`) |
| Go template action | The `{{ ... }}` directives Helm evaluates (`.Values`, `if`, `range`, functions) | This is the language you author a chart in |
| `values.schema.json` | A JSON Schema that validates `values.yaml` input | Catches a misspelled or wrong-typed value before render |
| Subchart / dependency | Another chart this chart depends on, declared in `Chart.yaml` `dependencies:` | E.g. bundling a `redis` or `postgresql` chart |
| `helm test` | Runs test Pods defined under `templates/tests/` against a release | Verifies the release actually works, not just that it installed |
| Kustomize | Kubernetes-native, template-free overlay/patch tool | The main alternative to Helm; compared in Section 7.5 |

---

# 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| Helm | Packages and deploys Kubernetes applications |
| kubectl | Validates Kubernetes resources created by Helm |
| Kubernetes | Target platform where Helm releases are installed |
| YAML | Used for Helm values and Kubernetes manifests |
| VS Code | Used to edit chart files and YAML templates |
| Terminal | Used to run Helm and Kubernetes commands |
| Git | Optional, used to version control Helm charts |
| Docker | Required if using local Kubernetes through Docker Desktop, kind, or minikube |

---

# 6. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| Amazon EKS | Managed Kubernetes service where Helm charts are commonly deployed in AWS |
| Amazon ECR | Container registry where application images are stored before Helm deploys them to EKS |
| IAM | Controls who or what can deploy to EKS |
| CloudWatch | Used later to observe applications deployed through Helm |
| AWS CLI | Used in EKS environments to configure cluster access |

## AWS-first framing

In an AWS enterprise environment, the typical flow is:

```text
Developer commits code
CI pipeline builds Docker image
Image is pushed to Amazon ECR
Helm chart is updated with the new image tag
Helm deploys the app to Amazon EKS
CloudWatch or another monitoring tool validates health
```

## Cost warning

For this class, local Kubernetes is recommended to avoid cloud cost.

If using EKS, remind students:

- EKS clusters have hourly cost.
- Load balancers created by Services or Ingress can create cost.
- NAT Gateways can create unexpected cost.
- Always clean up unused resources.

---

# 7. Azure and GCP Comparison Notes

Helm works at the Kubernetes layer, so the same Helm concepts apply across cloud providers.

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Managed Kubernetes | EKS | AKS | GKE |
| Container registry | ECR | Azure Container Registry | Artifact Registry |
| Monitoring | CloudWatch | Azure Monitor | Cloud Monitoring |
| IAM integration | AWS IAM and EKS access entries or aws-auth | Azure RBAC and Entra ID | Google IAM |

Practical note for students:

```text
A Helm chart can often be reused across EKS, AKS, and GKE, but cloud-specific parts such as ingress controllers, storage classes, IAM integration, and load balancer annotations may need changes.
```

---

# 7.5 Helm vs Kustomize

Helm is not the only way to manage configurable Kubernetes manifests. The other tool a senior engineer is expected to know — and to be able to choose between — is **Kustomize** (built into `kubectl` as `kubectl apply -k`).

The core difference: **Helm templates strings; Kustomize patches structured YAML.**

| Dimension | Helm | Kustomize |
|---|---|---|
| Mechanism | Go templating (`{{ .Values.x }}`) renders text into YAML | Strategic-merge / JSON patches over a base of plain YAML |
| Configuration input | `values.yaml` + `--set` | Overlays (`overlays/dev`, `overlays/prod`) that patch a `base/` |
| Packaging / sharing | Charts, versioned, pushed to OCI registries (`helm push`) | No package format; you copy/reference directories or remote bases |
| Release tracking | Yes — `helm history`, `helm rollback` (stores release state in-cluster) | No release object; rollback = re-apply old git commit |
| Dependencies | First-class subcharts (`Chart.yaml` `dependencies:`) | `components` / remote bases, but no version resolution |
| Logic (conditionals, loops) | Full: `if`, `range`, functions | Intentionally none — no logic, patches only |
| Install command | `helm install` / `helm upgrade` | `kubectl apply -k` |

Side-by-side: change the replica count for prod.

Helm — one template, value overridden:

```yaml
# templates/deployment.yaml
spec:
  replicas: {{ .Values.replicaCount }}
```
```yaml
# values-prod.yaml
replicaCount: 3
```

Kustomize — a base manifest, patched by an overlay:

```yaml
# base/deployment.yaml
spec:
  replicas: 1
```
```yaml
# overlays/prod/replicas-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
```
```yaml
# overlays/prod/kustomization.yaml
resources:
  - ../../base
patches:
  - path: replicas-patch.yaml
```

When each wins:

- **Helm** when you need a *distributable, versioned, parameterized package* (third-party software like `ingress-nginx`, `prometheus`; platform "golden path" charts in Week 20), release history/rollback, or conditional logic.
- **Kustomize** when you want *no templating language*, plain readable YAML, and small env-to-env diffs over manifests you own. Many GitOps shops use Kustomize for in-house apps and Helm for third-party software.
- **They compose:** Helm can post-render with Kustomize, and Argo CD / Flux support both. You will meet both again in the GitOps and Platform Engineering weeks.

---

# 8. Time-Boxed Instructor Agenda

| Time | Section | Instructor Activity | Student Activity |
|---:|---|---|---|
| 0:00 to 0:08 | Opening and context | Explain why Helm follows the Kubernetes weeks | Listen and connect prior knowledge |
| 0:08 to 0:18 | Review Kubernetes YAML pain points | Briefly review Deployment/Service/ConfigMap repetition | Answer review questions |
| 0:18 to 0:35 | Why Helm exists; chart vs release | Explain chart, release, values, templates | Compare raw YAML vs Helm |
| 0:35 to 1:00 | Helm chart anatomy (full `helm create` tree) | Walk through every file incl. `_helpers.tpl`, `NOTES.txt`, `charts/`, `tests/` | Inspect chart files |
| 1:00 to 1:35 | **Go templating hands-on** | Parameterize a hardcoded Deployment: `{{ .Values.x }}`, `if`, `range`, `_helpers.tpl`, `nindent`/`toYaml` | Author template blocks |
| 1:35 to 1:45 | Break | Pause | Pause |
| 1:45 to 2:10 | Instructor demo | Create, render (`--debug`), lint `--strict`, install, inspect, test, uninstall | Follow along or observe |
| 2:10 to 2:45 | Student lab | Support students authoring + parameterizing a chart | Build and template a chart |
| 2:45 to 2:55 | Troubleshooting activity | Introduce broken `values.yaml` / template issue | Debug with `helm lint` and `helm template` |
| 2:55 to 3:00 | Recap and homework | Summarize key points and explain homework | Ask final questions |

---

# 9. Instructor Lesson Plan

## Step 1: Open the class

Start by saying:

```text
Last week, we learned how to troubleshoot Kubernetes workloads directly using kubectl, logs, events, services, selectors, and DNS. Today we move from manually managing Kubernetes YAML to packaging applications in a repeatable way using Helm.
```

Ask students:

```text
What problems might happen if every team manually copies and edits Kubernetes YAML for every environment?
```

Expected responses:

- Copy/paste mistakes
- Wrong image tags
- Different YAML across environments
- Hard to roll back
- No standard deployment pattern

## Step 2: Review raw Kubernetes deployment flow

Show a simple raw YAML deployment:

```text
deployment.yaml
service.yaml
configmap.yaml
secret.yaml
ingress.yaml
```

Explain:

```text
This works for one app and one environment. But when we have dev, test, staging, and prod, it becomes difficult to maintain.
```

Teaching tip:

Keep this review short. Students already learned Kubernetes in Weeks 11 and 12.

## Step 3: Introduce Helm as the solution

Explain:

```text
Helm lets us package Kubernetes manifests into a reusable chart. Instead of copying YAML files across environments, we use templates and values.
```

Show the relationship:

```text
Chart + Values = Rendered Kubernetes YAML
```

Pause and ask:

```text
Does Helm replace Kubernetes?
```

Expected answer:

```text
No. Helm generates and applies Kubernetes resources. Kubernetes still runs the workloads.
```

## Step 4: Explain chart structure (the FULL `helm create` tree)

Walk through the *complete* tree `helm create` actually produces — students will see all of these files, so do not hide them:

```text
my-app/
├── Chart.yaml            # chart identity: name, version, appVersion, dependencies
├── values.yaml           # default configuration
├── values.schema.json    # (optional) JSON Schema validating values.yaml
├── .helmignore           # files to exclude when packaging the chart
├── charts/               # subcharts / dependencies live here
└── templates/
    ├── _helpers.tpl      # reusable NAMED templates (labels, names) — no output of its own
    ├── NOTES.txt         # printed to the user after install/upgrade
    ├── deployment.yaml
    ├── service.yaml
    ├── serviceaccount.yaml
    ├── hpa.yaml
    ├── ingress.yaml
    └── tests/
        └── test-connection.yaml   # Pod run by `helm test`
```

Explain each:

- `Chart.yaml`: chart identity. Note the two distinct version fields — `version` (the chart's own version, bumped on any chart change) vs `appVersion` (the version of the app the chart ships). They are independent.
- `values.yaml`: default configuration.
- `values.schema.json`: optional schema; if present, `helm install`/`template` reject values that violate it.
- `templates/`: Kubernetes YAML with Go template placeholders.
- `_helpers.tpl`: defines named templates with `{{- define }}`; produces no manifest itself.
- `NOTES.txt`: rendered like a template and printed after a successful install — used for "your app is at http://...".
- `charts/`: where declared subcharts are vendored by `helm dependency update`.
- `templates/tests/`: test hooks run by `helm test <release>`.

Teaching point:

```text
Files whose name starts with an underscore (like _helpers.tpl) are NOT rendered into manifests. They hold reusable snippets that other templates pull in with `include`.
```

## Step 5: Explain release concept

Use this example:

```text
Same chart:
- app-dev release
- app-test release
- app-prod release
```

Explain:

```text
A chart is the package. A release is an installed copy of that package.
```

## Step 5b: Go templating — author, do not just configure (CORE SEGMENT)

This is the load-bearing skill of the week. A senior engineer must be able to *read, write, and debug* chart templates, not only edit `values.yaml`. Teach it as a live "parameterize a hardcoded manifest" exercise.

### 1. Start from a hardcoded Deployment

```yaml
# hardcoded — works for exactly one app, one environment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 1
  template:
    spec:
      containers:
        - name: web
          image: nginx:1.27
```

### 2. Replace literals with values references

Template actions live inside `{{ }}`. `.Values` reads from `values.yaml`; `.Release`, `.Chart`, and `.Values` are the objects you use most.

```yaml
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
```

Explain the `{{- ` / ` -}}` whitespace chomps: a leading `{{-` trims preceding whitespace/newline, a trailing `-}}` trims following whitespace. This is how you keep rendered YAML correctly indented.

### 3. Conditionals — `if` / `else`

```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-web
{{- end }}
```

Now the Ingress only renders when `ingress.enabled: true`. Demonstrate by flipping the value and re-running `helm template`.

### 4. Loops — `range`

```yaml
env:
{{- range $key, $value := .Values.extraEnv }}
  - name: {{ $key }}
    value: {{ $value | quote }}
{{- end }}
```

with:

```yaml
# values.yaml
extraEnv:
  LOG_LEVEL: info
  REGION: us-east-1
```

### 5. Named templates and `_helpers.tpl`

Define a reusable label block once:

```yaml
{{/* templates/_helpers.tpl */}}
{{- define "myapp.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}
```

Pull it into a manifest with `include` (preferred over `template` because its output can be piped) and `nindent` to indent correctly:

```yaml
metadata:
  name: {{ .Release.Name }}-web
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
```

Note the trailing `.` passed to `include` — it forwards the current scope so the named template can see `.Chart`, `.Release`, etc.

### 6. `toYaml` for whole blocks (probes, resources)

For nested structures, render the whole sub-tree from values instead of field-by-field:

```yaml
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          {{- with .Values.livenessProbe }}
          livenessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
```

Teaching point — `indent` vs `nindent`: `nindent N` adds a leading newline then indents every line by N spaces; `indent N` indents without the leading newline. Use `nindent` when the block starts on its own line.

### 7. Always render before you trust it

```bash
helm template web . --debug
```

```text
A template is just code that prints YAML. If you cannot predict the output, run helm template. NEVER push a template you have not rendered.
```

## Step 6: Demo Helm workflow

Demonstrate:

```bash
helm create my-app
helm lint --strict        # fail on warnings, as CI would
helm template . --debug   # render locally; --debug shows source on error
helm install
helm list
helm status
helm test <release>       # run the test Pod under templates/tests/
helm uninstall
```

Clarify the `helm template` vs `helm install --dry-run` distinction:

- `helm template` renders **purely client-side** — it never talks to the cluster, so it cannot catch errors that need the API server (e.g. a missing CRD, admission webhooks).
- `helm install --dry-run --debug` renders **and** sends the manifests to the API server for validation without persisting them — closer to what install will actually do.

Pause after `helm template`.

Ask:

```text
Why is rendering before installing useful?
```

Expected response:

```text
It lets us inspect the final Kubernetes YAML and catch mistakes before changing the cluster.
```

## Step 7: Student lab

Students convert a simple Kubernetes app into a Helm chart.

Instructor should circulate and watch for:

- YAML indentation problems
- wrong template paths
- students editing too many generated files
- confusion between chart name and release name
- students forgetting to run `helm template`

## Step 8: Troubleshooting activity

Break a YAML value intentionally.

Have students run:

```bash
helm lint .
helm template student-app .
```

Explain:

```text
In real teams, Helm troubleshooting usually starts before deployment. Good teams render and validate before they apply.
```

## Step 9: Recap and transition to Class 2

Close with:

```text
Today we learned the structure and purpose of Helm charts. In Class 2, we will use separate values files for dev and prod, perform upgrades, check release history, and roll back a failed release.
```

---

# 10. Instructor Lecture Notes

## Opening explanation

Helm solves a common Kubernetes problem: repeated YAML. In a small lab, copying and editing a `deployment.yaml` file may seem fine. In a company with dozens of applications and multiple environments, that approach becomes risky.

A production deployment usually needs:

- Deployment
- Service
- ConfigMap
- Secret
- Ingress
- ServiceAccount
- Resource requests and limits
- Probes
- Environment variables
- Labels and annotations

If every team creates these manually, the organization ends up with inconsistent patterns.

## What Helm really does

Helm takes templates and values, then creates final Kubernetes manifests. These manifests are sent to the Kubernetes API.

Talking point:

```text
Helm is not magic. It is a packaging and templating tool for Kubernetes resources.
```

Common misconception:

```text
Students may think Helm runs the application. It does not. Kubernetes runs the application. Helm helps install and manage the Kubernetes objects.
```

## Chart vs release

A chart is reusable. A release is a deployed instance.

Example:

```text
Chart: company-web-app
Release 1: company-web-app-dev
Release 2: company-web-app-prod
```

Same chart, different release names and values.

## Why `values.yaml` matters

`values.yaml` separates configuration from structure.

The template defines the shape:

```yaml
replicas: {{ .Values.replicaCount }}
```

The values file defines the setting:

```yaml
replicaCount: 2
```

This matters because dev and prod usually need different settings.

## Enterprise context

A platform team may create a standard Helm chart for web services. Application teams use it by providing values.

Example platform-provided standards:

- Labels
- Probes
- Resource requests
- Security context
- ServiceAccount pattern
- Ingress conventions
- Monitoring annotations

This reduces deployment inconsistency.

## Chart dependencies and subcharts

Real charts rarely stand alone. A web app may need Redis or PostgreSQL packaged alongside it. Helm models this with **dependencies** declared in `Chart.yaml`:

```yaml
# Chart.yaml
apiVersion: v2
name: myapp
version: 0.1.0
appVersion: "1.0.0"
dependencies:
  - name: redis
    version: "20.x.x"
    repository: "oci://registry-1.docker.io/bitnamicharts"
    condition: redis.enabled    # only pulled in when redis.enabled is true
```

Workflow:

```bash
helm dependency update .   # resolves deps into charts/ and writes Chart.lock
helm dependency list .     # show declared deps and their status
```

Subchart values are namespaced under the subchart name in the parent's `values.yaml`:

```yaml
# parent values.yaml
redis:
  enabled: true
  auth:
    enabled: true
```

Teaching points:

- `Chart.lock` pins resolved versions — commit it, treat it like a lockfile (same discipline as `package-lock.json` or a Terraform lockfile in Week 14).
- The parent can override any subchart value; the subchart can never reach up into the parent.
- `condition:` lets a dependency be toggled on/off per environment without editing `Chart.yaml`.

## Chart distribution: OCI registries

Charts are shared through repositories. The modern (Helm 3.8+) default is **OCI registries** — the same registries that store container images (ECR, GHCR, Docker Hub):

```bash
helm package .                                   # produces myapp-0.1.0.tgz
aws ecr get-login-password --region us-east-1 \
  | helm registry login --username AWS --password-stdin <acct>.dkr.ecr.us-east-1.amazonaws.com
helm push myapp-0.1.0.tgz oci://<acct>.dkr.ecr.us-east-1.amazonaws.com/charts
helm install myapp oci://<acct>.dkr.ecr.us-east-1.amazonaws.com/charts/myapp --version 0.1.0
```

The older classic HTTP repo style still appears in the wild:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami/redis
```

## Chart testing

Installing successfully does not prove the app works. Helm ships a test mechanism — Pods under `templates/tests/` annotated as test hooks:

```yaml
# templates/tests/test-connection.yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ .Release.Name }}-test-connection"
  annotations:
    "helm.sh/hook": test
spec:
  restartPolicy: Never
  containers:
    - name: wget
      image: busybox:1.36
      command: ['wget']
      args: ['{{ .Release.Name }}-web:{{ .Values.service.port }}']
```

Run after install:

```bash
helm test <release>
```

For *template-level* unit tests (assert rendered output without a cluster), the standard tool is the **`helm-unittest`** plugin:

```bash
helm plugin install https://github.com/helm-unittest/helm-unittest
helm unittest .
```

and the CNCF **chart-testing** tool `ct lint-and-install` is the de-facto CI gate for chart repos.

## Common misconceptions

| Misconception | Correction |
|---|---|
| Helm replaces Kubernetes YAML | Helm generates Kubernetes YAML |
| Helm automatically makes apps production-ready | Helm helps package apps, but teams still need good probes, resources, monitoring, and security |
| One chart means one environment | One chart can support many environments |
| Helm rollback fixes everything | Rollback helps with Kubernetes resources but may not fix database migrations or external state |
| Helm is cloud-specific | Helm is Kubernetes-native and works across EKS, AKS, and GKE |
| `helm template` validates against the cluster | It renders client-side only; use `helm install --dry-run` for server-side validation |
| You configure a chart by editing templates | You configure via values; you *author* a chart by editing templates. Know the difference. |
| Helm and Kustomize are competitors you must pick once | They solve overlapping problems differently and frequently coexist (see Section 7.5) |

## Practical talking points

Use these during class:

```text
Raw YAML is fine when learning Kubernetes. Helm becomes useful when teams need repeatability.
```

```text
A Helm chart is a deployment package. A Helm release is the installed running copy.
```

```text
Before installing a chart, always render it with helm template. Do not guess what the final YAML looks like.
```

```text
In enterprise environments, Helm charts often become part of the platform team's golden path.
```

---

# 11. Whiteboard Explanation

## Simple diagram

```text
                  Helm Chart
        ┌────────────────────────┐
        │ Chart.yaml             │
        │ values.yaml            │
        │ templates/             │
        │  ├─ deployment.yaml    │
        │  └─ service.yaml       │
        └───────────┬────────────┘
                    │
                    │ helm template / helm install
                    ▼
        ┌────────────────────────┐
        │ Rendered Kubernetes    │
        │ YAML Manifests         │
        └───────────┬────────────┘
                    │
                    │ Sent to Kubernetes API
                    ▼
        ┌────────────────────────┐
        │ Kubernetes Cluster     │
        │ Pods, Services, etc.   │
        └────────────────────────┘
```

## Step-by-step explanation

1. The chart contains reusable deployment templates.
2. `values.yaml` provides default configuration.
3. Helm combines templates and values.
4. Helm renders normal Kubernetes YAML.
5. Kubernetes creates the resources.
6. The application runs as pods and services.

## Enterprise version

```text
Developer
   │
   │ commits code
   ▼
Git Repository
   │
   │ CI pipeline builds image
   ▼
Container Registry (ECR)
   │
   │ image tag passed to Helm
   ▼
Chart stored in OCI registry (helm push)
   │
   │ helm upgrade --install --atomic
   ▼
EKS Cluster
   │
   │ app runs
   ▼
Monitoring and Alerts
```

## What each component means

| Component | Meaning |
|---|---|
| Developer | Makes application or configuration changes |
| Git repository | Source of truth for app code and deployment files |
| Container registry | Stores built container images |
| Helm chart | Standard package for Kubernetes deployment |
| EKS cluster | AWS managed Kubernetes environment |
| Monitoring | Validates if deployment is healthy |

---

# 12. Instructor Demo Script

## Demo title

**Create, Render, Install, and Remove a Basic Helm Chart**

## Demo objective

Show students the basic Helm workflow:

1. Create a chart
2. Inspect chart structure
3. Render templates
4. Install release
5. Validate Kubernetes resources
6. Uninstall release

## Required setup

Instructor should verify:

```bash
helm version
kubectl version --client
kubectl cluster-info
kubectl get nodes
```

Expected output examples:

```text
version.BuildInfo{Version:"v3.x.x"...}
```

```text
Kubernetes control plane is running at ...
```

```text
NAME                 STATUS   ROLES
kind-control-plane   Ready    control-plane
```

## Step 1: Create working folder

```bash
mkdir -p week13-helm-demo
cd week13-helm-demo
```

Explain:

```text
We are creating a clean workspace for today's Helm demo.
```

## Step 2: Create a Helm chart

```bash
helm create week13-app
cd week13-app
```

Expected output:

```text
Creating week13-app
```

Explain:

```text
The helm create command generates a starter chart structure. In real teams, platform engineers often customize this starter chart heavily.
```

## Step 3: Inspect chart structure

```bash
ls -la
```

Optional:

```bash
tree .
```

Expected structure:

```text
.
├── Chart.yaml
├── charts
├── templates
└── values.yaml
```

Explain:

```text
Chart.yaml describes the chart. values.yaml stores default configuration. templates contains Kubernetes manifests.
```

## Step 4: Inspect `Chart.yaml`

```bash
cat Chart.yaml
```

Explain:

```text
This file contains metadata. It does not run the application. It helps Helm understand the chart name and version.
```

## Step 5: Inspect `values.yaml`

```bash
cat values.yaml
```

Point out:

```yaml
replicaCount: 1
image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: ""
```

Explain:

```text
These are default values. Templates can reference these values dynamically.
```

## Step 6: Render chart locally

```bash
helm template week13-app .
```

Expected output:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: week13-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: week13-app
```

Explain:

```text
This is one of the most important Helm troubleshooting commands. It shows what Kubernetes will receive before we install anything.
```

## Step 7: Lint the chart

```bash
helm lint .
```

Expected output:

```text
==> Linting .
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```

Explain:

```text
A lint warning is not always a failure. In this case, Helm recommends an icon, but the chart is still valid.
```

## Step 8: Install release

```bash
helm install week13-app .
```

Expected output:

```text
NAME: week13-app
LAST DEPLOYED: ...
NAMESPACE: default
STATUS: deployed
REVISION: 1
```

Explain:

```text
We installed the chart as a release named week13-app.
```

## Step 9: Validate release

```bash
helm list
```

Expected output:

```text
NAME          NAMESPACE   REVISION   STATUS    CHART
week13-app    default     1          deployed  week13-app-0.1.0
```

```bash
kubectl get pods
kubectl get svc
```

Expected output:

```text
NAME                           READY   STATUS    RESTARTS
week13-app-xxxxxxxxxx-xxxxx    1/1     Running   0
```

## Step 10: Inspect release status

```bash
helm status week13-app
```

Explain:

```text
helm status gives release-level information. kubectl gives Kubernetes resource-level information. In real troubleshooting, we use both.
```

## Step 11: Uninstall release

```bash
helm uninstall week13-app
```

Expected output:

```text
release "week13-app" uninstalled
```

Validate cleanup:

```bash
helm list
kubectl get pods
kubectl get svc
```

## Common demo failure points

| Failure | Cause | Recovery |
|---|---|---|
| `helm: command not found` | Helm not installed or PATH issue | Install Helm or fix PATH |
| `Kubernetes cluster unreachable` | kubeconfig not set | Run local cluster setup or configure kubeconfig |
| Pod stuck in ImagePullBackOff | Bad image or no registry access | Use a valid pinned tag such as `nginx:1.27` or verify image/registry access |
| YAML parse error | Bad indentation or syntax | Run `helm lint` and inspect file |
| Release already exists | Same release name used before | Run `helm uninstall <name>` or use a new release name |

## Cleanup steps

```bash
helm uninstall week13-app
cd ..
rm -rf week13-helm-demo
```

If using EKS, verify no external resources were created:

```bash
kubectl get svc
kubectl get ingress
```

---

# 13. Student Lab Manual

## Lab title

**Package a Kubernetes App into a Basic Helm Chart**

## Lab objective

Convert a simple Kubernetes application into a Helm chart, render the chart, install it into Kubernetes, validate the release, and clean it up.

## Estimated time

35 to 40 minutes

## Student prerequisites

Students should already know:

- Basic Kubernetes YAML
- Deployment and Service resources
- Basic `kubectl` commands
- How to use a terminal
- Basic YAML indentation

Required tools:

```bash
helm version
kubectl version --client
kubectl get nodes
```

## Architecture or workflow overview

```text
Student Helm Chart
      │
      │ helm template
      ▼
Rendered Kubernetes YAML
      │
      │ helm install
      ▼
Kubernetes Cluster
      │
      ├── Deployment
      ├── Pod
      └── Service
```

## Step 1: Create lab folder

```bash
mkdir -p week13-lab
cd week13-lab
```

## Step 2: Create a Helm chart

```bash
helm create student-app
cd student-app
```

Expected output:

```text
Creating student-app
```

## Step 3: Inspect chart files

```bash
ls
```

Expected output:

```text
Chart.yaml  charts  templates  values.yaml
```

Optional:

```bash
tree .
```

## Step 4: Update `values.yaml`

Open `values.yaml` and replace it with the version below. Note: resource requests/limits and probes are **not optional extras** — they are what makes a chart production-grade, so they are part of the core lab.

```yaml
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.27"          # pin a real tag; never ship "latest" to prod

service:
  type: ClusterIP
  port: 80

# Production-grade defaults: requests/limits and probes belong in the chart.
resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    cpu: 200m
    memory: 128Mi

livenessProbe:
  httpGet:
    path: /
    port: http
readinessProbe:
  httpGet:
    path: /
    port: http
```

Save the file. The default `helm create` `deployment.yaml` already wires `resources`, `livenessProbe`, and `readinessProbe` via `{{- toYaml .Values.resources | nindent 12 }}` and `{{- toYaml .Values.livenessProbe | nindent 12 }}`, so these values render straight through — open `templates/deployment.yaml` and find those lines so you can see the templating you learned in Step 5b in a real chart.

## Step 5: Render the chart

```bash
helm template student-app .
```

Expected output should include:

```yaml
kind: Service
```

and:

```yaml
kind: Deployment
```

## Step 6: Lint the chart

```bash
helm lint .
```

Expected output:

```text
1 chart(s) linted, 0 chart(s) failed
```

A warning about a missing icon is acceptable.

## Step 7: Install the chart

```bash
helm install student-app .
```

Expected output:

```text
NAME: student-app
STATUS: deployed
REVISION: 1
```

## Step 8: Validate Helm release

```bash
helm list
```

Expected output:

```text
student-app   default   1   deployed
```

## Step 9: Validate Kubernetes resources

```bash
kubectl get pods
```

Expected output:

```text
NAME                           READY   STATUS    RESTARTS   AGE
student-app-xxxxxxxxxx-xxxxx   1/1     Running   0          30s
```

```bash
kubectl get svc
```

Expected output:

```text
NAME          TYPE        CLUSTER-IP      PORT(S)
student-app   ClusterIP   10.x.x.x        80/TCP
```

## Step 10: Inspect release status

```bash
helm status student-app
```

## Step 11: Clean up

```bash
helm uninstall student-app
```

Expected output:

```text
release "student-app" uninstalled
```

Validate cleanup:

```bash
helm list
kubectl get pods
kubectl get svc
```

## Validation checklist

Students should confirm:

- [ ] Helm chart was created.
- [ ] `values.yaml` was updated.
- [ ] `helm template` rendered valid manifests.
- [ ] `helm lint` passed.
- [ ] Helm release was installed.
- [ ] Pod reached `Running` state.
- [ ] Service was created.
- [ ] Helm release was uninstalled.
- [ ] Kubernetes resources were cleaned up.

## Troubleshooting tips

| Problem | What to Check |
|---|---|
| `helm: command not found` | Helm installation and PATH |
| `cluster unreachable` | `kubectl get nodes` and kubeconfig |
| YAML parse error | Indentation, missing colon, tabs |
| Pod not running | `kubectl describe pod` and `kubectl logs` |
| Release already exists | Run `helm list` and uninstall old release |
| Template renders unexpected value | Check `values.yaml` and template references |

## Reflection questions

1. What is the difference between a Helm chart and a Helm release?
2. Why should you run `helm template` before installing?
3. What problem does `values.yaml` solve?
4. How could this chart be reused for dev and prod?
5. Why might a platform team create standard Helm charts?

## Optional challenge task: author a real template change

The point of this challenge is to *edit a template*, not just a value. The default service port already flows from `.Values.service.port`, so changing the value alone is not interesting — prove it, then add something the scaffold does not have.

1. Change the value and confirm the scaffold already wires it (no template edit needed):

   ```yaml
   service:
     type: ClusterIP
     port: 8080
   ```
   ```bash
   helm template student-app . | grep -A3 'kind: Service'
   ```
   You will see `port: 8080` render — the `helm create` `service.yaml` already references `{{ .Values.service.port }}`.

2. Now add a feature the scaffold does NOT have: a conditional ConfigMap. Create `templates/configmap.yaml`:

   ```yaml
   {{- if .Values.config.enabled }}
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: {{ include "student-app.fullname" . }}-config
     labels:
       {{- include "student-app.labels" . | nindent 4 }}
   data:
   {{- range $key, $value := .Values.config.data }}
     {{ $key }}: {{ $value | quote }}
   {{- end }}
   {{- end }}
   ```

   Add to `values.yaml`:

   ```yaml
   config:
     enabled: true
     data:
       LOG_LEVEL: info
       FEATURE_FLAG: "true"
   ```

3. Render and verify the ConfigMap appears, then flip `config.enabled: false` and confirm it disappears:

   ```bash
   helm template student-app .
   ```

This exercises `if`, `range`, `include`, and `nindent` together — the core templating skills.

---

# 14. Troubleshooting Activity

## Incident title

**Helm Release Fails Because of Invalid `values.yaml` Syntax**

## Business impact

The application team cannot deploy a new version of the service to Kubernetes. The release is blocked before reaching the cluster, delaying the planned deployment window.

## Symptoms

Student runs:

```bash
helm install student-app .
```

Error:

```text
Error: cannot load values.yaml: error converting YAML to JSON: yaml: line 5: could not find expected ':'
```

## Starting evidence

Broken `values.yaml`:

```yaml
replicaCount: 1

image:
  repository nginx
  tag: "latest"
  pullPolicy: IfNotPresent
```

The issue is here:

```yaml
repository nginx
```

It should be:

```yaml
repository: nginx
```

## Student investigation steps

1. Run Helm lint:

```bash
helm lint .
```

2. Try to render templates:

```bash
helm template student-app .
```

3. Open `values.yaml`.

4. Check:

```text
- Missing colons
- Wrong indentation
- Tabs instead of spaces
- Unclosed quotes
- Incorrect nesting
```

5. Fix the YAML.

6. Run validation again:

```bash
helm lint .
helm template student-app .
```

7. Install again:

```bash
helm install student-app .
```

## Expected root cause

The `values.yaml` file has invalid YAML syntax because `repository nginx` is missing a colon.

## Correct resolution

Fix the YAML:

```yaml
replicaCount: 1

image:
  repository: nginx
  tag: "latest"
  pullPolicy: IfNotPresent
```

Then rerun:

```bash
helm lint .
helm template student-app .
helm install student-app .
```

## Common wrong paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Checking pod logs first | The release never installed, so no pod exists |
| Deleting the cluster | The problem is local chart syntax, not the cluster |
| Changing image tag | Image tag is not the syntax problem |
| Reinstalling Helm | Helm works, the YAML file is broken |
| Running `kubectl get pods` repeatedly | Kubernetes has not received valid manifests yet |

## Instructor hints

Start with light hints:

```text
Did Helm even reach the Kubernetes cluster?
```

Then:

```text
What command lets us validate a chart before installing it?
```

Then:

```text
Look carefully at line 5 in values.yaml.
```

## Preventive action

Students should use this pre-deployment validation flow:

```bash
helm lint .
helm template student-app .
```

In enterprise CI/CD pipelines, add:

```text
helm lint
helm template
YAML validation
Kubernetes schema validation
manual approval for production
```

---

# 15. Scenario-Based Discussion Questions

## Question 1

**Why should an enterprise platform team standardize Helm charts instead of letting every team create completely different Kubernetes manifests?**

Expected themes:

- Standardization
- Security
- Faster onboarding
- Fewer mistakes
- Easier support
- Reusable deployment patterns

Follow-up:

```text
What parts should be standardized, and what parts should application teams still control?
```

## Question 2

**Should application teams own their Helm charts, or should the platform team own them?**

Expected themes:

- Shared ownership
- Platform owns base standards
- App teams own app-specific values
- Reviews through Git

Follow-up:

```text
What happens if the platform team owns too much?
```

## Question 3

**What risks exist when using Helm in production?**

Expected themes:

- Bad values can break deployments
- Poor templates can hide complexity
- Rollbacks may not fix databases
- Secrets must be handled carefully
- Lack of review can cause outages

Follow-up:

```text
What checks would you add before production deployment?
```

## Question 4

**How does Helm help with cost or operational efficiency?**

Expected themes:

- Faster deployments
- Less manual work
- Fewer mistakes
- Standard resource requests
- Easier cleanup

Follow-up:

```text
Can Helm also create cost problems?
```

Expected answer:

```text
Yes. If charts create LoadBalancers, large replicas, or persistent volumes without review, cost can increase.
```

## Question 5

**Why is `helm template` useful before deploying to EKS?**

Expected themes:

- Shows final Kubernetes YAML
- Catches incorrect values
- Helps code review
- Prevents surprises
- Useful in CI/CD

Follow-up:

```text
Would you allow production deployment without rendering or validation?
```

## Question 6

**How can Helm support dev, test, and prod environments?**

Expected themes:

- Same chart
- Different values files
- Different image tags
- Different replica counts
- Different resource limits

Follow-up:

```text
What values should be different between dev and prod?
```

## Question 7

**What security concerns should teams consider when creating Helm charts?**

Expected themes:

- Avoid hardcoded secrets
- Use Kubernetes Secrets carefully
- Use cloud secrets managers where possible
- Set security contexts
- Avoid privileged containers
- Use least privilege ServiceAccounts

Follow-up:

```text
Where should secrets come from in an enterprise deployment?
```

---

# 16. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple choice

What is Helm primarily used for?

A. Running containers directly  
B. Packaging and managing Kubernetes applications  
C. Replacing Kubernetes clusters  
D. Creating AWS accounts  

**Answer:** B  
**Explanation:** Helm packages Kubernetes manifests into reusable charts and manages releases.

## Question 2: Multiple choice

Which file contains default configurable values in a Helm chart?

A. `Chart.yaml`  
B. `values.yaml`  
C. `deployment.yaml`  
D. `release.yaml`  

**Answer:** B  
**Explanation:** `values.yaml` stores default configuration values used by templates.

## Question 3: True or false

Helm replaces Kubernetes and runs containers itself.

**Answer:** False  
**Explanation:** Kubernetes runs containers. Helm helps package, render, install, and manage Kubernetes resources.

## Question 4: Short answer

What is the difference between a Helm chart and a Helm release?

**Answer:**  
A chart is the reusable package. A release is an installed instance of that chart in a Kubernetes cluster.

## Question 5: Multiple choice

Which command previews the Kubernetes YAML generated by a Helm chart?

A. `helm show yaml`  
B. `helm template`  
C. `helm preview`  
D. `kubectl render`  

**Answer:** B  
**Explanation:** `helm template` renders chart templates locally without installing them.

## Question 6: Multiple choice

Which command checks a Helm chart for common issues?

A. `helm lint`  
B. `helm debug`  
C. `helm scan`  
D. `helm verify-yaml`  

**Answer:** A  
**Explanation:** `helm lint` validates chart structure and common problems.

## Question 7: Troubleshooting

A student sees this error:

```text
error converting YAML to JSON: yaml: line 5: could not find expected ':'
```

What is the most likely issue?

**Answer:**  
Invalid YAML syntax, likely a missing colon or indentation issue.

**Explanation:**  
Helm cannot parse the values or template file before rendering the chart.

## Question 8: AWS-related

In AWS, which managed Kubernetes service commonly runs applications deployed by Helm?

A. Amazon EC2  
B. Amazon EKS  
C. Amazon S3  
D. AWS Lambda  

**Answer:** B  
**Explanation:** Amazon EKS is AWS managed Kubernetes. Helm is commonly used to deploy workloads to EKS.

## Question 9: AWS-related

Where would a container image commonly be stored before Helm deploys it to EKS?

A. Amazon ECR  
B. Amazon RDS  
C. AWS CloudTrail  
D. Amazon Route 53  

**Answer:** A  
**Explanation:** Amazon ECR is AWS container registry service.

## Question 10: Troubleshooting

A Helm release installs successfully, but the pod is stuck in `ImagePullBackOff`. Is this primarily a Helm rendering problem or a Kubernetes runtime problem?

**Answer:**  
Kubernetes runtime problem.

**Explanation:**  
Helm successfully installed the resources. The pod fails later because Kubernetes cannot pull the container image.

## Question 11: True or false

The same Helm chart can be used to deploy different environments if different values are supplied.

**Answer:** True  
**Explanation:** This is one of Helm’s biggest benefits. One chart can support dev, test, and prod through different values.

## Question 12: Short answer

Why is Helm useful for platform engineering?

**Answer:**  
It allows platform teams to create standardized, reusable deployment patterns that application teams can use safely and consistently.

---

# 17. Homework Assignment

## Assignment title

**Explain Why Helm Is Useful in Enterprise Kubernetes Deployments**

## Scenario

Your company has 12 application teams deploying to Kubernetes. Each team currently maintains its own raw Kubernetes YAML files. Deployments are inconsistent, rollback steps are unclear, and production issues are difficult to troubleshoot because every application is packaged differently.

The platform team is considering Helm as a standard packaging approach.

## Student tasks

Write a 1 to 2 page response that explains:

1. What problem Helm solves
2. Difference between a chart and a release
3. Purpose of `Chart.yaml`
4. Purpose of `values.yaml`
5. Purpose of the `templates/` directory
6. How Helm helps dev, test, and prod deployments
7. How Helm supports enterprise standardization
8. One security concern when using Helm
9. One operational concern when using Helm
10. How Helm works across EKS, AKS, and GKE

## Expected deliverables

Students submit:

- Written document in Markdown or PDF
- Optional diagram showing chart to release flow
- Optional command list showing basic Helm workflow

## Submission format

```text
week13-class1-homework/
├── helm-enterprise-explanation.md
└── optional-diagram.png or diagram.md
```

## Estimated completion time

60 to 90 minutes

## Grading criteria

| Criteria | Points |
|---|---:|
| Explains Helm clearly | 20 |
| Correctly explains chart vs release | 15 |
| Explains chart file structure | 15 |
| Includes enterprise use case | 20 |
| Includes security or operational risk | 15 |
| Clear writing and formatting | 15 |

## Optional advanced challenge

Create a simple Mermaid or text diagram showing:

```text
Git → CI/CD → Image Registry → Helm Chart → EKS → Monitoring
```

---

# 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Thinking Helm replaces Kubernetes | Helm feels like a deployment tool, so students think it runs workloads | Reinforce that Helm sends manifests to Kubernetes |
| Confusing chart and release | Both terms are new | Use package vs installed copy analogy |
| Editing too many generated files | `helm create` produces many files | Start with only `Chart.yaml`, `values.yaml`, deployment, and service |
| Forgetting to run `helm template` | Students want to install immediately | Make rendering part of every workflow |
| Bad YAML indentation | YAML is whitespace-sensitive | Use VS Code YAML extension and `helm lint` |
| Missing colons in YAML | Beginner syntax issue | Validate with `helm lint` |
| Using same release name twice | Helm release already exists | Run `helm list`, then uninstall or choose a new name |
| Troubleshooting with `kubectl` too early | Chart failed before reaching cluster | Check if Helm rendered or installed first |
| Forgetting cleanup | Students leave releases running | Always end labs with `helm uninstall` |
| Ignoring cost in cloud clusters | Students may create cloud load balancers later | Warn about EKS, LoadBalancer services, NAT Gateway, and persistent storage costs |

---

# 19. Real-World Enterprise Scenario

## Scenario

A company is standardizing Kubernetes deployments across multiple application teams. Each team currently copies YAML from old projects and modifies it manually. This has caused:

- inconsistent labels
- missing readiness probes
- different resource request patterns
- unclear rollback process
- hardcoded environment variables
- production incidents after manual YAML edits

The platform team decides to create a reusable Helm chart standard.

## Constraints

| Constraint | Example |
|---|---|
| Access control | Developers can deploy to dev, but production requires approval |
| Security | No hardcoded secrets allowed |
| Reliability | All apps need readiness and liveness probes |
| Cost | Replica counts and resource requests must be reviewed |
| Operations | Releases must be traceable through Git and CI/CD |
| Production impact | Failed deployments must be easy to roll back |

## What each role would do

| Role | Responsibility |
|---|---|
| DevOps Engineer | Build CI/CD pipeline that deploys Helm charts |
| Cloud Engineer | Ensure EKS cluster, IAM, networking, and registry access are ready |
| SRE | Define health checks, alerts, rollback expectations, and production readiness checks |
| Platform Engineer | Create reusable chart standards and documentation |
| Application Team | Provide app-specific values and test the deployment |

## Enterprise lesson

Helm is not just a Kubernetes tool. In companies, it becomes part of the software delivery standard.

---

# 20. Instructor Tips

## Teaching tips

- Start with raw Kubernetes YAML pain before introducing Helm.
- Use the package manager analogy carefully: Helm is like a package manager, but the package contains Kubernetes resources.
- Repeat the chart vs release distinction several times.
- Do not go too deep into advanced templating in Class 1.
- Keep focus on structure, rendering, installing, validating, and troubleshooting.

## Pacing tips

- Keep Kubernetes review under 15 minutes.
- Do not spend too much time explaining every generated template from `helm create`.
- Use one simple app.
- Save dev/prod values, upgrades, and rollbacks for Class 2.

## Lab support tips

When students struggle, ask:

```text
Did helm lint pass?
Did helm template render?
Did helm install succeed?
Did Kubernetes create the pod?
Is the pod running?
```

This teaches layered troubleshooting.

## Helping struggling students

For beginners:

- Give them a working chart first.
- Ask them to change only `replicaCount` and image tag.
- Avoid complex template editing early.
- Pair them with students who completed the lab.

## Challenging advanced students

Ask advanced students to add:

- ConfigMap template
- custom labels
- resource requests and limits
- liveness and readiness probes
- namespace support
- ServiceAccount template

---

# 21. Student Outcome Checklist

## Students should be able to explain

- [ ] What Helm is
- [ ] Why Helm is useful
- [ ] Difference between raw Kubernetes YAML and Helm charts
- [ ] Difference between chart and release
- [ ] Purpose of `Chart.yaml`
- [ ] Purpose of `values.yaml`
- [ ] Purpose of `templates/`
- [ ] Why `helm template` is useful
- [ ] How Helm supports enterprise standardization

## Students should be able to build or configure

- [ ] Create a Helm chart
- [ ] Modify `values.yaml`
- [ ] Render a chart locally
- [ ] Lint a Helm chart
- [ ] Install a Helm release
- [ ] Validate pods and services created by Helm
- [ ] Uninstall a Helm release

## Students should be able to troubleshoot

- [ ] Invalid YAML syntax
- [ ] Failed chart rendering
- [ ] Release already exists
- [ ] Kubernetes cluster unreachable
- [ ] Pod not running after install
- [ ] Difference between Helm-level failure and Kubernetes-level failure

---

# 22. Class Completion Checklist

## Instructor checklist before ending class

- [ ] Students understand why Helm exists.
- [ ] Students can explain chart vs release.
- [ ] Students saw `helm create`.
- [ ] Students saw `helm template`.
- [ ] Students saw `helm lint`.
- [ ] Students saw `helm install`.
- [ ] Students saw `helm status`.
- [ ] Students saw `helm uninstall`.
- [ ] Troubleshooting activity was completed.
- [ ] Homework assignment was explained.
- [ ] Class 2 preview was given.

## Student checklist before leaving class

- [ ] Helm is installed and working.
- [ ] Kubernetes cluster is accessible.
- [ ] Student created a Helm chart.
- [ ] Student rendered the chart.
- [ ] Student installed a release.
- [ ] Student validated pod and service.
- [ ] Student uninstalled the release.
- [ ] Student understands homework expectations.

## Items to verify before moving to Class 2

Students should be ready to work with:

- `values.yaml`
- custom values files
- Helm release names
- `helm upgrade`
- `helm history`
- `helm rollback`

Class 2 should begin by connecting today’s chart foundation to environment-specific deployments, upgrades, and rollbacks.

## Class Artifacts & Validation

All artifacts are real on-disk files in the [`labs/helm-charts/`](../../labs/helm-charts/) module. This class uses the chart *anatomy* — `Chart.yaml`, `values.yaml`, `_helpers.tpl`, and the core (non-conditional) templates — plus the starter and broken fixtures students edit. The runner [`labs/helm-charts/validate.sh`](../../labs/helm-charts/validate.sh) executes all 17 gates and exits `0` (`17 passed, 0 failed, 0 deferred`) in this environment with `helm v3.16.3`, `kubeconform v0.6.7`, and `kubectl v1.34.2` against the live `kind-course` cluster.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/helm-charts/solution/chart/webapp/Chart.yaml | helm | Chart metadata (`apiVersion v2`, name/version/appVersion, kubeVersion) | `helm lint solution/chart/webapp` | PASS — `1 chart(s) linted, 0 failed` |
| 2 | labs/helm-charts/solution/chart/webapp/values.yaml | helm | Default (dev) values: image, replicas, resources, probes, config | `helm template webapp solution/chart/webapp \| kubeconform -strict -summary` | PASS — `5 resources, Valid: 5` |
| 3 | labs/helm-charts/solution/chart/webapp/templates/_helpers.tpl | helm | Named templates: name / fullname / labels / selectorLabels / image | `./validate.sh` (helpers gate) | PASS |
| 4 | labs/helm-charts/solution/chart/webapp/templates/deployment.yaml | helm | Deployment: probes, resources, non-root securityContext, config checksum | `helm template webapp solution/chart/webapp \| kubeconform -strict` | PASS |
| 5 | labs/helm-charts/solution/chart/webapp/templates/service.yaml | helm | ClusterIP Service `:80 -> :8080`, selects pods by shared labels | `helm template webapp solution/chart/webapp \| kubeconform -strict` | PASS |
| 6 | labs/helm-charts/solution/chart/webapp/templates/configmap.yaml | helm | ConfigMap rendered by `range` over `.Values.config`, consumed via `envFrom` | `helm template webapp solution/chart/webapp \| kubeconform -strict` | PASS |
| 7 | labs/helm-charts/solution/chart/webapp/templates/serviceaccount.yaml | helm | ServiceAccount, gated on `.Values.serviceAccount.create` | `helm template webapp solution/chart/webapp \| kubeconform -strict` | PASS |
| 8 | labs/helm-charts/starter/chart/webapp/templates/deployment.yaml | helm | Starter Deployment with 4 `TODO(student)` gaps (image, port, probes, resources) | `python3 tests/prerender.py starter/chart/webapp/templates/*.yaml` | PASS (structural pre-render) |
| 9 | labs/helm-charts/broken/deployment.yaml | helm | Troubleshooting fixture: missing `nindent` + under-indented `ports` (real injected fault) | `python3 tests/prerender.py broken/deployment.yaml` | PASS — correctly **rejected** (exit 1, as intended) |
| 10 | labs/helm-charts/tests/prerender.py | python | Offline `{{...}}`-stripping YAML structural checker (linter aid) | `python3 -m unittest discover -s tests` | PASS |
| 11 | labs/helm-charts/validate.sh | shell | Gate runner (17 gates incl. lint, template, kubeconform, server-side dry-run) | `bash -n validate.sh` then `./validate.sh` | PASS — `17 passed, 0 failed, 0 deferred` |

> The server-side `kubectl --context kind-course apply --dry-run=server` gate runs the rendered manifests through the **real apiserver** admission/validation and persists nothing. It validates the chart against a live cluster but is **not** a live operation (no release is installed, upgraded, rolled back, or autoscaled in this class); those operations are taught in Class 2.

## Definition of Done

- [x] Every technology taught (Helm chart anatomy + templating) ships a **runnable file on disk** — the chart under `solution/chart/webapp/`, not just fences.
- [x] Each artifact passes its **validation gate** (`helm lint`, `helm template | kubeconform -strict`, server-side dry-run); output captured in the lab README's Validation section.
- [x] Lab has **starter** (`starter/chart/webapp/templates/deployment.yaml` with 4 TODO gaps) and **solution** (`solution/chart/webapp/`) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, and cost notes.
- [x] **Cleanup/teardown** is provided and idempotent (`helm uninstall`; `helm template` itself persists nothing — $0, no cluster resources).
- [x] **Instructor answer key** exists for the lab (`README` → Instructor answer key, with grading points per TODO).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `broken/deployment.yaml` (injected `nindent`/indentation faults), not a hypothetical.
- [x] **Expected outputs** are shown (render counts 5 default; `image: "nginxinc/nginx-unprivileged:1.27.0"`; both probes on `http`).
- [x] **Cost & security warnings** present (non-root least-privilege defaults; no secrets in `values.yaml`/ConfigMap; pin image tags; $0).
- [x] **Cross-references** to the module repo and Weeks 11/12 (manifests) and Class 2 are correct.
- [x] The **artifact manifest** (§4.2) above is present and every path resolves.
- [ ] **Mastered** (operated/reused live, capstone-linked): the chart is consumed by the capstone (W23/W24), but in *this* class it is rendered and statically/server-side validated, not operated live (no install/upgrade/rollback/autoscale). Honest cap for Class 1 in isolation.
