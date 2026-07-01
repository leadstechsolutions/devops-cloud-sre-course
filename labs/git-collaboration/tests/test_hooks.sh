#!/usr/bin/env bash
set -euo pipefail

# test_hooks.sh
# ---------------------------------------------------------------------------
# Black-box behaviour tests for the solution/ hooks and scenario. Each test
# builds a throwaway repo under a mktemp dir, installs the solution hook(s),
# and asserts the hook blocks or allows the right things. No network needed.
#
# Run: tests/test_hooks.sh   (exits non-zero on first failed assertion)
# ---------------------------------------------------------------------------

MODULE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOL="$MODULE_DIR/solution"

WORK="$(mktemp -d)"
trap 'rm -rf -- "$WORK"' EXIT

pass=0; fail=0
ok()   { printf '  [PASS] %s\n' "$1"; pass=$((pass+1)); }
bad()  { printf '  [FAIL] %s\n' "$1"; fail=$((fail+1)); }

# Deterministic identity for the test repos.
export GIT_AUTHOR_NAME="Test" GIT_AUTHOR_EMAIL="t@example.com"
export GIT_COMMITTER_NAME="Test" GIT_COMMITTER_EMAIL="t@example.com"

new_repo() {
  local r="$WORK/$1"
  rm -rf -- "$r"; mkdir -p -- "$r"
  git -C "$r" init -q -b main
  cp "$SOL/hooks/pre-commit"  "$r/.git/hooks/pre-commit"
  cp "$SOL/hooks/commit-msg"  "$r/.git/hooks/commit-msg"
  chmod +x "$r/.git/hooks/pre-commit" "$r/.git/hooks/commit-msg"
  echo "$r"
}

echo "== git-collaboration hook tests =="

# --- 1. pre-commit BLOCKS a staged AWS access key --------------------------
r="$(new_repo aws_key)"
printf 'aws_access_key_id = AKIAIOSFODNN7EXAMPLE\n' >"$r/creds.txt"
git -C "$r" add creds.txt
if git -C "$r" commit -m "feat: add creds" >/dev/null 2>&1; then
  bad "pre-commit should block an AWS access key"
else
  ok "pre-commit blocks an AWS access key"
fi

# --- 2. pre-commit BLOCKS a staged private-key PEM header ------------------
r="$(new_repo pem)"
printf -- '-----BEGIN RSA PRIVATE KEY-----\nMIIabc\n-----END RSA PRIVATE KEY-----\n' >"$r/id_rsa"
git -C "$r" add id_rsa
if git -C "$r" commit -m "chore: add key" >/dev/null 2>&1; then
  bad "pre-commit should block a private key"
else
  ok "pre-commit blocks a private key"
fi

# --- 3. pre-commit BLOCKS a staged file > 5 MB -----------------------------
r="$(new_repo bigfile)"
head -c $((6 * 1024 * 1024)) /dev/zero >"$r/blob.bin"
git -C "$r" add blob.bin
if git -C "$r" commit -m "chore: add blob" >/dev/null 2>&1; then
  bad "pre-commit should block a >5MB file"
else
  ok "pre-commit blocks a >5MB file"
fi

# --- 4. pre-commit ALLOWS a clean, small, secret-free commit ---------------
r="$(new_repo clean)"
printf 'hello world\n' >"$r/app.txt"
git -C "$r" add app.txt
if git -C "$r" commit -m "feat: add greeting" >/dev/null 2>&1; then
  ok "pre-commit allows a clean commit"
else
  bad "pre-commit wrongly blocked a clean commit"
fi

# --- 5. commit-msg ACCEPTS a Conventional Commits subject ------------------
r="$(new_repo good_msg)"
printf 'x\n' >"$r/a.txt"; git -C "$r" add a.txt
if git -C "$r" commit -m "fix(api): handle empty payload" >/dev/null 2>&1; then
  ok "commit-msg accepts a Conventional Commit subject"
else
  bad "commit-msg wrongly rejected a valid subject"
fi

# --- 6. commit-msg REJECTS a non-conventional subject ----------------------
r="$(new_repo bad_msg)"
printf 'x\n' >"$r/a.txt"; git -C "$r" add a.txt
if git -C "$r" commit -m "updated stuff" >/dev/null 2>&1; then
  bad "commit-msg should reject 'updated stuff'"
else
  ok "commit-msg rejects a non-conventional subject"
fi

# --- 7. setup-scenario produces an unresolved conflict ---------------------
sc="$WORK/scenario"
if "$SOL/setup-scenario.sh" --dir "$sc" >/dev/null 2>&1 \
   && git -C "$sc" status --porcelain | grep -q '^UU config.yaml'; then
  ok "setup-scenario leaves an unresolved conflict (UU config.yaml)"
else
  bad "setup-scenario did not leave the expected conflict"
fi

# --- 8. setup-scenario is idempotent (second run rebuilds cleanly) ---------
if "$SOL/setup-scenario.sh" --dir "$sc" >/dev/null 2>&1 \
   && git -C "$sc" status --porcelain | grep -q '^UU config.yaml'; then
  ok "setup-scenario is idempotent on re-run"
else
  bad "setup-scenario was not idempotent"
fi

# --- 9. install-hooks symlinks the hooks into a target repo ----------------
ir="$WORK/install_target"
rm -rf -- "$ir"; mkdir -p -- "$ir"; git -C "$ir" init -q -b main
if "$SOL/install-hooks.sh" --target "$ir" >/dev/null 2>&1 \
   && [[ -L "$ir/.git/hooks/pre-commit" && -L "$ir/.git/hooks/commit-msg" ]]; then
  ok "install-hooks symlinks pre-commit and commit-msg"
else
  bad "install-hooks did not create the expected symlinks"
fi

echo "== $pass passed, $fail failed =="
exit $(( fail > 0 ? 1 : 0 ))
