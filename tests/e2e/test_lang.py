"""Usage: language detection and *.XX.* variant selection."""
import pytest
from conftest import LANG_URL, get


def test_default_when_no_variant_matches():
    # English has no index.en.html -> falls through to the plain default.
    r = get(LANG_URL, "/", headers={"Accept-Language": "en"})
    assert r.status_code == 200
    assert "LANG-DEFAULT" in r.text


def test_german_index_variant():
    r = get(LANG_URL, "/", headers={"Accept-Language": "de-CH,de;q=0.9"})
    assert r.status_code == 200
    assert "LANG-DE" in r.text


def test_french_index_variant():
    r = get(LANG_URL, "/", headers={"Accept-Language": "fr-FR,fr;q=0.9"})
    assert r.status_code == 200
    assert "LANG-FR" in r.text


@pytest.mark.parametrize("accept,marker", [
    ("de", "PAGE-DE"),
    ("en", "PAGE-EN"),
])
def test_page_language_variant(accept, marker):
    r = get(LANG_URL, "/page", headers={"Accept-Language": accept})
    assert r.status_code == 200
    assert marker in r.text


def test_unknown_language_falls_back_to_default_page():
    # Italian has no page.it.html -> serves the language neutral page.html.
    r = get(LANG_URL, "/page", headers={"Accept-Language": "it"})
    assert r.status_code == 200
    assert "PAGE-DEFAULT" in r.text
