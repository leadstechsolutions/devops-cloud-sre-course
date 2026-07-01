"""Stdlib unittest for iam_policy_audit. No pip, no boto3, no network.

Run from the module root:
    PYTHONPATH=solution python3 -m unittest discover -s tests

The good/bad fixtures live under solution/policies/iam/. We resolve them
relative to this test file so the suite runs from any cwd.
"""
import json
import os
import unittest

import iam_policy_audit as audit

HERE = os.path.dirname(os.path.abspath(__file__))
MODULE_ROOT = os.path.dirname(HERE)
IAM_DIR = os.path.join(MODULE_ROOT, "solution", "policies", "iam")


def load(name: str) -> dict:
    with open(os.path.join(IAM_DIR, name), encoding="utf-8") as fh:
        return json.load(fh)


class TestHelpers(unittest.TestCase):
    def test_as_list_normalises(self):
        self.assertEqual(audit._as_list(None), [])
        self.assertEqual(audit._as_list("a"), ["a"])
        self.assertEqual(audit._as_list(["a", "b"]), ["a", "b"])

    def test_has_wildcard_detects_star_and_qmark(self):
        self.assertEqual(audit._has_wildcard(["s3:GetObject", "s3:*"]), "s3:*")
        self.assertEqual(audit._has_wildcard(["iam:Get?"]), "iam:Get?")
        self.assertIsNone(audit._has_wildcard(["s3:GetObject", "s3:ListBucket"]))
        self.assertIsNone(audit._has_wildcard([]))

    def test_resource_overbroad_vs_scoped(self):
        # over-broad: the resource-id itself begins with a wildcard.
        self.assertTrue(audit._resource_is_overbroad("*"))
        self.assertTrue(audit._resource_is_overbroad("arn:aws:s3:::*"))
        self.assertTrue(audit._resource_is_overbroad("arn:aws:s3:::*/secret"))
        # scoped least-privilege -- must NOT be flagged: the resource-id starts
        # with a concrete name, the '*' only widens within that named resource.
        self.assertFalse(audit._resource_is_overbroad("arn:aws:s3:::my-bucket"))
        self.assertFalse(audit._resource_is_overbroad("arn:aws:s3:::my-bucket/*"))
        self.assertFalse(
            audit._resource_is_overbroad("arn:aws:iam::111122223333:role/app-*"))
        # Known limitation (documented): a "type/*" id like ".../instance/*" is
        # NOT caught by this simple linter because the id starts with a concrete
        # type name; gitleaks/Access Analyzer go deeper. See README.
        self.assertFalse(
            audit._resource_is_overbroad("arn:aws:ec2:us-east-1:111122223333:instance/*"))

    def test_first_overbroad_resource(self):
        self.assertEqual(
            audit._first_overbroad_resource(
                ["arn:aws:s3:::named/*", "arn:aws:s3:::*"]),
            "arn:aws:s3:::*")
        self.assertIsNone(
            audit._first_overbroad_resource(
                ["arn:aws:s3:::named", "arn:aws:s3:::named/*"]))


class TestGoodPolicy(unittest.TestCase):
    def setUp(self):
        self.policy = load("good-policy.json")

    def test_good_policy_has_no_findings(self):
        findings = audit.audit_policy(self.policy)
        self.assertEqual(findings, [],
                         msg=f"expected clean policy, got {findings}")

    def test_deny_wildcard_is_not_flagged(self):
        # The good policy contains a Deny */* guardrail; it must NOT be flagged.
        codes = [f.code for f in audit.audit_policy(self.policy)]
        self.assertNotIn("WILDCARD_ACTION", codes)
        self.assertNotIn("WILDCARD_RESOURCE", codes)


class TestBadPolicy(unittest.TestCase):
    def setUp(self):
        self.findings = audit.audit_policy(load("bad-policy.json"))
        self.by_code = {}
        for f in self.findings:
            self.by_code.setdefault(f.code, []).append(f)

    def test_flags_full_admin_high(self):
        admin = [f for f in self.findings
                 if f.sid == "AdminEverything"]
        codes = {f.code: f.severity for f in admin}
        self.assertEqual(codes.get("WILDCARD_ACTION"), "HIGH")
        self.assertEqual(codes.get("WILDCARD_RESOURCE"), "HIGH")

    def test_scoped_wildcard_is_medium(self):
        s3 = [f for f in self.findings if f.sid == "AllS3AnyBucket"]
        sev = {f.code: f.severity for f in s3}
        # "s3:*" is a scoped action wildcard -> MEDIUM, not HIGH.
        self.assertEqual(sev.get("WILDCARD_ACTION"), "MEDIUM")
        # "arn:aws:s3:::*" is a scoped resource wildcard -> MEDIUM.
        self.assertEqual(sev.get("WILDCARD_RESOURCE"), "MEDIUM")

    def test_flags_notaction(self):
        not_action = [f for f in self.findings
                      if f.code == "NOT_ACTION" and f.sid == "EverythingExceptIam"]
        self.assertEqual(len(not_action), 1)

    def test_bad_policy_has_findings(self):
        self.assertGreater(len(self.findings), 0)
        # The full-admin statement alone yields 2 findings; bad-policy total >= 5.
        self.assertGreaterEqual(len(self.findings), 5)


class TestStatementEdgeCases(unittest.TestCase):
    def test_missing_statement_raises(self):
        with self.assertRaises(ValueError):
            audit.audit_policy({"Version": "2012-10-17"})

    def test_single_statement_object_accepted(self):
        policy = {
            "Statement": {
                "Sid": "One", "Effect": "Allow",
                "Action": "*", "Resource": "*",
            }
        }
        findings = audit.audit_policy(policy)
        self.assertEqual(len(findings), 2)  # wildcard action + wildcard resource

    def test_not_resource_flagged(self):
        policy = {"Statement": [{
            "Sid": "NR", "Effect": "Allow",
            "Action": "s3:GetObject",
            "NotResource": "arn:aws:s3:::secret/*",
        }]}
        codes = [f.code for f in audit.audit_policy(policy)]
        self.assertIn("NOT_RESOURCE", codes)

    def test_non_allow_statement_ignored(self):
        policy = {"Statement": [{
            "Sid": "D", "Effect": "Deny", "Action": "*", "Resource": "*",
        }]}
        self.assertEqual(audit.audit_policy(policy), [])


if __name__ == "__main__":
    unittest.main()
