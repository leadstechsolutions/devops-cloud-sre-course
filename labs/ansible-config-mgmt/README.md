# Module: ansible-config-mgmt

> **Status:** Validated — every file parses, the security-invariant unit suite passes,
> **and the two authoritative Ansible gates now run here and PASS**:
> `ansible-playbook --syntax-check` (exit 0) and `ansible-lint` (0 failures, default
> profile — the solution actually clears the stricter `production` profile, 5/5).
> `./validate.sh` → **26 passed, 0 failed; exit 0** (and degrades to 24 passed on a
> Python-only box, `command -v`-guarded). The only remaining deferred gate is the
> `--check` dry run, which needs real/throwaway hosts. See [Validation](#validation)
> for the captured command output.
> **Tooling:** `ansible-core 2.17.14`, `ansible-lint 26.6.0`, collections
> `community.general` + `ansible.posix` (install with
> `ansible-galaxy collection install community.general ansible.posix`).
> **Maps to:** Week 08 (Configuration Management extension). Reuses the SSH key /
> instance-role posture established in `terraform-aws-foundations` (W14/15) and the
> CloudWatch destination from the `observability` module (W16/21).

## What you will build

An idempotent Ansible project that takes a fleet of fresh Ubuntu hosts (a `web` tier and
a `db` tier) to a known-good, hardened, observable baseline. Running `ansible-playbook
site.yml` applies three roles **in order** to every host:

1. **baseline** — creates a dedicated `appuser`/`appuser` group with an authorized SSH
   key, installs a common package set, sets the timezone to `Etc/UTC`, and ensures time
   sync (`chrony`) is running.
2. **hardening** — locks down `sshd` (`PermitRootLogin no`, `PasswordAuthentication no`,
   `PubkeyAuthentication yes`, plus `MaxAuthTries`/idle-timeout limits) **with an
   `sshd -t` validate guard on every edit so a bad change can't lock you out**, then
   configures the host firewall to **default-deny inbound and allow only 22/80/443**
   (opening the ports *before* flipping the default policy).
3. **cloudwatch_agent** — installs the Amazon CloudWatch agent and ships `/var/log/syslog`
   to CloudWatch Logs plus `mem`/`disk` metrics to CloudWatch Metrics, authenticating via
   the instance's IAM role (no baked-in keys).

The end state is verifiable: re-running the playbook reports **zero changes**
(idempotent), `sshd_config` denies root + password auth, and `ufw status` shows exactly
three allow rules.

## Prerequisites

- **To do the lab as written (against real hosts):**
  - `ansible-core >= 2.15` (`pip install ansible-core`) plus the collections
    `community.general` and `ansible.posix`
    (`ansible-galaxy collection install community.general ansible.posix`).
  - SSH access to one or more **Ubuntu 22.04+** hosts (EC2 instances, local VMs, or
    containers) that the control node can reach, with a sudo-capable bootstrap user.
  - An SSH keypair; put the private key at `~/.ssh/lab_ed25519` or edit
    `inventory.ini`.
  - For the `cloudwatch_agent` role to actually ship data: an AWS EC2 instance with an
    instance profile carrying the AWS-managed `CloudWatchAgentServerPolicy`.
- **To run the local validation gates in this repo (no hosts, no Ansible):**
  - `python3 >= 3.8` with **PyYAML** (`python3 -c "import yaml"` must succeed).
  - `bash >= 4`.
- **Prior modules reused:** the keypair/instance-role pattern from
  `labs/terraform-aws-foundations`; the CloudWatch destination from `labs/observability`.

## Architecture

See [`docs/architecture.mmd`](docs/architecture.mmd) (Mermaid).

```
control node ──ssh+sudo──> [web1 web2 db1]
   ansible.cfg + inventory.ini + group_vars/all.yml drive site.yml
   site.yml applies roles in order: baseline → hardening → cloudwatch_agent
   each host then streams syslog + mem/disk metrics → AWS CloudWatch
```

The control node holds no state on the targets beyond SSH; everything is declared in
`group_vars/all.yml` and the three roles. Role order matters: the app user must exist
(baseline) before SSH is locked down (hardening), and the agent is installed last.

## Repository layout

```
solution/                          # reference implementation (passes every gate)
  ansible.cfg                      # project-local Ansible config
  inventory.ini                    # [web]/[db] groups + [all:vars]
  site.yml                         # applies the three roles in order
  group_vars/all.yml               # all tunables (users, packages, ssh, ufw, cloudwatch)
  roles/
    baseline/{tasks,handlers,defaults}/main.yml
    hardening/{tasks,handlers}/main.yml
    cloudwatch_agent/{tasks,handlers,defaults}/main.yml
starter/                           # SAME tree, but the sshd lockdown tasks are TODO'd
broken/hardening-tasks-bad.yml     # a dangerous-but-valid-YAML fixture the gate rejects
tests/                             # stdlib unittest: security invariants + broken-fixture
docs/architecture.mmd              # diagram
validate.sh                        # runs every local gate; non-zero on any failure
```

## Setup

From a fresh clone, the local gates need nothing but Python + PyYAML:

```bash
cd labs/ansible-config-mgmt
python3 -c "import yaml"          # confirm PyYAML is present
./validate.sh                    # run the local gates (YAML parse + invariant tests)
```

To run it for real against hosts:

```bash
pip install "ansible-core>=2.15"
ansible-galaxy collection install community.general ansible.posix
cd solution
# edit inventory.ini: real ansible_host IPs + your key path
# override the placeholder key with your real public key:
ansible-playbook site.yml \
  --extra-vars "app_user_authorized_key='$(cat ~/.ssh/lab_ed25519.pub)'" \
  --check --diff               # dry run first; drop --check to apply
```

## Lab tasks

Do the work in **`starter/`**; check yourself against **`solution/`**.

1. **Read the existing roles.** Run `./validate.sh` once to see the starting state.
   _Done when:_ you can explain why role order in `site.yml` is baseline → hardening →
   cloudwatch_agent.

2. **Implement the three sshd lockdown tasks** in
   `starter/roles/hardening/tasks/main.yml` (replace the three `# TODO(student): ...`
   blocks). Each must use `ansible.builtin.lineinfile` with an idempotent `regexp:`, a
   `validate: "/usr/sbin/sshd -t -f %s"` guard, and `notify: Restart sshd`. The three
   directives are `PermitRootLogin`, `PasswordAuthentication`, `PubkeyAuthentication`,
   driven by the `ssh_*` vars in `group_vars/all.yml`.
   _Done when:_ pointing the invariant tests at `starter/` passes — verify with:
   ```bash
   # temporarily run the solution tests against your starter by diffing:
   diff <(grep -E '^\s+line:' starter/roles/hardening/tasks/main.yml) \
        <(grep -E '^\s+line:' solution/roles/hardening/tasks/main.yml)
   ```
   (no output = your three lines match the reference).

3. **Run the full gate.** `./validate.sh` must end with `0 failed` and exit 0.
   _Done when:_ exit code is 0 and the 17 unit tests pass.

4. **(With Ansible installed) syntax-check, lint, and dry-run.** With `ansible-core` +
   `ansible-lint` present, `./validate.sh` runs the syntax-check and lint gates for you
   (see [Validation](#validation)). For the remaining DEFERRED gate, run `--check --diff`
   against `solution/`.
   _Done when:_ `--syntax-check` exits 0, `ansible-lint solution/` reports 0 failures, and
   `--check --diff` shows the intended changes on a real/throwaway host, with a second run
   showing **zero changes** (idempotency).

## Validation

`./validate.sh` runs these (all PASS here):

| # | Gate | Command | Result |
|---|------|---------|--------|
| 1 | Every `.yml` is well-formed | `python3 -c "import yaml,sys; list(yaml.safe_load_all(open(f)))"` per file | **PASS** |
| 2 | Rendered agent config is valid JSON | `json.loads(json.dumps(cfg))` (mirrors the role) | **PASS** |
| 3 | Security-invariant + starter-incompleteness tests | `python3 -m unittest discover -s tests` | **PASS** (17 tests) |
| 4 | `broken/` fixture is detected as insecure | `python3 -m unittest tests.test_broken_fixture` | **PASS** |
| 5 | Playbook syntax-check | `ansible-playbook --syntax-check -i inventory.ini site.yml` | **PASS** (exit 0) |
| 6 | Lint (default profile; reaches `production`) | `ansible-lint solution/` | **PASS** (0 failures, 5/5) |

Gates 5–6 are `command -v`-guarded in `validate.sh`: they run wherever `ansible-core`
and `ansible-lint` are installed and **SKIP** (without failing the run) on a Python-only
box. They require the two collections:

```bash
ansible-galaxy collection install community.general ansible.posix
```

### Authoritative Ansible gates — captured output (PASS)

**A) Syntax check** — fastest authoritative gate:

```console
$ cd solution && ansible-playbook --syntax-check -i inventory.ini site.yml
[WARNING]: Collection community.general does not support Ansible version 2.17.14
playbook: site.yml
$ echo $?
0
```

(The `community.general` version warning is cosmetic — the collection's modules
resolve and the check passes; pin an older collection to silence it if desired.)

**B) Lint** for best-practice + security rules (run at the default profile; the
solution actually clears the stricter `production` profile):

```console
$ ansible-lint solution/
Passed: 0 failure(s), 1 warning(s) in 13 files processed of 15 encountered.
        Last profile that met the validation criteria was 'production'. Rating: 5/5 star
$ echo $?
0
```

The single residual is a **warning, not a failure** (exit 0): `args[module]` on the
`Default deny inbound, allow outbound` task. It is an *experimental* rule that can't
evaluate the looped `community.general.ufw` `policy: "{{ item.policy }}"` template at
lint time, so it wrongly reports the literal `{{ item.policy }}` isn't one of
allow/deny/reject. The loop only ever supplies `deny`/`allow`, which are valid — we keep
the proven open-22-before-default-deny ordering rather than weaken it to satisfy an
experimental linter limitation.

> **What was fixed to get here:** `ansible-lint` initially reported 13 fatal
> `var-naming[no-role-prefix]` violations — variables a role *defines* must carry the
> role name as a prefix. The role defaults/registers were renamed to `baseline_*` /
> `cloudwatch_agent_*` (e.g. `app_user` → `baseline_app_user`, `cw_ctl` →
> `cloudwatch_agent_ctl`). The fleet-wide public interface in `group_vars/all.yml` keeps
> the short names; each role default now resolves to that shared value
> (`baseline_app_user: "{{ app_user | default('appuser') }}"`). No security behaviour
> changed.

**C) Dry run against hosts** (still DEFERRED — needs real/throwaway hosts, not just the
tools). Show every change without making it; re-run to prove idempotency (second run must
report 0 changed):

```bash
cd solution && ansible-playbook site.yml --check --diff
```

## Expected results

`./validate.sh` final line and exit code (where `ansible-core` + `ansible-lint` are
installed, as here):

```
== 26 passed, 0 failed (plus 1 DEFERRED — see README) ==
# echo $? -> 0
```

On a Python-only box the two Ansible gates SKIP (not fail) and the line reads
`== 24 passed, 0 failed (plus 1 DEFERRED — see README) ==`, still exit 0.

Where Ansible is available, a successful apply ends with a recap like:

```
PLAY RECAP *********************************************************************
web1  : ok=18  changed=12  unreachable=0  failed=0  skipped=1  rescued=0  ignored=0
```

and a **second** `ansible-playbook site.yml` run shows `changed=0` on every host
(idempotent). On a target, `sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication'`
prints `permitrootlogin no` / `passwordauthentication no`, and `sudo ufw status` lists
only `22/tcp`, `80/tcp`, `443/tcp` ALLOW rules.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `./validate.sh` fails on a YAML parse line | A tab character or bad indentation in a role file | YAML forbids tabs; re-indent with 2 spaces. The failing path is printed. |
| Locked out of the host after a hardening run | An sshd edit was written without a `validate:` guard (see `broken/hardening-tasks-bad.yml`) | **Every** `lineinfile` against `sshd_config` must carry `validate: "/usr/sbin/sshd -t -f %s"`. The invariant test `test_every_sshd_edit_is_validated` enforces this. |
| Host unreachable mid-play, before SSH tasks finish | `ufw` default-deny was enabled *before* allowing port 22 (the `broken/` fixture's defect 3) | Order the tasks: **allow 22/80/443 first**, then set `policy: deny` for incoming. |
| `ansible-lint` flags `var-naming[no-role-prefix]` | A variable a role *defines* lacks the role-name prefix | Prefix role defaults/registers with the role name (`baseline_*` / `cloudwatch_agent_*`); keep the short names only in `group_vars/all.yml` and have each default resolve to them (e.g. `baseline_app_user: "{{ app_user \| default('appuser') }}"`). |
| `ansible-lint` shows a single `args[module]` *warning* on the ufw deny task | Experimental rule can't evaluate the looped `policy: "{{ item.policy }}"` template at lint time | Cosmetic — `ansible-lint` still exits 0. Do **not** weaken the open-22-before-deny ordering to silence it. |
| CloudWatch agent installs but ships nothing | The instance has no IAM role / `CloudWatchAgentServerPolicy` | Attach the AWS-managed policy to the instance profile. The role does **not** handle keys by design. |

**Reproduce the broken state:** `broken/hardening-tasks-bad.yml` is valid YAML but
insecure (root login left on, no validate guard, deny-before-allow). The gate
`python3 -m unittest tests.test_broken_fixture` proves all three defects are caught — if
that suite ever passes the fixture clean, the gate has lost its teeth.

## Cleanup

This module makes **no cloud resources by itself** — it configures hosts you already own.
To undo its effects on a target (run as the bootstrap/sudo user, **keep a session open**
so you aren't locked out):

```bash
# Re-allow password auth / root login only if you must:
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sshd -t && sudo systemctl reload ssh
# Disable the firewall:
sudo ufw disable
# Remove the app user and the CloudWatch agent:
sudo userdel -r appuser 2>/dev/null || true
sudo dpkg -r amazon-cloudwatch-agent 2>/dev/null || true
```

Local artifacts created by the gates are removed automatically (`validate.sh` uses a
trapped `mktemp`). There is nothing to destroy in this repo. If you spun up throwaway EC2
instances to test against, tear them down with the `terraform-aws-foundations` cleanup or
`aws ec2 terminate-instances`.

## Security considerations

- **No secrets in the repo.** The authorized key in `group_vars/all.yml` is an obviously
  fake placeholder; override it at runtime (`--extra-vars`, or Ansible Vault). Never
  commit a real private key or AWS access key.
- **Least privilege:** `become: true` is scoped at the play level and `sudo` is only used
  for tasks that need it. The CloudWatch agent authenticates via the **instance role**,
  not embedded credentials.
- **Lock-out safety is a security control here:** every `sshd_config` edit is validated
  before reload, and the firewall opens 22 before default-deny — both enforced by tests.
- **What NOT to commit:** `~/.ssh/lab_ed25519`, real inventory with public IPs, any
  rendered `amazon-cloudwatch-agent.json` containing account-specific data.
- For real fleets, store secrets in Ansible Vault (`ansible-vault encrypt`) and rotate the
  app user's authorized keys.

## Cost considerations

- The Ansible run itself is **$0** — it is just SSH.
- **CloudWatch is the only cost**, and only if you point the agent at a real AWS account:
  custom metrics (`mem`/`disk`) and ingested/stored logs are billed. With the lab's two
  metrics, one log stream per host, and 14-day retention, a few hosts cost roughly
  **< $1–2/month**. To stay at **$0**: don't apply the `cloudwatch_agent` role
  (`ansible-playbook site.yml --skip-tags cloudwatch`), or run the agent against
  LocalStack / not at all.
- EC2 test instances cost money while running — terminate them when done (see Cleanup).

## Instructor answer key

- **Reference solution:** [`solution/`](solution/). The graded gap is
  `solution/roles/hardening/tasks/main.yml` lines that set `PermitRootLogin`,
  `PasswordAuthentication`, and `PubkeyAuthentication`.
- **Non-obvious grading points:**
  1. The three sshd tasks **must** carry `validate: "/usr/sbin/sshd -t -f %s"`. A
     solution that sets the directives but omits the guard is a real-world lock-out risk —
     dock it even though it "works." Enforced by `test_every_sshd_edit_is_validated`.
  2. The `regexp:` must match the **commented** default (`^#?\s*PermitRootLogin`) or the
     task is not idempotent on a stock `sshd_config`.
  3. Firewall **ordering**: allow 22/80/443 before `policy: deny`. The `broken/` fixture
     exists precisely to make students articulate why.
  4. Variables, not literals: directives come from the `ssh_*` vars in
     `group_vars/all.yml`. Hard-coded `yes`/`no` in the task is a smell.
- **Common wrong answers:** using `PasswordAuthentication` as a boolean `false` (sshd
  wants the string `no`); forgetting `notify: Restart sshd` (changes never take effect);
  restarting instead of reloading sshd (drops live sessions — the handler reloads).
- **Quiz / troubleshooting answer:** the `broken/` fixture has exactly three defects
  (root login enabled, unvalidated edit, deny-before-allow); `tests/test_broken_fixture.py`
  is the answer key for detecting each.
