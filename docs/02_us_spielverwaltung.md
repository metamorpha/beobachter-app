# User Stories — Epic 1: Spielverwaltung

> Fokus: minimale Interaktion pro Ereignis, so wenig Eingaben wie möglich während des Spiels.
> Gerät: Tablet, Querformat.

---

### US-101 · Neues Spiel anlegen

**Als** Schiedsrichterbeobachter  
**möchte ich** vor dem Spiel ein neues Spiel anlegen,  
**damit** alle Ereignisse diesem Spiel zugeordnet werden.

**Akzeptanzkriterien:**
- [x] Ich kann ein neues Spiel mit folgenden Feldern anlegen: Datum, Uhrzeit (Anstoß), Spielort, Heimmannschaft (Name), Gastmannschaft (Name)
- [x] Alle Felder sind optional — ich kann das Spiel auch ohne Angaben starten
- [x] Das Spiel wird sofort lokal gespeichert
- [ ] Nach dem Anlegen lande ich direkt auf dem Live-Screen (Spielfeld-Sketch + Uhr)

---

### US-102 · Aufstellungen erfassen

**Als** Schiedsrichterbeobachter  
**möchte ich** die Rückennummern beider Teams erfassen,  
**damit** ich bei der Ereigniserfassung schnell auf Spieler verweisen kann.

**Akzeptanzkriterien:**
- [x] Ich kann für jede Mannschaft eine Liste von Rückennummern (1–99) eingeben
- [x] Die Eingabe ist optional — ich kann auch ohne Aufstellung Ereignisse erfassen
- [ ] Ich kann Nummern jederzeit (auch während des Spiels) nachträglich ergänzen
- [x] Es sind keine Spielernamen erforderlich

---

### US-103 · Spieluhr starten und stoppen

**Als** Schiedsrichterbeobachter  
**möchte ich** die Spieluhr per Knopfdruck starten und stoppen,  
**damit** die aktuelle Spielzeit automatisch bei jedem Ereignis übernommen wird.

**Akzeptanzkriterien:**
- [x] Die Spieluhr ist auf dem Live-Screen dauerhaft sichtbar (große Darstellung, gut lesbar)
- [x] Ein einzelner Tap auf „Start" startet die Uhr (MM:SS, aufwärts zählend)
- [x] Ein einzelner Tap auf „Stop" pausiert die Uhr (z. B. Halbzeit, Unterbrechung)
- [x] Erneutes Tippen auf „Start" setzt die Uhr fort (kein Reset)
- [x] Die Uhr läuft auch wenn das Display kurz dunkel wird (keine Unterbrechung durch Standby)
- [x] Die aktuelle Zeit wird bei jedem neuen Ereignis automatisch als Zeitstempel übernommen

---

### US-104 · Gespeicherte Spiele aufrufen

**Als** Schiedsrichterbeobachter  
**möchte ich** eine Übersicht meiner gespeicherten Spiele sehen,  
**damit** ich nach dem Spiel auf die Ereignisse zugreifen kann.

**Akzeptanzkriterien:**
- [x] Die Startseite zeigt eine Liste aller gespeicherten Spiele (absteigend nach Datum)
- [ ] Pro Spiel werden angezeigt: Datum, Teams, Anzahl erfasster Ereignisse
- [ ] Ein Tap auf ein Spiel öffnet die Nachbearbeitungsansicht (Epic 3)
- [x] Spiele bleiben dauerhaft gespeichert bis ich sie manuell lösche

---

### US-105 · Spieldaten aus Pressebericht-CSV importieren

**Als** Schiedsrichterbeobachter  
**möchte ich** vor dem Spiel eine Pressebericht-CSV-Datei importieren,  
**damit** ich Teamnamen und Aufstellungen nicht manuell eintippen muss.

**Akzeptanzkriterien:**
- [x] Auf dem Setup-Screen gibt es einen Button „Aus Pressebericht importieren"
- [x] Ein Tap öffnet den nativen Datei-Browser (gefiltert auf `.csv`-Dateien)
- [x] Nach Auswahl einer gültigen Pressebericht-CSV (DFB/FLVW-Format, `;`-separiert) werden automatisch befüllt: Heimmannschaft, Gastmannschaft, Liga, Spieltag, Spielort, Datum sowie alle Rückennummern (Startelf S1–S11 + Auswechsler A1–A9) beider Teams
- [x] Wenn bereits Daten eingegeben wurden, erscheint ein Bestätigungs-Dialog vor dem Überschreiben
- [x] Wenn die CSV nicht vollständig erkannt werden kann, wird so viel wie möglich importiert; ein gelbes Warn-Banner listet auf, welche Felder fehlen
- [x] Wenn gar keine Teambezeichnungen erkannt werden, erscheint ein Fehler-Dialog — kein Datenverlust
- [x] Abbrechene des Datei-Browsers hinterlässt keine Änderungen
- [x] Der Import funktioniert vollständig offline (kein Netzwerk nötig)
- [x] Nach dem Import kann der Nutzer alle Felder manuell korrigieren, bevor er das Spiel startet

---

### US-106 · Spiel löschen

**Als** Schiedsrichterbeobachter  
**möchte ich** ein abgeschlossenes Spiel aus der Übersicht löschen,  
**damit** die Liste übersichtlich bleibt und nicht mehr relevante Spiele nach dem Coaching nicht dauerhaft gespeichert sind.

**Akzeptanzkriterien:**
- [ ] Jede Spielkachel in der Übersicht zeigt ein Löschen-Icon (🗑), das ohne Swipe-Geste sichtbar ist
- [ ] Ein Tap auf das Icon öffnet einen Bestätigungs-Dialog mit Spielname und Warnung vor unwiderruflichem Datenverlust
- [ ] Der Dialog bietet „Abbrechen" (kein Effekt) und „Löschen" (rot hervorgehoben)
- [ ] Nach Bestätigung wird das Spiel mit allen zugehörigen Ereignissen, Aufstellungen und Timer-Daten gelöscht
- [ ] Die Kachel verschwindet sofort aus der Liste; andere Spiele bleiben unverändert
- [ ] Wird das letzte Spiel gelöscht, erscheint der Leer-Hinweis „Noch keine Spiele erfasst."
- [ ] Bei Spielen ohne Teamnamen zeigt der Dialog „Unbenanntes Spiel"
- [ ] Ein Tap auf Spielname oder Chevron (›) öffnet das Spiel — kein Löschen-Dialog
