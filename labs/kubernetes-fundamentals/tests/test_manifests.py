"""Offline structural tests for the kubernetes-fundamentals manifests.

A real cluster is NOT available in this environment, so `kubectl apply
--dry-run=client` cannot run (it needs the API server for RESTMapping). These
tests give meaningful local validation evidence instead: they render the
kustomize base/overlay exactly as kubectl would, then assert the security,
probe, and resource requirements from the lab spec actually hold in the
rendered objects. Pure stdlib + PyYAML; no network.

Run:  python3 -m unittest discover -s tests
"""
from __future__ import annotations

import os
import subprocess
import unittest

import yaml

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def kustomize(path: str) -> list[dict]:
    """Render a kustomize dir with `kubectl kustomize` and parse the docs."""
    out = subprocess.run(
        ["kubectl", "kustomize", os.path.join(ROOT, path)],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    return [d for d in yaml.safe_load_all(out) if d]


def by_kind(docs: list[dict], kind: str) -> list[dict]:
    return [d for d in docs if d.get("kind") == kind]


def one(docs: list[dict], kind: str, name_contains: str = "") -> dict:
    items = [
        d
        for d in by_kind(docs, kind)
        if name_contains in d["metadata"]["name"]
    ]
    assert len(items) == 1, f"expected 1 {kind} ~{name_contains!r}, got {len(items)}"
    return items[0]


class TestBaseRender(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.docs = kustomize("solution/base")

    def test_expected_kinds_present(self):
        kinds = sorted({d["kind"] for d in self.docs})
        for required in (
            "Namespace",
            "ConfigMap",
            "Secret",
            "Deployment",
            "Service",
            "HorizontalPodAutoscaler",
            "Ingress",
            "NetworkPolicy",
        ):
            self.assertIn(required, kinds, f"{required} missing from base")

    def test_namespace_enforces_restricted_psa(self):
        ns = one(self.docs, "Namespace")
        labels = ns["metadata"]["labels"]
        self.assertEqual(labels.get("pod-security.kubernetes.io/enforce"), "restricted")

    def test_deployment_two_replicas(self):
        dep = one(self.docs, "Deployment")
        self.assertEqual(dep["spec"]["replicas"], 2)

    def test_pod_security_context_runs_as_non_root(self):
        dep = one(self.docs, "Deployment")
        psc = dep["spec"]["template"]["spec"]["securityContext"]
        self.assertTrue(psc.get("runAsNonRoot"))
        self.assertEqual(psc.get("runAsUser"), 10001)
        self.assertEqual(psc.get("seccompProfile", {}).get("type"), "RuntimeDefault")

    def test_container_hardening(self):
        dep = one(self.docs, "Deployment")
        c = dep["spec"]["template"]["spec"]["containers"][0]
        csc = c["securityContext"]
        self.assertFalse(csc.get("allowPrivilegeEscalation"))
        self.assertTrue(csc.get("readOnlyRootFilesystem"))
        self.assertIn("ALL", csc.get("capabilities", {}).get("drop", []))

    def test_readonly_rootfs_has_writable_tmp(self):
        dep = one(self.docs, "Deployment")
        spec = dep["spec"]["template"]["spec"]
        c = spec["containers"][0]
        mounts = {m["mountPath"]: m["name"] for m in c["volumeMounts"]}
        self.assertIn("/tmp", mounts, "readOnlyRootFilesystem needs a writable /tmp")
        vol_name = mounts["/tmp"]
        vol = next(v for v in spec["volumes"] if v["name"] == vol_name)
        self.assertIn("emptyDir", vol, "/tmp must be backed by an emptyDir")

    def test_probes_on_healthz(self):
        dep = one(self.docs, "Deployment")
        c = dep["spec"]["template"]["spec"]["containers"][0]
        for probe in ("livenessProbe", "readinessProbe"):
            self.assertIn(probe, c, f"{probe} missing")
            self.assertEqual(c[probe]["httpGet"]["path"], "/healthz")
            # Probe must hit the real container port, by name or number.
            port = c[probe]["httpGet"]["port"]
            self.assertIn(port, ("http", 8000), f"{probe} targets wrong port {port}")

    def test_resources_requests_and_limits(self):
        dep = one(self.docs, "Deployment")
        res = dep["spec"]["template"]["spec"]["containers"][0]["resources"]
        for kind in ("requests", "limits"):
            self.assertIn("cpu", res[kind], f"missing {kind}.cpu")
            self.assertIn("memory", res[kind], f"missing {kind}.memory")

    def test_service_is_clusterip(self):
        svc = one(self.docs, "Service")
        self.assertEqual(svc["spec"]["type"], "ClusterIP")

    def test_hpa_targets_cpu_70(self):
        hpa = one(self.docs, "HorizontalPodAutoscaler")
        m = hpa["spec"]["metrics"][0]
        self.assertEqual(m["resource"]["name"], "cpu")
        self.assertEqual(m["resource"]["target"]["averageUtilization"], 70)

    def test_networkpolicy_default_deny_present(self):
        nps = by_kind(self.docs, "NetworkPolicy")
        names = {n["metadata"]["name"] for n in nps}
        # default-deny: empty podSelector with both policyTypes and no rules.
        deny = [
            n
            for n in nps
            if n["spec"].get("podSelector") == {}
            and set(n["spec"].get("policyTypes", [])) == {"Ingress", "Egress"}
            and not n["spec"].get("ingress")
            and not n["spec"].get("egress")
        ]
        self.assertTrue(deny, f"no default-deny NetworkPolicy among {names}")

    def test_networkpolicy_allows_from_ingress(self):
        nps = by_kind(self.docs, "NetworkPolicy")
        allows = [
            n
            for n in nps
            for rule in n["spec"].get("ingress", [])
            for frm in rule.get("from", [])
            if frm.get("namespaceSelector", {})
            .get("matchLabels", {})
            .get("kubernetes.io/metadata.name")
            == "ingress-nginx"
        ]
        self.assertTrue(allows, "no NetworkPolicy allows traffic from ingress-nginx")


class TestProdOverlay(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.docs = kustomize("solution/overlays/prod")

    def test_prod_patches_replicas_to_four(self):
        dep = one(self.docs, "Deployment")
        self.assertEqual(dep["spec"]["replicas"], 4)

    def test_prod_name_prefix_applied(self):
        dep = one(self.docs, "Deployment")
        self.assertTrue(dep["metadata"]["name"].startswith("prod-"))


class TestBrokenFixtures(unittest.TestCase):
    """The broken fixtures must be STRUCTURALLY valid (parse + carry the
    documented defect) so they apply cleanly and fail only at runtime."""

    def load(self, name: str) -> list[dict]:
        path = os.path.join(ROOT, "broken", name)
        with open(path) as fh:
            return [d for d in yaml.safe_load_all(fh) if d]

    def test_oomkilled_has_tiny_memory_limit(self):
        dep = next(d for d in self.load("deployment-oomkilled.yaml") if d["kind"] == "Deployment")
        mem = dep["spec"]["template"]["spec"]["containers"][0]["resources"]["limits"]["memory"]
        # 12Mi was verified on a live kind cluster to reproduce the DOCUMENTED
        # runtime symptom (Reason: OOMKilled, Exit Code: 137, CrashLoopBackOff).
        # A still-lower limit (<=8Mi, e.g. the old 4Mi) instead OOM-kills runc's
        # own init -> reason "StartError" / exit 128, which does NOT match the
        # README's symptom text. Keep the limit at the verified 12Mi.
        self.assertEqual(mem, "12Mi", "OOM fixture must keep the verified low memory limit")

    def test_badprobe_readiness_targets_wrong_port(self):
        dep = next(d for d in self.load("deployment-badprobe.yaml") if d["kind"] == "Deployment")
        c = dep["spec"]["template"]["spec"]["containers"][0]
        # The bug: readiness on a port nothing listens on (9999), liveness OK.
        self.assertEqual(c["readinessProbe"]["httpGet"]["port"], 9999)
        self.assertEqual(c["livenessProbe"]["httpGet"]["port"], 8000)


if __name__ == "__main__":
    unittest.main()
