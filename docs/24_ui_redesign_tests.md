# Testfälle — UI-Redesign (US-601 – US-606)

> Automatisiert in `test/ui_redesign_test.dart`, sofern nicht als **manuell** markiert.
> Prüfgröße für Widget-Tests: Tablet-Querformat 1280 × 800 dp.

---

## Regression (alle Stories)

### TC-6001: Bestehende Testsuite bleibt grün

**Schritte:** `flutter analyze` und `flutter test` ausführen.

**Erwartetes Ergebnis:** Keine Analyse-Befunde, alle Tests grün. Geändert wurden höchstens Finder nach Widget-Typ (z. B. `ElevatedButton` → `FilledButton`), keine Erwartungen.

---

### TC-6002: Logik-Schichten unverändert

**Schritte:** `git diff --stat main -- src/lib/domain src/lib/data src/lib/core src/lib/presentation/providers` (**manuell**).

**Erwartetes Ergebnis:** Keine Änderungen.

---

## US-601 · Einheitliches helles Design

### TC-6011: Helles Theme mit Inter

**Schritte:** App aufbauen, `Theme.of(context)` auslesen.

**Erwartetes Ergebnis:** `brightness == Brightness.light`, `fontFamily == 'Inter'`, `useMaterial3 == true`. `MaterialApp.darkTheme` ist nicht gesetzt.

---

### TC-6012: Live-Screen ist hell

**Schritte:** Live-Screen öffnen.

**Erwartetes Ergebnis:** Der Scaffold-Hintergrund ist hell (Luminanz > 0,8).

---

### TC-6013: Semantische Farben über ThemeExtension

**Schritte:** `Theme.of(context).extension<AppColors>()` auslesen.

**Erwartetes Ergebnis:** Erweiterung vorhanden; `home`, `away`, `correct`, `wrong`, `yellowCard`, `redCard`, `coaching` sind gesetzt und paarweise verschieden, soweit fachlich verschieden.

---

### TC-6014: Keine hartkodierten Farben in Screens und Widgets

**Schritte:** Quelltexte unter `lib/presentation/screens` und `lib/presentation/widgets` nach `Colors.red|green|blue|grey|amber|orange|yellow|blueGrey|deepOrange` durchsuchen (automatisiert als Test).

**Erwartetes Ergebnis:** Keine Treffer. (`Colors.white`, `Colors.black` und `Colors.transparent` für Overlays im Spielfeld sind erlaubt.)

---

### TC-6015: Textkontrast

**Schritte:** Spielliste, Live-Screen (mit Formular) und Statistik gegen `textContrastGuideline` prüfen.

**Erwartetes Ergebnis:** Guideline erfüllt.

---

## US-602 · Live-Screen in Daumenreichweite

### TC-6021: Phasen-Button unten links

**Schritte:** Live-Screen in Phase `bereit` öffnen.

**Erwartetes Ergebnis:** `btn_start_game` liegt in der unteren Bildschirmhälfte und in der linken Hälfte.

---

### TC-6022: Phasen-Button-Größe

**Schritte:** Live-Screen in Phase `ersteHalbzeit` öffnen.

**Erwartetes Ergebnis:** `btn_halbzeit` ist mindestens 160 dp breit und 64 dp hoch.

---

### TC-6023: Aufstellung und Szenen beschriftet in der Aktionsleiste

**Schritte:** Live-Screen öffnen.

**Erwartetes Ergebnis:** Texte „Aufstellung" und „Szenen" sind sichtbar; `btn_aufstellung` und `btn_szenen` liegen unten links, sind ≥ 56 dp hoch.

---

### TC-6024: Kopfleiste ohne Buttons

**Schritte:** Live-Screen öffnen.

**Erwartetes Ergebnis:** In der Kopfleiste (`live_scoreboard`) gibt es keine Buttons; sie zeigt Spielstand (`live_score`), Uhr (`timer_label`) und Phase.

---

### TC-6025: Laufende Uhr pulsiert, Pause nicht

**Schritte:** Phase `ersteHalbzeit` bzw. `halbzeit` öffnen.

**Erwartetes Ergebnis:** `timer_running_dot` ist bei laufender Uhr vorhanden, in der Halbzeitpause nicht.

---

### TC-6026: Ereignisliste — Zeilenhöhe und Lösch-Button

**Schritte:** Live-Screen mit 3 Ereignissen öffnen.

**Erwartetes Ergebnis:** Jede Zeile ≥ 56 dp hoch, Lösch-Button ≥ 48 × 48 dp.

---

### TC-6027: Tippflächen-Guideline im Live-Screen

**Schritte:** Live-Screen mit offenem Formular gegen `androidTapTargetGuideline` prüfen.

**Erwartetes Ergebnis:** Guideline erfüllt.

---

## US-603 · Erfassungsformular

### TC-6031: Ereignistyp-Kacheln ≥ 56 dp

**Schritte:** Formular öffnen.

**Erwartetes Ergebnis:** Jede `event_type_*`-Kachel ist mindestens 56 dp hoch.

---

### TC-6032: Entscheidungen ≥ 56 dp

**Schritte:** Formular öffnen, Typ „Fußvergehen" wählen.

**Erwartetes Ergebnis:** Jede `decision_*`-Fläche ist mindestens 56 dp hoch.

---

### TC-6033: Team-Umschalter und Rückennummern

**Schritte:** Formular mit Kader (Heim 7, 9) öffnen, Typ „Fußvergehen", Täter Heim wählen.

**Erwartetes Ergebnis:** `fouler_team_home` ≥ 56 dp hoch; Rückennummer-Chip `fouler_chip_7` ≥ 48 × 48 dp.

---

### TC-6034: Bewertungsfelder ≥ 64 dp mit Symbol

**Schritte:** Typ wählen.

**Erwartetes Ergebnis:** Alle vier `assessment_*`-Felder ≥ 64 dp hoch; „korrekt"-Felder zeigen `Icons.check`, „falsch"-Felder `Icons.close`.

---

### TC-6035: Speichern fix unten rechts, ≥ 64 dp

**Schritte:** Typ „Fußvergehen" wählen, Notiz aufklappen.

**Erwartetes Ergebnis:** `btn_save_event` ist ≥ 64 dp hoch, liegt in der rechten Bildschirmhälfte am unteren Rand und bleibt an derselben Position, wenn der Formularinhalt scrollt.

---

### TC-6037: Kein Überlauf bei schmaler Breite

**Schritte:** Formular in 300 dp Breite bauen (so schmal ist es kurz, während das Panel einblendet), Typ „Fußvergehen" und „Torentscheidung" wählen, bis zur Karten-Zeile scrollen.

**Erwartetes Ergebnis:** Kein Layout-Überlauf.

---

### TC-6036: Formularlogik unverändert

**Schritte:** Bestehende Tests in `event_form_panel_test.dart`, `spielstand_test.dart` ausführen.

**Erwartetes Ergebnis:** Grün.

---

## US-604 · Spielliste und Setup

### TC-6041: Spiele als Karten im Raster

**Schritte:** Spielliste mit 3 Spielen öffnen.

**Erwartetes Ergebnis:** `game_tile_*` stehen in zwei Spalten (zwei Karten mit gleichem `top`, unterschiedlichem `left`).

---

### TC-6042: Leer-Zustand

**Schritte:** Spielliste ohne Spiele öffnen.

**Erwartetes Ergebnis:** Text „Noch keine Spiele erfasst." sichtbar, dazu ein Hinweis auf „Neues Spiel".

---

### TC-6043: Lösch-Button bleibt sichtbar, ≥ 48 dp

**Schritte:** Spielliste mit einem Spiel öffnen.

**Erwartetes Ergebnis:** `btn_delete_game_*` sichtbar, ≥ 48 × 48 dp.

---

### TC-6044: Setup zweispaltig

**Schritte:** Setup öffnen.

**Erwartetes Ergebnis:** `tf_home_team` liegt links von der Überschrift „Aufstellung Heim".

---

### TC-6045: „Spiel starten" ohne Scrollen sichtbar

**Schritte:** Setup bei 1280 × 800 mit je 22 Rückennummern öffnen.

**Erwartetes Ergebnis:** `btn_start_game` liegt vollständig im sichtbaren Bereich, rechte untere Ecke.

---

## US-605 · Nachbereitung und Statistik

### TC-6051: Szenen als Karten, Aktionen ≥ 48 dp

**Schritte:** Szenen-Tab mit einem Ereignis öffnen.

**Erwartetes Ergebnis:** Buttons „Bearbeiten" und „Coaching" (Tooltip) je ≥ 48 × 48 dp.

---

### TC-6052: Statistik als 2 × 2-Dashboard

**Schritte:** Statistik-Tab öffnen.

**Erwartetes Ergebnis:** Überschriften „Heatmap", „Zeitachse", „Spieler-Ranking", „Vergehen pro Team" sichtbar; Heatmap und Zeitachse auf gleicher Höhe, Ranking und Vergehen darunter.

---

### TC-6053: Zeitachse als Balkendiagramm, Werte unverändert

**Schritte:** Statistik mit 2 Ereignissen in 0–15' und 1 in 60–75' öffnen.

**Erwartetes Ergebnis:** `timeline_chart` vorhanden; die Zähler „2" und „1" sind sichtbar, die Phasen-Beschriftungen bleiben (0–15' … 75–90').

---

## US-606 · Flüssige Übergänge

### TC-6061: Formular gleitet ein

**Schritte:** Feldtipp, nach 100 ms Position des Formulars messen, dann `pumpAndSettle`.

**Erwartetes Ergebnis:** Nach 100 ms liegt das Formular weiter rechts als im Endzustand.

---

### TC-6062: Bewegung reduzieren

**Schritte:** `MediaQuery(disableAnimations: true)`, Feldtipp, ein `pump()`.

**Erwartetes Ergebnis:** Das Formular steht sofort an der Endposition.

---

### TC-6063: Taps während Animation

**Schritte:** Feldtipp, nach 50 ms (Animation läuft) auf `event_type_footFoul` tippen, `pumpAndSettle`.

**Erwartetes Ergebnis:** Fußvergehen ist ausgewählt, Speichern aktiv.

---

### TC-6064: Geräte-Check (manuell)

**Schritte:** Auf iPad, Android-Tablet und Surface ein Spiel anlegen, 10 Ereignisse erfassen, Halbzeit und Abpfiff bedienen, draußen bei Tageslicht.

**Erwartetes Ergebnis:** Alle Aktionen ohne Umgreifen erreichbar, Texte lesbar, Übergänge ruckelfrei, keine Vibration.

---

## Ergebnis (2026-10-23)

| Bereich | Ergebnis |
|---|---|
| Automatisiert (`test/ui_redesign_test.dart`) | 31 Tests für TC-6011 – TC-6063, alle grün |
| Golden-Tests (`test/golden/`, Tag `golden`) | 8 Screens inkl. Bearbeiten-Dialog, Referenzbilder von macOS |
| Bestehende Suite (TC-6001) | 213 Tests grün; angepasst: 5 Typ-Finder, 1 Text-Finder (TC-1101), 1 `ensureVisible` (TC-EFR-05) |
| TC-6002 | `git diff main -- lib/domain lib/data lib/core lib/presentation/providers` ist leer |
| TC-6064 Geräte-Check | **offen** — manuell auf iPad, Android-Tablet und Surface |
