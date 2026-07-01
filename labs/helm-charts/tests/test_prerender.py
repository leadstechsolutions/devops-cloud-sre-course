"""Unit tests for the offline Helm pre-renderer (tests/prerender.py).

These are stdlib-only (unittest + PyYAML). They prove the pre-renderer:
  * turns a valid template skeleton into valid YAML,
  * still REJECTS a template whose *static* indentation is broken (so the gate
    has teeth and is not just rubber-stamping everything),
  * preserves list nesting that a careless edit would flatten.
"""
import os
import sys
import unittest

import yaml

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import prerender  # noqa: E402

CHART = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    os.pardir,
    "solution",
    "chart",
    "webapp",
    "templates",
)


def _render(text):
    return list(yaml.safe_load_all(prerender.prerender(text)))


class PrerenderValidTemplates(unittest.TestCase):
    def test_every_solution_template_parses(self):
        names = [
            "deployment.yaml",
            "service.yaml",
            "ingress.yaml",
            "hpa.yaml",
            "configmap.yaml",
            "serviceaccount.yaml",
            os.path.join("tests", "test-connection.yaml"),
        ]
        for name in names:
            path = os.path.join(CHART, name)
            with self.subTest(template=name):
                self.assertTrue(os.path.exists(path), f"missing {path}")
                with open(path, encoding="utf-8") as fh:
                    docs = _render(fh.read())
                # Each of these renders to exactly one manifest document.
                self.assertEqual(len(docs), 1)
                self.assertIn("kind", docs[0])

    def test_deployment_keeps_container_port_nesting(self):
        with open(os.path.join(CHART, "deployment.yaml"), encoding="utf-8") as fh:
            doc = _render(fh.read())[0]
        container = doc["spec"]["template"]["spec"]["containers"][0]
        # The port list must survive as a list of one mapping with name: http.
        self.assertEqual(container["ports"][0]["name"], "http")
        # Three writable emptyDir mounts for the read-only root filesystem.
        mounts = {m["name"] for m in container["volumeMounts"]}
        self.assertEqual(mounts, {"tmp", "nginx-cache", "nginx-run"})


class PrerenderControlFlow(unittest.TestCase):
    def test_gated_template_can_render_empty(self):
        # A template wholly inside an {{- if -}} that strips to nothing is valid
        # (it renders no document) and must not raise.
        text = "{{- if .Values.x }}\napiVersion: v1\nkind: Foo\n{{- end }}\n"
        docs = _render(text)
        # Two control lines dropped; the body remains -> one doc.
        self.assertEqual(len(docs), 1)

    def test_scalar_template_becomes_placeholder(self):
        text = "metadata:\n  name: {{ .Release.Name }}\n"
        doc = _render(text)[0]
        self.assertEqual(doc["metadata"]["name"], "__TPL__")


class PrerenderCatchesBreakage(unittest.TestCase):
    def test_broken_indentation_is_rejected(self):
        # 'protocol' is indented INSIDE the scalar string of containerPort —
        # a real class of bug. After prerender this is still invalid YAML
        # (a mapping value followed by an over-indented key), so it must fail.
        broken = (
            "containers:\n"
            "  - name: app\n"
            "    ports:\n"
            "   - containerPort: 8080\n"   # under-indented list item
            "       protocol: TCP\n"
        )
        with self.assertRaises(yaml.YAMLError):
            list(yaml.safe_load_all(prerender.prerender(broken)))

    def test_check_file_returns_false_on_bad_template(self, ):
        import tempfile

        bad = "a:\n  b: 1\n   c: 2\n"  # inconsistent indent -> YAML error
        with tempfile.NamedTemporaryFile(
            "w", suffix=".yaml", delete=False
        ) as fh:
            fh.write(bad)
            name = fh.name
        try:
            self.assertFalse(prerender.check_file(name))
        finally:
            os.unlink(name)


if __name__ == "__main__":
    unittest.main()
