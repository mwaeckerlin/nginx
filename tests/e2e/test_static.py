"""Usage: plain serving of local files."""
from conftest import STATIC_URL, get


def test_root_index_served():
    r = get(STATIC_URL, "/")
    assert r.status_code == 200
    assert "STATIC-INDEX" in r.text


def test_named_html_file():
    r = get(STATIC_URL, "/about.html")
    assert r.status_code == 200
    assert "STATIC-ABOUT" in r.text


def test_css_asset_served():
    r = get(STATIC_URL, "/css/style.css")
    assert r.status_code == 200
    assert "STATIC-CSS-MARKER" in r.text


def test_subdirectory_index():
    r = get(STATIC_URL, "/sub/")
    assert r.status_code == 200
    assert "STATIC-SUB-INDEX" in r.text


def test_missing_asset_returns_404():
    # A missing static asset must 404, never fall back to the app shell.
    r = get(STATIC_URL, "/css/missing.css")
    assert r.status_code == 404


def test_unknown_path_falls_back_to_index():
    # Universal behaviour: an unknown navigation path serves the index shell
    # so the same image also works for client side routed apps.
    r = get(STATIC_URL, "/some/unknown/path")
    assert r.status_code == 200
    assert "STATIC-INDEX" in r.text
