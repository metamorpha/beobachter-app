# Testfälle: CSV-Import (Pressebericht)

Referenz-UX: `docs/09_csv_import_ux.md`  
Test-Datei: `resources/Pressebericht-211204180.csv`

---

## TC-CSV-01 — Vollständiger Import: Teamnamen

**Vorbedingung:** Leerer GameSetupScreen (neues Spiel).  
**Aktion:** Import-Button tippen → `Pressebericht-211204180.csv` auswählen.  
**Erwartung:** Feld „Heimmannschaft" zeigt `DJK TuS Hordel`, Feld „Gastmannschaft" zeigt `SC Westfalia Herne`.

---

## TC-CSV-02 — Vollständiger Import: Meta-Daten

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** Referenz-CSV importieren.  
**Erwartung:**
- Liga: `Westfalenliga Herren Staffel 2`
- Spieltag: `23`
- Datum: `11.04.2026` (ggf. als `11.04.2026 18:00`)
- Spielort: `Hordeler Heide/Kunstr.1, Bochum` (oder nur `Bochum` falls Stadion-Feld leer)

---

## TC-CSV-03 — Vollständiger Import: Aufstellung Heim (Startelf)

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** Referenz-CSV importieren.  
**Erwartung:** Chips der Heimaufstellung enthalten genau die 11 Nummern: `21, 4, 5, 10, 14, 16, 17, 22, 23, 27, 29` — keine Duplikate, sortiert.

---

## TC-CSV-04 — Vollständiger Import: Aufstellung Heim (Auswechsler)

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** Referenz-CSV importieren.  
**Erwartung:** Auswechsler-Nummern Heim (`1, 6, 7, 9, 11, 13, 15, 18, 24`) sind ebenfalls als Chips vorhanden (insgesamt 20 Spieler Heim).

---

## TC-CSV-05 — Vollständiger Import: Aufstellung Gast (Startelf + Auswechsler)

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** Referenz-CSV importieren.  
**Erwartung:** Gast-Startelf: `44, 4, 6, 9, 10, 15, 21, 23, 24, 30, 77`. Auswechsler Gast: `1, 2, 5, 7, 14, 20, 26, 32, 33`.

---

## TC-CSV-06 — Kein Warn-Banner bei vollständigem Import

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** Referenz-CSV importieren.  
**Erwartung:** Kein Warn-Banner erscheint (alle Pflichtfelder erkannt).

---

## TC-CSV-07 — Datei-Picker Filter

**Vorbedingung:** Verschiedene Dateitypen auf dem Gerät vorhanden.  
**Aktion:** Import-Button tippen → Datei-Browser öffnet sich.  
**Erwartung:** Nur `.csv`-Dateien sind auswählbar (andere ausgegraut oder ausgeblendet).

---

## TC-CSV-08 — Datei-Picker abgebrochen

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** Import-Button tippen → Datei-Browser öffnet sich → Abbrechen/Zurück.  
**Erwartung:** GameSetupScreen unverändert, keine Fehlermeldung, kein Ladeindikator.

---

## TC-CSV-09 — Manuelle Korrektur nach Import

**Vorbedingung:** Referenz-CSV erfolgreich importiert.  
**Aktion:** Feld „Heimmannschaft" manuell auf `FC Test` ändern, dann `#99` zur Heimaufstellung hinzufügen.  
**Erwartung:** Änderungen werden akzeptiert; Spiel startet mit geänderten Werten.

---

## TC-CSV-10 — Spiel starten nach Import

**Vorbedingung:** Referenz-CSV importiert, alle Felder befüllt.  
**Aktion:** Button „Spiel starten" tippen.  
**Erwartung:** Navigation zum LiveScreen. Teambezeichnungen korrekt. Spieler-Chips aller importierten Nummern sind im Live-Aufstellungsbereich verfügbar.

---

## TC-CSV-11 — Überschreiben-Warnung erscheint

**Vorbedingung:** GameSetupScreen mit manuell eingegebenem Heimteam `FC Muster`.  
**Aktion:** Import-Button tippen.  
**Erwartung:** Dialog erscheint: „Import überschreibt vorhandene Daten. Fortfahren?" mit Buttons `Abbrechen` und `Importieren`.

---

## TC-CSV-12 — Überschreiben-Warnung: Abbrechen

**Vorbedingung:** Wie TC-CSV-11.  
**Aktion:** Dialog → `Abbrechen` tippen.  
**Erwartung:** GameSetupScreen mit `FC Muster` unverändert, keine Datei-Auswahl geöffnet.

---

## TC-CSV-13 — Überschreiben-Warnung: Bestätigen

**Vorbedingung:** Wie TC-CSV-11.  
**Aktion:** Dialog → `Importieren` → Referenz-CSV auswählen.  
**Erwartung:** Heimteam-Feld zeigt jetzt `DJK TuS Hordel` (überschrieben).

---

## TC-CSV-14 — Ungültige Datei: Kein CSV-Format

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** Import-Button → Bilddatei (.jpg) oder .txt ohne Semikolons auswählen (falls Picker keine Filterung erzwingt).  
**Erwartung:** Fehlerdialog: „Diese Datei hat kein erkanntes Format. Bitte eine Pressebericht-CSV auswählen." Keine Felder verändert.

---

## TC-CSV-15 — Leere CSV-Datei

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** Import-Button → leere `.csv`-Datei auswählen (0 Bytes).  
**Erwartung:** Fehlerdialog. App stürzt nicht ab.

---

## TC-CSV-16 — CSV ohne erkennbare Teamnamen (Pflichtfelder fehlen)

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** CSV mit korrektem Header, aber leeren Feldern `Heimmannschaft` und `Gastmannschaft` importieren.  
**Erwartung:** Fehlerdialog: „Diese Datei hat kein erkanntes Format..." Keine Felder verändert.

---

## TC-CSV-17 — Partial-Import: Aufstellung einer Mannschaft fehlt

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** CSV importieren, bei der alle `G-S*-Nr` und `G-A*-Nr` Spalten leer sind.  
**Erwartung:** Teamnamen und Heim-Aufstellung importiert. Gast-Aufstellung leer. Gelbes Warn-Banner: „Nicht importiert: Aufstellung Gast".

---

## TC-CSV-18 — Partial-Import: Datum nicht parsierbar

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** CSV importieren mit ungültigem Datumswert (z. B. `32.13.2026`).  
**Erwartung:** Alle anderen Felder werden importiert. Datums-Feld bleibt auf aktuellem Datum (heute). Warn-Banner weist auf fehlgeschlagenes Datum hin.

---

## TC-CSV-19 — Spielernummer außerhalb 1–99 wird ignoriert

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** CSV importieren mit einer Spielernummer `0` oder `100` in einem Heim-Spieler-Feld.  
**Erwartung:** Diese Nummer erscheint nicht als Chip. Alle gültigen Nummern werden korrekt importiert. Kein Absturz.

---

## TC-CSV-20 — Nicht-numerische Spielernummer wird ignoriert

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** CSV importieren mit einem Wert wie `TW` oder `abc` in einem Spielernummer-Feld (tritt im echten Format nicht auf, aber Robustheit prüfen).  
**Erwartung:** Wert ignoriert, keine Exception, restliche Spieler korrekt importiert.

---

## TC-CSV-21 — Duplikate in Spielernummern

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** CSV importieren, bei der dieselbe Nummer (z. B. `10`) sowohl in Startelf als auch Auswechslern steht.  
**Erwartung:** Nummer `10` erscheint nur einmal als Chip (Deduplizierung).

---

## TC-CSV-22 — Encoding: Umlaute korrekt

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** Referenz-CSV importieren.  
**Erwartung:** Teamname `DJK TuS Hordel` und Liga `Westfalenliga Herren Staffel 2` werden korrekt angezeigt (keine verstümmelten Umlaute wie `Westfalenliga Herren Staffel 2`).

---

## TC-CSV-23 — Zeilenende Windows (CRLF)

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** CSV mit Windows-Zeilenenden (`\r\n`) importieren.  
**Erwartung:** Import funktioniert identisch zu UNIX-Zeilenenden. Keine sichtbaren `\r`-Zeichen in Feldern.

---

## TC-CSV-24 — Performance: Kein UI-Freeze

**Vorbedingung:** Leerer GameSetupScreen.  
**Aktion:** Referenz-CSV (>200 Spalten, lange Zeilen) importieren.  
**Erwartung:** App bleibt responsiv während des Parsens. Import dauert < 1 Sekunde. Kein ANR / App-not-responding.

---

## Zusammenfassung Abdeckung

| Kategorie | Anzahl TCs |
|-----------|------------|
| Happy Path (vollständiger Import) | TC-01 bis TC-10 |
| Überschreiben-Warnung | TC-11 bis TC-13 |
| Fehlerfall / Ungültige Datei | TC-14 bis TC-16 |
| Partial-Import + Warnung | TC-17 bis TC-18 |
| Datenfiltierung (Nummern) | TC-19 bis TC-21 |
| Encoding & Format | TC-22 bis TC-23 |
| Performance | TC-24 |
| **Gesamt** | **24** |
