# Module: python-automation

> **Status:** Validated — every gate below was run in this environment and PASSED:
> `python3 -m py_compile` on all 11 `.py` files, and `python3 -m unittest` (42 tests,
> `OK`) against `solution/`. The live AWS CLI paths use boto3, which is **not** installed
> here; they are isolated behind `lib/awsclient.py` and exercised by the documented
> commands where boto3 + AWS credentials exist. See the Validation section for captured output.
> **Maps to:** Week 08 Class 02–03 (Python for cloud automation). Reuses the boto3-wrapper
> pattern referenced again in Week 21 (observability automation).

## What you will build
Three small, production-shaped AWS automation tools whose **business logic is pure and
unit-testable with no network and no boto3**: `tag_audit.py` (find resources missing
required tags), `ec2_rightsize.py` (recommend smaller/keep/larger from CPU+memory
utilization), and `cost_report.py` (group and total Cost Explorer rows by service and
render a table). The single point that touches AWS is a thin wrapper, `lib/awsclient.py`,
with a guarded boto3 import so the whole package still compiles and tests run on a CI box
that has neither boto3 nor AWS access. The end state: `./validate.sh` is green, 42 stdlib
`unittest` tests pass, and each CLI runs against a real account once you install boto3.

## Prerequisites
- `python >= 3.10` (uses `X | None` type syntax and `dict[...]` generics). This env: 3.10.12.
- No accounts/access needed for the lab itself or the tests — everything offline.
- For the **live CLI** paths only: `pip install -r solution/requirements.txt` (boto3) and
  AWS credentials with read-only permissions: `ec2:DescribeInstances`,
  `cloudwatch:GetMetricStatistics`, `ce:GetCostAndUsage`.
- Prior modules: none required. The `lib/awsclient.py` pattern recurs in later weeks.

## Architecture
See [`docs/architecture.mmd`](docs/architecture.mmd) (Mermaid). In words: the CLI
entrypoints (`main()` in each tool) call `lib/awsclient.py` to fetch data from AWS
(EC2 / CloudWatch / Cost Explorer), hand the **already-fetched plain dicts/lists** to pure
functions (`audit_resources`, `recommend`, `summarize`), and print the result. `boto3` is
imported in exactly one file, behind a `try/except ImportError`, so the pure functions and
the `tests/` (stdlib `unittest`, hand-built fixtures) import and run with no network and no
SDK installed.

## Repository layout
```
starter/    # intentionally incomplete — the core comparison/threshold logic is TODO'd
  lib/awsclient.py   tag_audit.py   ec2_rightsize.py   cost_report.py   requirements.txt
solution/   # reference implementation — passes every gate
  lib/awsclient.py   tag_audit.py   ec2_rightsize.py   cost_report.py   requirements.txt
tests/      # stdlib unittest, no AWS: test_tag_audit.py / test_ec2_rightsize.py / test_cost_report.py
docs/architecture.mmd
validate.sh # runs the module's gates; exits non-zero on any failure
```

## Setup
From a fresh clone, no installation is needed to do the lab or run the tests:
```bash
cd labs/python-automation
./validate.sh                       # baseline: solution green, starter red (expected)
# do the lab in starter/ ; check yourself against solution/
PYTHONPATH=starter python3 -m unittest discover -s tests -p 'test_*.py'   # your progress
```
Only if you want to run the tools against a real account:
```bash
pip install -r solution/requirements.txt   # boto3
cd solution && PYTHONPATH=. python3 tag_audit.py --required Owner CostCenter Environment
```

## Lab tasks
Work in `starter/`. Each TODO is marked `# TODO(student): ...`. Run the matching test file
after each one.

1. **`starter/tag_audit.py` → `missing_tags`** — build the list of required keys that are
   absent OR present-but-empty (`""`/`None`), sorted.
   *Done when:* `PYTHONPATH=starter python3 -m unittest tests.test_tag_audit` is `OK`.
2. **`starter/ec2_rightsize.py` → `recommend`** — implement the peak-based rule: `larger`
   if either peak `>= high`; `smaller` if both peaks `< low`; else `keep`. Mind the
   boundaries (`>=` high inclusive, `<` low strict).
   *Done when:* `PYTHONPATH=starter python3 -m unittest tests.test_ec2_rightsize` is `OK`.
3. **`starter/cost_report.py` → `summarize`** — accumulate per-service totals (a service
   can appear in several rows), sort by cost desc then name asc, round to cents, and
   compute the grand total.
   *Done when:* `PYTHONPATH=starter python3 -m unittest tests.test_cost_report` is `OK`.
4. **All green** — `PYTHONPATH=starter python3 -m unittest discover -s tests -p 'test_*.py'`
   reports `Ran 42 tests ... OK`. Your `starter/` now matches `solution/` behavior.

## Validation
`./validate.sh` runs all gates. Real captured output from this environment:

```
== validating python-automation ==
  [PASS] py_compile: all .py files (syntax)
  [PASS] unittest: solution passes all tests
  [PASS] starter is incomplete (tests fail until TODOs are done)
== 3 passed, 0 failed ==
```

Gate detail and the exact commands:

| Gate | Command | Result here |
|------|---------|-------------|
| Syntax | `python3 -m py_compile $(find solution tests starter -name '*.py')` | **PASS** |
| Unit tests (solution) | `PYTHONPATH=solution python3 -m unittest discover -s tests -p 'test_*.py'` | **PASS** — `Ran 42 tests ... OK` |
| Starter is incomplete | (same, `PYTHONPATH=starter`) must **fail** | **PASS** (fails: 11 failures, 11 errors until TODOs done) |
| boto3-free import | `python3 -c "from lib import awsclient; print(awsclient.boto3_available())"` (from `solution/`) | **PASS** — prints `False`, no crash |
| **Live** CLI (DEFERRED) | `pip install -r requirements.txt && PYTHONPATH=. python3 tag_audit.py --required Owner CostCenter` | **DEFERRED** — boto3 not installed in this build env; runs where boto3 + AWS creds exist |

Captured `unittest -v` tail (solution):
```
Ran 42 tests in 0.005s

OK
```

## Expected results
- **Tests:** `Ran 42 tests in ~0.00s` then `OK`. Exit code 0.
- **`tag_audit` (pure) sample:**
  ```
  NON-COMPLIANT: 1 resource(s) missing required tags

    i-0a (ec2:instance): missing CostCenter
  ```
- **`ec2_rightsize` (pure) sample:**
  ```
  i-hot: larger  (cpu_peak=92.0%, mem_peak=55.0%)
  i-idle: smaller (cpu_peak=8.0%, mem_peak=12.0%)
  i-fine: keep    (cpu_peak=50.0%, mem_peak=45.0%)
  ```
- **`cost_report` (pure) sample:**
  ```
  +------------+------------+
  | SERVICE    | COST (USD) |
  +------------+------------+
  | Amazon EC2 |   1,550.55 |
  | Amazon S3  |      88.20 |
  | AWS Lambda |      12.34 |
  +------------+------------+
  | TOTAL      |   1,651.09 |
  +------------+------------+
  ```
- **`tag_audit` live CLI** exits `1` when any resource is non-compliant (so cron/CI can gate on it), `0` when clean.

## Troubleshooting
Real, reproducible failures from this lab:

| Symptom | Cause | Fix |
|---------|-------|-----|
| `ModuleNotFoundError: No module named 'tag_audit'` when running tests | `PYTHONPATH` not set, so `import tag_audit` can't find the impl dir | Run via `PYTHONPATH=solution` (or `starter`) — `validate.sh` does this for you. |
| `RuntimeError: boto3 is not installed...` | You called a **live** path (`get_session`, the CLI) without boto3 | `pip install -r requirements.txt`. The pure functions and tests never need it — this error is the wrapper failing loudly on purpose, not a bug. |
| Starter: `NotImplementedError: implement recommend()` | The `recommend` TODO isn't done yet | Implement task 2. Expected until you do. |
| `test_boundary_low_exclusive` fails after your edit | You used `<=` instead of `<` for the low threshold | Low is strict (`<`): peak `== 20` must be `keep`, not `smaller`. |
| `test_uses_peak_not_average` fails | You averaged the samples instead of taking the peak | Right-size on `max(...)`; averaging hides spikes and causes throttling/OOM after downsizing. |
| `cost_report` total is wrong for a multi-day window | You overwrote per-service totals instead of accumulating | Cost Explorer returns one group per service *per time bucket*; `+=`, don't `=`. |

There is no separate `broken/` fixture: the **starter is the reproducible broken state** —
it compiles but its tests fail with concrete, diffable assertions until the three core-logic
TODOs are completed. That is the troubleshooting exercise.

## Cleanup
Nothing is created that needs tearing down. The lab writes no cloud resources and no local
state beyond Python's `__pycache__/`. To reset:
```bash
find labs/python-automation -name '__pycache__' -type d -prune -exec rm -rf {} +
```
The live CLIs are **read-only** (Describe/Get calls); even running them against AWS creates
nothing to clean up.

## Security considerations
- **No secrets in code.** The wrapper uses boto3's default credential chain (env vars,
  SSO, instance role) or a named `--profile`; nothing is hard-coded. Never commit
  `~/.aws/credentials`.
- **Least privilege.** The live paths need only `ec2:DescribeInstances`,
  `cloudwatch:GetMetricStatistics`, and `ce:GetCostAndUsage` — all read-only. Grant exactly
  those, nothing broader.
- **Dependency scanning.** `requirements.txt` pins boto3 to `>=1.34,<2.0`; run `pip-audit`
  (or your org's scanner) in CI before installing. The lab and tests install nothing.
- **Don't commit** `__pycache__/`, real account IDs, or cost exports.

## Cost considerations
- The lab and unit tests cost **$0** — entirely offline, no AWS calls.
- The live CLIs are read-only and mostly free, with one caveat: **AWS Cost Explorer charges
  $0.01 per `GetCostAndUsage` request** (the API, not the console). `cost_report.py` makes
  one request per page; a single monthly run is ~$0.01. EC2 `Describe*` and CloudWatch
  `GetMetricStatistics` within the free CloudWatch API tier are effectively free for this
  scale. To stay at **$0**, simply don't run the live `cost_report.py` path — the pure
  logic and its tests need no API at all.

## Instructor answer key
The reference implementation is in [`solution/`](solution/). Grading points that are easy
to get wrong:

- **Threshold boundaries** (`ec2_rightsize.recommend`): high is **inclusive** (`>=`), low
  is **strict** (`<`). `test_boundary_high_inclusive` and `test_boundary_low_exclusive`
  pin both; a `<=`/`>` slip passes the obvious cases but fails the edges.
- **Peak, not average** (`recommend`): students who average the samples pass the easy tests
  but fail `test_uses_peak_not_average`. Discuss *why* (spikes → throttling/OOM).
- **Empty tag value = missing** (`tag_audit.missing_tags`): `Owner=""` must count as
  missing, not present. Common wrong answer checks only `key not in tags`.
- **Accumulate, don't overwrite** (`cost_report.summarize`): the same service appears once
  per time bucket; `=` instead of `+=` silently undercounts. `test_groups_and_totals` uses
  EC2 twice to catch this.
- **boto3 isolation:** check that the student kept AWS calls out of the pure functions. If
  any pure function imports boto3 at module top, the tests would need the SDK — a design
  failure even if tests happen to pass on a box that has it. The guarded import in
  `lib/awsclient.py` and the lazy `from lib.awsclient import ...` inside `_fetch_*` are the
  correct pattern.
- Full suite: `PYTHONPATH=solution python3 -m unittest discover -s tests -p 'test_*.py'`
  must report **`Ran 42 tests ... OK`**.
