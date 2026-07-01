"""Offline structural assertions for the performance-scaling manifests.

These run without a cluster (PyYAML only) and lock in the properties the lab
depends on: the HPA targets CPU at 50% with min=1/max=5, the Deployment that the
HPA targets actually declares a CPU request (or the HPA can't compute a percent),
the Service selector matches the pods, and the broken fixture is genuinely broken
(no CPU request). Run: python3 -m unittest discover -s tests -p 'test_*.py'
"""
import os
import unittest

import yaml

HERE = os.path.dirname(os.path.abspath(__file__))
K8S = os.path.join(HERE, "..", "solution", "k8s")
BROKEN = os.path.join(HERE, "..", "broken")


def load_all(path):
    with open(path) as fh:
        return [d for d in yaml.safe_load_all(fh) if d]


def load_one(path):
    docs = load_all(path)
    assert len(docs) == 1, f"{path}: expected one document, got {len(docs)}"
    return docs[0]


class TestHPA(unittest.TestCase):
    def setUp(self):
        self.hpa = load_one(os.path.join(K8S, "hpa.yaml"))

    def test_kind_and_version(self):
        self.assertEqual(self.hpa["apiVersion"], "autoscaling/v2")
        self.assertEqual(self.hpa["kind"], "HorizontalPodAutoscaler")

    def test_min_max_replicas(self):
        spec = self.hpa["spec"]
        self.assertEqual(spec["minReplicas"], 1, "minReplicas must be 1")
        self.assertEqual(spec["maxReplicas"], 5, "maxReplicas must be 5")

    def test_targets_cpu_50_percent(self):
        metrics = self.hpa["spec"]["metrics"]
        cpu = [
            m
            for m in metrics
            if m["type"] == "Resource" and m["resource"]["name"] == "cpu"
        ]
        self.assertEqual(len(cpu), 1, "exactly one CPU Resource metric expected")
        target = cpu[0]["resource"]["target"]
        self.assertEqual(target["type"], "Utilization")
        self.assertEqual(
            target["averageUtilization"], 50, "CPU target must be 50%"
        )

    def test_targets_the_deployment(self):
        ref = self.hpa["spec"]["scaleTargetRef"]
        self.assertEqual(ref["kind"], "Deployment")
        self.assertEqual(ref["name"], "cpu-burner")


class TestDeployment(unittest.TestCase):
    def setUp(self):
        self.dep = load_one(os.path.join(K8S, "deployment.yaml"))
        self.container = self.dep["spec"]["template"]["spec"]["containers"][0]

    def test_has_cpu_request(self):
        # Without a CPU *request*, a Utilization HPA has no denominator and shows
        # <unknown>. This is the property the broken fixture violates on purpose.
        req = self.container["resources"]["requests"]
        self.assertIn("cpu", req, "Deployment must declare resources.requests.cpu")

    def test_runs_non_root(self):
        sc = self.dep["spec"]["template"]["spec"]["securityContext"]
        self.assertTrue(sc.get("runAsNonRoot"), "pod must run as non-root")

    def test_probes_target_healthz_not_burn(self):
        # Probes must hit the cheap /healthz, never /burn — a CPU-heavy probe
        # would fail the pod under load and cause restart storms.
        for probe in ("livenessProbe", "readinessProbe", "startupProbe"):
            path = self.container[probe]["httpGet"]["path"]
            self.assertEqual(path, "/healthz", f"{probe} must hit /healthz")

    def test_selector_matches_template_labels(self):
        sel = self.dep["spec"]["selector"]["matchLabels"]
        labels = self.dep["spec"]["template"]["metadata"]["labels"]
        for k, v in sel.items():
            self.assertEqual(labels.get(k), v, "selector must match pod labels")


class TestServiceWiring(unittest.TestCase):
    def test_service_selector_matches_deployment(self):
        svc = load_one(os.path.join(K8S, "service.yaml"))
        dep = load_one(os.path.join(K8S, "deployment.yaml"))
        sel = svc["spec"]["selector"]
        labels = dep["spec"]["template"]["metadata"]["labels"]
        for k, v in sel.items():
            self.assertEqual(
                labels.get(k), v, "Service selector must match the pod labels"
            )

    def test_service_targets_named_port(self):
        svc = load_one(os.path.join(K8S, "service.yaml"))
        port = svc["spec"]["ports"][0]
        self.assertEqual(port["targetPort"], "http")


class TestBrokenFixture(unittest.TestCase):
    def test_broken_deployment_has_no_cpu_request(self):
        docs = load_all(os.path.join(BROKEN, "deployment-no-cpu-request.yaml"))
        deps = [d for d in docs if d["kind"] == "Deployment"]
        self.assertEqual(len(deps), 1)
        container = deps[0]["spec"]["template"]["spec"]["containers"][0]
        requests = container.get("resources", {}).get("requests", {})
        self.assertNotIn(
            "cpu",
            requests,
            "broken fixture must OMIT cpu request to reproduce <unknown>",
        )

    def test_broken_hpa_still_targets_cpu(self):
        docs = load_all(os.path.join(BROKEN, "deployment-no-cpu-request.yaml"))
        hpas = [d for d in docs if d["kind"] == "HorizontalPodAutoscaler"]
        self.assertEqual(len(hpas), 1)
        metrics = hpas[0]["spec"]["metrics"]
        self.assertTrue(
            any(m["resource"]["name"] == "cpu" for m in metrics),
            "broken HPA must still target CPU so <unknown> is reproduced",
        )


if __name__ == "__main__":
    unittest.main()
