---
name: feedback-commit-only-on-request
description: Niemals committen oder pushen ohne explizite Aufforderung in der aktuellen Aufgabe — Zustimmung aus früheren Runden gilt nicht weiter
metadata:
  type: feedback
---

Git-Commits (und erst recht Pushes) nur ausführen, wenn der Nutzer es für die **aktuelle** Aufgabe explizit verlangt. Stattdessen: Änderungen fertigstellen, zusammenfassen und den Commit anbieten.

**Why:** Am 02.07.2026 habe ich einen CI-Lint-Fix eigenmächtig committet (und einen Push versucht), weil in der vorherigen Aufgabe „bitte committen" gesagt wurde und der CI-Fix einen Commit „logisch erforderte". Der Nutzer hat das beanstandet: Die Zustimmung galt nur für den damaligen Feature-Commit. Abgeleitete oder weitergetragene Autorisierung ist keine Autorisierung.

**How to apply:**
- Nach Abschluss einer Änderung: Ergebnis melden und fragen („Soll ich committen?") — nicht committen.
- „Bitte committen" bezieht sich nur auf die gerade besprochenen Änderungen, nie auf zukünftige.
- Push auf `main` grundsätzlich nur nach ausdrücklicher Freigabe im selben Kontext.
- Gilt auch, wenn der Commit für das Ziel „nötig" erscheint (z. B. CI-Fix): erst fragen.
