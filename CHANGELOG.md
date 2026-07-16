# Changelog

- 2026-07-14 **1.2.0**
    - Das ausgelieferte Image wird neu automatisch darauf geprüft, dass es keine Shell und keine Skriptsprache enthält — wer Codeausführung im Container erreicht, findet dort kein Werkzeug vor, mit dem er weiterkommt

- 2026-06-19 **1.1.0**
    - Fehlende statische Dateien (CSS, JS, Bilder …) liefern jetzt zuverlässig 404 statt der App-Shell oder PHP-Antwort – defekte Builds bleiben dadurch nicht mehr unentdeckt
    - Sprachvarianten (`*.XX.html`) funktionieren für jede Zwei-Buchstaben-Sprache, nicht mehr nur für Deutsch und Englisch
    - Einheitliche Auslieferung für statische Dateien, SPA/PWA, PHP und Sprachvarianten: die blosse Existenz einer Datei entscheidet über den Modus, ohne Zusatzkonfiguration
    - End-to-End-Testsuite (statische Dateien, SPA, PHP, Sprachvarianten) ersetzt das frühere HTTPS-Skript
