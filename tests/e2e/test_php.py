"""Usage: PHP via php-fpm, including the HTTPS forwarding regression."""
from conftest import PHP_URL, get


def test_php_executes():
    r = get(PHP_URL, "/probe.php")
    assert r.status_code == 200
    assert r.text.strip() == "HTTPS="


def test_front_controller_fallback():
    # No matching file and no index.html -> the request reaches index.php
    # with the original URI, enabling PHP side routing (e.g. WordPress).
    r = get(PHP_URL, "/article/42")
    assert r.status_code == 200
    assert "FRONT=/article/42" in r.text


def test_static_asset_in_php_app():
    r = get(PHP_URL, "/style.css")
    assert r.status_code == 200
    assert "PHP-APP-CSS-MARKER" in r.text


def test_https_empty_on_plain_http():
    # Plain HTTP must not report HTTPS to the PHP backend.
    r = get(PHP_URL, "/probe.php")
    assert r.text.strip() == "HTTPS="


def test_https_on_with_forwarded_proto_https():
    # A reverse proxy terminating TLS signals it via X-Forwarded-Proto.
    r = get(PHP_URL, "/probe.php", headers={"X-Forwarded-Proto": "https"})
    assert r.text.strip() == "HTTPS=on"


def test_https_empty_with_forwarded_proto_http():
    # An attacker-supplied X-Forwarded-Proto: http must not downgrade nor set it.
    r = get(PHP_URL, "/probe.php", headers={"X-Forwarded-Proto": "http"})
    assert r.text.strip() == "HTTPS="
