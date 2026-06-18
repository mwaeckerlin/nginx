"""Shared fixtures: base URLs of the per-usage nginx services + readiness wait."""
import os
import time

import pytest
import requests


# ----------------------------------------------------------------- Config ---

STATIC_URL = os.environ.get("STATIC_URL", "http://static:8080")
SPA_URL    = os.environ.get("SPA_URL",    "http://spa:8080")
PHP_URL    = os.environ.get("PHP_URL",    "http://php:8080")
LANG_URL   = os.environ.get("LANG_URL",   "http://lang:8080")


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
    for url in (STATIC_URL, SPA_URL, PHP_URL, LANG_URL):
        wait_for_http(url + "/")
