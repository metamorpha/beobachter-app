# Testfälle — Spielstand und Torschütze (US-214)

> **Abgelöst durch `25_tor_erfassung_tests.md` (US-215, 2026-10-23).** Die Erfassung über die Torentscheidung entfällt; die zugehörigen Tests wurden entfernt.

---

## Zählregel (Unit)

### TC-2141: Tor für Heim

**Vorbedingung:** Ereignis Typ `goalDecision`, Entscheidung `goal`, Torschützen-Team Heim, kein Eigentor.

**Erwartetes Ergebnis:** Spielstand 1 : 0.

---

### TC-2142: Tor für Gast

**Vorbedingung:** wie TC-2141, Team Gast.

**Erwartetes Ergebnis:** Spielstand 0 : 1.

---

### TC-2143: Eigentor wird dem Gegner gutgeschrieben

**Vorbedingung:** Torschützen-Team Heim, `ownGoal = true`, Entscheidung `goal`.

**Erwartetes Ergebnis:** Spielstand 0 : 1.

---

### TC-2144: Aberkanntes Tor zählt nicht

**Vorbedingung:** Typ `goalDecision`, Team Heim, Entscheidung `indirectFreeKick` (bzw. keine Entscheidung).

**Erwartetes Ergebnis:** Spielstand 0 : 0.

---

### TC-2145: Tor ohne Team zählt nicht

**Vorbedingung:** Typ `goalDecision`, Entscheidung `goal`, kein Torschützen-Team (z. B. Altdaten).

**Erwartetes Ergebnis:** Spielstand 0 : 0, kein Fehler.

---

### TC-2146: Nur Torentscheidungen zählen

**Vorbedingung:** Ereignis Typ `footFoul` mit Entscheidung `goal` (Fehleingabe).

**Erwartetes Ergebnis:** Spielstand 0 : 0.

---

### TC-2147: Gemischter Spielverlauf

**Vorbedingung:** Heim-Tor, Gast-Tor, Eigentor Gast, aberkanntes Heim-Tor.

**Erwartetes Ergebnis:** Spielstand 2 : 1.

---

## Ereignisformular

### TC-2148: Abschnitt „Tor" und vorausgewählte Entscheidung

**Schritte:** Formular öffnen → Typ „Torentsch." antippen.

**Erwartetes Ergebnis:**
- Abschnitt „Tor" mit Torschützen-Zeile und Schalter „Eigentor" sichtbar
- Abschnitt „Spieler" (Fouler/Gefoulter) nicht sichtbar
- Entscheidung „Tor" ist ausgewählt

---

### TC-2149: Vorschau-Zeile — alle Zustände

**Vorbedingung:** Spielstand 1 : 1.

**Schritte / Erwartetes Ergebnis:**
1. Nur Typ gewählt → „Team wählen, damit das Tor zählt"
2. Team Heim, Nummer 9 → „Tor für HEIM · #9 → 2 : 1"
3. Eigentor an → „Eigentor #9 (Heim) → Tor für GAST · 1 : 2"
4. Entscheidung „Tor" abwählen → „Tor aberkannt – Spielstand bleibt 1 : 1"

---

### TC-2150: Speichern mit Torschütze

**Schritte:** Torentsch. → Heim → #9 → Eigentor → Speichern.

**Erwartetes Ergebnis:** Gespeichertes Ereignis hat `goalScorerTeam = home`, `goalScorerNumber = 9`, `ownGoal = true`, `refDecision = goal`; keine EventPlayer-Einträge.

---

### TC-2151: Speichern ohne Team möglich

**Schritte:** Torentsch. → Speichern.

**Erwartetes Ergebnis:** Ereignis wird gespeichert, `goalScorerTeam = null`.

---

### TC-2152: Typwechsel verwirft Torschütze

**Schritte:** Torentsch. → Heim → #9 → Eigentor → Typ „Fußvergehen" → Speichern.

**Erwartetes Ergebnis:** `goalScorerTeam`, `goalScorerNumber` null, `ownGoal = false`.

---

### TC-2153: Bearbeiten — Vorausfüllung

**Vorbedingung:** Gespeichertes Eigentor Gast #4.

**Schritte:** Ereignis im Bearbeiten-Modus öffnen.

**Erwartetes Ergebnis:** Team Gast ausgewählt, Nummernfeld „4", Eigentor aktiv; Vorschau zeigt Gutschrift für Heim.

---

## Live-Screen

### TC-2154: Spielstand in der Kopfzeile

**Vorbedingung:** Spiel ohne Tore, dann mit 2 Heim-Toren und 1 Gast-Tor.

**Erwartetes Ergebnis:** Kopfzeile zeigt unter den Mannschaftsnamen „0 : 0" bzw. „2 : 1".

---

### TC-2155: Spielstand aktualisiert sich nach Löschen

**Vorbedingung:** Spielstand 1 : 0.

**Schritte:** Tor-Ereignis im Seitenpanel löschen.

**Erwartetes Ergebnis:** Kopfzeile zeigt sofort „0 : 0".

---

### TC-2156: Seitenpanel zeigt Spielstand nach dem Tor

**Vorbedingung:** Heim-Tor, Gast-Tor, aberkanntes Tor.

**Erwartetes Ergebnis:** Zeilen „⚽ Tor 1:0", „⚽ Tor 1:1" und „Torentsch.".

---

## Persistenz

### TC-2157: Torschützen-Felder überleben Speichern/Laden

**Schritte:** Ereignis mit Team, Nummer, Eigentor über `EventRepositoryImpl` speichern und neu laden (In-Memory-DB); danach `updateEvent` mit geänderten Werten.

**Erwartetes Ergebnis:** Alle drei Felder entsprechen den gespeicherten Werten.

---

### TC-2158: Migration v4 → v5

**Erwartetes Ergebnis:** Schema-Version 5; Tabelle `events` enthält `goal_scorer_team` (nullable Text), `goal_scorer_number` (nullable Int), `own_goal` (Bool, Default false). Bestehende Ereignisse bleiben erhalten.

---

### TC-2159: Torschütze nicht im Spieler-Ranking

**Vorbedingung:** Tor mit Torschütze Heim #9, keine Vergehen.

**Erwartetes Ergebnis:** `playerRankingProvider` liefert eine leere Liste.
