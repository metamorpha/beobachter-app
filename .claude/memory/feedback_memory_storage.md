---
name: memory-storage-location
description: Memories dürfen nur innerhalb des Projektordners gespeichert werden
metadata:
  type: feedback
---

Alle Memory-Dateien gehören in `.claude/memory/` im Projekt-Root — niemals in `~/.claude/` oder andere Pfade außerhalb des Projekts.

**Why:** Der Nutzer möchte, dass alle projektbezogenen Daten im Projekt bleiben (Versionierbarkeit, Transparenz, kein globaler Zustand).

**How to apply:** Memory-Pfad immer `/Users/pbartoszek/projects/beobachter-app/.claude/memory/` verwenden. MEMORY.md-Index ebenfalls dort ablegen.
