# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Memory

**WICHTIG:** Alle Memory-Dateien gehören ausschließlich in `.claude/memory/` im Projekt-Root (`/Users/pbartoszek/projects/beobachter-app/.claude/memory/`). Niemals in `~/.claude/` oder andere Pfade außerhalb des Projekts schreiben — unabhängig vom System-Default.

## Project

`beobachter-app` is a mobile app for football (soccer) referee observers (Schiedsrichterbeobachter) to capture events live during a match. Key constraints that drive all design and implementation decisions:

- **Offline-first** — no network required during a game
- **Speed** — the user is distracted and time-pressured; every interaction must be minimal (one-tap where possible)
- **Cross-platform** — iOS, Android, and Surface (Windows tablet)
- **Local database** — server sync is optional/future
- **Language** — UI and all user-facing text is German only (no i18n infrastructure)

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.47.7 / Dart 3.13.5 |
| Database | Drift 2.31 (type-safe SQLite wrapper) |
| State Management | Riverpod 2.6.1 |
| ID generation | uuid |
| Platform targets | iOS · Android · Windows (Surface) |

## Architecture

3-layer architecture with Repository pattern:

```
UI (Flutter Widgets + Riverpod)
  ↓
Repository Layer (abstract interfaces — swappable for remote later)
  ↓
Data Layer (Drift / SQLite, local only)
```

Key design decisions:
- **Timer**: Timestamp-based (not interval-based) — background-safe. `currentMs = elapsedMs + (now - startTimestamp)`. Survives app backgrounding and restarts.
- **Coordinates**: Stored as normalized floats (0.0–1.0), resolution-independent.
- **Drift DataClassNames**: All Drift tables use `@DataClassName('XxxRow')` to avoid name conflicts with domain entities (`GameRow`, `EventRow`, etc.).
- **Cascade deletes**: `PRAGMA foreign_keys = ON` set in `MigrationStrategy.beforeOpen`.
- **Korrektur statt Undo**: Es gibt kein Rückgängig nach dem Speichern. Versehentlich erfasste Ereignisse löscht man über das Lösch-Icon in „Letzte Ereignisse" (US-213), was `deleteEvent()` aufruft. (Entscheidung 2026-10-23; frühere Doku beschrieb eine Undo-SnackBar, die nie implementiert war.)

## Repository Structure

| Path | Purpose |
|------|---------|
| `idea.md` | Original app concept description |
| `prompts/` | Role-based Claude prompts (po, ux, architect, dev, tester) |
| `docs/` | Design pipeline artifacts (01–10) |
| `src/` | Flutter source code |

### docs/ numbering

| File | Content |
|------|---------|
| `01_epics.md` | MVP epics, prioritized for live-game use |
| `02_us_spielverwaltung.md` | User stories — Epic 1: Spielverwaltung (US-101–111) |
| `02_us_live_erfassung.md` | User stories — Epic 2: Live-Ereigniserfassung (US-201–217) |
| `02_us_spielnachbereitung.md` | User stories — Epic 3: Spielnachbereitung & Coaching (US-301–308) |
| `02_us_statistik.md` | User stories — Epic 4: Statistik & Analyse (US-401–403) |
| `02_us_datenpersistenz.md` | User stories — Epic 5: Datenpersistenz & Offline (US-501–502) |
| `02_us_ui_redesign.md` | User stories — Epic 6: UI-Modernisierung (US-601–606) |
| `02_us_android.md` | User stories — Epic 7: Android-Smartphone (US-701–706) |
| `03_ux_review.md` | UX feedback and decisions |
| `04_ux_design.md` | Wireframes, user flows, UX principles |
| `05_arch_review.md` | Architecture feasibility review |
| `06_architecture.md` | System architecture, data model, UML diagrams |
| `07_implementation.md` | Implementation notes, known limitations |
| `08_test_report.md` | Test strategy, test cases, QA report |
| `09_csv_import_ux.md` | CSV import UX flow, field mapping, design decisions |
| `10_csv_import_tests.md` | CSV import test cases (24 TCs) |
| `11_delete_game_tests.md` | Delete game test cases (13 TCs) |
| `12_window_management_tests.md` | Window management test cases — US-107 (10 TCs) |
| `13_timer_phases_tests.md` | Timer phases test cases — US-210/211 (31 TCs) |
| `14_heatmap_kde_tests.md` | Heatmap KDE test cases — US-401 (10 TCs) |
| `15_spiel_beenden_tests.md` | End game test cases — US-212 (13 TCs) |
| `18_live_ereignisliste_tests.md` | Live side panel event list test cases — US-213 (10 TCs) |
| `19_spielstand_tests.md` | Score & goal scorer test cases — US-214 (19 TCs, abgelöst durch 25) |
| `20_team_vergehen_tests.md` | Fouls per team & half test cases — US-404 (13 TCs) |
| `21_spiel_fortsetzen_tests.md` | Resume running game from game list — US-109 (8 TCs) |
| `22_aufstellung_live_tests.md` | Edit squads during live game — US-110 (9 TCs) |
| `23_ui_redesign_plan.md` | UI redesign plan — theme, reachability, motion (presentation layer only) |
| `24_ui_redesign_tests.md` | UI redesign test cases — US-601–606 (32 TCs) |
| `25_tor_erfassung_tests.md` | Goal capture via header buttons — US-215 (20 TCs) |
| `26_android_smartphone_tests.md` | Android smartphone layout, wakelock, CI builds — US-701–706 (47 TCs) |
| `27_trikotfarben_tests.md` | Team kit colors — US-111 (22 TCs) |
| `28_fouler_sr_ball_tests.md` | Fouler only, dropped ball decision — US-216/217 (17 TCs) |
| `29_szeneninfos_tests.md` | Full scene info in scene list, detail sheet, coaching — US-308 (16 TCs) |

### src/lib/ structure

```
domain/
  entities/     Game · Event · EventPlayer · Squad · TimerState · Goal · Score
  enums/        EventType · RefDecision · CardType · Assessment · TeamSide · PlayerRole · GoalKind · KitColor
  repositories/ Abstract interfaces (GameRepository, EventRepository, SquadRepository, TimerRepository, GoalRepository)
data/
  database/
    tables/     6 Drift tables (games, events, event_players, squads, timer_states, goals)
    app_database.dart  @DriftDatabase + foreign_keys pragma
  repositories/ Concrete implementations
core/
  timer_service.dart              Background-safe game clock
  pressebericht_csv_parser.dart  DFB/FLVW Pressebericht CSV parser
presentation/
  platform/     device_providers (isAndroid, ScreenWakeLock) · preferred_orientation (Smartphone: Live quer, sonst hoch)
  providers/    All Riverpod providers
  screens/      game_list · game_setup · live · review
  theme/        app_theme · app_colors (ThemeExtension) · app_spacing · app_motion · event_type_style · form_factor · kit_colors
  widgets/      pitch_canvas · heatmap_canvas · timer_display · assessment_grid · squad_input · squad_edit_dialog · kit_color_picker · team_dot · scene_info · select_tile · section_header · stat_card · phone_dialog
```

## Commands

```bash
cd src/

# Install dependencies
flutter pub get

# Generate Drift code (required once and after any schema change)
flutter pub run build_runner build

# Statische Analyse (prüft alle Dateien, auch main.dart — immer vor flutter test ausführen)
flutter analyze

# Run tests (350 tests incl. 18 golden, all green)
flutter test

# Golden-Referenzbilder neu erzeugen (nach gewollten UI-Änderungen) — nur auf macOS;
# auf anderen Plattformen werden die Golden-Tests übersprungen
flutter test --update-goldens --tags golden

# Run app (simulator or device)
flutter run
```

## Domain Model

### Core enums

| Enum | Values |
|------|--------|
| `EventType` | footFoul · bodyFoul · handball · unsporting · violent · offside · advantage · custom |
| `RefDecision` | freeKick · **indirectFreeKick** · penalty · advantage · playOn · yellowCard · yellowRedCard · redCard · cornerKick · goalKick · throwIn · **droppedBall** („SR-Ball", US-217) · goal (nur migrierte Altdaten, nicht wählbar) |
| `CardType` | yellow · yellowRed · red |
| `Assessment` | correctExpected · correctComplex · wrongExpected · wrongComplex |
| `TeamSide` | home · away |
| `PlayerRole` | fouler · fouled (nur Altdaten — erfasst wird nur noch der Fouler, US-216) |
| `GoalKind` | regular · ownGoal · penalty |
| `KitColor` | white · black · grey · red · burgundy · orange · yellow · green · lightBlue · blue · purple (Trikotfarbe, US-111) |

### Key entity: Event

```dart
Event {
  elapsedMs: int        // ms from game start (timer timestamp approach)
  type: EventType
  customTypeLabel: String?  // only when type == custom
  locationX/Y: double   // normalized 0.0–1.0
  refDecision: RefDecision?
  card: CardType?
  assessment: Assessment?   // 2×2 grid: correct/wrong × expected/complex
  sceneNote: String?
  coachingFlag: bool
  coachingNote: String?
}
```

### Key entity: Goal (US-215)

Goals are captured separately from events via the „+ Tor" buttons in the live header — no pitch location, no assessment.

```dart
Goal {
  elapsedMs: int / gamePhase   // frozen at button tap
  team: TeamSide        // team credited with the goal (also for own goals)
  scorerNumber: int?    // own goal: player of the defending team (= scorerTeam)
  kind: GoalKind        // regular · ownGoal · penalty
}
```

**Score** (`domain/entities/score.dart`) is always derived from goals, never stored (`Score.fromGoals`). DB schema is v8 (v8: `games.home_kit_color`/`away_kit_color`, US-111); the v6→v7 migration copies counted goal decisions into `goals` and turns all former `goalDecision` events into `custom` / „Torentscheidung". The `events.goal_scorer_*`/`own_goal` columns are legacy and unused.

## Implementation Status

All MVP features are implemented. See `docs/07_implementation.md` and `docs/08_test_report.md` for full details.

| Feature | Status |
|-----------------------------------|--------|
| Player ranking in stats tab | Done — `playerRankingProvider` aggregates EventPlayers per game |
| Squad chips in live event form | Done — loaded via `homeSquadProvider` / `awaySquadProvider` |
| Scene list filter (US-302) | Done — two-row filter bar (EventType + Korrekt/Falsch/Karte/Coaching) |
| Scene edit post-game (US-209) | Done — edit icon opens `EventFormPanel` as dialog with `initialEvent` |
| Indirect free kick in decisions | Done — `RefDecision.indirectFreeKick` ("Indir. FS") |
| CSV-Import (US-105) | Done — `PresskBerichtCsvParser` + `file_picker`; DB schema v2 (liga, spieltag) |
| Vergehen pro Team (US-404) | Done — `TeamFouls` + `teamFoulsProvider`; DB schema v6 (`event_players.jersey_number` nullable) |
| Laufendes Spiel fortsetzen (US-109) | Done — Tap in der Spielliste öffnet bei `GamePhase.istLaufend` den Live-Screen; Badge „Läuft" |
| Aufstellung im Live-Screen (US-110) | Done — `SquadEditDialog` über Button „Aufstellung"; `SquadInput` geteilt mit Spiel-Setup |
| Tor-Erfassung (US-215) | Done — „+ Tor"-Buttons je Team in der Live-Kopfzeile, `GoalDialog`, Tabelle `goals`; DB schema v7 |
| Android-Smartphone (US-701–706) | Done — Smartphone-Layout per `FormFactor.isPhone` (kürzere Seite < 600 dp, nicht per Plattform); Live-Screen quer mit Seitenleisten, Dialoge im Vollbild (`showAppDialog`); Display-Sperre über Kanal `de.beobachter/screen` in `MainActivity`; getrennte Workflows `build-windows.yml` / `build-android.yml` |
| Trikotfarben (US-111) | Done — `KitColorPicker` je Team in Setup und Dialog „Aufstellung"; `Game.homeKitColor`/`awayKitColor`, DB schema v8; Farben über `teamKitsProvider(gameId)` → `TeamKits.color(context, side)`, Fallback `AppColors.home/away`; helle Farben mit Rand (`AppColors.needsOutline`) |
| Nur Fouler, SR-Ball (US-216/217) | Done — Ereignisformular erfasst nur den Fouler; alte Gefoulten-Einträge bleiben beim Bearbeiten erhalten (`_legacyFouled`); `RefDecision.droppedBall` „SR-Ball" nach Einwurf; kein Schemawechsel |
| Szeneninfos (US-308) | Done — Fouler (Teamfarbe + Name + #Nr.) und „Fortsetzung: …" in Szenenliste und Coaching-Ansicht, Detail-Sheet mit allen Feldern; gemeinsames Widget `SceneInfoLine`/`ScenePlayer` (`widgets/scene_info.dart`), Spieler über `eventPlayersProvider(gameId)` (einmal pro Spiel, hängt an `eventsProvider`); kein Schemawechsel |
| UI-Redesign (US-601–606) | Done — helles Theme mit Inter, Aktionsleiste unten links im Live-Screen, große Auswahlflächen, Karten-Layouts, Statistik-Dashboard; Farben nur über `context.colors` / `context.scheme` (Teamfarben über `TeamKits`) |

## Development Pipeline

The project uses a structured multi-phase design pipeline. Each phase has a role-specific prompt in `prompts/`:

```
PO Interview → Epics → User Stories → UX Review → UX Design → Arch Review → Architecture → Dev → Testing
```

Run the full pipeline:
```bash
./run.sh
```

## Git Workflow

**MANDATORY — no exceptions:**

- **Ein Branch pro Bug bzw. Feature**, immer frisch von aktuellem `main` (`git fetch` + `main` per fast-forward auf `origin/main` bringen, dann abzweigen). Namensschema: `feature/<kurzname>` bzw. `fix/<kurzname>`.
- **Höchstens ein offener Feature-Branch.** Ein neues Feature wird erst begonnen, wenn der vorherige Feature-Branch per PR in `main` gemergt ist.
- Nie Änderungen für ein anderes Thema auf einem bestehenden Branch committen — liegt ungewollt Arbeit auf dem falschen Branch, per `git stash` auf den richtigen Branch mitnehmen.
- Gemergte Branches werden lokal und remote gelöscht.
- Integration in `main` nur per Pull Request.

## Feature Development Rules

**MANDATORY sequence for every new feature — no exceptions:**

1. **User Story** — Write and show US with acceptance criteria in the matching `docs/02_us_<epic>.md` file first. Wait for user confirmation before proceeding.
2. **UX Flow** — Add the user flow and wireframes to `docs/04_ux_design.md`.
3. **Test Cases** — Write test cases in a new `docs/NN_<feature>_tests.md` file.
4. **Implementation** — Only after steps 1–3 are complete and confirmed.
5. **Acceptance check** — After implementation, verify every acceptance criterion from the US and update checkboxes in the matching `docs/02_us_<epic>.md` file.

**If a user asks to implement a feature directly:** check whether a User Story exists in the `docs/02_us_*.md` files. If not, write the US first and show it before writing any code.
