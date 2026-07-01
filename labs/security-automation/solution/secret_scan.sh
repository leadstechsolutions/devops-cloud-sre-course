#!/usr/bin/env bash
# secret_scan.sh -- a minimal, dependency-free secret scanner.
#
# Scans either a directory tree or the files git has STAGED (so it can be wired
# as a pre-commit hook). Matches a small, high-signal set of credential patterns
# with extended regular expressions.
#
# Usage:
#   ./secret_scan.sh dir   <directory>     # walk a tree (skips .git/)
#   ./secret_scan.sh staged               # scan `git diff --cached` files
#
# Exit codes:
#   0  no secrets found
#   1  at least one likely secret found
#   2  usage / environment error
#
# This is a teaching tool, not gitleaks. The README documents the real-tool
# command (gitleaks / trufflehog). The patterns below are deliberately tight to
# keep false positives low; extend PATTERNS to add coverage.
set -euo pipefail

# label<TAB>extended-regex. Tabs separate the two fields.
# Kept narrow on purpose:
#   - AWS access key id:        AKIA + 16 base32 chars
#   - AWS secret access key:    aws_secret...=<40 base64-ish chars>
#   - Private key PEM header
#   - GitHub PAT (classic ghp_ and fine-grained github_pat_)
#   - Generic "password = '...'" / "secret: ..." assignments
PATTERNS=$(cat <<'EOF'
AWS Access Key ID	(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}
AWS Secret Access Key	aws_secret_access_key[[:space:]]*=[[:space:]]*['"]?[A-Za-z0-9/+=]{40}
Private Key (PEM)	-----BEGIN [A-Z ]*PRIVATE KEY-----
GitHub Token	(ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,})
Generic Password Assignment	(password|passwd|secret|token)[[:space:]]*[:=][[:space:]]*['"][^'"]{6,}['"]
EOF
)

scan_file() {
  # scan_file <path> ; prints findings, returns 0 always (caller aggregates).
  local file="$1"
  [[ -f "$file" ]] || return 0
  # Skip obviously-binary files so we do not spew garbage / match noise.
  if grep -Iq . "$file" 2>/dev/null; then :; else return 0; fi

  while IFS=$'\t' read -r label regex; do
    [[ -z "$label" ]] && continue
    # -n: line number, -E: ERE, -I: skip binary. One pass per pattern.
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
    # -print0 / read -d '' to survive spaces in names. Skip the .git dir.
    while IFS= read -r -d '' f; do
      scan_file "$f"
    done < <(find "$root" -type d -name .git -prune -o -type f -print0)
    ;;

  staged)
    command -v git >/dev/null 2>&1 || { echo "error: git not found" >&2; exit 2; }
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
      echo "error: not inside a git work tree" >&2; exit 2; }
    # Added/Copied/Modified staged files only.
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
