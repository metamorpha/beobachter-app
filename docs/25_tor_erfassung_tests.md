# Testfälle — Tor über eigene Buttons erfassen (US-215)

---

## Spielstand (Unit)

### TC-215-01: Tor zählt für das gewählte Team

**Vorbedingung:** Tor `team = home`, Torart Standard.

**Erwartetes Ergebnis:** Spielstand 1 : 0.

---

### TC-215-02: Eigentor zählt für das gewählte (begünstigte) Team

**Vorbedingung:** Tor `team = home`, Torart Eigentor.

**Erwartetes Ergebnis:** Spielstand 1 : 0; `scorerTeam` = Gast.

---

### TC-215-03: Laufender Spielstand nach Phase und Zeit

**Vorbedingung:** Tor Gast in 1. HZ Nachspielzeit (47'), Tor Heim in 2. HZ (46').

**Erwartetes Ergebnis:** Nachspielzeit-Tor ergibt 0 : 1, das Tor der 2. HZ ergibt 1 : 1.

---

## Kopfzeile & Dialog (Widget)

### TC-215-04: Tor-Buttons in der Kopfzeile

**Schritte:** Live-Screen öffnen.

**Erwartetes Ergebnis:** Buttons „+ Tor“ für Heim (links) und Gast (rechts) sichtbar und aktiv.

---

### TC-215-05: Buttons bei abgeschlossenem Spiel deaktiviert

**Vorbedingung:** Phase `abgeschlossen`.

**Erwartetes Ergebnis:** Beide Buttons deaktiviert; Tap öffnet keinen Dialog.

---

### TC-215-06: Schnellster Weg — 2 Taps

**Schritte:** „+ Tor“ (Heim) → Speichern.

**Erwartetes Ergebnis:** Tor gespeichert mit Team Heim, Torart Standard, ohne Nummer, Spielzeit und Phase des Button-Taps; Spielstand 1 : 0.

---

### TC-215-07: Spielzeit wird beim Button-Tap eingefroren

**Schritte:** Uhr steht auf 30:00 → „+ Tor“ → Uhr läuft weiter → Speichern.

**Erwartetes Ergebnis:** Gespeicherte Spielzeit 30:00.

---

### TC-215-08: Torschütze bei Standardtor/Strafstoßtor aus eigenem Kader

**Schritte:** „+ Tor“ (Heim), Torart Strafstoßtor.

**Erwartetes Ergebnis:** Chips zeigen den Heim-Kader; nach Wahl von #9 Vorschau „Tor für HEIM · #9 (Strafstoß) → 1 : 0“; gespeichert `kind = penalty`, `scorerNumber = 9`.

---

### TC-215-09: Eigentor — nur Kader der verteidigenden Mannschaft

**Schritte:** „+ Tor“ (Heim), #9 wählen, dann Torart Eigentor.

**Erwartetes Ergebnis:** #9 ist verworfen; Chips zeigen ausschließlich den Gast-Kader; nach Wahl von #4 Vorschau „Eigentor #4 (Gast) → Tor für HEIM · 1 : 0“.

---

### TC-215-10: Abbrechen verwirft das Tor

**Schritte:** „+ Tor“ → Abbrechen.

**Erwartetes Ergebnis:** Kein Tor gespeichert, Spielstand unverändert.

---

### TC-215-11: Vorschau berücksichtigt bestehende Tore

**Vorbedingung:** Spielstand 1 : 1.

**Schritte:** „+ Tor“ (Gast).

**Erwartetes Ergebnis:** Vorschau „Tor für GAST → 1 : 2“.

---

## „Letzte Ereignisse" (Widget)

### TC-215-12: Tore erscheinen chronologisch zwischen Ereignissen

**Vorbedingung:** Ereignis 10', Tor Heim 20' (#9, Strafstoß), Ereignis 30', Eigentor für Gast 40'.

**Erwartetes Ergebnis:** Reihenfolge von oben: Tor 40' („⚽ 1:1 · ET“), Ereignis 30', Tor 20' („⚽ 1:0 · #9 · 11m“), Ereignis 10'.

---

### TC-215-13: Tor löschen

**Schritte:** Lösch-Icon am Tor.

**Erwartetes Ergebnis:** Tor entfernt, Spielstand sinkt sofort und leuchtet kurz auf.

---

### TC-215-14: Tor bearbeiten

**Schritte:** Tap auf ein Tor → Torart Eigentor, Nummer wählen → Speichern.

**Erwartetes Ergebnis:** Dialog „Tor bearbeiten“ vorausgefüllt; Änderung gespeichert; Spielzeit unverändert.

---

## Abgrenzung

### TC-215-15: Tore nicht auf Platz, Heatmap, Szenenliste, Vergehen, Ranking

**Vorbedingung:** Spiel nur mit Toren (mit Torschützennummern).

**Erwartetes Ergebnis:** Keine Marker auf dem Platz, Szenenliste leer, Ranking leer, Vergehen-Tabelle 0.

---

### TC-215-16: Typ „Torentscheidung“ und Entscheidung „Tor“ entfallen

**Schritte:** Spielfeld antippen.

**Erwartetes Ergebnis:** Keine Kachel „Torentsch.“ im Ereignistyp, keine Kachel „Tor“ bei Entscheidung; kein Abschnitt „Tor“.

---

### TC-215-17: Karte „Tore“ in der Statistik

**Vorbedingung:** zwei Tore.

**Erwartetes Ergebnis:** Karte „Tore“ listet beide mit Minute, Team, Spielstand, Torschütze und Torart.

---

## Persistenz & Migration

### TC-215-18: Tor überlebt Speichern/Laden/Bearbeiten/Löschen

**Erwartetes Ergebnis:** Alle Felder (Team, Nummer, Torart, Zeit, Phase) werden unverändert gelesen; Update setzt Nummer auch auf null zurück.

---

### TC-215-19: Spiel löschen löscht seine Tore

**Erwartetes Ergebnis:** Nach `deleteGame` liefert `getGoals` eine leere Liste.

---

### TC-215-20: Migration v6 → v7

**Vorbedingung:** v6-Datenbank mit: Torentscheidung „Tor“ Heim, Eigentor Heim-Spieler (zählt für Gast), aberkannte Torentscheidung mit Bewertung, Torentscheidung „Tor“ ohne Team.

**Erwartetes Ergebnis:**
- Zwei Tore übernommen: Heim (Standard, Nummer erhalten) und Gast (Eigentor, Nummer erhalten), Zeit und Phase gleich
- Spielstand 1 : 1 wie vorher
- Alle vier Ereignisse sind jetzt Typ „Sonstiges“ mit Bezeichnung „Torentscheidung“; Bewertung, Ort und Notiz unverändert
