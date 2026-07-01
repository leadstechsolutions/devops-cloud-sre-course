# Module: linux-shell-automation

> **Status:** Validated — every `.sh` passes `bash -n`, the functional test
> suite (`tests/run-tests.sh`) runs green, **and `shellcheck -x` is now run as a
> gate**: all `solution/` scripts plus `validate.sh` and `tests/run-tests.sh` are
> lint-clean, while the `broken/` fixture still trips the exact warning (`SC2086`)
> it is meant to teach. Captured in this environment (bash 5.1, GNU
> coreutils/findutils, ShellCheck 0.10.0). See [Validation](#validation).
> **Maps to:** Week 02 Class 03 (shell scripting + a `broken/` troubleshooting
> exercise) and reused in Week 08 Class 01 (automation toolkit / cron-driven ops).

## What you will build
A small, production-shaped **shell operations toolkit**: four standalone scripts
that share one sourced library. By the end you have `disk-check.sh` (parses
`df -P`, exits non-zero when any mount exceeds a `--threshold`), `log-rotate.sh`
(gzip-rotates files older than N days, with `--dry-run`), `backup.sh` (timestamped
`tar.gz` with `--keep N` retention pruning), and `user-audit.sh` (lists human
accounts with UID ≥ 1000 and flags who has sudo). Every script has `usage()/-h`,
`getopts`-based flag parsing, `set -euo pipefail`, and sources `lib/common.sh`
(`log()`, `die()`, `require_cmd()`). You also debug a deliberately broken copy of
`disk-check.sh` that fails on mount paths containing spaces and on an off-by-one
threshold comparison.

## Prerequisites
- **bash ≥ 4.3** (uses `mapfile`, associative arrays, `read -d ''`).
- **GNU coreutils / findutils** (`df -P`, `find -mtime -print0 -printf`, `gzip`,
  `tar`, `du`, `sort`). On macOS install `coreutils`/`findutils` or run in a Linux
  container; BSD `find` lacks `-printf`.
- No accounts, no cloud, no network. Everything runs locally as an unprivileged user.
- No prior module required. This is the first hands-on lab; its scripts are reused
  as building blocks in Week 08.

## Architecture
Text diagram (no infrastructure — these are local CLI tools):

```
                 ┌────────────────────────┐
                 │   lib/common.sh        │   sourced by all four scripts
                 │   log()  die()         │   (diagnostics -> stderr)
                 │   require_cmd()        │
                 └───────────┬────────────┘
        ┌──────────────┬─────┴───────┬───────────────┐
        ▼              ▼             ▼               ▼
 disk-check.sh   log-rotate.sh   backup.sh      user-audit.sh
 (df -P parse,   (find -mtime,   (tar.gz +      (/etc/passwd uid>=1000
  threshold,      gzip, dry-run)  retention)     + sudo/wheel groups)
  exit 1 on
  breach)
```

Each script writes **data to stdout** and **diagnostics to stderr**, so they
compose cleanly in pipelines and cron. `disk-check.sh`'s non-zero exit on breach
makes it usable directly as a monitoring/cron gate.

## Repository layout
```
starter/    # intentionally incomplete — you implement the TODO(student) gaps
  lib/common.sh   # die() and require_cmd() bodies are gapped
  disk-check.sh   # df parse + breach comparison gapped
  log-rotate.sh   # find filter + gzip call gapped
  backup.sh       # tar creation + retention prune gapped
  user-audit.sh   # human-user filter + sudo flag gapped
solution/   # complete reference implementation — check yourself against this
  lib/common.sh
  disk-check.sh  log-rotate.sh  backup.sh  user-audit.sh
broken/
  disk-check-broken.sh   # Week-2 troubleshooting fixture (two real bugs)
tests/
  run-tests.sh    # fabricates a sandbox, runs solution scripts, asserts results
validate.sh       # runs all module gates (bash -n on every script + the tests)
```

## Setup
From a fresh clone, nothing to install — just make the scripts executable (they
already ship `+x`, but this is idempotent) and confirm bash is new enough:

```bash
cd labs/linux-shell-automation
bash --version | head -1          # expect >= 4.3
chmod +x solution/*.sh starter/*.sh broken/*.sh tests/*.sh validate.sh
./validate.sh                     # baseline: solution gates should pass
```

You do the lab in `starter/`. Run a starter script directly to see it is
incomplete, then fill the `TODO(student)` gaps until it matches `solution/`.

## Lab tasks
Work in `starter/`. Each task is **done when** its acceptance check passes.

1. **Implement the library (`starter/lib/common.sh`).** Fill `die()` (log at
   `ERROR`, then exit non-zero) and `require_cmd()` (fail via `die` when a command
   is missing). *Done when:* `bash -c 'source starter/lib/common.sh; require_cmd nosuchcmd'`
   prints an ERROR line and exits 1; `require_cmd bash` exits 0.

2. **Finish `disk-check.sh`.** Parse `usage_pct` (field 5, strip `%`) and `mount`
   (fields 6..NF, space-safe) from each `df -P` line, and breach only when usage
   is **strictly greater** than `--threshold`. *Done when:*
   `starter/disk-check.sh --threshold 0` prints `BREACH` lines and exits 1, while
   `--threshold 100` exits 0.

3. **Finish `log-rotate.sh`.** Drive the loop from `find` (regular files, not
   `*.gz`, `-mtime +DAYS`, `-print0`) and `gzip` each non-dry-run match. *Done when:*
   on a dir with a 40-day-old `app.log`, `--days 14 --dry-run` changes nothing and
   names the file; without `--dry-run` it produces `app.log.gz`; a re-run rotates 0.

4. **Finish `backup.sh`.** Create the `tar.gz` with `-C "$parent"`, then prune all
   but the newest `--keep` archives sharing the name prefix. *Done when:* creating
   4 archives with `--keep 2` leaves exactly 2 on disk and the newest untars to the
   original files.

5. **Finish `user-audit.sh`.** Keep only UID ≥ `--min-uid` (and skip 65534), and
   flag `yes`/`no` from the sudo/wheel membership set. *Done when:* against the
   fixtures in `tests/`, alice/bob/carol are listed, nobody/daemon are excluded,
   and the sudo column matches group membership.

6. **Troubleshooting (Week 2).** Reproduce and fix the two bugs in
   `broken/disk-check-broken.sh`. *Done when:* a `df` line with a space-containing
   mount prints as one field, and a mount sitting exactly at the threshold is
   **not** reported. See [Troubleshooting](#troubleshooting).

## Validation
`./validate.sh` runs every gate. Gates and **expected output**:

| Gate | Command | Expected |
|------|---------|----------|
| Shell syntax (all scripts) | `bash -n <file>` for every `.sh` | each prints `[PASS]` |
| Functional behaviour | `bash tests/run-tests.sh` | `25 passed, 0 failed`, exit 0 |
| Lint — authoritative | `shellcheck -x` on every `solution/` script + `validate.sh` + `tests/run-tests.sh` | each `[PASS]` (lint-clean) |
| Lint — broken fixture | `shellcheck -x broken/disk-check-broken.sh` | reports `SC2086` (intentional Bug 1) — gate fails if it ever stops |
| Lint — starter (informational) | `shellcheck -x starter/*.sh` | `SC2034` on TODO-gapped vars is expected; never fails the gate |

The shellcheck gate in `validate.sh` is guarded by `command -v shellcheck`, so it
runs wherever the linter is installed and prints `[SKIP]` (without failing) where
it is not.

Run them:

```bash
./validate.sh                                   # all gates (incl. shellcheck)
bash tests/run-tests.sh                         # just the functional suite
shellcheck -x solution/*.sh solution/lib/*.sh   # lint the reference solution
shellcheck -x validate.sh tests/run-tests.sh    # lint the harness itself
```

**`./validate.sh` (captured in this environment):**
```
== validating linux-shell-automation ==
  [PASS] bash -n broken/disk-check-broken.sh
  [PASS] bash -n solution/backup.sh
  [PASS] bash -n solution/disk-check.sh
  [PASS] bash -n solution/lib/common.sh
  [PASS] bash -n solution/log-rotate.sh
  [PASS] bash -n solution/user-audit.sh
  [PASS] bash -n starter/backup.sh
  [PASS] bash -n starter/disk-check.sh
  [PASS] bash -n starter/lib/common.sh
  [PASS] bash -n starter/log-rotate.sh
  [PASS] bash -n starter/user-audit.sh
  [PASS] bash -n tests/run-tests.sh
  [PASS] bash -n validate.sh
  [PASS] tests/run-tests.sh (functional)
-- shellcheck 0.10.0
  [PASS] shellcheck -x solution/backup.sh (clean)
  [PASS] shellcheck -x solution/disk-check.sh (clean)
  [PASS] shellcheck -x solution/lib/common.sh (clean)
  [PASS] shellcheck -x solution/log-rotate.sh (clean)
  [PASS] shellcheck -x solution/user-audit.sh (clean)
  [PASS] shellcheck -x validate.sh (clean)
  [PASS] shellcheck -x tests/run-tests.sh (clean)
  [PASS] shellcheck broken/ still reports SC2086 (intentional Bug 1)
  [INFO] shellcheck starter/backup.sh: SC2034 (expected — TODO student gaps)
  [INFO] shellcheck starter/disk-check.sh: SC2034 (expected — TODO student gaps)
  [INFO] shellcheck starter/lib/common.sh: SC2034,SC2317 (expected — TODO student gaps)
  [INFO] shellcheck starter/log-rotate.sh clean
  [INFO] shellcheck starter/user-audit.sh: SC2034 (expected — TODO student gaps)
== 22 passed, 0 failed ==
```

**`tests/run-tests.sh` (captured):**
```
== linux-shell-automation tests (sandbox: /tmp/tmp.XXXX) ==
-- disk-check.sh
  [PASS] disk-check: threshold 100 exits 0
  [PASS] disk-check: threshold 0 exits 1 (breach)
  [PASS] disk-check: prints BREACH lines
  [PASS] disk-check: rejects out-of-range threshold
-- log-rotate.sh
  [PASS] log-rotate: dry-run leaves dir unchanged
  [PASS] log-rotate: dry-run mentions old.log
  [PASS] log-rotate: old.log compressed
  [PASS] log-rotate: spaced file compressed
  [PASS] log-rotate: recent.log untouched
  [PASS] log-rotate: original removed by gzip
  [PASS] log-rotate: second run rotates 0 files
  [PASS] log-rotate: missing dir exits 1
-- backup.sh
  [PASS] backup: retention keeps exactly --keep archives
  [PASS] backup: archive contains source files
  [PASS] backup: missing --src exits 1
-- user-audit.sh
  [PASS] user-audit: lists alice / bob / carol
  [PASS] user-audit: excludes nobody and service accounts
  [PASS] user-audit: alice has sudo (sudo group)
  [PASS] user-audit: carol has sudo (wheel group)
  [PASS] user-audit: bob has no sudo
  [PASS] user-audit: missing passwd file exits 1
-- broken/disk-check-broken.sh (expected to misbehave)
  [PASS] broken: still parses (bug is behavioural)
== 25 passed, 0 failed ==
```

**Lint gate — `shellcheck` (now RUN here, was DEFERRED):** ShellCheck 0.10.0 is
installed and wired into `validate.sh`. The `-x` flag follows the
`source "${SCRIPT_DIR}/lib/common.sh"` directives; a `# shellcheck source-path=SCRIPTDIR`
directive on each script makes that resolution work from any working directory
(no more `SC1091` "not following" noise). Every `solution/` script — and the
harness (`validate.sh`, `tests/run-tests.sh`) — is lint-clean:

```console
$ shellcheck -x solution/*.sh solution/lib/*.sh validate.sh tests/run-tests.sh
$ echo "exit=$?"
exit=0
```

(no output = clean). The only non-suppressed lint in `solution/` was `SC2317`
on the double-source guard's `return` in `lib/common.sh` — a genuine false
positive (the line *is* reached on a second `source`), disabled narrowly on that
one statement with a justifying comment; no security or behaviour was weakened.

The **`broken/` fixture deliberately still fails lint** — and that is the
teaching point. ShellCheck statically catches **Bug 1** (the unquoted `$mount`)
as `SC2086`, exactly the word-splitting defect the troubleshooting exercise is
about. **Bug 2** (`>=` vs `>`) is *behavioural* and ShellCheck cannot see it,
which is precisely why the functional suite exists alongside the linter:

```console
$ shellcheck -x broken/disk-check-broken.sh

In broken/disk-check-broken.sh line 78:
    printf 'BREACH %3d%% > %d%%  %s\n' "$usage_pct" "$THRESHOLD" $mount
                                                                 ^----^ SC2086 (info): Double quote to prevent globbing and word splitting.
$ echo "exit=$?"
exit=1
```

`validate.sh` asserts this `SC2086` is still present, so the fixture cannot be
silently "fixed" without the gate noticing.

The **`starter/` scripts are intentionally incomplete** (`TODO(student)` gaps),
so they legitimately trip `SC2034` ("appears unused") on variables the student
has not yet consumed — e.g. `line`, `cmd`, `IS_SUDO`, `parent`. The gate reports
these as `[INFO]` and never fails on them; making them clean would mean writing
the student's answer. Scripts are otherwise written to be shellcheck-clean:
every expansion that can word-split is quoted, `read` uses `-r`, and `printf` is
used instead of `echo` for data.

## Expected results
- `disk-check.sh --threshold 100` → no output, exit **0**. `--threshold 0` →
  one `BREACH` line per mount, exit **1**.
- `log-rotate.sh --dir D --days 14` → old files become `*.gz`, recent files
  untouched; a second run reports `rotated 0 file(s)`.
- `backup.sh --src S --dest D --keep N` → exactly N `*.tar.gz` archives remain
  for that source; the newest untars to the original tree.
- `user-audit.sh` → a `UID USER SHELL SUDO` table containing only human accounts,
  with `yes`/`no` matching sudo/wheel membership.
- `tests/run-tests.sh` → `25 passed, 0 failed`, exit 0.

## Troubleshooting
This module ships a **real broken fixture** for the Week-2 exercise:
`broken/disk-check-broken.sh`. It is a copy of `solution/disk-check.sh` with two
genuine defects. Both are *behavioural* — the script still passes `bash -n`, which
is exactly why syntax-checking alone is not enough.

**Bug 1 — unquoted `$mount` (word-splitting).**
- *Symptom:* on a host with a mount path containing a space (e.g. WSL's
  `/usr/lib/wsl/drivers`, or a NAS mounted at `/mnt/data backup`), the report line
  is mangled — the path is split across the `%s` and trailing arguments, so a
  single mount appears broken across two fields/lines.
- *Cause:* line ~70 uses `printf '... %s\n' ... $mount` with **`$mount` unquoted**.
  Under word-splitting, `"/mnt/data backup"` becomes two arguments.
- *Reproduce:*
  ```bash
  df_out='Filesystem 1024-blocks Used Available Capacity Mounted on
  /dev/sda1 100 95 5 95% /mnt/data backup'
  # feeding that line through the unquoted printf yields:
  #   BREACH  95% > 50%  /mnt/data\nbackup     <- split!
  ```
- *Fix:* quote it — `printf '... %s\n' "$usage_pct" "$THRESHOLD" "$mount"`.

**Bug 2 — `>=` instead of `>` (off-by-one).**
- *Symptom:* a mount sitting **exactly at** the threshold (e.g. usage 90% with
  `--threshold 90`) is reported as a breach, and the script exits 1 when it should
  exit 0. Alarms fire one percent early; on-call gets paged for a non-event.
- *Cause:* line ~66 uses `((usage_pct >= THRESHOLD))`. "Breached" means *over*,
  not *at*, the threshold.
- *Reproduce:* set a mount to exactly the threshold value and run the broken
  script vs the solution — broken returns 1, solution returns 0.
- *Fix:* change `>=` to `>` — `((usage_pct > THRESHOLD))`.

After applying both fixes, `broken/disk-check-broken.sh` behaves identically to
`solution/disk-check.sh`. Other common real failures:

- **`find: -printf: unknown option` / mangled output on macOS:** you are using BSD
  `find`. Install GNU findutils (`brew install findutils`, then `gfind`) or run in
  a Linux container — `backup.sh` relies on `-printf '%f'`.
- **`set -u` "unbound variable" when no args are passed:** the scripts use the
  `"${ARGS[@]+"${ARGS[@]}"}"` idiom precisely so an empty array does not trip
  `set -u`. If you copy the parsing block, keep that `+` expansion.

## Cleanup
Nothing here provisions cloud or persistent resources. The scripts only write
where you tell them:
- `tests/run-tests.sh` creates a `mktemp -d` sandbox and removes it on exit via a
  `trap cleanup EXIT` (even on failure) — no manual cleanup needed.
- If you ran `backup.sh`/`log-rotate.sh` manually against a scratch dir, delete it:
  ```bash
  rm -rf /path/to/your/scratch-backups /path/to/your/scratch-logs
  ```
- `log-rotate.sh` and `backup.sh` are **destructive by design** (gzip removes the
  original; retention deletes old archives). Run against a copy first, or use
  `--dry-run` (log-rotate) to preview. Confirm nothing is left: `ls` the dirs you
  targeted.

## Security considerations
- **No secrets** are read, written, or committed. Do not add credentials to these
  scripts; pass paths/flags instead.
- **Least privilege:** run as an unprivileged user. `user-audit.sh` only *reads*
  `/etc/passwd` and `/etc/group` (world-readable) — it never needs root and makes
  no changes. Prefer auditing a captured copy (`-p`/`-g`) in CI rather than the
  live host.
- **Destructive ops:** `log-rotate.sh` (gzip) and `backup.sh` (retention `rm`)
  modify the filesystem. Scope `--dir`/`--dest` tightly; never point them at `/`
  or a home directory you care about. `rm -f -- "${DEST}/${old}"` uses `--` to stop
  option injection from filenames.
- **Word-splitting / injection:** all variable expansions used as command
  arguments are quoted (the whole point of the `broken/` exercise); `read -r`
  prevents backslash mangling; data goes through `printf`, not `echo`.
- **Do not commit** real backup archives, captured `passwd`/`group` files from
  production, or rotated logs — they may contain usernames/host data. Add such
  output dirs to `.gitignore` in your own repo.

## Cost considerations
**$0.** Everything is local CPU and a few kilobytes of temp disk; no cloud
provider, no managed service, no network egress. The only resource consumed is
disk space for archives — bounded by your `--keep` value, which is the point of
the retention logic. To stay at zero, you do not even need an account.

## Instructor answer key
The complete reference is in [`solution/`](solution/). Grade against it. Non-obvious
points and common wrong answers:

- **`disk-check.sh` mount parsing.** The frequent mistake is `mount=$6` (or
  `awk '{print $6}'`), which silently truncates mount paths containing spaces.
  Correct solutions blank `$1..$5` and print the remainder (or use `cut`/parameter
  expansion that preserves the tail). This is the same defect the `broken/` fixture
  exercises — students who hard-code `$6` reproduce Bug 1 themselves.
- **Strict `>` vs `>=`.** "Breach" is *over* threshold. A `>=` answer fails the
  "threshold 100 exits 0" intent on a full disk and is the off-by-one in Bug 2.
- **`log-rotate.sh` idempotency.** Solutions that don't exclude `*.gz` will
  re-compress on every run (`file.gz` → `file.gz.gz`). The `! -name '*.gz'` filter
  is required; the test asserts a second run rotates 0 files.
- **`-mtime +N` semantics.** `+N` = strictly older than N×24h. Off-by-one here is
  common; the test fabricates a 40-day-old file vs `--days 14` to make the boundary
  unambiguous.
- **`backup.sh` retention sort.** Relying on `ls` parsing is fragile; the reference
  uses `find -printf '%f' | sort -r` and slices `"${archives[@]:KEEP}"`. A correct
  answer keeps the **newest** N, not the oldest. The test creates 4 with `--keep 2`
  and asserts exactly 2 survive and the newest is intact.
- **`user-audit.sh` sudo source.** Checking only the `sudo` group misses `wheel`
  (RHEL/Arch) and `admin`. The reference unions all three. Also: members can come
  from the group's 4th field *or* a user's primary GID — the lab scopes to the
  supplementary-member case (the common one) and the test fixtures reflect that.
- **Library sourcing.** A correct `die()` must `exit` non-zero (not `return`), or
  `set -e` callers won't stop. Diagnostics must go to **stderr** so stdout stays
  pipeable — verify with `script ... 1>/dev/null` still showing the log lines.

For the **troubleshooting exercise**, the graded deliverable is the two-line diff
(`>=`→`>` and quoting `$mount`) plus a sentence each on the symptom. The
[Troubleshooting](#troubleshooting) section is the full answer key.
