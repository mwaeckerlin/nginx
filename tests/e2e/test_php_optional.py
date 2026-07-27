"""PHP forwarding is optional: no php-fpm in the stack, everything still works.

The stack has no php-fpm service, so the default backend hostname does not
resolve. The image must start anyway (a literal hostname in fastcgi_pass is
resolved at config-parse time and would abort startup — the fastcgi_pass must
go through an nginx variable so resolution is deferred to request time), and
a request for a PHP file must simply answer 404.
"""
from conftest import BARE_URL, SPA_URL, STATIC_URL, get


def test_starts_and_serves_without_php_fpm():
    # The core invariant: with no php-fpm service in the stack, nginx is up
    # and delivers static content instead of crash-looping at startup.
    r = get(STATIC_URL, "/")
    assert r.status_code == 200
    assert "STATIC-INDEX" in r.text


def test_php_request_without_backend_returns_404():
    # A *.php request in a static app (file not on disk) answers "not found".
    r = get(STATIC_URL, "/probe.php")
    assert r.status_code == 404


def test_php_request_with_path_info_returns_404():
    # The path-info form (/x.php/extra) takes the same PHP location.
    r = get(STATIC_URL, "/probe.php/extra")
    assert r.status_code == 404


def test_php_request_in_spa_returns_404():
    # Also in SPA mode a PHP probe must 404, never break the app shell.
    r = get(SPA_URL, "/probe.php")
    assert r.status_code == 404


def test_front_controller_fallback_without_backend_returns_404():
    # No index.html and no index.php: the universal fallback chain ends at
    # /index.php, which does not exist — the answer is 404, not a crash.
    r = get(BARE_URL, "/")
    assert r.status_code == 404


def test_unknown_route_without_shell_returns_404():
    r = get(BARE_URL, "/article/42")
    assert r.status_code == 404


def test_existing_file_in_bare_app_served():
    # The bare app still delivers files that do exist.
    r = get(BARE_URL, "/other.html")
    assert r.status_code == 200
    assert "BARE-OTHER" in r.text
