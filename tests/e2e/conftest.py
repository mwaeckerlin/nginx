"""Shared fixtures: base URLs of the per-usage nginx services + readiness wait.

The whole stack intentionally runs WITHOUT any php-fpm service: the readiness
wait therefore already pins the invariant that the image starts and serves
even when the default FastCGI backend hostname does not resolve.
"""
import os
import time

import pytest
import requests


# ----------------------------------------------------------------- Config ---

STATIC_URL  = os.environ.get("STATIC_URL",  "http://static:8080")
SPA_URL     = os.environ.get("SPA_URL",     "http://spa:8080")
LANG_URL    = os.environ.get("LANG_URL",    "http://lang:8080")
BARE_URL    = os.environ.get("BARE_URL",    "http://bare:8080")
DEADPHP_URL = os.environ.get("DEADPHP_URL", "http://deadphp:8080")
ROOTED_URL  = os.environ.get("ROOTED_URL",  "http://rooted:8080")


# ----------------------------------------------------------- Helpers -------

def wait_for_http(url: str, timeout: int = 60) -> None:
    """Wait until the server answers at all (any HTTP status counts as up)."""
    deadline = time.time() + timeout
    last = None
    while time.time() < deadline:
        try:
            requests.get(url, timeout=2)
            return
        except requests.RequestException as exc:  # connection refused / reset
            last = exc
            time.sleep(1)
    raise TimeoutError(f"{url} did not become ready within {timeout}s: {last}")


def get(url: str, path: str, **kwargs) -> requests.Response:
    return requests.get(url + path, timeout=10, **kwargs)


# --------------------------------------------------------- Fixtures --------

@pytest.fixture(scope="session", autouse=True)
def wait_for_services():
    for url in (STATIC_URL, SPA_URL, LANG_URL, BARE_URL, DEADPHP_URL,
                ROOTED_URL):
        wait_for_http(url + "/")
