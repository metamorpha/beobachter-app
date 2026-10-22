# Testfälle — Aufstellung während des Spiels korrigieren (US-110)

---

## Live-Screen (Widget)

### TC-1101: Button öffnet den Dialog

**Vorbedingung:** Live-Screen eines laufenden Spiels, Heim-Kader #4, #7; Gast-Kader #10.

**Aktion:** Tap auf „Aufstellung".

**Erwartetes Ergebnis:** Dialog „Aufstellung" mit den Abschnitten „Heim" und „Gast"; Chips #4, #7 (Heim) und #10 (Gast) sichtbar.

---

### TC-1102: Nummer per „+" hinzufügen

**Vorbedingung:** Dialog geöffnet, Heim-Kader #4, #7.

**Aktion:** „9" im Heim-Feld eingeben, „+" tippen.

**Erwartetes Ergebnis:** Chip #9 erscheint; `saveSquad(home)` erhält [4, 7, 9]; Eingabefeld ist leer.

---

### TC-1103: Nummer per Enter hinzufügen, sortiert

**Vorbedingung:** Dialog geöffnet, Gast-Kader #10.

**Aktion:** „3" im Gast-Feld eingeben, Enter.

**Erwartetes Ergebnis:** Gespeicherter Gast-Kader [3, 10]; Chip #3 steht vor #10.

---

### TC-1104: Ungültige Eingaben und Duplikate werden ignoriert

**Vorbedingung:** Dialog geöffnet, Heim-Kader #4.

**Aktion:** Nacheinander „0", „100", „abc" und „4" hinzufügen.

**Erwartetes Ergebnis:** Heim-Kader bleibt [4]; keine Fehlermeldung.

---

### TC-1105: Nummer entfernen

**Vorbedingung:** Dialog geöffnet, Heim-Kader #4, #7.

**Aktion:** ✕ an Chip #7.

**Erwartetes Ergebnis:** Chip #7 verschwindet; gespeicherter Heim-Kader [4].

---

### TC-1106: „Fertig" schließt den Dialog, Änderungen bleiben

**Vorbedingung:** Dialog geöffnet, #9 zu Heim hinzugefügt.

**Aktion:** „Fertig".

**Erwartetes Ergebnis:** Dialog geschlossen, Live-Screen sichtbar; gespeicherter Heim-Kader enthält #9.

---

### TC-1107: Ereignisformular zeigt neue Nummern

**Vorbedingung:** #9 zu Heim hinzugefügt, Dialog geschlossen.

**Aktion:** Tap aufs Spielfeld, Fußvergehen wählen, Täter-Team „H".

**Erwartetes Ergebnis:** Kader-Chip #9 ist im Formular sichtbar.

---

### TC-1108: Uhr und Szenen bleiben unberührt

**Vorbedingung:** Uhr läuft in der 2. HZ; eine Szene mit Täter Heim #7 erfasst.

**Aktion:** Dialog öffnen, #7 entfernen, „Fertig".

**Erwartetes Ergebnis:** Timer-Zustand unverändert (Phase, `isRunning`, Startzeitpunkt, `elapsedMs`); `updateEvent`/`deleteEvent` wurden nicht aufgerufen.

---

### TC-1109: Button im abgeschlossenen Spiel verfügbar

**Vorbedingung:** Spiel in Phase `abgeschlossen`.

**Erwartetes Ergebnis:** Button „Aufstellung" sichtbar und öffnet den Dialog.
