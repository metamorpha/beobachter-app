# UI-Redesign — Plan

> Ziel: moderne, ruhige Oberfläche mit gut erreichbaren Buttons und flüssigen Übergängen.
> Rahmen: **Businesslogik, Persistenz und Navigation bleiben unverändert.** Es ändert sich nur, wie die Screens aussehen und sich anfühlen.
> Gerät: Tablet im Querformat (iOS, Android, Surface), feste Fenstergröße.

---

## 1. Leitplanken

| Bleibt unverändert | Ändert sich |
|---|---|
| `domain/`, `data/`, `core/` (Uhr, CSV-Parser) | `app.dart` (Theme) |
| `presentation/providers/providers.dart` (nur lesen) | `presentation/screens/**`, `presentation/widgets/**` |
| Navigation: dieselben Screens, Routen, Dialoge, Tabs | neu: `presentation/theme/` (Design-Tokens, Komponenten) |
| Alle `Key('…')`-Bezeichner und alle UI-Texte | `pubspec.yaml` nur für Font-Assets |
| DB-Schema (v6), Repository-Interfaces | Tests: neue Golden- und Accessibility-Tests |

**Sicherheitsnetz:** Die bestehenden Tests finden Widgets fast nur über Keys (153×) und Texte (72×). Bleiben Keys und Texte stabil, sichern die vorhandenen Tests ab, dass die Logik unberührt bleibt. Nach jeder Phase müssen `flutter analyze` und `flutter test` grün sein.

Nur wenige Tests hängen am Widget-Typ (`find.byType(ElevatedButton)`, `Container`, `Divider`, `Row`) oder an Icons (`star_rounded`, `delete_outline`, `cancel`, `sticky_note_*`). Diese Stellen werden beim Umbau einzeln angepasst, und zwar nur der Finder, nie die Erwartung.

---

## 2. Ist-Analyse

| # | Befund | Wirkung |
|---|---|---|
| 1 | **Kein zentrales Theme.** `app.dart` setzt nur `colorSchemeSeed: green`; jeder Screen nutzt eigene `Colors.green.shade800`, `grey.shade900` usw. | Uneinheitlicher Look, Farben schwer zu pflegen |
| 2 | **Hell/Dunkel gemischt:** Spielliste, Setup und Nachbereitung sind hell, der Live-Screen ist dunkel. | Bruch beim Wechsel zwischen Screens |
| 3 | **Phasen-Buttons oben in der AppBar** (Start, Halbzeit, Abpfiff …) | Wer das Tablet quer mit beiden Händen hält, erreicht die Mitte oben am schlechtesten, und gerade dieser Button wird unter Zeitdruck gebraucht |
| 4 | **„Aufstellung" und „Szenen" als kleine Icons oben rechts** | Schwer zu treffen, die Bedeutung ist nicht sofort klar |
| 5 | **Sehr kleine Schrift im Erfassungsformular:** Section-Labels 10 pt, Chips und Eingaben 11–12 pt | Auf dem Platz mit Blendung kaum lesbar |
| 6 | **Kleine Tap-Ziele:** Team-Toggles, Rückennummer-Chips und Karten-Icons unter 48 dp | Fehltipps bei abgelenktem Blick |
| 7 | **„Spiel starten" im Setup ganz unten im Scrollbereich** | Muss erst gesucht werden |
| 8 | **Statistik als lange Liste**, Zeitachse aus `LinearProgressIndicator`s | Wirkt technisch, im Querformat wird Platz verschenkt |
| 9 | **Kaum Bewegung:** nur ein `AnimatedContainer` beim Panel und der Score-Highlight | Zustandswechsel wirken abrupt |

---

## 3. Design-Prinzipien

1. **Daumenzonen zuerst.** Im Querformat liegen die gut erreichbaren Zonen an der **linken und rechten Kante, untere Hälfte**. Häufige und zeitkritische Aktionen gehören dorthin, seltene nach oben.
2. **Tap-Ziele:** mindestens 48 dp überall, **56 dp im Live-Screen**, 64 dp für Primäraktionen (Speichern, Phasenwechsel).
3. **Ein ruhiges System:** eine Farbpalette, eine Typo-Skala, ein Abstandsraster (4/8/12/16/24/32), Radien 12/16/24. Farbe trägt Bedeutung (Heim, Gast, korrekt, falsch, Karten) und dient nicht als Dekoration.
4. **Lesbar auf dem Platz:** **ein helles Theme für alle Screens**, weil die App überwiegend draußen bei Tageslicht genutzt wird. Kontrast mindestens 4,5:1 (WCAG AA), wichtige Bedienelemente eher 7:1. Fließtext mindestens 14 pt, Uhr und Spielstand groß mit tabellarischen Ziffern. Keine hellgrauen Texte auf Weiß, keine reinen Pastellflächen als einziges Unterscheidungsmerkmal.
5. **Bewegung mit Zweck:** 150 ms für Auswahl-Feedback, 250 ms für Panels, 350 ms für Seitenwechsel, Kurve `easeOutCubic`. `MediaQuery.disableAnimations` wird respektiert.
6. **Offline:** keine Laufzeit-Downloads, auch keine Fonts über `google_fonts`. Schriften werden als Asset gebündelt.

---

## 4. Design-Fundament (`presentation/theme/`)

```
presentation/theme/
  app_theme.dart       ThemeData (nur hell), alle Component-Themes
  app_colors.dart      Semantische Farben als ThemeExtension (home, away, correct, wrong, yellowCard, redCard, coaching, pitch…)
  app_spacing.dart     Abstands- und Radius-Konstanten
  app_motion.dart      Dauern + Kurven
  widgets/             Gemeinsame Bausteine (s. u.)
```

**Component-Themes** in einem `ThemeData`: `FilledButton`, `OutlinedButton`, `SegmentedButton`, `ChipTheme`, `CardTheme`, `InputDecorationTheme` (gefüllt, Radius 12), `DialogTheme`, `TabBarTheme`, `PageTransitionsTheme`.

**Gemeinsame Bausteine** ersetzen die vielen lokalen Varianten:

| Baustein | Ersetzt |
|---|---|
| `SelectTile` (großer Auswahl-Button mit Icon + Label, animierter Auswahlzustand) | `_SelectChip`, Typ- und Entscheidungs-Chips |
| `TeamSwitch` (Heim/Gast als `SegmentedButton`, 56 dp) | `_teamToggle` |
| `NumberPad`-Chips (Rückennummern, 48×48) | Rückennummern-Chips im Formular |
| `SectionHeader` | `_sectionLabel`, `_SectionTitle` |
| `StatCard` (Karte mit Titel + Inhalt für Statistik) | lose Spalten im Statistik-Tab |
| `PhaseActionButton` (64 dp, Farbe nach Phase) | `ElevatedButton` in `_PhaseButtons` |

**Schrift:** Inter, als Asset gebündelt (offline, auf allen Plattformen gleich), mit `FontFeature.tabularFigures()` für Uhr, Spielstand und Zahlen.

---

## 5. Screens

### 5.1 Live-Screen (höchste Priorität)

Die Phasensteuerung wandert nach **unten links**, Erfassung und Speichern bleiben **rechts**. So liegt jede Aktion unter einem Daumen.

```
┌──────────────────────────────────────────────────────────────────────────┐
│  FC Heim            2 : 1            SV Gast           ● 2. HZ  67:12    │  ← schlanke Scoreboard-Leiste (nur Anzeige)
├────────────────────────────────────────────────┬─────────────────────────┤
│                                                │ Letzte Ereignisse       │
│                                                │ 67'  Fußvergehen     🗑 │
│                 S P I E L F E L D              │ 61'  ⚽ Tor 2:1      🗑 │
│        (Rasenstreifen, Marker je Typ-Farbe,    │ 54'  Abseits         🗑 │
│         Tap → Ripple + Marker „ploppt")        │ …                       │
│                                                │                         │
│                                                │                         │
├────────────────────────────────────────────────┤                         │
│ [■ ABPFIFF        ]  [👥 Aufstellung] [≡ Szenen]│                         │
└────────────────────────────────────────────────┴─────────────────────────┘
   ↑ linker Daumen: Phase (64 dp, breit)            ↑ rechter Daumen
```

- **Hell statt dunkel:** Der Live-Screen verliert sein dunkles Design (`grey.shade900`). Hintergrund und Panels sind hell, das Spielfeld bleibt sattgrün als einzige große Farbfläche. Das Erfassungsformular und die Ereignisliste nutzen dunkle Schrift auf hellem Grund.
- **Scoreboard-Leiste oben:** Teams, Spielstand (Highlight bei Tor bleibt), Uhr und Phase als Pill (z. B. „● 2. HZ" pulsiert, solange die Uhr läuft). Hier gibt es keine Buttons mehr.
- **Aktionsleiste unten links:** Phasen-Button (`PhaseActionButton`, 64 dp, Farbe nach Aktion: grün für Start, orange für Halbzeit, rot für Abpfiff), daneben „Aufstellung" und „Szenen" als beschriftete Tonal-Buttons. Keys und Bestätigungsdialog bei „Spiel beenden" bleiben.
- **Spielfeld:** Rasenstreifen, weiche Linien, Marker in Farbe des Ereignistyps. Ein Tap zeigt sofort einen Ripple an der Tap-Stelle. Ist das Formular offen, wird das Feld per Fade abgedunkelt statt hart.
- **Seitenpanel:** Die Ereignisliste bekommt Kartenoptik, eine Zeitspalte mit tabellarischen Ziffern und Typ-Icons. Löschen bleibt als dauerhaft sichtbares Icon (UX-Vorgabe US-213, ≥ 44 dp → neu 48 dp).
- **Panel-Übergang:** Das Formular schiebt sich per `SlideTransition` + Fade von rechts ein (250 ms) und nicht nur per Breitenänderung.

### 5.2 Ereignis-Formular (`EventFormPanel`)

```
┌─────────────────────────────┐
│ 67:12 · Erfassung       ✕   │
├─────────────────────────────┤
│ ┌──────┐┌──────┐┌──────┐    │  Ereignistyp: 3×3-Raster, Icon + Label, 56 dp
│ │ 🦶   ││ 💪   ││ ✋   │    │
│ │ Fuß  ││Oberk.││ Hand │    │
│ └──────┘└──────┘└──────┘    │
│ …                           │
├ Spieler ────────────────────┤
│ Täter   [Heim|Gast]  7 9 10…│  Rückennummern 48×48
│ Opfer   [Heim|Gast]  4 5 6 …│
├ Entscheidung ───────────────┤
│ [Freistoß][Indir.][Strafst.]│  4-spaltiges Raster, 56 dp
│ …                           │
├ Bewertung ──────────────────┤
│ [✓ erwartbar][✓ komplex]    │  2×2, 64 dp, klare Farben
│ [✗ erwartbar][✗ komplex]    │
├─────────────────────────────┤
│ [ Abbrechen ] [■ SPEICHERN ]│  sticky, 64 dp, rechts unten = rechter Daumen
└─────────────────────────────┘
```

- Reihenfolge und Inhalt der Felder bleiben, ebenso `_canSave`, Edit-Modus und alle Keys.
- Die Schrift steigt von 10–12 pt auf 14–16 pt, die Section-Header werden deutlicher.
- Auswahl-Feedback: Die Kachel skaliert kurz (0,96 → 1,0), dazu ein Farbwechsel über 150 ms. Es gibt keine Vibration.
- Speichern: kurze Bestätigungsanimation (Häkchen), danach schließt das Panel. Eine Undo-SnackBar gibt es im Code nicht, und das Redesign führt auch keine ein, weil das neue Logik wäre.

### 5.3 Spielliste

- Spiele als **Karten**: Teams groß, Spielstand, Datum, Liga/Spieltag klein, Phasen-Badge („Läuft" pulsiert grün, „Beendet" neutral).
- Landscape: 2-spaltiges Raster statt einer Liste über die volle Breite.
- Leerer Zustand mit Illustration und Hinweis auf „Neues Spiel".
- FAB „Neues Spiel" bleibt unten rechts, vergrößert. Das Lösch-Icon bleibt dauerhaft sichtbar (UX-Vorgabe US-106).

### 5.4 Spiel-Setup

- **Zwei Spalten:** links die Spieldaten, rechts die beiden Aufstellungen. Heute ist alles eine lange Spalte.
- Der CSV-Import wird eine **hervorgehobene Karte** ganz oben („Pressebericht importieren").
- **„Spiel starten" als fixierte Aktionsleiste unten rechts**, immer sichtbar und nicht mehr am Ende des Scrollbereichs.
- Die Import-Warnung wird ein einheitliches Banner im Theme-Stil.

### 5.5 Nachbereitung (Szenen · Coaching · Statistik)

- Die Tabs bleiben, gestylt per `TabBarTheme` mit Pill-Indikator.
- **Szenen:** Karten mit Zeit-Badge links, Typ und Entscheidung, Bewertungs-Pill, Karten-Symbol. Die Aktionen Bearbeiten und Coaching-Stern werden 48 dp groß und rechtsbündig. Die Filterleiste nutzt `FilterChip`s mit Zähler, aktive Filter sind einzeln entfernbar (wie bisher).
- **Coaching:** Karten mit Szenennotiz (read-only) und darunter einem Inline-Editor für die Coaching-Notiz. Die allgemeine Notiz steht oben als eigene Karte.
- **Statistik:** 2×2-**Dashboard aus `StatCard`s**: Heatmap, Zeitachse, Spieler-Ranking, Vergehen pro Team. Die Zeitachse wird ein echtes Balkendiagramm (eigener `CustomPainter`, keine neue Abhängigkeit), dessen Balken beim Öffnen hochwachsen.
- Der Bearbeiten-Dialog (`EventFormPanel` mit `initialEvent`) bleibt ein Dialog und bekommt nur die neue Optik.

### 5.6 Dialoge

`SquadEditDialog`, Lösch- und Beenden-Bestätigungen und Import-Fehler bekommen einheitliche Radien und Abstände. Destruktive Aktionen werden als `FilledButton` mit Fehlerfarbe dargestellt, Abbrechen als Text-Button. Keys bleiben.

---

## 6. Bewegung

| Moment | Animation |
|---|---|
| Seitenwechsel | `PageTransitionsTheme`: Fade + leichtes Hochschieben (350 ms) |
| Formular öffnen/schließen | Slide von rechts + Fade (250 ms), Spielfeld blendet weich ab |
| Tap aufs Spielfeld | Ripple an der Tap-Stelle, Marker „ploppt" ein (Scale 0 → 1, `easeOutBack`) |
| Auswahl in Rastern | Scale + Farbe (150 ms) |
| Speichern | Häkchen-Animation |
| Phasenwechsel | Button-Farbe/-Label per `AnimatedSwitcher`, Phase-Pill pulsiert bei laufender Uhr |
| Tor | bestehender Score-Highlight bleibt |
| Statistik | Balken wachsen, Heatmap blendet ein |

Ist `disableAnimations` gesetzt, wird alles auf 0 ms reduziert.

---

## 7. Qualitätssicherung

- **Bestehende Suite:** muss nach jeder Phase unverändert grün sein. Ausnahme sind die wenigen Typ- und Icon-Finder aus Abschnitt 1.
- **Neue Accessibility-Tests** pro Screen mit Flutters eingebauten Matchern:
  - `meetsGuideline(androidTapTargetGuideline)` (48 dp)
  - `meetsGuideline(iOSTapTargetGuideline)`
  - `meetsGuideline(textContrastGuideline)`
- **Golden-Tests** für Live-Screen (leer, Formular offen), Spielliste, Setup und Statistik in Tablet-Querformat. Sie machen visuelle Regressionen sichtbar.
- **Manueller Check** auf iPad, Android-Tablet und Surface: Daumen-Erreichbarkeit, Lesbarkeit draußen, Bedienung mit Maus.

---

## 8. Umsetzung in Phasen

Jede Phase ist ein eigener Commit. Am Ende jeder Phase sind `flutter analyze` und `flutter test` grün.

| Phase | Inhalt | Ergebnis |
|---|---|---|
| **0 · Pipeline** | US-601ff. in neuer `docs/02_us_ui_redesign.md`, UX-Flows/Wireframes in `04_ux_design.md`, Testfälle in `24_ui_redesign_tests.md` (gemäß Feature-Regeln in `CLAUDE.md`) | abgestimmte Anforderungen |
| **1 · Fundament** | `presentation/theme/`, Font-Asset, Component-Themes; alle hartkodierten `Colors.*` durch Theme-Tokens ersetzen, **ohne Layout-Änderung** | einheitliche Farben/Typo, sonst gleich |
| **2 · Live-Screen** | Scoreboard-Leiste, Aktionsleiste unten links, Spielfeld-Rendering, Ereignisliste | Daumen-Erreichbarkeit im Spiel |
| **3 · Erfassungsformular** | `SelectTile`-Raster, `TeamSwitch`, Nummern-Chips, sticky Speichern | schnellere, sicherere Erfassung |
| **4 · Spielliste + Setup** | Karten-Raster, Zwei-Spalten-Setup, fixierte Startleiste | moderner Einstieg |
| **5 · Nachbereitung** | Szenen-Karten, Coaching-Karten, Statistik-Dashboard | aufgeräumte Analyse |
| **6 · Motion & Feinschliff** | Übergänge, Golden- und A11y-Tests, Geräte-Check | „smoothes" Gefühl, abgesichert |

Phase 1 ist Voraussetzung für alles Weitere. Die Phasen 2–5 sind unabhängig voneinander, ihre Reihenfolge folgt dem Nutzen im Live-Spiel.

---

## 9. Entscheidungen

| # | Frage | Entscheidung |
|---|---|---|
| 1 | Hell, dunkel oder beides? | **Nur hell.** Die App wird überwiegend draußen genutzt, und bei Sonne ist ein helles Theme mit hohem Kontrast besser lesbar. Es gibt kein Dark Theme und kein `ThemeMode.system`. Alle Screens, auch der Live-Screen, nutzen dasselbe helle Theme. |
| 2 | Linkshänder-Option | **Nicht Teil des Redesigns.** Der Nutzer schreibt dafür später eine eigene User Story. Das Layout sollte die Spiegelung aber nicht unnötig erschweren (Aktionsleiste und Panel als eigenständige Widgets). |
| 3 | Haptisches Feedback | **Keine Vibration.** Rückmeldung erfolgt ausschließlich visuell. |
| 4 | Schrift | **Inter**, als Asset gebündelt. |
