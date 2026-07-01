#!/usr/bin/env bash
#
# run-tests.sh — functional tests for the setup-validation library.
#
# Strategy:
#   1. Unit-test version_ge / normalize_version / extract_version directly by
#      sourcing solution/lib/check.sh and feeding fake version strings. The
#      headline case is the 3.10-vs-3.9 ordering that a string compare gets
#      wrong.
#   2. Integration-test check_tool / detect_version by building a sandbox of
#      FAKE tool binaries (tiny scripts that print a chosen --version string),
#      putting them first on PATH, and asserting the right PASS/FAIL/WARN.
#   3. Regression-test the broken/ fixture: assert it STILL gets 3.9 >= 3.10
#      wrong, so a silent "fix" of the teaching bug is caught.
#
# No root, no network, stdlib + coreutils only. Cleans up via an EXIT trap.
#
set -uo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOL="${TESTS_DIR}/../solution"
BROKEN="${TESTS_DIR}/../broken/setup-check-broken.sh"

PASS=0
FAIL=0
ok()  { printf '  [PASS] %s\n' "$1"; PASS=$((PASS + 1)); }
bad() { printf '  [FAIL] %s\n' "$1"; FAIL=$((FAIL + 1)); }

# assert_true  "label" cmd...   -> passes if cmd returns 0
assert_true()  { if "${@:2}"; then ok "$1"; else bad "$1"; fi; }
# assert_false "label" cmd...   -> passes if cmd returns non-zero
assert_false() { if "${@:2}"; then bad "$1"; else ok "$1"; fi; }
# assert_eq "label" expected actual
assert_eq()    { if [[ "$2" == "$3" ]]; then ok "$1"; else bad "$1 (expected [$2], got [$3])"; fi; }
# assert_contains "label" haystack needle
assert_contains() { if [[ "$2" == *"$3"* ]]; then ok "$1"; else bad "$1 (missing [$3])"; fi; }

# Source the REAL (correct) library under test.
# shellcheck source-path=SCRIPTDIR
# shellcheck source=../solution/lib/check.sh
source "${SOL}/lib/check.sh"

echo "== setup-validation tests =="

# ---------------------------------------------------------------------------
# 1. normalize_version
# ---------------------------------------------------------------------------
echo "-- normalize_version"
assert_eq "strip leading v"        "1.6.0"  "$(normalize_version 'v1.6.0')"
assert_eq "strip build metadata"   "3.16.3" "$(normalize_version '3.16.3+gcfd0749')"
assert_eq "strip pre-release"      "1.14.1" "$(normalize_version '1.14.1-beta2')"
assert_eq "keep two-field version" "3.10"   "$(normalize_version '3.10')"
assert_eq "non-numeric -> empty"   ""       "$(normalize_version 'notaversion')"

# ---------------------------------------------------------------------------
# 2. extract_version (pull a version out of noisy CLI output)
# ---------------------------------------------------------------------------
echo "-- extract_version"
assert_eq "git output"        "2.34.1"  "$(extract_version 'git version 2.34.1')"
assert_eq "docker output"     "29.1.2"  "$(extract_version 'Docker version 29.1.2, build 890dcca')"
assert_eq "aws-cli output"    "2.32.11" "$(extract_version 'aws-cli/2.32.11 Python/3.13.9 Linux/6 exe/x86_64')"
assert_eq "terraform output"  "1.14.1"  "$(extract_version 'Terraform v1.14.1')"
assert_false "no version present returns 1" extract_version 'no numbers here'

# ---------------------------------------------------------------------------
# 3. version_ge — the heart of the lab. THESE are the cases a string compare
#    gets wrong.
# ---------------------------------------------------------------------------
echo "-- version_ge (numeric, NOT string)"
# The headline bug case: 3.10 must be >= 3.9 (string compare says NO).
assert_true  "3.10 >= 3.9  (string compare would FAIL this)" version_ge "3.10" "3.9"
assert_false "3.9  >= 3.10 (string compare would PASS this)" version_ge "3.9"  "3.10"
# Equal versions.
assert_true  "1.6.0 >= 1.6.0 (equal)"        version_ge "1.6.0" "1.6.0"
assert_true  "1.6   >= 1.6.0 (trailing 0)"   version_ge "1.6"   "1.6.0"
assert_true  "2     >= 2.0   (trailing 0)"   version_ge "2"     "2.0"
# Plain greater / less.
assert_true  "1.14.1 >= 1.6"                 version_ge "1.14.1" "1.6"
assert_false "1.6 >= 1.14.1"                 version_ge "1.6"    "1.14.1"
# Real-world tool strings (with prefixes / metadata) still compare right.
assert_true  "v3.16.3+g... >= 3.12"          version_ge "v3.16.3+gcfd0749" "3.12"
assert_true  "29.1.2 >= 24 (docker)"         version_ge "29.1.2" "24"
assert_false "23.0.0 >= 24 (docker too old)" version_ge "23.0.0" "24"
# Double-digit minor that proves base-10 (not octal): 1.8 from a "08"-ish field.
assert_true  "1.10 >= 1.8"                   version_ge "1.10" "1.8"
assert_false "1.8 >= 1.10"                   version_ge "1.8"  "1.10"
# Empty constraint means "any".
assert_true  "any version satisfies empty min" version_ge "0.0.1" ""
# Unparseable HAVE never satisfies.
assert_false "garbage HAVE fails" version_ge "garbage" "1.0"

# ---------------------------------------------------------------------------
# 4. check_tool / detect_version against a sandbox of FAKE tools.
#    Each fake binary just echoes a chosen --version string.
# ---------------------------------------------------------------------------
echo "-- check_tool (fake tools on PATH)"
FAKEBIN="$(mktemp -d)"
# SC2317: invoked by the EXIT trap, not inline.
# shellcheck disable=SC2317
cleanup() { rm -rf "$FAKEBIN"; }
trap cleanup EXIT

# make_fake NAME VERSION-STRING  -> writes $FAKEBIN/NAME that prints it
make_fake() {
  local name="$1" vstr="$2"
  cat > "${FAKEBIN}/${name}" <<EOF
#!/usr/bin/env bash
printf '%s\n' "${vstr}"
EOF
  chmod +x "${FAKEBIN}/${name}"
}

make_fake "faketf_new" "Terraform v1.14.1"   # satisfies >= 1.6
make_fake "faketf_old" "Terraform v1.5.7"    # too old for >= 1.6
make_fake "fakepy_new" "Python 3.10.12"      # satisfies >= 3.10
make_fake "fakepy_old" "Python 3.9.18"       # too old for >= 3.10 (string would PASS!)

PATH="${FAKEBIN}:${PATH}"

# detect_version returns the parsed version.
assert_eq "detect_version reads fake terraform" "1.14.1" "$(detect_version faketf_new)"
assert_eq "detect_version reads fake python"    "3.10.12" "$(detect_version fakepy_new)"
assert_false "detect_version on absent tool returns 1" detect_version definitely-not-a-real-tool-xyz

# NOTE: we capture each check_tool call in "$(...)" to read its stdout, so the
# CHECK_* counter increments happen in a SUBSHELL and do NOT reach this scope.
# Per-call assertions use the return code and printed text. A dedicated counter
# test further down runs check_tool inline (no subshell) to verify the counters.

# check_tool PASS path.
out="$(check_tool "tf" "faketf_new" "1.6" "required" "hint")"; rc=$?
assert_eq  "check_tool: new terraform returns 0" "0" "$rc"
assert_contains "check_tool: prints PASS for new tf" "$out" "[PASS]"

# check_tool FAIL path: too old.
out="$(check_tool "tf" "faketf_old" "1.6" "required" "upgrade terraform")"; rc=$?
assert_eq  "check_tool: old terraform returns 1" "1" "$rc"
assert_contains "check_tool: prints FAIL for old tf" "$out" "[FAIL]"
assert_contains "check_tool: FAIL shows the hint"    "$out" "upgrade terraform"

# The decisive case: python 3.9 must FAIL a >= 3.10 gate (a string compare PASSES it).
out="$(check_tool "python3" "fakepy_old" "3.10" "required" "install 3.10+")"; rc=$?
assert_eq  "check_tool: python 3.9 vs >=3.10 returns 1 (FAIL)" "1" "$rc"
assert_contains "check_tool: python 3.9 flagged too old" "$out" "too old"

# python 3.10 must PASS a >= 3.10 gate.
out="$(check_tool "python3" "fakepy_new" "3.10" "required" "install 3.10+")"; rc=$?
assert_eq  "check_tool: python 3.10 vs >=3.10 returns 0 (PASS)" "0" "$rc"

# Missing REQUIRED tool -> FAIL (returns 1).
out="$(check_tool "ghost" "definitely-not-a-real-tool-xyz" "1.0" "required" "install it")"; rc=$?
assert_eq  "check_tool: missing required returns 1" "1" "$rc"
assert_contains "check_tool: missing required says not installed" "$out" "not installed"

# Missing OPTIONAL tool -> WARN (returns 0, does not fail the suite).
out="$(check_tool "ghost" "definitely-not-a-real-tool-xyz" "1.0" "optional" "install it")"; rc=$?
assert_eq  "check_tool: missing optional returns 0" "0" "$rc"
assert_contains "check_tool: missing optional warns" "$out" "[WARN]"

# Counter test: run check_tool INLINE (no subshell) so the global CHECK_* counters
# actually update, and assert them. This also proves the WARN/FAIL bookkeeping.
echo "-- check_tool counters (inline)"
CHECK_PASS=0; CHECK_FAIL=0; CHECK_WARN=0
check_tool "tf"      "faketf_new" "1.6"  "required" "h" >/dev/null   # +1 pass
check_tool "tf"      "faketf_old" "1.6"  "required" "h" >/dev/null   # +1 fail
check_tool "ghost"   "no-such-xyz" "1.0" "optional" "h" >/dev/null   # +1 warn
assert_eq "counters: CHECK_PASS == 1" "1" "$CHECK_PASS"
assert_eq "counters: CHECK_FAIL == 1" "1" "$CHECK_FAIL"
assert_eq "counters: CHECK_WARN == 1" "1" "$CHECK_WARN"

# ---------------------------------------------------------------------------
# 5. broken/ fixture must REPRODUCE the bug (string compare ranks 3.9 > 3.10).
# ---------------------------------------------------------------------------
echo "-- broken/setup-check-broken.sh (expected to be WRONG)"
# Parses cleanly — the bug is behavioural, not syntactic.
assert_true "broken: still parses" bash -n "$BROKEN"

# Source the broken version_ge in a SUBSHELL so it does not clobber the real one,
# then probe the headline case directly.
broken_39_ge_310="$(
  bash -c '
    set -uo pipefail
    # Pull just the buggy version_ge out of the fixture and define it here.
    source <(sed -n "/^version_ge()/,/^}/p" "$1")
    if version_ge "3.9" "3.10"; then echo YES; else echo NO; fi
  ' _ "$BROKEN"
)"
# The whole point: the BROKEN code wrongly says 3.9 >= 3.10.
assert_eq "broken: WRONGLY reports 3.9 >= 3.10 (bug intact)" "YES" "$broken_39_ge_310"

broken_310_ge_39="$(
  bash -c '
    set -uo pipefail
    source <(sed -n "/^version_ge()/,/^}/p" "$1")
    if version_ge "3.10" "3.9"; then echo YES; else echo NO; fi
  ' _ "$BROKEN"
)"
# ...and wrongly says 3.10 is NOT >= 3.9.
assert_eq "broken: WRONGLY reports 3.10 < 3.9 (bug intact)" "NO" "$broken_310_ge_39"

# Sanity: the FIXED solution gets both right (already covered above, restated).
assert_true  "solution: correctly 3.10 >= 3.9"  version_ge "3.10" "3.9"
assert_false "solution: correctly NOT 3.9>=3.10" version_ge "3.9" "3.10"

# ---------------------------------------------------------------------------
echo "== ${PASS} passed, ${FAIL} failed =="
exit $((FAIL > 0 ? 1 : 0))
