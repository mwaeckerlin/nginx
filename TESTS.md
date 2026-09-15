# Tests

Register of all tests, grouped by kind and sorted by the
[FEATURES.md](FEATURES.md) number each test covers. `npm test` runs
everything; the guard `tests/docs-contract.sh` fails when a feature has no
test entry here or when any test carries a skip/xfail marker — tests are
never skipped.

The e2e stack (`tests/e2e/`) deliberately contains **no php-fpm service**:
the nginx suite runs entirely without PHP. The nginx+php-fpm combination
(F5, F7) is tested end-to-end in the php-fpm project, which consumes this
image.

## E2E — Backend/API (pytest against the real compose stack)

- **F1** `tests/e2e/test_static.py` › test_root_index_served — the root `index.html` is delivered.
- **F1** `tests/e2e/test_static.py` › test_named_html_file — a named HTML file is delivered.
- **F1** `tests/e2e/test_static.py` › test_css_asset_served — an asset in a subdirectory is delivered.
- **F1** `tests/e2e/test_static.py` › test_subdirectory_index — a subdirectory index is delivered.
- **F1** `tests/e2e/test_front_controller.py` › test_existing_html_file_still_served — a named HTML file is delivered beside a front controller.
- **F1** `tests/e2e/test_front_controller.py` › test_shell_file_is_still_addressable — `index.html` stays reachable by its own name beside a front controller.
- **F2** `tests/e2e/test_spa.py` › test_root_serves_shell — the app shell is served at the root.
- **F2** `tests/e2e/test_spa.py` › test_deep_route_serves_shell — a reload on a client side route returns the shell, not 404.
- **F2** `tests/e2e/test_spa.py` › test_real_asset_served — a real asset is served, not the shell.
- **F2** `tests/e2e/test_static.py` › test_unknown_path_falls_back_to_index — an unknown navigation path serves the shell.
- **F3** `tests/e2e/test_static.py` › test_missing_asset_returns_404 — a missing asset answers 404, never the shell.
- **F3** `tests/e2e/test_spa.py` › test_missing_asset_returns_404 — a missing SPA asset answers 404, never the shell.
- **F3** `tests/e2e/test_front_controller.py` › test_missing_asset_returns_404 — a missing asset answers 404 beside a front controller, never the shell.
- **F4** `tests/e2e/test_lang.py` › test_default_when_no_variant_matches — no matching variant falls through to the neutral file.
- **F4** `tests/e2e/test_lang.py` › test_german_index_variant — `index.de.html` selected for German.
- **F4** `tests/e2e/test_lang.py` › test_french_index_variant — `index.fr.html` selected for French (any two-letter code works).
- **F4** `tests/e2e/test_lang.py` › test_page_language_variant — `page.de.html`/`page.en.html` selected per language.
- **F4** `tests/e2e/test_lang.py` › test_unknown_language_falls_back_to_default_page — unknown language serves the neutral page.
- **F4** `tests/e2e/test_spa.py` › test_language_shell_selected_by_accept_language — the localized app shell is selected.
- **F5** `tests/e2e/test_front_controller.py` › test_unknown_path_goes_to_the_front_controller — with `index.php` beside `index.html` an unknown address reaches the front controller (502 from the closed backend), never the shell and never the PHP source (regression: every permalink answered 200 with the welcome page).
- **F5** `tests/e2e/test_front_controller.py` › test_unknown_path_with_query_goes_to_the_front_controller — the same with a query string, which must not turn the front controller into a file probe.
- **F5** `tests/e2e/test_front_controller.py` › test_root_goes_to_the_front_controller — the root is answered by the front controller, not by the shell beside it.
- **F6** `tests/e2e/test_php_optional.py` › test_starts_and_serves_without_php_fpm — the stack has no php-fpm service and nginx still starts and serves (regression: literal backend hostname aborted startup with "host not found").
- **F6** `tests/e2e/test_php_optional.py` › test_php_request_without_backend_returns_404 — a PHP request without backend answers 404.
- **F6** `tests/e2e/test_php_optional.py` › test_php_request_with_path_info_returns_404 — the path-info form answers 404 as well.
- **F6** `tests/e2e/test_php_optional.py` › test_php_request_in_spa_returns_404 — a PHP probe in SPA mode answers 404.
- **F6** `tests/e2e/test_php_optional.py` › test_front_controller_fallback_without_backend_returns_404 — no shell, no front controller: 404, no crash.
- **F6** `tests/e2e/test_php_optional.py` › test_unknown_route_without_shell_returns_404 — unknown route in a bare app answers 404.
- **F6** `tests/e2e/test_php_optional.py` › test_existing_file_in_bare_app_served — the bare app still delivers existing files.
- **F6** `tests/e2e/test_errorpages.py` › test_unreachable_backend_returns_502_page — backend resolvable but port closed: 502 page, no source leak, server stays up.
- **F8** `tests/e2e/test_headers.py` › test_headers_on_ok_response — the complete header set on a 200 response.
- **F8** `tests/e2e/test_headers.py` › test_headers_on_error_response — the complete header set on an error response.
- **F8** `tests/e2e/test_headers.py` › test_headers_not_duplicated — exactly one copy of each header.
- **F8** `tests/e2e/test_headers.py` › test_server_tokens_off — the server version is not revealed.
- **F9** `tests/e2e/test_errorpages.py` › test_error_page_404_english — the friendly English 404 page is served.
- **F9** `tests/e2e/test_errorpages.py` › test_error_page_404_german — the German 404 variant is selected via `Accept-Language`.
- **F9** `tests/e2e/test_errorpages.py` › test_unreachable_backend_returns_502_page — the friendly 502 maintenance page is served.
- **F10** `tests/e2e/test_errorpages.py` › test_root_env_override_served — `ROOT=/app/sub` takes effect at container start.
- **F12** `tests/e2e/test_spa_fallback.py` › test_known_path_served_with_fallback — `SPA_FALLBACK=yes`: an existing file is delivered.
- **F12** `tests/e2e/test_spa_fallback.py` › test_unknown_path_serves_start_page_with_fallback — `SPA_FALLBACK=yes`: an unknown path answers 200 with the start page.
- **F12** `tests/e2e/test_spa_fallback.py` › test_known_path_served_without_fallback — `SPA_FALLBACK=no`: an existing file is delivered.
- **F12** `tests/e2e/test_spa_fallback.py` › test_root_served_without_fallback — `SPA_FALLBACK=no`: the root still serves the start page.
- **F12** `tests/e2e/test_spa_fallback.py` › test_subdirectory_index_served_without_fallback — `SPA_FALLBACK=no`: a subdirectory index is still delivered.
- **F12** `tests/e2e/test_spa_fallback.py` › test_asset_served_without_fallback — `SPA_FALLBACK=no`: an existing asset is still delivered.
- **F12** `tests/e2e/test_spa_fallback.py` › test_unknown_path_returns_404_without_fallback — `SPA_FALLBACK=no`: an unknown path answers 404 with the error page, never the start page.
- **F12** `tests/e2e/test_spa_fallback.py` › test_unknown_path_404_page_localized_without_fallback — `SPA_FALLBACK=no`: the 404 page follows `Accept-Language`.
- **F12** `tests/e2e/test_spa_fallback.py` › test_missing_asset_returns_404_without_fallback — `SPA_FALLBACK=no`: a missing asset answers 404.
- **F12** `tests/e2e/test_front_controller.py` › test_unknown_path_returns_404_without_fallback — `SPA_FALLBACK=no` answers 404 before the front controller is probed.
- **F12** `tests/e2e/test_front_controller.py` › test_existing_file_still_served_without_fallback — `SPA_FALLBACK=no` still delivers existing files beside a front controller.
- **F12** `tests/e2e/test_spa_fallback.py` › test_default_keeps_the_fallback — without the variable the image answers as before: unknown path 200 with the start page.
- **F10** `tests/e2e/test_errorpages.py` › test_unreachable_backend_returns_502_page — `PHP_FPM_HOST` override reaches the FastCGI config.

## E2E — cross-project (php-fpm project, runs against this image)

- **F5** `tests/e2e/test_php.py` (php-fpm project) › test_php_executes, test_front_controller_fallback, test_static_asset_in_php_app, test_missing_php_file_returns_404 — PHP execution and front controller routing through the real FastCGI pairing.
- **F7** `tests/e2e/test_php.py` (php-fpm project) › test_https_empty_on_plain_http, test_https_on_with_forwarded_proto_https, test_https_empty_with_forwarded_proto_http — spoof-safe HTTPS signalling.

## Image-/Compose-Contract-Tests

- **F11** `tests/image-contract.sh` › no sh, no bash, no busybox, no perl — the shipped image is headless.
