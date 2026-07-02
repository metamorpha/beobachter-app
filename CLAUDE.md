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
| Framework | Flutter 3.41.7 / Dart 3.11.5 |
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
- **Undo**: 5-second SnackBar after each saved event calls `deleteEvent()`.

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
| `02_us_spielverwaltung.md` | User stories — Epic 1: Spielverwaltung (US-101–108) |
| `02_us_live_erfassung.md` | User stories — Epic 2: Live-Ereigniserfassung (US-201–209) |
| `02_us_spielnachbereitung.md` | User stories — Epic 3: Spielnachbereitung & Coaching (US-301–305) |
| `02_us_statistik.md` | User stories — Epic 4: Statistik & Analyse (US-401–403) |
| `02_us_datenpersistenz.md` | User stories — Epic 5: Datenpersistenz & Offline (US-501–502) |
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

### src/lib/ structure

```
domain/
  entities/     Game · Event · EventPlayer · Squad · TimerState
  enums/        EventType · RefDecision · CardType · Assessment · TeamSide · PlayerRole
  repositories/ Abstract interfaces (GameRepository, EventRepository, SquadRepository, TimerRepository)
data/
  database/
    tables/     5 Drift tables (games, events, event_players, squads, timer_states)
    app_database.dart  @DriftDatabase + foreign_keys pragma
  repositories/ Concrete implementations
core/
  timer_service.dart              Background-safe game clock
  pressebericht_csv_parser.dart  DFB/FLVW Pressebericht CSV parser
presentation/
  providers/    All Riverpod providers
  screens/      game_list · game_setup · live · review
  widgets/      pitch_canvas · heatmap_canvas · timer_display · assessment_grid
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

# Run tests (119 tests, all green)
flutter test

# Run app (simulator or device)
flutter run
```

## Domain Model

### Core enums

| Enum | Values |
|------|--------|
| `EventType` | footFoul · bodyFoul · handball · unsporting · violent · offside · advantage · goalDecision · custom |
| `RefDecision` | freeKick · **indirectFreeKick** · penalty · advantage · playOn · yellowCard · yellowRedCard · redCard · cornerKick · goalKick · throwIn · goal |
| `CardType` | yellow · yellowRed · red |
| `Assessment` | correctExpected · correctComplex · wrongExpected · wrongComplex |
| `TeamSide` | home · away |
| `PlayerRole` | fouler · fouled |

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

## Development Pipeline

The project uses a structured multi-phase design pipeline. Each phase has a role-specific prompt in `prompts/`:

```
PO Interview → Epics → User Stories → UX Review → UX Design → Arch Review → Architecture → Dev → Testing
```

Run the full pipeline:
```bash
./run.sh
```

## Feature Development Rules

**MANDATORY sequence for every new feature — no exceptions:**

1. **User Story** — Write and show US with acceptance criteria in the matching `docs/02_us_<epic>.md` file first. Wait for user confirmation before proceeding.
2. **UX Flow** — Add the user flow and wireframes to `docs/04_ux_design.md`.
3. **Test Cases** — Write test cases in a new `docs/NN_<feature>_tests.md` file.
4. **Implementation** — Only after steps 1–3 are complete and confirmed.
5. **Acceptance check** — After implementation, verify every acceptance criterion from the US and update checkboxes in the matching `docs/02_us_<epic>.md` file.

**If a user asks to implement a feature directly:** check whether a User Story exists in the `docs/02_us_*.md` files. If not, write the US first and show it before writing any code.
