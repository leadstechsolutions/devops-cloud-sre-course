# Module: setup-validation

> **Status:** Validated — every gate in `validate.sh` runs and passes in this
> environment (bash 5.1, shellcheck 0.10.0). `solution/setup-check.sh` detects the
> live toolchain and exits 0 because git 2.34, python 3.10.12, docker 29.1.2,
> terraform 1.14.1, aws 2.32.11, and kubectl 1.34.2 are all installed and meet the
> minimums; the 44-assertion test suite passes; the `broken/` fixture reproducibly
> mis-ranks `3.9 > 3.10`. Captured output is under [Validation](#validation).
> **Maps to:** Week 01 Class 01 (Course Orientation & Environment Setup). This is
> the very first thing a student runs to confirm their machine is course-ready; the
> `version_ge` helper is the reusable primitive behind every "is my tool new enough?"
> check used in later weeks.

## What you will build

A small, dependency-free **toolchain preflight checker** in Bash. Running
`./setup-check.sh` detects each tool the course needs (`git`, `python3`, `docker`,
`terraform`, `aws`, `kubectl`, plus optional `helm`/`kind`), parses its version out of
noisy CLI output, compares it against a minimum using **correct numeric semver
ordering**, and prints `PASS` / `FAIL` / `WARN` with a one-line remediation hint for
anything missing or too old. The script exits non-zero if any **required** tool is
absent or below its minimum, so it can gate a setup step or a CI job. A companion
`print-report.sh` renders a paste-ready table (text or Markdown).

The pedagogical core is one function, `version_ge`, and one classic bug: comparing
versions as **strings** makes `"3.9"` sort *after* `"3.10"`. You implement the correct
numeric comparison; the `broken/` fixture shows the wrong one failing in the wild.

## Prerequisites

- `bash >= 4` (uses arrays and `[[ ... =~ ]]`; bash 5.1 here).
- Course tools to *detect* (they do not all need to be installed for the lab to run —
  the checker's whole job is to tell you which are missing):
  `git >= 2.30`, `python3 >= 3.10`, `docker >= 24`, `terraform >= 1.6`, `aws >= 2`,
  `kubectl >= 1.27`; optional `helm >= 3.12`, `kind >= 0.20`.
- `shellcheck` to run the lint gate (optional; the gate self-skips if absent).
- No accounts, no network, no cloud credentials, no root.

## Architecture

```
   ./setup-check.sh ──┐                 ./print-report.sh ──┐
                      │  sources                            │  sources
                      ▼                                     ▼
              lib/check.sh  ──  detect_version(cmd) ── run "cmd --version", capture
                      │                              │
                      │         extract_version(s) ──┴─ grep first vN.N.N token
                      │
                      ├─ normalize_version(raw)  strip 'v', '-pre', '+build' → 1.6.0
                      ├─ version_ge(have, want)  split on '.', compare each field as int
                      └─ check_tool(...)         PASS/FAIL/WARN + hint, bump counters
```

`lib/check.sh` is a sourced library (no `set -e` of its own); the two entrypoints own
their shell options and just wire the tool matrix into `check_tool`. All diagnostics go
to stderr so stdout stays a clean report.

## Repository layout

```
starter/    # entrypoints are complete; lib/check.sh has version_ge() TODO'd — you fill it
  lib/check.sh
  setup-check.sh
  print-report.sh
solution/   # reference implementation — correct numeric version_ge
  lib/check.sh
  setup-check.sh
  print-report.sh
broken/     # setup-check-broken.sh — REAL string-compare bug (3.9 > 3.10)
tests/      # run-tests.sh — 44 assertions over fake versions + the broken fixture
validate.sh # runs every gate; exits non-zero on any failure
```

## Setup

From a fresh clone, nothing to install for the lab itself:

```bash
cd labs/setup-validation
./solution/setup-check.sh        # see the reference checker run against your machine
```

To do the lab, work in `starter/` and run the tests as you go:

```bash
cd labs/setup-validation
bash tests/run-tests.sh          # fails until you implement version_ge in starter/lib/check.sh
```

> The test suite sources `solution/lib/check.sh` (the reference) so it always shows you
> the target behaviour. To test **your** implementation, point it at your file, e.g.
> `SOL=starter bash -c 'source starter/lib/check.sh; version_ge 3.10 3.9 && echo OK'`,
> or temporarily copy your `version_ge` into `solution/lib/check.sh` and re-run.

## Lab tasks

1. **Implement `version_ge` in `starter/lib/check.sh`.**
   Replace the `TODO(student)` body so it compares versions *numerically*, field by
   field, with missing trailing fields treated as `0`.
   **Done when:** `source starter/lib/check.sh; version_ge 3.10 3.9 && echo yes`
   prints `yes`, and `version_ge 3.9 3.10 && echo yes || echo no` prints `no`.

2. **Run the checker against your own machine.**
   `./starter/setup-check.sh` — every installed, new-enough tool shows `[PASS]`; a
   missing/old required tool shows `[FAIL]` with a remediation hint and the script
   exits non-zero.
   **Done when:** the exit code matches reality — `echo $?` is `0` only if every
   required tool is present and new enough.

3. **Generate a report.**
   `./starter/print-report.sh` (text) and `./starter/print-report.sh --md` (Markdown).
   **Done when:** the table lists every tool with `ok` / `too-old` / `MISSING` and the
   verdict line agrees with `setup-check.sh`.

4. **Pass the full suite.**
   `bash tests/run-tests.sh` — once your `version_ge` is correct (and copied into
   `solution/lib/check.sh`, which the tests source), all 44 assertions pass.
   **Done when:** the suite prints `44 passed, 0 failed`.

## Validation

`./validate.sh` runs every gate. Real output from this environment:

```
== validating setup-validation ==
  [PASS] bash -n broken/setup-check-broken.sh
  [PASS] bash -n solution/lib/check.sh
  [PASS] bash -n solution/print-report.sh
  [PASS] bash -n solution/setup-check.sh
  [PASS] bash -n starter/lib/check.sh
  [PASS] bash -n starter/print-report.sh
  [PASS] bash -n starter/setup-check.sh
  [PASS] bash -n tests/run-tests.sh
  [PASS] bash -n validate.sh
  [PASS] tests/run-tests.sh (functional)
  [PASS] solution/setup-check.sh exits 0 (toolchain READY)
  [PASS] solution/print-report.sh exits 0
-- shellcheck 0.10.0
  [PASS] shellcheck -x solution/lib/check.sh (clean)
  [PASS] shellcheck -x solution/print-report.sh (clean)
  [PASS] shellcheck -x solution/setup-check.sh (clean)
  [PASS] shellcheck -x validate.sh (clean)
  [PASS] shellcheck -x tests/run-tests.sh (clean)
  [PASS] shellcheck -x broken/setup-check-broken.sh (clean)
  [INFO] shellcheck starter/lib/check.sh: SC2034 (expected — TODO student gap)
  [INFO] shellcheck starter/print-report.sh clean
  [INFO] shellcheck starter/setup-check.sh clean
== 18 passed, 0 failed ==
```

`exit 0`. The `[INFO]` line for `starter/lib/check.sh` is intentional: the unfinished
`version_ge` leaves its `have`/`want` locals unused (SC2034), which is the marker that
the student gap is still open — it is reported, never failed.

## Expected results

`./solution/setup-check.sh` on a fully-provisioned course machine:

```
== toolchain check ==
[PASS] git         2.34.1     (need >= 2.30)
[PASS] python3     3.10.12    (need >= 3.10)
[PASS] docker      29.1.2     (need >= 24)
[PASS] terraform   1.14.1     (need >= 1.6)
[PASS] aws         2.32.11    (need >= 2)
[PASS] kubectl     1.34.2     (need >= 1.27)
[PASS] helm        3.16.3     (need >= 3.12)
[PASS] kind        0.24.0     (need >= 0.20)

== summary: 8 pass, 0 fail, 0 warn ==
RESULT: READY — required toolchain satisfied.
```

`./solution/print-report.sh --md`:

```
| Tool | Found | Min | Status |
|------|-------|-----|--------|
| git | 2.34.1 | 2.30 | ok |
| python3 | 3.10.12 | 3.10 | ok |
| docker | 29.1.2 | 24 | ok |
| terraform | 1.14.1 | 1.6 | ok |
| aws | 2.32.11 | 2 | ok |
| kubectl | 1.34.2 | 1.27 | ok |
| helm | 3.16.3 | 3.12 | ok |
| kind | 0.24.0 | 0.20 | ok |

verdict: READY — required toolchain satisfied.
```

On a machine missing/old tools you would instead see `[FAIL] ... -- too old` /
`-- not installed` lines (each with a `hint:`), a non-zero summary, `RESULT: NOT READY`,
and exit code `1`. Optional tools (`helm`, `kind`) show `[WARN]` and do **not** fail.

## Troubleshooting

**Real, reproducible broken state — the string-compare bug.** `broken/setup-check-broken.sh`
is a copy of the checker whose `version_ge` compares versions as strings:

```bash
$ ./broken/setup-check-broken.sh
== toolchain check (BROKEN fixture) ==
[PASS] git         2.34.1     (need >= 2.30)
[PASS] python3     3.10.12    (need >= 3.10)
[FAIL] terraform   1.14.1     (need >= 1.6) -- too old      # <-- WRONG
== done (fail=1) ==
```

- **Symptom:** terraform 1.14.1 is flagged "too old" against a minimum of 1.6, and the
  script exits 1 on a perfectly fine machine.
- **Cause:** `[[ "1.14.1" > "1.6" ]]` is a *lexicographic string* comparison. Character
  by character, `'1' == '1'`, then `'.' == '.'`, then `'1' < '6'` — so the string
  `"1.14.1"` is judged **less than** `"1.6"`. The exact same bug makes `"3.9"` rank
  *above* `"3.10"`, so a too-old Python 3.9 would be wrongly accepted.
- **Fix:** split each version on `.` and compare field by field as integers
  (`(( 10#$have_field > 10#$want_field ))`). That is precisely what
  `solution/lib/check.sh:version_ge` does.

`tests/run-tests.sh` asserts the broken fixture *still* gets `3.9 >= 3.10` wrong, so if
anyone "tidies" the fixture into correctness the suite fails and flags the silent repair.

**Other gotchas the lab guards against:**

- *A tool prints its version to stderr* (e.g. some `--version` output) — `detect_version`
  captures `2>&1`, so this is handled.
- *Build metadata in the version* (`helm` prints `v3.16.3+gcfd0749`) — `normalize_version`
  strips `+...` and a leading `v`.
- *Leading-zero fields parsed as octal* (`08`, `09`) — `version_ge` forces base 10 with
  `10#`.

## Cleanup

Nothing to tear down. The scripts create no files, no processes, no cloud resources, and
make no network calls; the test suite uses a `mktemp -d` sandbox that an `EXIT` trap
removes. Idempotent by construction — re-run as often as you like.

```bash
# nothing to clean; optional sanity check that no stray temp dirs were left:
ls /tmp | grep -c 'tmp\.' || true
```

## Security considerations

- **No secrets, no credentials.** The checker never reads `~/.aws`, never calls a cloud
  API, never touches the network. It only runs `<tool> --version`, so there is nothing
  sensitive to leak in its output or its committed report.
- **Untrusted PATH.** The script invokes whatever `git`/`docker`/etc. are first on
  `PATH`. In a hardened CI runner, pin the toolchain (or run in a known image) rather
  than trusting an arbitrary `PATH`; the checker reports *what it found*, it does not
  vouch for *where it came from*.
- **Safe to commit.** The generated report contains only tool names and version numbers
  — fine to paste into an issue or PR.

## Cost considerations

$0. No cloud resources, no managed services, no data transfer — purely local shell. The
optional tools it detects (`helm`, `kind`) are also free and local.

## Instructor answer key

**The one line that matters** (`solution/lib/check.sh`, `version_ge`): split both
versions on `.` and compare each field numerically, defaulting missing trailing fields
to `0`:

```bash
local -a h w
IFS='.' read -r -a h <<<"$have"
IFS='.' read -r -a w <<<"$want"
local n=${#h[@]}; (( ${#w[@]} > n )) && n=${#w[@]}
local i hv wv
for (( i = 0; i < n; i++ )); do
  hv=$((10#${h[i]:-0})); wv=$((10#${w[i]:-0}))
  (( hv > wv )) && return 0
  (( hv < wv )) && return 1
done
return 0   # all fields equal -> have == want -> >=
```

**Grading points (non-obvious):**

- **Numeric, not string.** The single most common wrong answer is `[[ "$have" > "$want" ]]`
  or `sort -V`-by-hand that still string-compares. Probe it with `version_ge 3.10 3.9`
  (must be true) and `version_ge 3.9 3.10` (must be false). The `broken/` fixture is the
  canonical wrong answer; `tests/run-tests.sh` pins it.
- **Trailing-field defaulting.** `version_ge 1.6 1.6.0` must be true. A solution that
  compares array lengths or bails when lengths differ fails this. Missing fields = 0.
- **Base-10 forcing.** Without `10#`, a field like `08` triggers `value too great for
  base` under `set -e`/arithmetic, or silently mis-parses. Ask why `10#` is there.
- **`>=`, not `>`.** Equal versions must pass (`version_ge 1.6.0 1.6.0` → true). A
  common off-by-one returns 1 on equality.
- **Optional vs required.** Missing `helm`/`kind` must `WARN` and keep the exit code 0;
  missing `git`/`python3`/... must `FAIL` and force a non-zero exit. Check that a
  student who hardcodes "all tools required" is marked down.
- **Version parsing.** `detect_version`/`extract_version` must survive real output
  (`aws-cli/2.32.11 Python/3.13.9 ...`, `Docker version 29.1.2, build 890dcca`,
  `v3.16.3+gcfd0749`). The reference uses a single ERE `grep` + `normalize_version`.

**Reference solution:** `solution/`. **Broken fixture for the troubleshooting exercise:**
`broken/setup-check-broken.sh`. **Test answer key:** every assertion in
`tests/run-tests.sh` is labelled with the behaviour it pins (44 total).

## Class Artifacts & Validation

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `solution/lib/check.sh` | shell | version helpers (`version_ge`, `normalize_version`, `extract_version`, `detect_version`, `check_tool`) | `shellcheck -x solution/lib/check.sh` | PASS |
| 2 | `solution/setup-check.sh` | shell | toolchain preflight checker | `bash solution/setup-check.sh` (exit 0 here) | PASS |
| 3 | `solution/print-report.sh` | shell | text/Markdown summary report | `bash solution/print-report.sh` (exit 0 here) | PASS |
| 4 | `starter/lib/check.sh` | shell | same lib with `version_ge` TODO'd | `bash -n starter/lib/check.sh` | PASS (parses; SC2034 = open gap) |
| 5 | `broken/setup-check-broken.sh` | shell | string-compare bug fixture | `bash tests/run-tests.sh` pins the bug | PASS |
| 6 | `tests/run-tests.sh` | shell | 44-assertion functional suite | `bash tests/run-tests.sh` | PASS (44/0) |
| 7 | `validate.sh` | shell | module gate runner | `./validate.sh` | PASS (18/0, exit 0) |
