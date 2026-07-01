"""Unit tests for the Flask app — run by the pytest gate in ci.yml.

Run from the repository root: `pytest -q`. The `app/__init__.py` package
marker makes `from app.main import ...` resolve without a conftest hack.
"""
from app.main import add, app


def test_add() -> None:
    assert add(2, 3) == 5
    assert add(-1, 1) == 0


def test_health_endpoint_status() -> None:
    client = app.test_client()
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "ok"


def test_health_endpoint_reports_version() -> None:
    client = app.test_client()
    body = client.get("/health").get_json()
    assert "version" in body
    assert body["version"].count(".") == 2  # semver-ish: MAJOR.MINOR.PATCH
