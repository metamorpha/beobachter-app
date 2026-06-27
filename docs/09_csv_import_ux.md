# CSV-Import: UX Flow & Designentscheidungen

## Kontext

Nutzer können auf dem GameSetupScreen eine Pressebericht-CSV (Spielberichtsnummer-Format des DFB/FLVW) importieren, um Teamnamen, Aufstellungen und Spielmeta-Daten automatisch zu befüllen. Der Nutzer prüft danach die importierten Daten und kann sie vor dem Spielstart korrigieren.

---

## Entscheidungsprotokoll

| Frage | Entscheidung |
|-------|-------------|
| Einstiegspunkt | GameSetupScreen (Import-Button) |
| Spielernamen | Nein — nur Rückennummern |
| Auswechsler importieren | Ja — Startelf S1–S11 + Auswechsler A1–A9 |
| Meta-Daten | Teamnamen, Datum, Spielort, Liga, Spieltag |
| Liga/Spieltag | Neue Felder im Datenmodell erforderlich |
| Fehlerfall | Partial-Import + Warnung |
| Nach Import | Felder befüllt, Nutzer prüft und startet |
| Multi-Spiel-CSV | Nicht unterstützt — immer erste Datenzeile |
| Überschreiben | Warnung + Bestätigung bevor Daten überschrieben werden |
| Datei-Picker | System-Datei-Picker (`file_picker` Package) |

---

## UX Flows

### Flow 1 — Normaler Import (leerer Screen)

```
GameSetupScreen (leer)
  │
  ├─ [Button: "Aus Pressebericht importieren" + Icon upload]
  │     │
  │     ▼
  │   System-Datei-Picker öffnet sich
  │   (Filter: *.csv)
  │     │
  │     ├─ Nutzer bricht ab ──────────────────► GameSetupScreen (unverändert)
  │     │
  │     └─ Nutzer wählt Datei
  │           │
  │           ▼
  │         CSV wird geparst
  │           │
  │           ├─ Vollständig erkannt
  │           │     └─► Alle Felder befüllt, kein Banner
  │           │
  │           └─ Teilweise erkannt
  │                 └─► Felder soweit befüllt + gelbes Warn-Banner:
  │                     "Folgende Felder konnten nicht importiert werden: [...]"
  │
  ▼
GameSetupScreen mit vorausgefüllten Feldern
  │  Nutzer kann manuell korrigieren / ergänzen
  │
  └─ [Button: "Spiel starten"] ──► LiveScreen
```

### Flow 2 — Import mit vorhandenen Daten (Überschreiben)

```
GameSetupScreen (Daten bereits eingegeben)
  │
  ├─ [Button: "Aus Pressebericht importieren"]
  │     │
  │     ▼
  │   Warn-Dialog:
  │   "Import überschreibt vorhandene Daten. Fortfahren?"
  │   [Abbrechen]  [Importieren]
  │     │                │
  │     ▼                ▼
  │   Keine         Datei-Picker öffnet sich
  │   Änderung      → weiter wie Flow 1
  │
  ▼
```

### Flow 3 — Ungültige/nicht erkennbare CSV

```
  CSV wird geparst
  │
  ├─ Mindestfelder fehlen (kein Heimteam UND kein Gastteam erkennbar)
  │     └─► Fehler-Dialog: "Diese Datei hat kein erkanntes Format.
  │         Bitte eine Pressebericht-CSV auswählen."
  │         [OK] ──► GameSetupScreen (unverändert)
  │
  └─ Einige Felder erkannt, andere fehlen
        └─► Partial-Import + Warn-Banner
            (z. B. Spieler-Nummern einer Mannschaft fehlen)
```

---

## Screen-Layout: GameSetupScreen (erweitert)

```
┌─────────────────────────────────────────┐
│ ← Spiel einrichten                      │
├─────────────────────────────────────────┤
│                                         │
│  [📁 Aus Pressebericht importieren]     │  ← Neuer Button, prominent oben
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Spieldaten                             │
│  Heimmannschaft [___________________]   │
│  Gastmannschaft [___________________]   │
│  Liga           [___________________]   │  ← Neu
│  Spieltag       [___________________]   │  ← Neu
│  Spielort       [___________________]   │
│  Datum          [___________________]   │  ← Neu (aus CSV)
│                                         │
│  Aufstellung Heim                       │
│  [Rückennummer] [+ Hinzufügen]          │
│  #21 #4 #5 ...                          │
│                                         │
│  Aufstellung Gast                       │
│  [Rückennummer] [+ Hinzufügen]          │
│  #44 #4 #6 ...                          │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  ▶  Spiel starten               │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

**Warn-Banner** (bei Partial-Import, unter dem Import-Button):

```
┌─────────────────────────────────────────┐
│ ⚠️  Nicht importiert: Aufstellung Gast  │
│    (Felder manuell ergänzen)            │
└─────────────────────────────────────────┘
```

---

## CSV-Parsing: Feldmapping

Das Format ist semikolon-separiert, erste Zeile = Header, zweite Zeile = Daten.

| CSV-Spalte | App-Feld | Pflicht |
|------------|----------|---------|
| `Heimmannschaft` | `homeTeamName` | Ja |
| `Gastmannschaft` | `awayTeamName` | Ja |
| `Spieldatum` + `Anstoßzeit` | `date` (DateTime) | Nein |
| `Stadion` + `Ort` | `location` | Nein |
| `Liganame` | `liga` (neu) | Nein |
| `Spieltag` | `spieltag` (neu) | Nein |
| `H-S1-Nr` … `H-S11-Nr` | Startelf Heim | Nein |
| `H-A1-Nr` … `H-A9-Nr` | Auswechsler Heim | Nein |
| `G-S1-Nr` … `G-S11-Nr` | Startelf Gast | Nein |
| `G-A1-Nr` … `G-A9-Nr` | Auswechsler Gast | Nein |

**Spieler-Nummern-Filterregel**: Nur Werte importieren, die als Integer 1–99 parsierbar sind. Leere Zellen, `TW`, `C`, `ETW` und alle anderen Nicht-Zahlen werden ignoriert (die Spalten `H-S1-Hinweis` / `H-S1-Status` etc. bleiben ungenutzt).

**Datum-Parsing**: `Spieldatum` im Format `DD.MM.YYYY` + `Anstoßzeit` im Format `HH:MM` → kombinieren zu `DateTime`. Schlägt das Parsing fehl → Datum bleibt `DateTime.now()`.

**Spielort**: Wenn `Stadion` nicht leer → `"Stadion, Ort"`. Wenn leer → nur `Ort`. Wenn beides leer → leer.

**Multi-Zeilen-CSV**: Nur die erste Datenzeile (Zeile 2) wird verarbeitet. Weitere Zeilen werden ignoriert (kein Hinweis nötig, da Pressebericht-Dateien immer genau ein Spiel enthalten).

---

## Datenmodell-Änderungen

Zwei neue optionale Felder auf der `Game`-Entität und der `games`-Drift-Tabelle:

```dart
// domain/entities/game.dart
String? liga;       // z. B. "Westfalenliga Herren Staffel 2"
String? spieltag;   // z. B. "23" (als String, da Freitext möglich)
```

Die Felder sind optional (nullable) und werden auf dem GameSetupScreen als normale `TextField`s angezeigt. Der bestehende Spielstart-Flow bleibt unverändert.

---

## Neue Abhängigkeit

| Package | Version | Zweck |
|---------|---------|-------|
| `file_picker` | ^8.x | Nativer Datei-Browser für iOS / Android / Windows |

---

## Robustheit-Anforderungen

- Kein Absturz bei beliebiger Datei-Eingabe (try/catch um gesamten Parser)
- Leerzeilen und Windows-Zeilenenden (`\r\n`) werden toleriert
- Semikolons innerhalb von Werten (in Anführungszeichen) werden korrekt behandelt
- Encoding: UTF-8 primär, Latin-1/Windows-1252 als Fallback (Umlaute)
- Datei-Picker bricht ab → keinerlei Zustandsänderung
