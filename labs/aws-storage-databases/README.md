# Module: aws-storage-databases

> **Status:** Validated — every gate in `validate.sh` runs and passes here
> (`terraform fmt -check`, `init -backend=false`, `validate`, `checkov`, and the
> stdlib unit tests). No `terraform apply` is run in this environment (no AWS
> creds); the orchestrator runs the live apply -> destroy separately. See
> [Validation](#validation) for captured output.
> **Maps to:** Week 7 (AWS storage & databases). Builds on the Terraform basics
> from `labs/terraform-aws-foundations` (Week 6) and is reused by later weeks
> that need a secured bucket + table to read from.

## What you will build
A small, security-hardened AWS storage stack defined in Terraform: an **S3
bucket** with versioning, AES256 server-side encryption, a full public-access
block, a noncurrent-version lifecycle rule, server access logging into a
dedicated logs bucket, and a least-privilege bucket policy (deny non-TLS, deny
unencrypted uploads); a **DynamoDB table** in on-demand (`PAY_PER_REQUEST`) mode
with point-in-time recovery and SSE; and an **encrypted gp3 EBS volume**. An
**EC2 `t3.micro` + instance profile** that reads (read-only, least privilege)
from the bucket and table is included but **gated behind `enable_compute`
(default `false`)** so the default `apply` provisions only the near-free storage
primitives. The whole thing passes `checkov` with zero unsuppressed findings.

## Prerequisites
- `terraform >= 1.6` (validated on 1.14.1).
- `checkov >= 3` for the security gate (validated on 3.2.459).
- `python3 >= 3.8` for the structural unit tests (stdlib only — no pip installs).
- For the **live** apply/destroy (done by the orchestrator, not in this lab):
  an AWS account with credentials and, ideally, a budget alarm.
- Recommended prior module: `labs/terraform-aws-foundations` (provider pinning,
  `default_tags`, `fmt/init/validate` workflow).

## Architecture
See [`docs/architecture.mmd`](docs/architecture.mmd) (Mermaid).

```
            +--------------------- always created (~$0) ---------------------+
            |  aws_s3_bucket.data        aws_dynamodb_table.app              |
            |   - versioning              - PAY_PER_REQUEST                  |
            |   - AES256 SSE              - point-in-time recovery           |
            |   - public access BLOCKED   - SSE on                          |
            |   - lifecycle (expire        aws_ebs_volume.data              |
            |     noncurrent)              - gp3, 8 GiB, encrypted          |
            |   - least-priv policy                                         |
            |   - access logging --> aws_s3_bucket.logs (own lifecycle)     |
            +----------------------------------------------------------------+

            +------- gated: enable_compute = false by default --------------+
            |  aws_iam_role.instance + instance profile (least-priv read)   |
            |        |  reads S3 (Get/List) + DynamoDB (Get/Query)          |
            |  aws_instance.app  (t3.micro, IMDSv2 required, encrypted root)|
            +----------------------------------------------------------------+
```

The data bucket and table are the durable storage; the logs bucket receives
server access logs; the compute tier (off by default) demonstrates how a
workload assumes a role to read storage without long-lived keys.

## Repository layout
```
starter/    # intentionally incomplete — the S3 security blocks are TODO'd
solution/   # reference implementation — complete and checkov-clean
broken/     # a public, unencrypted bucket that trips checkov (troubleshooting)
tests/      # stdlib unittest structural checks (no network)
docs/       # architecture.mmd
validate.sh # runs this module's validation gates
```

## Setup
From a fresh clone, no cloud access needed for the gates:
```bash
cd labs/aws-storage-databases
terraform -chdir=solution init -backend=false   # downloads the aws provider
./validate.sh                                    # runs every gate (expects exit 0)
```
To work the lab, edit `starter/` and check yourself against `solution/`.
To run it live (costs apply — see [Cost considerations](#cost-considerations)):
```bash
cd solution
cp terraform.tfvars.example terraform.tfvars   # edit project/region as needed
terraform init
terraform apply        # enable_compute=false by default -> storage only
# ... inspect ...
terraform destroy      # ALWAYS destroy when done
```

## Lab tasks
Work in `starter/`. The S3 **data** bucket is created for you but unsecured; the
logs bucket, DynamoDB table, EBS volume, and gated compute are complete and are
a worked reference. Each TODO in `starter/main.tf` has a "done when" below.

1. **Versioning** — add `aws_s3_bucket_versioning.data` (`status = "Enabled"`).
   _Done when:_ `terraform validate` passes and `checkov` no longer reports
   `CKV_AWS_21` for `aws_s3_bucket.data`.
2. **Encryption (AES256)** — add
   `aws_s3_bucket_server_side_encryption_configuration.data` with
   `sse_algorithm = "AES256"`.
   _Done when:_ checkov no longer reports the S3 encryption findings.
3. **Block public access** — add `aws_s3_bucket_public_access_block.data` with
   all four flags `true`.
   _Done when:_ `CKV2_AWS_6` / `CKV_AWS_53..56` no longer fail for the bucket.
4. **Lifecycle** — add `aws_s3_bucket_lifecycle_configuration.data` expiring
   noncurrent versions after `var.noncurrent_version_expiration_days` and
   aborting incomplete multipart uploads after 7 days; `depends_on` versioning.
   _Done when:_ `CKV2_AWS_61` passes for the bucket.
5. **Access logging** — add `aws_s3_bucket_logging.data` targeting
   `aws_s3_bucket.logs` with prefix `s3-access-logs/`.
   _Done when:_ `CKV_AWS_18` passes for the bucket.
6. **Least-privilege bucket policy** — add a `data
   "aws_iam_policy_document" "bucket"` that **denies** non-TLS requests
   (`aws:SecureTransport = false`) and **denies** `PutObject` without
   `x-amz-server-side-encryption = AES256`; attach it with
   `aws_s3_bucket_policy.data` (`depends_on` the public access block).
   _Done when:_ `./validate.sh` exits 0 and `checkov -d starter` is clean.

**Acceptance for the whole lab:** `terraform fmt -check -recursive starter`,
`terraform -chdir=starter validate`, and `checkov -d starter --compact` all pass.

## Validation
`./validate.sh` runs the gates below (no `apply`, so it costs $0). Expected
output (captured in this environment):

```
== validating aws-storage-databases ==
  [PASS] terraform fmt -check -recursive (solution)
  [PASS] terraform fmt -check -recursive (starter)
  [PASS] terraform fmt -check -recursive (broken)
  [PASS] terraform validate (solution)
  [PASS] terraform validate (starter)
  [PASS] terraform validate (broken — syntax is valid by design)
  [PASS] python unittest (tests/)
  [PASS] checkov (solution — clean)
  [PASS] checkov (broken fixture fails — expected, public bucket)
== 9 passed, 0 failed ==
```

The `checkov` solution scan reports **44+ passed, 0 failed, 9 skipped** — every
skip carries a narrow, documented `checkov:skip=` reason in `solution/main.tf`
(see [Security considerations](#security-considerations)). Individual gates:

```bash
terraform -chdir=solution init -backend=false && terraform -chdir=solution validate
checkov -d solution --compact --quiet      # exit 0
python3 -m unittest discover -s tests      # 18 tests OK
```

## Expected results
- `terraform validate` on `solution/`, `starter/`, and `broken/`: **Success!**.
- `checkov -d solution`: **`Passed checks: 46, Failed checks: 0, Skipped checks: 9`**.
- `checkov -d broken`: **`Failed checks: 15`** (public access block disabled,
  public-read ACL, public `s3:GetObject` policy, no encryption/logging/lifecycle)
  — this is the *expected* failing state for the troubleshooting exercise.
- `python3 -m unittest discover -s tests`: **`Ran 18 tests ... OK`**.
- A live `terraform apply` (orchestrator) with `enable_compute=false` creates
  ~13 resources (2 buckets + their configs, 1 table, 1 volume) and **no EC2**.

## Troubleshooting
Reproducible broken state lives in [`broken/`](broken/). It is a bucket that is
made **world-readable**:

| Step | Command | Symptom |
|------|---------|---------|
| 1 | `terraform -chdir=broken init -backend=false && terraform -chdir=broken validate` | **Success!** — the config is syntactically valid, so `validate` alone does NOT catch the problem. |
| 2 | `checkov -d broken --compact` | `Failed checks: 15`, including `CKV_AWS_53/54/55/56` (public access block all `false`), `CKV2_AWS_65` (ACLs enabled), `CKV2_AWS_6` (no effective public access block). |

- **Symptom:** the bucket allows anonymous `s3:GetObject` and a `public-read` ACL.
- **Cause:** `aws_s3_bucket_public_access_block.public` sets all four flags to
  `false`, an `aws_s3_bucket_acl` grants `public-read`, and the bucket policy
  allows `s3:GetObject` to `Principal = "*"`.
- **Fix:** mirror `solution/main.tf` — set all four public-access-block flags to
  `true`, delete the public ACL and the public policy statement, and add the
  encryption/versioning/logging/lifecycle blocks. Re-run `checkov -d broken` and
  watch the failures drop to zero.

Other common errors:
- `Error: creating S3 Bucket ... BucketAlreadyExists` on live apply — the bucket
  name is global. The solution suffixes the name with account id + region; if you
  still collide, change `var.project`.
- `validate` complains about a counted resource attribute (`...app[0]`) — gated
  resources are lists; index them when `enable_compute` is involved.

## Cleanup
Idempotent teardown of anything created live:
```bash
cd solution
terraform destroy            # removes buckets (force_destroy), table, volume,
                             # and EC2/role/profile if enable_compute was true
```
Confirm nothing is left:
```bash
aws s3 ls | grep aws-storage-db        # no matching buckets
aws dynamodb list-tables               # table gone
aws ec2 describe-volumes --filters Name=tag:Project,Values=aws-storage-db
```
The buckets use `force_destroy = true`, so `destroy` removes them even with a few
leftover test objects. **Always run `terraform destroy` when finished.**

## Security considerations
- **No secrets in code.** `terraform.tfvars`, state, and `.terraform/` are
  gitignored (`solution/.gitignore`). State can contain ARNs/account ids — keep
  it in a private remote backend for real use.
- **S3 hardening:** versioning + AES256 SSE + full public-access block + a bucket
  policy that denies non-TLS transport and unencrypted uploads + access logging.
- **DynamoDB:** SSE on (AWS-owned key) + point-in-time recovery.
- **EBS / EC2:** volumes encrypted at rest; the instance requires **IMDSv2**
  (`http_tokens = required`) so role creds can't be stolen via SSRF; the instance
  role is **read-only on this bucket and this table only** (no `*` resources).
- **Documented checkov skips** (intentional teaching choices, not oversights):
  - `CKV_AWS_145` / `CKV_AWS_119` / `CKV_AWS_189` — this lab teaches **SSE-S3
    (AES256) / AWS-managed keys** as the free baseline; customer-managed KMS keys
    are the named "harden further" step, not the near-$0 default.
  - `CKV_AWS_144` (S3 cross-region replication) and `CKV2_AWS_62` (S3 event
    notifications) — out of scope for a single-region storage-primitives lab;
    each would add cost or an external target (SNS/SQS/Lambda).
  - `CKV_AWS_18` on the **logs** bucket only — a log target must not log to
    itself (recursion); the data bucket it serves *is* logged.
  Real findings (access logging, lifecycle on the logs bucket) were **fixed in
  source**, not skipped.

## Cost considerations
With `enable_compute = false` (the default) the stack is **effectively $0**:
- **S3** — two empty buckets cost nothing to exist; you pay per GB stored and per
  request. An empty create -> destroy is cents at most.
- **DynamoDB** — `PAY_PER_REQUEST` means **no provisioned capacity**; an idle
  table is $0. PITR storage is negligible for an empty table.
- **EBS** — one **gp3, 8 GiB** volume is roughly **$0.64/month** (us-east-1
  ~$0.08/GB-month), i.e. a couple of cents for the minutes of a lab.
- **EC2 is GATED OFF.** Setting `enable_compute = true` adds a `t3.micro`
  (~$0.0104/hr on-demand) plus its 8 GiB root volume — still cents/hour, but it
  is the only resource here that bills while *idle*, so leave it off unless doing
  the compute exercise.

To stay at $0: keep `enable_compute = false`, keep the volume small, and
**`terraform destroy` immediately after** every live apply.

## Instructor answer key
The complete reference is [`solution/`](solution/). Non-obvious grading points:
- **All four** public-access-block flags must be `true` — students often set only
  `block_public_acls`/`block_public_policy` and miss `ignore_public_acls` /
  `restrict_public_buckets`, leaving `CKV2_AWS_6` failing.
- The **lifecycle** resource must `depends_on` the versioning resource, otherwise
  a race can apply the noncurrent-version rule before versioning exists.
- The **bucket policy** must use `Deny` (not `Allow`) — a common wrong answer is
  an `Allow` that accidentally widens access. The `aws:SecureTransport = false`
  condition + `s3:x-amz-server-side-encryption != AES256` condition are the two
  required guards.
- The **instance policy** must be least privilege: no `s3:*`, no `"*"` resource.
  Catch students who paste `AmazonS3FullAccess`.
- **Compute gating:** every compute resource (ami data source, role, policy doc,
  role policy, instance profile, instance) must be `count`-gated on
  `enable_compute`; a default `plan` must show **no** EC2/IAM resources.
- **Troubleshooting:** the `broken/` fixture passes `terraform validate` — the
  teaching point is that **`validate` checks syntax, not security**; you need
  `checkov` (or Trivy/tfsec) to catch a public bucket.
- Answer-key checks are encoded in `tests/test_terraform_structure.py` (18 tests)
  so grading is reproducible.

## Class Artifacts & Validation
| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | solution/main.tf | terraform | Secured S3 + DynamoDB + EBS + gated EC2 | `terraform -chdir=solution validate` | PASS |
| 2 | solution/ | terraform | Full module | `checkov -d solution --compact --quiet` | PASS (46 passed, 0 failed, 9 documented skips) |
| 3 | starter/main.tf | terraform | TODO'd S3 security blocks | `terraform -chdir=starter validate` | PASS (validate); checkov fails until TODOs done (by design) |
| 4 | broken/main.tf | terraform | Public bucket troubleshooting fixture | `checkov -d broken --compact` | FAILS as expected (15 findings) |
| 5 | tests/test_terraform_structure.py | python | Structural answer-key tests | `python3 -m unittest discover -s tests` | PASS (18 tests) |
| 6 | validate.sh | shell | All gates | `./validate.sh` | PASS (exit 0) |
