# Testfälle — Trikotfarben der Teams (US-111)

---

## Domain & Datenhaltung

### TC-111-01: Palette vollständig und eindeutig

**Aktion:** Alle Werte von `KitColor` durchlaufen.

**Erwartetes Ergebnis:** Es gibt genau 11 Werte: Weiß, Schwarz, Grau, Rot, Bordeaux, Orange, Gelb, Grün, Hellblau, Blau, Lila. Jeder hat einen deutschen Namen und eine eigene Farbe. `needsOutline` ist nur bei Weiß, Gelb und Hellblau `true`.

---

### TC-111-02: Trikotfarben werden gespeichert und geladen

**Vorbedingung:** In-Memory-Datenbank.

**Aktion:** Spiel mit `homeKitColor = white`, `awayKitColor = black` speichern und erneut laden.

**Erwartetes Ergebnis:** Die geladenen Werte sind `white` und `black`.

---

### TC-111-03: Spiel ohne Trikotfarben

**Aktion:** Spiel ohne Farben speichern und laden.

**Erwartetes Ergebnis:** Beide Felder sind `null`. `TeamColors` liefert Heim `#1D4ED8` und Gast `#C2261D`.

---

### TC-111-04: Migration v7 → v8 erhält Altdaten

**Vorbedingung:** Datenbank in Schema v7 mit einem Spiel, Kader, Ereignissen und Toren.

**Aktion:** Datenbank mit Schema v8 öffnen.

**Erwartetes Ergebnis:** Die Migration läuft fehlerfrei. Alle Daten sind unverändert vorhanden, und beide Trikotfarben sind `null`.

---

### TC-111-05: Unbekannter Farbwert in der DB

**Vorbedingung:** In `home_kit_color` steht ein unbekannter Text, z. B. `"magenta"`.

**Aktion:** Spiel laden.

**Erwartetes Ergebnis:** Kein Absturz. `homeKitColor` ist `null`, es gilt die Standardfarbe.

---

### TC-111-06: CSV-Import setzt keine Farben

**Aktion:** Gültige Pressebericht-CSV importieren (US-105).

**Erwartetes Ergebnis:** Das Spiel hat keine Trikotfarben, im Setup ist keine Farbe markiert.

---

## Spiel-Setup (Widget)

### TC-111-07: Farbauswahl je Team sichtbar

**Vorbedingung:** Neues Spiel im Setup.

**Erwartetes Ergebnis:** In der Karte „Aufstellungen" steht unter „Aufstellung Heim" und unter „Aufstellung Gast" je eine Farbauswahl mit 11 Flächen. Keine Fläche ist markiert.

---

### TC-111-08: Farbe wählen wirkt sofort

**Aktion:** Bei Heim „Weiß" antippen und die Rückennummer 7 hinzufügen.

**Erwartetes Ergebnis:** „Weiß" trägt Haken und Rahmen. Punkt und Überschrift „Aufstellung Heim" sowie Chip #7 sind weiß, mit Rand und dunkler Schrift.

---

### TC-111-09: Farbe wird mit dem Spiel gespeichert

**Aktion:** Heim „Gelb", Gast „Schwarz" wählen, dann „Spiel starten".

**Erwartetes Ergebnis:** Beide Farben sind schon direkt nach der Auswahl gespeichert (`updateKitColor`) und bleiben nach „Spiel starten“ erhalten: `homeKitColor = yellow`, `awayKitColor = black`.

---

### TC-111-10: Bestehendes Spiel bearbeiten

**Vorbedingung:** Gespeichertes Spiel mit Heim „Grün".

**Aktion:** Spiel im Setup öffnen.

**Erwartetes Ergebnis:** Bei Heim ist „Grün" markiert, bei Gast nichts.

---

### TC-111-11: Hinweis bei gleicher Farbe

**Aktion:** Bei beiden Teams „Rot" wählen. Danach bei Gast „Blau" wählen.

**Erwartetes Ergebnis:** Nach dem ersten Schritt erscheint „Beide Teams haben dieselbe Trikotfarbe", und „Spiel starten" bleibt aktiv. Nach dem zweiten Schritt ist der Hinweis wieder weg.

---

## Live-Screen (Widget)

### TC-111-12: Kopfzeile in Trikotfarben

**Vorbedingung:** Spiel mit Heim „Weiß" und Gast „Schwarz" im Live-Screen.

**Erwartetes Ergebnis:**
- Der Team-Punkt Heim und der Heim-Button „+ Tor" sind weiß, haben einen Rand und eine dunkle Schrift.
- Der Team-Punkt Gast und der Gast-Button „+ Tor" sind schwarz und haben eine weiße Schrift.

---

### TC-111-13: Tor-Dialog und Kader-Chips im Ereignisformular

**Vorbedingung:** wie TC-111-12, Heim-Kader #9.

**Aktion:**
1. „+ Tor" (Heim) antippen.
2. Den Dialog abbrechen.
3. Aufs Spielfeld tippen und Täter-Team „H" wählen.

**Erwartetes Ergebnis:** Der Punkt im Tor-Dialog und Chip #9 sind in beiden Fällen weiß und haben einen Rand.

---

### TC-111-14: Farbe im Dialog „Aufstellung" ändern

**Vorbedingung:** Laufendes Spiel mit Heim „Blau" (Standard).

**Aktion:** Dialog „Aufstellung" öffnen, bei Heim „Lila" wählen, dann „Fertig".

**Erwartetes Ergebnis:** Die Farbe ist sofort gespeichert (`updateKitColor`, `homeKitColor = purple`). Die Kopfzeile zeigt Lila, ohne dass der Screen neu geöffnet wird. Der Timer-Zustand ist unverändert.

---

### TC-111-15: Hinweis im Dialog „Aufstellung"

**Aktion:** Im Dialog bei Gast dieselbe Farbe wählen wie bei Heim.

**Erwartetes Ergebnis:** Der Hinweis „Beide Teams haben dieselbe Trikotfarbe" ist sichtbar. „Fertig" schließt den Dialog trotzdem.

---

### TC-111-16: „Letzte Ereignisse" zeigt Tore in Trikotfarbe

**Vorbedingung:** Spiel mit Gast „Grün" und einem erfassten Gast-Tor.

**Erwartetes Ergebnis:** Der Punkt am Tor-Eintrag ist grün.

---

### TC-111-17: Fachfarben bleiben unverändert

**Vorbedingung:** Heim „Gelb", Gast „Rot". Eine Szene mit Gelber Karte und Bewertung „falsch" ist erfasst.

**Erwartetes Ergebnis:**
- Kartenfarbe = `yellowCard` (`#FACC15`)
- Bewertung = `wrong`
- Phasen-Buttons und Spielfeld unverändert

---

## Nachbereitung (Widget)

### TC-111-18: Ranking, Torliste und Vergehen in Trikotfarben

**Vorbedingung:** Abgeschlossenes Spiel, Heim „Weiß", Gast „Bordeaux", mit Toren und Vergehen beider Teams.

**Erwartetes Ergebnis:**
- Die Team-Badges in Spieler-Ranking und Torliste sind weiß (mit Rand) bzw. bordeaux.
- In „Vergehen pro Team" ist „G" bordeaux. „H" ist dunkel (`onSurface`) statt weiß und damit lesbar.

---

## Smartphone & Darstellung

### TC-111-19: Farbauswahl auf dem Smartphone

**Vorbedingung:** Bildschirm 390 × 844 dp, Setup im Hochformat. Danach Live-Dialog „Aufstellung" im Querformat 844 × 390 dp.

**Erwartetes Ergebnis:** In beiden Ansichten sind alle 11 Flächen ohne horizontales Scrollen erreichbar, mindestens 40 dp groß, und es gibt keinen Overflow.

---

### TC-111-20: Altspiel sieht unverändert aus (Golden)

**Vorbedingung:** Spiel ohne Trikotfarben.

**Erwartetes Ergebnis:** Die bestehenden Goldens für den Live-Screen und die Nachbereitung bleiben ohne Neuerzeugung grün.

---

### TC-111-21: Golden mit Trikotfarben

**Vorbedingung:** Heim „Weiß", Gast „Schwarz".

**Erwartetes Ergebnis:** Es gibt neue Goldens für die Live-Kopfzeile und die Setup-Karte „Aufstellungen". Ränder und Schriftfarben sind korrekt.

---

### TC-111-22: Bestehende Testsuite bleibt grün

**Aktion:** `flutter analyze` und `flutter test`.

**Erwartetes Ergebnis:** Keine Analyzer-Meldungen, alle Tests grün.

---

## Ergebnis (2026-10-30)

| TC | Status | Umsetzung |
|---|---|---|
| 01–05 | ✅ | `test/trikotfarben_test.dart` (Unit- und Repository-Tests mit In-Memory-DB) |
| 06 | ✅ | Zusatzprüfung in `test/game_setup_import_test.dart` (TC-GS-01) |
| 07–16 | ✅ | `test/trikotfarben_test.dart` (Widget-Tests mit echter In-Memory-DB und Golden-Testdaten) |
| 17 | ✅ | Unit-Test: Karten- und Bewertungsfarben unverändert, Trikotfarben weichen davon ab. Zusätzlich bleiben die bestehenden Live-/Nachbereitungs-Goldens unverändert |
| 18–19 | ✅ | `test/trikotfarben_test.dart` |
| 20 | ✅ | `live`, `live_form`, `review_*` und `phone_live*` bleiben ohne Neuerzeugung grün. Nur `game_setup` und `phone_game_setup` wurden wegen der neuen Farbauswahl neu erzeugt |
| 21 | ✅ | Neue Goldens `game_setup_kits.png` und `live_kits.png` (Heim Weiß, Gast Schwarz) |
| 22 | ✅ | `flutter analyze` ohne Befund; `flutter test`: 319 Tests grün |

Offen: Sichtprüfung auf einem echten Gerät, vor allem ob Weiß und Gelb bei Tageslicht unterscheidbar sind.
