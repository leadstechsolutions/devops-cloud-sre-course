# Lab toolchain

Everything needed to run **every** module's `./validate.sh` with real tools (no DEFERRED).

```bash
bash labs/tools/install-toolchain.sh        # ~/.local/bin, no root needed
export PATH="$HOME/.local/bin:$PATH"         # add to ~/.bashrc
bash labs/tools/kind-up.sh                    # optional: real local Kubernetes (free, disposable)
```

Installs (pinned versions): terraform·helm·kind·kubectl·kubeconform·docker·shellcheck·
hadolint·opa·conftest·grype·syft·cosign·k6·promtool·actionlint·ansible·ansible-lint·
yamllint·checkov·pytest.

| Lab | Gate the toolchain unlocks |
|---|---|
| linux-shell-automation | `shellcheck -x` on every script |
| docker-containers | `hadolint`, `grype` CVE scan, `syft` SBOM, `cosign` sign/verify |
| kubernetes-fundamentals | `kubeconform` + **live `kubectl apply` on kind** (OOMKilled/probe repro) |
| helm-charts | `helm lint`, `helm template`, `kubeconform` |
| ansible-config-mgmt | `ansible-playbook --syntax-check`, `ansible-lint` |
| observability | `promtool check rules/config` |
| security-automation | `opa test`, `conftest test` |
| terraform-aws-foundations | `checkov` IaC scan (+ `terraform validate`) |
| cicd-pipelines | `actionlint`, `yamllint` |
| sre-incident-response | `k6` script run against the deployed app |

> **AWS labs** additionally need credentials for an isolated sandbox account. Configure
> with `aws configure` (or SSO) and follow each lab's **apply → validate → `terraform destroy`**
> flow. Keep test spend trivial: VPC/IGW/subnets/S3/DynamoDB/IAM are ~$0; never leave a NAT
> gateway, RDS instance, or EKS control plane running. Destroy immediately.

Cluster lifecycle: `bash labs/tools/kind-up.sh` to create, `kind delete cluster --name course` to remove.
