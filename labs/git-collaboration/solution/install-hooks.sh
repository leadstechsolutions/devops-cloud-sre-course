#!/usr/bin/env bash
set -euo pipefail

# install-hooks.sh
# ---------------------------------------------------------------------------
# Symlinks the hooks in ./hooks/ into a target repository's .git/hooks/ so the
# repo always runs the version-controlled hook (edit once, every clone of THIS
# checkout benefits). Symlinking (rather than copying) keeps the hooks in sync
# with the files under source control.
#
# Usage:
#   ./install-hooks.sh [--target <repo>] [--force]
#
#   --target <repo>  Path to the Git repo to install into. Defaults to the repo
#                    that contains this script's hooks dir's parent ($PWD's repo).
#   --force          Overwrite existing hooks (backed up to <hook>.bak first).
#   -h, --help       Show help.
# ---------------------------------------------------------------------------

usage() { sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'; }

# Directory that holds this script (and the hooks/ subdir next to it).
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

if [[ ! -d "$HOOKS_SRC" ]]; then
  echo "error: hooks source dir not found: $HOOKS_SRC" >&2
  exit 1
fi

# Locate the target repo's hooks directory (honours worktrees / custom GITDIR).
if ! git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: '$TARGET' is not inside a Git working tree" >&2
  exit 1
fi
git_common="$(git -C "$TARGET" rev-parse --path-format=absolute --git-common-dir)"
DEST="$git_common/hooks"
mkdir -p -- "$DEST"

installed=0
for hook_path in "$HOOKS_SRC"/*; do
  [[ -f "$hook_path" ]] || continue
  hook="$(basename -- "$hook_path")"
  dest="$DEST/$hook"

  # Ensure the source hook is executable (the symlink inherits the target mode).
  chmod +x "$hook_path"

  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ -L "$dest" && "$(readlink -- "$dest")" == "$hook_path" ]]; then
      echo "  [ok]   $hook already linked"
      installed=$((installed + 1))
      continue
    fi
    if [[ "$FORCE" -eq 1 ]]; then
      mv -- "$dest" "$dest.bak"
      echo "  [back] existing $hook -> $hook.bak"
    else
      echo "  [skip] $hook exists (use --force to replace)"
      continue
    fi
  fi

  ln -s -- "$hook_path" "$dest"
  echo "  [link] $hook -> $hook_path"
  installed=$((installed + 1))
done

echo "Installed/verified $installed hook(s) into $DEST"
