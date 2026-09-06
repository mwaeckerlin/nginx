"""Usage: SPA_FALLBACK decides what an address matching no file answers.

Both services below serve the very same files (apps/static); they differ
only in the setting, so every difference in the answer comes from it.
"""
from conftest import FALLBACK_NO_URL, FALLBACK_YES_URL, STATIC_URL, get


# ------------------------------------------------- SPA_FALLBACK=yes --------

def test_known_path_served_with_fallback():
    r = get(FALLBACK_YES_URL, "/about.html")
    assert r.status_code == 200
    assert "STATIC-ABOUT" in r.text


def test_unknown_path_serves_start_page_with_fallback():
    # yes: an unknown path is a client side route and gets the app shell.
    r = get(FALLBACK_YES_URL, "/some/unknown/path")
    assert r.status_code == 200
    assert "STATIC-INDEX" in r.text


# -------------------------------------------------- SPA_FALLBACK=no -------

def test_known_path_served_without_fallback():
    r = get(FALLBACK_NO_URL, "/about.html")
    assert r.status_code == 200
    assert "STATIC-ABOUT" in r.text


def test_root_served_without_fallback():
    r = get(FALLBACK_NO_URL, "/")
    assert r.status_code == 200
    assert "STATIC-INDEX" in r.text


def test_subdirectory_index_served_without_fallback():
    r = get(FALLBACK_NO_URL, "/sub/")
    assert r.status_code == 200
    assert "STATIC-SUB-INDEX" in r.text


def test_asset_served_without_fallback():
    r = get(FALLBACK_NO_URL, "/css/style.css")
    assert r.status_code == 200
    assert "STATIC-CSS-MARKER" in r.text


def test_unknown_path_returns_404_without_fallback():
    # no: a mistyped address must answer "not found", never 200 with the
    # start page — otherwise search engines index invented addresses.
    r = get(FALLBACK_NO_URL, "/some/unknown/path")
    assert r.status_code == 404
    assert "STATIC-INDEX" not in r.text
    assert "Misguided" in r.text


def test_unknown_path_404_page_localized_without_fallback():
    r = get(FALLBACK_NO_URL, "/some/unknown/path",
            headers={"Accept-Language": "de-CH,de;q=0.9"})
    assert r.status_code == 404
    assert "Fehlgeleitet" in r.text


def test_missing_asset_returns_404_without_fallback():
    r = get(FALLBACK_NO_URL, "/css/missing.css")
    assert r.status_code == 404


# ------------------------------------------------------- the default ------

def test_default_keeps_the_fallback():
    # No SPA_FALLBACK in the environment: the image answers exactly as
    # before, so upgrading a running deployment changes nothing.
    r = get(STATIC_URL, "/some/unknown/path")
    assert r.status_code == 200
    assert "STATIC-INDEX" in r.text
