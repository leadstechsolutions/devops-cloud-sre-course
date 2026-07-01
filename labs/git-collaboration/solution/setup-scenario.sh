#!/usr/bin/env bash
set -euo pipefail

# setup-scenario.sh
# ---------------------------------------------------------------------------
# Builds a small, self-contained Git repository that contains a REPRODUCIBLE
# merge conflict, so a learner can practice resolving it (and the docs/ rebase
# walkthrough). The scenario is:
#
#   main      :  add config.yaml with replicas: 2   (the "production" value)
#   feature/* :  branched from the same base, sets  replicas: 5
#   main      :  meanwhile also changes the SAME line to replicas: 3
#
# Merging feature/scale-up into main therefore conflicts on that one line,
# which is exactly the kind of conflict students hit in week 3 class 2.
#
# The script is IDEMPOTENT and SELF-CLEANING: re-running it against the same
# --dir wipes and rebuilds the scenario from scratch, so it is safe to run in
# a loop while practising. It never touches anything outside --dir.
# ---------------------------------------------------------------------------

usage() {
  cat <<'USAGE'
Usage: setup-scenario.sh --dir <path> [--keep]

  --dir <path>   Directory to (re)build the scenario in. REQUIRED.
                 The directory is created if missing and WIPED if it exists.
  --keep         Do not wipe an existing --dir; refuse if it is non-empty.
  -h, --help     Show this help.

Exit status: 0 on success, non-zero on any error.
USAGE
}

DIR=""
KEEP=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)
      [[ $# -ge 2 ]] || { echo "error: --dir needs a value" >&2; exit 2; }
      DIR="$2"; shift 2 ;;
    --dir=*) DIR="${1#--dir=}"; shift ;;
    --keep)  KEEP=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$DIR" ]]; then
  echo "error: --dir is required" >&2
  usage >&2
  exit 2
fi

# Refuse the obviously dangerous targets so a stray --dir / never wipes a real tree.
case "$DIR" in
  /|""|"$HOME"|.) echo "error: refusing to operate on '$DIR'" >&2; exit 2 ;;
esac

# Resolve to an absolute path WITHOUT requiring the dir to exist yet.
parent="$(dirname -- "$DIR")"
base="$(basename -- "$DIR")"
mkdir -p -- "$parent"
DIR="$(cd -- "$parent" && pwd)/$base"

if [[ -e "$DIR" ]]; then
  if [[ "$KEEP" -eq 1 ]]; then
    if [[ -n "$(ls -A -- "$DIR" 2>/dev/null)" ]]; then
      echo "error: --keep set but '$DIR' is not empty" >&2
      exit 1
    fi
  else
    # Self-cleaning: only ever removes the target dir we were told to build.
    rm -rf -- "$DIR"
  fi
fi
mkdir -p -- "$DIR"

# Deterministic identity + dates so the scenario is byte-reproducible and does
# not depend on (or pollute) the learner's global git config.
export GIT_AUTHOR_NAME="Lab Bot"
export GIT_AUTHOR_EMAIL="lab@example.com"
export GIT_COMMITTER_NAME="Lab Bot"
export GIT_COMMITTER_EMAIL="lab@example.com"
export GIT_AUTHOR_DATE="2025-01-01T00:00:00Z"
export GIT_COMMITTER_DATE="2025-01-01T00:00:00Z"

git -C "$DIR" init -q -b main

# ---- Base commit on main: a config both branches will edit -----------------
cat >"$DIR/config.yaml" <<'YAML'
service: payments
# Number of pods to run for the payments service.
replicas: 2
port: 8080
YAML

cat >"$DIR/README.md" <<'MD'
# payments service

Deployment config lives in `config.yaml`.
MD

git -C "$DIR" add config.yaml README.md
git -C "$DIR" commit -q -m "chore: add payments service config (replicas 2)"

# ---- Feature branch: scale up to 5 -----------------------------------------
git -C "$DIR" switch -q -c feature/scale-up
# Portable in-place edit (works on GNU and BSD sed): rewrite the replicas line.
sed 's/^replicas: .*/replicas: 5/' "$DIR/config.yaml" >"$DIR/config.yaml.tmp"
mv "$DIR/config.yaml.tmp" "$DIR/config.yaml"
git -C "$DIR" add config.yaml
git -C "$DIR" commit -q -m "feat: scale payments to 5 replicas for Black Friday"

# ---- Back on main: someone else changed the SAME line to 3 -----------------
git -C "$DIR" switch -q main
sed 's/^replicas: .*/replicas: 3/' "$DIR/config.yaml" >"$DIR/config.yaml.tmp"
mv "$DIR/config.yaml.tmp" "$DIR/config.yaml"
git -C "$DIR" add config.yaml
git -C "$DIR" commit -q -m "fix: bump payments to 3 replicas after capacity review"

# ---- Trigger the conflict: try to merge the feature branch into main -------
# We intentionally let the merge fail and LEAVE the repo mid-conflict so the
# learner walks into an unresolved conflict, exactly as docs/ describes.
set +e
git -C "$DIR" merge --no-edit feature/scale-up >/dev/null 2>&1
merge_rc=$?
set -e

if [[ "$merge_rc" -eq 0 ]]; then
  echo "error: merge unexpectedly succeeded; scenario did not produce a conflict" >&2
  exit 1
fi

# Sanity check: confirm we really are sitting on an unresolved conflict.
if ! git -C "$DIR" status --porcelain | grep -q '^UU '; then
  echo "error: expected an unresolved (UU) conflict but none is present" >&2
  exit 1
fi

echo "Scenario ready in: $DIR"
echo
echo "Current state (note the conflict on config.yaml):"
git -C "$DIR" status
echo
echo "Resolve it by hand, or follow docs/conflict-resolution.md."
