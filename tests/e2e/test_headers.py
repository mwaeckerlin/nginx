"""Security headers: one authoritative set on every response, including errors.

The headers are defined in conf/server.d/default.conf (server level). nginx
add_header inheritance is all-or-nothing: a server block that sets its own
add_header inherits nothing from http level, so the server block must carry
the complete set — these tests pin exactly that.
"""
from conftest import STATIC_URL, get


EXPECTED = {
    "X-Content-Type-Options": "nosniff",
    # "0" — the legacy XSS auditor is deprecated; enabling it can be abused
    # for cross-site leaks, so it is explicitly switched off (OWASP guidance)
    "X-XSS-Protection": "0",
    "X-Frame-Options": "SAMEORIGIN",
    "Referrer-Policy": "no-referrer",
    "X-Permitted-Cross-Domain-Policies": "none",
}


def test_headers_on_ok_response():
    r = get(STATIC_URL, "/")
    assert r.status_code == 200
    for name, value in EXPECTED.items():
        assert r.headers.get(name) == value, f"{name}: {r.headers.get(name)!r}"


def test_headers_on_error_response():
    # `always` flag: the headers must also be present on error pages
    # (an asset extension, because other paths intentionally fall back to the shell)
    r = get(STATIC_URL, "/does-not-exist.css")
    assert r.status_code == 404
    for name, value in EXPECTED.items():
        assert r.headers.get(name) == value, f"{name}: {r.headers.get(name)!r}"


def test_headers_not_duplicated():
    # exactly one copy of each security header (no http-level + server-level double)
    r = get(STATIC_URL, "/")
    raw = [k for k, _ in r.raw.headers.items()]
    for name in EXPECTED:
        assert raw.count(name) == 1, f"{name} appears {raw.count(name)} times"


def test_server_tokens_off():
    r = get(STATIC_URL, "/")
    server = r.headers.get("Server", "")
    assert "/" not in server, f"Server header leaks a version: {server!r}"
