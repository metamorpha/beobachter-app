# Implementation Notes — Beobachter-App MVP

> Stack: Flutter 3.41.7 · Dart 3.11.5 · Drift 2.31 · Riverpod 2.6.1
> TDD: Tests wurden vor der Implementierung verfasst

---

## Setup & Build

```bash
cd src/
flutter pub get
flutter pub run build_runner build   # Drift-Code generieren (einmalig / nach Schema-Änderungen)
flutter test                          # 99 Tests, alle grün
flutter run                           # iOS / Android / Windows
```

---

## Projektstruktur

```
src/lib/
├── main.dart                        # Einstiegspunkt (ProviderScope)
├── app.dart                         # MaterialApp, BeobachterApp
├── domain/
│   ├── entities/                    # Game · Event · EventPlayer · Squad · TimerState
│   ├── enums/                       # EventType · RefDecision · CardType · Assessment · TeamSide · PlayerRole · GamePhase
│   └── repositories/               # Abstrakte Interfaces (4 Stück)
├── data/
│   ├── database/
│   │   ├── tables/                  # 5 Drift-Tabellen (@DataClassName je Tabelle)
│   │   └── app_database.dart        # @DriftDatabase + PRAGMA foreign_keys, Schema v3
│   └── repositories/               # 4 konkrete Implementierungen
├── core/
│   ├── timer_service.dart           # Background-safe Spieluhr
│   └── pressebericht_csv_parser.dart  # CSV-Parser für DFB/FLVW-Pressebericht-Format
└── presentation/
    ├── providers/providers.dart     # Alle Riverpod-Provider
    ├── screens/
    │   ├── game_list/               # Startseite: Spielübersicht
    │   ├── game_setup/              # Spiel anlegen + Aufstellung + CSV-Import
    │   ├── live/                    # Live-Screen + EventFormPanel
    │   └── review/                  # Szenen · Coaching · Statistik (3 Tabs)
    └── widgets/
        ├── pitch_canvas.dart        # CustomPainter: Spielfeld + Marker
        ├── heatmap_canvas.dart      # CustomPainter: KDE-Dichte-Heatmap
        ├── timer_display.dart       # Spieluhr + Start/Stop-Button
        └── assessment_grid.dart    # 2×2-Bewertungs-Grid
```

---

## Technische Entscheidungen

### Drift @DataClassName

Drift generiert Datenklassen mit denselben Namen wie die Domain-Entities (`Game`, `Event`, …). Um Konflikte zu vermeiden, tragen alle Drift-Tabellen `@DataClassName('XxxRow')`:

```dart
@DataClassName('GameRow')
class Games extends Table { … }
```

Die Repository-Implementierungen verwenden intern `GameRow`, `EventRow` etc. und mappen auf die Domain-Entities.

### Background-safe Timer

`TimerService` nutzt keinen `setInterval`-basierten Timer für die Datenspeicherung. Stattdessen:

```dart
// Start: Timestamp in DB schreiben
timerState.startTimestamp = DateTime.now()

// Laufende Zeit (jederzeit korrekt, auch nach Neustart):
currentMs = elapsedMs + (now - startTimestamp)

// Stop: Akkumulieren + in DB schreiben
elapsedMs += (now - startTimestamp)
```

Der UI-Ticker (`Timer.periodic(1s)`) aktualisiert nur die Anzeige — kein Datenverlust bei App-Hintergrund.

### Korrektur statt Undo

Es gibt keine Undo-SnackBar (sie war hier früher beschrieben, wurde aber nie implementiert). Versehentlich gespeicherte Ereignisse löscht man über das Lösch-Icon in „Letzte Ereignisse" (`_RecentEvents` im `LiveScreen`), das `eventRepository.deleteEvent(id)` aufruft. Nach dem Speichern zeigt der Live-Screen lediglich den Hinweis „Ereignis gespeichert" (US-603). Entscheidung siehe `06_architecture.md`, Abschnitt „Korrektur nach Speichern".

### SQLite Foreign Keys

Drift aktiviert `foreign_keys` nicht standardmäßig. Kaskadierendes Löschen (Game → Events → EventPlayers) wird explizit aktiviert:

```dart
MigrationStrategy(
  beforeOpen: (details) async {
    await customStatement('PRAGMA foreign_keys = ON');
  },
)
```

### Koordinaten normalisiert

Spielfeld-Tap-Koordinaten werden als `double` (0.0–1.0) gespeichert, unabhängig von Bildschirmauflösung:

```dart
final x = (local.dx / box.size.width).clamp(0.0, 1.0);
final y = (local.dy / box.size.height).clamp(0.0, 1.0);
```

Heatmap und Marker berechnen Pixel-Positionen beim Rendern aus diesen Werten.

### Heatmap als Dichteverteilung — KDE (US-401)

`HeatmapCanvas` rendert die Ereignisorte als kontinuierliche Dichteverteilung statt eines festen Zonenrasters:

- **`HeatmapDensity`** (in `heatmap_canvas.dart`, öffentlich für Tests): reine Dart-Klasse, berechnet ein normalisiertes Dichtegitter (96×64) per Gauß-Kernel (σ = 0.04 in normierten Koordinaten, abgeschnitten bei 3σ). Maximum = 1.0; leere Ereignisliste → Nullgitter.
- **Rendering:** Zellen oberhalb eines Schwellwerts (0.05) werden in eine `saveLayer`-Ebene gezeichnet und mit einem einzelnen `ImageFilter.blur`-Pass geglättet — keine sichtbaren Rasterkanten, ein Blur für alle Zellen statt pro Rechteck.
- **Farbrampe:** gelb (niedrige Dichte) → orange → rot (Maximum); Alpha 0.15–0.85, sodass Einzelereignisse sichtbar bleiben und Feldlinien durchscheinen.
- **Aufwand:** Events × Kernel-Fußabdruck (~25×25 Zellen) — bei 200 Events unkritisch, Berechnung einmal pro Ereignisliste im Painter gecacht.

### Spieler-Auswahl im Live-Formular

Der `EventFormPanel` zeigt Spielernummern als Chips (Heim/Gast farblich getrennt). Nicht vorerfasste Nummern können via Ziffernblock-TextField eingegeben werden. Die Spieler werden als separate `EventPlayer`-Objekte in einer eigenen Tabelle gespeichert und per CASCADE beim Löschen des Events mit entfernt.

---

### Spielphasen-System (US-210, US-211, US-212)

`GamePhase` in `domain/enums/game_phase.dart` definiert 14 Spielzustände:

| Phase | Anzeige | Timer |
|-------|---------|-------|
| `bereit` | `00:00` | gestoppt |
| `ersteHalbzeit` | `MM:SS` | läuft |
| `ersteHalbzeitNachspielzeit` | `45+XX` | läuft |
| `halbzeit` | eingefroren | gestoppt |
| `zweiteHalbzeit` | `MM:SS` | läuft |
| `zweiteHalbzeitNachspielzeit` | `90+XX` | läuft |
| `beendet` | eingefroren | gestoppt |
| `verlaengerungErsteHalbzeit` | `MM:SS` | läuft |
| `verlaengerungErsteHalbzeitNachspielzeit` | `105+XX` | läuft |
| `verlaengerungHalbzeit` | eingefroren | gestoppt |
| `verlaengerungZweiteHalbzeit` | `MM:SS` | läuft |
| `verlaengerungZweiteHalbzeitNachspielzeit` | `120+XX` | läuft |
| `beendetVerlaengerung` | eingefroren | gestoppt |
| `abgeschlossen` | eingefroren | gestoppt, endgültig |

**Auto-Advance:** `_tick()` im `TimerService` prüft `phase.nachspielzeitSchwelle` — bei Überschreitung wechselt die Phase automatisch in die NS-Phase (kein manueller Eingriff nötig).

**Phase-aware Formatierung:** `GamePhaseX.formatMs(ms, phase)` ist die zentrale Methode, die von `TimerState.formattedTime` und `Event.elapsedLabel` genutzt wird.

**Ereignis-Zeitstempel:** Jedes `Event` speichert seine `gamePhase` — notwendig, weil der Timer nie zurückgesetzt wird und `elapsedMs` allein nicht eindeutig (z. B. 47 Min kann 1. HZ-NS oder reguläre 2. HZ sein).

**Datenbankschema v3:** Neue Spalten `phase` in `timer_states` und `game_phase` in `events`. Migration in `app_database.dart`.

**Spiel endgültig beenden (US-212):** Aus `beendet` und `beendetVerlaengerung` führt `TimerService.spielBeenden()` (nach Bestätigungsdialog im `TimerDisplay`) in den Endzustand `abgeschlossen`. `_advancePhase()` und `start()` sind gegen Übergänge aus `abgeschlossen` gesperrt — ein abgeschlossenes Spiel kann nicht erneut gestartet werden. Der Live-Screen ignoriert Feldtipps (keine neue Erfassung); die Nachbereitung (Review) bleibt unverändert nutzbar. Die Spielphase wird per `TimerRepository.watchTimerState()` (Drift-Stream) reaktiv in der Spielliste angezeigt („Beendet"-Badge, `gamePhaseProvider`). Keine Schema-Migration nötig: die Phase wird als Enum-`name` gespeichert.

---

### CSV-Import (US-105)

`PresskBerichtCsvParser` in `core/pressebericht_csv_parser.dart` liest das DFB/FLVW-Pressebericht-Format (`;`-separiert, Header + 1 Datenzeile):

```dart
// Verwendung im GameSetupScreen:
final result = PresskBerichtCsvParser.parse(csvContent);
// result.homeTeamName, result.awayTeamName, result.homeNumbers, …
// result.warnings: Liste nicht importierter Felder (für Warn-Banner)
```

**Robustheit:** CRLF-tolerant, UTF-8 mit Latin-1-Fallback, ungültige Spielernummern (außerhalb 1–99, nicht-numerisch) werden ignoriert, Datums-Bounds-Validierung gegen Dart-DateTime-Overflow.

**Datenbankschema v2:** `games`-Tabelle erhält zwei neue nullable-Spalten `liga` (Text) und `spieltag` (Text). Migration läuft automatisch beim ersten Start nach Update.

**Abhängigkeit:** `file_picker ^8.0.0` für nativen Datei-Browser (iOS/Android/Windows). iOS `Info.plist` enthält `LSSupportsOpeningDocumentsInPlace` und `UIFileSharingEnabled`.

---

### Fensterverwaltung Windows + macOS (US-107, US-108)

`window_manager ^0.4.0` wird in `main.dart` vor `runApp()` initialisiert. Der Guard schließt iOS/Android aus:

```dart
if (Platform.isWindows || Platform.isMacOS) {
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow(
    const WindowOptions(skipTaskbar: false),
    () async {
      await windowManager.maximize();
      await windowManager.setResizable(false);
      await windowManager.show();
      await windowManager.focus();
    },
  );
}
```

`waitUntilReadyToShow` hält das Fenster verborgen, bis es maximiert ist — kein Flackern beim Start. `setResizable(false)` deaktiviert alle Drag-Handles auf Windows und macOS gleichermaßen.

---

### Navigationsfluß (US-104)

```
GameListScreen
  ├── FAB "Neues Spiel"  → GameSetupScreen  → LiveScreen (pushReplacement)
  └── Tap Spielkachel    → ReviewScreen
                               └── Edit-Icon (✏)  → GameSetupScreen
```

Jede Spielkachel zeigt Datum und Ereignisanzahl im Subtitle. Der `eventCountProvider(gameId)` ist ein `FutureProvider.family<int, String>` in `providers.dart` und ruft `getEvents` auf.

---

## Tests (119 gesamt)

| Datei | Tests | Fokus |
|-------|-------|-------|
| `test/spiel_beenden_test.dart` | 11 | US-212: spielBeenden, Neustart-Sperre, Buttons, Dialog, Badge |
| `test/heatmap_density_test.dart` | 9 | KDE-Dichtegitter: Normalisierung, Symmetrie, Randfälle, Widget-Smoke |
| `test/core/pressebericht_csv_parser_test.dart` | 26 | CSV-Parser: Teamnamen, Meta, Spielernummern, Warnungen, Fehlerbehandlung |
| `test/core/timer_service_phase_test.dart` | 22 | Phasenübergänge, Auto-Advance, Stream, Persistenz, formatMs |
| `test/domain/entities/timer_state_test.dart` | 16 | Timer-Logik, Akkumulation, Phase-Erhalt, formattedTime (alle NS-Formate) |
| `test/domain/entities/event_test.dart` | 13 | Zeitformatierung (regulär + alle NS-Phasen), copyWith, Defaults |
| `test/data/repositories/game_repository_test.dart` | 6 | CRUD, Sortierung, Isolation |
| `test/data/repositories/event_repository_test.dart` | 8 | CRUD, Cascade, Enum-Persistenz, optionale Felder |
| `test/data/repositories/squad_repository_test.dart` | 4 | Upsert, Team-Trennung, leere Liste |
| `test/widget_test.dart` | 3 | App-Start (Smoke-Test) |

Alle Tests laufen gegen eine In-Memory-SQLite-Datenbank (`NativeDatabase.memory()`).


---

## UI-Redesign (Epic 6, US-601 – US-606)

Nur die Presentation-Schicht wurde geändert; `domain/`, `data/`, `core/` und `providers.dart` sind unverändert.

### Theme (`presentation/theme/`)

| Datei | Inhalt |
|---|---|
| `app_theme.dart` | Einziges, helles `ThemeData` (Material 3, Inter) mit allen Component-Themes; Seitenwechsel per FadeForwards (350 ms), iOS behält Cupertino |
| `app_colors.dart` | `AppColors` als `ThemeExtension`: Heim/Gast, korrekt/falsch, Karten, Coaching, Phasen-Aktionen, Spielfeld; `context.colors` mit Fallback für Tests ohne App-Theme |
| `app_spacing.dart` | Abstände, Radien, Mindestgrößen (`tap` 48, `liveTap` 56, `primaryAction` 64) |
| `app_motion.dart` | Dauern/Kurve; `AppMotion.of` liefert `Duration.zero` bei „Bewegung reduzieren" |
| `event_type_style.dart` | Icon und Markerfarbe je `EventType` |

Inter liegt unter `assets/fonts/inter/` (SIL OFL, `OFL.txt`).

**Stolperfalle:** `ThemeData.textTheme` enthält vor `Theme.of` noch keine Schriftgrößen (die Geometrie wird erst beim Lokalisieren ergänzt). `AppTheme` legt deshalb `Typography.englishLike2021` explizit zugrunde, sonst fehlen z. B. dem AppBar-Titel die Größen.

### Gemeinsame Bausteine (`presentation/widgets/`)

- `SelectTile` — große Auswahlfläche (Typ, Entscheidung, Team, Nummer, Karte, Bewertung) mit Druck-Skalierung und weichem Farbwechsel
- `SectionHeader`, `StatCard`
- `TimerDisplay` aufgeteilt in `TimerClock` (Anzeige, Kopfleiste) und `PhaseActions` (Buttons, Aktionsleiste); `TimerDisplay` kombiniert beide weiterhin
- `paintPitch()` in `pitch_canvas.dart` — gemeinsame Feldzeichnung für Live-Spielfeld und Heatmap

### Animationen ohne Dauerschleife

Widget-Tests nutzen `pumpAndSettle`; Endlos-Animationen würden nie zur Ruhe kommen. Deshalb:
- der Punkt der laufenden Uhr blendet im Sekundentakt des Timer-Streams (je Tick eine endliche Animation),
- das „Läuft"-Badge pulsiert nur dreimal nach dem Erscheinen.

### Golden-Tests

`test/golden/screens_golden_test.dart` rendert acht Screens mit echter Inter-Schrift und Material Icons bei 1280 × 800 und echten Schatten (`debugDisableShadows = false`). Neu erzeugen: `flutter test --update-goldens --tags golden`. Referenzbilder stammen von macOS und werden nur dort erzeugt und geprüft; auf anderen Plattformen (z. B. Windows für Surface) werden die Golden-Tests mit Begründung übersprungen, weil die Schriftdarstellung minimal abweicht.

---

## Trikotfarben (US-111)

- **Datenmodell:** `Game.homeKitColor` / `awayKitColor` (`KitColor?`) liegen in der Tabelle `games` (Schema v8), nicht in `squads`, weil ein Spiel nicht immer einen Kader-Datensatz hat. Gespeichert wird `KitColor.name`. Unbekannte Werte werden beim Laden zu `null` (`KitColorLabel.tryParse`).
- **Speichern:** `GameRepository.updateKitColor()` schreibt sofort, im Spiel-Setup und im Dialog „Aufstellung" gleichermaßen, analog zu den Rückennummern. `updateGame()` nimmt die Farben mit, damit „Spiel starten" und der CSV-Import sie nicht überschreiben.
- **Provider:** `gameProvider(gameId)` lädt das einzelne Spiel. `teamKitsProvider(gameId)` leitet daraus `TeamKits` ab und ist `null`, solange noch nichts geladen ist. Screens, die das `Game` bereits kennen (Live-Kopfzeile, „Letzte Ereignisse"), überbrücken das erste Laden mit `TeamKits.fromGame(game)`, damit beim Öffnen nichts kurz blau/rot aufblitzt. Nach jeder Farbänderung werden `gameProvider` und `gamesProvider` invalidiert.
- **Darstellung:** `TeamKits.color(context, side)` liefert die Trikotfarbe oder fällt auf `AppColors.home` / `away` zurück. Die Hex-Werte stehen in `presentation/theme/kit_colors.dart`.
- **Helle Farben:** `AppColors.needsOutline()` (Luminanz > 0,5, trifft Weiß, Gelb, Hellblau) entscheidet über einen 1,5-dp-Rand (`teamColorOutline`). Betroffen sind `TeamDot`, `TeamBadge`, Kader-Chips, „+ Tor"-Buttons und ausgewählte `SelectTile`s. Die Spalten „H"/„G" der Vergehen-Tabelle sind dann in `onSurface` statt in Teamfarbe gesetzt, der Ranking-Balken in `outline`.
- **Widgets:** `KitColorPicker` + `KitClashHint` (`widgets/kit_color_picker.dart`), `TeamDot` + `TeamBadge` (`widgets/team_dot.dart`) ersetzen die bisher verstreuten Farbpunkte.
- **Tests:** `test/trikotfarben_test.dart` (TC-111-01 – 19), TC-111-06 in `game_setup_import_test.dart`, Goldens `game_setup_kits` und `live_kits`. Migrationstests ab v4–v6 legen jetzt eine `games`-Tabelle an, weil die v8-Migration Spalten ergänzt.

## Nur Fouler, SR-Ball (US-216, US-217)

- **Nur Fouler:** `EventFormPanel` zeigt im Abschnitt „Spieler" nur noch die Fouler-Zeile (`_foulerRow`). `PlayerRole.fouled` bleibt im Enum und in der Datenbank, damit Altdaten lesbar bleiben. Gefoulte aus `initialPlayers` werden in `_legacyFouled` gehalten und beim Speichern unverändert mitgeschrieben, weil `updateEvent()` alle Spieler eines Ereignisses neu schreibt.
- **SR-Ball:** neuer Wert `RefDecision.droppedBall` („SR-Ball") direkt nach `throwIn`. Die Entscheidung wird wie alle anderen als `name` gespeichert, deshalb gibt es keinen Schemawechsel (bleibt v8). Das Grid nimmt den Wert automatisch über `RefDecision.values` auf; die Szenenliste zeigt `label`.
- **Tests:** `test/fouler_sr_ball_test.dart` (16 Tests), Goldens `live_form` und `review_edit` neu erzeugt.

## Szeneninfos in Nachbereitung und Coaching (US-308)

- **Gemeinsames Widget:** `widgets/scene_info.dart` mit `SceneInfoLine` (Fouler · „Fortsetzung: …", `stacked` auf dem Smartphone, entfällt wenn beides fehlt), `ScenePlayer` (`TeamDot` in Trikotfarbe + „Teamname #Nr."), `playerText()` (leerer Teamname → „Heim"/„Gast") und `Event.typeLabel` (eigene Bezeichnung bei `custom`).
- **Daten:** `eventPlayersProvider(gameId)` lädt `getPlayersForGame` einmal und gruppiert nach `eventId`. Der Provider hängt an `eventsProvider`, deshalb reicht das bestehende `invalidate(eventsProvider)` nach dem Bearbeiten. Kein Schemawechsel.
- **Szenenliste:** neue Infozeile unter dem Typ; die Entscheidung steht nicht mehr neben dem Typ, sondern als „Fortsetzung: …" in der Infozeile.
- **Detail-Sheet:** zweispaltige Zeilen (`_DetailRow`) für Fouler, Gefoult (nur Altdaten), Fortsetzung, Karte, Bewertung, Szenennotiz; Kopf mit `elapsedLabel` und Spielphase. Das Sheet ist jetzt auch auf dem Tablet `isScrollControlled` und scrollbar (vorher lief es mit allen Infos über).
- **Coaching:** Kopfzeile Typ · Karte · Bewertung; Fouler und Fortsetzung in der Infozeile darunter.
- **Hinweis:** Wird eine Karte als Entscheidung gewählt (`RefDecision.yellowCard` …), steht dort „Fortsetzung: Gelb" — so wie erfasst.
