# Week 3: Git, Git Workflows, and Collaboration
> **▶ Runnable lab for this class:** [`labs/git-collaboration/`](../../labs/git-collaboration/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 2 Package: Branching, Pull Requests, Collaboration, and Conflict Resolution

**Week:** 3
**Class:** 2
**Track:** Unified DevOps · Cloud · SRE Track

---

# 1. Class Overview

## Class Title

**Class 2: Pull Requests, Merge Requests, Code Review, and Merge Conflict Resolution**

## Class Purpose

This class teaches students how Git becomes a team collaboration tool. Class 1 focused on the local workflow: edit, stage, commit, branch, and push. Class 2 extends that workflow into real team practices: pull requests, merge requests, peer review, protected branches, and resolving merge conflicts.

## How This Class Builds From Class 1

Class 1 taught students how to work locally:

```text
Working Directory -> Staging Area -> Local Repository -> Remote Repository
```

Class 2 teaches students what happens after they push a branch:

```text
Feature Branch -> Push -> Pull Request or Merge Request -> Review -> Merge -> Conflict Resolution
```

This is the workflow students will later use for:

- Terraform infrastructure changes
- CI/CD pipeline updates
- Kubernetes YAML changes
- Helm chart updates
- Runbook and automation script changes
- Production support documentation

## What Students Will Build, Analyze, or Practice

Students will practice:

- Creating a feature branch
- Pushing a branch to GitHub or GitLab
- Opening a pull request or merge request
- Writing a useful PR/MR description
- Reviewing file changes
- Configuring branch protection and a CODEOWNERS file
- Comparing merge, rebase, and squash; using `git pull --rebase` and `--force-with-lease`
- Resolving a merge conflict in an editor (VS Code / `git mergetool`)
- Understanding GitOps and trunk-based development at an awareness level
- Recovering from common Git workflow mistakes

---

# 2. Quick Review of Class 1

## Review Points

1. Git tracks changes to files over time.
2. A repository is a folder managed by Git.
3. `git status` shows the current state of the working directory.
4. `git add` stages changes.
5. `git commit` saves staged changes to local history.
6. A branch isolates work from the main branch.
7. `git push` sends local commits to the remote repository.
8. Clear commit messages help teammates understand the change.

## Quick Recall Questions

### Question 1

What command shows which branch you are currently on?

**Expected answer:**

```bash
git branch
```

### Question 2

What is the difference between `git add` and `git commit`?

**Expected answer:**  
`git add` stages changes. `git commit` saves staged changes to local Git history.

### Question 3

Why do teams use feature branches?

**Expected answer:**  
Feature branches isolate work so changes can be reviewed and tested before merging into the main branch.

## Common Gaps Students May Still Have From Class 1

| Gap | What It Looks Like | Instructor Response |
|---|---|---|
| Confusing Git with GitHub/GitLab | Students think Git only works online | Explain Git is local, GitHub/GitLab host remote repos |
| Forgetting to stage files | `nothing to commit` appears | Reinforce `git status`, then `git add` |
| Working in the wrong folder | `not a git repository` appears | Have students run `pwd`, `ls`, and `git status` |
| Not understanding branches | Students commit directly to main | Re-explain branch safety before team workflow |
| Weak commit messages | Messages like `update` or `fix` | Show better examples tied to real work |

## Bridge Into Class 2

Instructor transition:

```text
In Class 1, you learned how to create and commit changes locally. Today, we move into the team workflow. In real DevOps and cloud teams, your branch does not usually go straight into main. You push it, open a pull request or merge request, get review, pass checks, resolve conflicts if needed, and then merge safely.
```

---

# 3. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** how pull requests and merge requests support team collaboration.
2. **Compare** local Git workflow with team-based Git workflow.
3. **Create** a feature branch and push it to a remote repository.
4. **Build** a pull request or merge request with a clear title and description.
5. **Validate** file changes before requesting review.
6. **Compare** merge, rebase, and squash-merge, and use `git pull --rebase` and `--force-with-lease`.
7. **Configure** branch protection and a CODEOWNERS file on a test repository.
8. **Resolve** a merge conflict in an editor (VS Code / `git mergetool`).
9. **Explain** GitOps and trunk-based development at an awareness level.
10. **Document** a safe Git workflow for Terraform, Kubernetes, or CI/CD changes.

---

# 4. Prerequisites Students Should Already Know

## Required Class 1 Knowledge

Students should already know:

- What Git is
- What a repository is
- What a branch is
- How to run `git status`
- How to stage files with `git add`
- How to commit files with `git commit`
- How to create a branch with `git switch -c` (legacy: `git checkout -b`)
- How to inspect changes with `git diff`
- How to view commit history with `git log --oneline`
- How a `.gitignore` keeps secrets and Terraform state out of the repo

## Required Prior Concepts

Students should understand:

- Basic terminal navigation
- Basic file editing
- Why teams review technical changes
- Why direct changes to production-related code are risky

## Required Tools Already Installed

Students need:

- Git
- VS Code or another text editor
- Terminal
- Browser
- GitHub or GitLab account

## Required Files, Repos, or Setup From Class 1

Students should have one of the following:

Option 1, from Class 1:

```text
week3-git-lab/
  README.md
```

Option 2, instructor-provided starter repo:

```text
week3-team-workflow/
  README.md
  environment.txt
```

Recommended starting files:

```markdown
# Week 3 Team Git Workflow

This repository is used to practice pull requests, merge requests, code review, and merge conflict resolution.
```

```text
Environment: development
```

---

# 5. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Pull Request | A request to merge changes from one branch into another, commonly used in GitHub | Used for code review before changes reach main |
| Merge Request | GitLab’s term for pull request | Common in DevOps teams using GitLab CI/CD |
| Code Review | A teammate checks your changes before they are merged | Helps catch mistakes before production impact |
| Reviewer | Person responsible for reviewing the change | Usually a senior engineer, peer, or code owner |
| Protected Branch | A branch that blocks direct pushes | Used to protect main or production branches |
| Merge | Combining changes from one branch into another | Usually happens after review and approval |
| Merge Conflict | Git cannot automatically combine changes | Requires a human to decide the correct final content |
| Conflict Marker | Text Git adds to show conflicting sections | Must be removed before completing the merge |
| Approval | Required sign-off before merge | Supports governance and safer changes |
| Audit Trail | History of who changed what, when, and why | Important for infrastructure, security, and incidents |
| Branch Strategy | Rules for how teams create, name, and merge branches | Helps teams keep work organized |
| Main Branch | Primary stable branch | Often tied to production or deployable code |
| Merge commit | A commit that joins two branches and keeps both histories | Default GitHub/GitLab merge; preserves the full branch graph |
| Rebase | Replays your commits on top of the latest target branch | Produces a clean, linear history; rewrites commit IDs |
| Squash merge | Combines all PR commits into one commit on merge | Keeps `main` history tidy: one commit per change |
| Linear history | A `main` with no merge commits, just a straight line | Common required policy; easier to read, bisect, and revert |
| Fast-forward | Moving a branch pointer forward with no merge commit | Possible when the target has not advanced |
| `--force-with-lease` | A safe force-push that aborts if the remote moved | The senior-safe alternative to `--force` after a rebase |
| CODEOWNERS | A file mapping paths to required reviewers | Auto-requests the right team (e.g. SRE for `/runbooks`) on a PR |
| Branch protection | Repo rules that gate merges into a branch | Require reviews, passing checks, linear history, no direct push |
| GitOps | Git as the source of truth a controller reconciles | Argo CD / Flux make the cluster match the repo (W11–W13) |
| Trunk-based development | Short-lived branches merged frequently into `main` | The dominant 2026 strategy for CI/CD-heavy teams |

---

# 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| Git | Used for branch, commit, merge, rebase, and conflict resolution |
| GitHub or GitLab | Used to create PRs/MRs and configure branch protection + CODEOWNERS |
| `gh` (GitHub CLI) | Authenticates and manages PRs from the terminal |
| Terminal | Used to run Git commands |
| VS Code | Used to edit files and resolve conflicts in its 3-way merge UI |
| `git mergetool` | Launches a configured merge tool for conflict resolution |
| Browser | Used to review branch changes, PR/MR status, and protection settings |

## Tool Notes

GitHub uses the term:

```text
Pull Request
```

GitLab uses the term:

```text
Merge Request
```

For this class, students should understand that both serve the same core purpose:

```text
Request review before merging changes into another branch.
```

---

# 7. AWS Services Used

No AWS resources are required for this class.

However, AWS is used as the real-world context for why PR/MR workflows matter.

| AWS-Related Future Work | Why PR/MR Matters |
|---|---|
| Terraform VPC changes | Incorrect routes or CIDRs can break connectivity |
| IAM policy changes | Overly broad permissions can create security risk |
| EKS manifests | Bad deployment YAML can break applications |
| CI/CD pipelines | Bad pipeline logic can deploy broken code |
| CloudWatch alerts | Bad alert thresholds can create noise or miss incidents |
| S3 bucket policy changes | Bad policy can expose or block data |

## AWS Teaching Point

In enterprise AWS environments, teams should not make infrastructure changes directly on the main branch. A pull request or merge request creates a review point before cloud changes are applied.

---

# 8. Azure and GCP Comparison Notes

Keep this section short.

| Platform | Git Workflow Usage |
|---|---|
| AWS | GitHub, GitLab, CodeCommit, or external Git tools commonly trigger Terraform and deployment pipelines |
| Azure | Azure Repos and GitHub integrate with Azure DevOps Pipelines |
| GCP | GitHub, GitLab, and Cloud Source workflows can trigger Cloud Build |

Key message:

```text
The PR/MR workflow is cloud-agnostic. Whether the target platform is AWS, Azure, or GCP, teams still need review, audit, approval, and safe merge practices.
```

---

# 9. Time-Boxed Instructor Agenda

| Time | Section | Activity |
|---:|---|---|
| 0:00 to 0:15 | Class 1 Review | Review Git local workflow and branch basics |
| 0:15 to 0:32 | Team Workflow Concepts | PRs, MRs, code review, protected branches |
| 0:32 to 0:52 | History & Strategy | Merge vs rebase vs squash, linear history, `pull --rebase`, `--force-with-lease`, GitOps, trunk-based |
| 0:52 to 1:18 | Instructor Demo Part 1 | Push branch, open PR/MR, branch protection + CODEOWNERS |
| 1:18 to 1:28 | Break | Short break |
| 1:28 to 1:55 | Instructor Demo Part 2 | Create and resolve a merge conflict in the editor; rebase + `--force-with-lease` |
| 1:55 to 2:35 | Student Lab | Create PR/MR, resolve a conflict in VS Code, optional rebase/protection |
| 2:35 to 2:50 | Troubleshooting Activity | Failed push, conflict markers, accidental main commit |
| 2:50 to 2:58 | Discussion and Quiz | Scenario-based discussion and quick knowledge check |
| 2:58 to 3:00 | Wrap-Up | Homework and Week 3 completion summary |

---

# 10. Instructor Lesson Plan

## Step 1: Review Local Workflow

Start by drawing the Class 1 flow:

```text
Working Directory -> Staging Area -> Local Repository -> Remote Repository
```

Ask:

```text
What command moves a file into the staging area?
```

Expected answer:

```bash
git add
```

Ask:

```text
What command saves staged changes into local history?
```

Expected answer:

```bash
git commit
```

Transition:

```text
Now we will focus on what happens after your branch reaches the remote repository.
```

## Step 2: Explain Team Workflow

Show the team workflow:

```text
Feature Branch -> Push -> PR/MR -> Review -> Approval -> Merge
```

Explain:

- A PR/MR is not just a button.
- It is a communication and review process.
- It helps teams avoid unsafe changes.
- It becomes part of the audit history.

## Step 3: Explain Pull Request vs Merge Request

Say:

```text
GitHub calls it a pull request. GitLab calls it a merge request. The idea is the same: you are asking the team to review and merge your branch.
```

## Step 3b: Explain How Teams Shape History

Before the demo, cover the team-strategy vocabulary (full detail in the lecture notes):

- Merge commit vs rebase vs squash-merge, and what each does to `main` history.
- Linear history as a common required policy.
- `git pull --rebase` instead of plain `git pull`.
- `git push --force-with-lease` as the only acceptable force-push, on your own branch.
- GitOps awareness: Git is the source of truth a controller reconciles (W11–W13).
- Trunk-based development vs GitFlow.

Pause and ask:

```text
If your team wanted a clean, linear main, would you pick merge commits, rebase, or squash? Why?
```

## Step 4: Explain Code Review

Cover what reviewers look for:

- Does the change solve the right problem?
- Is anything risky?
- Are secrets included accidentally?
- Is the naming clear?
- Is the change too large?
- Are tests or validation included?
- For Terraform, is the plan safe?
- For Kubernetes, are probes, ports, and selectors correct?

## Step 5: Instructor Demo, PR/MR

Demonstrate:

1. Create feature branch.
2. Edit file.
3. Commit change.
4. Push branch.
5. Open PR/MR.
6. Write title and description.
7. Review diff.
8. Discuss approval.

Pause for questions after showing the file diff.

## Step 6: Explain Merge Conflicts

Say:

```text
A merge conflict happens when Git cannot decide how to combine two changes. Git is not broken. Git is asking a human to choose the correct final version.
```

Show conflict markers:

```text
<<<<<<< HEAD
Environment: development
=======
Environment: staging
>>>>>>> feature/change-environment
```

Explain each part.

## Step 7: Instructor Demo, Conflict Resolution

Demonstrate a simple conflict with `environment.txt`.

Pause before resolving and ask:

```text
Which line should we keep and why?
```

## Step 8: Student Lab

Students create their own branch, push, open PR/MR, then resolve a conflict.

Instructor should support students with:

```bash
git status
git branch
git log --oneline
git remote -v
```

## Step 9: Troubleshooting Activity

Use the incident-style activity to reinforce real-world problem-solving.

## Step 10: Close the Week

End by connecting Git to Week 4:

```text
Next week we move into AWS Cloud Foundations. Git will continue to matter because cloud teams store scripts, Terraform, diagrams, and infrastructure notes in Git.
```

---

# 11. Instructor Lecture Notes

## Opening Talking Point

“Class 1 taught you how to work with Git locally. Today we move into the team workflow. In real DevOps and cloud teams, your change usually does not go straight into main. It goes through review.”

## Why PR/MR Workflows Matter

A pull request or merge request creates a formal checkpoint.

It answers:

- What changed?
- Why did it change?
- Who made the change?
- Who reviewed it?
- Did validation pass?
- Is it safe to merge?

In enterprise teams, this matters because one small change can affect:

- Production access
- Infrastructure cost
- Security permissions
- Application uptime
- Customer traffic
- Compliance and audit requirements

## Git Review Is Part of Change Control

For DevOps, Cloud Engineering, and SRE roles, Git review is not optional best practice. It is often part of operational control.

Examples:

```text
Terraform change to a security group
Kubernetes deployment update
CI/CD deployment rule change
IAM policy update
Monitoring alert threshold change
Runbook update after an incident
```

## Common Misconception: “The PR/MR Is Just for Developers”

Correction:

```text
Infrastructure engineers, platform engineers, DevOps engineers, and SREs use pull requests and merge requests every day.
```

## What Makes a Good PR/MR

A good PR/MR should include:

```text
Clear title
Short summary
Reason for change
Validation performed
Risk or rollback notes
Screenshots or command output if useful
Linked ticket if applicable
```

Example strong title:

```text
Add Git workflow notes for Week 3 lab
```

Weak title:

```text
update
```

## Merge Conflict Explanation

A merge conflict is not always bad. It means Git found overlapping changes and needs a human decision.

Say:

```text
Git can merge many changes automatically, but it cannot understand business intent. If two engineers edit the same line differently, Git asks us to choose the correct result.
```

## Enterprise Context

In a Terraform repository, conflict resolution must be handled carefully.

Example:

One engineer changes:

```hcl
instance_type = "t3.micro"
```

Another engineer changes:

```hcl
instance_type = "t3.medium"
```

Git cannot know whether the correct answer is cost savings or higher performance. A human must understand the requirement.

## Talking Point for Students

“When resolving conflicts, do not just delete markers randomly. Understand the desired final state.”

## Merge vs Rebase vs Squash: How Teams Shape History

Every team makes a choice about what `main` history looks like. There is no single
right answer, but a senior engineer must be able to explain the tradeoffs.

```text
MERGE COMMIT (default)
  - git merge feature  (or "Create a merge commit" in the PR UI)
  - Keeps every commit AND adds a commit that joins the two branches.
  - History shows the true branch graph, but can get noisy with many merges.

REBASE
  - git rebase main  (run on your feature branch)
  - Replays YOUR commits on top of the latest main, as if you started today.
  - Produces a clean, linear history. NO merge commit.
  - Trade-off: it REWRITES your commit IDs, so only rebase commits that have
    not been shared, or coordinate before force-pushing a shared branch.

SQUASH MERGE
  - "Squash and merge" in the PR UI.
  - Collapses all the commits in the PR into ONE commit on main.
  - Most popular default in 2026: one clean commit per change/PR, easy to revert.
```

Talking point:

```text
"Ask in an interview: how does your team handle history? The strong answer names
the policy — usually squash-merge with a required linear history on main — and
explains why: a readable main, one revert per change, and clean git bisect."
```

## `git pull` Is `fetch` + Merge — Prefer `--rebase`

A plain `git pull` does a fetch and then a MERGE, which creates little merge commits
on your own branch and is the usual source of the "messy history" students complain
about. Configure pull to rebase instead:

```bash
# One-time global setting (recommended):
git config --global pull.rebase true

# Or per-pull:
git pull --rebase origin main
```

```text
With --rebase, your local commits are replayed on top of the latest remote work,
keeping a straight line instead of a tangle of merge commits.
```

## Force-Pushing Safely: `--force-with-lease`

After a rebase, your local history no longer matches the remote, so a normal push
is rejected. The dangerous fix is `git push --force`, which can silently overwrite
a teammate's commits. The senior-safe command is:

```bash
git push --force-with-lease
```

```text
--force-with-lease refuses to push if the remote branch moved since you last
fetched it — i.e. if a teammate pushed in the meantime. It protects their work.
RULE: never use plain --force on a shared branch. Use --force-with-lease, and only
on branches you own (your own feature branch / PR branch), never on main.
```

## GitOps: Git as the Source of Truth

```text
The PR/MR workflow you are learning is the front door to modern delivery. In GitOps,
Git is not just a record — it is the SOURCE OF TRUTH. A controller such as Argo CD
or Flux continuously watches a repo and makes the live Kubernetes cluster match
what is committed. You change production by merging a PR, and the controller
reconciles the cluster to the new desired state. The review, approval, and history
discipline in this class is exactly what makes GitOps safe. You will see this in
Weeks 11–13 (Kubernetes and Helm).
```

## Team Strategy: Trunk-Based vs GitFlow

```text
TRUNK-BASED DEVELOPMENT (dominant in 2026)
  - Short-lived feature branches, merged into main frequently (often daily).
  - main is always releasable; CI runs on every PR.
  - Pairs naturally with squash-merge + linear history and continuous deployment.

GITFLOW (older, heavier)
  - Long-lived develop/release/hotfix branches alongside main.
  - More ceremony; useful for versioned/desktop releases, rarely for cloud services.

This course teaches a LIGHT trunk-based model: branch, PR, review, squash-merge,
delete the branch. Name the tradeoff so students recognize both in interviews.
```

---

# 12. Whiteboard Explanation

## Class 1 to Class 2 Flow

```text
Class 1:
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
Remote Branch
```

```text
Class 2:
Remote Branch
   |
   v
Pull Request / Merge Request
   |
   v
Review + Comments + Checks
   |
   v
Approval
   |
   v
Merge to Main
```

## Simple Team Workflow Diagram

```text
Engineer Laptop
   |
   | create feature branch
   v
feature/update-docs
   |
   | commit changes
   v
Local Git History
   |
   | push branch
   v
Remote Repository
   |
   | open PR/MR
   v
Code Review
   |
   | approval
   v
main branch
```

## Merge Conflict Diagram

```text
main branch:
environment.txt
Environment: development

feature branch:
environment.txt
Environment: staging

Git sees same file, same line, different content.

Result:
Conflict must be resolved manually.
```

## Enterprise Version

```text
Jira Ticket
   |
   v
Feature Branch
   |
   v
Commit Terraform / YAML / Pipeline Change
   |
   v
Push Branch
   |
   v
Merge Request
   |
   v
Automated Checks
   |
   v
Peer Review
   |
   v
Approval
   |
   v
Merge to Main
   |
   v
Pipeline Deploys or Applies Change
```

## Component Meaning

| Component | Meaning |
|---|---|
| Jira Ticket | Business or technical request |
| Feature Branch | Safe workspace for changes |
| Commit | Traceable unit of change |
| Push | Shares branch with team |
| PR/MR | Request for review |
| Automated Checks | CI/CD validation |
| Approval | Human review checkpoint |
| Merge | Accepted into main branch |
| Pipeline | Executes deployment or infrastructure workflow |

---

# 13. Instructor Demo Script

## Demo Title

**Open a Merge Request and Resolve a Merge Conflict**

## Demo Objective

Show students how a feature branch becomes a reviewed team change, and how to resolve a basic merge conflict.

## Required Setup

Instructor needs:

- Git installed
- GitHub or GitLab repository
- Terminal
- VS Code
- Browser logged into GitHub or GitLab

Recommended repo:

```text
week3-team-workflow-demo
```

Recommended initial file:

```text
environment.txt
```

Initial content:

```text
Environment: development
```

---

## Demo Part A: Create a Branch and Open a PR/MR

### Step 1: Clone or Enter Repo

```bash
git clone <REMOTE_REPO_URL>
cd week3-team-workflow-demo
```

Expected output:

```text
Cloning into 'week3-team-workflow-demo'...
```

If repo already exists:

```bash
cd week3-team-workflow-demo
git switch main
git pull --rebase
```

Explain:

```text
We start from the latest main branch so our feature branch is based on current work.
```

### Step 2: Create a Feature Branch

```bash
git switch -c feature/update-team-workflow-docs
```

Expected output:

```text
Switched to a new branch 'feature/update-team-workflow-docs'
```

Explain:

```text
This branch isolates our work from main.
```

### Step 3: Edit README

```bash
echo "" >> README.md
echo "## Team Git Workflow" >> README.md
echo "Changes should be made in feature branches and reviewed through pull requests or merge requests." >> README.md
```

### Step 4: Check Status

```bash
git status
```

Expected output:

```text
modified: README.md
```

Explain:

```text
Git sees that README.md changed.
```

### Step 5: Stage and Commit

```bash
git add README.md
git commit -m "Add team Git workflow notes"
```

Expected output:

```text
1 file changed
```

### Step 6: Push Branch

```bash
git push -u origin feature/update-team-workflow-docs
```

Expected output:

```text
branch 'feature/update-team-workflow-docs' set up to track 'origin/feature/update-team-workflow-docs'
```

Explain:

```text
The branch now exists on the remote platform, where the team can review it.
```

### Step 7: Open PR/MR in Browser

In GitHub:

- Click **Compare & pull request**
- Add title
- Add description
- Review files changed
- Create pull request

In GitLab:

- Click **Create merge request**
- Add title
- Add description
- Review changes
- Create merge request

Recommended title:

```text
Add team Git workflow notes
```

Recommended description:

```text
Summary:
- Added notes explaining feature branch workflow
- Documented why PR/MR review matters

Validation:
- Ran git status
- Reviewed file diff locally
- Confirmed branch pushed successfully

Risk:
- Documentation-only change
```

Explain:

```text
A good PR/MR description helps reviewers understand the change quickly.
```

---

## Demo Part B: Create and Resolve a Merge Conflict

### Step 1: Prepare Main

```bash
git switch main
git pull --rebase
echo "Environment: development" > environment.txt
git add environment.txt
git commit -m "Add environment file"
git push
```

Explain:

```text
This creates a file on main that we will intentionally edit in conflicting ways.
```

### Step 2: Create Feature Branch

```bash
git switch -c feature/change-environment-to-staging
echo "Environment: staging" > environment.txt
git add environment.txt
git commit -m "Change environment to staging"
```

### Step 3: Change Same File on Main

```bash
git switch main
echo "Environment: production" > environment.txt
git add environment.txt
git commit -m "Change environment to production"
```

### Step 4: Try to Merge Feature Branch

```bash
git merge feature/change-environment-to-staging
```

Expected output:

```text
CONFLICT (content): Merge conflict in environment.txt
Automatic merge failed; fix conflicts and then commit the result.
```

Explain:

```text
Git cannot decide whether the environment should be production or staging.
```

### Step 5: Open Conflict File

```bash
cat environment.txt
```

Expected output:

```text
<<<<<<< HEAD
Environment: production
=======
Environment: staging
>>>>>>> feature/change-environment-to-staging
```

Explain:

- `HEAD` means current branch, main.
- The section below `=======` is from the branch being merged.
- The markers must be removed.
- The final file should contain only the correct final value.

### Step 6: Resolve Conflict (Editor — How It Is Really Done)

Resolve the conflict in an editor so students see the markers and choose deliberately.
This is how almost everyone resolves conflicts in real work — not by overwriting from
the terminal.

Open the file in VS Code:

```bash
code environment.txt
```

VS Code shows a 3-way merge UI above the conflict with clickable actions:

```text
Accept Current Change   -> keeps the HEAD (main) side
Accept Incoming Change  -> keeps the feature-branch side
Accept Both Changes     -> keeps both, in order
Compare Changes         -> shows a side-by-side diff
```

For this demo, click **Accept Incoming Change** so the file becomes:

```text
Environment: staging
```

Make sure NO conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) remain, then save.

Command-line / IDE-agnostic alternative — `git mergetool`:

```bash
git mergetool        # opens your configured merge tool (vimdiff, VS Code, etc.)
```

Terminal shortcut (only when you are certain you want one whole side):

```bash
git checkout --theirs environment.txt   # take the incoming (feature) version
# git checkout --ours environment.txt    # take the current (main) version
```

```text
Teaching point: prefer the editor. "echo final > file" works but trains students
to OVERWRITE rather than MERGE. Real conflicts often need lines from BOTH sides,
which you can only judge by reading the markers in an editor.
```

### Step 7: Complete Merge

```bash
git add environment.txt
git commit -m "Resolve environment merge conflict"
```

Expected output:

```text
Resolved merge conflict
```

### Step 8: Validate History

```bash
git log --oneline --graph --all
```

Expected output example:

```text
*   abc1234 Resolve environment merge conflict
|\
| * def5678 Change environment to staging
* | ghi9012 Change environment to production
|/
* jkl3456 Add environment file
```

Explain:

```text
The graph helps us see branches and merge history.
```

---

## Demo Part C: Rebase a Branch and Push Safely

Show students the alternative to a merge commit: rebasing a feature branch onto the
latest `main` for a linear history.

```bash
# On a feature branch that is behind main:
git switch feature/update-team-workflow-docs
git fetch origin
git rebase origin/main
```

If the rebase hits a conflict, Git pauses:

```text
CONFLICT (content): Merge conflict in README.md
error: could not apply <hash>... <commit message>
```

Resolve it in the editor (same markers as a merge), then continue:

```bash
git add README.md
git rebase --continue
# (or "git rebase --abort" to bail out and return to the pre-rebase state)
```

Because rebase rewrote the branch's commit IDs, a normal push is rejected. Push
safely:

```bash
git push --force-with-lease
```

Explain:

```text
--force-with-lease updates YOUR feature branch and aborts if a teammate pushed to
it since your last fetch. Never use plain --force, and never force-push main.
```

## Demo Part D: Configure Branch Protection and CODEOWNERS

Governance the course keeps invoking should actually be configured, not just described.

Add a CODEOWNERS file so the right reviewers are auto-requested on every PR:

```bash
mkdir -p .github
cat > .github/CODEOWNERS <<'EOF'
# Default owners for everything in the repo
*               @your-org/platform-team

# Infrastructure code requires a cloud reviewer
/terraform/     @your-org/cloud-team

# Runbooks require SRE review
/runbooks/      @your-org/sre-team
EOF

git add .github/CODEOWNERS
git commit -m "Add CODEOWNERS for required reviewers"
git push
```

Then enable branch protection on `main` in the platform UI:

```text
GitHub: Repo > Settings > Branches > Add branch ruleset (or protection rule) for "main":
  [x] Require a pull request before merging
  [x] Require approvals (1+)
  [x] Require review from Code Owners
  [x] Require status checks to pass before merging
  [x] Require linear history        (forces squash/rebase, blocks merge commits)
  [x] Do not allow bypassing the above (block direct pushes to main)

GitLab: Settings > Repository > Protected branches: protect "main",
  set "Allowed to merge = Maintainers", "Allowed to push = No one",
  and require approvals under Settings > Merge requests.
```

Validate that direct pushes to main are now blocked:

```bash
git switch main
echo "direct edit" >> README.md
git commit -am "Try a direct push to main"
git push
```

Expected output (push is rejected):

```text
remote: error: GH006: Protected branch update failed for refs/heads/main.
remote: error: Required status check ... / Changes must be made through a pull request.
```

Recover by undoing the local direct commit and routing it through a PR instead:

```bash
git reset --soft HEAD~1   # keep the change, drop the commit
git switch -c fix/readme-note
git commit -am "Add README note via PR"
git push -u origin fix/readme-note
```

---

## Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| Push rejected | Remote has changes not local | Run `git pull`, resolve conflicts, push again |
| Cannot open PR/MR | Branch was not pushed | Run `git push -u origin <branch>` |
| Authentication fails | HTTPS password auth is dead; no key/login set up | Run `gh auth login` or verify the `ed25519` SSH key (see Class 1, Demo Part 9) |
| No conflict appears | Files or lines were not changed in both branches | Recreate conflict by editing same line |
| Conflict markers left in file | Student did not fully resolve conflict | Reopen file and remove markers |
| Wrong branch | Demo is on incorrect branch | Run `git branch`, then checkout correct branch |

## Cleanup Steps

Local cleanup:

```bash
cd ..
rm -rf week3-team-workflow-demo
```

Windows PowerShell:

```powershell
cd ..
Remove-Item -Recurse -Force week3-team-workflow-demo
```

Remote cleanup:

- Delete demo branch after merge
- Do not delete shared class repo unless no longer needed

Security warning:

```text
Never commit AWS keys, GitHub tokens, passwords, private SSH keys, or secrets into Git.
```

---

# 14. Student Lab Manual

## Lab Title

**Team Git Workflow With PR/MR and Merge Conflict Resolution**

## Lab Objective

Practice the team Git workflow used by DevOps, Cloud Engineering, and SRE teams.

## Estimated Time

40 minutes

## Student Prerequisites

Students need:

- Completed Class 1 local Git workflow
- Git installed
- GitHub or GitLab account
- A remote repository
- Basic knowledge of branch, commit, and push

## Starting Point From Class 1

Students should have:

```text
week3-git-lab/
  README.md
```

They should already know:

```bash
git status
git add
git commit
git checkout -b
git log --oneline
```

## Workflow Overview

```text
Start from main
Create feature branch
Edit file
Commit change
Push branch
Open PR/MR
Review diff
Create conflict
Resolve conflict
Validate final result
```

---

## Part 1: Prepare Your Repository

### Step 1: Go to Your Repo

```bash
cd week3-git-lab
```

Check:

```bash
git status
```

Expected output:

```text
On branch main
nothing to commit, working tree clean
```

If you are not on main:

```bash
git switch main
```

## Part 2: Create a Feature Branch

```bash
git switch -c feature/add-team-workflow-notes
```

(Legacy equivalent you may still see: `git checkout -b feature/add-team-workflow-notes`.)

Expected output:

```text
Switched to a new branch 'feature/add-team-workflow-notes'
```

Validate:

```bash
git branch
```

Expected output:

```text
* feature/add-team-workflow-notes
  main
```

## Part 3: Add Team Workflow Notes

Run:

```bash
echo "" >> README.md
echo "## Team Workflow" >> README.md
echo "In enterprise DevOps teams, changes are made in feature branches and reviewed through pull requests or merge requests." >> README.md
```

Check status:

```bash
git status
```

Expected output:

```text
modified: README.md
```

## Part 4: Stage and Commit

```bash
git add README.md
git commit -m "Add team workflow notes"
```

Expected output:

```text
1 file changed
```

## Part 5: Push Branch to Remote

If your remote is already configured:

```bash
git push -u origin feature/add-team-workflow-notes
```

If remote is not configured:

```bash
git remote add origin <REMOTE_REPO_URL>
git push -u origin feature/add-team-workflow-notes
```

Validate remote:

```bash
git remote -v
```

Expected output:

```text
origin  <REMOTE_REPO_URL> (fetch)
origin  <REMOTE_REPO_URL> (push)
```

## Part 6: Open Pull Request or Merge Request

In GitHub:

1. Open your repo in browser.
2. Click **Compare & pull request**.
3. Add title.
4. Add description.
5. Click **Create pull request**.

In GitLab:

1. Open your repo in browser.
2. Click **Create merge request**.
3. Add title.
4. Add description.
5. Click **Create merge request**.

Suggested title:

```text
Add team workflow notes
```

Suggested description:

```text
Summary:
- Added team Git workflow notes
- Explained feature branches and PR/MR review

Validation:
- Ran git status
- Confirmed branch was pushed
- Reviewed README changes

Risk:
- Documentation-only change
```

## Part 7: Create a Merge Conflict Locally

Return to terminal.

Go to main:

```bash
git switch main
```

Create a file:

```bash
echo "Environment: development" > environment.txt
git add environment.txt
git commit -m "Add environment file"
```

Create a branch:

```bash
git switch -c feature/change-environment
echo "Environment: staging" > environment.txt
git add environment.txt
git commit -m "Change environment to staging"
```

Return to main and change same line:

```bash
git switch main
echo "Environment: production" > environment.txt
git add environment.txt
git commit -m "Change environment to production"
```

Try to merge:

```bash
git merge feature/change-environment
```

Expected output:

```text
CONFLICT (content): Merge conflict in environment.txt
Automatic merge failed; fix conflicts and then commit the result.
```

## Part 8: Resolve the Conflict

Open the file:

```bash
cat environment.txt
```

You should see:

```text
<<<<<<< HEAD
Environment: production
=======
Environment: staging
>>>>>>> feature/change-environment
```

Resolve it in your editor (do NOT just overwrite from the terminal). Open the file:

```bash
code environment.txt
```

In VS Code, use the merge UI above the conflict and click **Accept Incoming Change**
(the `feature/change-environment` side), so the file becomes exactly:

```text
Environment: staging
```

Confirm that NO conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) remain, then save.

If you are not using VS Code, edit the file in any editor by hand: delete the three
marker lines and the side you do not want, leaving only `Environment: staging`.

Stage and commit the resolution:

```bash
git add environment.txt
git commit -m "Resolve environment merge conflict"
```

Validate:

```bash
git status
git log --oneline --graph --all
```

Expected status:

```text
nothing to commit, working tree clean
```

## Validation Checklist

- [ ] I created a feature branch.
- [ ] I committed README changes.
- [ ] I pushed my feature branch.
- [ ] I opened a PR or MR.
- [ ] I wrote a clear PR/MR description.
- [ ] I created a merge conflict.
- [ ] I identified conflict markers.
- [ ] I resolved the conflict in an editor (not by overwriting).
- [ ] I committed the conflict resolution.
- [ ] I validated with `git status`.
- [ ] (Optional) I rebased a branch and pushed with `--force-with-lease`.
- [ ] (Optional) I enabled branch protection and added CODEOWNERS.

## Troubleshooting Tips

| Problem | Likely Cause | Fix |
|---|---|---|
| `not a git repository` | Wrong folder | `cd week3-git-lab` |
| `failed to push some refs` | Remote changed or branch issue | Run `git pull`, then push |
| No PR/MR option appears | Branch not pushed | Run `git push -u origin <branch>` |
| No conflict appears | Did not edit same line in both branches | Repeat conflict steps carefully |
| Conflict markers remain | File not cleaned correctly | Remove `<<<<<<<`, `=======`, `>>>>>>>` |
| Cannot commit conflict fix | File not staged | Run `git add environment.txt` |

## Cleanup Steps

Local cleanup is optional.

To remove the lab folder:

```bash
cd ..
rm -rf week3-git-lab
```

Windows PowerShell:

```powershell
cd ..
Remove-Item -Recurse -Force week3-git-lab
```

Do not delete your remote repository unless instructed.

## Reflection Questions

1. What is the purpose of a PR or MR?
2. Why is code review important for infrastructure changes?
3. What causes a merge conflict?
4. Why should conflict markers never remain in final files?
5. How does this workflow help with Terraform or Kubernetes changes?

## Optional Challenge Tasks (Senior Practice)

Pick at least one. These are exactly the topics a senior interview probes.

### Challenge A: Rebase Instead of Merge

Create a divergence, then rebase your feature branch onto `main` for a linear history:

```bash
git switch -c feature/rebase-practice
echo "Rebase practice line" >> README.md
git commit -am "Add rebase practice line"

# Advance main so the branch falls behind:
git switch main
echo "Main moved forward" >> notes.txt
git add notes.txt && git commit -m "Advance main"

# Rebase the feature branch on top of the new main:
git switch feature/rebase-practice
git rebase main
git log --oneline --graph --all   # observe the straight, linear history
```

If you had already pushed the feature branch, push the rebased version safely:

```bash
git push --force-with-lease
```

Write one sentence on why you would never use plain `git push --force` on a shared branch.

### Challenge B: Enable Branch Protection on Your Test Repo

In your GitHub or GitLab test repo, protect `main`:

- Require a pull request before merging
- Require at least 1 approval
- Require linear history (blocks merge commits)
- Block direct pushes to `main`

Then prove it: try `git push` a commit straight to `main` and confirm it is rejected.

### Challenge C: Add a CODEOWNERS File

```bash
mkdir -p .github
printf '* @your-username\n/runbooks/ @your-username\n' > .github/CODEOWNERS
git add .github/CODEOWNERS
git commit -m "Add CODEOWNERS"
```

Open a PR that touches `/runbooks/` and confirm the owner is auto-requested as a reviewer.

### Challenge D: Configure `pull.rebase`

```bash
git config --global pull.rebase true
```

Explain in one line how this changes what `git pull` does and why it produces a cleaner history.

---

# 15. Troubleshooting Activity

## Incident Title

**Merge Request Blocked by Merge Conflict**

## Business Impact

A DevOps engineer is trying to merge a documentation update for a Terraform workflow. The merge request is blocked because another engineer changed the same file on the main branch.

The team cannot complete the change until the conflict is resolved.

## Symptoms

The PR/MR shows:

```text
This branch has conflicts that must be resolved.
```

Local merge shows:

```text
CONFLICT (content): Merge conflict in README.md
Automatic merge failed; fix conflicts and then commit the result.
```

## Starting Evidence

Student opens `README.md` and sees:

```text
<<<<<<< HEAD
Terraform changes must be reviewed by the cloud platform team.
=======
Terraform changes must be reviewed by the DevOps team before merge.
>>>>>>> feature/update-terraform-workflow
```

`git status` shows:

```text
You have unmerged paths.
  both modified: README.md
```

## Student Investigation Steps

Students should:

1. Run:

```bash
git status
```

2. Open the conflicted file.
3. Identify conflict markers:

```text
<<<<<<<
=======
>>>>>>>
```

4. Decide correct final content.
5. Remove all conflict markers.
6. Save the file.
7. Stage the fixed file:

```bash
git add README.md
```

8. Commit resolution:

```bash
git commit -m "Resolve README merge conflict"
```

9. Validate:

```bash
git status
```

## Expected Root Cause

Two branches changed the same line in the same file. Git could not automatically decide which change should win.

## Correct Resolution

Manually edit the file to the correct final wording, remove conflict markers, stage the file, and commit the resolution.

Recommended final text:

```text
Terraform changes must be reviewed by the cloud platform and DevOps teams before merge.
```

## Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Delete the entire file | Loses useful documentation |
| Keep both conflict marker sections | Leaves invalid conflict text in repo |
| Run random reset commands | Can lose work |
| `git push --force` on a shared branch | Can silently overwrite teammate commits; use `--force-with-lease` and only on your own branch |
| Ignore the conflict | Merge remains blocked |
| Copy only one side without reading | May remove important context |

## Instructor Hints

Hint 1:

```text
What file does git status say is conflicted?
```

Hint 2:

```text
Can you find the conflict markers in the file?
```

Hint 3:

```text
What should the final business-approved sentence say?
```

## Preventive Action

Teams can reduce conflicts by:

- Pulling latest main before starting work (`git pull --rebase`)
- Keeping branches short-lived (trunk-based development)
- Making smaller changes
- Communicating when editing shared files
- Using clear ownership for critical files (CODEOWNERS)
- Reviewing PR/MR diffs before merge

---

# 16. Scenario-Based Discussion Questions

## Question 1

Why should Terraform changes go through a PR/MR instead of being pushed directly to main?

Expected response themes:

- Infrastructure changes can affect production.
- Review catches risky changes.
- Plan output can be reviewed.
- Main branch should remain stable.
- Audit history matters.

Follow-up prompt:

```text
What could happen if a security group rule is merged without review?
```

## Question 2

Should all PRs require approval?

Expected response themes:

- Production-related repos should require review.
- Documentation-only changes may have lighter review.
- Teams should define rules based on risk.
- Protected branches enforce standards.

Follow-up prompt:

```text
Would you use the same approval rule for README changes and IAM policy changes?
```

## Question 3

What should a reviewer look for in a Kubernetes manifest change?

Expected response themes:

- Image tag
- Ports
- Selectors
- Probes
- Resource requests and limits
- Secrets references
- Namespace

Follow-up prompt:

```text
Which mistake could cause an app to be unreachable after deployment?
```

## Question 4

Why are merge conflicts common in team environments?

Expected response themes:

- Multiple people edit same files.
- Long-lived branches fall behind.
- Shared config files change often.
- Documentation and environment files are frequently edited.

Follow-up prompt:

```text
How can teams reduce conflict frequency?
```

## Question 5

How can Git history help during a production incident?

Expected response themes:

- Shows recent changes.
- Links issue to deployment.
- Helps identify risky commits.
- Supports rollback decision.
- Provides audit evidence.

Follow-up prompt:

```text
What command can show recent commits quickly?
```

## Question 6

What makes a PR/MR description useful?

Expected response themes:

- Clear summary
- Why change was made
- Validation performed
- Risk
- Rollback plan
- Screenshots or command output
- Linked ticket

Follow-up prompt:

```text
What would you include in a PR description for a Terraform VPC route table change?
```

## Question 7

How do DevOps Engineers, Cloud Engineers, and SREs use PR/MR workflows differently?

Expected response themes:

- DevOps reviews pipelines and deployment logic.
- Cloud Engineers review infrastructure, IAM, network, and cost impact.
- SREs review reliability, monitoring, rollback, and incident risk.

Follow-up prompt:

```text
Who should review a change that modifies Kubernetes readiness probes?
```

## Question 8

Your team wants a readable, linear `main` history. Would you choose merge commits, rebase, or squash-merge — and why?

Expected response themes:

- Squash-merge keeps one commit per change and an easy revert.
- Rebase keeps a linear branch but rewrites commit IDs (coordinate before force-push).
- Merge commits preserve the full graph but get noisy.
- Many teams require linear history via branch protection.

Follow-up prompt:

```text
What does git bisect or git revert look like under each strategy?
```

## Question 9

When is `git push --force-with-lease` acceptable, and when is force-pushing never acceptable?

Expected response themes:

- Acceptable on your own feature/PR branch after a rebase.
- `--force-with-lease` protects teammates by aborting if the remote moved.
- Never force-push a shared/protected branch like `main`.
- Plain `--force` can silently destroy commits.

Follow-up prompt:

```text
What would happen if you force-pushed main while a teammate was mid-PR?
```

## Question 10

In a GitOps model, how does a change reach production, and why does that make PR review even more important?

Expected response themes:

- A commit/merge to Git is the change; a controller (Argo CD/Flux) reconciles the cluster.
- Git is the source of truth; the live system follows it automatically.
- A bad merge can be auto-deployed, so review and required checks are the safety net.
- Audit trail and rollback come from Git history.

Follow-up prompt:

```text
If production drifts from the repo, which one "wins" under GitOps?
```

---

# 17. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

What is the main purpose of a pull request or merge request?

A. Delete old branches automatically  
B. Request review before merging changes  
C. Replace the need for commits  
D. Install Git locally  

**Answer:** B  
**Explanation:** PRs and MRs allow teams to review, discuss, approve, and merge changes safely.

## Question 2: Multiple Choice

Which platform commonly uses the term “merge request”?

A. GitHub  
B. GitLab  
C. Docker  
D. AWS CloudWatch  

**Answer:** B  
**Explanation:** GitLab uses “merge request.” GitHub uses “pull request.”

## Question 3: True or False

A protected branch can prevent direct pushes to main.

**Answer:** True  
**Explanation:** Protected branches help enforce review and approval workflows.

## Question 4: True or False

A merge conflict means Git is broken.

**Answer:** False  
**Explanation:** A merge conflict means Git needs a human to decide how to combine overlapping changes.

## Question 5: Short Answer

What command shows the current branch and whether files are conflicted?

**Answer:**

```bash
git status
```

**Explanation:** `git status` is the first command to run when diagnosing most Git issues.

## Question 6: Short Answer

Name three items that should be included in a good PR/MR description.

**Answer:**  
Summary, validation, risk, rollback notes, linked ticket, screenshots, command output.

**Explanation:** A good description helps reviewers understand the change and its impact.

## Question 7: Troubleshooting

A student sees this in a file:

```text
<<<<<<< HEAD
Environment: production
=======
Environment: staging
>>>>>>> feature/change-environment
```

What should they do?

**Answer:**  
Decide the correct final content, remove all conflict markers, save the file, run `git add`, and commit the resolution.

**Explanation:** Conflict markers must not remain in the final file.

## Question 8: Troubleshooting

A student pushes a branch, but GitHub or GitLab does not show an option to create a PR/MR. What is one likely cause?

**Answer:**  
The branch may not have been pushed to the remote, or it was pushed to the wrong remote.

**Fix:**

```bash
git push -u origin <branch-name>
git remote -v
```

## Question 9: AWS-Related Question

Why is PR/MR review important before merging Terraform code that changes AWS IAM permissions?

**Answer:**  
IAM changes can create security risks, over-permissioned access, or production access issues.

**Explanation:** Review helps enforce least privilege and prevents unsafe access changes.

## Question 10: AWS-Related Question

A Terraform change modifies an AWS security group rule. What should reviewers check?

**Answer:**  
They should check source CIDR, ports, protocol, whether access is too broad, business justification, and production impact.

**Explanation:** Security group changes can expose systems or break connectivity.

## Question 11: Class 1 and Class 2 Connection

In Class 1, students learned `git commit`. In Class 2, what happens after commits are pushed to a remote feature branch?

**Answer:**  
The student opens a PR/MR for review and merge.

**Explanation:** Local commits become part of team collaboration after push and review.

## Question 12: Class 1 and Class 2 Connection

Why is a feature branch created before a PR/MR?

**Answer:**  
A PR/MR compares the feature branch changes against the target branch, usually main.

**Explanation:** Feature branches isolate changes and make review possible.

## Question 13: Multiple Choice

Your feature branch has fallen behind `main`. Which approach gives `main` a clean, linear history with no extra merge commit?

A. `git merge main` into your feature branch  
B. `git rebase main` on your feature branch, then squash-merge the PR  
C. `git push --force` to main  
D. Delete `main` and recreate it  

**Answer:** B  
**Explanation:** Rebasing replays your commits on top of the latest `main`; squash-merge then lands one clean commit. `--force` to `main` is dangerous and `merge` adds a merge commit.

## Question 14: True or False

`git push --force-with-lease` is safer than `git push --force` because it aborts if the remote branch has moved since your last fetch.

**Answer:** True  
**Explanation:** `--force-with-lease` protects a teammate's commits by refusing to overwrite a branch that advanced behind your back.

## Question 15: Short Answer

In GitOps, what is the relationship between Git and the running system?

**Answer:**  
Git is the source of truth; a controller (Argo CD or Flux) continuously reconciles the live system to match what is committed in Git.

**Explanation:** Changes are made by merging a PR, not by manual console edits — the controller makes reality match the repo.

## Question 16: Short Answer

What does a `CODEOWNERS` file do, and where would you require SRE review?

**Answer:**  
It maps repository paths to required reviewers so a PR auto-requests the right team. You would assign `/runbooks/` (or reliability-critical paths) to the SRE team.

**Explanation:** CODEOWNERS plus branch protection ("require review from Code Owners") enforces the governance, rather than relying on convention.

## Question 17: Troubleshooting

After rebasing your feature branch, `git push` is rejected with "Updates were rejected because the tip of your current branch is behind." You know the remote only has your own earlier commits. What is the correct command?

**Answer:**

```bash
git push --force-with-lease
```

**Explanation:** Rebase rewrote your commit IDs, so the history diverged; `--force-with-lease` updates your branch only if no one else pushed to it.

---

# 18. Homework Assignment

## Assignment Title

**Git Team Workflow Diagram and Branch-to-Merge Explanation**

## Scenario

Your team manages Terraform code for AWS networking. A developer wants to update a security group rule. Before making real infrastructure changes, your team lead asks you to document the correct Git workflow from branch creation through merge.

## Student Tasks

Students must create:

1. A Git workflow diagram.
2. A written explanation of the workflow.
3. A sample PR/MR description.
4. A short explanation of how to resolve a merge conflict.
5. A short answer explaining why direct pushes to main are risky.

## Required Workflow Steps to Include

```text
Start from main
Pull latest changes
Create feature branch
Make change
Run validation
Commit change
Push branch
Open PR/MR
Request review
Resolve comments
Resolve conflicts if needed
Merge after approval
Delete feature branch
```

## Expected Deliverables

Students submit one document containing:

1. Diagram:

```text
main -> feature branch -> commit -> push -> PR/MR -> review -> approval -> merge
```

2. Written explanation, 1 to 2 paragraphs.
3. Sample PR/MR title and description.
4. Merge conflict resolution steps.
5. Enterprise risk explanation for direct changes to main.

## Submission Format

Accepted formats:

- Markdown file
- PDF
- Git repository link
- Text document

## Estimated Completion Time

45 to 60 minutes

## Grading Criteria

| Criteria | Points |
|---|---:|
| Workflow diagram is complete | 20 |
| Written explanation is clear | 20 |
| PR/MR description is realistic | 20 |
| Merge conflict steps are accurate | 20 |
| Enterprise risk explanation is practical | 10 |
| Formatting and completeness | 10 |
| Total | 100 |

## Optional Advanced Challenge

Create a real GitHub or GitLab repository and submit a link to a PR/MR that includes:

- Clear title
- Description
- Commit history
- File diff
- At least one comment or self-review note

---

# 19. Common Student Mistakes

| Mistake | Why It Happens | Fix or Avoidance |
|---|---|---|
| Opening PR/MR from wrong branch | Student does not check current branch | Run `git branch` before pushing |
| Weak PR title | Student treats PR as a formality | Use specific action-based title |
| Empty PR description | Student does not know what reviewers need | Use summary, validation, risk format |
| Leaving conflict markers | Student does not understand conflict syntax | Show markers and require cleanup |
| Resolving conflict without reading | Student randomly chooses one side | Discuss business intent before editing |
| Force pushing casually | Student searches online and copies commands | Use `--force-with-lease`, never plain `--force`; never force-push `main` |
| Working on stale branch | Student does not pull latest main | `git pull --rebase` before creating a feature branch |
| Committing to main directly | Student forgets branch workflow | Protect main and enforce feature branches |
| Not reviewing diff | Student trusts the command only | Always check changed files before PR/MR |
| Mixing unrelated changes | Student edits too many files | Keep PRs small and focused |

---

# 20. Real-World Enterprise Scenario

## Scenario

A logistics company has a cloud platform team managing AWS infrastructure through Terraform. The team stores Terraform code in GitLab. A developer requests a change to allow application traffic from an internal CIDR block to an application load balancer.

The change affects:

- AWS security groups
- Terraform code
- Application connectivity
- Security review
- Production risk
- Audit requirements

## Constraints

| Constraint | Example |
|---|---|
| Access control | Only platform team can approve production network changes |
| Security | No open `0.0.0.0/0` access unless explicitly approved |
| Reliability | Bad security group change can break app traffic |
| Cost | Incorrect infrastructure changes may create unnecessary resources |
| Audit | All production changes must be traceable |
| Team workflow | Merge request must include Terraform plan summary |
| Approval | Senior cloud engineer must approve before merge |

## How Class Topic Applies

The engineer should:

1. Pull latest main.
2. Create a feature branch.
3. Make the Terraform security group change.
4. Run validation.
5. Commit with clear message.
6. Push branch.
7. Open merge request.
8. Include summary, risk, validation, and plan output.
9. Request review.
10. Resolve comments or conflicts.
11. Merge after approval.

## What Each Role Would Do

| Role | Action |
|---|---|
| DevOps Engineer | Ensures pipeline validates the Terraform change |
| Cloud Engineer | Reviews AWS networking and IAM impact |
| SRE | Reviews production reliability and rollback considerations |
| Security Reviewer | Checks exposure and least privilege |
| Engineering Lead | Confirms business need and timing |

## Key Enterprise Lesson

Git workflow is part of production safety. A good PR/MR can prevent outages, security exposure, and untracked cloud changes.

---

# 21. Instructor Tips

## Teaching Tips

- Start with the Class 1 workflow and extend it.
- Keep PR/MR terminology simple.
- Use GitHub or GitLab visually so students see the workflow.
- Emphasize review and communication, not just commands.
- Explain that conflict resolution requires judgment, not only syntax.

## Pacing Tips

- Do not spend too long explaining every Git feature.
- Focus on PR/MR, conflict resolution, and the merge/rebase/squash strategy choice.
- Teach `--force-with-lease`, `pull --rebase`, GitOps awareness, and branch protection as core; keep `stash` and `cherry-pick` as optional discussion.
- Leave enough lab time for authentication and branch issues.

## Lab Support Tips

When students are stuck, ask them to run:

```bash
pwd
ls
git status
git branch
git remote -v
git log --oneline
```

## How to Help Struggling Students

Ask:

```text
What branch are you on?
What file did you change?
Did you commit the change?
Did you push the branch?
What does Git status say?
```

Avoid immediately fixing it for them. Have them read the error message first.

## How to Challenge Advanced Students

Ask advanced students to:

- Add a `.gitignore`
- Create a PR/MR template
- Use branch naming conventions
- Add reviewers
- Resolve a more complex conflict
- Explain branch protection rules
- Draft a Terraform PR/MR description with risk and rollback sections

---

# 22. Student Outcome Checklist

## Students Should Be Able to Explain

- [ ] What a pull request is
- [ ] What a merge request is
- [ ] Why code review matters
- [ ] What a protected branch is
- [ ] What a merge conflict is
- [ ] Why direct pushes to main are risky
- [ ] The difference between merge, rebase, and squash-merge
- [ ] When `--force-with-lease` is safe and why plain `--force` is dangerous
- [ ] What GitOps means (Git as source of truth a controller reconciles)
- [ ] Trunk-based development vs GitFlow at a high level
- [ ] How Git supports Terraform, Kubernetes, and CI/CD workflows
- [ ] Why Git history matters during incidents

## Students Should Be Able to Build or Configure

- [ ] Create a feature branch
- [ ] Commit changes to the branch
- [ ] Push branch to remote
- [ ] Open a PR or MR
- [ ] Write a useful PR/MR title
- [ ] Write a useful PR/MR description
- [ ] Review changed files
- [ ] Resolve a merge conflict in an editor
- [ ] Rebase a branch and push with `--force-with-lease`
- [ ] Configure branch protection and a CODEOWNERS file

## Students Should Be Able to Troubleshoot

- [ ] Failed push
- [ ] Wrong branch
- [ ] Missing remote
- [ ] Conflict markers
- [ ] Unmerged paths
- [ ] PR/MR not appearing
- [ ] Accidental commit to main
- [ ] Branch out of date with main

---

# 23. Class Completion Checklist

## Instructor Checklist Before Ending Class

- [ ] Reviewed Class 1 local Git workflow
- [ ] Explained PR vs MR terminology
- [ ] Demonstrated opening a PR/MR
- [ ] Demonstrated conflict creation and resolution
- [ ] Students practiced branch, push, PR/MR
- [ ] Students resolved at least one conflict
- [ ] Students understand homework expectations
- [ ] Students understand how Git connects to AWS, Terraform, Kubernetes, and CI/CD

## Student Checklist Before Leaving Class

- [ ] I understand what a PR/MR is
- [ ] I pushed a branch to remote
- [ ] I opened or observed a PR/MR
- [ ] I reviewed file differences
- [ ] I created a merge conflict
- [ ] I resolved a merge conflict
- [ ] I know why direct pushes to main are risky
- [ ] I understand the homework assignment

## Items to Verify Before Closing the Week

Students should be comfortable with:

```bash
git switch -c        # legacy: git checkout -b
git status
git add
git commit
git push
git pull --rebase
git merge
git rebase
git push --force-with-lease
git log --oneline --graph --all
git branch
git remote -v
```

They should understand this team workflow:

```text
Feature Branch -> Push -> PR/MR -> Review -> Approval -> Merge
```

---

# 24. End-of-Week Summary

## What Students Learned This Week

Students learned how Git supports real DevOps, Cloud Engineering, and SRE collaboration.

They practiced:

- Creating repositories
- Creating branches
- Staging files
- Committing changes
- Viewing commit history
- Pushing branches
- Opening PRs or MRs
- Understanding code review
- Resolving merge conflicts
- Connecting Git to infrastructure and production workflows

## How Class 1 and Class 2 Connect

Class 1 focused on local Git fundamentals:

```text
Edit -> Stage -> Commit -> Branch -> Push
```

Class 2 extended that into team collaboration:

```text
Push -> PR/MR -> Review -> Merge -> Conflict Resolution
```

Together, the week gives students the foundation they need before working with:

- AWS labs
- Terraform code
- Dockerfiles
- CI/CD pipelines
- Kubernetes manifests
- Helm charts
- SRE runbooks

## How This Week Prepares Students for the Next Week

Next week introduces AWS Cloud Foundations. Git will remain important because students will eventually store AWS-related work in repositories, including:

- AWS CLI scripts
- Terraform files
- Architecture notes
- Lab documentation
- Security checklists
- Troubleshooting notes

## What Students Should Review Before the Next Module

Students should review:

1. `git status`
2. `git add`
3. `git commit`
4. `git switch -c` (legacy: `git checkout -b`)
5. `git push` and `git push --force-with-lease`
6. PR/MR purpose
7. Merge conflict markers and editor-based resolution
8. Merge vs rebase vs squash, and `git pull --rebase`
9. Why main branch should be protected (branch protection, CODEOWNERS)
10. GitOps and trunk-based development at an awareness level
11. Why Git matters for AWS and infrastructure work

---

# 25. Class Artifacts & Validation

Runnable, on-disk artifacts that back this class, from the shared module
[`labs/git-collaboration/`](../../labs/git-collaboration/), which the module README
maps directly to **Week 03 Class 02**. This class drives all of them: the
`setup-scenario.sh` builds the **reproducible merge conflict** students resolve
(by merge and by rebase, per `docs/conflict-resolution.md`); the two hooks enforce
secret-safety and Conventional Commits; `install-hooks.sh` wires them into a repo.
All rows are validated by the module's `validate.sh` (10/10 gates pass here:
`bash 5.x`, `git 2.34`).

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/git-collaboration/solution/setup-scenario.sh | bash | Builds a deterministic `UU config.yaml` merge conflict (same `replicas:` line, two values) — the conflict students resolve in the lab; idempotent + self-cleaning | `bash -n solution/setup-scenario.sh`; behaviour: `./solution/setup-scenario.sh --dir /tmp/conflict-lab` then `git -C /tmp/conflict-lab status --porcelain` → `UU config.yaml` | PASS — spot-check returns `UU config.yaml`; `tests/test_hooks.sh` asserts conflict + idempotency |
| 2 | labs/git-collaboration/solution/hooks/commit-msg | bash hook | Enforces Conventional Commits (`feat(api): …` accepted, `updated stuff` rejected); exempts merge/revert auto-messages | `bash -n solution/hooks/commit-msg`; behaviour via `tests/test_hooks.sh` (`commit-msg rejects a non-conventional subject`) | PASS — via `./validate.sh` |
| 3 | labs/git-collaboration/solution/hooks/pre-commit | bash hook | Blocks staged AWS keys / PEM private keys / files > 5 MB — the secret-scan a reviewer relies on before a PR | `bash -n solution/hooks/pre-commit`; behaviour via `tests/test_hooks.sh` (blocks `AKIA…`, blocks > 5 MB, clean commit passes) | PASS — via `./validate.sh` |
| 4 | labs/git-collaboration/solution/install-hooks.sh | bash | Symlinks both hooks into a target repo's `.git/hooks/` (worktree-safe via `--git-common-dir`) | `bash -n solution/install-hooks.sh`; behaviour via `tests/test_hooks.sh` (`install-hooks symlinks pre-commit and commit-msg`) | PASS — via `./validate.sh` |
| 5 | labs/git-collaboration/docs/conflict-resolution.md | docs | Worked merge **and** rebase walkthrough (marker table, `git diff --check`, ours/theirs in rebase) — the answer key for the conflict lab | n/a (documentation; verified against the §14 conflict scenario) | Present — matches scenario |
| 6 | labs/git-collaboration/tests/test_hooks.sh | bash tests | Black-box behaviour tests for hooks + the conflict scenario (9 assertions) | `bash tests/test_hooks.sh` | PASS — `9 passed, 0 failed` |
| 7 | labs/git-collaboration/validate.sh | bash | Module gate runner: `bash -n` on every script/hook + behaviour tests | `./validate.sh` | PASS — `== 10 passed, 0 failed ==` |

Notes:
- The PR/MR, branch-protection, and CODEOWNERS steps in §13 (Demo Parts A/D) require a
  live GitHub/GitLab account and are **instructor-run against a real remote** — there is
  no committed CI/remote run log in this repo, so those steps are taught and documented
  but not captured as an automated PASS here.
- `shellcheck` is installed in this build (`0.10.0`) and passes clean on the solution
  scripts; `gitleaks` is not installed (documented DEFERRED in the lab README). The local
  gates (`bash -n` + behaviour tests) are the required substitute and they pass.
- No live cloud operation is involved — local `bash` + `git` only ($0). There is no
  `LIVE-*EVIDENCE*` file for this module; the PASS evidence is the static `validate.sh`
  run plus the `setup-scenario.sh` conflict spot-check above.

---

# 26. Definition of Done

Ticked honestly for **Class 2** against the shared module
[`labs/git-collaboration/`](../../labs/git-collaboration/) (artifact standard §5):

- [x] Every technology taught ships at least one **runnable file on disk** — `setup-scenario.sh`, `commit-msg`, `pre-commit`, `install-hooks.sh` exist on disk (not just fences). PR/MR + branch-protection are platform-UI actions, documented with exact steps, not authored files.
- [x] Each artifact passes its **validation gate** — `./validate.sh` → `10 passed, 0 failed`; conflict spot-check → `UU config.yaml`; output captured in §25.
- [x] Lab has **starter** (intentionally incomplete `TODO(student)` gaps) and **solution** (reference) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, and cost notes.
- [x] **Cleanup/teardown** is provided and idempotent — `rm -rf` of the `--dir`/`--target` scenario repos; hook uninstall documented; tests/validate self-clean via `mktemp` + trap.
- [x] **Instructor answer key** exists — `docs/conflict-resolution.md` (merge + rebase), the module README "Instructor answer key" section, plus this class file's Knowledge-Check answer key (§17) and homework rubric (§18).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — §15 reproduces a blocked merge conflict with exact markers/`git status`; the lab's `setup-scenario.sh` **is** the deterministic injected fault (re-run for an identical `UU config.yaml`).
- [x] **Expected outputs** are shown for every demo and lab step (CONFLICT message, conflict markers, `git log --oneline --graph --all`, protected-branch rejection).
- [x] **Cost & security warnings** present — never force-push a shared branch / `main`; never commit secrets; `--force-with-lease` only on own branch; explicit $0 cost note in the module.
- [x] **Cross-references** verified — links to `labs/git-collaboration/`, the course's artifact standard, Class 1 (Demo Part 9 auth), and forward refs (Week 4 AWS, Weeks 11–13 GitOps) resolve.
- [x] The **artifact manifest** (§25) is present and every path resolves (`ls`-verified).

Honest scope note: this class is **Practiced**, not Mastered. The lab is static-validated
(shell syntax + behaviour tests + a real reproducible conflict) with starter/solution and
an answer key. The live PR/MR, branch-protection, and CODEOWNERS work is instructor-run
against a real remote but not captured as a repo artifact, and the module is not yet
reused/operated in a later week or the capstone — so it does not reach the 8–10 band.
