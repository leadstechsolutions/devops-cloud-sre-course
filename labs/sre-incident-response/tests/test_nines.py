"""Offline unit tests for nines_downtime pure logic. No network, no clock."""
import contextlib
import io
import unittest

import nines_downtime as nd


def _run_cli(mod, argv):
    """Run a module's main() with stdout/stderr captured, return exit code."""
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf), contextlib.redirect_stderr(buf):
        return mod.main(argv)


class TestAllowedDowntime(unittest.TestCase):
    def test_three_nines_30d(self):
        # 99.9% over 30 days == 0.001 * 2_592_000 s == 2592 s == 43m 12s.
        secs = nd.allowed_downtime_seconds(0.999, nd.PERIOD_30D_SECONDS)
        self.assertAlmostEqual(secs, 2592.0, places=3)

    def test_three_nines_year(self):
        # 99.9% over 365 days == 0.001 * 31_536_000 == 31_536 s == 8h 45m 36s.
        secs = nd.allowed_downtime_seconds(0.999, nd.PERIOD_YEAR_SECONDS)
        self.assertAlmostEqual(secs, 31_536.0, places=3)

    def test_four_nines_year(self):
        secs = nd.allowed_downtime_seconds(0.9999, nd.PERIOD_YEAR_SECONDS)
        self.assertAlmostEqual(secs, 3_153.6, places=2)

    def test_two_nines_30d(self):
        # 99% over 30 days == 0.01 * 2_592_000 == 25_920 s == 7h 12m.
        secs = nd.allowed_downtime_seconds(0.99, nd.PERIOD_30D_SECONDS)
        self.assertAlmostEqual(secs, 25_920.0, places=3)

    def test_target_out_of_range_raises(self):
        with self.assertRaises(ValueError):
            nd.allowed_downtime_seconds(1.0, nd.PERIOD_30D_SECONDS)
        with self.assertRaises(ValueError):
            nd.allowed_downtime_seconds(-0.01, nd.PERIOD_30D_SECONDS)

    def test_period_must_be_positive(self):
        with self.assertRaises(ValueError):
            nd.allowed_downtime_seconds(0.999, 0)


class TestHumanize(unittest.TestCase):
    def test_zero(self):
        self.assertEqual(nd.humanize_seconds(0), "0s")

    def test_seconds_only(self):
        self.assertEqual(nd.humanize_seconds(45), "45s")

    def test_minutes_and_seconds(self):
        self.assertEqual(nd.humanize_seconds(2592), "43m 12s")

    def test_hours_minutes_seconds(self):
        self.assertEqual(nd.humanize_seconds(31_536), "8h 45m 36s")

    def test_days(self):
        # 1d 2h 3m 4s == 86400 + 7200 + 180 + 4 == 93_784.
        self.assertEqual(nd.humanize_seconds(93_784), "1d 2h 3m 4s")

    def test_drops_internal_zero_units(self):
        # Exactly 1 hour: no minutes, no seconds shown.
        self.assertEqual(nd.humanize_seconds(3600), "1h")

    def test_rounds_subsecond(self):
        self.assertEqual(nd.humanize_seconds(59.6), "1m")

    def test_negative_raises(self):
        with self.assertRaises(ValueError):
            nd.humanize_seconds(-1)


class TestNinesLabel(unittest.TestCase):
    def test_known_nines(self):
        self.assertEqual(nd.nines_label(0.9), "one nine")
        self.assertEqual(nd.nines_label(0.99), "two nines")
        self.assertEqual(nd.nines_label(0.999), "three nines")
        self.assertEqual(nd.nines_label(0.9999), "four nines")
        self.assertEqual(nd.nines_label(0.99999), "five nines")
        self.assertEqual(nd.nines_label(0.999999), "six nines")

    def test_non_nines_is_empty(self):
        self.assertEqual(nd.nines_label(0.9995), "")
        self.assertEqual(nd.nines_label(0.95), "")


class TestDowntimeBudget(unittest.TestCase):
    def test_structure_and_human_strings(self):
        b = nd.downtime_budget(0.999)
        self.assertEqual(b["nines"], "three nines")
        self.assertEqual(b["per_30d"]["human"], "43m 12s")
        self.assertEqual(b["per_year"]["human"], "8h 45m 36s")
        self.assertAlmostEqual(b["per_30d"]["seconds"], 2592.0, places=3)

    def test_non_nines_target_has_empty_label(self):
        b = nd.downtime_budget(0.9995)
        self.assertEqual(b["nines"], "")


class TestFormatReport(unittest.TestCase):
    def test_contains_periods(self):
        out = nd.format_report(nd.downtime_budget(0.999))
        self.assertIn("three nines", out)
        self.assertIn("43m 12s", out)
        self.assertIn("8h 45m 36s", out)


class TestCli(unittest.TestCase):
    def test_main_happy_path(self):
        self.assertEqual(_run_cli(nd, ["--target", "0.999"]), 0)

    def test_main_json(self):
        self.assertEqual(_run_cli(nd, ["--target", "0.9999", "--json"]), 0)

    def test_main_bad_target(self):
        self.assertEqual(_run_cli(nd, ["--target", "1.5"]), 2)


if __name__ == "__main__":
    unittest.main()
