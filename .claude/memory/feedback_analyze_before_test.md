---
name: feedback-analyze-before-test
description: flutter analyze nach jeder Code-Änderung ausführen — flutter test allein deckt main.dart nicht ab
metadata:
  type: feedback
---

Immer `flutter analyze` nach jeder Code-Änderung ausführen, bevor die Arbeit als fertig gemeldet wird.

**Why:** `flutter test` prüft nur Code, der von Tests erreichbar ist. `main.dart` wird von keinem Test importiert — ein Kompilierfehler dort bleibt unsichtbar. `flutter analyze` deckt alle Dateien ab und schlägt sofort an.

**How to apply:** `cd src && flutter analyze` als Pflichtschritt nach jeder Codeänderung, vor `flutter test` und vor der Fertigmeldung.
