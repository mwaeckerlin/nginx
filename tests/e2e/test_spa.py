"""Usage: single page app / PWA with client side routing."""
from conftest import SPA_URL, get


def test_root_serves_shell():
    r = get(SPA_URL, "/")
    assert r.status_code == 200
    assert "SPA-SHELL-EN" in r.text


def test_deep_route_serves_shell():
    # A reload on a client side route must return the app shell, not 404.
    r = get(SPA_URL, "/wallets/123")
    assert r.status_code == 200
    assert "SPA-SHELL-EN" in r.text


def test_real_asset_served():
    r = get(SPA_URL, "/assets/app.js")
    assert r.status_code == 200
    assert "SPA-ASSET-MARKER" in r.text


def test_missing_asset_returns_404():
    # A broken asset reference must surface as 404, not as the HTML shell.
    r = get(SPA_URL, "/assets/missing.js")
    assert r.status_code == 404


def test_language_shell_selected_by_accept_language():
    r = get(SPA_URL, "/wallets/123",
            headers={"Accept-Language": "de-CH,de;q=0.9"})
    assert r.status_code == 200
    assert "SPA-SHELL-DE" in r.text
