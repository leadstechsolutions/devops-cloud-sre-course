"""Offline unit tests for error_budget pure logic. No network, no clock.

Run from the module root:
    PYTHONPATH=solution/scripts python3 -m unittest discover -s tests
(validate.sh wires PYTHONPATH for both solution/ and starter/.)
"""
import contextlib
import io
import unittest

import error_budget as eb


def _run_cli(mod, argv):
    """Run a module's main() with stdout/stderr captured, return exit code."""
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf), contextlib.redirect_stderr(buf):
        return mod.main(argv)


class TestBurnRate(unittest.TestCase):
    def test_no_errors_is_zero(self):
        self.assertEqual(eb.burn_rate(0.999, 1_000_000, 1_000_000), 0.0)

    def test_spending_exactly_budget_is_1x(self):
        # 1000 bad of 1,000,000 at 99.9% == exactly the budget == 1.0x.
        self.assertAlmostEqual(eb.burn_rate(0.999, 999_000, 1_000_000), 1.0, places=9)

    def test_double_budget_is_2x(self):
        self.assertAlmostEqual(eb.burn_rate(0.999, 998_000, 1_000_000), 2.0, places=9)

    def test_canonical_fast_burn_14_4x(self):
        # 1.44% error fraction against a 0.1% budget -> the classic 14.4x page.
        self.assertAlmostEqual(eb.burn_rate(0.999, 9856, 10_000), 14.4, places=6)

    def test_target_out_of_range_raises(self):
        with self.assertRaises(ValueError):
            eb.burn_rate(1.0, 1, 2)
        with self.assertRaises(ValueError):
            eb.burn_rate(-0.1, 1, 2)

    def test_total_must_be_positive(self):
        with self.assertRaises(ValueError):
            eb.burn_rate(0.99, 0, 0)

    def test_good_cannot_exceed_total(self):
        with self.assertRaises(ValueError):
            eb.burn_rate(0.99, 11, 10)


class TestTimeToExhaustion(unittest.TestCase):
    def test_already_exhausted_is_zero(self):
        self.assertEqual(eb.time_to_exhaustion_hours(0.0, 2.0, 720), 0.0)
        self.assertEqual(eb.time_to_exhaustion_hours(-0.5, 2.0, 720), 0.0)

    def test_no_burn_is_none(self):
        self.assertIsNone(eb.time_to_exhaustion_hours(1.0, 0.0, 720))

    def test_half_budget_half_rate_is_full_window(self):
        # 50% left, burning at 0.5x -> 0.5 * 720 / 0.5 = 720h.
        self.assertAlmostEqual(
            eb.time_to_exhaustion_hours(0.5, 0.5, 720), 720.0, places=6)

    def test_full_budget_at_2x_is_half_window(self):
        self.assertAlmostEqual(
            eb.time_to_exhaustion_hours(1.0, 2.0, 720), 360.0, places=6)


class TestCompute(unittest.TestCase):
    def test_blown_budget_150_percent_consumed(self):
        r = eb.compute(0.999, 998_500, 1_000_000)
        self.assertEqual(r.bad, 1500)
        self.assertAlmostEqual(r.allowed_bad_events, 1000.0, places=3)
        self.assertAlmostEqual(r.budget_consumed, 1.5, places=9)
        self.assertAlmostEqual(r.budget_remaining, -0.5, places=9)
        self.assertAlmostEqual(r.burn_rate, 1.5, places=9)
        # Budget already gone -> time to exhaustion is 0, not negative/None.
        self.assertEqual(r.time_to_exhaustion_hours, 0.0)

    def test_healthy_budget(self):
        r = eb.compute(0.999, 999_500, 1_000_000)
        self.assertAlmostEqual(r.budget_remaining, 0.5, places=9)
        self.assertAlmostEqual(r.burn_rate, 0.5, places=9)
        # 50% left, 0.5x burn -> exactly one 720h window remaining.
        self.assertAlmostEqual(r.time_to_exhaustion_hours, 720.0, places=6)

    def test_perfect_window_never_exhausts(self):
        r = eb.compute(0.999, 1_000_000, 1_000_000)
        self.assertEqual(r.budget_remaining, 1.0)
        self.assertEqual(r.burn_rate, 0.0)
        self.assertIsNone(r.time_to_exhaustion_hours)

    def test_custom_window_scales_tte(self):
        # Same 0.5x burn, 50% left, but a 168h (7d) window -> 168h remaining.
        r = eb.compute(0.999, 999_500, 1_000_000, window_hours=168)
        self.assertAlmostEqual(r.time_to_exhaustion_hours, 168.0, places=6)

    def test_window_hours_must_be_positive(self):
        with self.assertRaises(ValueError):
            eb.compute(0.999, 1, 2, window_hours=0)


class TestFormatReport(unittest.TestCase):
    def test_contains_key_fields(self):
        out = eb.format_report(eb.compute(0.999, 998_500, 1_000_000))
        self.assertIn("Burn rate", out)
        self.assertIn("1.50x", out)
        self.assertIn("EXHAUSTED", out)

    def test_healthy_status(self):
        # 10% consumed -> 90% remaining -> HEALTHY.
        out = eb.format_report(eb.compute(0.999, 999_900, 1_000_000))
        self.assertIn("Status", out)
        self.assertIn("HEALTHY", out)

    def test_at_risk_status(self):
        # 800 bad of 1M against a 1000 budget -> 80% consumed -> 20% left -> AT RISK.
        out = eb.format_report(eb.compute(0.999, 999_200, 1_000_000))
        self.assertIn("AT RISK", out)

    def test_status_for_thresholds(self):
        self.assertEqual(eb.status_for(eb.compute(0.999, 999_900, 1_000_000)), "HEALTHY")
        self.assertEqual(eb.status_for(eb.compute(0.999, 999_200, 1_000_000)), "AT RISK")
        self.assertEqual(eb.status_for(eb.compute(0.999, 998_500, 1_000_000)), "EXHAUSTED")


class TestCli(unittest.TestCase):
    def test_main_happy_path_returns_zero(self):
        rc = _run_cli(eb, ["--target", "0.999", "--good", "999900", "--total", "1000000"])
        self.assertEqual(rc, 0)

    def test_main_json_flag(self):
        rc = _run_cli(
            eb, ["--target", "0.999", "--good", "999900", "--total", "1000000", "--json"]
        )
        self.assertEqual(rc, 0)

    def test_main_bad_input_returns_two(self):
        # good > total is invalid -> compute raises -> main returns exit code 2.
        rc = _run_cli(eb, ["--target", "0.999", "--good", "11", "--total", "10"])
        self.assertEqual(rc, 2)


if __name__ == "__main__":
    unittest.main()
