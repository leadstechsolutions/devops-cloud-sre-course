"""Offline unit tests for cost_report pure logic. No AWS, no boto3."""
import unittest

import cost_report as cr


def _row(service, amount, unit="USD"):
    """Build a Cost Explorer group row fixture."""
    return {
        "Keys": [service],
        "Metrics": {"UnblendedCost": {"Amount": str(amount), "Unit": unit}},
    }


class TestParseRow(unittest.TestCase):
    def test_extracts_service_and_amount(self):
        self.assertEqual(cr.parse_row(_row("Amazon EC2", "12.34")), ("Amazon EC2", 12.34))

    def test_missing_keys_raises(self):
        with self.assertRaises(ValueError):
            cr.parse_row({"Keys": [], "Metrics": {"UnblendedCost": {"Amount": "1"}}})

    def test_missing_metric_raises(self):
        with self.assertRaises(ValueError):
            cr.parse_row({"Keys": ["S3"], "Metrics": {}})

    def test_non_numeric_amount_raises(self):
        with self.assertRaises(ValueError):
            cr.parse_row(_row("EC2", "not-a-number"))


class TestSummarize(unittest.TestCase):
    def test_groups_and_totals(self):
        rows = [
            _row("Amazon EC2", "100.00"),
            _row("Amazon S3", "25.50"),
            _row("Amazon EC2", "50.00"),  # same service, different day
        ]
        summary = cr.summarize(rows)
        self.assertEqual(summary["total"], 175.50)
        self.assertEqual(
            summary["services"],
            [
                {"service": "Amazon EC2", "amount": 150.00},
                {"service": "Amazon S3", "amount": 25.50},
            ],
        )

    def test_sorted_by_cost_desc(self):
        rows = [_row("A", "1.00"), _row("B", "9.00"), _row("C", "5.00")]
        services = cr.summarize(rows)["services"]
        self.assertEqual([s["service"] for s in services], ["B", "C", "A"])

    def test_tie_break_by_name_asc(self):
        rows = [_row("Zebra", "5.00"), _row("Apple", "5.00")]
        services = cr.summarize(rows)["services"]
        self.assertEqual([s["service"] for s in services], ["Apple", "Zebra"])

    def test_empty_input(self):
        summary = cr.summarize([])
        self.assertEqual(summary, {"services": [], "total": 0.0})

    def test_rounding(self):
        rows = [_row("EC2", "0.005"), _row("EC2", "0.005")]
        # 0.005 + 0.005 = 0.01 after rounding
        self.assertEqual(cr.summarize(rows)["total"], 0.01)


class TestFormatTable(unittest.TestCase):
    def test_empty_message(self):
        out = cr.format_table({"services": [], "total": 0.0})
        self.assertIn("No cost data", out)

    def test_table_contains_rows_and_total(self):
        summary = cr.summarize([_row("Amazon EC2", "150.00"), _row("Amazon S3", "25.50")])
        out = cr.format_table(summary)
        self.assertIn("SERVICE", out)
        self.assertIn("Amazon EC2", out)
        self.assertIn("150.00", out)
        self.assertIn("TOTAL", out)
        self.assertIn("175.50", out)

    def test_alignment_columns_consistent(self):
        summary = cr.summarize([_row("X", "1.00"), _row("LongServiceName", "2.00")])
        out = cr.format_table(summary)
        widths = {len(line) for line in out.splitlines()}
        # Every rendered line (separators + rows) must be the same width.
        self.assertEqual(len(widths), 1)

    def test_thousands_separator(self):
        summary = cr.summarize([_row("EC2", "12345.67")])
        out = cr.format_table(summary)
        self.assertIn("12,345.67", out)


if __name__ == "__main__":
    unittest.main()
