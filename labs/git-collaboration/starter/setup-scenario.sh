#!/usr/bin/env bash
set -euo pipefail

# setup-scenario.sh  (STARTER — fill the TODOs, compare with solution/setup-scenario.sh)
# ---------------------------------------------------------------------------
# Build a self-contained repo with a REPRODUCIBLE merge conflict on one line:
#   base on main: replicas: 2
#   feature/scale-up: replicas: 5
#   main (later): replicas: 3
#   merging feature into main => conflict on the replicas line.
# Must be idempotent / self-cleaning via --dir.
# ---------------------------------------------------------------------------

usage() {
  cat <<'USAGE'
Usage: setup-scenario.sh --dir <path> [--keep]
  --dir <path>   Directory to (re)build the scenario in. REQUIRED, WIPED if exists.
  --keep         Do not wipe an existing --dir; refuse if non-empty.
  -h, --help     Show this help.
USAGE
}

DIR=""
KEEP=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir) [[ $# -ge 2 ]] || { echo "error: --dir needs a value" >&2; exit 2; }
           DIR="$2"; shift 2 ;;
    --dir=*) DIR="${1#--dir=}"; shift ;;
    --keep) KEEP=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$DIR" ]]; then echo "error: --dir is required" >&2; usage >&2; exit 2; fi
case "$DIR" in /|""|"$HOME"|.) echo "error: refusing to operate on '$DIR'" >&2; exit 2 ;; esac

parent="$(dirname -- "$DIR")"; base="$(basename -- "$DIR")"
mkdir -p -- "$parent"
DIR="$(cd -- "$parent" && pwd)/$base"

# TODO(student): make the script self-cleaning/idempotent.
#   - If "$DIR" exists and --keep is NOT set, remove it (rm -rf -- "$DIR") so a
#     re-run rebuilds from scratch.
#   - If --keep IS set, refuse when "$DIR" is non-empty (exit 1).
#   Then recreate it: mkdir -p -- "$DIR"
mkdir -p -- "$DIR"

export GIT_AUTHOR_NAME="Lab Bot" GIT_AUTHOR_EMAIL="lab@example.com"
export GIT_COMMITTER_NAME="Lab Bot" GIT_COMMITTER_EMAIL="lab@example.com"
export GIT_AUTHOR_DATE="2025-01-01T00:00:00Z" GIT_COMMITTER_DATE="2025-01-01T00:00:00Z"

git -C "$DIR" init -q -b main

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

# Feature branch: scale up to 5.
git -C "$DIR" switch -q -c feature/scale-up
# TODO(student): edit config.yaml so 'replicas: 2' becomes 'replicas: 5',
#   then 'git add' and commit with a Conventional-Commits feat: message.
#   Hint (portable in-place edit):
#     sed 's/^replicas: .*/replicas: 5/' "$DIR/config.yaml" >"$DIR/config.yaml.tmp"
#     mv "$DIR/config.yaml.tmp" "$DIR/config.yaml"

# Back on main: change the SAME line to 3 so the merge will conflict.
git -C "$DIR" switch -q main
# TODO(student): edit config.yaml so 'replicas:' becomes 3, add, and commit
#   with a Conventional-Commits fix: message.

# Trigger the conflict (let it fail and LEAVE the repo mid-conflict).
set +e
git -C "$DIR" merge --no-edit feature/scale-up >/dev/null 2>&1
merge_rc=$?
set -e

if [[ "$merge_rc" -eq 0 ]]; then
  echo "error: merge unexpectedly succeeded; no conflict produced" >&2
  exit 1
fi
if ! git -C "$DIR" status --porcelain | grep -q '^UU '; then
  echo "error: expected an unresolved (UU) conflict but none is present" >&2
  exit 1
fi

echo "Scenario ready in: $DIR"
git -C "$DIR" status
echo "Resolve it by hand, or follow docs/conflict-resolution.md."
