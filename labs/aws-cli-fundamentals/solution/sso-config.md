# Configuring the AWS CLI with IAM Identity Center (SSO)

This is the credential method these scripts assume in a real org. SSO issues
**short-lived** credentials per session, so there are no long-lived access keys
sitting in `~/.aws/credentials` waiting to leak. Every script in this lab honours
the profile you configure here via `AWS_PROFILE`.

> All steps below are **read-only against your identity** plus local config file
> writes. None of them create, modify, or delete AWS resources.

## 1. One-time: configure an SSO profile

```bash
aws configure sso
```

The interactive wizard asks for:

| Prompt                       | What to enter                                                        |
|------------------------------|----------------------------------------------------------------------|
| `SSO session name`           | A short name for the SSO session, e.g. `my-org`                       |
| `SSO start URL`              | Your portal URL, e.g. `https://my-org.awsapps.com/start`             |
| `SSO region`                 | The region your Identity Center instance lives in, e.g. `us-east-1`  |
| `SSO registration scopes`    | Accept the default `sso:account:access`                              |

A browser tab opens for you to authenticate and approve the device. Back in the
terminal you then pick:

| Prompt                       | What to enter                                                        |
|------------------------------|----------------------------------------------------------------------|
| Account                      | Choose the AWS account you want this profile to target               |
| Role                         | Choose the permission set / role (e.g. `ReadOnly`, `PowerUser`)      |
| `CLI default client Region`  | The region your commands default to, e.g. `eu-west-1`               |
| `CLI default output format`  | `json` (these scripts parse JSON/text; `json` is the safe default)  |
| `CLI profile name`           | A profile name you will pass as `AWS_PROFILE`, e.g. `readonly`       |

This writes a stanza to `~/.aws/config` like:

```ini
[sso-session my-org]
sso_start_url = https://my-org.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access

[profile readonly]
sso_session = my-org
sso_account_id = 123456789012
sso_role_name = ReadOnly
region = eu-west-1
output = json
```

Nothing secret is stored here — just *which* role to assume. The actual
credentials are minted on login and cached under `~/.aws/sso/cache/`.

## 2. Each working session: log in

SSO tokens expire (commonly 8–12 hours). When a script reports
`credentials are not usable`, re-authenticate:

```bash
aws sso login --profile readonly
```

This refreshes the cached token. No keys are written to disk in plaintext.

## 3. Use the profile

```bash
export AWS_PROFILE=readonly        # all the lab scripts pick this up
./whoami.sh                        # confirm WHO you are before doing anything
```

`whoami.sh` is the canary: if it prints your account and ARN, every other
read-only script in this lab will authenticate the same way. If it dies with a
clear error, run `aws sso login --profile "$AWS_PROFILE"` and retry.

## 4. Verifying the session without trusting a script

```bash
aws sts get-caller-identity --profile readonly
```

If that returns an `Account` / `Arn` / `UserId` JSON object, you are
authenticated. If it returns `Error loading SSO Token` or
`The SSO session has expired`, run `aws sso login` again.

## 5. Logging out (clears the cached token)

```bash
aws sso logout
```

Use this on shared machines. It removes the cached SSO token so the short-lived
credentials can no longer be used from this host.

## Why SSO over static keys (security note)

- **No long-lived secrets on disk.** Static `aws_access_key_id` /
  `aws_secret_access_key` in `~/.aws/credentials` are the #1 source of leaked AWS
  keys (committed to git, pasted in Slack, baked into images). SSO issues
  temporary credentials that expire automatically.
- **Centralised revocation.** Disable the user in Identity Center and every
  derived session dies — you are not hunting for keys to rotate.
- **Least privilege by permission set.** The role you pick (`ReadOnly`) scopes
  what the profile can do; this lab only needs `Describe*` / `List*` / `sts`.
- **Auditability.** CloudTrail records the assumed-role session, so actions are
  attributable to a human via the permission set.
