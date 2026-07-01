# Week 1: DevOps, Cloud, and SRE Career Foundations

**Program:** Enterprise DevOps, Cloud Engineering, and Site Reliability Engineering Program  
**Week:** 1  
**Module Title:** DevOps, Cloud, and SRE Career Foundations  
**Track:** Unified DevOps · Cloud · SRE Track  
**Class Format:** 2 instructor-led classes, 3 hours each  
**Primary Cloud:** AWS  
**Secondary Cloud Exposure:** Azure and GCP  
**Audience:** Beginner to intermediate learners  
**Goal:** Prepare students for job-ready DevOps Engineer, Cloud Engineer, and Site Reliability Engineer roles

> This README is the week index. The full instructor-and-student packages live in the class files. Edit content there, not here, to avoid duplication.

---

> **▶ Runnable lab for this class:** [`labs/setup-validation/`](../../labs/setup-validation/)
>
> The **on-disk, validated** version of this class's work — clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check against `solution/`, then run `./validate.sh`.

## Week 1 Overview

Week 1 introduces the professional world of DevOps, Cloud Engineering, Site Reliability Engineering, Platform Engineering, and Production Support. Students learn how these roles fit together in an enterprise organization, how software moves from code to production (both push-based CI/CD and pull-based GitOps), and how modern teams measure delivery health with DORA metrics. They then validate the local toolchain (terminal, VS Code, Git, AWS CLI, Docker, Terraform) and the AWS Console, and practice evidence-first troubleshooting on real setup errors.

This is a soft start: orientation plus environment validation. Real building begins in Week 2 (Linux).

---

## Week 1 Learning Objectives

By the end of Week 1, students should be able to:

1. Explain the difference between DevOps Engineering, Cloud Engineering, SRE, Platform Engineering, and Production Support, and describe what *senior* looks like in each.
2. Describe how software moves from code to production via both push-based CI/CD and pull-based GitOps.
3. Recognize the four DORA metrics (deployment frequency, lead time for changes, change failure rate, MTTR) and what they measure.
4. Identify the major tools used throughout the course and validate them locally.
5. Use basic terminal commands and document tool versions in a setup report.
6. Understand AWS Console, AWS Regions, and Availability Zones at a high level.
7. Know that the modern AWS CLI credential path is IAM Identity Center (SSO) with short-lived credentials, not long-lived access keys.
8. Document setup issues clearly using an evidence-first troubleshooting approach (command → exact error → likely cause → next step).

---

## Classes

| Class | Title | Focus | Link |
|---|---|---|---|
| 1 | Understanding DevOps, Cloud Engineering, and SRE Roles | Role clarity, enterprise workflow, seniority framing, DORA metrics, GitOps awareness, toolchain tour | [class-01.md](./class-01.md) |
| 2 | Lab Environment Setup and First Cloud Toolchain Validation | Terminal + tool validation, IAM Identity Center (SSO) awareness, OpenTofu and dev containers context, AWS Console orientation, setup troubleshooting | [class-02.md](./class-02.md) |

---

## Deliverables

- `setup-validation.md` (toolchain validation report) — see Class 2 lab.
- `week-01-role-reflection.md` (role comparison reflection) — see Class 1 homework.

---

## Cost and Safety

This week creates no AWS resources. Students observe the AWS Console only. Do not create or hand out long-lived access keys; the recommended authentication path (introduced conceptually here, hands-on in Weeks 4 and 6) is AWS IAM Identity Center (SSO).

---

## What's Next

Week 2 begins the first major technical foundation: **Linux for Cloud and DevOps work** (filesystem, permissions, users and groups, processes, services, logs, SSH, and basic Linux troubleshooting).
