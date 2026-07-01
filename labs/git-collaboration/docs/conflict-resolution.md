# Worked walkthrough: resolving a merge conflict, then doing it with rebase

This is the companion to `solution/setup-scenario.sh`. Build the scenario first:

```bash
cd labs/git-collaboration/solution
./setup-scenario.sh --dir /tmp/conflict-lab
cd /tmp/conflict-lab
```

The scenario leaves you on `main`, mid-merge, with one unresolved conflict in
`config.yaml`. Two commits changed the **same** `replicas:` line:

- `main` set it to `3` (capacity review).
- `feature/scale-up` set it to `5` (Black Friday).

Git cannot pick for you, so it stops and asks.

---

## Part A — resolve with `git merge`

### 1. See where you are

```bash
git status
```

You will see `Unmerged paths: both modified: config.yaml` and the merge in
progress. `git status --porcelain` shows the line `UU config.yaml` — `UU` means
"both sides modified" (a content conflict).

### 2. Look at the conflict markers

`config.yaml` now contains conflict markers:

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

Read it as three parts:

| Marker | Meaning |
|--------|---------|
| `<<<<<<< HEAD` … `=======` | what **your current branch** (`main`) has |
| `=======` … `>>>>>>> feature/scale-up` | what the **incoming** branch has |

### 3. Decide and edit

The merge conflict is a **human decision**, not a Git command. Suppose Black
Friday wins: we want `5`. Edit the file so it reads exactly:

```yaml
service: payments
# Number of pods to run for the payments service.
replicas: 5
port: 8080
```

Delete **all three** marker lines (`<<<<<<<`, `=======`, `>>>>>>>`). A common
mistake is leaving a stray `=======` behind — `git diff --check` catches it:

```bash
git diff --check        # prints nothing when no markers remain
```

### 4. Mark resolved and complete the merge

```bash
git add config.yaml
git status              # 'All conflicts fixed but you are still merging.'
git commit --no-edit    # completes the merge commit
```

Verify:

```bash
git log --oneline --graph -n 5
grep '^replicas:' config.yaml      # -> replicas: 5
```

`git log --graph` shows the two parents joining at the merge commit. Done.

> If you make a mess and want to start the merge over:
> `git merge --abort` returns you to the pre-merge state cleanly.

---

## Part B — the same change, but with `rebase` (linear history)

Merge commits preserve the fork; rebase **replays** your branch on top of the
new base for a straight line. Many teams prefer rebase for feature branches.
Rebuild a fresh scenario and replay the feature branch onto `main` instead of
merging:

```bash
./setup-scenario.sh --dir /tmp/conflict-lab     # idempotent: rebuilds clean
cd /tmp/conflict-lab
git merge --abort                               # drop the pre-staged merge
git switch feature/scale-up
git rebase main
```

Rebase stops at the same conflicting line, but now the markers show the
**opposite** sides, because rebase is replaying *your* commit on top of `main`:

```yaml
<<<<<<< HEAD
replicas: 3          # this is now 'main' (the base you are replaying onto)
=======
replicas: 5          # this is your commit being replayed
>>>>>>> <sha> (feat: scale payments to 5 replicas for Black Friday)
```

Resolve exactly as before (keep `5`), then continue the rebase:

```bash
git add config.yaml
git rebase --continue
```

If a commit becomes empty or you want out:

```bash
git rebase --abort      # back to before the rebase
# or, after starting:
git rebase --skip       # drop the current commit and move on
```

Now `feature/scale-up` sits directly on top of `main` with a linear history:

```bash
git log --oneline --graph main feature/scale-up
```

Fast-forward `main` to it (no merge commit needed):

```bash
git switch main
git merge --ff-only feature/scale-up
```

---

## Rebase safety rules (read before you rebase in a real team)

1. **Never rebase a branch others have pulled.** Rebasing rewrites SHAs; anyone
   who already has the old commits will diverge. Rebase only your own,
   un-pushed (or only-yours) feature branches.
2. **Push rewritten history with `--force-with-lease`, never `--force`.**
   `--force-with-lease` refuses to overwrite if the remote moved since you last
   fetched, so you cannot clobber a teammate's pushed work:
   ```bash
   git push --force-with-lease
   ```
3. **`git pull --rebase`** keeps your local commits on top of upstream instead
   of creating a merge bubble for every sync.
4. When a rebase goes wrong, `git reflog` shows every prior HEAD; you can
   `git reset --hard HEAD@{N}` back to any of them.

---

## Quick reference

| Goal | Command |
|------|---------|
| See conflicted files | `git status` / `git diff --name-only --diff-filter=U` |
| Check for leftover markers | `git diff --check` |
| Take one whole side | `git checkout --ours <file>` / `git checkout --theirs <file>` |
| Mark a file resolved | `git add <file>` |
| Finish a merge | `git commit --no-edit` |
| Abort a merge | `git merge --abort` |
| Continue a rebase | `git rebase --continue` |
| Abort a rebase | `git rebase --abort` |
| Safe force-push | `git push --force-with-lease` |
| Undo via history | `git reflog` then `git reset --hard HEAD@{N}` |
