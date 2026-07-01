# Learner Repositories (`labs/`)

These are the **runnable** half of the course. Every hands-on technology in the 25-week
program has a self-contained module repository here with real files you can lint, plan,
build, run, and validate — not fenced code blocks inside Markdown.

Each module follows the structure in [`_TEMPLATE/`](_TEMPLATE/).

## How to use a module

```bash
cd labs/<module>
cat README.md            # prerequisites, architecture, tasks, cleanup, cost, security
# do the lab in starter/  (intentionally incomplete — you fill the gaps)
# check yourself against solution/  (reference implementation)
./validate.sh            # runs the module's validation gates
```

## Module catalog

| # | Module | Used in weeks | Primary artifacts | Local validation in this repo |
|--:|--------|---------------|-------------------|-------------------------------|
| 0 | [setup-validation](setup-validation/) | W1 | `*.sh` toolchain checker | `bash -n`, `shellcheck`, run checker + tests |
| 1 | [linux-shell-automation](linux-shell-automation/) | W2, W8 | `*.sh` | `bash -n`, run smoke tests |
| 2 | [python-automation](python-automation/) | W8 | `*.py`, `tests/` | `py_compile`, `unittest` |
| 3 | [git-collaboration](git-collaboration/) | W3 | `*.sh`, hooks | `bash -n`, scripted scenario |
| 4 | [terraform-aws-foundations](terraform-aws-foundations/) | W14, W15, W4/5/7 | `*.tf`, `*.tfvars.example` | `terraform fmt/init/validate` |
| 5 | [cicd-pipelines](cicd-pipelines/) | W9, W19 | GH Actions, GitLab CI | YAML parse, job graph check |
| 6 | [docker-containers](docker-containers/) | W10 | `Dockerfile`, `compose.yaml`, app | `docker build`, `compose config` |
| 7 | [kubernetes-fundamentals](kubernetes-fundamentals/) | W11, W12 | `*.yaml` manifests | YAML parse, `--dry-run=client` |
| 8 | [helm-charts](helm-charts/) | W13 | `Chart.yaml`, templates | `helm lint` + `helm template` + `kubeconform` + live `kubectl apply --dry-run=server` |
| 9 | [ansible-config-mgmt](ansible-config-mgmt/) | W8 (ext) | playbooks, roles | `ansible-playbook --syntax-check` + `ansible-lint` |
| 10 | [observability](observability/) | W16, W21 | Prom rules, Grafana JSON, OTel | `promtool check rules/config` + JSON/YAML parse |
| 11 | [security-automation](security-automation/) | W6, W19 | `*.sh`, policies, IAM JSON | `opa test` + `shellcheck` + JSON parse |
| 12 | [sre-incident-response](sre-incident-response/) | W21, W22 | SLO YAML, runbooks, k6, scripts | real `k6 run` + `py_compile` + tests + `bash -n` |
| 13 | [capstone](capstone/) | W23, W24 | integrates 4–12 | per-component gates |
| 14 | [aws-cli-fundamentals](aws-cli-fundamentals/) | W4 | `*.sh` read-only AWS ops | `shellcheck` + live read-only run on a real account ($0) |
| 15 | [aws-storage-databases](aws-storage-databases/) | W7 | `*.tf` S3/DynamoDB/EBS/EC2 | `terraform validate` + `checkov` + **live apply→destroy** ($0) |
| 16 | [performance-scaling](performance-scaling/) | W22 | k8s HPA, k6 load, cpu-burner | `kubeconform` + `k6` + **live HPA 1→5 under load on kind** |
| 17 | [career-prep](career-prep/) | W25 | resume/system-design/STAR (md) | structure + substance checks (presence + min length) |
| 18 | [platform-golden-path](platform-golden-path/) | W20 | service template + `scaffold.sh` generator, Dockerfile, Helm chart, GH Actions CI | `shellcheck` + scaffold run/diff + `py_compile`/`unittest` + `hadolint` + `actionlint` + `helm lint/template` + `kubeconform` + **real `docker build` of the generated service** (+ live kind deploy & `helm test` via `RUN_LIVE=1 ./drill.sh`) |
| 19 | [observability-stack](observability-stack/) | W16, W21 | instrumented `/metrics` app, single-Prometheus k8s deploy, RED recording rules, multi-burn-rate alert, Grafana JSON | `py_compile`/`unittest` + `promtool check config/rules` + **`promtool test rules` (burn-rate alert FIRES on synthetic data)** + `kubeconform` + `hadolint` + JSON parse (+ live kind deploy & PromQL query via `RUN_LIVE=1 ./run-demo.sh`) |

## Status legend

Each module README states its build status honestly:

- **Validated** — files exist on disk and pass their local validation gate in this environment.
- **Structurally validated** — files parse and are render-checked, but the full tool
  (`helm`, `ansible-lint`, `promtool`, a live cluster, an AWS account) is not present in
  this build environment; the README documents the exact command to run where it is.
- **Scaffolded** — structure, README, and task list exist; reference solution is partial
  and labeled as such. Not to be scored as practiced.

Do not treat a "Scaffolded" module as a completed lab. See each README's top banner.

## Cost & safety

Modules that provision real cloud resources (`terraform-aws-foundations`, parts of the
capstone) are written **plan-only by default** — you must run `terraform apply` yourself,
on your own account, after reading the cost note. Every such module ships a `cleanup`
path. Nothing here charges money unless you explicitly apply it.
