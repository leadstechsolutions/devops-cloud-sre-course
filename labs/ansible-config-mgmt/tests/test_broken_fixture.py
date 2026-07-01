"""The broken/ fixture MUST be rejected by our invariant checks.

This proves the validation gate actually has teeth: a dangerous-but-valid-YAML
hardening file is caught by the same checks that pass the solution. If these
tests ever PASS the fixture (i.e. fail to detect a defect), the gate is broken.
"""

import os
import unittest

import yaml

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
BROKEN = os.path.join(ROOT, "broken", "hardening-tasks-bad.yml")


def load_tasks(path):
    with open(path, encoding="utf-8") as fh:
        return [t for t in (yaml.safe_load(fh) or []) if isinstance(t, dict)]


def audit(tasks):
    """Return the set of defects detected in a hardening tasks list."""
    defects = set()
    names = [t.get("name", "") for t in tasks]

    for t in tasks:
        mod = t.get("ansible.builtin.lineinfile")
        if not isinstance(mod, dict):
            continue
        line = mod.get("line", "")
        if line.replace(" ", "").lower() == "permitrootloginyes":
            defects.add("root_login_enabled")
        if mod.get("path") == "/etc/ssh/sshd_config" and "validate" not in mod:
            defects.add("unvalidated_sshd_edit")

    # Order check: default-deny before an allow-22 rule.
    deny_idx = next((i for i, n in enumerate(names) if "default-deny" in n.lower()), None)
    allow_idx = next((i for i, n in enumerate(names) if "allow inbound" in n.lower()), None)
    if deny_idx is not None and (allow_idx is None or deny_idx < allow_idx):
        defects.add("deny_before_allow")

    return defects


class BrokenFixtureTest(unittest.TestCase):
    def setUp(self):
        self.defects = audit(load_tasks(BROKEN))

    def test_fixture_is_valid_yaml(self):
        # It parses — the danger is semantic, not syntactic. That is the point.
        self.assertTrue(load_tasks(BROKEN))

    def test_detects_root_login_enabled(self):
        self.assertIn("root_login_enabled", self.defects)

    def test_detects_unvalidated_sshd_edit(self):
        self.assertIn("unvalidated_sshd_edit", self.defects)

    def test_detects_deny_before_allow(self):
        self.assertIn("deny_before_allow", self.defects)


if __name__ == "__main__":
    unittest.main()
