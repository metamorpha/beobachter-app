---
name: regression-user-stories
description: Nach jeder Implementierung alle User-Story-Akzeptanzkriterien prüfen und Checkboxen aktualisieren
metadata:
  type: feedback
---

Nach jeder Codeänderung eine Regression gegen docs/02_user_stories.md durchführen:
1. Für jede betroffene User Story alle Akzeptanzkriterien prüfen (Code lesen + ggf. App starten)
2. Checkboxen in docs/02_user_stories.md aktualisieren (neu erfüllt → [x], Regression → zurück auf [ ])
3. Regressions explizit an den Nutzer melden bevor der Task als abgeschlossen gilt

**Why:** Der Nutzer möchte lückenlosen Überblick über den Implementierungsstand. Checkboxen, die still veralten, sind wertlos.

**How to apply:** Gilt für jede Änderung an src/ — auch kleine Bugfixes können Akzeptanzkriterien brechen. Immer alle Stories durchgehen, nicht nur die offensichtlich betroffenen.
