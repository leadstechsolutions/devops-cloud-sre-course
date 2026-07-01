# How to Use This Course

Welcome! This course is **hands-on**. Most of your learning happens in the **21 lab modules**
under [`labs/`](labs/) — real projects you complete and validate, not slides to read.

This guide shows you the workflow once; **every lab works the same way.**

---

## Day one: set up your machine (5 minutes)

```bash
git clone https://github.com/leadstechsolutions/devops-cloud-sre-course.git
cd devops-cloud-sre-course

# Start with the setup lab — it tells you exactly which tools you're missing:
cd labs/setup-validation
cat README.md
./validate.sh
```

The `setup-validation` lab checks your toolchain and prints something like:

```
[PASS] git         2.34.1     (need >= 2.30)
[PASS] python3     3.10.12    (need >= 3.10)
[PASS] docker      29.1.2     (need >= 24)
[PASS] terraform   1.14.1     (need >= 1.6)
[PASS] aws         2.32.11    (need >= 2)
[PASS] kubectl     1.34.2     (need >= 1.27)
RESULT: READY — required toolchain satisfied.
```

Install anything it reports as missing, then you're ready to start Week 1.

> **No prior DevOps experience required** — just comfort with a terminal. You don't need every
> tool installed on day one; each lab's README lists exactly what *that* lab needs.

---

## How every lab is organized

Each folder under [`labs/`](labs/) contains the same five parts:

| Part | What it's for |
|------|---------------|
| `README.md` | The brief: what you build, prerequisites, expected output, troubleshooting, cleanup, and cost notes. |
| `starter/` | **Your working copy.** It has deliberate `TODO(student)` gaps for you to fill in. |
| `solution/` | The **reference answer** — check yourself against it when you get stuck. |
| `tests/` | The automated test suite for the module. |
| `validate.sh` | The **checker** — runs every gate (lint, syntax, tests, build) and prints `PASS`/`FAIL`. |

---

## The lab loop (do this for every module)

**1. Read the brief.**
```bash
cd labs/<module>
cat README.md
```

**2. Run the checker once** to confirm your tools work and to see the "green" target you're aiming for.
```bash
./validate.sh
```

**3. Do the work in `starter/`.** Find the `TODO(student)` gaps and complete them:
```bash
grep -rn "TODO(student)" starter/
```
Example (from `setup-validation`):
```bash
# starter/lib/check.sh
# TODO(student): replace the line below with a correct numeric comparison.
: "REPLACE ME"
return 1
```

**4. Check yourself against `solution/`** when you're unsure what "correct" looks like:
```bash
diff starter/lib/check.sh solution/lib/check.sh
```

**5. Re-run and confirm.** When your implementation is right, the gates go green and the tool you
built actually runs:
```bash
./validate.sh          # aim for "N passed, 0 failed"
```

That's the whole rhythm: **read → run → fill the TODOs → compare to solution → validate.**

> **Tip:** `solution/` is there to *learn from*, not to copy. Try the `starter/` TODOs yourself
> first; open the solution to understand the intended approach and edge cases.

---

## What each lab needs (three types)

Every lab README lists its exact prerequisites, but they fall into three groups:

### 🖥️ Offline labs — just your laptop
Only local CLI tools; no accounts, no network, no cost. Most labs are here — e.g.
`linux-shell-automation`, `python-automation`, `git-collaboration`, `aws-cli-fundamentals`,
`security-automation`, `cicd-pipelines`, `docker-containers` (needs the Docker daemon running).

### ☸️ Live Kubernetes labs — need a local cluster
These run against a real cluster you create locally with **[kind](https://kind.sigs.k8s.io/)**
(Kubernetes-in-Docker). e.g. `kubernetes-fundamentals`, `k8s-production-ops`, `helm-charts`,
`sre-incident-response`, `performance-scaling`.

```bash
kind create cluster            # one-time: spin up a local cluster
# ...do the lab...
kind delete cluster            # tear it down when done
```

### ☁️ Live AWS labs — need an AWS account
These provision real AWS resources with Terraform. e.g. `terraform-aws-foundations`,
`aws-storage-databases`.

- Use an **AWS account with the free tier** and a small budget.
- They follow a **build → verify → destroy** flow, so cost stays about **$0** — **always run the
  teardown** (`terraform destroy`, or the cleanup steps in the lab README) when you finish.

```bash
export AWS_PROFILE=your-sandbox-profile   # never use a production account
# ...do the lab (apply)...
terraform destroy                          # ALWAYS clean up
```

> ⚠️ **Cost & safety:** only run cloud labs in a personal/sandbox AWS account, never production.
> Tear resources down as soon as you're done. Never commit real AWS keys — the security labs use
> the well-known **example** key `AKIAIOSFODNN7EXAMPLE` as a *fixture*, which is not a real credential.

---

## Working through the course

- Each week ships as two class packages, `class-01.md` and `class-02.md`, under
  [`01-foundation-track/`](01-foundation-track/) (Weeks 1–16) and
  [`02-advanced-track/`](02-advanced-track/) (Weeks 17–25). Read them, then do the linked lab.
- The full week-by-week map (topics · lab · outcome) is in [`CURRICULUM.md`](CURRICULUM.md).
- Weeks 23–24 are the **capstone** (`labs/capstone/`) — it ties the whole course together.
- Week 25 (`labs/career-prep/`) turns your work into a resume, portfolio, and interview prep.

## Stuck?

1. Re-read the lab `README.md` — most have a **Troubleshooting** section.
2. Run `./validate.sh` and read the first `[FAIL]` — the checkers print the failing command.
3. Compare your `starter/` file against `solution/` (`diff`) to spot the gap.

Happy building — you build it, you run it, you prove it. 🚀
