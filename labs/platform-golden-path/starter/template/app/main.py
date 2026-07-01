"""__SERVICE_NAME__ — STARTER. Complete the TODOs.

A stdlib-only HTTP service. Your job is to finish the readiness logic and the
root payload so the provided tests pass.
"""
from __future__ import annotations

import json
import os
import threading
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any

SERVICE_NAME = os.environ.get("SERVICE_NAME", "__SERVICE_NAME__")
PORT = int(os.environ.get("PORT", "8080"))

_ready = threading.Event()
_ready.set()


def build_payload() -> dict[str, Any]:
    # TODO: return a dict with at least "service" (the SERVICE_NAME) and a
    # "message" key. The tests assert both are present and that the body
    # contains "hello from the golden path".
    raise NotImplementedError


class Handler(BaseHTTPRequestHandler):
    server_version = "__SERVICE_NAME__/1.0"

    def _send_json(self, status: int, body: dict[str, Any]) -> None:
        payload = json.dumps(body).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self) -> None:  # noqa: N802
        if self.path == "/healthz":
            self._send_json(HTTPStatus.OK, {"status": "ok"})
        elif self.path == "/readyz":
            # TODO: return 200 {"status":"ready"} when _ready is set, else
            # 503 {"status":"draining"}.
            raise NotImplementedError
        elif self.path == "/":
            self._send_json(HTTPStatus.OK, build_payload())
        else:
            self._send_json(HTTPStatus.NOT_FOUND, {"error": "not found"})


def make_server() -> ThreadingHTTPServer:
    return ThreadingHTTPServer(("", PORT), Handler)


def main() -> None:
    httpd = make_server()
    # TODO: install SIGTERM/SIGINT handlers that clear _ready and shut the
    # server down gracefully (see solution).
    httpd.serve_forever()


if __name__ == "__main__":
    main()
