"""Structural security tests for the ansible-config-mgmt module.

Ansible itself is not installed in this environment, so we cannot run a live
`--check` against a host. Instead we parse the role YAML with PyYAML and assert
the *security invariants* the lab is supposed to teach:

  - the solution disables root SSH login and password auth, and enables pubkey
  - the solution opens exactly the ports 22/80/443 and nothing else
  - the firewall default policy is deny-inbound
  - the starter has the sshd lockdown tasks removed (it is intentionally
    incomplete) but is still valid YAML

These run under stdlib `unittest` (no pip, no network).
"""

import os
import unittest

import yaml

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SOL = os.path.join(ROOT, "solution")
STARTER = os.path.join(ROOT, "starter")


def load_tasks(path):
    """Load a tasks file into a list of task dicts (drop nulls/comments)."""
    with open(path, encoding="utf-8") as fh:
        data = yaml.safe_load(fh)
    return [t for t in (data or []) if isinstance(t, dict)]


def lineinfile_lines(tasks):
    """Return the `line:` values of every ansible.builtin.lineinfile task."""
    out = []
    for t in tasks:
        mod = t.get("ansible.builtin.lineinfile") or t.get("lineinfile")
        if isinstance(mod, dict) and "line" in mod:
            out.append(mod["line"])
    return out


class GroupVarsTest(unittest.TestCase):
    def setUp(self):
        with open(os.path.join(SOL, "group_vars", "all.yml"), encoding="utf-8") as fh:
            self.vars = yaml.safe_load(fh)

    def test_root_login_disabled(self):
        self.assertEqual(self.vars["ssh_permit_root_login"], "no")

    def test_password_auth_disabled(self):
        self.assertEqual(self.vars["ssh_password_authentication"], "no")

    def test_pubkey_auth_enabled(self):
        self.assertEqual(self.vars["ssh_pubkey_authentication"], "yes")

    def test_allowed_ports_exactly_22_80_443(self):
        ports = sorted(p["port"] for p in self.vars["ufw_allowed_ports"])
        self.assertEqual(ports, ["22", "443", "80"])
        for rule in self.vars["ufw_allowed_ports"]:
            self.assertEqual(rule["proto"], "tcp")

    def test_app_user_defined(self):
        self.assertTrue(self.vars["app_user"])
        self.assertTrue(self.vars["app_group"])


class SolutionHardeningTest(unittest.TestCase):
    def setUp(self):
        self.tasks = load_tasks(
            os.path.join(SOL, "roles", "hardening", "tasks", "main.yml")
        )
        self.lines = lineinfile_lines(self.tasks)

    def test_solution_disables_root_login(self):
        self.assertTrue(
            any(l.startswith("PermitRootLogin") for l in self.lines),
            "solution must set PermitRootLogin",
        )

    def test_solution_disables_password_auth(self):
        self.assertTrue(
            any(l.startswith("PasswordAuthentication") for l in self.lines),
            "solution must set PasswordAuthentication",
        )

    def test_solution_enables_pubkey_auth(self):
        self.assertTrue(
            any(l.startswith("PubkeyAuthentication") for l in self.lines),
            "solution must set PubkeyAuthentication",
        )

    def test_every_sshd_edit_is_validated(self):
        # Each lineinfile that touches sshd_config must use a validate: guard so
        # a broken edit cannot be written. This is the lock-yourself-out check.
        for t in self.tasks:
            mod = t.get("ansible.builtin.lineinfile")
            if isinstance(mod, dict) and mod.get("path") == "/etc/ssh/sshd_config":
                self.assertIn(
                    "validate",
                    mod,
                    f"sshd edit '{t.get('name')}' is missing a validate: guard",
                )
                self.assertIn("sshd -t", mod["validate"])

    def test_ufw_allow_before_default_deny(self):
        # The 'allow ports' task must appear before the 'default deny' task so we
        # never drop our own SSH session.
        names = [t.get("name", "") for t in self.tasks]
        allow_idx = next(i for i, n in enumerate(names) if "Allow inbound ports" in n)
        deny_idx = next(i for i, n in enumerate(names) if "Default deny" in n)
        self.assertLess(allow_idx, deny_idx)


class StarterIsIncompleteTest(unittest.TestCase):
    """The starter must be valid YAML but missing the sshd lockdown tasks."""

    def setUp(self):
        self.path = os.path.join(STARTER, "roles", "hardening", "tasks", "main.yml")
        self.tasks = load_tasks(self.path)
        self.lines = lineinfile_lines(self.tasks)

    def test_starter_yaml_is_valid(self):
        self.assertIsInstance(self.tasks, list)
        self.assertGreater(len(self.tasks), 0)

    def test_starter_missing_sshd_lockdown(self):
        for directive in (
            "PermitRootLogin",
            "PasswordAuthentication",
            "PubkeyAuthentication",
        ):
            self.assertFalse(
                any(l.startswith(directive) for l in self.lines),
                f"starter should NOT yet implement {directive} (it is a TODO)",
            )

    def test_starter_has_todo_markers(self):
        with open(self.path, encoding="utf-8") as fh:
            body = fh.read()
        self.assertGreaterEqual(body.count("TODO(student)"), 3)


if __name__ == "__main__":
    unittest.main()
