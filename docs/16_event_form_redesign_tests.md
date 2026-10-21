# Testfälle — Event-Formular Redesign

> Scope: EventFormPanel — Progressive Disclosure, Visual Redesign, Coaching-Flag, Player-Bug-Fix

---

## TC-EFR-01: Vor Typ-Auswahl nur Typ-Grid sichtbar

**Vorbedingung:** Live-Screen, Tap auf Spielfeld → EventFormPanel öffnet sich (Ersterfassung).

**Schritte:** Formular öffnen, nichts auswählen.

**Erwartetes Ergebnis:**
- Typ-Grid mit allen 9 EventTypes ist sichtbar
- Felder Spieler, Entscheidung, Karte, Bewertung, Notiz sind NICHT sichtbar
- Platzhaltertext „Typ auswählen, dann speichern" erscheint
- Speichern-Button ist inaktiv (ausgegraut)

---

## TC-EFR-02: Zeitstempel wird beim Öffnen eingefroren

**Vorbedingung:** Uhr läuft (z. B. 47:23).

**Schritte:** Spielfeld antippen → Formular öffnet sich. 10 Sekunden warten. Typ wählen. Speichern.

**Erwartetes Ergebnis:**
- Header zeigt 47:23 (Zeitpunkt des Taps)
- Gespeichertes Ereignis hat `elapsedMs` entsprechend 47:23, NICHT 47:33

---

## TC-EFR-03: Nach Typ-Auswahl erscheinen Felder (Animation)

**Vorbedingung:** Formular offen, kein Typ ausgewählt.

**Schritte:** Tap auf „Abseits".

**Erwartetes Ergebnis:**
- Entscheidungs-Grid erscheint (AnimatedSwitcher, ca. 150 ms)
- Karte + Coaching-Zeile erscheint
- Bewertungs-Grid erscheint
- Notiz-Toggle erscheint
- Spieler-Sektion erscheint NICHT (Abseits ist kein Foul-Typ)
- Speichern-Button wird aktiv

---

## TC-EFR-04: Spieler-Sektion nur bei Foul-Typen

**Vorbedingung:** Formular offen.

**Schritte (a):** Typ „Fußvergehen" auswählen.
**Erwartetes Ergebnis (a):** Spieler-Sektion (Fouler + Gefoulter) erscheint.

**Schritte (b):** Typ zu „Abseits" wechseln.
**Erwartetes Ergebnis (b):** Spieler-Sektion verschwindet.

**Foul-Typen mit Spieler-Sektion:** Fußvergehen, Körpervergehen, Handspiel, Unsportlichkeit, Tätlichkeit.
**Typen ohne Spieler-Sektion:** Abseits, Vorteil, Torentscheidung, Sonstiges.

---

## TC-EFR-05: Coaching-Flag im Formular toggelbar

**Vorbedingung:** Formular offen, beliebiger Typ ausgewählt.

**Schritte:** Coaching-Stern (☆) antippen.

**Erwartetes Ergebnis:**
- Stern wechselt auf ausgefüllt (⭐, amber)
- Erneuter Tap: wechselt zurück auf ☆

---

## TC-EFR-06: Coaching-Flag wird beim Speichern übertragen (Ersterfassung)

**Vorbedingung:** Formular offen.

**Schritte:** Typ wählen → Coaching-Stern auf ⭐ setzen → Speichern.

**Erwartetes Ergebnis:**
- Gespeichertes Event hat `coachingFlag == true`
- Ereignis erscheint in der Coaching-Ansicht der Nachbereitung

---

## TC-EFR-07: Coaching-Flag im Bearbeitungsmodus vorausgefüllt

**Vorbedingung:** Bestehendes Event mit `coachingFlag == true`.

**Schritte:** Bearbeiten-Dialog öffnen.

**Erwartetes Ergebnis:**
- Coaching-Stern zeigt ⭐ (amber) beim Öffnen
- Kein Tap nötig, um den Wert beizubehalten

---

## TC-EFR-08: Spieler-Daten im Bearbeitungsmodus vorausgefüllt

**Vorbedingung:** Event mit Fouler Heim #7 und Gefoultem Gast #11 gespeichert.

**Schritte:** Bearbeiten-Dialog öffnen.

**Erwartetes Ergebnis:**
- Fouler: Heim-Chip selektiert, #7 im Ziffernfeld oder als selektierter Squad-Chip
- Gefoulter: Gast-Chip selektiert, #11 im Ziffernfeld oder als selektierter Squad-Chip

---

## TC-EFR-09: Spieler-Daten werden beim Speichern (Edit) beibehalten

**Vorbedingung:** Event mit Fouler Heim #7 gespeichert.

**Schritte:** Bearbeiten-Dialog öffnen → Entscheidung ändern → Speichern.

**Erwartetes Ergebnis:**
- Fouler Heim #7 bleibt erhalten
- Keine leere Spielerliste nach dem Speichern

---

## TC-EFR-10: InkWell-Feedback auf Chips

**Vorbedingung:** Formular offen.

**Schritte:** Beliebigen Typ-Chip antippen.

**Erwartetes Ergebnis:**
- Ripple-Animation sichtbar beim Tap (InkWell, nicht nur GestureDetector)

---

## TC-EFR-11: Kein Scrollen des Panels auf Ziel-Tablet (Querformat)

**Vorbedingung:** Gerät: iPad/Surface im Querformat (min. 768px Höhe). Foul-Szenario (größte Formular-Variante).

**Schritte:** Typ „Fußvergehen" wählen → alle Felder sichtbar.

**Erwartetes Ergebnis:**
- Alle Felder (Spieler, Entscheidung, Karte, Coaching, Bewertung, Notiz-Toggle, Speichern-Button) ohne Scrollen sichtbar
- Kein vertikaler Scroll-Indikator aktiv

---

## TC-EFR-12: Typ-Wechsel setzt Entscheidung und Karte zurück

**Vorbedingung:** Formular offen, Typ „Fußvergehen", Entscheidung „Freistoß", Karte „Gelb" gewählt.

**Schritte:** Typ auf „Abseits" wechseln.

**Erwartetes Ergebnis:**
- Entscheidung wird auf leer zurückgesetzt
- Karte wird auf leer zurückgesetzt
- Spieler-Sektion verschwindet

---

## TC-EFR-13: Minimaler Pfad funktioniert weiterhin (3 Taps)

**Schritte:** Tap Spielfeld → Tap Typ → Tap Speichern.

**Erwartetes Ergebnis:**
- Event wird gespeichert mit Typ, Location, Zeitstempel
- Entscheidung, Karte, Bewertung, Spieler: alle null/leer
- `coachingFlag == false`

---

## TC-EFR-14: Widget-Keys bleiben erhalten (Regressions-Schutz)

**Erwartetes Ergebnis:**
- `Key('btn_close_event_form')` vorhanden
- `Key('btn_save_event')` vorhanden
- `Key('event_type_<name>')` für alle 9 EventTypes vorhanden
- `Key('decision_<name>')` für alle RefDecisions vorhanden (nur wenn Typ ausgewählt)
- `Key('card_<name>')` für alle CardTypes vorhanden (nur wenn Typ ausgewählt)
