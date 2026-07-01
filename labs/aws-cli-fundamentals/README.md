# Module: aws-cli-fundamentals

> **Status:** Validated (static + offline) — every `.sh` passes `bash -n`; the
> offline functional suite (`tests/run-tests.sh`, 50 assertions) runs green
> against an `aws` stub; and `shellcheck -x` is a gate (all `solution/` scripts,
> `validate.sh`, `tests/`, **and** the `broken/` fixture are lint-clean — the
> fixture's defect is *behavioural*, not a lint error). Captured in this
> environment (AWS CLI v2.32.11, bash 5.1, ShellCheck 0.10.0). The scripts make
> **read-only** AWS calls; the **live read against a real account is `$0`** and is
> run by the orchestrator (and was confirmed here to fail clearly when no
> credentials are present — see [Validation](#validation)). See
> [Cost considerations](#cost-considerations).
> **Maps to:** Week 04 Class 01 (AWS CLI fundamentals + identity/credentials) and
> reused in Week 04 Class 02 (cost & tag governance) and as the read-only probe
> toolkit referenced from the Terraform weeks.

## What you will build
A small, production-shaped **read-only AWS CLI toolkit**: five standalone scripts
that share one sourced library and never mutate a single resource. By the end you
have `whoami.sh` (resolves your identity via `sts:GetCallerIdentity` and fails
clearly when there are no credentials), `regions.sh` (`ec2:DescribeRegions` as an
aligned table), `inventory.sh` (a read-only EC2 + S3 + IAM snapshot),
`cost-guard.sh` (flags running instances, available NAT gateways, idle Elastic
IPs and detached EBS volumes — the classic money-burning leftovers — and exits
non-zero so it works as a cron/CI cost gate), and `tag-audit.sh` (lists resources
missing required governance tags). Every script has `usage()/-h`, sources
`lib/common.sh` (`log()`, `die()`, `require_cmd()`, `aws_region()`,
`require_aws_creds()`), and treats a credential failure as a hard error. You also
debug `broken/whoami-broken.sh`, which **swallows the no-credentials error and
falsely reports success** while ignoring `AWS_PROFILE`.

## Prerequisites
- **AWS CLI v2 ≥ 2.0** (`aws --version`). v2 is assumed for `aws configure sso`.
- **bash ≥ 4.3** (uses `mapfile`, `[[ ]]`, arrays) and GNU coreutils (`awk`,
  `grep`, `sort`, `tr`).
- **AWS access for the live read** (optional locally): an IAM principal or SSO
  permission set with `sts:GetCallerIdentity`, `ec2:Describe*`,
  `s3:ListAllMyBuckets`, and `iam:ListUsers`. A **ReadOnlyAccess**-style policy is
  more than enough. No write permissions are needed or used. See
  [`solution/sso-config.md`](solution/sso-config.md).
- No prior module is required. The identity/credentials patterns here are reused
  by the Terraform weeks (same profile/SSO model).

## Architecture
See [`docs/architecture.mmd`](docs/architecture.mmd). Text view:

```
  AWS credentials (AWS_PROFILE / SSO token / env keys)
                       │
              ┌────────▼─────────┐
              │  lib/common.sh   │  log() die() require_cmd()
              │                  │  aws_region() require_aws_creds()
              └────────┬─────────┘
   ┌──────────┬────────┼─────────┬──────────────┐
   ▼          ▼        ▼         ▼              ▼
whoami.sh  regions.sh inventory cost-guard.sh  tag-audit.sh
(sts:Get-  (ec2:Desc- (ec2/s3/  (running EC2,  (missing Owner/
Caller-     ribe-      iam       NAT, idle EIP, Environment/
Identity)   Regions)   List/     detached EBS;  Project tags;
                       Describe)  exit 1 on      exit 1 on
                                  finding)       violation)
```

Each script writes **data to stdout** and **timestamped diagnostics to stderr**,
so they compose in pipelines and cron. `cost-guard.sh` and `tag-audit.sh` exit
non-zero on a finding, making them directly usable as scheduled governance gates.
Every API verb is a `Describe*` / `List*` / `Get*` / `ls` — the toolkit is
read-only by construction, enforced by a static gate in the test suite.

## Repository layout
```
starter/    # intentionally incomplete — you implement the TODO(student) gaps
  lib/common.sh   # aws_region() and require_aws_creds() are gapped
  whoami.sh       # credential probe + identity field extraction gapped
  regions.sh      # describe-regions args + table formatting gapped
  inventory.sh    # the three Describe/List blocks gapped
  cost-guard.sh   # the four leftover-detection blocks gapped
  tag-audit.sh    # required-tag parsing + per-resource comparison gapped
solution/   # reference implementation — check yourself against this
  lib/common.sh   whoami.sh  regions.sh  inventory.sh  cost-guard.sh  tag-audit.sh
  sso-config.md   # aws configure sso walkthrough (the assumed credential method)
broken/
  whoami-broken.sh  # troubleshooting fixture: swallows the no-creds error,
                    #   ignores AWS_PROFILE -> false success (exit 0)
tests/
  run-tests.sh    # OFFLINE functional suite (uses an `aws` stub; no real account)
docs/
  architecture.mmd
validate.sh        # runs this module's validation gates
```

## Setup
From a fresh clone, no AWS account is needed to run the gates:

```bash
cd labs/aws-cli-fundamentals
./validate.sh            # bash -n + offline tests + shellcheck; exits 0 on success
```

To run the scripts for real against your account, configure credentials
(SSO recommended — see [`solution/sso-config.md`](solution/sso-config.md)):

```bash
aws configure sso                 # one-time; writes a profile to ~/.aws/config
export AWS_PROFILE=readonly       # or whatever you named the profile
export AWS_REGION=eu-west-1       # the region cost-guard / inventory will scan
./solution/whoami.sh              # confirm WHO you are before anything else
```

## Lab tasks
Work in `starter/`. Each task's "done when" is checked by `tests/run-tests.sh`
(which uses an `aws` stub, so you can iterate with no real account) and/or a live
run once you have credentials.

1. **Implement `lib/common.sh` helpers.** Fill `aws_region()` (honour
   `AWS_REGION` → `AWS_DEFAULT_REGION` → `aws configure get region`) and
   `require_aws_creds()` (probe `sts:GetCallerIdentity`, surface the real error,
   `die` non-zero on failure — **do not** swallow it).
   *Done when:* with no credentials every script exits 1 with
   `credentials are not usable`; with credentials `whoami.sh` prints your account.
2. **Implement `whoami.sh`.** Call `require_aws_creds`, then extract Account, Arn,
   UserId via `--query`/`--output text` and resolve the region.
   *Done when:* `./whoami.sh` prints Account/ARN/Name/Profile/Region and exits 0
   with valid creds; exits 1 with a clear message without.
3. **Implement `regions.sh`.** `ec2:DescribeRegions` → aligned table; `--all`
   adds disabled opt-in regions.
   *Done when:* output has a `REGION` header and one sorted row per region.
4. **Implement `inventory.sh`.** Read-only EC2 + S3 + IAM snapshot with `(none)`
   handling and per-section totals.
   *Done when:* all three sections render against the stub and a real account.
5. **Implement `cost-guard.sh`.** Detect running instances, available NAT
   gateways, idle EIPs, detached EBS volumes; exit 1 if any are found.
   *Done when:* it prints `[BURN]` lines for offenders and exits 1, 0 when clean.
6. **Implement `tag-audit.sh`.** List EC2 instances + EBS volumes missing any
   required tag key (default `Owner,Environment,Project`, overridable with
   `--require`); exit 1 on any violation.
   *Done when:* untagged/partly-tagged resources are listed with the missing keys.
7. **Troubleshoot `broken/whoami-broken.sh`.** Find and fix the two bugs (see
   [Troubleshooting](#troubleshooting)).
   *Done when:* it exits non-zero with no credentials and reports the real profile.

## Validation
`./validate.sh` runs three gate groups and exits non-zero if any fails:

1. **`bash -n`** on every `.sh` (syntax).
2. **`tests/run-tests.sh`** — 50 offline functional assertions using an `aws`
   stub on `PATH` (no real account, no network): every solution script fails
   clearly with no creds; the broken fixture *falsely* succeeds; the happy path
   resolves identity, lists regions/inventory, and flags cost leftovers against
   canned data; `--help` exits 0; and a static check proves **no mutating verb**
   exists in `solution/`.
3. **`shellcheck -x`** — all `solution/` scripts, `validate.sh`, `tests/`, and the
   `broken/` fixture are lint-clean; `starter/` findings are reported for info.

Expected tail of `./validate.sh`:

```
  [PASS] tests/run-tests.sh (offline functional)
-- shellcheck 0.10.0
  [PASS] shellcheck -x solution/cost-guard.sh (clean)
  ...
  [PASS] shellcheck -x broken/whoami-broken.sh (clean — bug is behavioural)
  [PASS] sso-config.md present
== 26 passed, 0 failed ==
```

**Live read confirmation (captured here, real AWS CLI, no credentials):**

```
$ AWS_PROFILE= ./solution/whoami.sh
... [ERROR] AWS credentials are not usable for this command.
... aws: Unable to locate credentials. You can configure credentials by running "aws login".
... [ERROR] fix: run 'aws sso login' (SSO) or 'aws configure' (static keys), ...
# exit status: 1
```

The same run against the broken fixture *wrongly* exits 0 with blank fields and
`Profile : default` — that is the teachable defect.

## Expected results
- **With credentials:** `whoami.sh` prints a 12-digit account, your ARN, a
  derived Name, the active Profile and Region, and exits 0. `regions.sh` prints a
  table of ~17+ enabled regions. `inventory.sh` prints three sections with totals.
  `cost-guard.sh` prints `== N finding(s) ==` and exits 1 if `N>0`, else 0.
  `tag-audit.sh` prints `== N missing-tag violation(s) ==` and exits 1 if `N>0`.
- **Without credentials:** every script exits 1 with
  `AWS credentials are not usable for this command.` and the real CLI error.
- **Offline suite:** `== 50 passed, 0 failed ==`, exit 0.

## Troubleshooting
**Fixture:** [`broken/whoami-broken.sh`](broken/whoami-broken.sh) — a deliberately
broken copy of `whoami.sh` with two real, reproducible bugs.

| # | Symptom | Cause | Fix |
|---|---------|-------|-----|
| 1 | Script prints blank `Account`/`ARN` and **exits 0** even with no credentials — a scheduled "is my access valid?" check never fires. | The credential probe is run as `aws sts get-caller-identity 2>/dev/null \|\| true`: `\|\| true` discards the non-zero exit status and `2>/dev/null` hides the real error, so a failed probe is treated as success. | Replace with `require_aws_creds` (or an `if ! aws sts get-caller-identity ...; then die ...; fi` block) that **surfaces the error and exits non-zero**. |
| 2 | The `Profile` line always says `default` and `Region` is wrong, even when `AWS_PROFILE`/`AWS_REGION` are set — you can't tell which account was queried. | `Profile` is hard-coded to the literal `default` and `region` is hard-coded to `us-east-1`; `AWS_PROFILE`/`AWS_REGION` are ignored. | Print `${AWS_PROFILE:-default}` and resolve the region with `aws_region` (the helper that honours the CLI precedence chain). |

Reproduce the bug:

```bash
AWS_PROFILE=anything ./broken/whoami-broken.sh ; echo "exit=$?"   # prints blanks, exit=0 (wrong)
AWS_PROFILE=anything ./solution/whoami.sh       ; echo "exit=$?"  # clear error, exit=1 (right)
```

**Other real failures:**
- `The SSO session has expired` / `Error loading SSO Token` → run
  `aws sso login --profile "$AWS_PROFILE"` (see `sso-config.md`).
- `An error occurred (UnauthorizedOperation)` on a Describe call → the role lacks
  the read permission; attach a ReadOnlyAccess-style policy.
- Empty `Region` line → set `AWS_REGION` or add `region =` to the profile;
  `inventory.sh`/`cost-guard.sh` scan the resolved region only.

## Cleanup
**Nothing to clean up.** Every script is strictly read-only — it creates no AWS
resources, writes no tags, and leaves no local state beyond stdout/stderr. The
offline test suite builds a `mktemp -d` sandbox and removes it via an `EXIT`
trap. To remove a configured SSO session from a shared host:

```bash
aws sso logout            # clears the cached short-lived token
```

## Security considerations
- **Least privilege.** The toolkit needs only `sts:GetCallerIdentity`,
  `ec2:Describe*`, `s3:ListAllMyBuckets`, and `iam:ListUsers`. Grant a
  ReadOnlyAccess-style permission set — **never** write/admin for this lab.
- **Read-only by construction.** No script calls a mutating verb; the test suite
  enforces this with a static `grep` gate over `solution/`. Adding a `create`/
  `delete`/`put`/`modify`/`tag`/`run-instances` call would fail validation.
- **No secrets on disk.** Prefer SSO (`aws configure sso`) over long-lived access
  keys — short-lived tokens expire automatically and centralise revocation. Do
  **not** commit `~/.aws/credentials`, access keys, account IDs in examples, or
  SSO start URLs. See [`solution/sso-config.md`](solution/sso-config.md).
- **Fail closed.** `require_aws_creds` exits non-zero on any auth failure, so the
  toolkit never operates against an unintended or unauthenticated context — the
  exact failure the `broken/` fixture demonstrates by failing *open*.

## Cost considerations
- **Running the scripts is `$0`.** `Describe*` / `List*` / `Get*` /
  `GetCallerIdentity` API calls are free; the toolkit creates nothing billable.
- **The point of the toolkit is to *save* money.** `cost-guard.sh` surfaces the
  classic leftover costs so you can delete them: idle Elastic IPs (~$3.6/mo
  each), NAT gateways (~$32/mo + data each), detached EBS volumes (per GiB-month),
  and forgotten running instances. Run it per region you use (loop over
  `regions.sh`) on a schedule.
- **Stay at $0:** this lab never provisions anything. If you later create test
  resources to exercise `cost-guard.sh`/`tag-audit.sh` against real findings,
  delete them afterward — the scripts only *report*, they do not remediate.

## Instructor answer key
Reference implementation: [`solution/`](solution/). Grading points:

- **`require_aws_creds` must not swallow the error** — the single most important
  point. A solution that uses `|| true` or hides stderr, or that prints identity
  before checking auth, is wrong even if it "works" with valid creds. Test by
  running with `AWS_PROFILE=nonexistent`: it must exit non-zero with a clear
  message (the `broken/` fixture is the anti-pattern).
- **`aws_region` must honour CLI precedence** (`AWS_REGION` → `AWS_DEFAULT_REGION`
  → `aws configure get region`), not hard-code a region.
- **Read-only only.** Any mutating verb is an automatic fail; the static gate in
  `tests/run-tests.sh` enforces it. Common wrong answer: using
  `aws ec2 create-tags` to "fix" `tag-audit.sh` findings — the script audits, it
  must not remediate.
- **`cost-guard.sh`/`tag-audit.sh` exit codes** must be non-zero on findings so
  they work as gates; a solution that always exits 0 fails the stub test.
- **Mount/space-safe parsing & quoting** — quote `"$mount"`-style fields and
  handle the `None`/empty-tag case in `tag-audit.sh` (untagged resources must
  still be flagged, not skipped).
- **Common wrong answers:** depending on `jq` (not guaranteed present — use
  `--query`/`--output text`); forgetting `--all-regions` semantics in
  `regions.sh`; treating an empty `Describe` result as an error instead of
  `(none)`.

### Class Artifacts & Validation
| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | solution/lib/common.sh | shell | shared log/die/region/creds helpers | `shellcheck -x` + `bash -n` | PASS |
| 2 | solution/whoami.sh | shell | sts:GetCallerIdentity identity probe | `shellcheck -x`; live read = $0 | PASS (static); live $0 |
| 3 | solution/regions.sh | shell | ec2:DescribeRegions table | `shellcheck -x`; live read = $0 | PASS (static); live $0 |
| 4 | solution/inventory.sh | shell | read-only EC2/S3/IAM snapshot | `shellcheck -x`; live read = $0 | PASS (static); live $0 |
| 5 | solution/cost-guard.sh | shell | flags running EC2/NAT/EIP/EBS leftovers | `shellcheck -x`; stub test | PASS |
| 6 | solution/tag-audit.sh | shell | lists resources missing required tags | `shellcheck -x`; stub test | PASS |
| 7 | solution/sso-config.md | docs | aws configure sso walkthrough | gate: file present | PASS |
| 8 | broken/whoami-broken.sh | shell | false-success / ignores AWS_PROFILE | stub test reproduces bug | PASS |
| 9 | tests/run-tests.sh | shell | 50 offline functional assertions | `bash tests/run-tests.sh` | PASS (50/50) |
| 10 | validate.sh | shell | module gate runner | `./validate.sh` | PASS (exit 0) |
