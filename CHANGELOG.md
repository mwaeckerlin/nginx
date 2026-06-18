# Changelog

- 2026-06-19 **1.1.0**
    - Fehlende statische Dateien (CSS, JS, Bilder …) liefern jetzt zuverlässig 404 statt der App-Shell oder PHP-Antwort – defekte Builds bleiben dadurch nicht mehr unentdeckt
    - Sprachvarianten (`*.XX.html`) funktionieren für jede Zwei-Buchstaben-Sprache, nicht mehr nur für Deutsch und Englisch
    - Einheitliche Auslieferung für statische Dateien, SPA/PWA, PHP und Sprachvarianten: die blosse Existenz einer Datei entscheidet über den Modus, ohne Zusatzkonfiguration
    - End-to-End-Testsuite (statische Dateien, SPA, PHP, Sprachvarianten) ersetzt das frühere HTTPS-Skript
