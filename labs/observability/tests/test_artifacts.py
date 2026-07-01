"""Structural invariants for the observability module artifacts.

These are real gates, not just "the file parses". They assert the things a learner most
often gets wrong and the things downstream tools require:

  * The Grafana dashboard is a valid dashboard MODEL (schemaVersion, panels, every panel
    has targets with a non-empty PromQL expr).
  * The Prometheus rule files have the recording rules the alerts depend on, and the
    burn-rate alerts use the correct multi-window / multi-burn-rate thresholds
    (1h+5m @ 14.4x, 6h+30m @ 6x) for a 99.9% SLO.
  * The OpenSLO spec declares the 99.9% objective the alerts protect.

Run: python3 -m unittest discover -s tests
Stdlib + PyYAML only (PyYAML is a documented prerequisite of this module).
"""
import json
import os
import unittest

import yaml

HERE = os.path.dirname(os.path.abspath(__file__))
SOL = os.path.join(HERE, "..", "solution")


def load_yaml(*parts):
    with open(os.path.join(SOL, *parts)) as fh:
        return yaml.safe_load(fh)


def load_yaml_all(*parts):
    with open(os.path.join(SOL, *parts)) as fh:
        return list(yaml.safe_load_all(fh))


def load_json(*parts):
    with open(os.path.join(SOL, *parts)) as fh:
        return json.load(fh)


class TestGrafanaDashboard(unittest.TestCase):
    """The dashboard must be a valid Grafana dashboard model with usable panels."""

    @classmethod
    def setUpClass(cls):
        cls.d = load_json("grafana", "dashboards", "service-overview.json")

    def test_has_schema_version_and_title_and_uid(self):
        self.assertIn("schemaVersion", self.d)
        self.assertIsInstance(self.d["schemaVersion"], int)
        self.assertGreaterEqual(self.d["schemaVersion"], 36)  # modern Grafana
        self.assertTrue(self.d.get("title"))
        self.assertTrue(self.d.get("uid"))

    def test_has_panels(self):
        panels = self.d.get("panels")
        self.assertIsInstance(panels, list)
        self.assertGreaterEqual(len(panels), 3, "need rate, errors, latency panels")

    def test_panel_ids_unique(self):
        ids = [p["id"] for p in self.d["panels"]]
        self.assertEqual(len(ids), len(set(ids)), "duplicate panel ids break Grafana")

    def test_every_panel_has_targets_with_expr(self):
        for p in self.d["panels"]:
            with self.subTest(panel=p.get("title")):
                targets = p.get("targets")
                self.assertTrue(targets, f"panel {p.get('title')!r} has no targets")
                for t in targets:
                    self.assertTrue(
                        t.get("expr", "").strip(),
                        f"panel {p.get('title')!r} target {t.get('refId')} has empty expr",
                    )

    def test_covers_rate_errors_latency(self):
        titles = " ".join(p.get("title", "").lower() for p in self.d["panels"])
        self.assertIn("rate", titles)
        self.assertIn("error", titles)
        self.assertIn("latency", titles)


class TestRecordingRules(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.doc = load_yaml("prometheus", "rules", "recording.rules.yml")
        cls.records = {
            r["record"]
            for g in cls.doc["groups"]
            for r in g["rules"]
            if "record" in r
        }

    def test_red_series_present(self):
        for name in (
            "job:http_requests:rate5m",
            "job:http_requests_error_ratio:rate5m",
            "job:http_request_duration_seconds:p99",
        ):
            self.assertIn(name, self.records, f"missing RED recording rule {name}")

    def test_windows_the_alerts_need_are_recorded(self):
        # The burn-rate alerts reference these exact windows.
        for name in (
            "job:http_requests_error_ratio:rate5m",
            "job:http_requests_error_ratio:rate30m",
            "job:http_requests_error_ratio:rate1h",
            "job:http_requests_error_ratio:rate6h",
        ):
            self.assertIn(name, self.records)

    def test_p99_uses_histogram_quantile_with_le(self):
        expr = next(
            r["expr"]
            for g in self.doc["groups"]
            for r in g["rules"]
            if r.get("record") == "job:http_request_duration_seconds:p99"
        )
        self.assertIn("histogram_quantile", expr)
        self.assertIn("by (job, le)", expr.replace("\n", " "))


class TestAlertingRules(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.doc = load_yaml("prometheus", "rules", "alerting.rules.yml")
        cls.alerts = {
            r["alert"]: r
            for g in cls.doc["groups"]
            for r in g["rules"]
            if "alert" in r
        }

    def test_both_burn_rate_alerts_exist(self):
        self.assertIn("CheckoutErrorBudgetBurnFast", self.alerts)
        self.assertIn("CheckoutErrorBudgetBurnSlow", self.alerts)

    def test_fast_burn_is_multiwindow_14_4x(self):
        a = self.alerts["CheckoutErrorBudgetBurnFast"]
        expr = a["expr"].replace("\n", " ")
        self.assertIn("rate1h", expr, "fast-burn long window must be 1h")
        self.assertIn("rate5m", expr, "fast-burn short window must be 5m")
        self.assertIn("14.4", expr, "fast-burn threshold must be 14.4x")
        self.assertIn(" and ", expr, "must require BOTH windows (multiwindow)")
        self.assertEqual(a["labels"]["severity"], "page")

    def test_slow_burn_is_multiwindow_6x(self):
        a = self.alerts["CheckoutErrorBudgetBurnSlow"]
        expr = a["expr"].replace("\n", " ")
        self.assertIn("rate6h", expr, "slow-burn long window must be 6h")
        self.assertIn("rate30m", expr, "slow-burn short window must be 30m")
        self.assertIn("6 * 0.001", expr, "slow-burn threshold must be 6x budget")
        self.assertIn(" and ", expr)
        self.assertEqual(a["labels"]["severity"], "ticket")

    def test_alerts_have_summary_and_runbook(self):
        for name in ("CheckoutErrorBudgetBurnFast", "CheckoutErrorBudgetBurnSlow"):
            ann = self.alerts[name].get("annotations", {})
            self.assertTrue(ann.get("summary"), f"{name} needs a summary")
            self.assertTrue(ann.get("runbook_url"), f"{name} needs a runbook_url")


class TestOpenSLO(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.docs = load_yaml_all("slo", "slo.yaml")

    def test_apiversion_v1(self):
        slo = next(d for d in self.docs if d["kind"] == "SLO")
        self.assertEqual(slo["apiVersion"], "openslo/v1")

    def test_objective_is_99_9_percent(self):
        slo = next(d for d in self.docs if d["kind"] == "SLO")
        target = slo["spec"]["objectives"][0]["target"]
        self.assertEqual(target, 0.999, "availability objective must be 99.9%")

    def test_ratio_metric_uses_prometheus(self):
        slo = next(d for d in self.docs if d["kind"] == "SLO")
        ratio = slo["spec"]["indicator"]["spec"]["ratioMetric"]
        for side in ("total", "good"):
            src = ratio[side]["metricSource"]
            self.assertEqual(src["type"], "Prometheus")
            self.assertIn("http_requests_total", src["spec"]["query"])


if __name__ == "__main__":
    unittest.main()
