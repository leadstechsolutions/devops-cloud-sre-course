#!/usr/bin/env bash
# secret_scan.sh -- a minimal, dependency-free secret scanner.
#
# STARTER -- the PATTERNS table is TODO'd. Add the credential regexes, then:
#
#   ./secret_scan.sh dir ../broken    # should find the planted AWS key (exit 1)
#   ./secret_scan.sh dir solution     # should be clean (exit 0)
#
# Usage:
#   ./secret_scan.sh dir   <directory>
#   ./secret_scan.sh staged
#
# Exit codes: 0 none / 1 secret found / 2 usage|env error
set -euo pipefail

# label<TAB>extended-regex. Tabs separate the two fields.
# TODO(student): add at least these high-signal patterns (label<TAB>regex):
#   - "AWS Access Key ID"        : AKIA followed by 16 uppercase-alnum chars
#                                  (real prefixes: AKIA|ASIA|AROA|AIDA|...)
#   - "Private Key (PEM)"        : the "-----BEGIN ... PRIVATE KEY-----" header
#   - "Generic Password Assignment": password|secret|token = "<6+ chars>"
# Use extended regex (grep -E). One pattern per line; a literal TAB between the
# label and the regex. Example row (already provided to show the format):
PATTERNS=$(cat <<'EOF'
GitHub Token	(ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,})
EOF
)

scan_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  if grep -Iq . "$file" 2>/dev/null; then :; else return 0; fi

  while IFS=$'\t' read -r label regex; do
    [[ -z "$label" ]] && continue
    if grep -nIE "$regex" "$file" >/tmp/_secret_hits.out 2>/dev/null; then
      while IFS= read -r hit; do
        printf '  [SECRET] %s: %s:%s\n' "$label" "$file" "$hit"
        FOUND=$((FOUND + 1))
      done < /tmp/_secret_hits.out
    fi
  done <<< "$PATTERNS"
}

FOUND=0

[[ $# -ge 1 ]] || { echo "usage: $0 {dir <directory>|staged}" >&2; exit 2; }
mode="$1"

case "$mode" in
  dir)
    [[ $# -eq 2 ]] || { echo "usage: $0 dir <directory>" >&2; exit 2; }
    root="$2"
    [[ -d "$root" ]] || { echo "error: no such directory: $root" >&2; exit 2; }
    while IFS= read -r -d '' f; do
      scan_file "$f"
    done < <(find "$root" -type d -name .git -prune -o -type f -print0)
    ;;

  staged)
    command -v git >/dev/null 2>&1 || { echo "error: git not found" >&2; exit 2; }
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
      echo "error: not inside a git work tree" >&2; exit 2; }
    while IFS= read -r f; do
      [[ -n "$f" ]] && scan_file "$f"
    done < <(git diff --cached --name-only --diff-filter=ACM)
    ;;

  *)
    echo "usage: $0 {dir <directory>|staged}" >&2
    exit 2
    ;;
esac

if [[ "$FOUND" -gt 0 ]]; then
  echo "FAIL: $FOUND likely secret(s) found. Remove them and rotate the credential."
  exit 1
fi
echo "OK: no secrets found."
exit 0
