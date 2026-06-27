# UX Design — Beobachter-App MVP

> Gerät: Tablet, Querformat
> Fokus: Geschwindigkeit, One-Tap-Aktionen, kein Scrollen

---

## UX-Prinzipien

1. **Minimal-Event first** — Ort + Typ genügen zum Speichern; alles andere ist optional
2. **Kein Scrollen im Live-Modus** — alle Felder sind auf dem Bildschirm sichtbar
3. **Spielfeld bleibt immer sichtbar** — Ereignisformular als Side Panel, nie Vollbild
4. **One-Tap pro Schritt** — keine Dropdowns, keine Texteingaben im kritischen Pfad
5. **Tastatur nur für Notizen** — und nur auf expliziten Wunsch des Nutzers
6. **Teamfarben als Orientierung** — Heim/Gast durchgehend farblich unterschieden

---

## User Flows

### Flow 1 — Spiel starten

```
Startseite (Spielübersicht)
  │
  ▼
[+ Neues Spiel]
  │
  ▼
Spiel-Setup (optional ausfüllbar)
  ├── Datum / Uhrzeit / Ort
  ├── Heimmannschaft (Name)
  ├── Gastmannschaft (Name)
  └── Aufstellungen (Rückennummern, je Team)
  │
  ▼
[Spiel starten →]
  │
  ▼
Live-Screen
  ├── Spielfeld-Sketch (links, ~60% Breite)
  ├── Spieluhr (oben Mitte, groß)
  └── [▶ Start] Button
```

---

### Flow 2 — Ereignis erfassen (kritischer Pfad)

```
Live-Screen
  │
  ▼ Tap auf Spielfeld
  │
  ▼
Ereignisformular öffnet sich (Side Panel rechts, ~40% Breite)
  │
  ├── [Minimal-Pfad: 3 Taps]
  │     1. Ereignistyp wählen  →  2. Entscheidung wählen  →  3. [Speichern]
  │
  └── [Erweiterter Pfad: bis zu 8 Taps]
        1. Ereignistyp
        2. Fouler (Rückennummer)
        3. Gefoulter (Rückennummer)
        4. Entscheidung
        5. Karte (optional)
        6. Bewertung 2×2-Grid
        7. Notiz aufklappen + tippen (optional)
        8. [Speichern]
  │
  ▼
Zurück zu Live-Screen (Marker auf Spielfeld sichtbar)
```

---

### Flow 4 — Spiel löschen

```
Spielübersicht
  │
  ▼ Tap auf 🗑-Icon in einer Spielkachel
  │
  ▼
AlertDialog: „Spiel löschen?"
  │  Text: „<Spielname> und alle erfassten Ereignisse
  │         werden unwiderruflich gelöscht."
  │
  ├── [Abbrechen]
  │     └── Dialog schließt sich, Kachel bleibt unverändert
  │
  └── [Löschen]  (rot hervorgehoben)
        └── Spiel + alle Ereignisse + Aufstellungen + Timer-State
            werden gelöscht (Cascade-Delete via Foreign Keys)
            Kachel verschwindet aus der Liste
            Bei letztem Spiel: Leer-Hinweis „Noch keine Spiele erfasst."
```

**UX-Entscheidungen:**
- 🗑-Icon ist permanent sichtbar (keine Swipe-Geste) — funktioniert gleich mit Touch und Maus (Surface)
- Dialog nennt den Spielnamen; bei unbenannten Spielen: „Unbenanntes Spiel"
- Kein Undo nach dem Löschen — ein Bestätigungs-Dialog reicht für diese destruktive Aktion

**Wireframe — Spielübersicht mit Löschen-Icon:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Beobachter                                                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│  ⚽  DJK TuS Hordel – SC Westfalia Herne          11.04.2026   🗑   ›        │
├─────────────────────────────────────────────────────────────────────────────┤
│  ⚽  Unbenanntes Spiel                            27.06.2026   🗑   ›        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│                                          [+ Neues Spiel]                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Wireframe — Bestätigungs-Dialog:**

```
┌──────────────────────────────────────────┐
│  Spiel löschen?                          │
│                                          │
│  „DJK TuS Hordel – SC Westfalia Herne"  │
│  und alle erfassten Ereignisse werden    │
│  unwiderruflich gelöscht.                │
│                                          │
│         [Abbrechen]    [Löschen]         │
└──────────────────────────────────────────┘
```

---

### Flow 3 — Nachbearbeitung & Coaching

```
Startseite → Spiel antippen
  │
  ▼
Nachbearbeitungs-Screen
  ├── Tab: Szenenliste
  │     ├── Filter (Typ / Bewertung / Karte / Coaching)
  │     ├── Szene antippen → Detail-Ansicht / Bearbeiten
  │     └── Coaching-Flag (⭐) per Tap setzen
  │
  ├── Tab: Coaching-Ansicht
  │     └── Nur markierte Szenen, chronologisch
  │
  └── Tab: Statistik
        ├── Heatmap
        ├── Zeitachse
        └── Spieler-Ranking
```

---

## Wireframes

### Screen 1 — Live-Screen (Querformat Tablet)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ◀ Spiele          Heimteam  47:23  Gastteam             [■ STOP]           │
├──────────────────────────────────────────────┬──────────────────────────────┤
│                                              │                              │
│                                              │   Letzte Ereignisse          │
│          SPIELFELD-SKETCH                    │   ───────────────────        │
│          (tappable, Draufsicht)              │   43' Fußvergehen  Freistoß  │
│                                              │   38' Handspiel    Weiter    │
│   ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·            │   31' Abseits      Abseits   │
│   ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·            │   ───────────────────        │
│   ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·            │                              │
│   ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·            │                              │
│   ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·            │                              │
│   ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·            │                              │
│                                              │                              │
│                    ✕ (Ereignismarker)        │                              │
│                                              │                              │
└──────────────────────────────────────────────┴──────────────────────────────┘
```

**Interaktion:** Tap auf beliebige Stelle des Spielfelds → Ereignisformular öffnet sich als Side Panel (rechts), Spielfeld bleibt sichtbar.

---

### Screen 2 — Ereignisformular (Minimal-Zustand)

```
┌──────────────────────────────────────────────┬──────────────────────────────┐
│                                              │ 47:23  ✕ Abbrechen           │
│          SPIELFELD-SKETCH                    ├──────────────────────────────┤
│          (abgedunkelt, Marker sichtbar)      │ EREIGNISTYP                  │
│                                              │ ┌────────┐ ┌────────────────┐│
│                    ✕ ← Marker                │ │Fußverg.│ │Oberkörperverg. ││
│                                              │ └────────┘ └────────────────┘│
│                                              │ ┌────────┐ ┌──────┐ ┌──────┐ │
│                                              │ │Handsp. │ │Unspt.│ │Tätkl.│ │
│                                              │ └────────┘ └──────┘ └──────┘ │
│                                              │ ┌────────┐ ┌──────┐ ┌──────┐ │
│                                              │ │Abseits │ │Vort. │ │Tor   │ │
│                                              │ └────────┘ └──────┘ └──────┘ │
│                                              │ ┌──────────────────────────┐ │
│                                              │ │        Sonstiges         │ │
│                                              │ └──────────────────────────┘ │
│                                              │                              │
│                                              │        [▶ SPEICHERN]         │
└──────────────────────────────────────────────┴──────────────────────────────┘
```

**Minimalzustand:** Typ gewählt → Speichern aktiv. Alle weiteren Felder erscheinen nach Typ-Auswahl darunter.

---

### Screen 3 — Ereignisformular (ausgeklappt, Foul-Szenario)

```
┌──────────────────────────────────────────────┬──────────────────────────────┐
│                                              │ 47:23  ✕ Abbrechen           │
│          SPIELFELD-SKETCH                    ├──────────────────────────────┤
│          (abgedunkelt)                       │ [Fußvergehen ✓]              │
│                                              ├──────────────────────────────┤
│                    ✕                         │ SPIELER                      │
│                                              │       HEIM           GAST    │
│                                              │  Fouler:  [5][7][9]  [3][11] │
│                                              │  Gefoulter:[5][7][9] [3][11] │
│                                              ├──────────────────────────────┤
│                                              │ ENTSCHEIDUNG                 │
│                                              │[Freistoß][Strafstoß][Vorteil]│
│                                              │[Weiter  ][Gelb     ][GR     ]│
│                                              │[Rot     ][Ecke     ][Abstoß ]│
│                                              │[Einwurf ][Tor              ] │
│                                              ├──────────────────────────────┤
│                                              │ KARTE  [ ]Gelb [✓]GR [ ]Rot  │
│                                              ├──────────────────────────────┤
│                                              │ BEWERTUNG                    │
│                                              │ ┌───────────┬──────────────┐ │
│                                              │ │ Korrekt · │  Korrekt ·   │ │
│                                              │ │ Erwartbar │  Komplex     │ │
│                                              │ ├───────────┼──────────────┤ │
│                                              │ │  Falsch · │   Falsch ·   │ │
│                                              │ │ Erwartbar │   Komplex    │ │
│                                              │ └───────────┴──────────────┘ │
│                                              ├──────────────────────────────┤
│                                              │ [+ Notiz]                    │
│                                              │                              │
│                                              │        [▶ SPEICHERN]         │
└──────────────────────────────────────────────┴──────────────────────────────┘
```

**Hinweise:**
- Spieler-Buttons zeigen nur vorerfasste Nummern; Tap auf „+" öffnet Ziffernblock
- Entscheidungs-Grid: 3 Spalten, 4 Zeilen, keine Labels länger als 9 Zeichen
- 2×2-Bewertungs-Grid: ein Tap wählt beide Dimensionen gleichzeitig
- „+ Notiz" klappt ein Textfeld auf (Tastatur erscheint erst dann)

---

### Screen 4 — Szenenliste (Nachbearbeitung)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ◀ Spiele   Heimteam – Gastteam   30.04.2026   [Szenen][Coaching][Statistik]│
├─────────────────────────────────────────────────────────────────────────────┤
│  Filter: [Alle Typen ▼]  [Alle Bewertungen ▼]  [Karte: alle]  [Coaching: alle] │
├──────┬──────────────────────┬──────────────┬────────────┬────────┬──────────┤
│ Zeit │ Ereignis             │ Entscheidung │  Bewertung │ Karte  │Coaching  │
├──────┼──────────────────────┼──────────────┼────────────┼────────┼──────────┤
│ 12'  │ Fußvergehen 7→11     │ Freistoß     │ ✓ Erwartb. │ —      │   ⭐     │
│ 23'  │ Handspiel            │ Weiter       │ ✗ Komplex  │ —      │   ☆      │
│ 31'  │ Abseits              │ Abseits      │ ✓ Erwartb. │ —      │   ☆      │
│ 38'  │ Oberkörperverg. 4→9  │ Strafstoß    │ ✗ Komplex  │ Gelb   │   ⭐     │
│ 47'  │ Tätlichkeit 3→7      │ Rot          │ ✓ Komplex  │ Rot    │   ⭐     │
└──────┴──────────────────────┴──────────────┴────────────┴────────┴──────────┘
```

**Interaktion:** Tap auf Zeile → Detail/Bearbeiten. Tap auf ⭐/☆ → Coaching-Flag togglen.

---

### Screen 5 — Statistik: Heatmap + Zeitachse + Ranking

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  [Szenen]  [Coaching]  [Statistik ✓]                                        │
│  Filter: [Alle Typen ▼]  [Beide Teams ▼]                                    │
├──────────────────────────────────────────────┬──────────────────────────────┤
│                                              │ ZEITACHSE                    │
│        HEATMAP (Spielfeld-Draufsicht)        │                              │
│                                              │  0–15  ████░░░░  4 Ereign.  │
│     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░         │ 15–30  ██████░░  6 Ereign.  │
│     ░░░░░▓▓░░░░░░░░░░░░░░░░░░░░░░░░         │ 30–45  ████████  8 Ereign.  │
│     ░░░░░▓█░░░░░░░░░░░░░▓░░░░░░░░░░         │ 45–60  ██░░░░░░  2 Ereign.  │
│     ░░░░░░░░░░░░░░░░░░░░▓▓░░░░░░░░░         │ 60–75  ████░░░░  4 Ereign.  │
│     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░         │ 75–90  ██████░░  6 Ereign.  │
│     ░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░         │                              │
│     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░         │ SPIELER-RANKING              │
│                                              │  #7  Heim  ████  5×          │
│  ░ = wenig   ▓ = mittel   █ = viel          │  #3  Gast  ███░  4×          │
│                                              │  #11 Gast  ██░░  3×          │
│                                              │  #4  Heim  █░░░  2×          │
└──────────────────────────────────────────────┴──────────────────────────────┘
```

---

## Interaktions-Spezifikationen

### Spielfeld-Tap → Ereignisformular

- Tap-Genauigkeit: Mindest-Tap-Zielgröße 44×44 pt (Apple HIG / Material Design)
- Marker wird sofort am Tap-Ort gesetzt (< 50 ms visuelles Feedback)
- Formular öffnet sich von rechts ein (Slide-In, 200 ms)
- Spielfeld wird leicht abgedunkelt (Overlay 30% schwarz), bleibt aber lesbar

### Spielerauswahl

- Vorerfasste Nummern als Chips/Buttons: Heim (Teamfarbe A), Gast (Teamfarbe B)
- Zwei Zeilen: „Fouler" und „Gefoulter"
- Nicht vorerfasste Nummer: Button „+" öffnet Ziffernblock (0–9), max. 2-stellig
- Tap auf bereits gewählten Button: deselektieren

### Entscheidungs-Grid

- 3×4-Grid (3 Spalten, 4 Zeilen)
- Button-Größe: mindestens 60×40 pt
- Gewählte Entscheidung: farbig hervorgehoben, erneuter Tap deselektiert

### 2×2-Bewertungs-Grid

- 4 gleichgroße Felder, Tap wählt genau ein Feld
- Korrekt-Felder: grün hinterlegt; Falsch-Felder: rot hinterlegt
- Erneuter Tap auf gewähltes Feld: deselektieren (keine Bewertung)

### Spieluhr

- Anzeige: `MM:SS` (z. B. `47:23`), Schriftgröße ≥ 32 pt
- Start/Stop: einzelner großer Button (`▶` / `■`), mindestens 80×60 pt
- Uhr läuft im Hintergrund (Plattform-Timer, kein App-Vordergrund erforderlich)
- Bei Tap auf Spielfeld während laufender Uhr: aktuelle Zeit wird sofort als Zeitstempel des Ereignisses eingefroren