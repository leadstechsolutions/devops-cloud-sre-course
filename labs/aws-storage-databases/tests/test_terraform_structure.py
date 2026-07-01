"""Structural tests for the aws-storage-databases solution.

Stdlib-only checks (no terraform binary, no AWS, no network) that assert the
reference solution keeps the security and cost invariants the lab teaches. They
complement the terraform fmt/init/validate + checkov gates in validate.sh.

Run from the module root:
    python3 -m unittest discover -s tests
"""

import os
import re
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
SOLUTION = os.path.join(ROOT, "solution")
STARTER = os.path.join(ROOT, "starter")
BROKEN = os.path.join(ROOT, "broken")


def read(*parts):
    with open(os.path.join(*parts), encoding="utf-8") as fh:
        return fh.read()


class SolutionLayout(unittest.TestCase):
    def test_required_files_exist(self):
        for name in (
            "versions.tf",
            "providers.tf",
            "variables.tf",
            "main.tf",
            "outputs.tf",
            "terraform.tfvars.example",
        ):
            self.assertTrue(
                os.path.isfile(os.path.join(SOLUTION, name)),
                f"missing solution file: {name}",
            )


class VersionAndProvider(unittest.TestCase):
    def test_aws_provider_pinned_v5(self):
        versions = read(SOLUTION, "versions.tf")
        self.assertIn("hashicorp/aws", versions)
        self.assertRegex(versions, r'version\s*=\s*"~>\s*5\.0"')

    def test_required_version(self):
        self.assertRegex(
            read(SOLUTION, "versions.tf"), r'required_version\s*=\s*">=\s*1\.6"'
        )

    def test_provider_default_tags_and_region_var(self):
        providers = read(SOLUTION, "providers.tf")
        self.assertIn("default_tags", providers)
        self.assertIn("var.region", providers)


class Variables(unittest.TestCase):
    def setUp(self):
        self.vars = read(SOLUTION, "variables.tf")

    def test_environment_validation(self):
        self.assertIn('contains(["dev", "staging", "prod"]', self.vars)

    def test_enable_compute_defaults_off(self):
        block = re.search(
            r'variable "enable_compute" \{.*?\n\}', self.vars, re.DOTALL
        )
        self.assertIsNotNone(block, "enable_compute variable not found")
        self.assertRegex(block.group(0), r"type\s*=\s*bool")
        self.assertRegex(block.group(0), r"default\s*=\s*false")


class S3Security(unittest.TestCase):
    def setUp(self):
        self.main = read(SOLUTION, "main.tf")

    def test_data_bucket_versioning_and_sse_aes256(self):
        self.assertIn(
            'resource "aws_s3_bucket_versioning" "data"', self.main
        )
        self.assertIn(
            'resource "aws_s3_bucket_server_side_encryption_configuration" "data"',
            self.main,
        )
        self.assertIn('sse_algorithm = "AES256"', self.main)

    def test_public_access_block_all_true(self):
        block = re.search(
            r'resource "aws_s3_bucket_public_access_block" "data" \{.*?\n\}',
            self.main,
            re.DOTALL,
        )
        self.assertIsNotNone(block, "data public access block not found")
        for flag in (
            "block_public_acls",
            "block_public_policy",
            "ignore_public_acls",
            "restrict_public_buckets",
        ):
            self.assertRegex(
                block.group(0),
                rf"{flag}\s*=\s*true",
                f"{flag} must be true",
            )

    def test_lifecycle_expires_noncurrent_versions(self):
        self.assertIn(
            'resource "aws_s3_bucket_lifecycle_configuration" "data"', self.main
        )
        self.assertIn("noncurrent_version_expiration", self.main)

    def test_least_privilege_bucket_policy_denies_insecure_transport(self):
        self.assertIn("DenyInsecureTransport", self.main)
        self.assertIn("aws:SecureTransport", self.main)
        # Deny effect must be present for the secure-transport guard.
        self.assertIn('effect = "Deny"', self.main)


class DynamoDB(unittest.TestCase):
    def setUp(self):
        self.block = re.search(
            r'resource "aws_dynamodb_table" "app" \{.*?\n\}\n',
            read(SOLUTION, "main.tf"),
            re.DOTALL,
        )

    def test_block_found(self):
        self.assertIsNotNone(self.block, "dynamodb table block not found")

    def test_pay_per_request_pitr_and_sse(self):
        b = self.block.group(0)
        self.assertIn('billing_mode = "PAY_PER_REQUEST"', b)
        self.assertIn('hash_key     = "id"', b)
        self.assertRegex(b, r"point_in_time_recovery\s*\{\s*enabled\s*=\s*true")
        self.assertRegex(b, r"server_side_encryption\s*\{\s*enabled\s*=\s*true")


class EbsVolume(unittest.TestCase):
    def test_gp3_encrypted(self):
        block = re.search(
            r'resource "aws_ebs_volume" "data" \{.*?\n\}',
            read(SOLUTION, "main.tf"),
            re.DOTALL,
        )
        self.assertIsNotNone(block, "ebs volume block not found")
        self.assertRegex(block.group(0), r'type\s*=\s*"gp3"')
        self.assertRegex(block.group(0), r"encrypted\s*=\s*true")


class ComputeGating(unittest.TestCase):
    def setUp(self):
        self.main = read(SOLUTION, "main.tf")

    def test_instance_and_profile_gated_on_flag(self):
        for resource in (
            'resource "aws_instance" "app"',
            'resource "aws_iam_instance_profile" "instance"',
            'resource "aws_iam_role" "instance"',
        ):
            self.assertIn(resource, self.main, f"missing: {resource}")
        # Each gated resource uses the enable_compute count guard.
        self.assertGreaterEqual(
            len(re.findall(r"var\.enable_compute \? 1 : 0", self.main)),
            5,
            "expected ami/role/policy-doc/role-policy/profile/instance to be gated",
        )

    def test_instance_requires_imdsv2(self):
        self.assertRegex(self.main, r'http_tokens\s*=\s*"required"')

    def test_instance_policy_is_least_privilege(self):
        # No wildcard resources or actions on the instance read policy.
        doc = re.search(
            r'data "aws_iam_policy_document" "instance" \{.*?\n\}\n',
            self.main,
            re.DOTALL,
        )
        self.assertIsNotNone(doc)
        self.assertNotIn('resources = ["*"]', doc.group(0))
        self.assertNotIn('actions   = ["*"]', doc.group(0))
        self.assertNotIn('"s3:*"', doc.group(0))


class StarterIsGapped(unittest.TestCase):
    def test_starter_has_todos_and_no_data_security_blocks(self):
        main = read(STARTER, "main.tf")
        self.assertIn("TODO", main)
        # The data-bucket security resources must NOT already exist in starter.
        self.assertNotIn(
            'resource "aws_s3_bucket_versioning" "data"', main
        )
        self.assertNotIn(
            'resource "aws_s3_bucket_public_access_block" "data"', main
        )


class BrokenFixture(unittest.TestCase):
    def test_broken_makes_bucket_public(self):
        main = read(BROKEN, "main.tf")
        # The intentional defect: a public-read ACL and all-false access block.
        self.assertIn('acl    = "public-read"', main)
        self.assertIn("block_public_acls       = false", main)
        self.assertIn('Principal = "*"', main)


if __name__ == "__main__":
    unittest.main()
