# Changelog

- 2026-09-15 **1.3.3**
    - PHP applications whose image carries a start page in the web root are reachable again under every address: since June a WordPress permalink and every other routed address answered with the welcome page of this image instead of the application, because the static start page was consulted before the application's own entry point. The entry point now decides every address it is there for, and answers "not found" for one it does not know
        - a purely static or single page application is untouched: where the web root holds no entry point, the start page answers as before, and the setting for a static website keeps answering "not found"
    - The case is measured end to end for the first time: a service whose web root holds both files, with and without the start page fallback

- 2026-09-06 **1.3.2**
    - An address that matches no file can now answer "not found" instead of the start page: that is the right behaviour for a static website, where a typing error in the address otherwise answers with the start page and search engines index every invented address as a valid page
        - the previous behaviour stays the default, so no running installation changes on an update, and a single page application keeps its deep links and reloads
    - Both settings are measured end to end on the same files: existing address delivered, unknown address the start page in one and the localized "not found" page in the other

- 2026-07-27 **1.3.1**
    - PHP forwarding is optional again: the image starts and serves even when no PHP backend exists in the stack — since the environment-variable rework of January it aborted at startup with "host not found", which broke deployments of purely static sites
        - a PHP request without a backend now answers "not found"; a configured but unreachable backend shows the maintenance page instead of taking the server down
    - The test suite now runs entirely without PHP and pins exactly this: startup without a backend, "not found" for PHP requests, localized error pages and configuration through environment variables — the PHP combination tests moved to the php-fpm project, which tests both images together
    - Feature and test registers added (FEATURES.md, TESTS.md) with an automatic guard: every feature must have a test, and no test may be skipped

- 2026-07-17 **1.3.0**
    - Security headers consolidated and automatically tested: the complete set now lives in one place — previously, centrally defined headers (e.g. the clickjacking protection) were silently lost because of nginx's all-or-nothing header inheritance
        - clickjacking protection (embedding only from the site itself) is now effective for the first time
        - the deprecated browser XSS auditor is now explicitly disabled (it can be abused for cross-site leaks)
        - new end-to-end tests pin every header, including on error pages
    - TLS policy modernized to the Mozilla "intermediate" profile: only modern authenticated encryption, current curves, the client picks the best suite; OCSP stapling removed (it was silently ineffective without a resolver, and Let's Encrypt has discontinued OCSP)
    - The error log no longer runs in debug mode in production (less data exposure and log flooding); the verbose debug log format now carries a warning because it records request contents
    - Image build completes without warnings; example and default page corrected
    - README states the role explicitly: runtime image for the final build stage, never a build image

- 2026-07-14 **1.2.0**
    - The shipped image is now automatically verified to contain no shell and no scripting language — an attacker who reaches code execution in the container finds no tool to pivot with

- 2026-06-19 **1.1.0**
    - Missing static files (CSS, JS, images …) now reliably return 404 instead of the app shell or a PHP response — broken builds no longer stay undetected
    - Language variants (`*.XX.html`) work for any two-letter language, no longer only German and English
    - Unified delivery for static files, SPA/PWA, PHP and language variants: the mere existence of a file decides the mode, with no extra configuration
    - End-to-end test suite (static files, SPA, PHP, language variants) replaces the former HTTPS script
