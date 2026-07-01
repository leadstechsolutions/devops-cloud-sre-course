# Week 3: Git, Git Workflows, and Collaboration  
> **▶ Runnable lab for this class:** [`labs/git-collaboration/`](../../labs/git-collaboration/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 1 Package: Git Fundamentals and Local Workflows

**Week:** 3
**Class:** 1
**Track:** Unified DevOps · Cloud · SRE Track

---

# 1. Class Overview

## Class Title

**Class 1: Git Fundamentals, Commits, Branches, and Local Workflow**

## Class Purpose

This class introduces students to Git as a core tool for DevOps, Cloud Engineering, and SRE work. Students learn how Git tracks changes, why teams use branches, how commits work, and how local changes move from a developer workstation to a shared remote repository.

## How This Class Connects to the Overall Course

Git becomes the foundation for later course topics:

| Future Topic | Git Connection |
|---|---|
| Terraform | Infrastructure changes are reviewed and tracked in Git |
| CI/CD | Pipelines trigger from Git commits and branches |
| Docker | Dockerfiles and app code are versioned in Git |
| Kubernetes | YAML manifests and Helm charts are stored in Git |
| SRE | Runbooks, scripts, postmortems, and automation live in Git |
| Cloud Engineering | Network, IAM, and platform code changes go through Git review |

## What Students Will Practice

Students will practice:

- Creating a Git repository
- Checking repository status
- Inspecting changes with `git diff`
- Staging files
- Creating commits
- Creating and switching branches with `git switch` / `git restore`
- Adding a `.gitignore` to keep secrets and state out of the repo
- Setting up remote authentication (`gh auth login` or an `ed25519` SSH key)
- Viewing commit history
- Pushing a branch to GitHub or GitLab
- Troubleshooting common beginner Git issues

---

# 2. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** why Git is important for DevOps, Cloud Engineering, and SRE work.
2. **Describe** the difference between a working directory, staging area, local repository, and remote repository.
3. **Configure** basic Git identity settings.
4. **Create** a local Git repository.
5. **Stage and commit** file changes, inspecting them first with `git diff`.
6. **Build** a simple branch-based workflow using `git switch` and `git restore`.
7. **Configure** a `.gitignore` and remote authentication (`gh auth login` or `ed25519` SSH key).
8. **Push** a local branch to a remote repository.
9. **Troubleshoot** common Git errors such as missing identity, untracked files, wrong branch, and failed push.

---

# 3. Prerequisites Students Should Already Know

## Required Prior Concepts

Students should already understand:

- Basic terminal usage
- Basic file and folder navigation
- Basic text editing in VS Code or another editor
- What a command-line tool is
- Why teams need to track technical changes

## Required Tools Already Installed

Students should have:

- Git
- VS Code
- Terminal or command prompt
- Browser
- GitHub or GitLab account, if remote push will be practiced

## Required Accounts or Access

Recommended:

- GitHub account or GitLab account
- Ability to create a test repository
- No AWS access required for this class

## Files, Repos, or Sample Code Needed

Instructor can provide either:

1. A starter repository, or  
2. Let students create a new local repository during the lab.

Recommended starter file:

```text
README.md
```

Optional sample content:

```markdown
# Week 3 Git Lab

This repository is used to practice Git fundamentals for DevOps, Cloud Engineering, and SRE workflows.
```

---

# 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Git | A version control tool that tracks changes to files | Used to track code, Terraform, Kubernetes YAML, scripts, and documentation |
| Repository | A folder managed by Git | A team may have repos for apps, infrastructure, pipelines, and runbooks |
| Working directory | The files currently visible and editable on your machine | This is where engineers make changes before committing |
| Staging area | A preparation area for changes before committing | Lets engineers choose exactly what goes into the next commit |
| Commit | A saved snapshot of changes | Creates traceable history of who changed what and why |
| Branch | A separate line of work | Used to safely make changes without directly modifying main |
| Main branch | The primary stable branch | Often protected in enterprise teams |
| Remote repository | A shared copy hosted on GitHub, GitLab, or another platform | Enables collaboration, review, and CI/CD |
| Push | Send local commits to remote | Makes your branch visible to teammates and pipelines |
| Pull | Bring remote changes into your local repo | Keeps your local copy updated |
| Git history | The record of commits over time | Helps teams audit changes and troubleshoot regressions |
| Commit message | Text explaining why a change was made | Important for future troubleshooting and reviews |
| `git switch` | Modern command to change branches (Git 2.23+) | The recommended verb for moving between branches; clearer than `checkout` |
| `git restore` | Modern command to discard or unstage changes (Git 2.23+) | Recommended verb for undoing edits or unstaging; clearer than `checkout` |
| `git diff` | Shows exactly what changed, line by line | Used to inspect a change before staging, committing, or opening a review |
| `.gitignore` | A file listing paths Git should never track | Prevents committing secrets, state files, and build junk (`.env`, `*.tfstate`) |
| SSH key | A key pair that authenticates you to GitHub/GitLab without a password | `ed25519` keys are the 2026 standard for pushing to remotes |
| GitOps | A delivery model where Git is the source of truth that a controller reconciles | Argo CD / Flux watch a repo and make the cluster match it (seen in W11–W13) |

---

# 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| Git | Main version control tool for tracking changes |
| Terminal | Used to run Git commands |
| VS Code | Used to edit files and inspect repo changes |
| GitHub or GitLab | Used as the remote repository platform |
| `gh` (GitHub CLI) | Authenticates to GitHub and manages repos/PRs from the terminal |
| `ssh-keygen` | Generates an `ed25519` SSH key pair for keyless remote push |
| Browser | Used to view remote repositories and pushed branches |

## Tool Notes for Beginners

Students should understand that Git is not the same as GitHub or GitLab.

```text
Git = the version control tool
GitHub/GitLab = platforms that host Git repositories
```

---

# 6. AWS Services Used

No AWS service is directly required in this class.

However, Git will later support AWS-related work such as:

| Future AWS Topic | How Git Will Be Used |
|---|---|
| Terraform for AWS | Track VPC, IAM, EC2, S3, and EKS infrastructure code |
| AWS CI/CD pipelines | Trigger pipelines from commits and branches |
| AWS IAM changes | Review policies before applying them |
| AWS EKS | Store Kubernetes YAML and Helm charts |
| AWS CloudWatch | Store dashboards, alert definitions, and runbooks as code |

## AWS Teaching Point

In real AWS teams, engineers should not manually change production infrastructure without a tracked change. Git gives the team an audit trail before infrastructure changes are deployed.

## Awareness: Git as the Source of Truth (GitOps)

Plant this idea now; it pays off in Weeks 11–13 (Kubernetes/Helm):

```text
In modern delivery, Git is not just a record of changes — it is the SOURCE OF TRUTH.
A controller (Argo CD or Flux) watches a Git repo and continuously makes the live
system match what is committed. You change infrastructure by merging a commit, not
by clicking in a console. This is called GitOps. The local skills you learn today
(commit, branch, review, history) are the foundation of how production gets deployed.
```

---

# 7. Azure and GCP Comparison Notes

Keep this section short during class.

| Platform | Git Workflow Relationship |
|---|---|
| AWS | Git is commonly used with Terraform, GitLab CI, GitHub Actions, CodePipeline, EKS manifests, and infrastructure code |
| Azure | Azure Repos and GitHub are commonly used with Azure DevOps pipelines |
| GCP | Git providers are commonly integrated with Cloud Build and GKE deployment workflows |

Key point:

```text
The Git workflow is mostly cloud-agnostic.
The same branch, commit, push, and review model applies across AWS, Azure, and GCP.
```

---

# 8. Time-Boxed Instructor Agenda

| Time | Section | Activity |
|---:|---|---|
| 0:00 to 0:10 | Opening | Welcome, class purpose, why Git matters |
| 0:10 to 0:25 | Role Context | Git in DevOps, Cloud Engineering, and SRE |
| 0:25 to 0:50 | Core Concepts | Repository, working directory, staging area, commits, remote |
| 0:50 to 1:15 | Branching Basics | Main branch, feature branches, safe change isolation |
| 1:15 to 1:25 | Break | Short break |
| 1:25 to 2:00 | Instructor Demo | Git init, config, add, diff, commit, switch, .gitignore, auth, push |
| 2:00 to 2:40 | Student Lab | Students perform local Git workflow |
| 2:40 to 2:55 | Troubleshooting Activity | Fix identity error, wrong branch, untracked file, failed push |
| 2:55 to 3:00 | Recap | Outcomes, homework, Class 2 preview |

---

# 9. Instructor Lesson Plan

## Step 1: Open With Why Git Matters

Explain:

```text
Git is one of the most important tools in DevOps, Cloud Engineering, and SRE because it tracks technical change.
```

Use examples:

- Terraform VPC change
- Kubernetes deployment update
- CI/CD pipeline edit
- Bash script update
- Incident runbook improvement

Teaching tip:

Do not start with commands immediately. First explain why teams care about Git.

## Step 2: Explain the Local Git Workflow

Introduce the basic flow:

```text
Edit file
Check status
Stage file
Commit file
View history
Push branch
```

Pause and ask:

```text
Why would a team want a history of changes?
```

Expected student answers:

- To know who changed something
- To roll back
- To review mistakes
- To troubleshoot issues after deployment

## Step 3: Explain Repository Anatomy

Show these areas:

```text
Working Directory -> Staging Area -> Local Repository -> Remote Repository
```

Explain each area slowly.

Beginner teaching note:

Students often think `git add` means upload. Clarify that `git add` only stages files locally.

## Step 4: Introduce Branches

Explain:

```text
A branch lets you work safely without changing the main line of work.
```

Use enterprise framing:

```text
In real teams, production-related changes should happen on a feature branch and be reviewed before merging.
```

## Step 5: Instructor Demo

Run the demo slowly. After every command, show `git status`.

Teaching tip:

`git status` is the most beginner-friendly troubleshooting command in Git.

## Step 6: Student Lab

Let students work independently or in pairs.

Instructor should walk around and check:

- Are they in the right folder?
- Did they initialize Git?
- Did they configure name and email?
- Did they create a branch?
- Did they commit changes?
- Did they understand what was committed?

## Step 7: Troubleshooting Review

Use real beginner mistakes:

- `Author identity unknown`
- `nothing to commit`
- wrong branch
- remote not configured
- push rejected

## Step 8: Class Wrap-Up

End with this message:

```text
Today you learned the local Git workflow. In Class 2, we will turn this into a team workflow using pull requests, merge requests, code review, and conflict resolution.
```

---

# 10. Instructor Lecture Notes

## Opening Talking Point

“Before we touch Terraform, Kubernetes, Docker, or CI/CD pipelines, we need Git. Git is the system that lets technical teams work safely. It gives us history, accountability, review, and rollback options.”

## Why Git Matters in DevOps

DevOps is about improving delivery speed and reliability. Git helps with both.

Without Git:

- Changes happen manually
- Nobody knows exactly what changed
- Rollbacks are harder
- Reviews are inconsistent
- Automation is difficult

With Git:

- Every change is tracked
- Teams can review before merging
- CI/CD pipelines can run automatically
- Infrastructure changes are auditable
- Documentation stays versioned

## Git Is Not Only for Developers

Students may assume Git is only for application code. Correct that early.

Git is used for:

```text
Terraform
Kubernetes YAML
Helm charts
Dockerfiles
Pipeline YAML
Bash scripts
Python scripts
Runbooks
Architecture notes
Incident documentation
```

## Working Directory, Staging Area, and Commit

Explain it like packing a box:

```text
Working directory = your desk
Staging area = items you choose to pack
Commit = sealed box with a label
Remote repository = shared storage room
```

## Common Misconception

Misconception:

```text
git add uploads the file.
```

Correction:

```text
git add only stages the file locally. Nothing goes to GitHub or GitLab until git push.
```

## Commit Quality

A commit should explain what changed.

Weak commit messages:

```text
changes
update
fix
stuff
```

Better commit messages:

```text
Add initial README for Git lab
Update lab notes with Git workflow explanation
Add health check script for Linux service monitoring
```

## Branching

Explain:

```text
The main branch should be stable. A feature branch is where you safely prepare a change.
```

Real example:

```text
feature/add-vpc-module
feature/update-readme
bugfix/fix-pipeline-variable
docs/add-runbook-template
```

## Enterprise Context

In enterprise teams, branches and commits connect to change management.

For example:

- A Jira ticket describes the requested change.
- A feature branch contains the implementation.
- A commit records the change.
- A merge request asks for review.
- A pipeline validates the change.
- Approval allows merge.
- The merge can trigger deployment.

---

# 11. Whiteboard Explanation

## Simple Git Flow

```text
Student laptop
     |
     v
Working Directory
     |
     | git add
     v
Staging Area
     |
     | git commit
     v
Local Repository
     |
     | git push
     v
Remote Repository
GitHub / GitLab
```

## Step-by-Step Explanation

1. **Working Directory**
   - Where files are edited.
   - Git sees that files changed.

2. **Staging Area**
   - Where selected changes are prepared.
   - Created using `git add`.

3. **Local Repository**
   - Where committed snapshots are saved.
   - Created using `git commit`.

4. **Remote Repository**
   - Shared team location.
   - Updated using `git push`.

## Enterprise Version

```text
Engineer
  |
  v
Feature Branch
  |
  v
Commit Changes
  |
  v
Push Branch
  |
  v
Merge Request
  |
  v
Review + Pipeline Checks
  |
  v
Merge to Main
  |
  v
Deploy or Apply Change
```

## How This Connects to Infrastructure

```text
Terraform change
  |
  v
Feature branch
  |
  v
Commit
  |
  v
Merge request
  |
  v
Review plan output
  |
  v
Merge
  |
  v
Pipeline applies infrastructure change
```

---

# 12. Instructor Demo Script

## Demo Title

**Basic Git Workflow: Create, Commit, Branch, and Push**

## Demo Objective

Show students how a DevOps or cloud engineer tracks changes locally and prepares them for team collaboration.

## Required Setup

Instructor needs:

- Git installed
- Terminal open
- VS Code installed
- Optional GitHub or GitLab test repository
- Internet access if pushing to remote

## Demo Part 1: Verify Git

Run:

```bash
git --version
```

Expected output:

```text
git version 2.x.x
```

Explain:

```text
This confirms Git is installed and available from the terminal.
```

## Demo Part 2: Configure Git Identity

Run:

```bash
git config --global user.name "Instructor Name"
git config --global user.email "instructor@example.com"
git config --global init.defaultBranch main
```

Validate:

```bash
git config --global --list
```

Expected output:

```text
user.name=Instructor Name
user.email=instructor@example.com
init.defaultBranch=main
```

Explain:

```text
Git needs to know who is creating commits. In real teams, this identity connects changes to a person.
```

Teaching point on the default branch:

```text
Older Git installs name the first branch "master"; newer ones name it "main".
Do not leave this to luck. Setting init.defaultBranch=main once makes every new
repo start on main, which matches what GitHub/GitLab and this course expect.
```

## Demo Part 3: Create a Local Repository

Run:

```bash
mkdir git-week3-demo
cd git-week3-demo
git init
```

Expected output:

```text
Initialized empty Git repository in .../git-week3-demo/.git/
```

Explain:

```text
This folder is now being tracked by Git.
```

## Demo Part 4: Add a README

Run:

```bash
echo "# Git Week 3 Demo" > README.md
git status
```

Expected output:

```text
Untracked files:
  README.md
```

Explain:

```text
Git sees the file, but it is not tracking it in a commit yet.
```

## Demo Part 5: Stage and Commit

Run:

```bash
git add README.md
git status
```

Expected output:

```text
Changes to be committed:
  new file: README.md
```

Run:

```bash
git commit -m "Add initial README"
```

Expected output:

```text
[main abc1234] Add initial README
 1 file changed, 1 insertion(+)
 create mode 100644 README.md
```

Explain:

```text
The file is now saved as a committed snapshot in local Git history.
```

## Demo Part 6: View History

Run:

```bash
git log --oneline
```

Expected output:

```text
abc1234 Add initial README
```

Explain:

```text
Git history helps us understand what changed over time.
```

## Demo Part 7: Create a Feature Branch

Run (modern verb, Git 2.23+):

```bash
git switch -c feature/update-readme
```

Expected output:

```text
Switched to a new branch 'feature/update-readme'
```

Validate:

```bash
git branch
```

Expected output:

```text
* feature/update-readme
  main
```

Explain:

```text
The star shows the branch we are currently working on.
```

Legacy note:

```text
You will still see "git checkout -b feature/update-readme" in older docs and
codebases. It does the same thing. Since Git 2.23, "git switch" (change branches)
and "git restore" (discard/unstage changes) split checkout's two overloaded jobs
into two clear verbs. Teach and use switch/restore; recognize checkout as legacy.
```

Switching back to an existing branch:

```bash
git switch main          # modern
# git checkout main      # legacy equivalent
```

## Demo Part 8: Make a Change on the Branch

Run:

```bash
echo "This repository demonstrates a basic Git workflow for DevOps students." >> README.md
git status
```

## Demo Part 8b: Inspect the Change Before Staging (`git diff`)

Before staging anything, look at exactly what changed:

```bash
git diff
```

Expected output:

```diff
diff --git a/README.md b/README.md
index 1a2b3c4..5d6e7f8 100644
--- a/README.md
+++ b/README.md
@@ -1 +1,2 @@
 # Git Week 3 Demo
+This repository demonstrates a basic Git workflow for DevOps students.
```

Explain:

```text
git diff shows the change line by line: '+' is added, '-' is removed.
Inspecting the diff BEFORE you stage and commit is the same discipline you will
use later to "render/plan before apply" with Terraform. Never commit a change
you have not actually looked at.
```

Now stage, then inspect the staged change:

```bash
git add README.md
git diff --staged      # what will go into the next commit
```

If you decide a working-directory edit was a mistake, discard it with the modern verb:

```text
git restore README.md          # discard unstaged edits in the file
git restore --staged README.md # unstage (keep the edits, undo the git add)
```

Commit when the diff looks correct:

```bash
git commit -m "Update README with Git workflow purpose"
```

Expected output:

```text
[feature/update-readme def5678] Update README with Git workflow purpose
 1 file changed, 1 insertion(+)
```

Explain:

```text
This change is isolated on the feature branch.
```

## Demo Part 8c: Add a `.gitignore` (Required, Not Optional)

The most damaging beginner mistake for this audience is committing secrets or
generated state. Create a `.gitignore` that excludes them from the start:

```bash
cat > .gitignore <<'EOF'
# Secrets and credentials — NEVER commit these
.env
*.pem
*.key
credentials
aws-credentials*

# Terraform state and local cache
.terraform/
*.tfstate
*.tfstate.*
*.tfvars

# Logs and OS/editor noise
*.log
.DS_Store
.vscode/
EOF

git add .gitignore
git commit -m "Add .gitignore for secrets, Terraform state, and local noise"
```

Demonstrate that it works:

```bash
echo "AWS_SECRET_ACCESS_KEY=abc123" > .env
git status
```

Expected output:

```text
On branch feature/update-readme
nothing to commit, working tree clean
```

Explain:

```text
Git does not show .env as untracked — .gitignore is keeping it out of the repo.
This is the single most important safety habit in this course.
```

Security teaching point — what to do if a secret is ever committed:

```text
.gitignore only prevents NEW files from being tracked. It does NOT remove a secret
that is already committed. Git history is forever and is copied to every clone.
If a credential reaches a commit:
  1. ROTATE the secret immediately (assume it is already compromised).
  2. Then scrub history (git filter-repo or BFG) and force-push — covered later.
Rotation first, history cleanup second. Never rely on "deleting" the file.
```

## Demo Part 9: Set Up Remote Authentication (2026)

HTTPS-with-password auth to GitHub/GitLab no longer works. Pick ONE method and
authenticate once before pushing.

Option A — GitHub CLI (simplest for GitHub):

```bash
gh auth login
# Choose: GitHub.com -> HTTPS -> authenticate with browser
gh auth status   # confirms you are logged in
```

Option B — ed25519 SSH key (works for GitHub and GitLab):

```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
# Press Enter to accept the default path (~/.ssh/id_ed25519); set a passphrase.

# Start the agent and load the key:
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Print the PUBLIC key and paste it into GitHub/GitLab > Settings > SSH keys:
cat ~/.ssh/id_ed25519.pub

# Verify (GitHub example):
ssh -T git@github.com
```

Explain:

```text
Never share or commit the PRIVATE key (id_ed25519, no .pub). Only the .pub goes
to the platform. This is the same ed25519 key concept introduced in Week 2 (Linux);
the key you made there can be reused here.
A Personal Access Token (PAT) is a third option for HTTPS automation, but gh auth
login or an SSH key is preferred for interactive work.
```

## Demo Part 9b: Optional Remote Push

Only do this if a remote repository is ready.

Run:

```bash
git remote add origin <REMOTE_REPO_URL>
git push -u origin feature/update-readme
```

Expected output:

```text
branch 'feature/update-readme' set up to track 'origin/feature/update-readme'
```

Explain:

```text
Now the branch exists on the remote platform where a team could review it.
```

## Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| `git: command not found` | Git not installed or terminal not refreshed | Install Git or reopen terminal |
| `Author identity unknown` | Git name/email missing | Run `git config --global user.name` and `user.email` |
| `not a git repository` | Instructor is in wrong folder | Run `pwd` or `ls`, then `cd` into repo |
| Push fails | Remote not configured or wrong URL | Run `git remote -v` and correct the URL |
| Authentication fails | HTTPS password auth is dead; no key/login configured | Run `gh auth login`, or add an `ed25519` SSH key (Demo Part 9) |

## Cleanup Steps

For local cleanup:

```bash
cd ..
rm -rf git-week3-demo
```

Windows PowerShell:

```powershell
cd ..
Remove-Item -Recurse -Force git-week3-demo
```

Security warning:

```text
Never commit passwords, AWS access keys, tokens, or private SSH keys into Git.
```

---

# 13. Student Lab Manual

## Lab Title

**Create Your First DevOps Git Workflow**

## Lab Objective

Practice the basic Git workflow used by DevOps, Cloud Engineering, and SRE teams.

## Estimated Time

40 minutes

## Student Prerequisites

Students need:

- Git installed
- Terminal access
- VS Code or text editor
- Optional GitHub or GitLab account

## Workflow Overview

```text
Create folder
Initialize Git
Create README
Stage file
Commit file
Create branch
Edit file
Commit branch change
View history
Optional push to remote
```

## Step 1: Verify Git

Run:

```bash
git --version
```

Expected output:

```text
git version 2.x.x
```

## Step 2: Configure Your Git Identity

Run:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
```

Validate:

```bash
git config --global --list
```

Expected output:

```text
user.name=Your Name
user.email=your.email@example.com
init.defaultBranch=main
```

Setting `init.defaultBranch=main` ensures every new repo starts on `main` instead
of the older `master` name.

## Step 3: Create a Lab Folder

Run:

```bash
mkdir week3-git-lab
cd week3-git-lab
```

## Step 4: Initialize Git

Run:

```bash
git init
```

Expected output:

```text
Initialized empty Git repository
```

## Step 5: Create a README File

Run:

```bash
echo "# Week 3 Git Lab" > README.md
echo "This lab practices Git fundamentals for DevOps and cloud teams." >> README.md
```

Check status:

```bash
git status
```

Expected output should show:

```text
Untracked files:
  README.md
```

## Step 6: Stage the File

Run:

```bash
git add README.md
git status
```

Expected output should show:

```text
Changes to be committed:
  new file: README.md
```

## Step 7: Commit the File

Run:

```bash
git commit -m "Add initial README"
```

Expected output:

```text
1 file changed
create mode 100644 README.md
```

## Step 8: Create a Feature Branch

Run (modern verb):

```bash
git switch -c feature/add-lab-notes
```

Expected output:

```text
Switched to a new branch 'feature/add-lab-notes'
```

Legacy equivalent you may still see: `git checkout -b feature/add-lab-notes`.

Check current branch:

```bash
git branch
```

Expected output:

```text
* feature/add-lab-notes
  main
```

## Step 9: Add Lab Notes

Run:

```bash
echo "" >> README.md
echo "## Lab Notes" >> README.md
echo "Git helps teams track changes, review work, and support CI/CD automation." >> README.md
```

Check status:

```bash
git status
```

Expected output:

```text
modified: README.md
```

## Step 9b: Inspect Your Change With `git diff`

Before staging, look at exactly what you changed:

```bash
git diff
```

You should see your added lines prefixed with `+`. Always inspect a change before
you commit it — this is the same "look before you apply" habit you will use with
Terraform later.

## Step 10: Stage and Commit the Branch Change

Run:

```bash
git add README.md
git commit -m "Add lab notes"
```

## Step 10b: Add a `.gitignore` (Required)

This is a core safety step, not optional. Create a `.gitignore` so secrets and
generated files can never be committed:

```bash
cat > .gitignore <<'EOF'
# Secrets — NEVER commit these
.env
*.pem
*.key

# Terraform state and local cache
.terraform/
*.tfstate
*.tfstate.*

# Logs and OS/editor noise
*.log
.DS_Store
.vscode/
EOF

git add .gitignore
git commit -m "Add .gitignore for secrets and generated files"
```

Prove it works:

```bash
echo "API_TOKEN=secret123" > .env
git status
```

`.env` should NOT appear as untracked — `.gitignore` is excluding it.

```text
Remember: .gitignore only stops NEW files from being tracked. If a secret was
ALREADY committed, the fix is to ROTATE the secret first (treat it as leaked),
then clean history separately. Git history is permanent.
```

## Step 11: View Commit History

Run:

```bash
git log --oneline
```

Expected output should show your commits, newest first, for example:

```text
9ab12cd Add .gitignore for secrets and generated files
def5678 Add lab notes
abc1234 Add initial README
```

## Step 12: Push to Remote

First make sure you are authenticated (do this once per machine):

```bash
gh auth login        # GitHub, browser-based; OR
ssh -T git@github.com  # confirm your ed25519 SSH key works
```

Then add the remote and push. Use the SSH URL if you set up an SSH key:

```bash
git remote add origin <REMOTE_REPO_URL>
git push -u origin feature/add-lab-notes
```

Validate:

```bash
git remote -v
```

Expected output:

```text
origin  <REMOTE_REPO_URL> (fetch)
origin  <REMOTE_REPO_URL> (push)
```

## Validation Checklist

Students should confirm:

- [ ] Git is installed
- [ ] Git name and email are configured
- [ ] Repository was initialized
- [ ] README file was created
- [ ] First commit was created
- [ ] Feature branch was created
- [ ] Second commit was created on feature branch
- [ ] `git log --oneline` shows commit history
- [ ] Optional remote push completed successfully

## Troubleshooting Tips

| Problem | What to Check | Fix |
|---|---|---|
| `not a git repository` | Are you inside the repo folder? | `cd week3-git-lab` |
| `Author identity unknown` | Git name/email missing | Configure `user.name` and `user.email` |
| Nothing to commit | File not changed or already committed | Edit file, run `git status` |
| Wrong branch | Run `git branch` | Use `git switch <branch>` (legacy: `git checkout <branch>`) |
| Push failed | Remote URL or auth issue | Check `git remote -v`; run `gh auth login` or verify SSH key |

## Cleanup Steps

Local cleanup:

```bash
cd ..
rm -rf week3-git-lab
```

Windows PowerShell:

```powershell
cd ..
Remove-Item -Recurse -Force week3-git-lab
```

Do not delete remote repositories unless the instructor tells you to.

## Reflection Questions

1. What does `git status` tell you?
2. What is the difference between `git add` and `git commit`?
3. Why should a team use branches?
4. Why is a clear commit message important?
5. How will Git help when you later work with Terraform or Kubernetes?

## Optional Challenge Task

Create a second branch from `main` using the modern verbs:

```bash
git switch main
git switch -c feature/add-troubleshooting-notes
```

Add a file:

```bash
echo "# Troubleshooting Notes" > troubleshooting.md
echo "Always start with git status." >> troubleshooting.md
```

Inspect, then commit it:

```bash
git diff
git add troubleshooting.md
git commit -m "Add Git troubleshooting notes"
```

Stretch goal: use `git restore` to practice undo. Make an edit, run `git diff` to
confirm it, then run `git restore troubleshooting.md` and confirm the edit is gone.

---

# 14. Troubleshooting Activity

## Incident Title

**Student Cannot Create a Git Commit**

## Business Impact

A junior cloud engineer is trying to commit Terraform documentation updates before opening a merge request. The commit fails, blocking the team from reviewing the change.

## Symptoms

Student runs:

```bash
git commit -m "Add README"
```

Error:

```text
Author identity unknown

Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

fatal: unable to auto-detect email address
```

## Starting Evidence

Students are given:

```bash
git status
```

Output:

```text
Changes to be committed:
  new file: README.md
```

And:

```bash
git config --global --list
```

Output does not show `user.name` or `user.email`.

## Student Investigation Steps

Students should:

1. Read the error message carefully.
2. Check Git configuration:

```bash
git config --global --list
```

3. Configure Git identity:

```bash
git config --global user.name "Student Name"
git config --global user.email "student@example.com"
```

4. Retry commit:

```bash
git commit -m "Add README"
```

5. Validate history:

```bash
git log --oneline
```

## Expected Root Cause

Git user identity was not configured.

## Correct Resolution

Set global Git username and email, then retry the commit.

## Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Reinstall Git | Git is installed. Configuration is missing |
| Delete the repo | The repo is not broken |
| Run `git push` | There is no commit to push yet |
| Change file permissions | This is not a permissions issue |
| Create another folder | The issue will follow the student until Git identity is configured |

## Instructor Hints

Start with:

```text
What does the error message ask you to configure?
```

Then:

```text
Which command shows your current Git config?
```

## Preventive Action

During future environment setup, students should always validate:

```bash
git config --global user.name
git config --global user.email
```

---

# 15. Scenario-Based Discussion Questions

## Question 1

Why should a cloud engineer commit Terraform changes instead of editing infrastructure manually in the AWS Console?

Expected response themes:

- Git creates history
- Review is possible
- Changes can be rolled back
- Team can audit changes
- Manual changes create drift

Follow-up prompt:

```text
What could go wrong if someone changes a production security group manually?
```

## Question 2

Why is a feature branch safer than working directly on main?

Expected response themes:

- Isolates work
- Prevents breaking stable code
- Supports review
- Allows testing before merge

Follow-up prompt:

```text
Should the main branch be protected in an enterprise repo?
```

## Question 3

What makes a good commit message?

Expected response themes:

- Clear
- Specific
- Describes what changed
- Helps future troubleshooting

Follow-up prompt:

```text
Which is better: "fix" or "Fix missing health check path in deployment manifest"?
```

## Question 4

Why should teams avoid committing secrets into Git?

Expected response themes:

- Security risk
- Secrets may be copied forever in history
- Credentials could be misused
- Rotation may be required

Follow-up prompt:

```text
What types of files should never be committed?
```

## Question 5

How does Git support CI/CD?

Expected response themes:

- Pipelines trigger from commits
- Branch rules control deployment
- Merge requests run validation
- Build and deployment history is traceable

Follow-up prompt:

```text
Why might a pipeline run on feature branches before code reaches main?
```

## Question 6

How can Git history help during an incident?

Expected response themes:

- Identify recent changes
- Link incident to deployment
- Review commits before failure
- Support rollback decisions

Follow-up prompt:

```text
What command shows recent commit history?
```

## Question 7

Why do DevOps, Cloud Engineering, and SRE all need Git?

Expected response themes:

- DevOps uses it for pipelines
- Cloud Engineering uses it for IaC
- SRE uses it for runbooks and automation
- All roles need change tracking

Follow-up prompt:

```text
Which files from your future labs should be stored in Git?
```

---

# 16. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

What does Git primarily help teams do?

A. Monitor CPU usage  
B. Track file changes over time  
C. Create AWS accounts  
D. Encrypt databases  

**Answer:** B  
**Explanation:** Git tracks changes to files and preserves history.

## Question 2: Multiple Choice

Which command shows the current state of your working directory?

A. `git log`  
B. `git status`  
C. `git push`  
D. `git clone`  

**Answer:** B  
**Explanation:** `git status` shows changed, staged, and untracked files.

## Question 3: Multiple Choice

What does `git add README.md` do?

A. Uploads the file to GitHub  
B. Deletes the file  
C. Stages the file for commit  
D. Creates a new branch  

**Answer:** C  
**Explanation:** `git add` moves changes into the staging area.

## Question 4: True or False

A commit is a saved snapshot of selected changes.

**Answer:** True  
**Explanation:** A commit records staged changes in local Git history.

## Question 5: True or False

Feature branches are useful because they allow engineers to isolate work before merging.

**Answer:** True  
**Explanation:** Branches reduce risk by keeping work separate from the main branch.

## Question 6: Short Answer

What is the modern command (Git 2.23+) that creates and switches to a new branch named `feature/update-readme`?

**Answer:**

```bash
git switch -c feature/update-readme
```

**Explanation:** `git switch -c` creates the branch and switches to it. The older
equivalent is `git checkout -b feature/update-readme`.

## Question 7: Short Answer

Why should commit messages be clear?

**Answer:**  
Clear commit messages help teammates understand what changed and help future troubleshooting.

## Question 8: Troubleshooting

A student runs `git commit -m "Add file"` and gets:

```text
Author identity unknown
```

What should they do?

**Answer:**

```bash
git config --global user.name "Student Name"
git config --global user.email "student@example.com"
```

**Explanation:** Git needs user identity before creating commits.

## Question 9: Troubleshooting

A student runs `git status` and sees:

```text
Untracked files:
  README.md
```

What should they do before committing?

**Answer:**

```bash
git add README.md
```

**Explanation:** The file must be staged before commit.

## Question 10: AWS-Related Question

How will Git be used later when working with AWS Terraform code?

A. To replace AWS IAM  
B. To track and review infrastructure code changes  
C. To automatically reduce AWS costs  
D. To create passwords  

**Answer:** B  
**Explanation:** Terraform code for AWS infrastructure should be stored and reviewed in Git.

## Question 11: AWS-Related Question

Why is Git important before changing AWS infrastructure?

**Answer:**  
Git creates an audit trail and supports review before changes affect cloud resources.

**Explanation:** This is critical for security, reliability, and change control.

---

# 17. Homework Assignment

## Assignment Title

**Git Local Workflow Reflection and Command Practice**

## Scenario

You joined a cloud platform team. Before working on Terraform, Kubernetes, or CI/CD repositories, your lead asks you to demonstrate that you understand the basic local Git workflow.

## Student Tasks

Students must:

1. Create a local Git repository.
2. Add a README file.
3. Commit the README.
4. Create a feature branch.
5. Add lab notes.
6. Commit the branch change.
7. Show Git history.
8. Write a short explanation of the workflow.

## Required Commands to Use

```bash
git init
git status
git add
git diff
git commit
git switch -c
git branch
git log --oneline
```

Legacy note: `git checkout -b` is the older equivalent of `git switch -c`. Use the
modern verbs in your submission.

## Expected Deliverables

Students submit:

1. Screenshot or copied terminal output for:
   - `git status`
   - `git branch`
   - `git log --oneline`

2. Short written answers:
   - What is a commit?
   - What is a branch?
   - What does `git add` do?
   - Why should teams avoid direct changes to main?

3. A list of 10 Git commands with one-line explanations.

## Submission Format

One of the following:

- Markdown file
- PDF
- Git repository link
- Text document

## Estimated Completion Time

45 to 60 minutes

## Grading Criteria

| Criteria | Points |
|---|---:|
| Repository created correctly | 20 |
| Commits created correctly | 20 |
| Branch created correctly | 15 |
| Command outputs included | 15 |
| Written explanations are clear | 20 |
| Git command list included | 10 |
| Total | 100 |

## Optional Advanced Challenge

Push the feature branch to GitHub or GitLab and submit the remote repository URL.

---

# 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Running Git commands in the wrong folder | Student is not comfortable with terminal navigation | Use `pwd`, `ls`, and `cd` before Git commands |
| Forgetting Git identity configuration | New Git installation | Run `git config --global user.name` and `user.email` |
| Thinking `git add` uploads files | Confusing staging with pushing | Explain local workflow visually |
| Committing directly to main | Student does not understand branch safety | Always create a feature branch first |
| Writing unclear commit messages | Beginner habit | Use action-based messages like `Add README` |
| Forgetting to stage before commit | Missing workflow step | Use `git status` before every commit |
| Pushing before adding a remote | Remote repo not configured | Run `git remote add origin <url>` |
| Using random folders for labs | Lack of workspace organization | Create a dedicated course workspace folder |
| Committing secrets | Students do not know Git history risk | Add a `.gitignore` from the start; if a secret is committed, ROTATE it first |
| Not reading error messages | Panic during CLI errors | Teach students to slow down and read the output |

---

# 19. Real-World Enterprise Scenario

## Scenario

A cloud platform team manages AWS infrastructure using Terraform. A junior engineer needs to update documentation for a VPC module before making actual code changes.

The team uses:

- GitLab for repositories
- Feature branches for changes
- Merge requests for review
- Protected main branch
- CI pipeline validation
- Jira ticket for tracking

## Constraints

| Constraint | Meaning |
|---|---|
| Access control | Only approved engineers can merge to main |
| Security | No credentials or secrets can be committed |
| Reliability | Bad infrastructure changes can affect production |
| Audit | The team must know who changed what and why |
| Cost | Unreviewed Terraform changes can create expensive resources |
| Team workflow | Changes must be reviewed before merge |

## What Each Role Would Do

| Role | Responsibility |
|---|---|
| DevOps Engineer | Creates branch, updates pipeline or Terraform code, opens merge request |
| Cloud Engineer | Reviews infrastructure design and AWS impact |
| SRE | Reviews operational risk, reliability, monitoring, and rollback impact |

## Enterprise Teaching Point

Git is not just a developer convenience. It is part of production change control.

---

# 20. Instructor Tips

## Teaching Tips

- Start with why Git matters before commands.
- Use diagrams frequently.
- Run `git status` after almost every command.
- Keep the first class focused on local workflow.
- Avoid overwhelming students with rebase, cherry-pick, stash, or advanced branching today.

## Pacing Tips

- Move slowly during the first demo.
- Expect students to struggle with folders and terminal paths.
- Leave enough time for troubleshooting.
- Do not rush remote push if students are still struggling locally.

## Lab Support Tips

Check these first when students are stuck:

```bash
pwd
ls
git status
git branch
git config --global --list
```

## Helping Struggling Students

Ask:

```text
What folder are you in?
What does git status say?
What branch are you on?
Did you stage the file?
Did Git give you an exact error?
```

## Challenging Advanced Students

Ask them to:

- Create multiple branches
- Add a `.gitignore`
- Push to remote
- Compare GitHub and GitLab PR/MR flow
- Write better commit messages
- Explain how Git triggers CI/CD

---

# 21. Student Outcome Checklist

## Students Should Be Able to Explain

- [ ] What Git is
- [ ] What a repository is
- [ ] What the working directory is
- [ ] What the staging area is
- [ ] What a commit is
- [ ] What a branch is
- [ ] Why main should be protected
- [ ] Why Git matters for DevOps, Cloud Engineering, and SRE

## Students Should Be Able to Build or Configure

- [ ] Configure Git username, email, and `init.defaultBranch=main`
- [ ] Create a local repository
- [ ] Create a README file
- [ ] Inspect a change with `git diff`
- [ ] Stage a file
- [ ] Commit a file
- [ ] Create a feature branch with `git switch -c`
- [ ] Add a `.gitignore` that excludes secrets and Terraform state
- [ ] Set up remote auth (`gh auth login` or `ed25519` SSH key)
- [ ] View branch list
- [ ] View commit history
- [ ] Push a branch to remote

## Students Should Be Able to Troubleshoot

- [ ] Missing Git identity
- [ ] Untracked files
- [ ] Nothing to commit
- [ ] Wrong folder
- [ ] Wrong branch
- [ ] Remote not configured
- [ ] Failed push due to authentication or remote issues

---

# 22. Class Completion Checklist

## Instructor Checklist Before Ending Class

- [ ] Students understand Git vs GitHub/GitLab
- [ ] Students completed at least one commit
- [ ] Students created a feature branch
- [ ] Students ran `git status`
- [ ] Students ran `git log --oneline`
- [ ] Students understand why branches matter
- [ ] Students understand homework expectations
- [ ] Students know Class 2 will cover PR/MR and conflicts

## Student Checklist Before Leaving Class

- [ ] I configured Git username and email
- [ ] I created a local Git repository
- [ ] I created and committed a README file
- [ ] I created a feature branch
- [ ] I committed a change on the feature branch
- [ ] I viewed my commit history
- [ ] I understand the difference between `git add`, `git commit`, and `git push`
- [ ] I know what to submit for homework

## Verify Before Moving to Class 2

Before Class 2, students should be comfortable with:

```text
git status
git add
git diff
git commit
git branch
git switch -c
git log --oneline
```

They should also understand this flow:

```text
Working Directory -> Staging Area -> Local Repository -> Remote Repository
```

Class 2 can then build naturally into:

```text
Feature Branch -> Push -> Pull Request or Merge Request -> Review -> Merge -> Conflict Resolution
```

---

# 23. Class Artifacts & Validation

Runnable, on-disk artifacts that back this class, from the shared module
[`labs/git-collaboration/`](../../labs/git-collaboration/). Class 1 teaches the local
workflow and the **secret-safety** habit (`.gitignore` + a `pre-commit` hook that
refuses to commit AWS keys / private keys / large files). The hook and its installer
are the runnable files behind that teaching; the conflict scenario and Conventional
Commits hook are exercised in Class 2. All rows are validated by the module's own
`validate.sh` (10/10 gates pass in this environment: `bash 5.x`, `git 2.34`).

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/git-collaboration/solution/hooks/pre-commit | bash hook | `pre-commit` that blocks staged AWS keys / PEM private keys / files > 5 MB — the runnable backstop for Class 1's `.gitignore` + secret-safety lesson | `bash -n solution/hooks/pre-commit` (syntax) and `bash tests/test_hooks.sh` (behaviour) | PASS — `10 passed, 0 failed` via `./validate.sh` |
| 2 | labs/git-collaboration/solution/install-hooks.sh | bash | Symlinks the hooks into a repo's `.git/hooks/` so secret-blocking is active on commit | `bash -n solution/install-hooks.sh`; behaviour covered by `tests/test_hooks.sh` (`install-hooks symlinks pre-commit and commit-msg`) | PASS — via `./validate.sh` |
| 3 | labs/git-collaboration/tests/test_hooks.sh | bash tests | Black-box behaviour tests proving the hook blocks a crafted `AKIA…` secret and a > 5 MB file while a clean commit succeeds | `bash tests/test_hooks.sh` | PASS — `9 passed, 0 failed` |
| 4 | labs/git-collaboration/validate.sh | bash | Module gate runner: `bash -n` on every script/hook + the behaviour tests | `./validate.sh` | PASS — `== 10 passed, 0 failed ==` |
| 5 | labs/git-collaboration/README.md | docs | Prerequisites, architecture, validation, expected output, troubleshooting, cleanup, security and cost notes for the module | n/a (documentation) | Present — Status banner: Validated |

Notes:
- `shellcheck` and `gitleaks` are documented as DEFERRED in the lab README. `shellcheck`
  **is** installed in this build (`0.10.0`) and passes clean on the solution scripts;
  `gitleaks` is not installed. The local gates (`bash -n` + behaviour tests) are the
  required substitute and they pass.
- No live cloud operation is involved — this is local `bash` + `git` only ($0, no
  network). There is therefore no `LIVE-*EVIDENCE*` file for this module; the PASS
  evidence is the static `validate.sh` run above.

---

# 24. Definition of Done

Ticked honestly for **Class 1** against the shared module
[`labs/git-collaboration/`](../../labs/git-collaboration/) (artifact standard §5):

- [x] Every technology taught ships at least one **runnable file on disk** — the
      `pre-commit`/`install-hooks.sh` bash files exist on disk (not just fenced); the
      `git` commands themselves are CLI usage, not authored artifacts.
- [x] Each artifact passes its **validation gate** — `./validate.sh` → `10 passed, 0 failed`; output captured in §23.
- [x] Lab has **starter** (intentionally incomplete `TODO(student)` gaps) and **solution** (reference) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, and cost notes.
- [x] **Cleanup/teardown** is provided and idempotent — `rm -rf` of the `--dir`/`--target` paths; tests/validate use `mktemp` + trap.
- [x] **Instructor answer key** exists — module README "Instructor answer key" section plus `solution/`; this class file has a Knowledge-Check answer key (§16) and homework grading rubric (§17).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — §14 reproduces the `Author identity unknown` failure with exact symptoms and fix; the lab's `setup-scenario.sh` is a deterministic injected-fault fixture.
- [x] **Expected outputs** are shown for every demo and lab step (e.g. `git status`, `git log --oneline`, `.gitignore` suppressing `.env`).
- [x] **Cost & security warnings** present — secret-handling guidance (rotate-first), "never commit `*.pem`/keys/`.tfstate`", and an explicit $0 cost note in the module.
- [x] **Cross-references** verified — links to `labs/git-collaboration/`, the course's artifact standard, and forward refs (Week 2 ed25519 key, Weeks 11–13 GitOps, Class 2) resolve.
- [x] The **artifact manifest** (§23) is present and every path resolves (`ls`-verified).

Honest scope note: this class is **Practiced**, not Mastered. The lab is static-validated
(shell syntax + behaviour tests) with starter/solution and an answer key, but performs no
live cloud operation and is not yet reused/operated in a later week or the capstone.
