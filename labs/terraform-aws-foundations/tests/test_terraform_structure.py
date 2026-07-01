"""Structural tests for the terraform-aws-foundations solution.

These are stdlib-only checks (no terraform binary, no AWS, no network) that assert
the reference solution keeps the invariants the lab teaches. They run anywhere
`python3 -m unittest` runs and complement the terraform fmt/init/validate gates.

Run from the module root:
    python3 -m unittest discover -s tests
"""

import os
import re
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
SOLUTION = os.path.normpath(os.path.join(HERE, "..", "solution"))
VPC_MODULE = os.path.join(SOLUTION, "modules", "vpc")
SECURE_S3 = os.path.join(SOLUTION, "examples", "secure-s3")
STARTER_SECURE_S3 = os.path.normpath(
    os.path.join(HERE, "..", "starter", "examples", "secure-s3")
)


def read(*parts):
    with open(os.path.join(*parts), encoding="utf-8") as fh:
        return fh.read()


class SolutionLayout(unittest.TestCase):
    def test_required_root_files_exist(self):
        for name in (
            "versions.tf",
            "providers.tf",
            "variables.tf",
            "main.tf",
            "outputs.tf",
            "terraform.tfvars.example",
            "backend.tf.example",
        ):
            self.assertTrue(
                os.path.isfile(os.path.join(SOLUTION, name)),
                f"missing root file: {name}",
            )

    def test_required_module_files_exist(self):
        for name in ("main.tf", "variables.tf", "outputs.tf"):
            self.assertTrue(
                os.path.isfile(os.path.join(VPC_MODULE, name)),
                f"missing vpc module file: {name}",
            )


class VersionPins(unittest.TestCase):
    def test_terraform_required_version(self):
        versions = read(SOLUTION, "versions.tf")
        self.assertRegex(versions, r'required_version\s*=\s*">=\s*1\.6"')

    def test_aws_provider_pinned_v5(self):
        versions = read(SOLUTION, "versions.tf")
        self.assertIn("hashicorp/aws", versions)
        self.assertRegex(versions, r'version\s*=\s*"~>\s*5\.0"')


class ProviderTagging(unittest.TestCase):
    def test_provider_has_default_tags(self):
        providers = read(SOLUTION, "providers.tf")
        self.assertIn("default_tags", providers)
        self.assertIn("var.region", providers)


class VpcModuleContent(unittest.TestCase):
    def setUp(self):
        self.main = read(VPC_MODULE, "main.tf")

    def test_uses_cidrsubnet_for_subnets(self):
        self.assertIn("cidrsubnet(", self.main)

    def test_private_subnet_offset_avoids_overlap(self):
        # private netnum must be offset by az_count so it cannot overlap public.
        self.assertIn("count.index + local.az_count", self.main)

    def test_creates_core_resources(self):
        for resource in (
            'resource "aws_vpc" "this"',
            'resource "aws_subnet" "public"',
            'resource "aws_subnet" "private"',
            'resource "aws_internet_gateway" "this"',
            'resource "aws_route_table" "public"',
            'resource "aws_route_table_association" "public"',
            'resource "aws_default_security_group" "this"',
        ):
            self.assertIn(resource, self.main, f"missing: {resource}")

    def test_nat_is_gated_on_flag(self):
        # NAT gateway, EIP, and the private default route must all be count-gated.
        for resource in (
            'resource "aws_eip" "nat"',
            'resource "aws_nat_gateway" "this"',
            'resource "aws_route" "private_nat"',
        ):
            self.assertIn(resource, self.main, f"missing: {resource}")
        # each gated block uses the ternary count guard
        self.assertGreaterEqual(
            len(re.findall(r"var\.enable_nat_gateway \? 1 : 0", self.main)),
            3,
            "expected eip, nat gateway, and private route to be count-gated",
        )

    def test_default_sg_has_no_open_rules(self):
        # The locked-down default SG block must not declare ingress/egress rules.
        block = re.search(
            r'resource "aws_default_security_group" "this" \{.*?\n\}',
            self.main,
            re.DOTALL,
        )
        self.assertIsNotNone(block, "default SG block not found")
        # No ingress/egress RULE blocks (the comment may mention the words).
        self.assertNotRegex(block.group(0), r"\bingress\s*\{")
        self.assertNotRegex(block.group(0), r"\begress\s*\{")


class SecureS3Example(unittest.TestCase):
    """The Week 14 secure-S3 lecture example must keep every security control
    and the sensitive output the lecture teaches."""

    def setUp(self):
        self.main = read(SECURE_S3, "main.tf")
        self.outputs = read(SECURE_S3, "outputs.tf")
        self.variables = read(SECURE_S3, "variables.tf")

    def test_example_files_exist(self):
        for name in (
            "versions.tf",
            "providers.tf",
            "variables.tf",
            "main.tf",
            "outputs.tf",
            "terraform.tfvars.example",
        ):
            self.assertTrue(
                os.path.isfile(os.path.join(SECURE_S3, name)),
                f"missing secure-s3 example file: {name}",
            )

    def test_has_bucket_and_all_security_controls(self):
        for resource in (
            'resource "aws_s3_bucket" "this"',
            'resource "aws_s3_bucket_public_access_block" "this"',
            'resource "aws_s3_bucket_server_side_encryption_configuration" "this"',
            'resource "aws_s3_bucket_versioning" "this"',
        ):
            self.assertIn(resource, self.main, f"missing: {resource}")

    def test_public_access_fully_blocked(self):
        for flag in (
            "block_public_acls       = true",
            "block_public_policy     = true",
            "ignore_public_acls      = true",
            "restrict_public_buckets = true",
        ):
            self.assertIn(flag, self.main, f"missing PAB flag: {flag}")

    def test_encryption_uses_sse_kms_with_cmk(self):
        # The example upgrades the lecture's AES256 to SSE-KMS with a CMK.
        self.assertIn('resource "aws_kms_key" "bucket"', self.main)
        self.assertIn('sse_algorithm     = "aws:kms"', self.main)
        self.assertIn("kms_master_key_id = aws_kms_key.bucket.arn", self.main)

    def test_bucket_arn_output_is_sensitive(self):
        block = re.search(
            r'output "bucket_arn" \{.*?\n\}', self.outputs, re.DOTALL
        )
        self.assertIsNotNone(block, "bucket_arn output not found")
        self.assertIn("sensitive   = true", block.group(0))

    def test_bucket_name_variable_has_validation(self):
        block = re.search(
            r'variable "bucket_name" \{.*?\n\}\s*\n', self.variables, re.DOTALL
        )
        self.assertIsNotNone(block, "bucket_name variable not found")
        self.assertIn("validation {", block.group(0))

    def test_starter_leaves_controls_todo(self):
        # The starter must NOT already contain the controls as LIVE resources;
        # they should be commented TODO blocks the student fills in. Strip
        # comment lines before checking so the TODO hints (which mention the
        # resource names) do not count as live declarations.
        starter = read(STARTER_SECURE_S3, "main.tf")
        self.assertIn("TODO(student)", starter)
        live = "\n".join(
            line for line in starter.splitlines() if not line.lstrip().startswith("#")
        )
        self.assertNotIn(
            'resource "aws_s3_bucket_public_access_block" "this"', live
        )
        self.assertNotIn(
            'resource "aws_s3_bucket_versioning" "this"', live
        )
        self.assertNotIn(
            'resource "aws_s3_bucket_server_side_encryption_configuration" "this"',
            live,
        )


class BrokenFixture(unittest.TestCase):
    def test_broken_main_has_unindexed_count_reference(self):
        broken = read(os.path.join(SOLUTION, "..", "broken"), "main.tf")
        # The intentional defect: referencing a counted resource without an index.
        self.assertIn("aws_nat_gateway.this.id", broken)


if __name__ == "__main__":
    unittest.main()
