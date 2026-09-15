"""An application with index.php AND index.html in its root.

Every image derived from mwaeckerlin/nginx carries the welcome page
`index.html` in `/app`, so a PHP application that copies its own files in
has both. The front controller must decide every address that matches no
file; the HTML shell answering instead made WordPress permalinks show the
welcome page with status 200 (regression 2026-09-15).

The backend host of these services resolves (the static service) and its
port 9000 is closed: a request handed to the front controller therefore
ends in the 502 maintenance page, which is the proof that it went to
php-fpm. The PHP source must never appear in an answer.
"""
from conftest import FC_NOFALLBACK_URL, FC_URL, get


def test_unknown_path_goes_to_the_front_controller():
    r = get(FC_URL, "/lokal/verkehr/klimapolitik/")
    assert r.status_code == 502
    assert "FC-SHELL" not in r.text
    assert "FC-NEVER-EXECUTED" not in r.text


def test_unknown_path_with_query_goes_to_the_front_controller():
    r = get(FC_URL, "/beitrag/42?preview=true")
    assert r.status_code == 502
    assert "FC-SHELL" not in r.text
    assert "FC-NEVER-EXECUTED" not in r.text


def test_root_goes_to_the_front_controller():
    r = get(FC_URL, "/")
    assert r.status_code == 502
    assert "FC-SHELL" not in r.text
    assert "FC-NEVER-EXECUTED" not in r.text


def test_existing_html_file_still_served():
    r = get(FC_URL, "/real.html")
    assert r.status_code == 200
    assert "FC-REAL" in r.text


def test_shell_file_is_still_addressable():
    # The shell is a file like any other and stays reachable by its name.
    r = get(FC_URL, "/index.html")
    assert r.status_code == 200
    assert "FC-SHELL" in r.text


def test_missing_asset_returns_404():
    r = get(FC_URL, "/css/missing.css")
    assert r.status_code == 404
    assert "FC-SHELL" not in r.text


def test_unknown_path_returns_404_without_fallback():
    # SPA_FALLBACK=no answers 404 before anything else is probed.
    r = get(FC_NOFALLBACK_URL, "/lokal/verkehr/klimapolitik/")
    assert r.status_code == 404
    assert "FC-SHELL" not in r.text
    assert "FC-NEVER-EXECUTED" not in r.text


def test_existing_file_still_served_without_fallback():
    r = get(FC_NOFALLBACK_URL, "/real.html")
    assert r.status_code == 200
    assert "FC-REAL" in r.text
