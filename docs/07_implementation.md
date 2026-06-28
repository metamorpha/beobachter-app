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
        ├── heatmap_canvas.dart      # CustomPainter: 6×4-Zonen-Heatmap
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

### Undo-Mechanismus

Nach jedem gespeicherten Event erscheint ein `SnackBar` mit 5-Sekunden-Fenster:

```dart
ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  duration: Duration(seconds: 5),
  action: SnackBarAction(
    label: 'Rückgängig',
    onPressed: () => eventRepository.deleteEvent(eventId),
  ),
));
```

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

### Spieler-Auswahl im Live-Formular

Der `EventFormPanel` zeigt Spielernummern als Chips (Heim/Gast farblich getrennt). Nicht vorerfasste Nummern können via Ziffernblock-TextField eingegeben werden. Die Spieler werden als separate `EventPlayer`-Objekte in einer eigenen Tabelle gespeichert und per CASCADE beim Löschen des Events mit entfernt.

---

### Spielphasen-System (US-210, US-211)

`GamePhase` in `domain/enums/game_phase.dart` definiert 13 Spielzustände:

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

**Auto-Advance:** `_tick()` im `TimerService` prüft `phase.nachspielzeitSchwelle` — bei Überschreitung wechselt die Phase automatisch in die NS-Phase (kein manueller Eingriff nötig).

**Phase-aware Formatierung:** `GamePhaseX.formatMs(ms, phase)` ist die zentrale Methode, die von `TimerState.formattedTime` und `Event.elapsedLabel` genutzt wird.

**Ereignis-Zeitstempel:** Jedes `Event` speichert seine `gamePhase` — notwendig, weil der Timer nie zurückgesetzt wird und `elapsedMs` allein nicht eindeutig (z. B. 47 Min kann 1. HZ-NS oder reguläre 2. HZ sein).

**Datenbankschema v3:** Neue Spalten `phase` in `timer_states` und `game_phase` in `events`. Migration in `app_database.dart`.

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

## Tests (99 gesamt)

| Datei | Tests | Fokus |
|-------|-------|-------|
| `test/core/pressebericht_csv_parser_test.dart` | 26 | CSV-Parser: Teamnamen, Meta, Spielernummern, Warnungen, Fehlerbehandlung |
| `test/core/timer_service_phase_test.dart` | 22 | Phasenübergänge, Auto-Advance, Stream, Persistenz, formatMs |
| `test/domain/entities/timer_state_test.dart` | 16 | Timer-Logik, Akkumulation, Phase-Erhalt, formattedTime (alle NS-Formate) |
| `test/domain/entities/event_test.dart` | 13 | Zeitformatierung (regulär + alle NS-Phasen), copyWith, Defaults |
| `test/data/repositories/game_repository_test.dart` | 6 | CRUD, Sortierung, Isolation |
| `test/data/repositories/event_repository_test.dart` | 8 | CRUD, Cascade, Enum-Persistenz, optionale Felder |
| `test/data/repositories/squad_repository_test.dart` | 4 | Upsert, Team-Trennung, leere Liste |
| `test/widget_test.dart` | 3 | App-Start (Smoke-Test) |

Alle Tests laufen gegen eine In-Memory-SQLite-Datenbank (`NativeDatabase.memory()`).

