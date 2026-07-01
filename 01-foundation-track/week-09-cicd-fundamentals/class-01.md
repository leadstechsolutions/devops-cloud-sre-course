# Week 9: CI/CD Fundamentals
# Class 1 Package: Understanding CI/CD and Building Your First Pipeline

**Week:** 9
**Class:** 1
**Track:** Unified DevOps · Cloud · SRE Track

> **▶ Runnable lab for this class:** [`labs/cicd-pipelines/`](../../labs/cicd-pipelines/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## 1. Class Overview

### Class Title

**Class 1: Understanding CI/CD and Building Your First Pipeline**

### Class Purpose

This class introduces students to the purpose, structure, and workflow of CI/CD pipelines. Students will learn how modern engineering teams automatically validate code changes before merging or deploying them.

The goal is not to make students pipeline experts in one class. The goal is to help them understand the core moving parts of a pipeline and build a simple working CI pipeline.

### How This Class Connects to the Overall Course

This class connects several earlier topics:

- **Git workflows from Week 3:** pipelines are triggered by commits, pushes, branches, and merge requests.
- **Linux from Week 2:** pipeline jobs run shell commands on runners.
- **Bash and Python scripting from Week 8:** pipeline jobs often use shell scripting, and Python is used for automation and tests.
- **Docker from Week 10:** the very next week, pipelines will build container images. The small Flask app we test here is the same one you will containerize in Week 10, so this week and next share one example application.
- **Kubernetes (Weeks 11-12), Helm (Week 13), and Terraform (Weeks 14-15) later in the course:** pipelines will later validate, plan, deploy, and release infrastructure and applications. The DevSecOps gates introduced here are deepened in Week 19.

### What Students Will Build, Analyze, or Practice

Students will:

- Analyze how a code change moves through a CI pipeline.
- Read a basic YAML pipeline file.
- Build a simple pipeline with validation, test, and package stages.
- Produce a basic artifact.
- Troubleshoot common YAML and pipeline structure issues.

---

## 2. Class Learning Objectives

By the end of this class, students will be able to:

1. **Explain** the difference between Continuous Integration, Continuous Delivery, and Continuous Deployment.
2. **Identify** common CI/CD pipeline stages such as lint, test, build/package, scan, and deploy.
3. **Describe** how commits, branches, and pull requests trigger pipelines, and how branch protection / required status checks *enforce* the gate.
4. **Explain** the role of runners (GitHub-hosted vs self-hosted) in executing pipeline jobs.
5. **Build** a real GitHub Actions CI pipeline that installs dependencies, runs a linter, runs `pytest` unit tests (exit-code-driven), and produces a real build artifact.
6. **Add** a working security gate (secret scanning with gitleaks + dependency/SCA scan with `pip-audit`) that *fails the build* on findings.
7. **Read and translate** the same pipeline into GitLab CI syntax (comparison appendix) and recognize where the concepts map.
8. **Troubleshoot** pipeline failures using the evidence-first method (symptom → evidence → root cause → fix → validate), starting from the first failed log line.

---

## 3. Prerequisites Students Should Already Know

### Required Prior Concepts

Students should already understand:

- Basic Git commands: `clone`, `add`, `commit`, `push`, `switch`/`branch` (from Week 3)
- Branches and pull requests (or merge requests)
- Basic terminal commands such as `ls`, `cd`, `cat`, `mkdir`, `echo` (from Week 2)
- Basic Python and Bash from Week 8 (running `python`, `pip`, and shell commands)
- Basic YAML indentation concepts
- Basic idea of code repositories

### Required Tools Already Installed

Students should have:

- Git
- Python 3.11+ and `pip`
- VS Code
- Terminal or command prompt
- Browser
- GitHub account (primary). GitLab account optional, only for the comparison appendix.
- Optional: Docker Desktop, not required for Class 1
- Optional: AWS CLI v2, not required for Class 1 demo

### Required Accounts or Access

Students need:

- A GitHub account and access to create a repository (primary tool for this week)
- Optional: a GitLab account, only if they want to try the comparison appendix

### Files, Repos, or Sample Code Needed

Students need a small repository containing a real (tiny) Python web app so the pipeline can lint, test, and build something meaningful — not just check that a file exists.

Recommended starter structure (this is the same Flask app you will containerize in Week 10):

```text
week-09-ci-cd/
├── README.md
├── requirements.txt
├── requirements-dev.txt
├── app/
│   ├── __init__.py
│   └── main.py
└── tests/
    └── test_main.py
```

Example `README.md`:

```markdown
# Week 9 CI/CD Demo

This repository is used to practice CI/CD pipeline concepts with a small,
real Python (Flask) application that is linted, tested, and packaged.
```

The application files are provided in the Instructor Demo Script and Student Lab Manual below.

---

## 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| CI | Continuous Integration. Automatically checking code changes when developers push code. | Teams use CI to catch problems before code is merged. |
| CD | Continuous Delivery or Continuous Deployment. Automating the release path after code is validated. | Teams use CD to move code safely through dev, staging, and production. |
| Pipeline | An automated workflow made of jobs and stages. | A pipeline acts like a quality gate for code changes. |
| Job | One task inside a pipeline. | Example: run tests, check formatting, create artifact. |
| Stage | A group or phase of jobs. | Example: validate, test, package, deploy. |
| Runner or Agent | The worker machine that executes pipeline jobs. | In GitLab, runners execute `.gitlab-ci.yml`. In GitHub, hosted runners execute workflow jobs. |
| Artifact | A file created by a pipeline and saved after a job finishes. | Build files, reports, packages, or compiled output. |
| YAML | A configuration format commonly used for pipelines. | CI/CD pipelines are often defined using YAML files. |
| Merge Request or Pull Request | A request to merge code changes into another branch. | Teams review code and pipeline results before merging. |
| Quality Gate | A required check before code can continue to the next step. | A failed test can block merging into main. |
| Branch-Based Workflow | Pipeline behavior changes based on branch name. | Feature branches may run tests, while main may deploy. |
| Linter | A tool that checks code style and likely bugs without running it. | `ruff`/`flake8` for Python; failing lint can block a merge. |
| Unit Test | An automated test that checks one small piece of behavior and exits non-zero on failure. | `pytest` runs unit tests; a non-zero exit code fails the CI job. |
| SAST | Static Application Security Testing — scans source code for security flaws. | `bandit` for Python; surfaces issues before code ships. |
| SCA | Software Composition Analysis — scans your *dependencies* for known vulnerabilities (CVEs). | `pip-audit` checks installed packages against vulnerability databases. |
| Secret Scanning | Detecting committed credentials (keys, tokens) in code or history. | `gitleaks` blocks a PR that leaks an AWS key. |
| SBOM | Software Bill of Materials — a machine-readable inventory of everything in a build. | `syft` generates an SBOM; required by many enterprises and SLSA. |
| Required Status Check | A CI check that *must pass* before GitHub/GitLab will allow a merge. | This is the setting that actually *enforces* the quality gate. |
| OIDC Federation | Keyless cloud auth where CI exchanges a short-lived token for a cloud role. | GitHub Actions assumes an AWS IAM role with no stored access keys. |

---

## 5. Tools Used

**Primary CI tool for this week: GitHub Actions.** GitHub Actions is the dominant CI surface in the 2026 job market, so we teach it to depth. GitLab CI is shown in a short comparison appendix (Section 12, Option B) so you can recognize the mapping; Jenkins is the common *legacy* enterprise surface you may be screened on, summarized in the comparison table. Master one tool well rather than two tools shallowly.

| Tool | Why It Is Used |
|---|---|
| Git | Tracks code changes and triggers pipeline workflows through commits and branches. |
| GitHub Actions (primary) | Runs the CI/CD workflow defined in `.github/workflows/*.yml`. |
| GitLab CI (comparison only) | Same concepts, different YAML (`.gitlab-ci.yml`); shown so the skills are portable. |
| Python + pip | The demo app is a tiny Flask app; `pip` installs its dependencies in CI. |
| ruff | Fast Python linter — the "lint" gate. |
| pytest | Runs unit tests; a non-zero exit code fails the job. |
| pip-audit | Dependency/SCA vulnerability scan against known CVEs. |
| bandit | Python SAST (static security scan of source). |
| gitleaks | Secret scanner — fails the build if a credential is committed. |
| YAML | Defines pipeline jobs, stages, and workflow behavior. |
| VS Code | Used to edit repository files and pipeline YAML. |
| Terminal | Used to run Git commands and inspect local files. |
| Browser | Used to view repository, pipeline status, job logs, and artifacts. |

---

## 6. AWS Services Used

Class 1 does not require students to create AWS resources. AWS is introduced conceptually so students understand where CI/CD will connect later.

| AWS Service | How It Connects to CI/CD |
|---|---|
| Amazon ECR | Later pipelines can build Docker images and push them to ECR. |
| Amazon S3 | Pipelines can store build artifacts, reports, or Terraform plan files in S3. |
| IAM | Pipelines need controlled permissions to access AWS securely. |
| STS | Future pipelines can use temporary credentials through role assumption instead of long-lived keys. |

### AWS Security Note

Students should never hardcode AWS access keys in pipeline YAML files. The modern, recommended pattern is **keyless OIDC federation**: GitHub Actions presents a short-lived OIDC token and `aws-actions/configure-aws-credentials` exchanges it for a temporary IAM role session — no stored secrets at all. Class 2 demonstrates this end to end, and Week 17 (multi-account) and Week 19 (DevSecOps) build on it.

---

## 7. Azure and GCP Comparison Notes

| CI/CD Area | AWS-Oriented Example | Azure Equivalent | GCP Equivalent |
|---|---|---|---|
| Pipeline platform | GitLab CI or GitHub Actions deploying to AWS | Azure DevOps Pipelines | Google Cloud Build |
| Container registry | Amazon ECR | Azure Container Registry | Artifact Registry |
| Artifact storage | Amazon S3 | Azure Blob Storage | Cloud Storage |
| Pipeline identity | IAM role or temporary credentials | Managed identity or service connection | Service account or workload identity |

Keep the teaching focus on GitHub Actions (primary). GitLab/Azure/GCP are mentioned only to show that the pipeline concepts are portable.

---

## 8. Time-Boxed Instructor Agenda

| Time | Section | Activity |
|---:|---|---|
| 0:00 to 0:10 | Opening | Explain why CI/CD matters in real teams |
| 0:10 to 0:20 | Review | Connect Git branches and pull requests to pipelines |
| 0:20 to 0:35 | Concept teaching | CI vs Continuous Delivery vs Continuous Deployment (tight, ~15 min) |
| 0:35 to 0:55 | Pipeline anatomy | Jobs, runners, artifacts, `needs`, matrix; what a *real* gate contains |
| 0:55 to 1:05 | YAML basics | Indentation, key-value pairs, lists (quick) |
| 1:05 to 1:15 | Break | Short break |
| 1:15 to 2:00 | Instructor demo | Build a REAL GitHub Actions pipeline: install → lint → pytest → build artifact → security gate (gitleaks + pip-audit) |
| 2:00 to 2:45 | Student lab | Students build the same real pipeline on the Flask app and turn on branch protection |
| 2:45 to 2:55 | Troubleshooting activity | Fix a failing lint/test/security gate using evidence-first method |
| 2:55 to 3:00 | Recap | Review outcomes and assign homework |

---

## 9. Instructor Lesson Plan

### Step 1: Open With a Real-World Problem

Explain:

> Imagine five developers are pushing changes to the same application. Without automation, someone has to manually check whether each change breaks the app. CI/CD gives the team a repeatable way to validate every change.

Ask students:

- What could go wrong if code is merged without testing?
- What checks should happen before code reaches production?

### Step 2: Connect CI/CD to Git

Show a simple flow:

```text
Developer changes code
    ↓
Commit
    ↓
Push branch
    ↓
Pipeline runs
    ↓
Merge request reviewed
    ↓
Merge to main
```

Teaching tip: remind students that CI/CD is built on top of Git behavior.

### Step 3: Explain CI vs CD

Use this simple distinction:

- CI checks if the change is safe to merge.
- CD prepares or performs deployment after validation.

Avoid overloading students with advanced release strategies in Class 1. Those come later.

### Step 4: Explain Pipeline Anatomy

Cover:

- Workflow / pipeline
- Job (and `needs` for ordering between jobs)
- Step
- Runner (GitHub-hosted `ubuntu-latest` vs self-hosted)
- Matrix build (run the same job across multiple versions in parallel)
- Artifact
- Job log

Pause and ask:

> Which part actually runs the commands?

Expected answer: the runner.

Teaching point: a *real* CI gate is not "did a file exist." It is: install dependencies → lint → run unit tests (exit code drives pass/fail) → build a real artifact → run security scans (secrets, dependencies). We will build exactly that today.

### Step 4b: Real Gates and Security From Day One

Explain that for 2026 senior readiness, a CI pipeline that does not scan for secrets and vulnerable dependencies is incomplete. Today's pipeline includes:

- **gitleaks** — fails the build if a credential is committed.
- **pip-audit** — fails (or warns) if a dependency has a known CVE.

These are the first taste of DevSecOps, which Week 19 covers in depth.

### Step 4c: Enforcement Is a Setting, Not a Hope

Explain the most commonly missed point: a pipeline does not block a merge by itself. You must turn on **branch protection** with **required status checks**. We will turn that on in the lab so students *see* the gate actually stop a bad merge.

### Step 5: Introduce YAML Carefully

Show that indentation matters.

Bad:

```yaml
validate:
stage: validate
script:
- echo "hello"
```

Good:

```yaml
validate:
  stage: validate
  script:
    - echo "hello"
```

Teaching tip: beginners often struggle more with YAML than CI/CD concepts. Slow down here.

### Step 6: Run Instructor Demo

Build the pipeline live. Explain each section before committing.

### Step 7: Student Lab

Students repeat the process in their own repo.

Instructor should circulate and check:

- File name
- File location
- YAML indentation
- Repository contains `README.md`
- Pipeline actually triggered

### Step 8: Troubleshooting Activity

Give students a broken pipeline. Ask them to diagnose before showing the fix.

### Step 9: Recap

Close with:

> Today you built a real quality gate: lint, tests, a real artifact, and security scans, enforced by branch protection. Next class, we make the CD half real — variables and secrets, OIDC keyless auth to AWS, a real artifact publish with environment promotion and approval, and deployment strategies (rolling, blue/green, canary).

---

## 10. Instructor Lecture Notes

### Opening Talking Points

> CI/CD is one of the most important daily skills for DevOps engineers. It is how teams move from manual, risky delivery to repeatable, automated delivery.

> Every time someone pushes code, the pipeline can check whether the code is safe, whether tests pass, whether files are present, and whether the output can be packaged.

### CI Explanation

Continuous Integration means developers integrate code frequently and automatically validate those changes.

Common CI checks:

- Does the code compile?
- Do tests pass?
- Does formatting meet standards?
- Are required files present?
- Does the application package successfully?

### CD Explanation

Continuous Delivery means code is always in a deployable state after passing checks. A human may still approve production deployment.

Continuous Deployment means the system automatically deploys changes after passing checks.

For beginners, emphasize this:

```text
CI = validate the change
CD = deliver or deploy the change
```

### Pipeline Stages

A realistic CI pipeline looks like this:

```text
lint -> test -> build/package -> security scan
```

In Class 1, students build all of these in GitHub Actions against a real (tiny) Flask app:

```text
lint (ruff) -> test (pytest) -> build artifact -> security gate (gitleaks + pip-audit)
```

Deployment (the CD half) is introduced and made real in Class 2. Class 1's job is to make the *integration* gate genuine — real install, real lint, real tests, real scans — not a YAML-shaped echo.

### Runners

A runner is where the job runs. It can be:

- GitLab shared runner
- GitLab self-hosted runner
- GitHub-hosted runner
- Self-hosted GitHub runner

Explain:

> The pipeline file defines what should happen. The runner is the machine that actually does it.

### Artifacts

Artifacts are files saved after a job.

Examples:

- `.zip` package
- test report
- application binary
- build output
- Terraform plan file
- generated documentation

In this class, the artifact is a real, SHA-tagged tarball of the application (`dist/app-${GITHUB_SHA::7}.tar.gz`) built by the pipeline and uploaded as a build artifact, so each build is traceable to the exact commit it came from.

### Enterprise Context

In a real company:

- Developers submit merge requests.
- Pipelines validate changes.
- Code owners review changes.
- Security checks may run.
- Artifacts are stored.
- Deployments may require approval.
- Production changes are audited.

CI/CD is not just automation. It is a control point for quality, security, and reliability.

### Common Misconceptions

| Misconception | Correction |
|---|---|
| CI/CD is only for developers | DevOps, cloud, platform, and SRE teams all use pipelines. |
| A successful pipeline means the app is perfect | It only means the configured checks passed. |
| YAML errors are rare | YAML indentation mistakes are very common. |
| Secrets can be written in pipeline files | Secrets must be stored securely in CI/CD settings or secret managers. |
| CI/CD always means automatic production deployment | Many companies use manual approvals for production. |

---

## 11. Whiteboard Explanation

### Simple Diagram: Basic CI Pipeline

```text
Developer Laptop
    |
    | git push
    v
Git Repository
    |
    | pipeline trigger
    v
CI Pipeline
    |
    | Stage 1
    v
Validate Job
    |
    | Stage 2
    v
Test Job
    |
    | Stage 3
    v
Package Job
    |
    v
Artifact Created
```

### Step-by-Step Explanation

1. Developer makes a code change.
2. Developer pushes the branch.
3. GitLab or GitHub detects the change.
4. The pipeline starts automatically.
5. A runner executes each job.
6. Jobs run shell commands.
7. If all jobs pass, the pipeline succeeds.
8. If one job fails, the pipeline fails.
9. The team reviews logs and fixes the issue.
10. If successful, the merge request can move forward.

### Enterprise Version

```text
Developer
   |
   v
Feature Branch
   |
   v
Merge Request
   |
   v
CI Pipeline
   |
   |-- Validate
   |-- Unit Tests
   |-- Security Scan
   |-- Build Artifact
   v
Code Review
   |
   v
Approved Merge
   |
   v
Main Branch
```

### What Each Component Means

| Component | Meaning |
|---|---|
| Developer | Person making a code or infrastructure change |
| Feature branch | Isolated branch for work |
| Merge request | Review request before merging |
| CI pipeline | Automated checks |
| Runner | Machine that executes jobs |
| Artifact | Output saved by pipeline |
| Code review | Human review process |
| Main branch | Stable branch protected by checks |

---

## 12. Instructor Demo Script

### Demo Title

**Build a REAL CI Pipeline in GitHub Actions: Lint, Test, Build Artifact, and Security Gate on a Small Flask App**

### Demo Objective

Show students a CI pipeline that actually does CI: install dependencies, lint, run unit tests (exit-code-driven), build a real artifact, and run security scans that *fail the build*. This is the same app students will containerize in Week 10.

```text
lint (ruff) -> test (pytest) -> build artifact -> security gate (gitleaks + pip-audit)
```

### Required Setup

Instructor needs:

- GitHub account and a new repository named `week-09-ci-demo`
- Local Git and Python 3.11+
- VS Code or text editor

### Step 1: Create the App and Tests Locally

```bash
mkdir week-09-ci-demo
cd week-09-ci-demo
git init -b main
mkdir -p app tests .github/workflows
```

Create `app/__init__.py` (empty file):

```bash
touch app/__init__.py
```

Create `app/main.py`:

```python
from flask import Flask

app = Flask(__name__)


def add(a: int, b: int) -> int:
    """Tiny pure function so we have something real to unit test."""
    return a + b


@app.get("/health")
def health():
    return {"status": "ok"}, 200


if __name__ == "__main__":
    # Bind to localhost for local runs only.
    app.run(host="127.0.0.1", port=8000)
```

Create `tests/test_main.py`:

```python
from app.main import add, app


def test_add():
    assert add(2, 3) == 5


def test_health_endpoint():
    client = app.test_client()
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.get_json() == {"status": "ok"}
```

Create `requirements.txt`:

```text
flask==3.1.0
```

Create `requirements-dev.txt`:

```text
-r requirements.txt
pytest==8.3.4
ruff==0.8.4
pip-audit==2.7.3
```

Create `README.md`:

```bash
echo "# Week 9 CI Demo" > README.md
```

Explain:

> We now have a real (tiny) app with a pure function and an endpoint, plus real tests. The pipeline will lint it, test it, and package it — not just check that a file exists.

### Step 2: Verify Locally First (render/run before you push)

Reinforce the "run it locally before you trust the pipeline" discipline:

```bash
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements-dev.txt
ruff check .
pytest -q
```

Expected output (abbreviated):

```text
All checks passed!
2 passed in 0.20s
```

### Step 3: Create the GitHub Actions Workflow

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

jobs:
  lint-test-build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.11", "3.12"]
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: pip

      - name: Install dependencies
        run: pip install -r requirements-dev.txt

      - name: Lint (ruff)
        run: ruff check .

      - name: Unit tests (pytest)
        run: pytest -q

      - name: Build artifact
        run: |
          mkdir -p dist
          # A real, reproducible build artifact: a versioned source tarball
          # tagged with the commit SHA for traceability.
          tar -czf "dist/app-${GITHUB_SHA::7}.tar.gz" app requirements.txt
          ls -la dist

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-build-${{ matrix.python-version }}
          path: dist/*.tar.gz
          retention-days: 7

  security:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0   # gitleaks scans full history

      - name: Secret scan (gitleaks)
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Dependency vulnerability scan (pip-audit / SCA)
        run: |
          pip install pip-audit==2.7.3
          pip-audit -r requirements.txt
```

Explain each part:

- `permissions: contents: read` — least privilege by default; we only grant more where a step needs it.
- `strategy.matrix` runs lint+test+build across Python 3.11 and 3.12 in parallel — a senior-expected pattern.
- `cache: pip` speeds up installs without caching anything unsafe.
- The build step produces a **real artifact** named with the **commit SHA** (`${GITHUB_SHA::7}`) for traceability — this matters in Class 2.
- The `security` job is a **separate job** so a code change and a security finding are clearly distinguishable in the run summary. Both `gitleaks` and `pip-audit` **exit non-zero on findings**, which fails the job and therefore the required status check.

### Step 4: Commit and Push

```bash
cat > .gitignore <<'EOF'
.venv/
__pycache__/
dist/
EOF
git add .
git commit -m "Add Flask app, tests, and real CI pipeline"
git remote add origin https://github.com/<YOU>/week-09-ci-demo.git
git push -u origin main
```

### Step 5: Show the Run in GitHub

1. Open the repo, go to the **Actions** tab.
2. Open the latest **CI** run.
3. Show the `lint-test-build (3.11)` and `(3.12)` matrix jobs running in parallel.
4. Open a job and read the log top-to-bottom — point out the `ruff` and `pytest` output.
5. In the run summary, download the **artifact** (`app-build-3.12`).
6. Show the `security` job and its gitleaks/pip-audit output.

Expected run summary:

```text
lint-test-build (3.11): success
lint-test-build (3.12): success
security: success
```

### Step 6: Make the Gate FAIL on Purpose (teach the value)

Show students the gate is real by breaking something, then reading the evidence:

```bash
# Introduce a real failure: a bug the unit test will catch
sed -i 's/return a + b/return a - b/' app/main.py
git commit -am "Break add() to demonstrate the test gate"
git push
```

The `test` step fails with a clear `pytest` assertion error. Read the first failed line, fix it, push again, and watch it go green. This models the evidence-first loop: symptom (red job) → evidence (assertion in log) → root cause (`-` should be `+`) → fix → validate (green).

### Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| Workflow does not start | File not under `.github/workflows/` or not pushed | Confirm path and that it was committed and pushed |
| `ModuleNotFoundError: app` in pytest | Tests run from a different working dir | Ensure `pytest` runs from repo root and `app/__init__.py` exists |
| ruff fails on demo code | Style finding | Read the rule code in the log; fix or run `ruff check --fix .` locally |
| gitleaks action fails to start | Missing `fetch-depth: 0` | Add `fetch-depth: 0` to the checkout step |
| Matrix job slow | Cold cache | Expected on first run; cache warms on subsequent runs |

### Cleanup Steps

No AWS resources are created in Class 1.

Optional cleanup:

```bash
deactivate 2>/dev/null || true
cd ..
rm -rf week-09-ci-demo
```

For hosted repo cleanup, delete the demo repository if it is no longer needed.

### Option B (Comparison Appendix): The Same Pipeline in GitLab CI

You do not need to build this in class — it exists so you recognize the mapping when you see GitLab in the wild. The concepts (install → lint → test → build → scan) are identical; only the syntax differs.

```yaml
stages: [lint, test, build]

default:
  image: python:3.12

variables:
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.pip-cache"

cache:
  paths:
    - .pip-cache/

lint:
  stage: lint
  script:
    - pip install -r requirements-dev.txt
    - ruff check .

test:
  stage: test
  script:
    - pip install -r requirements-dev.txt
    - pytest -q

build:
  stage: build
  script:
    - mkdir -p dist
    - tar -czf "dist/app-${CI_COMMIT_SHORT_SHA}.tar.gz" app
  artifacts:
    paths:
      - dist/*.tar.gz
    expire_in: 1 week
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
```

Mapping cheat sheet:

| Concept | GitHub Actions | GitLab CI | Jenkins (legacy) |
|---|---|---|---|
| Pipeline file | `.github/workflows/*.yml` | `.gitlab-ci.yml` | `Jenkinsfile` |
| Unit of work | job → steps | job → script | stage → steps |
| Ordering | `needs:` | `stages:` | `stage('...')` order |
| Matrix | `strategy.matrix` | parallel `matrix:` | `matrix {}` directive |
| Conditional run | `if:` | `rules:` (NOT legacy `only:`) | `when {}` |
| Artifacts | `upload-artifact` | `artifacts.paths` | `archiveArtifacts` |
| Keyless cloud auth | OIDC `id-token: write` | OIDC `id_tokens` | plugin/credentials |

Note: modern GitLab uses `rules:` for conditional execution. The older `only:`/`except:` keywords are deprecated — do not teach them to 2026 students.

---

## 13. Student Lab Manual

### Lab Title

**Build a Real CI Pipeline (Lint + Test + Build + Security Gate) and Enforce It with Branch Protection**

### Lab Objective

Create a GitHub Actions pipeline that installs dependencies, lints with `ruff`, runs `pytest`, builds a real artifact, and runs security scans — then turn on branch protection so a failing check actually blocks a merge.

### Estimated Time

45 minutes

### Student Prerequisites

Students need:

- Git and Python 3.11+ installed
- GitHub account
- VS Code or text editor
- Basic terminal knowledge

### Workflow Overview

```text
Create repo (app + tests)
   ↓
Add GitHub Actions workflow (lint, test, build, security)
   ↓
Run locally first (ruff + pytest)
   ↓
Commit and push
   ↓
Pipeline runs (matrix 3.11/3.12 + security)
   ↓
Turn on branch protection (required status checks)
   ↓
Open a PR with a failing test → see the merge get blocked
```

### Step-by-Step Student Instructions

#### Step 1: Create the Repository and App

Create an empty GitHub repository named `week-09-student-ci`, then locally:

```bash
git clone https://github.com/<YOU>/week-09-student-ci.git
cd week-09-student-ci
mkdir -p app tests .github/workflows
touch app/__init__.py
```

Create `app/main.py`:

```python
def add(a: int, b: int) -> int:
    return a + b
```

Create `tests/test_main.py`:

```python
from app.main import add


def test_add():
    assert add(2, 3) == 5
```

Create `requirements-dev.txt`:

```text
pytest==8.3.4
ruff==0.8.4
pip-audit==2.7.3
```

Create `README.md`:

```bash
echo "# Week 9 Student CI Lab" > README.md
```

#### Step 2: Run It Locally First

```bash
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements-dev.txt
ruff check .
pytest -q
```

You should see `All checks passed!` and `1 passed`. Never push a pipeline you have not run locally.

#### Step 3: Add the Workflow

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

jobs:
  lint-test-build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.11", "3.12"]
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: pip

      - name: Install dependencies
        run: pip install -r requirements-dev.txt

      - name: Lint
        run: ruff check .

      - name: Test
        run: pytest -q

      - name: Build artifact
        run: |
          mkdir -p dist
          tar -czf "dist/app-${GITHUB_SHA::7}.tar.gz" app
          ls -la dist

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-build-${{ matrix.python-version }}
          path: dist/*.tar.gz
          retention-days: 7

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Secret scan
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### Step 4: Commit and Push

```bash
printf '.venv/\n__pycache__/\ndist/\n' > .gitignore
git add .
git commit -m "Add app, tests, and real CI pipeline"
git push
```

#### Step 5: Inspect the Pipeline

1. Open the repo in GitHub and go to **Actions**.
2. Open the latest **CI** run.
3. Confirm both matrix jobs (`3.11`, `3.12`) and the `security` job pass.
4. Read one job log top-to-bottom; find the `ruff` and `pytest` lines.
5. Download the `app-build-3.12` artifact from the run summary.

#### Step 6: Enforce the Gate with Branch Protection

This is the step most courses skip. The pipeline only *blocks* merges if you require it.

1. In the repo, go to **Settings → Branches → Add branch ruleset** (or **Branch protection rules**).
2. Target branch: `main`.
3. Enable **Require a pull request before merging**.
4. Enable **Require status checks to pass before merging**, and select the `lint-test-build` and `security` checks.
5. Save.

#### Step 7: Prove It Works

```bash
git switch -c break-it
sed -i 's/return a + b/return a - b/' app/main.py   # introduce a real bug
git commit -am "Introduce a bug"
git push -u origin break-it
```

Open a pull request from `break-it` into `main`. The `Test` check fails, and GitHub now **blocks the Merge button**. Read the failed log, fix the bug (`-` back to `+`), push the fix, and watch the PR become mergeable.

### Expected Outputs

Passing run summary:

```text
lint-test-build (3.11): success
lint-test-build (3.12): success
security: success
```

Failing PR (after introducing the bug):

```text
Test  FAILED — assert 5 == -1
Merging is blocked: required status check "lint-test-build" failing
```

### Validation Checklist

Students should verify:

- The app and tests exist and run locally
- The workflow file is at `.github/workflows/ci.yml`
- The matrix runs on both 3.11 and 3.12
- Lint, test, build, and security jobs all pass
- A build artifact (named with the commit SHA) is downloadable
- Branch protection blocks a PR whose tests fail

### Troubleshooting Tips

| Problem | What to Check (evidence first) |
|---|---|
| Workflow did not run | Is the file under `.github/workflows/` and pushed? |
| `ModuleNotFoundError: app` | Does `app/__init__.py` exist? Is pytest run from the repo root? |
| `ruff check` fails | Read the rule code in the log; run `ruff check --fix .` locally |
| Artifact missing | Did the `tar` step succeed? Check `ls -la dist` output |
| gitleaks job errors immediately | Is `fetch-depth: 0` set on the checkout step? |
| Merge not blocked | Did you select the checks under required status checks? |

### Cleanup Steps

No cloud resources are created.

```bash
deactivate 2>/dev/null || true
cd ..
rm -rf week-09-student-ci
```

Delete the GitHub repo if you no longer need it.

### Reflection Questions

1. What caused your pipeline to start, and why does `pull_request` matter for the gate?
2. Which job produced the artifact, and why is naming it with the commit SHA useful?
3. What exactly blocked the merge when the test failed — the pipeline, or branch protection?
4. Why run lint and tests across a matrix of Python versions?
5. What would `pip-audit` or `gitleaks` catch that a unit test never would?

### Optional Challenge Task

Add a SAST scan with `bandit`:

```yaml
      - name: SAST (bandit)
        run: |
          pip install bandit==1.8.0
          bandit -r app
```

Then commit a deliberately insecure line (e.g., `eval(user_input)`) on a branch and watch the scan flag it.

---

## 14. Troubleshooting Activity

### Incident Title

**CI Is Red on a PR: Lint Passes Locally but the Test and Artifact Jobs Fail**

### Business Impact

A development team cannot merge a feature branch because the CI pipeline fails. Branch protection blocks the merge, and the release is delayed.

### Symptoms

Students see one of these in the Actions log:

```text
E   ModuleNotFoundError: No module named 'app'
```

or:

```text
assert 6 == 5
```

or:

```text
tar: app: Cannot stat: No such file or directory
```

### Starting Evidence

Broken workflow + repo state:

```yaml
name: CI
on:
  pull_request:
permissions:
  contents: read
jobs:
  lint-test-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -r requirements-dev.txt
      - run: ruff check .
      - run: pytest -q
      - run: |
          mkdir -p dist
          tar -czf dist/app.tar.gz application   # wrong directory name
```

And the repo is missing `app/__init__.py`, so `from app.main import add` cannot resolve.

### Student Investigation Steps

Apply the evidence-first method:

1. Which job/step failed *first*? (Read top-to-bottom.)
2. What is the exact error on the first failed line?
3. `ModuleNotFoundError: app` — is `app/` a package? Does `app/__init__.py` exist?
4. If the assertion fails, is the test wrong or the code wrong? Read the assertion.
5. For the `tar` failure, does the directory the command references actually exist (`application` vs `app`)?

### Expected Root Cause

Two compounding issues:

1. `app/__init__.py` is missing, so the import in the test fails (`ModuleNotFoundError`).
2. The build step references a non-existent directory `application` instead of `app`.

### Correct Resolution

```bash
touch app/__init__.py        # make app a proper package
```

```yaml
      - run: |
          mkdir -p dist
          tar -czf "dist/app-${GITHUB_SHA::7}.tar.gz" app   # correct dir, SHA-tagged
```

After fixing, push again and confirm the run goes green and the artifact uploads.

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Re-running the pipeline without changes | The same failure will repeat. |
| Deleting the failing test or scan | Hides the defect instead of fixing it; defeats the gate. |
| Assuming GitHub is broken | Most failures are import paths, command typos, or a real bug the test caught. |
| Editing the test to match the buggy output | The test was right; the code was wrong. Read the assertion. |

### Instructor Hints

Start with:

> What is the first job that failed?

Then ask:

> Does the error point to YAML parsing, command failure, or artifact upload?

### Preventive Action

- Use consistent two-space YAML indentation.
- Validate YAML before pushing.
- Keep pipeline files small at first.
- Create directories before writing files.
- Read job logs from top to bottom.

---

## 15. Scenario-Based Discussion Questions

### Question 1

**Why should a company run a pipeline before allowing code to merge?**

Expected themes:

- Prevent broken code from entering main branch
- Catch issues early
- Improve team confidence
- Standardize checks

Follow-up:

> What types of checks should block a merge request?

### Question 2

**Should every pipeline failure block production deployment?**

Expected themes:

- Critical failures should block deployment
- Non-critical warnings may not block
- Teams need clear policies
- Severity matters

Follow-up:

> What failures would you classify as production blockers?

### Question 3

**Where should secrets be stored in a CI/CD workflow?**

Expected themes:

- Not in source code
- Not in YAML files
- Store in CI/CD secret variables or cloud secret managers

Follow-up:

> What could happen if an AWS key is committed to Git?

### Question 4

**Why might a team store artifacts after a pipeline job?**

Expected themes:

- Reuse build output
- Save reports
- Support troubleshooting
- Provide release evidence

Follow-up:

> What artifacts might a Terraform pipeline save?

### Question 5

**What is the risk of letting every push deploy directly to production?**

Expected themes:

- Broken releases
- Security risk
- No approval process
- Customer impact

Follow-up:

> When might automatic deployment to production be acceptable?

### Question 6

**How does CI/CD help DevOps Engineers, Cloud Engineers, and SREs differently?**

Expected themes:

- DevOps: delivery automation
- Cloud Engineer: infrastructure validation
- SRE: reliability and safe change management

Follow-up:

> How would an SRE use pipeline history during an incident?

### Question 7

**What is more important in the beginning: a complex pipeline or a reliable simple pipeline?**

Expected themes:

- Reliable simple pipeline first
- Add complexity gradually
- Avoid confusing teams

Follow-up:

> What is the first pipeline every repo should have?

---

## 16. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple Choice

What is the main purpose of Continuous Integration?

A. Manually deploy code to production  
B. Automatically validate code changes frequently  
C. Replace Git branches  
D. Store cloud billing data  

**Answer:** B  
**Explanation:** CI automatically validates code changes when developers push or open merge requests.

### Question 2: Multiple Choice

Which file is commonly used for GitLab CI?

A. `pipeline.json`  
B. `.gitlab-ci.yml`  
C. `Dockerfile.ci`  
D. `aws-pipeline.yaml`  

**Answer:** B  
**Explanation:** GitLab CI pipelines are commonly defined in `.gitlab-ci.yml`.

### Question 3: Multiple Choice

What executes the commands inside a pipeline job?

A. Artifact  
B. Runner or agent  
C. README file  
D. Git branch  

**Answer:** B  
**Explanation:** A runner or agent executes the job commands.

### Question 4: True or False

YAML indentation can cause a pipeline to fail.

**Answer:** True  
**Explanation:** YAML is indentation-sensitive. Incorrect indentation can make the pipeline invalid.

### Question 5: True or False

A successful pipeline guarantees that the application has no bugs.

**Answer:** False  
**Explanation:** A successful pipeline only means the configured checks passed.

### Question 6: Short Answer

What is an artifact in a CI/CD pipeline?

**Answer:**  
An artifact is a file or output created by a pipeline job and saved for later use.

**Explanation:** Examples include build files, test reports, packages, or Terraform plans.

### Question 7: Short Answer

Name three common pipeline stages.

**Answer:**  
Lint, test, build. Other valid examples include security scan and deploy (the pipeline you built was lint -> test -> build artifact -> security gate).

**Explanation:** Stages organize the pipeline workflow into logical steps.

### Question 8: Troubleshooting

The `pytest` step fails with:

```text
ModuleNotFoundError: No module named 'app'
```

What should you check first?

**Answer:**  
Check that the dependency-install step ran before the test step and that the app package/module is on the Python path (for example, the install step (`pip install -r requirements.txt`) succeeded and the tests are run from the repository root where `app` lives).

**Explanation:** A non-zero exit code from `pytest` fails the CI job. `ModuleNotFoundError` usually means the install step was skipped or failed, or the test is being run from the wrong working directory, so the application module cannot be imported.

### Question 9: Troubleshooting

A package job says:

```text
No files to upload
```

What is a likely cause?

**Answer:**  
The artifact file was not created, or the artifact path is incorrect.

**Explanation:** The pipeline can only upload files that exist at the specified path.

### Question 10: AWS-Related

Which AWS service can store container images built by a future CI/CD pipeline?

A. CloudWatch  
B. Amazon ECR  
C. IAM  
D. Route 53  

**Answer:** B  
**Explanation:** Amazon ECR stores Docker/container images.

### Question 11: AWS-Related

Why should pipelines avoid hardcoding AWS access keys?

**Answer:**  
Hardcoded keys can be leaked in source control and create security risk.

**Explanation:** Pipelines should use secure variables or role-based authentication.

### Question 12: Multiple Choice

What usually happens when a job in an early stage fails?

A. Later stages continue automatically  
B. The pipeline usually stops or marks the workflow as failed  
C. The repository is deleted  
D. The runner becomes permanent  

**Answer:** B  
**Explanation:** Most pipelines stop or fail when a required earlier job fails.

---

## 17. Homework Assignment

### Assignment Title

**Design a Basic CI Workflow for Dev, Test, and Production**

### Scenario

A development team is building a web application. They want every merge request to run validation before the code is merged. They are not ready for full deployment automation yet, but they want a basic CI workflow that prepares them for future Docker, Kubernetes, and AWS deployments.

### Student Tasks

Students must create a short design document that includes:

1. A CI/CD workflow diagram (lint → test → build → security gate)
2. Pipeline stages, including which security gates run (secret scan, SCA, optional SAST/SBOM)
3. Trigger conditions (`push` to main vs `pull_request`)
4. Which checks should run on feature branches
5. Which checks should run on the main branch
6. What artifact should be created and how it is named for traceability (commit SHA)
7. What should happen if a pipeline fails, and which checks are *required* for merge
8. Where secrets should be stored, and why OIDC is preferred over static keys
9. How AWS ECR, S3, or IAM might be used later
10. Three possible pipeline failure scenarios and the evidence you would read first

### Expected Deliverables

Submit one document containing:

- Workflow diagram
- Pipeline stage table
- Short explanation of each stage
- Failure handling notes
- Security notes
- Future AWS integration notes

### Submission Format

Accepted formats:

- Markdown file
- PDF
- Word document
- Git repository README

### Estimated Completion Time

60 to 90 minutes

### Grading Criteria

| Criteria | Points |
|---|---:|
| Clear pipeline flow | 20 |
| Correct CI/CD terminology | 20 |
| Practical stage design | 20 |
| Security and secrets awareness | 15 |
| Failure and troubleshooting awareness | 15 |
| AWS future integration explanation | 10 |

### Optional Advanced Challenge

Write a working GitHub Actions workflow that implements the design, including at least one security gate (gitleaks or pip-audit) as a required status check, and turn on branch protection so a failing check blocks the merge. Push a deliberately failing commit and capture the blocked-merge screenshot as evidence.

---

## 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Wrong pipeline file name | Students confuse GitLab and GitHub file paths | Confirm platform-specific file location |
| Bad YAML indentation | YAML is sensitive to spacing | Use two spaces and copy known-good examples |
| Forgetting to commit pipeline file | File exists locally but not remotely | Run `git status`, `git add`, `git commit`, `git push` |
| Missing `README.md` | Test checks for a file that does not exist | Create and commit the required file |
| Wrong artifact path | Script creates one path, artifact config points to another | Match generated file path exactly |
| Hardcoding secrets | Beginners do not know secure variable management yet | Store secrets in platform settings, not code |
| Confusing CI with deployment | Students think all pipelines deploy | Explain CI as validation first |
| Ignoring job logs | Students guess instead of reading errors | Teach them to read logs from the first failure line |

---

## 19. Real-World Enterprise Scenario

### Scenario

A retail company has multiple developers working on a customer-facing web application. Developers often push changes quickly, but recent broken merges have caused failed deployments and delays.

Leadership wants a safer process before code is merged into the main branch.

### Constraints

- Developers must work in feature branches.
- Merge requests must be reviewed.
- A pipeline must validate every merge request.
- Production deployment is not automated yet.
- Secrets must not be stored in the repo.
- Future pipeline stages should support Docker image builds and AWS deployment.

### How the Class Topic Applies

This class introduces the first step: CI validation.

The team creates a pipeline that:

1. Runs on every merge request.
2. Validates repository structure.
3. Runs basic tests.
4. Creates an artifact.
5. Blocks merge if validation fails.

### What Each Role Would Do

| Role | Responsibility |
|---|---|
| DevOps Engineer | Build and maintain the CI pipeline. |
| Cloud Engineer | Ensure future AWS deployment access is secure. |
| SRE | Ensure pipeline checks reduce production risk and failed releases. |
| Developer | Fix code or test failures before requesting review. |
| Security Engineer | Review how secrets and credentials are handled. |

---

## 20. Instructor Tips

### Teaching Tips

- Use a very simple repo first.
- Avoid introducing Docker too early in this class.
- Explain YAML slowly.
- Show job logs live.
- Make students read errors before fixing them.
- Reinforce that CI/CD is a workflow, not just a tool.

### Pacing Tips

- Do not spend more than 25 minutes on CI vs CD definitions.
- Reserve enough time for hands-on work.
- Expect YAML errors during the lab.
- Keep Class 1 focused on CI, not full deployment.

### Lab Support Tips

When helping students, check in this order:

1. File name
2. File location
3. YAML indentation
4. Git commit and push
5. Pipeline trigger
6. Job log
7. Artifact path

### Helping Struggling Students

Give them a working minimal GitHub Actions workflow first:

```yaml
name: CI
on: [push, pull_request]
permissions:
  contents: read
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -r requirements-dev.txt
      - run: pytest -q
```

Then add lint, the build artifact, and the security job one step at a time.

### Challenging Advanced Students

Ask advanced students to:

- Add a `bandit` SAST job and a `pip-audit` SCA job and make them required checks
- Generate an SBOM with `anchore/sbom-action` (syft) and upload it as an artifact
- Add a `concurrency:` block to cancel superseded PR runs
- Extract the lint/test steps into a reusable workflow (`workflow_call`) or a composite action
- Convert the workflow to the GitLab CI equivalent and explain why `rules:` replaced `only:`

---

## 21. Student Outcome Checklist

### Students Should Be Able to Explain

- What CI/CD means
- Difference between CI, Continuous Delivery, and Continuous Deployment
- What a pipeline is
- What jobs and stages are
- What a runner does
- What artifacts are
- Why pipelines protect the main branch

### Students Should Be Able to Build or Configure

- A Git repository with a small real app and tests
- A GitHub Actions workflow with lint, test (matrix), build, and security jobs
- A real, SHA-tagged build artifact
- A secret scan (gitleaks) and dependency scan (pip-audit) that fail the build on findings
- Branch protection with required status checks that enforces the gate

### Students Should Be Able to Troubleshoot

- YAML syntax errors
- Wrong pipeline file location
- Missing required files
- Failed shell commands
- Missing artifact paths
- Pipeline not triggering after push

---

## 22. Class Completion Checklist

### Instructor Checklist Before Ending Class

Confirm that students understand:

- CI validates code changes
- CD moves code toward release or deployment
- Pipelines are made of jobs and stages
- Runners execute pipeline commands
- YAML indentation matters
- Artifacts are saved pipeline outputs
- Job logs are the first place to troubleshoot

Confirm that most students have:

- Created a repo
- Added a pipeline file
- Triggered a pipeline
- Viewed job logs
- Created or inspected an artifact

### Student Checklist Before Leaving Class

Students should verify:

- My repository contains `README.md`
- My pipeline YAML file is committed and pushed
- My pipeline ran successfully or I understand why it failed
- I can find pipeline job logs
- I can explain what each job does
- I can explain what an artifact is
- I documented at least one troubleshooting lesson

### Items to Verify Before Moving to Class 2

Before Class 2, students should be ready to work with:

- Variables
- Artifacts
- Basic secret handling concepts
- Branch-based workflows
- Manual approval concepts
- Practical pipeline troubleshooting

Class 2 should build directly on this by adding variables, artifacts, secrets, approvals, AWS pipeline concepts, and more realistic team workflows.

---

## Class Artifacts & Validation

All paths are relative to the repo root. This class builds the **PRIMARY** Week 9
pipeline `ci.yml` (lint → test → SHA-tagged tarball + the gitleaks/pip-audit security
gate) over a small Flask app, plus the troubleshooting fixture. Every gate below was
run in this environment; commands are reproducible from `labs/cicd-pipelines/`.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/cicd-pipelines/solution/.github/workflows/ci.yml | CI/CD (GitHub Actions) | The Class-1 pipeline verbatim: `lint (ruff) → test (pytest 3.11/3.12) → build SHA-tagged tarball` + a hard `security` job (gitleaks + pip-audit, no `continue-on-error`) | `actionlint solution/.github/workflows/ci.yml` | PASS (actionlint 1.7.3, 0 errors) |
| 2 | labs/cicd-pipelines/solution/.github/workflows/ci.yml | CI/CD invariants | Workflow unit tests asserting the security gate is hard, `fetch-depth: 0` present, tarball is SHA-tagged, no static keys | `python3 -m unittest discover -s tests` | PASS (24 tests) |
| 3 | labs/cicd-pipelines/solution/.github/workflows/ci.yml | Job graph | Every `needs:` resolves; DAG is acyclic | `python3 tests/check_job_graph.py solution/.github/workflows/ci.yml` | PASS |
| 4 | labs/cicd-pipelines/solution/app/main.py | Python automation | The Flask service under test (`add()` + `/health`) | `python3 -m py_compile solution/app/main.py solution/app/__init__.py` | PASS |
| 5 | labs/cicd-pipelines/solution/tests/test_main.py | Application code under test | pytest unit tests the CI gate runs | `cd solution && python3 -m pytest -q` | PASS (3 passed) |
| 6 | labs/cicd-pipelines/solution/app/Dockerfile | Docker | Non-root image; smoke test confirms `/health` → 200 | `docker build` + `/health` smoke (in `./validate.sh`) | PASS (~184 MB, HTTP 200) |
| 7 | labs/cicd-pipelines/broken/ci-bad-needs.yml | Troubleshooting fixture | Real broken workflow (two dangling `needs:`) for the drill — gate must REJECT it | `! python3 tests/check_job_graph.py broken/ci-bad-needs.yml` ; `! actionlint broken/ci-bad-needs.yml` | PASS (correctly rejected) |
| 8 | labs/cicd-pipelines/docs/architecture.mmd | Architecture diagram | Mermaid of the PR → required-check → merge → tag flow | renders in Mermaid; YAML/diagram parse in `./validate.sh` | PASS |
| 9 | labs/cicd-pipelines/validate.sh | Shell automation | One command that runs every local gate above | `./validate.sh` | PASS (31 passed, 0 failed) |

**Live operations that are DEFERRED (documented, not run here — no live-evidence file exists for this week):**
the actual `gitleaks` secret-block and `pip-audit` CVE-block on a real PR, the `ruff`
lint step, and the branch-protection *required-check* enforcement run only in real
GitHub CI. The exact commands are wired into `ci.yml` and documented in
`labs/cicd-pipelines/README.md` (`gitleaks detect --source solution --no-git`,
`cd solution && pip-audit -r requirements.txt`, `ruff check solution`). The pipeline is
fully static-validated here; it has **not** been operated against a live PR in this
environment.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — `ci.yml` (GitHub Actions), `app/main.py`, `tests/test_main.py`, `app/Dockerfile`, `validate.sh` all exist as real files.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured — `actionlint`, the unittest invariants, the job-graph check, `py_compile`, `pytest`, the docker `/health` smoke, and `yamllint` all PASS (see table + `./validate.sh`: 31 passed, 0 failed).
- [x] Lab has **starter** (security job is TODO) and **solution** (reference) versions — `labs/cicd-pipelines/starter/` and `labs/cicd-pipelines/solution/`.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** — `labs/cicd-pipelines/README.md`.
- [x] **Cleanup/teardown** is provided and idempotent — README "Cleanup" section; the local lab creates **no** cloud resources by default.
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise — README "Instructor answer key" + §16/§17 here.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `broken/ci-bad-needs.yml` (two injected dangling `needs:`), and the gate is proven to reject it.
- [x] **Expected outputs** are shown for demos and labs — README "Expected results"; §13 "Expected Outputs" here.
- [x] **Cost & security warnings** present — README "Security considerations" / "Cost considerations"; local lab is $0.
- [x] **Cross-references** to the module repo and to prior/next weeks are correct — links to `labs/cicd-pipelines/`; feeds Week 10 (same app → image) and reused by Week 19 (advanced supply-chain).
- [x] The **artifact manifest** (§4.2) is present and every path resolves — verified with `ls`/gate runs above.
- [ ] **Mastered / live-operated** — the secret-block, CVE-block, and required-check enforcement are NOT yet exercised against a live PR (no live-evidence file). Capped accordingly in the score.
