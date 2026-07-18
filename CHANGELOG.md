# Changelog

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
