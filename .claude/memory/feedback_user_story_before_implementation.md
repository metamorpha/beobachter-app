---
name: user-story-before-implementation
description: Verpflichtende Reihenfolge für jedes neue Feature — US zuerst, dann UX, dann Tests, dann Code
metadata:
  type: feedback
---

Bei neuen Features immer in dieser Reihenfolge vorgehen — keine Ausnahmen:

1. **User Story** schreiben (inkl. Akzeptanzkriterien) in `docs/02_user_stories.md`, dem Nutzer zeigen und Bestätigung abwarten
2. **UX Flow** ergänzen in `docs/04_ux_design.md`
3. **Testfälle** schreiben in `docs/NN_<feature>_tests.md`
4. **Implementierung** — erst wenn Schritte 1–3 abgeschlossen und bestätigt sind
5. **Abnahme** — nach der Implementierung alle Akzeptanzkriterien prüfen und Checkboxen in `docs/02_user_stories.md` aktualisieren

**Why:** User Stories, die nach der Implementierung geschrieben werden, passen sich unbewusst an das an, was gebaut wurde — nicht an das, was gebraucht wird. Der Tester prüft dann gegen falsche Kriterien. Außerdem: Implementierungsangebote vor fertiger US (wie beim Spiel-Löschen-Feature passiert) umgehen die Abstimmung und können zu unnötigem Rework führen.

**How to apply:** Sobald ein Nutzer „implementiere Feature X" sagt — zuerst prüfen, ob eine US in `docs/02_user_stories.md` existiert. Wenn nicht: US schreiben, zeigen, dann erst implementieren. Auch wenn ein UX-Dokument bereits existiert, ersetzt es nicht die formale User Story mit Akzeptanzkriterien. Die Regel steht auch in `CLAUDE.md` unter „Feature Development Rules".
