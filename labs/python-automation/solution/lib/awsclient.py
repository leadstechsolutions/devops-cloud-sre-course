"""Thin boto3 wrapper.

This is the *only* place that imports boto3. Keeping the SDK behind a small
facade means the rest of the codebase (tag_audit, ec2_rightsize, cost_report)
stays pure and unit-testable: tests build plain dicts/lists and never construct a
real client.

The boto3 import is guarded so this file still passes ``python3 -m py_compile``
and so the pure-logic modules can be imported in a CI box that has no boto3 and
no network. Calling any function that actually needs boto3 without it installed
raises a clear, actionable error instead of a bare ``ModuleNotFoundError`` at
import time.
"""
from __future__ import annotations

from typing import Any, Optional

try:  # boto3 is optional: pure logic + tests must work without it.
    import boto3  # type: ignore
    from botocore.config import Config as _BotoConfig  # type: ignore

    _HAVE_BOTO3 = True
except ImportError:  # pragma: no cover - exercised only on boxes without boto3
    boto3 = None  # type: ignore
    _BotoConfig = None  # type: ignore
    _HAVE_BOTO3 = False

# Retry/backoff defaults that are sane for read-only inventory/cost tooling.
DEFAULT_REGION = "us-east-1"
_RETRY_CONFIG_KWARGS = {"retries": {"max_attempts": 5, "mode": "standard"}}


def boto3_available() -> bool:
    """Return True when boto3 is importable in this interpreter."""
    return _HAVE_BOTO3


def _require_boto3() -> None:
    if not _HAVE_BOTO3:
        raise RuntimeError(
            "boto3 is not installed. Install it with `pip install -r requirements.txt` "
            "to make live AWS calls. The pure-logic functions and the unit tests do not "
            "need boto3."
        )


def get_session(
    profile: Optional[str] = None,
    region: str = DEFAULT_REGION,
) -> "Any":
    """Return a configured ``boto3.Session``.

    Args:
        profile: Named profile from ``~/.aws/credentials`` / ``~/.aws/config``.
            ``None`` uses the default credential chain (env vars, SSO, instance
            role, etc.).
        region: AWS region to bind the session to.

    Raises:
        RuntimeError: if boto3 is not installed.
    """
    _require_boto3()
    return boto3.Session(profile_name=profile, region_name=region)


def get_client(
    service: str,
    session: Optional["Any"] = None,
    profile: Optional[str] = None,
    region: str = DEFAULT_REGION,
) -> "Any":
    """Return a boto3 client for ``service`` with retry config applied.

    A caller can pass an existing ``session`` (so one session is reused across
    several clients) or let this build one. Tests never call this; they stub the
    pure functions with hand-built data instead.
    """
    _require_boto3()
    if session is None:
        session = get_session(profile=profile, region=region)
    return session.client(service, config=_BotoConfig(**_RETRY_CONFIG_KWARGS))


def paginate(client: "Any", operation: str, result_key: str, **kwargs: "Any") -> list:
    """Drain a paginated boto3 operation into a flat list.

    Example:
        ``paginate(ec2, "describe_instances", "Reservations")``

    This isolates pagination so each CLI doesn't re-implement the token loop.
    """
    _require_boto3()
    paginator = client.get_paginator(operation)
    out: list = []
    for page in paginator.paginate(**kwargs):
        out.extend(page.get(result_key, []))
    return out
