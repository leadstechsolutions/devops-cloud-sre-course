"""Offline unit tests for tag_audit pure logic.

No AWS, no boto3, no network. PYTHONPATH must point at the implementation dir
(solution/ or starter/) so `import tag_audit` resolves -- validate.sh sets this.
"""
import unittest

import tag_audit


class TestNormalizeTagList(unittest.TestCase):
    def test_aws_shape_to_mapping(self):
        aws_tags = [
            {"Key": "Name", "Value": "web-1"},
            {"Key": "Owner", "Value": "team-x"},
        ]
        self.assertEqual(
            tag_audit.normalize_tag_list(aws_tags),
            {"Name": "web-1", "Owner": "team-x"},
        )

    def test_skips_entries_without_key(self):
        self.assertEqual(tag_audit.normalize_tag_list([{"Value": "orphan"}]), {})

    def test_missing_value_becomes_empty_string(self):
        self.assertEqual(tag_audit.normalize_tag_list([{"Key": "K"}]), {"K": ""})


class TestMissingTags(unittest.TestCase):
    def test_none_missing_when_all_present(self):
        res = {"id": "i-1", "tags": {"Owner": "a", "Env": "prod"}}
        self.assertEqual(tag_audit.missing_tags(res, ["Owner", "Env"]), [])

    def test_reports_absent_keys_sorted(self):
        res = {"id": "i-1", "tags": {"Owner": "a"}}
        self.assertEqual(
            tag_audit.missing_tags(res, ["Env", "CostCenter", "Owner"]),
            ["CostCenter", "Env"],
        )

    def test_empty_value_counts_as_missing(self):
        res = {"id": "i-1", "tags": {"Owner": "", "Env": None}}
        self.assertEqual(
            tag_audit.missing_tags(res, ["Owner", "Env"]), ["Env", "Owner"]
        )

    def test_resource_with_no_tags_key(self):
        res = {"id": "i-1"}
        self.assertEqual(tag_audit.missing_tags(res, ["Owner"]), ["Owner"])

    def test_non_mapping_tags_raises(self):
        res = {"id": "i-1", "tags": [("Owner", "a")]}
        with self.assertRaises(TypeError):
            tag_audit.missing_tags(res, ["Owner"])


class TestAuditResources(unittest.TestCase):
    def setUp(self):
        self.resources = [
            {"id": "i-good", "type": "ec2:instance",
             "tags": {"Owner": "a", "CostCenter": "100"}},
            {"id": "i-bad", "type": "ec2:instance",
             "tags": {"Owner": "a"}},
            {"id": "i-empty", "type": "ec2:instance", "tags": {}},
        ]
        self.required = ["Owner", "CostCenter"]

    def test_only_non_compliant_returned(self):
        findings = tag_audit.audit_resources(self.resources, self.required)
        ids = [f["id"] for f in findings]
        self.assertEqual(ids, ["i-bad", "i-empty"])

    def test_finding_shape(self):
        findings = tag_audit.audit_resources(self.resources, self.required)
        self.assertEqual(
            findings[0],
            {"id": "i-bad", "type": "ec2:instance", "missing": ["CostCenter"]},
        )

    def test_all_compliant_returns_empty(self):
        findings = tag_audit.audit_resources(
            [self.resources[0]], self.required
        )
        self.assertEqual(findings, [])

    def test_input_order_preserved(self):
        findings = tag_audit.audit_resources(self.resources, self.required)
        self.assertEqual([f["id"] for f in findings], ["i-bad", "i-empty"])

    def test_empty_required_raises(self):
        with self.assertRaises(ValueError):
            tag_audit.audit_resources(self.resources, [])


class TestFormatReport(unittest.TestCase):
    def test_compliant_message(self):
        self.assertIn("OK", tag_audit.format_report([]))

    def test_lists_each_finding(self):
        findings = [
            {"id": "i-bad", "type": "ec2:instance", "missing": ["CostCenter"]},
        ]
        out = tag_audit.format_report(findings)
        self.assertIn("NON-COMPLIANT", out)
        self.assertIn("i-bad", out)
        self.assertIn("CostCenter", out)


if __name__ == "__main__":
    unittest.main()
