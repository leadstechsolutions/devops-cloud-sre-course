"""Offline unit tests for ec2_rightsize pure logic. No AWS, no boto3."""
import unittest

import ec2_rightsize as rs


class TestThresholds(unittest.TestCase):
    def test_defaults(self):
        t = rs.Thresholds()
        self.assertEqual((t.low, t.high), (20.0, 80.0))

    def test_invalid_order_raises(self):
        with self.assertRaises(ValueError):
            rs.Thresholds(low=80, high=20)

    def test_out_of_range_raises(self):
        with self.assertRaises(ValueError):
            rs.Thresholds(low=-1, high=80)
        with self.assertRaises(ValueError):
            rs.Thresholds(low=20, high=101)


class TestRecommend(unittest.TestCase):
    def test_larger_when_cpu_hot(self):
        # peak cpu 95 >= high 80 -> larger, even though mem is cold
        self.assertEqual(rs.recommend([10, 95, 30], [5, 10, 8]), rs.LARGER)

    def test_larger_when_mem_hot(self):
        self.assertEqual(rs.recommend([10, 12], [50, 88]), rs.LARGER)

    def test_smaller_when_both_cold(self):
        # both peaks below low 20 -> smaller
        self.assertEqual(rs.recommend([5, 12, 8], [3, 15, 10]), rs.SMALLER)

    def test_keep_in_the_middle(self):
        # cpu peak 55 (between), mem peak 40 (between) -> keep
        self.assertEqual(rs.recommend([30, 55], [20, 40]), rs.KEEP)

    def test_keep_when_one_cold_one_mid(self):
        # cpu cold (peak 10 < 20) but mem mid (peak 45) -> not both cold -> keep
        self.assertEqual(rs.recommend([5, 10], [40, 45]), rs.KEEP)

    def test_boundary_high_inclusive(self):
        # peak exactly 80 == high -> larger (>= is intentional)
        self.assertEqual(rs.recommend([80], [10]), rs.LARGER)

    def test_boundary_low_exclusive(self):
        # peak exactly 20 == low -> NOT smaller (< is strict) -> keep
        self.assertEqual(rs.recommend([20], [19]), rs.KEEP)

    def test_uses_peak_not_average(self):
        # average cpu is ~5 but one spike to 90 must force larger
        self.assertEqual(rs.recommend([0, 0, 0, 90], [1, 1, 1, 1]), rs.LARGER)

    def test_custom_thresholds(self):
        t = rs.Thresholds(low=10, high=50)
        self.assertEqual(rs.recommend([45], [45], t), rs.KEEP)
        self.assertEqual(rs.recommend([55], [5], t), rs.LARGER)
        self.assertEqual(rs.recommend([5], [5], t), rs.SMALLER)

    def test_empty_samples_raise(self):
        with self.assertRaises(ValueError):
            rs.recommend([], [10])
        with self.assertRaises(ValueError):
            rs.recommend([10], [])


class TestRecommendFleet(unittest.TestCase):
    def test_fleet_actions_and_peaks(self):
        fleet = [
            {"id": "i-hot", "cpu": [10, 90], "mem": [5, 5]},
            {"id": "i-cold", "cpu": [3, 8], "mem": [4, 9]},
            {"id": "i-mid", "cpu": [40, 50], "mem": [30, 45]},
        ]
        out = rs.recommend_fleet(fleet)
        self.assertEqual(
            [(r["id"], r["action"]) for r in out],
            [("i-hot", rs.LARGER), ("i-cold", rs.SMALLER), ("i-mid", rs.KEEP)],
        )
        self.assertEqual(out[0]["cpu_peak"], 90)
        self.assertEqual(out[1]["mem_peak"], 9)


if __name__ == "__main__":
    unittest.main()
