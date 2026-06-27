---
name: conflict-detection-before-implementation
description: Vor jeder Implementierung User Stories auf Widersprüche prüfen und den Nutzer entscheiden lassen
metadata:
  type: feedback
---

Vor dem Implementieren einer neuen User Story oder eines Features:
1. Alle bestehenden User Stories in docs/02_user_stories.md auf Konflikte mit der neuen Anforderung prüfen
2. Gefundene Widersprüche dem Nutzer explizit vorlegen (welche Stories, was genau widerspricht sich)
3. Warten bis der Nutzer den Widerspruch auflöst — erst dann implementieren

**Why:** Widersprüche, die erst im Code auffallen, erzwingen Refactoring. Der Nutzer soll die fachliche Entscheidung treffen, nicht die Implementierung.

**How to apply:** Gilt auch für subtile Konflikte (z. B. eine Story sagt "nur in Nachbearbeitung", eine andere impliziert denselben Screen im Live-Betrieb). Lieber einmal zu viel fragen als einen versteckten Widerspruch einbauen. Kombinieren mit [[user-story-before-implementation]].
