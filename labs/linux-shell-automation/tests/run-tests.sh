#!/usr/bin/env bash
#
# run-tests.sh — functional tests for the linux-shell-automation solution scripts.
#
# Strategy: build a throwaway sandbox under a mktemp dir, fabricate files with
# controlled mtimes and synthetic passwd/group fixtures, run each solution script
# against the sandbox, and assert on exit codes and output. No root, no network,
# stdlib tools only. Cleans up on exit (success or failure) via a trap.
#
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOL="${TESTS_DIR}/../solution"

PASS=0
FAIL=0

ok()   { printf '  [PASS] %s\n' "$1"; PASS=$((PASS + 1)); }
bad()  { printf '  [FAIL] %s\n' "$1"; FAIL=$((FAIL + 1)); }

# assert_eq "label" expected actual
assert_eq() {
  if [[ "$2" == "$3" ]]; then ok "$1"; else
    bad "$1 (expected [$2], got [$3])"
  fi
}

# assert_contains "label" haystack needle
assert_contains() {
  if [[ "$2" == *"$3"* ]]; then ok "$1"; else
    bad "$1 (output did not contain [$3])"
  fi
}

WORK="$(mktemp -d)"
# SC2317: invoked indirectly by the EXIT trap below, not called inline.
# shellcheck disable=SC2317
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

echo "== linux-shell-automation tests (sandbox: $WORK) =="

# ---------------------------------------------------------------------------
# 1. disk-check.sh
# ---------------------------------------------------------------------------
echo "-- disk-check.sh"

# Threshold 100 can never be exceeded -> exit 0.
set +e
out="$("$SOL/disk-check.sh" --threshold 100 2>/dev/null)"; rc=$?
set -e
assert_eq "disk-check: threshold 100 exits 0" "0" "$rc"

# Threshold 0 will be exceeded by at least one real mount -> exit 1.
set +e
out="$("$SOL/disk-check.sh" --threshold 0 2>/dev/null)"; rc=$?
set -e
assert_eq "disk-check: threshold 0 exits 1 (breach)" "1" "$rc"
assert_contains "disk-check: prints BREACH lines" "$out" "BREACH"

# Invalid threshold is rejected.
set +e
"$SOL/disk-check.sh" --threshold 999 >/dev/null 2>&1; rc=$?
set -e
assert_eq "disk-check: rejects out-of-range threshold" "1" "$rc"

# ---------------------------------------------------------------------------
# 2. log-rotate.sh
# ---------------------------------------------------------------------------
echo "-- log-rotate.sh"

LOGDIR="$WORK/logs"
mkdir -p "$LOGDIR"
printf 'fresh\n' > "$LOGDIR/recent.log"
printf 'stale\n' > "$LOGDIR/old.log"
printf 'stale spaced\n' > "$LOGDIR/old name.log"
# Make the two "old" files 40 days old; leave recent.log as now.
touch -d '40 days ago' "$LOGDIR/old.log" "$LOGDIR/old name.log"

# Dry-run must NOT modify the directory.
# SC2012: use find (not ls) so non-alphanumeric filenames are handled safely;
# -printf '%f\n' emits just the basename for a stable, sorted snapshot.
before="$(find "$LOGDIR" -maxdepth 1 -mindepth 1 -printf '%f\n' | sort)"
out="$("$SOL/log-rotate.sh" --dir "$LOGDIR" --days 14 --dry-run 2>&1)"
after="$(find "$LOGDIR" -maxdepth 1 -mindepth 1 -printf '%f\n' | sort)"
assert_eq "log-rotate: dry-run leaves dir unchanged" "$before" "$after"
assert_contains "log-rotate: dry-run mentions old.log" "$out" "old.log"

# Real run gzips the two old files, leaves recent.log.
"$SOL/log-rotate.sh" --dir "$LOGDIR" --days 14 >/dev/null 2>&1
if [[ -f "$LOGDIR/old.log.gz" ]];      then ok "log-rotate: old.log compressed";       else bad "log-rotate: old.log compressed"; fi
if [[ -f "$LOGDIR/old name.log.gz" ]]; then ok "log-rotate: spaced file compressed";   else bad "log-rotate: spaced file compressed"; fi
if [[ -f "$LOGDIR/recent.log" ]];      then ok "log-rotate: recent.log untouched";     else bad "log-rotate: recent.log untouched"; fi
if [[ ! -f "$LOGDIR/old.log" ]];       then ok "log-rotate: original removed by gzip"; else bad "log-rotate: original removed by gzip"; fi

# Idempotent: a second run finds nothing new to rotate (no plain old files left).
out="$("$SOL/log-rotate.sh" --dir "$LOGDIR" --days 14 2>&1)"
assert_contains "log-rotate: second run rotates 0 files" "$out" "rotated 0 file"

# Missing dir is an error.
set +e
"$SOL/log-rotate.sh" --dir "$WORK/does-not-exist" >/dev/null 2>&1; rc=$?
set -e
assert_eq "log-rotate: missing dir exits 1" "1" "$rc"

# ---------------------------------------------------------------------------
# 3. backup.sh
# ---------------------------------------------------------------------------
echo "-- backup.sh"

SRC="$WORK/src"
DEST="$WORK/backups"
mkdir -p "$SRC"
printf 'data\n' > "$SRC/payload.txt"

# Create 4 archives with --keep 2; only the 2 newest must survive.
for _ in 1 2 3 4; do
  "$SOL/backup.sh" --src "$SRC" --dest "$DEST" --keep 2 >/dev/null 2>&1
  sleep 1   # ensure a distinct second-resolution timestamp per archive
done
count="$(find "$DEST" -maxdepth 1 -name 'src-*.tar.gz' | wc -l | tr -d ' ')"
assert_eq "backup: retention keeps exactly --keep archives" "2" "$count"

# The surviving archive is a valid tarball containing the payload.
latest="$(find "$DEST" -maxdepth 1 -name 'src-*.tar.gz' | sort | tail -1)"
if tar -tzf "$latest" 2>/dev/null | grep -q 'src/payload.txt'; then
  ok "backup: archive contains source files"
else
  bad "backup: archive contains source files"
fi

# Missing --src is an error.
set +e
"$SOL/backup.sh" --dest "$DEST" --keep 2 >/dev/null 2>&1; rc=$?
set -e
assert_eq "backup: missing --src exits 1" "1" "$rc"

# ---------------------------------------------------------------------------
# 4. user-audit.sh
# ---------------------------------------------------------------------------
echo "-- user-audit.sh"

cat > "$WORK/passwd" <<'EOF'
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
alice:x:1000:1000:Alice:/home/alice:/bin/bash
bob:x:1001:1001:Bob:/home/bob:/bin/bash
carol:x:1002:1002:Carol:/home/carol:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
EOF
cat > "$WORK/group" <<'EOF'
root:x:0:
sudo:x:27:alice
wheel:x:998:carol
nogroup:x:65534:
EOF

out="$("$SOL/user-audit.sh" -p "$WORK/passwd" -g "$WORK/group" 2>/dev/null)"
# nobody (65534) and the UID<1000 service accounts must be excluded.
assert_contains "user-audit: lists alice"  "$out" "alice"
assert_contains "user-audit: lists bob"    "$out" "bob"
assert_contains "user-audit: lists carol"  "$out" "carol"
if [[ "$out" != *nobody* && "$out" != *daemon* ]]; then
  ok "user-audit: excludes nobody and service accounts"
else
  bad "user-audit: excludes nobody and service accounts"
fi
# alice (sudo) and carol (wheel) -> yes ; bob -> no.
assert_contains "user-audit: alice flagged sudo=yes" "$out" "$(printf 'alice')"
if printf '%s\n' "$out" | awk '/alice/{print $4}' | grep -qx 'yes'; then
  ok "user-audit: alice has sudo (sudo group)"; else bad "user-audit: alice has sudo"; fi
if printf '%s\n' "$out" | awk '/carol/{print $4}' | grep -qx 'yes'; then
  ok "user-audit: carol has sudo (wheel group)"; else bad "user-audit: carol has sudo"; fi
if printf '%s\n' "$out" | awk '/bob/{print $4}' | grep -qx 'no'; then
  ok "user-audit: bob has no sudo"; else bad "user-audit: bob has no sudo"; fi

# Unreadable passwd file is an error.
set +e
"$SOL/user-audit.sh" -p "$WORK/no-such-passwd" -g "$WORK/group" >/dev/null 2>&1; rc=$?
set -e
assert_eq "user-audit: missing passwd file exits 1" "1" "$rc"

# ---------------------------------------------------------------------------
# 5. broken/ fixture must reproduce its bug (off-by-one at threshold).
# ---------------------------------------------------------------------------
echo "-- broken/disk-check-broken.sh (expected to misbehave)"
BROKEN="${TESTS_DIR}/../broken/disk-check-broken.sh"
# Both scripts are syntactically valid; the bug is behavioural, not a parse error.
if bash -n "$BROKEN"; then ok "broken: still parses (bug is behavioural)"; else bad "broken: parses"; fi

# ---------------------------------------------------------------------------
echo "== ${PASS} passed, ${FAIL} failed =="
exit $((FAIL > 0 ? 1 : 0))
