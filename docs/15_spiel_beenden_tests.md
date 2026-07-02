# Testfälle — US-212: Spiel endgültig beenden

> Abgedeckte User Story: US-212 (Spiel endgültig beenden)
> Gerät: Tablet, Querformat
> Umsetzung: Unit-Tests (`TimerService`), Widget-Tests (`TimerDisplay`, `LiveScreen`, `GameListScreen`), manuelle Prüfung

---

## Gruppe A — TimerService (Unit)

### TC-1501 · spielBeenden() setzt Phase `abgeschlossen` und stoppt die Uhr

**Vorbedingung:** Phase `beendet` (nach Abpfiff 2. HZ)
**Aktion:** `spielBeenden()` aufrufen
**Erwartetes Ergebnis:** Phase ist `abgeschlossen`; `isRunning` ist `false`; Zustand wird persistiert (`saveTimerState`)
**Kriterium:** US-212 AK „Spiel beenden"

---

### TC-1502 · spielBeenden() aus `beendetVerlaengerung`

**Vorbedingung:** Phase `beendetVerlaengerung` (nach Abpfiff Verl.)
**Aktion:** `spielBeenden()` aufrufen
**Erwartetes Ergebnis:** Phase ist `abgeschlossen`; `isRunning` ist `false`
**Kriterium:** US-212 AK „Spiel beenden nach Verlängerung"

---

### TC-1503 · Abgeschlossenes Spiel kann nicht erneut gestartet werden

**Vorbedingung:** Phase `abgeschlossen`
**Aktion:** `startGame()`, `startVerlaengerung()`, `start()` nacheinander aufrufen
**Erwartetes Ergebnis:** Alle Aufrufe sind wirkungslos: Phase bleibt `abgeschlossen`, `isRunning` bleibt `false`, kein weiterer `saveTimerState`-Aufruf
**Kriterium:** US-212 AK „kann nicht erneut gestartet werden"

---

### TC-1504 · Abgeschlossen-Zustand überlebt Neustart (load)

**Vorbedingung:** Persistierter TimerState mit Phase `abgeschlossen`
**Aktion:** Neuen `TimerService` erzeugen und `load()` aufrufen
**Erwartetes Ergebnis:** Phase ist `abgeschlossen`; Uhr läuft nicht; kein Ticker gestartet
**Kriterium:** US-212 AK Persistenz

---

## Gruppe B — TimerDisplay (Widget)

### TC-1505 · Phase `beendet`: zwei Buttons sichtbar

**Vorbedingung:** TimerState mit Phase `beendet`
**Aktion:** `TimerDisplay` rendern
**Erwartetes Ergebnis:** Buttons `Verlängerung` (`btn_verlaengerung`) und `Spiel beenden` (`btn_spiel_beenden`) sind beide sichtbar
**Kriterium:** US-212 AK Wahlmöglichkeit

---

### TC-1506 · Phase `beendetVerlaengerung`: nur „Spiel beenden"

**Vorbedingung:** TimerState mit Phase `beendetVerlaengerung`
**Aktion:** `TimerDisplay` rendern
**Erwartetes Ergebnis:** Nur Button `Spiel beenden` sichtbar; kein Verlängerungs-Button
**Kriterium:** US-212 AK Wahlmöglichkeit nach Verlängerung

---

### TC-1507 · „Spiel beenden" öffnet Bestätigungsdialog; Abbrechen ändert nichts

**Vorbedingung:** Phase `beendet`
**Aktion:** Tap auf `Spiel beenden`, dann Tap auf `Abbrechen`
**Erwartetes Ergebnis:** Dialog mit Irreversibilitäts-Hinweis erscheint; nach Abbrechen bleibt Phase `beendet`, beide Buttons weiterhin sichtbar
**Kriterium:** US-212 AK Bestätigungsdialog

---

### TC-1508 · Dialog bestätigen schließt das Spiel ab

**Vorbedingung:** Phase `beendet`
**Aktion:** Tap auf `Spiel beenden`, dann Tap auf `Beenden` im Dialog
**Erwartetes Ergebnis:** Phase wechselt auf `abgeschlossen`; Phase-Label zeigt „Abgeschlossen"; keine Phasen-Buttons mehr sichtbar
**Kriterium:** US-212 AK Bestätigungsdialog + kein Neustart

---

### TC-1509 · Phase `abgeschlossen`: kein Phasen-Button

**Vorbedingung:** TimerState mit Phase `abgeschlossen`
**Aktion:** `TimerDisplay` rendern
**Erwartetes Ergebnis:** Kein Phasen-Button sichtbar; Zeitanzeige eingefroren; Label „Abgeschlossen"
**Kriterium:** US-212 AK „keine Phasen-Buttons mehr"

---

## Gruppe C — Live-Screen und Spielliste (Widget)

### TC-1510 · Feldtipp im abgeschlossenen Spiel öffnet kein Formular

**Vorbedingung:** LiveScreen geöffnet, Phase `abgeschlossen`
**Aktion:** Auf das Spielfeld tippen
**Erwartetes Ergebnis:** Kein `EventFormPanel` erscheint; Seitenpanel zeigt weiterhin „Letzte Ereignisse"
**Kriterium:** US-212 AK „keine neuen Ereignisse"

---

### TC-1511 · Spielliste zeigt „Beendet"-Badge für abgeschlossenes Spiel

**Vorbedingung:** Ein Spiel mit persistierter Phase `abgeschlossen`, ein Spiel ohne
**Aktion:** Spielliste rendern
**Erwartetes Ergebnis:** Nur das abgeschlossene Spiel trägt das Badge „Beendet"
**Kriterium:** US-212 AK Kennzeichnung in Spielliste

---

## Gruppe D — Manuelle Prüfung (Simulator/Gerät)

### TC-1512 · Nachbereitung bleibt vollständig erreichbar

**Vorbedingung:** Abgeschlossenes Spiel mit Ereignissen, Notizen und Coaching-Flags
**Aktion:** Spielliste → Tap auf das Spiel → Tabs Szenen / Coaching / Statistik durchgehen; eine Szene bearbeiten und eine Coaching-Notiz ändern
**Erwartetes Ergebnis:** Review öffnet direkt; alle Tabs vollständig funktionsfähig; Szenen-Bearbeitung (US-209) und Notizen funktionieren unverändert
**Kriterium:** US-212 AK Nachbereitung

---

### TC-1513 · App-Neustart: Spiel bleibt abgeschlossen

**Vorbedingung:** Spiel abgeschlossen
**Aktion:** App vollständig beenden und neu starten; Spiel öffnen
**Erwartetes Ergebnis:** Phase weiterhin „Abgeschlossen"; keine Phasen-Buttons; „Beendet"-Badge in der Spielliste
**Kriterium:** US-212 AK Persistenz

---

## Ergebnisübersicht

| TC | Gruppe | Art | Status |
|----|--------|-----|--------|
| TC-1501 | A — TimerService | Unit | ✅ |
| TC-1502 | A — TimerService | Unit | ✅ |
| TC-1503 | A — TimerService | Unit | ✅ |
| TC-1504 | A — TimerService | Unit | ✅ |
| TC-1505 | B — TimerDisplay | Widget | ✅ |
| TC-1506 | B — TimerDisplay | Widget | ✅ |
| TC-1507 | B — TimerDisplay | Widget | ✅ |
| TC-1508 | B — TimerDisplay | Widget | ✅ |
| TC-1509 | B — TimerDisplay | Widget | ✅ |
| TC-1510 | C — Live/Spielliste | Widget | ✅ |
| TC-1511 | C — Live/Spielliste | Widget | ✅ |
| TC-1512 | D — Manuelle Prüfung | Manuell | ✅ (bestanden am 02.07.2026) |
| TC-1513 | D — Manuelle Prüfung | Manuell | ✅ (bestanden am 02.07.2026) |
