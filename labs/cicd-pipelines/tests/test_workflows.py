"""Test suite for the CI/CD workflows.

Runs with stdlib unittest (no pip beyond PyYAML):
    python3 -m unittest discover -s tests

Covers:
  * YAML parses for every workflow (primary CI, advanced CI, CD, GitLab).
  * Job graph is valid for the solution and detected-broken for the broken fixture.
  * Security invariants:
      - PRIMARY ci.yml (Week 9 lecture): gitleaks + pip-audit hard gate, no soft-fail.
      - ADVANCED ci-advanced.yml: Trivy image scan hard gate (exit-code 1).
      - cd.yml: OIDC, not long-lived keys.
"""
import unittest
from pathlib import Path

import yaml

from check_job_graph import check_workflow

MODULE_ROOT = Path(__file__).resolve().parent.parent
SOLUTION = MODULE_ROOT / "solution"
BROKEN = MODULE_ROOT / "broken"

CI = SOLUTION / ".github" / "workflows" / "ci.yml"          # PRIMARY (Week 9)
CI_ADVANCED = SOLUTION / ".github" / "workflows" / "ci-advanced.yml"
CD = SOLUTION / ".github" / "workflows" / "cd.yml"
GITLAB = SOLUTION / ".gitlab-ci.yml"


def load(path: Path):
    return yaml.safe_load(path.read_text())


def _steps_of(job: dict) -> list:
    return job.get("steps") or []


class TestYamlParses(unittest.TestCase):
    def test_all_workflows_parse(self) -> None:
        for wf in (CI, CI_ADVANCED, CD, GITLAB):
            with self.subTest(workflow=wf.name):
                self.assertIsInstance(load(wf), dict)


class TestJobGraph(unittest.TestCase):
    def test_solution_ci_graph_valid(self) -> None:
        self.assertEqual(check_workflow(CI), [])

    def test_solution_ci_advanced_graph_valid(self) -> None:
        self.assertEqual(check_workflow(CI_ADVANCED), [])

    def test_solution_cd_graph_valid(self) -> None:
        self.assertEqual(check_workflow(CD), [])

    def test_broken_fixture_is_detected(self) -> None:
        broken_wf = BROKEN / "ci-bad-needs.yml"
        errs = check_workflow(broken_wf)
        self.assertTrue(errs, "broken fixture should produce at least one error")
        self.assertTrue(
            any("not a defined job" in e for e in errs),
            f"expected a dangling-needs error, got: {errs}",
        )


class TestCiSecurityGate(unittest.TestCase):
    """The PRIMARY Week 9 gate: gitleaks (secret scan) + pip-audit (SCA)."""

    def setUp(self) -> None:
        self.ci = load(CI)
        self.security = self.ci["jobs"]["security"]
        self.steps = _steps_of(self.security)

    def test_has_gitleaks_secret_scan(self) -> None:
        gitleaks = [s for s in self.steps if "gitleaks" in str(s.get("uses", ""))]
        self.assertEqual(len(gitleaks), 1, "expected exactly one gitleaks step")
        # gitleaks-action needs the token to annotate the run.
        self.assertIn("GITHUB_TOKEN", gitleaks[0].get("env", {}))

    def test_checkout_full_history_for_gitleaks(self) -> None:
        # gitleaks scans the FULL history, so the checkout must set fetch-depth: 0.
        checkouts = [s for s in self.steps if "actions/checkout" in str(s.get("uses", ""))]
        self.assertTrue(checkouts, "security job must check out the repo")
        self.assertEqual(str(checkouts[0]["with"]["fetch-depth"]), "0")

    def test_has_pip_audit_sca_scan(self) -> None:
        run_blob = "\n".join(str(s.get("run", "")) for s in self.steps)
        self.assertIn("pip-audit", run_blob, "expected a pip-audit SCA step")
        self.assertIn("requirements.txt", run_blob, "pip-audit must scan requirements.txt")

    def test_no_soft_fail_on_security_job(self) -> None:
        # The gate must not be neutralized at the job level...
        self.assertNotEqual(self.security.get("continue-on-error"), True)
        # ...nor at any step level, and no `|| true` may swallow the exit code.
        for s in self.steps:
            self.assertNotEqual(s.get("continue-on-error"), True)
            self.assertNotIn("|| true", str(s.get("run", "")))


class TestCiLintTestBuild(unittest.TestCase):
    """The PRIMARY pipeline lints, tests, and produces a real tarball artifact."""

    def setUp(self) -> None:
        self.ci = load(CI)
        self.job = self.ci["jobs"]["lint-test-build"]
        self.run_blob = "\n".join(str(s.get("run", "")) for s in _steps_of(self.job))

    def test_runs_ruff_and_pytest(self) -> None:
        self.assertIn("ruff check", self.run_blob)
        self.assertIn("pytest", self.run_blob)

    def test_builds_sha_tagged_tarball(self) -> None:
        # Artifact must be a SHA-tagged tarball for traceability.
        self.assertIn("tar -czf", self.run_blob)
        self.assertIn("GITHUB_SHA", self.run_blob)

    def test_uploads_artifact(self) -> None:
        uploads = [
            s for s in _steps_of(self.job)
            if "actions/upload-artifact" in str(s.get("uses", ""))
        ]
        self.assertEqual(len(uploads), 1, "expected one upload-artifact step")


class TestCiLeastPrivilege(unittest.TestCase):
    def test_top_level_permissions_read_only(self) -> None:
        ci = load(CI)
        self.assertEqual(ci["permissions"], {"contents": "read"})

    def test_concurrency_configured(self) -> None:
        ci = load(CI)
        self.assertIn("concurrency", ci)
        self.assertTrue(ci["concurrency"]["cancel-in-progress"])


class TestCiAdvancedScanGate(unittest.TestCase):
    """The ADVANCED variant: a hard Trivy IMAGE scan gate."""

    def setUp(self) -> None:
        self.ci = load(CI_ADVANCED)
        self.scan = self.ci["jobs"]["scan"]

    def test_scan_runs_after_build(self) -> None:
        self.assertIn("build", self.scan["needs"])

    def test_scan_is_a_hard_gate(self) -> None:
        trivy_steps = [
            s for s in _steps_of(self.scan)
            if "trivy-action" in str(s.get("uses", ""))
        ]
        self.assertEqual(len(trivy_steps), 1, "expected exactly one Trivy scan step")
        with_block = trivy_steps[0]["with"]
        self.assertEqual(str(with_block["exit-code"]), "1")
        self.assertIn("HIGH", str(with_block["severity"]))
        self.assertIn("CRITICAL", str(with_block["severity"]))

    def test_no_soft_fail_continue_on_error(self) -> None:
        self.assertNotEqual(self.scan.get("continue-on-error"), True)


class TestCdOidc(unittest.TestCase):
    def setUp(self) -> None:
        self.cd = load(CD)
        self.deploy = self.cd["jobs"]["deploy"]

    def test_triggers_on_version_tags(self) -> None:
        # PyYAML parses bare `on:` as the boolean True, so look it up by both keys.
        triggers = self.cd.get("on", self.cd.get(True))
        self.assertIn("v*", triggers["push"]["tags"])

    def test_oidc_id_token_write(self) -> None:
        self.assertEqual(self.deploy["permissions"]["id-token"], "write")

    def test_uses_configure_aws_credentials_with_role(self) -> None:
        steps = self.deploy["steps"]
        aws_steps = [s for s in steps if "configure-aws-credentials" in str(s.get("uses", ""))]
        self.assertEqual(len(aws_steps), 1)
        with_block = aws_steps[0]["with"]
        self.assertIn("role-to-assume", with_block)

    def test_no_long_lived_keys_in_step_inputs(self) -> None:
        # No static AWS key inputs may appear as `with:` inputs on ANY step.
        for step in self.deploy["steps"]:
            with_block = step.get("with") or {}
            self.assertNotIn("aws-access-key-id", with_block)
            self.assertNotIn("aws-secret-access-key", with_block)

    def test_production_environment_required(self) -> None:
        env = self.deploy["environment"]
        self.assertEqual(env["name"], "production")


class TestGitlabMirror(unittest.TestCase):
    def setUp(self) -> None:
        self.gl = load(GITLAB)

    def test_has_five_stages(self) -> None:
        self.assertEqual(
            self.gl["stages"], ["lint", "test", "build", "scan", "deploy"]
        )

    def test_scan_gate_not_allowed_to_fail(self) -> None:
        scan = self.gl["scan:trivy"]
        self.assertEqual(scan["allow_failure"], False)
        self.assertIn("--exit-code 1", " ".join(
            s if isinstance(s, str) else " ".join(s) for s in scan["script"]
        ))


if __name__ == "__main__":
    unittest.main()
