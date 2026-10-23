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
  ├── Tab: Coaching-Ansicht  (US-306 / US-307)
  │     ├── Abschnitt „Allgemeine Notiz" (mehrzeilig, autosave bei FocusLoss)
  │     ├── [Kein Szenen-Hinweis wenn keine Szenen markiert]
  │     └── Pro markierter Szene (chronologisch):
  │           ├── Header-Zeile: Minute · Typ · Entscheidung · Bewertung · ⭐ Toggle
  │           ├── Szenennotiz (read-only, falls vorhanden, grau + 📋-Icon)
  │           └── Coaching-Notiz (inline TextField, autosave bei FocusLoss)
  │
  └── Tab: Statistik
        ├── Heatmap
        ├── Zeitachse
        └── Spieler-Ranking
```

---

### Screen 6 — Coaching-Ansicht (US-306 / US-307)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ◀ Spiele   Heimteam – Gastteam   30.04.2026   [Szenen][Coaching✓][Statistik]│
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ALLGEMEINE NOTIZ                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Eröffnungsworte, allgemeines Fazit …                                │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  12'  Fußvergehen · Freistoß · ✗ Komplex                              ⭐   │
│  📋  "War knapp aber klar Foul"                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Coaching-Notiz …                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────────────┤
│  38'  Oberkörpervergehen · Strafstoß · ✗ Komplex                      ⭐   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Positionierung war gut, aber Kontaktstärke übersehen                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────────────┤
│  47'  Tätlichkeit · Rot · ✓ Komplex                                   ⭐   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Coaching-Notiz …                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

**UX-Entscheidungen:**
- Allgemeine Notiz steht immer oben — auch wenn noch keine Szenen markiert sind
- Autosave bei FocusLoss: kein Speichern-Button, keine Bestätigung
- Szenennotiz (Live-Notiz) ist read-only und visuell abgesetzt (grau, 📋-Icon) — keine Verwechslung mit der editierbaren Coaching-Notiz
- Coaching-Flag (⭐) bleibt per Tap in der Zeile togglebar, ohne die Notizen-Felder zu schließen
- Ein demarkiertes Ereignis (☆ → ⭐ wieder aktiviert) erscheint sofort in der Liste (reaktiv über `eventsProvider`)

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
│          (tappable, Draufsicht)              │   43:12  Fußvergehen    🗑   │
│                                              │   ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄     │
│   ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·            │   38:40  Handspiel      🗑   │
│   ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·            │   ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄     │
│   ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·            │   31:05  Abseits        🗑   │
│   ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·            │   ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄     │
│   ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·            │   …  (weitere Zeilen bis     │
│   ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·            │       Panelende, danach      │
│                                              │       scrollbar ↕)           │
│                    ✕ (Ereignismarker)        │                              │
│                                              │                              │
└──────────────────────────────────────────────┴──────────────────────────────┘
```

**Interaktion:** Tap auf beliebige Stelle des Spielfelds → Ereignisformular öffnet sich als Side Panel (rechts), Spielfeld bleibt sichtbar.

**Ereignisliste im Seitenpanel (US-213):**
- Liste zeigt alle Ereignisse, neuestes oben, und füllt die volle Panelhöhe — Anzahl sichtbarer Zeilen hängt von der Bildschirmhöhe ab
- Mehr Ereignisse als Platz → Liste scrollt; Überschrift „Letzte Ereignisse" + Trennlinie bleiben fix
- Zeilen min. 44 dp hoch, Schrift 14, dezente Trennlinie zwischen Zeilen — minimiert Fehltipps unter Zeitdruck
- Lösch-Button (🗑) mit Tippfläche ≥ 44 × 44 dp, Icon 22 dp

---

### Screen 2 — Ereignisformular (vor Typ-Auswahl)

```
┌──────────────────────────────────────────────┬──────────────────────────────┐
│                                              │ ⏱ 47:23  Ereignis erfassen ✕ │
│          SPIELFELD-SKETCH                    ├──────────────────────────────┤
│          (abgedunkelt, Marker sichtbar)      │ EREIGNISTYP                  │
│                                              │ [Fußverg.] [Körperverg.]     │
│                    ✕ ← Marker                │ [Handsp.]  [Unsptl.] [Tätk.] │
│                                              │ [Abseits]  [Vorteil] [Tor]   │
│                                              │ [Sonstiges              ]    │
│                                              ├──────────────────────────────┤
│                                              │                              │
│                                              │  Typ auswählen, dann         │
│                                              │  speichern                   │
│                                              │                              │
│                                              ├──────────────────────────────┤
│                                              │       [▶ SPEICHERN]  (inakt.)│
└──────────────────────────────────────────────┴──────────────────────────────┘
```

**Verhalten vor Typ-Auswahl:** Nur Typ-Grid + inaktiver Speichern-Button sichtbar. Kein Scrollen erforderlich. Zeitstempel wird beim Öffnen des Formulars eingefroren (nicht erst beim Speichern).

---

### Screen 3 — Ereignisformular (Typ gewählt, Foul-Szenario)

```
┌──────────────────────────────────────────────┬──────────────────────────────┐
│                                              │ ⏱ 47:23  Ereignis erfassen ✕ │
│          SPIELFELD-SKETCH                    ├──────────────────────────────┤
│          (abgedunkelt)                       │ EREIGNISTYP                  │
│                                              │ [Fußverg.✓] [Körperverg.]    │
│                    ✕                         │ [Handsp.]  [Unsptl.] [Tätk.] │
│                                              │ [Abseits]  [Vorteil] [Tor]   │
│                                              ├──────────────────────────────┤
│                                              │ SPIELER                      │
│                                              │ Fouler:  [H][G] #__ [5][9]   │
│                                              │ Gefoul.: [H][G] #__ [5][9]   │
│                                              ├──────────────────────────────┤
│                                              │ ENTSCHEIDUNG                 │
│                                              │[Freistoß][Ind.FS][Strafstoß] │
│                                              │[Vorteil ][Weiter][Gelb     ] │
│                                              │[GR      ][Rot   ][Ecke     ] │
│                                              │[Abstoß  ][Einw. ][Tor      ] │
│                                              ├──────────────────────────────┤
│                                              │ KARTE [Gelb][GR][Rot]        │
│                                              │                    Coaching ☆│
│                                              ├──────────────────────────────┤
│                                              │ BEWERTUNG                    │
│                                              │ ┌──────────┬───────────────┐ │
│                                              │ │ Korrekt  │  Korrekt      │ │
│                                              │ │ Erwartb. │  Komplex      │ │
│                                              │ ├──────────┼───────────────┤ │
│                                              │ │  Falsch  │   Falsch      │ │
│                                              │ │ Erwartb. │   Komplex     │ │
│                                              │ └──────────┴───────────────┘ │
│                                              ├──────────────────────────────┤
│                                              │ [+ Notiz]                    │
│                                              │        [▶ SPEICHERN]         │
└──────────────────────────────────────────────┴──────────────────────────────┘
```

**Verhalten nach Typ-Auswahl:**
- Felder erscheinen per AnimatedSwitcher (Fade, 150 ms)
- Spieler-Sektion nur bei Foul-Typen (Fuß-/Körpervergehen, Handspiel, Unsportl., Tätlichkeit)
- Spielernummern als horizontale Chip-Leiste scrollbar (Squad-Nummern), ergänzend ein `#`-Freitextfeld
- KARTE und Coaching-Flag (☆/⭐) in einer gemeinsamen Zeile — spart vertikale Höhe
- Coaching-Flag im Formular setzbar (statt nur in der Nachbereitung)
- Kein Scrollen des gesamten Panels auf Ziel-Tablets (Querformat); SingleChildScrollView als Sicherheitsnetz für sehr kleine Bildschirme
- Zeitstempel = Moment des Feldtipps (eingefroren beim Öffnen des Formulars)
- „+ Notiz" klappt ein Textfeld auf (Tastatur erscheint erst dann)

---

### Screen 3b — Torentscheidung & Spielstand (US-214)

**Flow 6 — Tor erfassen:**

```
Feldtipp (Tor-Position)
  → Typ „Torentsch." antippen          (Entscheidung „Tor" automatisch vorausgewählt)
  → Torschützen-Team [Heim]/[Gast]     (Pflicht für Spielstand)
  → optional: Nummer (Kader-Chip / #)
  → optional: [⚽ Eigentor]
  → Vorschau-Zeile prüfen
  → Speichern                          → Kopfzeile zeigt neuen Spielstand (kurz hervorgehoben)
```

Minimaler Pfad: **4 Taps** (Feld → Torentsch. → Team → Speichern).

**Kopfzeile Live-Screen:**

```
┌──────────────────────────────────────────────────────────────┐
│  ◀              FC Musterstadt – SV Beispiel            ☰     │
│                         2 : 1                                 │
│                [ 1. HZ   23:41   ■ ]                          │
└──────────────────────────────────────────────────────────────┘
```

**Ereignisformular, Typ Torentscheidung:**

```
┌ 🕐 23:41   Ereignis erfassen                      ✕ ┐
│ EREIGNISTYP                                          │
│ [Fußverg.] [Handspiel] … [Torentsch. ✓] [Sonstiges]  │
│ ──────────────────────────────────────────────────── │
│ TOR                                                  │
│ Torschütze  [Heim ✓] [Gast]  [ # ]  #7  #9✓  #11 …   │
│             [ ⚽ Eigentor ]                           │
│ ┌──────────────────────────────────────────────────┐ │
│ │  Tor für HEIM · #9  →  2 : 1                     │ │
│ └──────────────────────────────────────────────────┘ │
│ ──────────────────────────────────────────────────── │
│ ENTSCHEIDUNG   … [Tor ✓] …                           │
│ … Karte · Bewertung · Notiz wie bisher …             │
│ [            ✓ Speichern            ]                │
└──────────────────────────────────────────────────────┘
```

**Vorschau-Zeile (Zustände):**

| Zustand | Text | Farbe |
|---------|------|-------|
| Tor zählt | „Tor für HEIM · #9 → 2 : 1" | grün |
| Eigentor | „Eigentor #4 (Heim) → Tor für GAST · 1 : 2" | grün |
| Entscheidung ≠ Tor | „Tor aberkannt – Spielstand bleibt 1 : 1" | grau |
| Entscheidung = Tor, kein Team | „Team wählen, damit das Tor zählt" | orange |

**UX-Entscheidungen:**
- Spielstand ist abgeleitet (aus Ereignissen berechnet), nie separat gespeichert — kann nicht auseinanderlaufen; Löschen/Bearbeiten wirken automatisch
- Zählt nur bei Entscheidung „Tor" — aberkannte Tore (Abseits, Foul) bleiben als Szene erfasst, ändern aber den Stand nicht
- Eigentor: Team/Nummer beschreiben den Spieler, der den Ball ins eigene Tor lenkt (so wie man es auf dem Platz sieht); die Gutschrift an den Gegner macht die App
- Vorschau-Zeile macht die Gutschrift vor dem Speichern sichtbar — verhindert vertauschte Teams, besonders bei Eigentoren
- Speichern ohne Team erlaubt (orange Hinweis statt Blockade) — kein Zeitdruck-Hindernis
- Spielstand-Highlight (~0,6 s) beim Wechsel dient als periphere Bestätigung
- Seitenpanel: gezählte Tore als „⚽ Tor 2:1" (Stand nach dem Tor), aberkannte als „Torentsch."
- Torschütze wird nicht als Spieler-Rolle gespeichert → erscheint nicht im Foul-Ranking

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

**Heatmap-Darstellung (KDE):**

- Die Heatmap wird als kontinuierliche Dichteverteilung gerendert (Kernel Density Estimation), nicht als festes Zonenraster. Jedes Ereignis trägt eine weiche Gauß-Glocke bei; Überlagerungen addieren sich.
- Farbrampe nach Dichte: transparent (keine Dichte) → gelb (niedrig) → orange (mittel) → rot (Maximum). Hotspots erscheinen dadurch punktgenau und intensiv, ohne sichtbare Rasterkanten.
- Einzelereignisse bleiben als weiche gelbe Flecken sichtbar (Mindest-Deckkraft), damit auch spärlich belegte Bereiche lesbar sind.
- Grüner Rasen und vereinfachte Feldlinien (Außenlinie, Mittellinie) bleiben als Untergrund bzw. durchscheinendes Overlay erhalten.

### Screen 5b — Vergehen pro Team und Halbzeit (US-404)

Rechte Spalte des Statistik-Tabs, unterhalb des Spieler-Rankings:

```
┌──────────────────────────────┐
│ SPIELER-RANKING              │
│  1. [H] #7              5×   │   ← scrollbar, füllt Resthöhe
│  2. [G] #3              4×   │
│  …                           │
├──────────────────────────────┤
│ VERGEHEN PRO TEAM            │   ← feste Höhe, nicht scrollbar
│               1. HZ   2. HZ  │
│               H   G   H   G  │
│ Fußvergehen   3   1   2   4  │
│ Oberkörperv.  0   2   1   1  │
│ Andere        1   0   0   2  │
│ ──────────────────────────── │
│ Summe         4   3   3   7  │
└──────────────────────────────┘
```

Mit Verlängerung kommt rechts eine Spaltengruppe „Verl." (H | G) hinzu.

**UX-Entscheidungen:**
- Spaltenköpfe „H"/„G" in Teamfarbe (Heim blau, Gast rot) — konsistent mit dem Spieler-Ranking
- Zahlen rechtsbündig, Summenzeile fett und durch Trennlinie abgesetzt
- Nullwerte werden als „0" angezeigt (nicht leer), damit die Tabelle auf einen Blick vollständig lesbar ist
- Die Tabelle ist reine Anzeige ohne Interaktion; Filterung bleibt der Szenenliste vorbehalten
- „Andere" = Handspiel, Unsportlichkeit, Tätlichkeit, Sonstiges. Abseits, Vorteil und Torentscheidung sind keine Vergehen im Sinne der Tabelle

**Auswirkung auf das Ereignisformular:** Ein Tap auf „H"/„G" beim Fouler bzw. Gefoulten wird jetzt auch ohne Rückennummer gespeichert. Die Bedienung selbst ändert sich nicht.

---

### Spielliste — Laufendes Spiel fortsetzen (US-109)

```
┌──────────────────────────────────────────────────┐
│ Beobachter                                       │
├──────────────────────────────────────────────────┤
│ ⚽ FC A – SV B   [Läuft]          ›   🗑          │  ← Tap → Live-Screen
│    22.10.2026 · 14 Ereignisse                    │
│ ⚽ TuS C – VfL D [Beendet]        ›   🗑          │  ← Tap → Nachbereitung
│    15.10.2026 · 31 Ereignisse                    │
│ ⚽ SC E – FC F                    ›   🗑          │  ← Tap → Nachbereitung
│    29.10.2026 · 0 Ereignisse                     │
└──────────────────────────────────────────────────┘
```

**Flow:**
```
Live-Screen ──[Zurück]──► Spielliste ──[Tap auf „Läuft"-Spiel]──► Live-Screen
                                                                   (Uhr, Phase, Spielstand unverändert)
```

**Zuordnung Phase → Ziel:**

| Phase | Badge | Tap öffnet |
|-------|-------|------------|
| keine / `bereit` | — | Nachbereitung |
| 1. HZ … Verlängerung, inkl. Pausen, Nachspielzeit und `beendet`/`beendetVerlaengerung` | „Läuft" (grün) | Live-Screen |
| `abgeschlossen` | „Beendet" (grau) | Nachbereitung |

**UX-Entscheidungen:**
- Ein Tap, kein Zwischendialog — nach einem versehentlichen „Zurück" zählt jede Sekunde
- Das Badge „Läuft" zeigt vor dem Tippen, wohin der Tap führt; Form und Größe wie „Beendet", Farbe grün
- Auch nach dem Abpfiff (vor „Spiel beenden") gilt das Spiel als laufend, weil „Verlängerung" und „Spiel beenden" nur im Live-Screen erreichbar sind
- Die Uhr wird beim Öffnen nicht angefasst: Der Timer ist zeitstempelbasiert und rechnet die verstrichene Zeit selbst nach

---

### Live-Screen — Aufstellung korrigieren (US-110)

Kopfzeile des Live-Screens, rechts: `[👥 Aufstellung]  [☰ Szenen]`

```
┌───────────────────────────────────────────────────────────┐
│  Aufstellung                                              │
│                                                           │
│  HEIM (blau)                    GAST (rot)                │
│  [ Rückennr. 1–99 ]  [+]        [ Rückennr. 1–99 ]  [+]   │
│  (#1 ✕)(#4 ✕)(#7 ✕)(#9 ✕)       (#1 ✕)(#3 ✕)(#10 ✕)       │
│  (#14 ✕)(#23 ✕)                 (#17 ✕)                   │
│                                                           │
│                                              [ Fertig ]   │
└───────────────────────────────────────────────────────────┘
```

**Flow:**
```
Live-Screen ──[👥]──► Dialog „Aufstellung" ──[Nummer + Enter/„+"]──► Chip erscheint (sofort gespeichert)
                                           ──[✕ an Chip]─────────► Chip verschwindet (sofort gespeichert)
                                           ──[Fertig]────────────► Live-Screen (Uhr lief weiter)
```

**UX-Entscheidungen:**
- Dialog statt eigener Seite: Live-Screen und Uhr bleiben im Hintergrund sichtbar, Rückkehr mit einem Tap
- Beide Teams nebeneinander — kein Team-Umschalter, weniger Taps
- Enter fügt die Nummer hinzu und leert das Feld; der Fokus bleibt im Feld, sodass mehrere Nummern hintereinander eingetippt werden können
- Sofort speichern, kein „Abbrechen": Es gibt nichts zu verwerfen, und ein vergessenes „Speichern" kann keine Nummern kosten
- Ungültige Eingaben (außerhalb 1–99, keine Zahl) und Duplikate werden still ignoriert — keine Fehlermeldung im Zeitdruck
- Entfernen einer Nummer ändert keine erfassten Szenen; die Nummer steht dort als Wert, nicht als Verweis
- Eingabe und Chips sind dasselbe Widget wie im Bearbeiten-Bildschirm (Screen „Spiel anlegen")

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

- Anzeige: `MM:SS` (z. B. `47:23`) in der regulären Spielzeit, Schriftgröße ≥ 32 pt
- In der Nachspielzeit wechselt die Anzeige automatisch auf `45+X` / `90+X` / `105+X` / `120+X`
- Phase-Label direkt unter der Zeit (z. B. „1. Halbzeit", „Nachspielzeit", „Halbzeitpause")
- Phasen-Button rechts neben der Uhr: beschriftungsabhängig von aktuellem Zustand (s. Flow 5)
- Uhr läuft im Hintergrund (Plattform-Timer, kein App-Vordergrund erforderlich)

---

### Flow 5 — Spielphasen-Steuerung (US-210 / US-211 / US-212)

#### Zustandsmaschine

```
[BEREIT]
   │ ▶ Start
   ▼
[1. HALBZEIT]  ──── automatisch bei 45:00 ────▶  [1. HZ NACHSPIELZEIT]
                                                          │ ⏸ Halbzeit
                                                          ▼
                                                  [HALBZEITPAUSE]
                                                          │ ▶ 2. HZ starten
                                                          ▼
[2. HALBZEIT]  ◀────────────────────────────────────────┘
   │                                   automatisch bei 90:00
   └──── automatisch bei 90:00 ────▶  [2. HZ NACHSPIELZEIT]
                                                          │ ⏸ Abpfiff
                                                          ▼
                                                  [BEENDET]
                                                 /         \
                        ⏹ Spiel beenden        /           \ ▶ Verlängerung starten
                        (mit Bestätigung)     /             ▼
                                 [ABGESCHLOSSEN]    [VERL. 1. HZ]  ──▶  [VERL. 1. HZ NS]
                                                                               │ ⏸ HZ (Verl.)
                                                                               ▼
                                                                    [VERL. HALBZEIT]
                                                                               │ ▶ 2. Verl. starten
                                                                               ▼
                                                                    [VERL. 2. HZ]  ──▶  [VERL. 2. HZ NS]
                                                                                               │ ⏸ Abpfiff
                                                                                               ▼
                                                                                     [BEENDET n. VERL.]
                                                                                               │ ⏹ Spiel beenden
                                                                                               │ (mit Bestätigung)
                                                                                               ▼
                                                                                     [ABGESCHLOSSEN]
```

`ABGESCHLOSSEN` ist ein Endzustand: keine weiteren Phasen-Übergänge, Spieluhr eingefroren, keine neue Ereigniserfassung. Nachbereitung (Szenen, Coaching, Statistik) bleibt vollständig zugänglich.

#### Phasen-Tabelle: Zeitanzeige und Steuerbutton

| Phase | Zeitanzeige | Phase-Label | Button (rechts) |
|-------|-------------|-------------|-----------------|
| Bereit | `00:00` | — | `▶ Start` |
| 1. Halbzeit | `MM:SS` (0–44:59) | 1. Halbzeit | `⏸ Halbzeit` |
| 1. HZ Nachspielzeit | `45+01`, `45+02`, … | Nachspielzeit | `⏸ Halbzeit` |
| Halbzeitpause | eingefroren | Halbzeitpause | `▶ 2. HZ starten` |
| 2. Halbzeit | `MM:SS` (45:00–89:59) | 2. Halbzeit | `⏸ Abpfiff` |
| 2. HZ Nachspielzeit | `90+01`, `90+02`, … | Nachspielzeit | `⏸ Abpfiff` |
| Beendet (regulär) | eingefroren | Beendet | `▶ Verlängerung` + `⏹ Spiel beenden` |
| Verl. 1. HZ | `MM:SS` (90:00–104:59) | Verl. 1. HZ | `⏸ HZ (Verl.)` |
| Verl. 1. HZ NS | `105+01`, … | Nachspielzeit | `⏸ HZ (Verl.)` |
| Verl. Halbzeit | eingefroren | Verl. Halbzeit | `▶ 2. Verl. starten` |
| Verl. 2. HZ | `MM:SS` (105:00–119:59) | Verl. 2. HZ | `⏸ Abpfiff (Verl.)` |
| Verl. 2. HZ NS | `120+01`, … | Nachspielzeit | `⏸ Abpfiff (Verl.)` |
| Beendet (n. Verl.) | eingefroren | Beendet | `⏹ Spiel beenden` |
| Abgeschlossen | eingefroren | Abgeschlossen | — |

#### Wireframes — Live-Screen Header je Phase

```
── 1. Halbzeit (23:45) ─────────────────────────────────────────────────────
│  ◀ Spiele    Heimteam  ·  23:45  ·  1. Halbzeit  ·  Gastteam  [⏸ HALBZEIT]  │

── 1. HZ Nachspielzeit ──────────────────────────────────────────────────────
│  ◀ Spiele    Heimteam  ·  45+02  ·  Nachspielzeit  ·  Gastteam [⏸ HALBZEIT]  │

── Halbzeitpause ────────────────────────────────────────────────────────────
│  ◀ Spiele    Heimteam  ·  45+03  ·  Halbzeitpause  ·  Gastteam [▶ 2. HZ]    │

── 2. Halbzeit (67:12) ──────────────────────────────────────────────────────
│  ◀ Spiele    Heimteam  ·  67:12  ·  2. Halbzeit  ·  Gastteam  [⏸ ABPFIFF]   │

── 2. HZ Nachspielzeit ──────────────────────────────────────────────────────
│  ◀ Spiele    Heimteam  ·  90+02  ·  Nachspielzeit  ·  Gastteam [⏸ ABPFIFF]  │

── Beendet (regulär) ────────────────────────────────────────────────────────
│  ◀ Spiele  Heimteam · 90+03 · Beendet · Gastteam [▶ VERLÄNGERUNG] [⏹ SPIEL BEENDEN] │

── Verlängerung 1. HZ (97:30) ───────────────────────────────────────────────
│  ◀ Spiele    Heimteam  ·  97:30  ·  Verl. 1. HZ   ·  Gastteam [⏸ HZ (VERL.)] │

── Verlängerung 1. HZ Nachspielzeit ─────────────────────────────────────────
│  ◀ Spiele    Heimteam  · 105+01  ·  Nachspielzeit  ·  Gastteam [⏸ HZ (VERL.)] │

── Verlängerung 2. HZ (112:15) ──────────────────────────────────────────────
│  ◀ Spiele    Heimteam  · 112:15  ·  Verl. 2. HZ   ·  Gastteam [⏸ ABPFIFF (VERL.)] │

── Verlängerung 2. HZ Nachspielzeit ─────────────────────────────────────────
│  ◀ Spiele    Heimteam  · 120+02  ·  Nachspielzeit  ·  Gastteam [⏸ ABPFIFF (VERL.)] │

── Beendet nach Verlängerung ────────────────────────────────────────────────
│  ◀ Spiele    Heimteam  · 120+03  ·  Beendet        ·  Gastteam [⏹ SPIEL BEENDEN] │

── Abgeschlossen ────────────────────────────────────────────────────────────
│  ◀ Spiele    Heimteam  ·  90+03  ·  Abgeschlossen  ·  Gastteam              │
```

#### Bestätigungsdialog „Spiel beenden" (US-212)

```
┌─────────────────────────────────────────────┐
│  Spiel endgültig beenden?                   │
│                                             │
│  Das Spiel kann danach nicht erneut         │
│  gestartet werden. Szenen, Notizen und      │
│  Statistik bleiben weiterhin verfügbar.     │
│                                             │
│                  [Abbrechen]  [Beenden]     │
└─────────────────────────────────────────────┘
```

**UX-Entscheidungen:**
- Phase-Label und Zeitanzeige sind immer sichtbar — kein Suchen, kein Modal
- Während des laufenden Spiels genau **ein** Phasen-Button sichtbar: kontextsensitiv und eindeutig beschriftet. Einzige Ausnahme: nach dem Abpfiff (Spiel steht, keine Zeitnot) stehen „Verlängerung" und „Spiel beenden" nebeneinander
- „Verlängerung starten" erscheint erst nach regulärem Abpfiff — kein versehentlicher Tap während des Spiels
- „Spiel beenden" ist irreversibel und verlangt daher eine Bestätigung — nach dem Abpfiff ist die Zeitkritik des Live-Betriebs vorbei, der Dialog stört nicht (US-212)
- Im abgeschlossenen Spiel öffnet ein Feldtipp kein Ereignisformular mehr; die Nachbereitung (Szenen bearbeiten, Coaching-Notizen, Statistik) bleibt unverändert nutzbar
- In der Spielliste trägt ein abgeschlossenes Spiel ein „Beendet"-Badge; der Tap führt zur Nachbereitung (laufende Spiele: siehe US-109)
- Phasen-Button mindestens **120×48 pt** — sicher tappbar auch mit ablenktem Blick
- Automatischer NS-Wechsel läuft unhörbar/visuell (Anzeige wechselt, kein Dialog, kein Ton)

---

## Plattformverhalten — Fensterverwaltung (US-107)

### Grundsatz

Die UI ist ausschließlich für **Tablet-Querformat in fester Größe** gestaltet. Ein responsives Layout für beliebige Fenstergrößen ist nicht vorgesehen und würde die One-Tap-Bedienung im Live-Betrieb gefährden.

### Verhalten je Plattform

| Plattform | Verhalten |
|-----------|-----------|
| **Windows (Surface)** | App startet maximiert; Resize-Handles deaktiviert; Minimieren erlaubt |
| **macOS** | App startet maximiert; Resize-Handles deaktiviert; Minimieren in Dock erlaubt (US-108) |
| **iOS** | Vollbild vom Betriebssystem erzwungen — keine App-seitige Änderung |
| **Android** | Vollbild vom Betriebssystem erzwungen — keine App-seitige Änderung |

### UX-Entscheidungen

- **Kein Restore-Button / kein „Fenstermodus"** — die App hat keinen Kleinfenster-Modus; ein Restore würde ebenfalls maximiert landen
- **Minimieren erlaubt** — der Beobachter muss kurz zu anderen Windows-Apps wechseln können (z. B. Kalender, Notizen)
- **Kein Vollbild im F11-Sinne** — das Windows-Titlelbar bleibt sichtbar (native Tablet-UX auf Surface); nur die Fenstergröße ist fixiert
- **Kein explizites Nutzer-Feedback** — das Verhalten ist erwartungskonform und braucht keinen Toast oder Dialog
- Bei Tap auf Spielfeld während laufender Uhr: aktuelle Zeit wird sofort als Zeitstempel des Ereignisses eingefroren
---

## UI-Redesign — Epic 6 (US-601 – US-606)

> Ersetzt die visuellen Vorgaben der früheren Abschnitte. Flows, Navigation, Felder und Verhalten bleiben unverändert.
> Plan und Begründungen: [`23_ui_redesign_plan.md`](23_ui_redesign_plan.md).

### Grundsätze

| Thema | Vorgabe |
|---|---|
| Theme | **Ein helles Theme für alle Screens** (Außeneinsatz bei Tageslicht). Kein Dark Theme. |
| Schrift | Inter, gebündelt. Ziffern für Uhr, Spielstand und Rückennummern gleich breit. |
| Größen | Fließtext ≥ 14 pt, Beschriftungen ≥ 12 pt. Tippflächen ≥ 48 dp, im Live-Screen ≥ 56 dp, Primäraktionen ≥ 64 dp. |
| Kontrast | Text ≥ 4,5:1 zum Hintergrund. |
| Daumenzonen | Zeitkritische Aktionen an der linken bzw. rechten Kante unten. Oben nur Anzeige. |
| Rückmeldung | Nur visuell. Keine Vibration, kein Ton. |

### Farben mit fester Bedeutung

| Token | Bedeutung | Wert |
|---|---|---|
| `primary` | Markenfarbe, Start-Aktionen | Dunkelgrün `#1B6B3A` |
| `home` / `away` | Heim / Gast | Blau `#1D4ED8` / Rot `#C2261D` |
| `correct` / `wrong` | Bewertung korrekt / falsch | Grün `#15803D` / Rot `#B91C1C` |
| `yellowCard` · `yellowRedCard` · `redCard` | Karten | `#FACC15` · `#EA580C` · `#B91C1C` |
| `coaching` | Coaching-Stern | Amber `#F59E0B` |
| `phaseStart` · `phasePause` · `phaseStop` · `phaseFinish` | Phasen-Buttons | Grün · Orange `#C2410C` · Rot · Schiefer `#334155` |
| `pitch` | Spielfeld | Rasengrün mit Streifen |

### Wireframe — Live-Screen (ersetzt Screen 1)

```
┌──────────────────────────────────────────────────────────────────────────┐
│  FC Heim              2 : 1              SV Gast        ● 2. HZ   67:12  │  Anzeige, keine Buttons
├────────────────────────────────────────────────┬─────────────────────────┤
│                                                │ LETZTE EREIGNISSE       │
│                                                │ 67:12  Fußvergehen   🗑 │  Zeilen ≥ 56 dp
│               S P I E L F E L D                │ 61:03  ⚽ Tor 2:1    🗑 │
│        Rasenstreifen · Marker in Typ-Farbe     │ 54:40  Abseits       🗑 │
│                                                │                         │
├────────────────────────────────────────────────┤                         │
│ [ ■  Abpfiff      ] [👥 Aufstellung] [≡ Szenen] │                         │
└────────────────────────────────────────────────┴─────────────────────────┘
  linker Daumen                                     rechter Daumen
```

- Phasen-Button **≥ 160 × 64 dp** (ersetzt die frühere Vorgabe 120 × 48 pt). Bei zwei Buttons nach dem Abpfiff („Verlängerung", „Spiel beenden") stehen beide nebeneinander in der Aktionsleiste.
- Ein pulsierender Punkt vor der Phase zeigt eine laufende Uhr. In Pausen ist der Punkt statisch.
- „Aufstellung" und „Szenen" sind beschriftete Tonal-Buttons (≥ 56 dp).

### Wireframe — Ereignisformular (ersetzt Screen 2/3)

```
┌──────────────────────────────┐
│ ⏱ 67:12  Ereignis erfassen ✕ │
├──────────────────────────────┤
│ EREIGNISTYP                  │
│ [Fuß    ][Oberk.  ][Hand    ]│  Kacheln ≥ 56 dp, Icon + Label
│ [Unspor.][Tätl.   ][Abseits ]│
│ [Vorteil][Tor     ][Sonst.  ]│
├──────────────────────────────┤
│ SPIELER                      │
│ Täter     [Heim|Gast] # 7 9 …│  Umschalter ≥ 56 dp, Chips ≥ 48 × 48
│ Gefoult   [Heim|Gast] # 4 5 …│
│ ENTSCHEIDUNG                 │
│ [FS ][IFS][11m][Vort.]…      │  Raster ≥ 56 dp
│ KARTE  [Gelb][G-R][Rot]   ☆  │
│ BEWERTUNG                    │
│ [✓ Erwartbar][✓ Komplex]     │  ≥ 64 dp, ✓/✗ zusätzlich zur Farbe
│ [✗ Erwartbar][✗ Komplex]     │
│ + Notiz                      │
├──────────────────────────────┤
│ [       ■ Speichern        ] │  fix unten, ≥ 64 dp
└──────────────────────────────┘
```

### Wireframe — Spielliste

```
┌──────────────────────────────────────────────────────────────┐
│ Beobachter                                                   │
├──────────────────────────────────────────────────────────────┤
│ ┌───────────────────────────┐ ┌───────────────────────────┐  │
│ │ ⚽ FC Heim                 │ │ ⚽ TuS A                    │  │
│ │    SV Gast         ● Läuft│ │    SC B           Beendet │  │
│ │ 23.10.2026 · 12 Ereignisse│ │ 16.10.2026 · 31 Ereign.   │  │
│ │                     🗑    │ │                     🗑    │  │
│ └───────────────────────────┘ └───────────────────────────┘  │
│                                          [ + Neues Spiel ]   │
└──────────────────────────────────────────────────────────────┘
```

### Wireframe — Spiel-Setup

```
┌──────────────────────────────────────────────────────────────┐
│ ← Spiel einrichten                                           │
├──────────────────────────────────────────────────────────────┤
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ ⬆ Aus Pressebericht importieren                          │ │
│ └──────────────────────────────────────────────────────────┘ │
│ SPIELDATEN                    │ AUFSTELLUNG HEIM             │
│ [Heimmannschaft      ]        │ [Rückennummer] [+]           │
│ [Gastmannschaft      ]        │ #1 #4 #7 …                   │
│ [Liga] [Spieltag]             │ AUFSTELLUNG GAST             │
│ [Spielort            ]        │ [Rückennummer] [+]           │
├──────────────────────────────────────────────────────────────┤
│                                       [ ▶ Spiel starten ]    │  fix sichtbar
└──────────────────────────────────────────────────────────────┘
```

### Wireframe — Statistik (ersetzt Screen 5)

```
┌──────────────────────────────┬───────────────────────────────┐
│ HEATMAP                      │ ZEITACHSE                     │
│ (KDE wie bisher)             │  ▆  ▃  █  ▂  ▅  ▇             │
│                              │ 0' 15' 30' 45' 60' 75'        │
├──────────────────────────────┼───────────────────────────────┤
│ SPIELER-RANKING              │ VERGEHEN PRO TEAM             │
│ 1. [H] #7   4×               │ (Tabelle wie bisher)          │
└──────────────────────────────┴───────────────────────────────┘
```

### Interaktions-Spezifikationen

| Moment | Verhalten |
|---|---|
| Seitenwechsel | Überblenden, ca. 350 ms |
| Formular öffnen / schließen | Gleitet von rechts ein bzw. aus, ca. 250 ms; das Spielfeld wird weich abgedunkelt |
| Tap aufs Spielfeld | Sofortiger Ring an der Tap-Stelle; neuer Marker erscheint mit kurzer Einblend-Animation |
| Auswahl (Typ, Entscheidung, Bewertung, Nummer) | Farbwechsel und kurze Größenanimation, 150 ms |
| Speichern | Kurzes Häkchen auf dem Button, dann schließt das Panel |
| Phasenwechsel | Farbe und Beschriftung des Buttons wechseln animiert |
| Statistik öffnen | Balken der Zeitachse wachsen hoch |
| „Bewegung reduzieren" aktiv | Alle Animationen entfallen |
| Grundregel | Eine laufende Animation blockiert nie einen Tap |

---

## Flow 6 — Tor erfassen (US-215)

Tore werden nicht mehr über das Spielfeld erfasst, sondern über je einen Button pro Team in der Kopfzeile. Das Team steht damit nach dem ersten Tap fest; alle weiteren Angaben sind optional.

```
Tap „+ Tor" (Heim)                     ← Spielzeit + Phase werden hier eingefroren
   ↓
Dialog „Tor für HEIM"
   ├─ Torart: [Standardtor]* [Eigentor] [Strafstoßtor]
   ├─ Torschütze: [#] + Kader-Chips
   │     Standard/Strafstoß → Kader des begünstigten Teams
   │     Eigentor          → Kader der verteidigenden Mannschaft
   ├─ Vorschau: „Tor für HEIM · #9 → 2 : 1"
   └─ [Abbrechen]   [Speichern]        ← schnellster Weg: 2 Taps
   ↓
Spielstand in der Kopfzeile leuchtet kurz auf, Tor erscheint oben in „Letzte Ereignisse"
```

### Wireframe — Kopfzeile mit Tor-Buttons

```
┌──────────────────────────────────────────────────────────────────────┐
│ [⚽ + Tor]      ● FC Heim – SV Gast ●      [⚽ + Tor]     ▶ 23:41     │
│  (Heimfarbe)           2 : 1                (Gastfarbe)   1. Halbzeit │
└──────────────────────────────────────────────────────────────────────┘
```

- Buttons mindestens 48 dp hoch, Teamfarbe als Füllung, links Heim, rechts Gast — entsprechend der Reihenfolge der Mannschaftsnamen
- Bei abgeschlossenem Spiel ausgegraut

### Wireframe — Tor-Dialog

```
┌──────────────────────────────────────────────┐
│ ● Tor für HEIM                     ⏱ 23:41   │
│   FC Heim                                    │
├──────────────────────────────────────────────┤
│ TORART                                       │
│ [ Standardtor ] [ Eigentor ] [ Strafstoßtor ]│
│                                              │
│ TORSCHÜTZE (HEIM)                 optional   │
│ [ # ]  #1 #4 #7 #9 #10 #11 …                 │
│                                              │
│ ✓ Tor für HEIM · #9 → 2 : 1                  │
├──────────────────────────────────────────────┤
│               [ Abbrechen ]  [ ✓ Speichern ] │
└──────────────────────────────────────────────┘
```

- Bei **Eigentor** lautet die Überschrift „TORSCHÜTZE (GAST · EIGENTOR)“; Chips in Gastfarbe; eine gewählte Nummer wird beim Wechsel der Torart verworfen
- Vorschau-Varianten: „Tor für HEIM · #9 (Strafstoß) → 2 : 1“, „Eigentor #4 (Gast) → Tor für HEIM · 2 : 1“
- Bearbeiten: gleicher Dialog, Titel „Tor bearbeiten“, vorausgefüllt, Zeit unverändert

### „Letzte Ereignisse" mit Toren

```
│ 52:10  ●  ⚽ 2:1 · #9 · 11m      🗑 │   ← Punkt in Teamfarbe, Tap = bearbeiten
│ 47:03  ●  Fußvergehen            🗑 │
│ 23:41  ●  ⚽ 1:1 · ET            🗑 │
```

- Tore und Ereignisse stehen gemeinsam chronologisch (Phase, dann Zeit), neuestes oben
- Kennzeichnung: „ET“ = Eigentor, „11m“ = Strafstoßtor

### Nachbereitung — Karte „Tore"

Im Statistik-Dashboard teilt sich die untere Reihe in Spieler-Ranking · **Tore** · Vergehen pro Team. Die Karte listet je Tor Minute, Team-Badge, Spielstand danach, Torschütze und Torart.
