#!/usr/bin/env bash
# Reproducible validation toolchain for the course labs.
# Installs everything to ~/.local/bin (no root) so a fresh clone can run every
# module's ./validate.sh with REAL tools (not DEFERRED). Idempotent.
#
# Usage:  bash labs/tools/install-toolchain.sh
#         export PATH="$HOME/.local/bin:$PATH"     # add to your shell rc
#         bash labs/tools/kind-up.sh               # optional: real local k8s
#
# Requires: curl, tar, python3 (>=3.10), docker (for kind/scanning).
set -uo pipefail
BIN="$HOME/.local/bin"; mkdir -p "$BIN"; export PATH="$BIN:$PATH"
TMP="$(mktemp -d)"; cd "$TMP" || exit 1
ok(){ printf '  [OK]   %-13s %s\n' "$1" "$2"; }
no(){ printf '  [FAIL] %-13s %s\n' "$1" "$2"; }
have(){ command -v "$1" >/dev/null 2>&1; }
dl(){ curl -fsSL -m 150 "$1" -o "$2"; }

# pinned versions (bump deliberately)
HELM=v3.16.3 KUBECONFORM=v0.6.7 KIND=v0.24.0 SHELLCHECK=v0.10.0 HADOLINT=2.12.0
OPA=v0.68.0 CONFTEST=0.55.0 K6=v0.54.0 PROM=2.54.1 SYFT=v1.14.1 COSIGN=v2.4.1
GRYPE=v0.82.0 ACTIONLINT=1.7.3

echo "== pip (user) =="
python3 -m pip --version >/dev/null 2>&1 || { dl https://bootstrap.pypa.io/get-pip.py get-pip.py && python3 get-pip.py --user -q; }
python3 -m pip install --user -q boto3 yamllint pytest checkov ansible-core ansible-lint 2>/dev/null \
  && ok pip "boto3 yamllint pytest checkov ansible ansible-lint" || no pip "see pip output"

echo "== static binaries -> $BIN =="
have helm        || { dl https://get.helm.sh/helm-${HELM}-linux-amd64.tar.gz h.tgz && tar xzf h.tgz && install -m755 linux-amd64/helm "$BIN/helm"; }
have kubeconform || { dl https://github.com/yannh/kubeconform/releases/download/${KUBECONFORM}/kubeconform-linux-amd64.tar.gz k.tgz && tar xzf k.tgz kubeconform && install -m755 kubeconform "$BIN/"; }
have kind        || { dl https://kind.sigs.k8s.io/dl/${KIND}/kind-linux-amd64 "$BIN/kind" && chmod +x "$BIN/kind"; }
have shellcheck  || { dl https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK}/shellcheck-${SHELLCHECK}.linux.x86_64.tar.xz s.txz && tar xJf s.txz && install -m755 shellcheck-${SHELLCHECK}/shellcheck "$BIN/"; }
have hadolint    || { dl https://github.com/hadolint/hadolint/releases/download/v${HADOLINT}/hadolint-Linux-x86_64 "$BIN/hadolint" && chmod +x "$BIN/hadolint"; }
have opa         || { dl https://github.com/open-policy-agent/opa/releases/download/${OPA}/opa_linux_amd64_static "$BIN/opa" && chmod +x "$BIN/opa"; }
have conftest    || { dl https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST}/conftest_${CONFTEST}_Linux_x86_64.tar.gz c.tgz && tar xzf c.tgz conftest && install -m755 conftest "$BIN/"; }
have grype       || { dl https://github.com/anchore/grype/releases/download/${GRYPE}/grype_${GRYPE#v}_linux_amd64.tar.gz g.tgz && tar xzf g.tgz grype && install -m755 grype "$BIN/"; }
have syft        || { dl https://github.com/anchore/syft/releases/download/${SYFT}/syft_${SYFT#v}_linux_amd64.tar.gz y.tgz && tar xzf y.tgz syft && install -m755 syft "$BIN/"; }
have cosign      || { dl https://github.com/sigstore/cosign/releases/download/${COSIGN}/cosign-linux-amd64 "$BIN/cosign" && chmod +x "$BIN/cosign"; }
have k6          || { dl https://github.com/grafana/k6/releases/download/${K6}/k6-${K6}-linux-amd64.tar.gz x.tgz && tar xzf x.tgz && install -m755 k6-${K6}-linux-amd64/k6 "$BIN/"; }
have promtool    || { dl https://github.com/prometheus/prometheus/releases/download/v${PROM}/prometheus-${PROM}.linux-amd64.tar.gz p.tgz && tar xzf p.tgz && install -m755 prometheus-${PROM}.linux-amd64/promtool "$BIN/"; }
have actionlint  || { dl https://github.com/rhysd/actionlint/releases/download/v${ACTIONLINT}/actionlint_${ACTIONLINT}_linux_amd64.tar.gz a.tgz && tar xzf a.tgz actionlint && install -m755 actionlint "$BIN/"; }

cd /; rm -rf "$TMP"
echo "== inventory =="
for t in terraform helm kind kubectl kubeconform docker shellcheck hadolint opa conftest grype syft cosign k6 promtool actionlint ansible ansible-lint yamllint checkov pytest; do
  have "$t" && printf '  yes %s\n' "$t" || printf '  --- %s MISSING\n' "$t"
done
echo "Add to your shell:  export PATH=\"\$HOME/.local/bin:\$PATH\""
