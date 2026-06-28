# Testfälle — US-210 / US-211: Spielphasen-Steuerung mit Nachspielzeit und Verlängerung

> Abgedeckte User Stories: US-210 (Halbzeit, Nachspielzeit), US-211 (Verlängerung)
> Gerät: Tablet, Querformat

---

## Gruppe A — Zeitanzeige: 1. Halbzeit

### TC-1301 · Timer startet bei 0:00

**Vorbedingung:** Neues Spiel angelegt; Live-Screen geöffnet; Timer noch nicht gestartet  
**Aktion:** — (Beobachtung ohne Interaktion)  
**Erwartetes Ergebnis:** Timer zeigt `00:00`; Phase-Label ist leer oder „Bereit"; Button `▶ Start` sichtbar  
**Kriterium:** US-210 AK 1. HZ

---

### TC-1302 · Timer-Anzeige läuft in MM:SS während 1. HZ

**Vorbedingung:** 1. Halbzeit läuft, Timer bei ca. 23:00  
**Aktion:** 45 Sekunden abwarten  
**Erwartetes Ergebnis:** Anzeige wechselt von `23:00` → `23:45` im Format `MM:SS`; Phase-Label zeigt „1. Halbzeit"  
**Kriterium:** US-210 AK 1. HZ

---

### TC-1303 · Automatischer Wechsel in Nachspielzeit bei 45:00

**Vorbedingung:** 1. Halbzeit läuft  
**Aktion:** Timer erreicht 45:00  
**Erwartetes Ergebnis:** Anzeige wechselt unmittelbar von `44:59` → `45+01`; Phase-Label wechselt auf „Nachspielzeit"; kein User-Eingriff nötig  
**Kriterium:** US-210 AK 1. HZ, Nachspielzeit

---

### TC-1304 · Nachspielzeit 1. HZ zählt korrekt hoch

**Vorbedingung:** Nachspielzeit 1. HZ läuft, Anzeige bei `45+01`  
**Aktion:** 60 Sekunden abwarten  
**Erwartetes Ergebnis:** Anzeige zeigt `45+02`; Hochzählen bleibt konsistent  
**Kriterium:** US-210 AK Nachspielzeit

---

## Gruppe B — Halbzeit-Button und Pausen-Verhalten

### TC-1305 · „Halbzeit"-Button sichtbar während 1. HZ

**Vorbedingung:** 1. Halbzeit läuft (beliebige Zeit < 45:00)  
**Aktion:** Live-Screen betrachten  
**Erwartetes Ergebnis:** Button `⏸ Halbzeit` ist im Header sichtbar und tappbar; kein anderer Phasen-Button ist gleichzeitig sichtbar  
**Kriterium:** US-210 AK Halbzeitpause

---

### TC-1306 · „Halbzeit"-Button sichtbar während 1. HZ Nachspielzeit

**Vorbedingung:** Nachspielzeit 1. HZ läuft (z. B. Anzeige `45+02`)  
**Aktion:** Live-Screen betrachten  
**Erwartetes Ergebnis:** Button `⏸ Halbzeit` bleibt sichtbar; Phase-Label zeigt „Nachspielzeit"  
**Kriterium:** US-210 AK Halbzeitpause

---

### TC-1307 · Tap auf „Halbzeit" stoppt den Timer

**Vorbedingung:** Nachspielzeit 1. HZ läuft, Anzeige z. B. `45+03`  
**Aktion:** Button `⏸ Halbzeit` antippen  
**Erwartetes Ergebnis:** Timer friert bei aktuellem Wert ein; Phase-Label wechselt auf „Halbzeitpause"; Button wechselt zu `▶ 2. HZ starten`  
**Kriterium:** US-210 AK Halbzeitpause

---

### TC-1308 · „Halbzeit"-Button NICHT sichtbar in Pause

**Vorbedingung:** Halbzeitpause aktiv  
**Aktion:** Live-Screen betrachten  
**Erwartetes Ergebnis:** Button `⏸ Halbzeit` ist nicht sichtbar; Button `▶ 2. HZ starten` ist sichtbar  
**Kriterium:** US-210 AK Halbzeitpause

---

## Gruppe C — Zeitanzeige: 2. Halbzeit

### TC-1309 · 2. HZ startet bei 45:00 (nicht 0:00)

**Vorbedingung:** Halbzeitpause aktiv  
**Aktion:** Button `▶ 2. HZ starten` antippen  
**Erwartetes Ergebnis:** Timer startet bei `45:00` und läuft hoch; Phase-Label zeigt „2. Halbzeit"; Button wechselt zu `⏸ Abpfiff`  
**Kriterium:** US-210 AK 2. HZ

---

### TC-1310 · Timer-Anzeige läuft in MM:SS während 2. HZ

**Vorbedingung:** 2. Halbzeit läuft, Timer bei ca. 67:00  
**Aktion:** 30 Sekunden abwarten  
**Erwartetes Ergebnis:** Anzeige wechselt von `67:00` → `67:30` im Format `MM:SS`  
**Kriterium:** US-210 AK 2. HZ

---

### TC-1311 · Automatischer Wechsel in Nachspielzeit bei 90:00

**Vorbedingung:** 2. Halbzeit läuft  
**Aktion:** Timer erreicht 90:00  
**Erwartetes Ergebnis:** Anzeige wechselt unmittelbar von `89:59` → `90+01`; Phase-Label wechselt auf „Nachspielzeit"  
**Kriterium:** US-210 AK 2. HZ, Nachspielzeit

---

### TC-1312 · Tap auf „Abpfiff" stoppt den Timer

**Vorbedingung:** Nachspielzeit 2. HZ läuft, Anzeige z. B. `90+04`  
**Aktion:** Button `⏸ Abpfiff` antippen  
**Erwartetes Ergebnis:** Timer friert ein; Phase-Label wechselt auf „Beendet"; Button wechselt zu `▶ Verlängerung`  
**Kriterium:** US-210 AK Spielende

---

## Gruppe D — Ereignis-Zeitstempel

### TC-1313 · Ereignis-Zeitstempel in regulärer Spielzeit (MM:SS)

**Vorbedingung:** 1. Halbzeit läuft, Timer bei z. B. `23:45`  
**Aktion:** Tap auf Spielfeld → Ereignis erfassen und speichern  
**Erwartetes Ergebnis:** Ereignis zeigt in Szenenliste und Formular den Zeitstempel `23:45`  
**Kriterium:** US-210 AK Ereignis-Zeitstempel

---

### TC-1314 · Ereignis-Zeitstempel in 1. HZ Nachspielzeit (45+X)

**Vorbedingung:** Nachspielzeit 1. HZ läuft, Anzeige bei `45+02`  
**Aktion:** Tap auf Spielfeld → Ereignis erfassen und speichern  
**Erwartetes Ergebnis:** Ereignis zeigt Zeitstempel `45+02` (nicht `47:00` o. ä.)  
**Kriterium:** US-210 AK Ereignis-Zeitstempel

---

### TC-1315 · Ereignis-Zeitstempel in 2. HZ Nachspielzeit (90+X)

**Vorbedingung:** Nachspielzeit 2. HZ läuft, Anzeige bei `90+03`  
**Aktion:** Tap auf Spielfeld → Ereignis erfassen und speichern  
**Erwartetes Ergebnis:** Ereignis zeigt Zeitstempel `90+03`  
**Kriterium:** US-210 AK Ereignis-Zeitstempel

---

### TC-1316 · Zeitstempel im Ereignisformular wird live aktualisiert

**Vorbedingung:** 1. Halbzeit läuft; Ereignisformular noch geöffnet nach Tap auf Spielfeld  
**Aktion:** Formular 30 Sekunden lang offen lassen ohne zu speichern  
**Erwartetes Ergebnis:** Der im Formular angezeigte Zeitstempel bleibt auf dem Wert zum Tap-Zeitpunkt eingefroren (kein Live-Update nach dem Öffnen)  
**Kriterium:** US-201 AK + US-210 AK Ereignis-Zeitstempel

---

## Gruppe E — Verlängerung (US-211)

### TC-1317 · „Verlängerung"-Button erscheint nach Abpfiff

**Vorbedingung:** Reguläres Spielende erreicht (Status „Beendet")  
**Aktion:** Live-Screen betrachten  
**Erwartetes Ergebnis:** Button `▶ Verlängerung` ist sichtbar; kein laufender Timer  
**Kriterium:** US-211 AK VL 1. HZ

---

### TC-1318 · „Verlängerung"-Button NICHT sichtbar während laufendem Spiel

**Vorbedingung:** 2. Halbzeit läuft  
**Aktion:** Live-Screen betrachten  
**Erwartetes Ergebnis:** Button `▶ Verlängerung` ist nicht sichtbar  
**Kriterium:** US-211 AK VL 1. HZ

---

### TC-1319 · Verlängerung 1. HZ startet bei 90:00

**Vorbedingung:** Status „Beendet" nach regulärer Spielzeit  
**Aktion:** Button `▶ Verlängerung` antippen  
**Erwartetes Ergebnis:** Timer startet bei `90:00` und läuft hoch; Phase-Label zeigt „Verl. 1. HZ"; Button wechselt zu `⏸ HZ (Verl.)`  
**Kriterium:** US-211 AK VL 1. HZ

---

### TC-1320 · Automatischer Wechsel in VL Nachspielzeit bei 105:00

**Vorbedingung:** Verlängerung 1. HZ läuft  
**Aktion:** Timer erreicht 105:00  
**Erwartetes Ergebnis:** Anzeige wechselt von `104:59` → `105+01`; Phase-Label wechselt auf „Nachspielzeit"  
**Kriterium:** US-211 AK VL 1. HZ

---

### TC-1321 · Tap auf „HZ (Verl.)" stoppt den Timer

**Vorbedingung:** Verlängerung 1. HZ Nachspielzeit läuft, Anzeige bei `105+02`  
**Aktion:** Button `⏸ HZ (Verl.)` antippen  
**Erwartetes Ergebnis:** Timer friert ein; Phase-Label wechselt auf „Verl. Halbzeit"; Button wechselt zu `▶ 2. Verl. starten`  
**Kriterium:** US-211 AK VL 1. HZ

---

### TC-1322 · Verlängerung 2. HZ startet bei 105:00

**Vorbedingung:** Halbzeitpause der Verlängerung aktiv  
**Aktion:** Button `▶ 2. Verl. starten` antippen  
**Erwartetes Ergebnis:** Timer startet bei `105:00` und läuft hoch; Phase-Label zeigt „Verl. 2. HZ"; Button wechselt zu `⏸ Abpfiff (Verl.)`  
**Kriterium:** US-211 AK VL 2. HZ

---

### TC-1323 · Automatischer Wechsel in VL 2. HZ Nachspielzeit bei 120:00

**Vorbedingung:** Verlängerung 2. HZ läuft  
**Aktion:** Timer erreicht 120:00  
**Erwartetes Ergebnis:** Anzeige wechselt von `119:59` → `120+01`; Phase-Label wechselt auf „Nachspielzeit"  
**Kriterium:** US-211 AK VL 2. HZ

---

### TC-1324 · Tap auf „Abpfiff (Verl.)" beendet das Spiel endgültig

**Vorbedingung:** Verlängerung 2. HZ Nachspielzeit läuft, Anzeige bei `120+03`  
**Aktion:** Button `⏸ Abpfiff (Verl.)` antippen  
**Erwartetes Ergebnis:** Timer friert ein; Phase-Label zeigt „Beendet"; kein weiterer Phasen-Button sichtbar  
**Kriterium:** US-211 AK VL 2. HZ

---

### TC-1325 · Ereignis-Zeitstempel in VL 1. HZ (MM:SS)

**Vorbedingung:** Verlängerung 1. HZ läuft, Timer bei `97:30`  
**Aktion:** Tap auf Spielfeld → Ereignis speichern  
**Erwartetes Ergebnis:** Ereignis zeigt Zeitstempel `97:30`  
**Kriterium:** US-211 AK Zeitstempel

---

### TC-1326 · Ereignis-Zeitstempel in VL 1. HZ Nachspielzeit (105+X)

**Vorbedingung:** VL 1. HZ Nachspielzeit läuft, Anzeige bei `105+02`  
**Aktion:** Tap auf Spielfeld → Ereignis speichern  
**Erwartetes Ergebnis:** Ereignis zeigt Zeitstempel `105+02`  
**Kriterium:** US-211 AK Zeitstempel

---

### TC-1327 · Ereignis-Zeitstempel in VL 2. HZ Nachspielzeit (120+X)

**Vorbedingung:** VL 2. HZ Nachspielzeit läuft, Anzeige bei `120+01`  
**Aktion:** Tap auf Spielfeld → Ereignis speichern  
**Erwartetes Ergebnis:** Ereignis zeigt Zeitstempel `120+01`  
**Kriterium:** US-211 AK Zeitstempel

---

## Gruppe F — Persistenz und Hintergrund-Sicherheit

### TC-1328 · Phase bleibt nach App-Backgrounding erhalten

**Vorbedingung:** 2. Halbzeit läuft, Timer bei `67:12`  
**Aktion:** App in den Hintergrund wechseln (Home-Button / App-Switcher); 60 Sekunden warten; App wieder in den Vordergrund bringen  
**Erwartetes Ergebnis:** Timer zeigt `68:12` (weitergelaufen im Hintergrund); Phase-Label zeigt „2. Halbzeit"  
**Kriterium:** Timestamp-basierter Timer (CLAUDE.md Architektur)

---

### TC-1329 · Phase bleibt nach App-Neustart erhalten

**Vorbedingung:** Nachspielzeit 1. HZ läuft, Anzeige bei `45+01`  
**Aktion:** App beenden; sofort neu starten  
**Erwartetes Ergebnis:** Live-Screen zeigt die korrekte Phase und die weitergelaufene Zeit; Phase-Label zeigt „Nachspielzeit"  
**Kriterium:** Persistente TimerState-Entität (Drift)

---

## Gruppe G — Szenenliste und Nachbearbeitung

### TC-1330 · Zeitstempel-Anzeige in Szenenliste korrekt formatiert

**Vorbedingung:** Spiel mit Ereignissen in allen Phasen (regulär + Nachspielzeiten)  
**Aktion:** Nachbearbeitungs-Screen öffnen → Tab „Szenen"  
**Erwartetes Ergebnis:** Zeitstempel-Spalte zeigt phasenkonformes Format:  
- Reguläre Zeit: `23:45`  
- 1. HZ NS: `45+02`  
- 2. HZ NS: `90+01`  
- VL regulär: `97:30`  
- VL NS: `105+02`  
**Kriterium:** US-210 / US-211 AK Ereignis-Zeitstempel

---

### TC-1331 · Zeitstempel bleibt nach nachträglicher Bearbeitung korrekt

**Vorbedingung:** Ereignis mit Zeitstempel `45+02` in der Szenenliste  
**Aktion:** Ereignis öffnen → Bearbeiten → nur Bewertung ändern → Speichern  
**Erwartetes Ergebnis:** Zeitstempel bleibt `45+02`; kein ungewolltes Zurücksetzen auf andere Zeitdarstellung  
**Kriterium:** US-209 + US-210 AK Zeitstempel

---

## Übersicht

| TC | Gruppe | US | Priorität |
|----|--------|----|-----------|
| TC-1301 | A — Zeitanzeige 1. HZ | US-210 | Hoch |
| TC-1302 | A — Zeitanzeige 1. HZ | US-210 | Hoch |
| TC-1303 | A — Zeitanzeige 1. HZ | US-210 | Hoch |
| TC-1304 | A — Zeitanzeige 1. HZ | US-210 | Mittel |
| TC-1305 | B — Halbzeit-Button | US-210 | Hoch |
| TC-1306 | B — Halbzeit-Button | US-210 | Hoch |
| TC-1307 | B — Halbzeit-Button | US-210 | Hoch |
| TC-1308 | B — Halbzeit-Button | US-210 | Mittel |
| TC-1309 | C — Zeitanzeige 2. HZ | US-210 | Hoch |
| TC-1310 | C — Zeitanzeige 2. HZ | US-210 | Hoch |
| TC-1311 | C — Zeitanzeige 2. HZ | US-210 | Hoch |
| TC-1312 | C — Zeitanzeige 2. HZ | US-210 | Hoch |
| TC-1313 | D — Zeitstempel | US-210 | Hoch |
| TC-1314 | D — Zeitstempel | US-210 | Hoch |
| TC-1315 | D — Zeitstempel | US-210 | Hoch |
| TC-1316 | D — Zeitstempel | US-210 | Mittel |
| TC-1317 | E — Verlängerung | US-211 | Hoch |
| TC-1318 | E — Verlängerung | US-211 | Mittel |
| TC-1319 | E — Verlängerung | US-211 | Hoch |
| TC-1320 | E — Verlängerung | US-211 | Hoch |
| TC-1321 | E — Verlängerung | US-211 | Hoch |
| TC-1322 | E — Verlängerung | US-211 | Hoch |
| TC-1323 | E — Verlängerung | US-211 | Hoch |
| TC-1324 | E — Verlängerung | US-211 | Hoch |
| TC-1325 | E — Verlängerung | US-211 | Mittel |
| TC-1326 | E — Verlängerung | US-211 | Mittel |
| TC-1327 | E — Verlängerung | US-211 | Mittel |
| TC-1328 | F — Persistenz | US-210/211 | Hoch |
| TC-1329 | F — Persistenz | US-210/211 | Hoch |
| TC-1330 | G — Szenenliste | US-210/211 | Mittel |
| TC-1331 | G — Szenenliste | US-209/210 | Mittel |
