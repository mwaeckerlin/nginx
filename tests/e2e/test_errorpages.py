"""Localized error pages and environment-based configuration."""
from conftest import DEADPHP_URL, ROOTED_URL, STATIC_URL, get


def test_error_page_404_english():
    r = get(STATIC_URL, "/css/missing.css",
            headers={"Accept-Language": "en"})
    assert r.status_code == 404
    assert "Misguided" in r.text


def test_error_page_404_german():
    r = get(STATIC_URL, "/css/missing.css",
            headers={"Accept-Language": "de-CH,de;q=0.9"})
    assert r.status_code == 404
    assert "Fehlgeleitet" in r.text


def test_unreachable_backend_returns_502_page():
    # The PHP file exists and the backend host resolves, but its port is
    # closed: the request must end in the maintenance page — the PHP source
    # must never leak, and the server must stay up.
    r = get(DEADPHP_URL, "/probe.php")
    assert r.status_code == 502
    assert "Maintenance" in r.text
    assert "NEVER-EXECUTED" not in r.text


def test_root_env_override_served():
    # ROOT=/app/sub: the substituted value must take effect at startup.
    r = get(ROOTED_URL, "/")
    assert r.status_code == 200
    assert "STATIC-SUB-INDEX" in r.text
