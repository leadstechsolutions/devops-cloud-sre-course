# Module: terraform-aws-foundations

> **Status:** Validated — `terraform fmt -check`, `init -backend=false`, `validate`, and a
> **`checkov` IaC security scan** all pass here on Terraform v1.14.1 with `hashicorp/aws`
> (matched `~> 5.0` -> v5.100.0) and checkov v3.2.459. `./validate.sh` reports **10 passed,
> 0 failed** (exit 0); real output is captured below in [Validation](#validation). The static
> gates are **plan-free** ($0). This module ships **two validated artifacts**: the reusable
> **VPC root module** (Week 14 Class 02 / Week 15 networking) and a self-contained
> **secure-S3 example** under [`solution/examples/secure-s3/`](solution/examples/secure-s3/)
> that is the on-disk version of the **Week 14 Class 01** lecture's secure-S3 workflow
> (`checkov`: 46 passed, 0 failed, 3 documented skips). The VPC module has additionally been
> **applied to and destroyed from a real AWS account** (071146695791, us-east-1):
> `Apply complete! Resources: 19 added` (VPC + 4 subnets + IGW + 3 route tables, API-verified)
> then `Destroy complete! Resources: 19 destroyed`, confirmed clean — see
> [`LIVE-AWS-VALIDATION.txt`](LIVE-AWS-VALIDATION.txt). Total live cost **$0** (NAT disabled;
> ~90s lifetime). **Always run `terraform destroy` immediately after testing.**
> **Maps to:**
> - **Week 14 Class 01** (Terraform fundamentals + first AWS resource) -> [`solution/examples/secure-s3/`](solution/examples/secure-s3/) — the secure-by-default S3 bucket the lecture builds, hardened to a senior baseline.
> - **Week 14 Class 02 / Week 15** (Terraform + AWS networking) -> the VPC root module + `modules/vpc`.
>
> Concepts are first introduced in Weeks 4, 5, and 7 (cloud + networking fundamentals) and
> operated again in the Week 23/24 capstone, which reuses this VPC module. The secure-S3
> pattern is reinforced in Week 19 (DevSecOps).

## What you will build

This module contains **two related Terraform artifacts**, one per Week 14 class:

1. **Week 14 Class 01 — a secure S3 bucket** ([`examples/secure-s3/`](solution/examples/secure-s3/)).
   The on-disk, validated version of the Class 01 lecture demo: an `aws_s3_bucket` plus the
   *separate* security controls that AWS does **not** give you for free since provider v4 —
   `aws_s3_bucket_public_access_block` (block all four public flags),
   `aws_s3_bucket_server_side_encryption_configuration` (**SSE-KMS** with a customer-managed
   `aws_kms_key`, rotation on — the senior upgrade over the lecture's AES256),
   `aws_s3_bucket_versioning`, a bucket policy that **denies non-TLS and unencrypted uploads**,
   a lifecycle rule, server **access logging** into a separate hardened log bucket, and
   EventBridge notifications. It exposes a **`bucket_arn` output marked `sensitive`** and a
   `bucket_name` variable with **two validation blocks** (length + DNS shape). A `starter/`
   variant leaves every security control as a `TODO(student)` block.

2. **Week 14 Class 02 / Week 15 — a VPC network foundation** (described below).

A reusable Terraform **root module** that calls a local child module `modules/vpc` to stand
up an AWS network foundation: one `aws_vpc`, a public **and** a private subnet in each of
`az_count` Availability Zones (CIDRs carved with `cidrsubnet()` so they never overlap), an
internet gateway with a public route table and per-subnet associations, an **optional** NAT
gateway + Elastic IP gated behind `enable_nat_gateway` (off by default to stay free), a
**locked-down default security group** (all rules revoked, a CIS best practice), and
**VPC flow logs** shipped to an encrypted, retention-bounded CloudWatch log group via a
least-privilege IAM role (CIS best practice; the log group is free until traffic flows).
Everything is tagged through the provider's `default_tags` plus a per-resource `Name`. You
also wire up commented-out S3 remote state with **native S3 locking** (`use_lockfile`) and a
`terraform.tfvars.example`.

## Prerequisites

- `terraform >= 1.6` (validated here on v1.14.1) **or** OpenTofu `>= 1.6`.
- `python3 >= 3.10` (for the stdlib structural tests in `tests/`).
- Network access on first `terraform init` to download the AWS provider (`~> 5.0`).
- To actually **apply** (optional, not required for this lab): an AWS account and credentials
  (`aws configure` or env vars) with permission to create VPC resources, plus a budget alarm.
- Prior modules: none required. This is the networking foundation that later modules
  (`kubernetes-fundamentals` infra, capstone) build on.

## Architecture

See [`docs/architecture.mmd`](docs/architecture.mmd) (Mermaid). In words: an internet
gateway attaches to the VPC; the public route table sends `0.0.0.0/0` to the IGW and is
associated with every public subnet (which auto-assign public IPs). Private subnets get
their own route table with **no** default route unless `enable_nat_gateway = true`, in which
case a single NAT gateway (with an EIP, placed in the first public subnet) provides outbound
egress via a `0.0.0.0/0 -> NAT` route. The default SG is replaced with a no-rule, deny-all SG.

## Repository layout

```
starter/    # incomplete versions — do the labs here
  modules/vpc/main.tf            # VPC lab: 5 TODO(student) blocks
  examples/secure-s3/main.tf     # S3 lab: 6 TODO(student) security-control gaps
solution/   # complete, validated reference implementations
  versions.tf providers.tf variables.tf main.tf outputs.tf   # VPC root module
  terraform.tfvars.example  backend.tf.example  .gitignore
  modules/vpc/{main.tf,variables.tf,outputs.tf}              # VPC child module
  examples/secure-s3/            # Week 14 Class 01 secure-S3 example (self-contained root)
    versions.tf providers.tf variables.tf main.tf outputs.tf
    terraform.tfvars.example  .gitignore
broken/     # troubleshooting fixture: one reproducible defect that fails `terraform validate`
tests/      # stdlib-only structural tests (no terraform/AWS/network needed)
docs/architecture.mmd
validate.sh # runs every gate (10 total); exits non-zero on any failure
```

## Setup

```bash
cd labs/terraform-aws-foundations

# Work the lab in starter/ (it is intentionally incomplete and will fail validate
# until you fill the TODOs):
cd starter
terraform init -backend=false      # downloads the AWS provider, no backend, no creds
# ...edit modules/vpc/main.tf to remove the TODO(student) blocks...
terraform fmt -recursive
terraform validate

# Check yourself against the reference any time:
cd ../solution && terraform init -backend=false && terraform validate
```

You do **not** need AWS credentials for any gate in this lab — `init -backend=false` +
`validate` are offline after the provider is cached.

### Week 14 Class 01 — secure S3 example

The secure-S3 artifact is a **self-contained root config** (not the VPC module), so you run
Terraform directly inside its directory:

```bash
cd labs/terraform-aws-foundations

# Do the Class 01 lab in the starter (security controls are TODO):
cd starter/examples/secure-s3
terraform init -backend=false
# ...fill the 6 TODO(student) blocks in main.tf...
terraform fmt -recursive
terraform validate
checkov -d . --compact           # goal: 0 failed (starter fails by design until you finish)

# Reference implementation:
cd ../../../solution/examples/secure-s3
terraform init -backend=false && terraform validate
checkov -d . --compact           # 46 passed, 0 failed, 3 documented skips
```

## Lab tasks

### Lab A — Week 14 Class 01: secure the S3 bucket

Work in `starter/examples/secure-s3/main.tf`. The bucket and KMS key are provided; add the
six security controls left as `TODO(student)` blocks. After each, `terraform validate` should
stay green and `checkov -d .` should report fewer failures, reaching **0 failed** when done.

1. **Block public access.** Add `aws_s3_bucket_public_access_block.this` with all four flags
   (`block_public_acls`, `block_public_policy`, `ignore_public_acls`, `restrict_public_buckets`)
   set to `true`. **Done when** `checkov` no longer reports `CKV2_AWS_6`.
2. **Encrypt at rest with the CMK.** Add `aws_s3_bucket_server_side_encryption_configuration.this`
   using `sse_algorithm = "aws:kms"` and `kms_master_key_id = aws_kms_key.bucket.arn`, with
   `bucket_key_enabled = true`. **Done when** `CKV_AWS_145` passes.
3. **Enable versioning.** Add `aws_s3_bucket_versioning.this` with `status = "Enabled"`.
   **Done when** `CKV_AWS_21` passes.
4. **Add the deny-by-default bucket policy.** Add `aws_s3_bucket_policy.this` (built from an
   `aws_iam_policy_document`) that **denies** any request over plain HTTP
   (`aws:SecureTransport = false`) and any upload not encrypted with `aws:kms`. Add
   `depends_on = [aws_s3_bucket_public_access_block.this]`. **Done when** `CKV_AWS_53/54/55/56`
   and the TLS check pass.
5. **Abort stale multipart uploads.** Add `aws_s3_bucket_lifecycle_configuration.this` with
   `filter {}` and `abort_incomplete_multipart_upload { days_after_initiation = 7 }`.
   **Done when** `CKV_AWS_300` passes.
6. **Add access logging + notifications.** Create a second, equally-hardened log bucket, wire
   `aws_s3_bucket_logging.this` to it, and enable `aws_s3_bucket_notification` with
   `eventbridge = true` on both buckets. **Done when** `CKV_AWS_18` and `CKV2_AWS_62` pass and
   `checkov -d .` reports **0 failed**, matching `solution/examples/secure-s3/`.

> Acceptance for Lab A: `cd solution/examples/secure-s3 && terraform validate` prints
> `Success! The configuration is valid.` and `checkov -d . --compact` prints
> `Passed checks: 46, Failed checks: 0, Skipped checks: 3`.

### Lab B — Week 14 Class 02 / Week 15: the VPC module

1. **Carve the public subnets.** In `starter/modules/vpc/main.tf`, implement
   `resource "aws_subnet" "public"` with `count = local.az_count`, `cidr_block` from
   `cidrsubnet(var.vpc_cidr, local.newbits, count.index)`, the matching AZ,
   `map_public_ip_on_launch = true`, and `Name`/`Tier=public` tags.
   **Done when** `terraform validate` no longer reports `aws_subnet.public` undeclared.
2. **Carve the private subnets without overlap.** Implement
   `resource "aws_subnet" "private"`. Offset the netnum by `local.az_count`
   (`cidrsubnet(var.vpc_cidr, local.newbits, count.index + local.az_count)`) so private
   CIDRs never collide with public ones; no public IP on launch; `Tier=private`.
   **Done when** `validate` passes and `cidrsubnet` produces e.g. `10.0.0.0/24`/`10.0.1.0/24`
   (public) and `10.0.2.0/24`/`10.0.3.0/24` (private) for a 2-AZ `/16`.
3. **Associate public subnets with the public route table.** Implement
   `resource "aws_route_table_association" "public"` (`count = local.az_count`).
   **Done when** `validate` passes and there is one association per public subnet.
4. **Gate the NAT gateway behind the flag.** Implement `aws_eip.nat`,
   `aws_nat_gateway.this`, and `aws_route.private_nat`, each with
   `count = var.enable_nat_gateway ? 1 : 0`, `depends_on = [aws_internet_gateway.this]` on
   the EIP/NAT, and the private default route pointing at `aws_nat_gateway.this[0].id`.
   **Done when** `terraform validate` passes, and `./validate.sh` (run from the module root,
   but pointed at your starter) is green. **Done overall** when the starter validates
   identically to the solution.

> Acceptance for the whole lab: `cd solution && terraform validate` prints
> `Success! The configuration is valid.` and `../validate.sh` reports `7 passed, 0 failed`.

## Validation

`./validate.sh` runs all gates from the module root and exits non-zero on any failure.
The exact commands (run from `solution/` unless noted) and their **expected output**:

```bash
terraform fmt -check -recursive solution
# (no output, exit 0)

terraform -chdir=solution init -backend=false
# "Terraform has been successfully initialized!"

terraform -chdir=solution validate
# Success! The configuration is valid.

terraform -chdir=solution/modules/vpc init -backend=false
terraform -chdir=solution/modules/vpc validate
# Success! The configuration is valid.

# Week 14 Class 01 secure-S3 example (self-contained root):
terraform -chdir=solution/examples/secure-s3 init -backend=false
terraform -chdir=solution/examples/secure-s3 validate
# Success! The configuration is valid.

python3 -m unittest discover -s tests
# Ran 18 tests ... OK

# Negative gate — the broken fixture MUST fail:
terraform -chdir=broken init -backend=false && terraform -chdir=broken validate
# Error: Missing resource instance key  (exit 1 — this is the expected "PASS" for the gate)

# IaC security scan (checkov) — runs only where checkov is installed:
checkov -d solution --compact --quiet
checkov -d solution/modules/vpc --compact --quiet
checkov -d solution/examples/secure-s3 --compact --quiet --framework terraform
# Passed checks: 48, Failed checks: 0, Skipped checks: 1   (root)
# Passed checks: 45, Failed checks: 0, Skipped checks: 1   (vpc module)
# Passed checks: 46, Failed checks: 0, Skipped checks: 3   (secure-s3 example)

# Negative gate — the STARTER secure-s3 MUST fail checkov (controls are TODO):
checkov -d starter/examples/secure-s3 --compact --quiet --framework terraform
# Failed checks: 7   (exit 1 — this is the expected "PASS" for the gate)
```

Captured real run of `./validate.sh` in this environment:

```
== validating terraform-aws-foundations ==
  [PASS] terraform fmt -check -recursive (solution)
  [PASS] terraform validate (solution root)
  [PASS] terraform validate (solution/modules/vpc)
  [PASS] terraform validate (solution/examples/secure-s3)
  [PASS] python unittest (tests/)
  [PASS] broken/ fixture fails terraform validate (expected)
  [PASS] checkov (solution)
  [PASS] checkov (solution/modules/vpc)
  [PASS] checkov (solution/examples/secure-s3)
  [PASS] starter/examples/secure-s3 checkov fails (controls TODO, expected)
== 10 passed, 0 failed ==
```

And the headline gate, run directly:

```
$ terraform -chdir=solution validate
Success! The configuration is valid.
```

### IaC security scan (checkov) — evidence

This gate was previously **DEFERRED** (the tool was not installed). It is now run for real
with checkov v3.2.459. **Before:** the scan reported **2 failed** checks on the root
(**1 failed** on the vpc module). **After** the fixes below, both scans are **0 failed**:

```
$ checkov -d solution --compact --quiet
terraform scan results:
Passed checks: 48, Failed checks: 0, Skipped checks: 1

$ checkov -d solution/modules/vpc --compact --quiet
terraform scan results:
Passed checks: 45, Failed checks: 0, Skipped checks: 1
```

**Finding 1 — `CKV2_AWS_11` "Ensure VPC flow logging is enabled in all VPCs" (FAILED -> FIXED).**
A genuine security gap. Fixed by adding **VPC flow logs** in `modules/vpc/main.tf`:
`aws_flow_log` (traffic_type `ALL`) -> an encrypted `aws_cloudwatch_log_group`
(customer-managed `aws_kms_key` with rotation, 365-day retention) written by a
least-privilege `aws_iam_role` scoped to just that log group. The check now passes:

```
$ checkov -d solution --compact | grep -A1 CKV2_AWS_11
Check: CKV2_AWS_11: "Ensure VPC flow logging is enabled in all VPCs"
	PASSED for resource: module.vpc.aws_vpc.this
```

**Finding 2 — `CKV_AWS_130` "Ensure VPC subnets do not assign public IP by default"
(FAILED -> documented narrow skip).** This is the one **intentional teaching choice**: a
*public* subnet auto-assigning public IPs (`map_public_ip_on_launch = true`) is the defining
behaviour of the public-vs-private split this lab teaches. The private subnets correctly
leave it off. A narrow, line-scoped suppression is recorded **in the source** rather than
weakening it:

```
# in solution/modules/vpc/main.tf, on aws_subnet.public:
# checkov:skip=CKV_AWS_130: This is intentionally a PUBLIC subnet — auto-
# assigning a public IP is its defining behaviour and a core teaching goal ...

$ checkov -d solution/modules/vpc --compact | grep -A2 SKIPPED
Check: CKV_AWS_130: "Ensure VPC subnets do not assign public IP by default"
	SKIPPED for resource: aws_subnet.public
	Suppress comment:  This is intentionally a PUBLIC subnet ...
```

`terraform validate` remains green after the fixes (`Success! The configuration is valid.`
on both the root and the vpc module).

### secure-S3 example — checkov evidence (Week 14 Class 01)

`checkov -d solution/examples/secure-s3 --compact --quiet --framework terraform` reports
**Passed: 46, Failed: 0, Skipped: 3**. The three skips are narrow, documented teaching-scope
choices recorded **in the source** (same discipline as the VPC `CKV_AWS_130` skip):

- **`CKV_AWS_144` (cross-region replication)** on **both** buckets — CRR needs a second-region
  bucket plus an IAM replication role; it is a multi-region topic taught later. The DR control
  taught *here* is **versioning** (enabled), which protects against accidental delete/overwrite.
- **`CKV_AWS_18` (access logging)** on the **log bucket only** — the log bucket logging its own
  access into itself is circular; the *primary* bucket's access **is** logged into it.

Every genuine S3 control is implemented, not suppressed: public-access-block (all four flags),
SSE-KMS with a customer-managed key, versioning, a deny-non-TLS / deny-unencrypted-upload
bucket policy, a multipart-abort lifecycle rule, server access logging, and EventBridge
notifications. The KMS key policy is written inline with `jsonencode` (not an
`aws_iam_policy_document` data source) so the canonical account-root `kms:*` statement is not
mis-flagged as an over-broad IAM policy. The **starter** intentionally fails (`Failed: 7`)
until the student completes the six TODOs — that negative result is itself a validate.sh gate.

## Expected results

- `terraform validate` on `solution/`, `solution/modules/vpc/`, and
  `solution/examples/secure-s3/`: `Success! The configuration is valid.`
- `./validate.sh`: `10 passed, 0 failed` (exit 0).
- **secure-S3 example** — a hypothetical `terraform apply` (not run here; needs AWS creds)
  would create **~14 resources**: 2 buckets (primary + logs) each with public-access-block,
  SSE-KMS config, versioning, lifecycle, and EventBridge notification; the KMS key + alias;
  the bucket policy; and the access-logging link. `terraform output bucket_arn` is redacted as
  `<sensitive>` (read it with `terraform output -raw bucket_arn`).
- A hypothetical `terraform plan` (not run here; needs AWS creds) with defaults
  (`az_count=2`, `enable_nat_gateway=false`) would create: 1 VPC, 4 subnets (2 public,
  2 private), 1 IGW, 2 route tables, 1 public route, 2 public + 2 private associations,
  1 default SG = 13, **plus** the flow-log stack (1 KMS key, 1 CloudWatch log group,
  1 IAM role, 1 IAM role policy, 1 flow log) = **18 resources**, **0** NAT/EIP. With
  `enable_nat_gateway=true`: **+3** (EIP, NAT gateway, private route) = **21 resources**.

## Troubleshooting

Real, reproducible fixture: [`broken/`](broken/). It is the solution's NAT logic with one
classic defect.

| Symptom | Cause | Fix |
|---------|-------|-----|
| `terraform validate` on `broken/` errors: **"Missing resource instance key … Because `aws_nat_gateway.this` has \"count\" set, its attributes must be accessed on specific instances."** | `aws_route.private_nat` references `aws_nat_gateway.this.id`, but that resource has `count`, so it is a list, not a single object. | Index it: `aws_nat_gateway.this[0].id`, and gate the route itself with `count = var.enable_nat_gateway ? 1 : 0` so it only exists when the NAT does. |

Reproduce it:

```bash
cd broken && terraform init -backend=false && terraform validate   # exits 1 with the error above
```

Other common failures while doing the lab:

- **Overlapping subnet CIDRs** — if you forget the `+ local.az_count` offset in task 2,
  `validate` still passes but `apply` fails with `InvalidSubnet.Conflict`. The structural
  test `test_private_subnet_offset_avoids_overlap` guards against this in the solution.
- **`fmt` gate fails** — run `terraform fmt -recursive` to auto-format, then re-check.

**secure-S3 (Lab A) common failures:**

- **`bucket_name` validation error** (e.g. *"bucket_name must be a valid lowercase S3 name"*)
  — S3 names are 3–63 chars, lowercase, DNS-style, and must start/end alphanumeric. The
  `bucket_name` variable enforces this *at plan time* so you fail fast instead of at
  `apply` with `InvalidBucketName`. Fix the name in your `terraform.tfvars`.
- **`BucketAlreadyExists` on apply** — bucket names are *globally* unique across all of AWS.
  Add your initials and a date suffix.
- **`terraform output bucket_arn` prints `<sensitive>`** — that is correct: the output is
  marked `sensitive`. Read the real value with `terraform output -raw bucket_arn`.
- **checkov still reports failures on the starter** — that is expected until you finish the
  six TODOs. Compare your `main.tf` to `solution/examples/secure-s3/main.tf`.

## Cleanup

These gates create only local working files — **no cloud resources**. Idempotent cleanup:

```bash
# from labs/terraform-aws-foundations
find . -name '.terraform' -type d -prune -exec rm -rf {} +
find . -name '.terraform.lock.hcl' -delete
find . -name '*.tfstate*' -delete
```

If you went further and ran `terraform apply` on your own account, tear it down with:

```bash
# VPC module:
cd solution
terraform destroy            # removes the VPC and everything in it
terraform state list         # confirm: should print nothing after destroy

# secure-S3 example:
cd solution/examples/secure-s3
terraform destroy            # set force_destroy=true in tfvars so a non-empty
                             # versioned bucket does not block the destroy
terraform state list         # confirm: empty after destroy
```

Confirm in the AWS console (VPC dashboard) that no VPC, NAT gateway, or EIP remains — an
**unattached EIP still bills**, so verify the EIP is released after `destroy`. For the S3
example, confirm both the primary and `-logs` buckets are gone, and that the KMS key is
scheduled for deletion (it lingers for `deletion_window_in_days = 7`, then is removed).

## Security considerations

- **Never commit** `terraform.tfvars`, `*.auto.tfvars`, `backend.tf`, `.terraform/`, or any
  `*.tfstate` — state can contain sensitive values. The provided `.gitignore` enforces this;
  only the `*.example` files are committed.
- **Least privilege:** the default security group is replaced with a deny-all
  (`aws_default_security_group` with no rules) so nothing inherits the permissive AWS
  default. Real workloads get their own narrowly-scoped SGs, not the default.
- **VPC flow logs** (`aws_flow_log` -> encrypted CloudWatch log group) capture all traffic
  metadata for audit/forensics — a CIS best practice and the checkov `CKV2_AWS_11` gate. The
  log group is encrypted with a customer-managed KMS key (rotation on) and has a 365-day
  retention; the IAM role that writes the logs is scoped to just that one log group.
- **IaC is statically scanned** with `checkov` (in `validate.sh`). On the VPC module the only
  suppressed check is the public subnet's `map_public_ip_on_launch` (`CKV_AWS_130`), which is
  the intended, documented behaviour of a *public* subnet — see the inline `checkov:skip`.
- **secure-S3 example (Week 14 Class 01):** demonstrates the secure-by-default S3 baseline a
  hiring manager looks for. A bare `aws_s3_bucket` is unencrypted, unversioned, and only
  implicitly non-public since provider v4, so the example adds: **block-all-public-access**,
  **SSE-KMS** with a customer-managed, rotation-enabled key (auditable in CloudTrail), a
  **bucket policy that denies non-TLS requests and any non-KMS upload**, **versioning**, and
  **server access logging** into a second hardened bucket. The `bucket_arn` and `kms_key_arn`
  **outputs are marked `sensitive`** so they are not echoed into CI logs. The only suppressed
  checks are `CKV_AWS_144` (cross-region replication — multi-region scope, taught later) and
  `CKV_AWS_18` on the log bucket (logging itself is circular) — both documented inline.
- **Remote state** (`backend.tf.example`) uses an **encrypted** S3 bucket with **native S3
  state locking** (`use_lockfile = true`, Terraform >= 1.10) — the old separate DynamoDB lock
  table is **legacy and no longer needed**. In production, also enable bucket versioning,
  block public access, and a KMS key. State is sensitive — restrict bucket IAM to the CI role
  and operators only.
- No secrets are hard-coded; region and tags come from variables. Input validation on
  `bucket_name` (length + DNS shape) rejects bad values at plan time, not at apply.

## Cost considerations

| Resource | Cost |
|----------|------|
| VPC, subnets, route tables, internet gateway, default SG | **Free** |
| KMS key for flow logs | **$1/mo** per CMK (only billed once *applied*; $0 to validate) |
| VPC flow logs -> CloudWatch log group | **Free to create**; CloudWatch charges for log ingestion/storage only once real traffic flows |
| **NAT gateway** (`enable_nat_gateway = true`) | **~$0.045/hr ≈ $32/mo** + **~$0.045/GB** data processed |
| Elastic IP attached to a running NAT | free while attached; **billed if left unattached** |
| **secure-S3 example:** S3 buckets (primary + logs) | empty buckets are **free**; you pay only for stored objects (~$0.023/GB-mo) and requests |
| **secure-S3 example:** KMS key for SSE-KMS | **$1/mo** per CMK once applied (`bucket_key_enabled` cuts per-request KMS cost); $0 to validate |

**Default is `enable_nat_gateway = false`, and all validation gates here are plan/validate
only — they never call `apply` — so validating this lab is $0.** If you actually `apply`, the
only standing charge with the defaults is the flow-log KMS key (~$1/mo); the NAT gateway
(~$32/mo) stays off unless you flip `enable_nat_gateway`. `destroy` promptly to drop even the
KMS charge.

### Remote state (one-time, optional, costs pennies)

```bash
aws s3api create-bucket --bucket tf-aws-foundations-tfstate-CHANGE-ME --region us-east-1
aws s3api put-bucket-versioning --bucket tf-aws-foundations-tfstate-CHANGE-ME \
  --versioning-configuration Status=Enabled
# Native S3 locking (`use_lockfile = true`) needs NO DynamoDB table on Terraform >= 1.10.
# (Legacy: pre-1.10 used `dynamodb_table` + a LockID table — no longer required.)
# then: cp backend.tf.example backend.tf, uncomment, and run `terraform init`
```

## Instructor answer key

The complete references are in [`solution/`](solution/). Grade the student's `starter/` by
running `terraform validate` + `checkov` on it and diffing against the solution.

### Lab A — secure S3 (Week 14 Class 01)

Reference: [`solution/examples/secure-s3/`](solution/examples/secure-s3/). Grade by running
`checkov -d starter/examples/secure-s3 --compact` on the student's work — a finished lab is
**0 failed**. Non-obvious grading points:

1. **All four public-access-block flags must be `true`.** A student who sets only
   `block_public_acls` leaves the bucket reachable via policy — `restrict_public_buckets` and
   `block_public_policy` matter most. Half-blocking is a common, dangerous mistake.
2. **Encryption must reference the CMK**, not just `AES256`. `kms_master_key_id =
   aws_kms_key.bucket.arn` with `sse_algorithm = "aws:kms"`. A student who leaves it on SSE-S3
   (`AES256`) is *acceptable* (the lecture starts there) but does not earn the "auditable key"
   point; the deliverable target is SSE-KMS.
3. **The `bucket_arn` output must be marked `sensitive`.** This is an explicit learning goal —
   missing `sensitive = true` means the ARN leaks into CI logs.
4. **`bucket_name` must have validation.** Both the length (3–63) and the DNS-shape regex.
   A student who removes the validation to "make it work" has defeated the fail-fast point.
5. **The deny-by-default bucket policy** must deny *both* non-TLS transport and non-KMS
   uploads, and depend on the public-access-block. Denying only one is partial credit.

Common wrong answers: leaving the controls as a single `aws_s3_bucket` with inline (pre-v4)
arguments that the v5 provider ignores; forgetting `bucket_key_enabled` (works, but costs more
per request); committing `terraform.tfvars`.

### Lab B — VPC module (Week 14 Class 02 / Week 15)

Reference: [`solution/`](solution/) + `solution/modules/vpc/`. Diff `modules/vpc/main.tf`
against the solution. Non-obvious grading points:

1. **Subnet CIDRs must not overlap.** The whole point of `count.index + local.az_count` in
   the private subnet. A student who writes `cidrsubnet(..., count.index)` for *both* will
   pass `validate` but their infra is broken — dock for it. (`tests/` checks the solution
   has the offset.)
2. **NAT, EIP, and the private route must all be `count`-gated** on `enable_nat_gateway`.
   Gating only the NAT but not the route (or vice-versa) leaves a dangling reference and
   fails `validate` — this is exactly the `broken/` fixture. Indexing must use `[0]`.
3. **`aws_default_security_group` with no `ingress`/`egress` blocks = revoke-all.** A student
   who adds an `egress { ... 0.0.0.0/0 }` "to be safe" has defeated the lockdown.
4. **Tags** must flow from provider `default_tags` (Project/Environment/ManagedBy) **plus**
   a per-resource `Name`; both are required.

Common wrong answers: hard-coding two AZs instead of using `count`/`slice`; using a `cidrsubnet`
`newbits` that doesn't fit `az_count*2` subnets; referencing a counted resource without `[0]`;
committing `terraform.tfvars` or state.

### Answer keys for the other artifacts

- **Troubleshooting exercise:** fix `broken/main.tf` line ~74 `aws_nat_gateway.this.id`
  -> `aws_nat_gateway.this[0].id` and add `count = var.enable_nat_gateway ? 1 : 0` to the
  route. After the fix, `terraform validate` in `broken/` prints
  `Success! The configuration is valid.`
- **Structural tests:** `python3 -m unittest discover -s tests` -> `Ran 18 tests … OK`
  (includes the `SecureS3Example` class asserting the controls, the sensitive output, and
  that the starter leaves the controls as TODO).
