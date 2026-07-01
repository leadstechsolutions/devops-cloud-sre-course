#!/usr/bin/env bash
set -euo pipefail

# install-hooks.sh  (STARTER — fill the TODOs, compare with solution/install-hooks.sh)
# ---------------------------------------------------------------------------
# Symlink the hooks in ./hooks/ into a target repo's .git/hooks/ directory.
# Usage: ./install-hooks.sh [--target <repo>] [--force]
# ---------------------------------------------------------------------------

usage() { echo "Usage: install-hooks.sh [--target <repo>] [--force]"; }

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_SRC="$SCRIPT_DIR/hooks"
TARGET="."
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) [[ $# -ge 2 ]] || { echo "error: --target needs a value" >&2; exit 2; }
              TARGET="$2"; shift 2 ;;
    --target=*) TARGET="${1#--target=}"; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -d "$HOOKS_SRC" ]] || { echo "error: no hooks dir: $HOOKS_SRC" >&2; exit 1; }

if ! git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: '$TARGET' is not inside a Git working tree" >&2
  exit 1
fi

# TODO(student): compute DEST as the target repo's hooks directory, then mkdir -p it.
#   Hint: the robust way (handles worktrees/custom GITDIR) is:
#     git_common="$(git -C "$TARGET" rev-parse --path-format=absolute --git-common-dir)"
#     DEST="$git_common/hooks"
DEST="REPLACE_ME"     # <-- replace with the computed hooks dir
mkdir -p -- "$DEST"

installed=0
for hook_path in "$HOOKS_SRC"/*; do
  [[ -f "$hook_path" ]] || continue
  hook="$(basename -- "$hook_path")"
  dest="$DEST/$hook"
  chmod +x "$hook_path"

  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ -L "$dest" && "$(readlink -- "$dest")" == "$hook_path" ]]; then
      echo "  [ok]   $hook already linked"; installed=$((installed + 1)); continue
    fi
    if [[ "$FORCE" -eq 1 ]]; then
      mv -- "$dest" "$dest.bak"; echo "  [back] existing $hook -> $hook.bak"
    else
      echo "  [skip] $hook exists (use --force to replace)"; continue
    fi
  fi

  # TODO(student): create the symlink from $dest to $hook_path (ln -s -- ...).
  echo "  [link] $hook -> $hook_path"
  installed=$((installed + 1))
done

echo "Installed/verified $installed hook(s) into $DEST"
