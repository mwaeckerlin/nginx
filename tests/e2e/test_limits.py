"""The request limits come from the environment (CLIENT_MAX_BODY_SIZE)."""
import requests

from conftest import LIMITED_URL, STATIC_URL

BODY = b"x" * 2048


def test_body_above_the_limit_is_refused():
    r = requests.post(LIMITED_URL + "/index.html", data=BODY, timeout=10)
    assert r.status_code == 413


def test_default_accepts_the_same_body():
    r = requests.post(STATIC_URL + "/index.html", data=BODY, timeout=10)
    assert r.status_code != 413
