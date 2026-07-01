# Module: git-collaboration

> **Status:** Validated — every gate in `validate.sh` runs and passes in this
> environment (bash 5.x, git 2.34). The reference solution actually creates a
> reproducible merge conflict and the hooks actually block secrets/large files;
> output is captured under [Validation](#validation).
> **Maps to:** Week 03 Class 02 (Pull Requests, Code Review, and Merge Conflict
> Resolution). Reused as the hooks/scenario baseline for collaboration practice
> referenced from `01-foundation-track/week-03-git-workflows/`.

## What you will build

A small Git "collaboration toolkit" plus a practice scenario. You build: (1) a
`setup-scenario.sh` that spins up a throwaway repo containing a **reproducible
merge conflict** on a single `replicas:` line so you can practise resolving it;
(2) two client-side Git hooks — a `pre-commit` that refuses to commit AWS keys,
private-key PEM blocks, or files larger than 5 MB, and a `commit-msg` that
enforces Conventional Commits; and (3) an `install-hooks.sh` that symlinks those
hooks into any repo's `.git/hooks/`. End state: you can reproduce a conflict on
demand, resolve it by merge **and** by rebase, and have a repo whose hooks stop
the two most common "oops" commits (a leaked secret, a giant binary).

## Prerequisites

- `git >= 2.23` (uses `git switch`; tested on 2.34).
- `bash >= 4` (uses `mapfile -d`, arrays).
- Standard POSIX `grep`/`sed`. No network, no cloud account, no cost.
- Prior modules: none required. Pairs with Week 3 Class 1 (local Git basics).

## Architecture

Text diagram (no live infrastructure — this is all local Git):

```
setup-scenario.sh --dir <tmp>
        │  git init; commit base (replicas:2)
        │  branch feature/scale-up -> replicas:5
        │  main -> replicas:3
        └─ git merge feature/scale-up  ──►  CONFLICT (UU config.yaml)  ──► you resolve
                                                       (docs/conflict-resolution.md)

install-hooks.sh --target <repo>
        └─ ln -s solution/hooks/{pre-commit,commit-msg}  ->  <repo>/.git/hooks/
                                                                    │
                              git commit  ─────────────────────────┤
                                pre-commit: block secrets / >5MB ───┘
                                commit-msg: enforce Conventional Commits
```

The merge conflict is engineered (same line changed two different ways on two
branches) so it is identical every run; the hooks are version-controlled files
symlinked into a target repo so editing the source updates every install.

## Repository layout

```
starter/                 # intentionally incomplete — you fill the TODO(student) gaps
  setup-scenario.sh      #   self-clean logic + the two conflicting edits are TODO
  install-hooks.sh       #   computing the .git/hooks dir + the symlink are TODO
  hooks/pre-commit       #   secret regexes + large-file test are TODO
  hooks/commit-msg       #   the Conventional Commits regex is TODO
solution/                # complete reference implementation (all gates pass)
  setup-scenario.sh
  install-hooks.sh
  hooks/pre-commit
  hooks/commit-msg
docs/conflict-resolution.md   # worked merge + rebase walkthrough
tests/test_hooks.sh      # black-box behaviour tests for hooks + scenario
validate.sh              # runs this module's gates; non-zero on any failure
```

## Setup

From a fresh clone, no installation is needed — everything is bash + git:

```bash
cd labs/git-collaboration
./validate.sh                      # confirm the reference solution is healthy
./solution/setup-scenario.sh --dir /tmp/conflict-lab   # build a practice conflict
```

To work the lab, edit the files under `starter/` and check yourself against
`solution/`.

## Lab tasks

1. **Make the hooks real.** In `starter/hooks/pre-commit`, replace the four
   `REPLACE_ME_*` regexes with patterns that catch AWS access keys, AWS secret
   keys, PEM `PRIVATE KEY` headers, and any `-----BEGIN` block; implement the
   large-file test against `$MAX_BYTES`.
   *Done when:* staging a file containing `AKIAIOSFODNN7EXAMPLE` and trying to
   commit prints `BLOCKED` and exits non-zero, while a clean commit succeeds.
2. **Enforce Conventional Commits.** In `starter/hooks/commit-msg`, build the
   `types` alternation and full subject `pattern`.
   *Done when:* `git commit -m "updated stuff"` is rejected and
   `git commit -m "fix(api): handle empty payload"` is accepted.
3. **Build the conflict scenario.** In `starter/setup-scenario.sh`, add the
   self-cleaning logic and the two edits that change the same `replicas:` line.
   *Done when:* `./starter/setup-scenario.sh --dir /tmp/lab` leaves
   `git -C /tmp/lab status --porcelain` showing `UU config.yaml`, and re-running
   it rebuilds cleanly (idempotent).
4. **Install the hooks.** In `starter/install-hooks.sh`, compute the target
   repo's hooks dir and create the symlinks.
   *Done when:* after `./starter/install-hooks.sh --target /tmp/lab`,
   `/tmp/lab/.git/hooks/pre-commit` is a symlink and committing a secret there
   is blocked.
5. **Resolve a conflict two ways.** Follow `docs/conflict-resolution.md` to
   resolve the scenario with `git merge`, then again with `git rebase`.
   *Done when:* `grep '^replicas:' config.yaml` shows your chosen value, no
   conflict markers remain (`git diff --check` is clean), and `git log --graph`
   shows a merge commit (Part A) / linear history (Part B).

## Validation

`./validate.sh` runs all gates. Exact commands and the **expected output**:

```bash
# Gate 1 — shell syntax on every script/hook (expect silent success, exit 0)
bash -n solution/hooks/pre-commit        # ...and each other .sh / hook

# Gate 2 — behaviour tests (expect "8 passed/... 9 passed, 0 failed")
bash tests/test_hooks.sh

# Spot check — the scenario really conflicts:
./solution/setup-scenario.sh --dir /tmp/conflict-lab
git -C /tmp/conflict-lab status --porcelain      # expect: UU config.yaml

# Spot check — the hook really blocks a staged secret:
#   (see Expected results for the captured run)
```

Expected `./validate.sh` tail:

```
== 10 passed, 0 failed ==
```

## Expected results

`setup-scenario.sh` leaves this (captured run):

```
$ ./solution/setup-scenario.sh --dir /tmp/conflict-lab
Scenario ready in: /tmp/conflict-lab
...
both modified:   config.yaml
$ git -C /tmp/conflict-lab status --porcelain
UU config.yaml
```

`config.yaml` mid-conflict:

```yaml
service: payments
# Number of pods to run for the payments service.
<<<<<<< HEAD
replicas: 3
=======
replicas: 5
>>>>>>> feature/scale-up
port: 8080
```

`pre-commit` blocking a crafted AWS secret (captured run, exit code 1):

```
$ printf 'aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY\n' > creds.env
$ git add creds.env && git commit -m "feat: add credentials"
BLOCKED: creds.env contains secret-like content (AWS key / private key / BEGIN block).
         Remove the secret, rotate it if it ever existed, and use a secrets manager.

pre-commit: 1 problem(s) found. Commit aborted.
To override (NOT for real secrets): git commit --no-verify
$ echo $?
1
```

`commit-msg` rejects `updated stuff` (exit 1) and accepts `fix(api): handle ...`.

## Troubleshooting

Real, reproducible failure → symptom → cause → fix:

- **Symptom:** your starter `pre-commit` lets a secret through. **Cause:** the
  `REPLACE_ME_*` placeholders never match real keys, so `grep -Eq` finds
  nothing. **Fix:** replace them with real ERE, e.g. `(AKIA|ASIA)[0-9A-Z]{16}`.
- **Symptom:** `setup-scenario.sh` prints `merge unexpectedly succeeded`.
  **Cause:** the two branches did not edit the **same** line (e.g. you appended
  instead of replacing `replicas:`), so Git auto-merges. **Fix:** ensure both
  edits rewrite the existing `replicas:` line to different values.
- **Symptom:** after resolving, `git commit` still says "unmerged paths".
  **Cause:** you edited the file but forgot `git add config.yaml` to mark it
  resolved. **Fix:** `git add config.yaml` then `git commit --no-edit`.
- **Symptom:** leftover `=======` causes a YAML/parse error later. **Cause:** a
  conflict marker line survived your edit. **Fix:** `git diff --check` flags the
  line; delete it. See the marker table in `docs/conflict-resolution.md`.
- **Reproducing a broken state on demand:** `setup-scenario.sh` *is* the
  injected fault — a deterministic `UU config.yaml`. Re-run it any time to get a
  fresh, identical conflict to practise on. (No separate `broken/` fixture is
  needed; the scenario script is the reproducible broken state, which is why the
  spec does not ask for a `broken/` dir for this module.)

## Cleanup

Everything this module creates lives under the `--dir` / `--target` you pass.
Idempotent teardown:

```bash
rm -rf /tmp/conflict-lab /tmp/lab        # the scenario repos
# Uninstall hooks from a target repo:
rm -f <repo>/.git/hooks/pre-commit <repo>/.git/hooks/commit-msg
# If you used --force, restore any backups:
#   mv <repo>/.git/hooks/pre-commit.bak <repo>/.git/hooks/pre-commit
```

No cloud resources, daemons, or background processes are started, so there is
nothing else to stop. `validate.sh` and `tests/test_hooks.sh` clean up their own
`mktemp` working dirs via a trap.

## Security considerations

This module *is* a security control: the `pre-commit` hook is a last line of
defence against committing secrets. Important caveats taught here:

- **Client-side hooks are advisory, not enforcing.** Anyone can bypass them with
  `git commit --no-verify`, and a fresh clone has no hooks until
  `install-hooks.sh` runs. Treat them as a developer convenience; enforce the
  real gate **server-side** (a CI secret-scan job, GitHub push protection,
  branch-protection rules). The README's hooks complement, not replace, those.
- **Detection is pattern-based and best-effort.** It catches AWS keys, PEM
  private keys, and `-----BEGIN` blocks — not every possible secret. Run a
  dedicated scanner (gitleaks / trufflehog) in CI for full coverage; the exact
  command is in [DEFERRED gates](#deferred--full-tool-commands).
- **A secret that was ever committed is compromised.** The hook only stops the
  *next* commit; if a key reached history, **rotate it** and scrub history.
- **Never commit:** `*.pem`, `id_rsa`/`id_ed25519`, `.env` with real values,
  `*.tfstate`, cloud credential files. Use a secrets manager + `.gitignore`.

## Cost considerations

$0. This module is entirely local bash + git. It provisions no cloud resources,
makes no network calls, and starts no long-running processes. Nothing here can
incur charges. (The *lesson* — keep secrets out of Git — exists partly because a
leaked cloud key is one of the fastest ways to run up a real bill.)

## Instructor answer key

Reference implementation: [`solution/`](solution/). Non-obvious grading points:

- **pre-commit must inspect the *staged* blob, not the working tree.** Grading
  catch: a solution that `grep`s the working-tree file (`grep -r .`) will both
  miss staged-only content and flag unstaged scratch files. The reference reads
  the index via `git cat-file -s :"$f"` and `git diff --cached`. Accept any
  approach that scans staged content only.
- **Large-file check must measure the staged size**, so a `git add`ed 6 MB blob
  is caught even if the working-tree copy was later truncated. `git cat-file -s
  ":$f"` is the clean way; `wc -c` on the working file is *almost* right but
  wrong after a post-add edit.
- **commit-msg regex:** `^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\([a-z0-9._-]+\))?(!)?: .+[^.]$`.
  Common wrong answers: forgetting the `!` breaking-change marker; allowing a
  trailing period; not anchoring with `^…$` (so `xfeat: y` slips through);
  rejecting valid scopes. Merge/revert/fixup auto-messages must be exempt.
- **setup-scenario idempotency:** must `rm -rf` the target on re-run (guarded so
  it never wipes `/`, `$HOME`, or `.`). A solution that fails on the second run
  loses the idempotency point.
- **install-hooks:** symlink (not copy) is the intended answer so source edits
  propagate; using `--git-common-dir` (vs hard-coding `.git/hooks`) earns full
  marks because it works inside worktrees.
- **Conflict resolution (docs):** students must remove **all three** marker
  lines and `git add` to mark resolved; the rebase half flips "ours/theirs",
  which trips many learners — verify they understand *why*.

Quiz/homework/troubleshooting answer key: the bullets above plus
`docs/conflict-resolution.md` (worked, with both merge and rebase paths) serve
as the full answer key for this module's exercises.

### DEFERRED — full-tool commands

These run where the tool is installed (not required for this module's local
gates; documented for completeness):

- **shellcheck** (style/lint beyond `bash -n`):
  `shellcheck solution/*.sh solution/hooks/* starter/*.sh starter/hooks/*`
- **gitleaks** (CI-grade secret scan, superset of the hook):
  `gitleaks detect --source <repo> --no-banner`

Both are marked DEFERRED in the validation table because `shellcheck`/`gitleaks`
are not present in this build environment; `bash -n` + the behaviour tests are
the local substitute and they pass.
