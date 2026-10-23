# Beobachter-App

**Live-Erfassung für Schiedsrichterbeobachter im Fußball**

Als Schiedsrichterbeobachter hat man während eines Spiels keine Hand frei, keine Zeit und meist kein Netz. Die Beobachter-App ersetzt Notizblock und Stoppuhr: Man tippt auf die Stelle des Spielfelds, an der etwas passiert ist, wählt mit wenigen Taps Ereignistyp, Schiedsrichterentscheidung und Bewertung aus, und die Spielzeit wird automatisch mitgeschrieben. Nach dem Abpfiff stehen eine chronologische Szenenliste, eine Coaching-Ansicht für das Gespräch mit dem Schiedsrichter und Statistiken bereit, etwa Hotspots auf dem Feld, belastende Spielphasen und auffällige Spieler.

> Ziel: Ein beobachtetes Ereignis lässt sich in **unter 10 Sekunden** vollständig erfassen.

---

## Inhalt

- [So funktioniert die App](#so-funktioniert-die-app)
- [Leitprinzipien](#leitprinzipien)
- [Technik im Überblick](#technik-im-überblick)
- [Architektur](#architektur)
- [Domänenmodell](#domänenmodell)
- [Loslegen](#loslegen)
- [User Stories](#user-stories)
- [Dokumentation & Entwicklungsprozess](#dokumentation--entwicklungsprozess)

---

## So funktioniert die App

### 1. Vor dem Spiel: Spiel anlegen
- Spieldaten erfassen: Datum, Ort, Heim- und Gastmannschaft, Liga, Spieltag
- Aufstellungen beider Teams eingeben (Rückennummern)
- **Oder:** einen **Pressebericht als CSV** (DFB/FLVW-Format) importieren, dann sind Spieldaten und Aufstellungen sofort da

### 2. Während des Spiels: Live-Erfassung
- **Spieluhr** mit echten Spielphasen: 1. Halbzeit, Halbzeitpause, 2. Halbzeit, Nachspielzeit (`45+02`, `90+03`) und optional Verlängerung (2 × 15 Min.)
- **Tipp aufs Spielfeld** startet die Erfassung. Der Ort wird gespeichert, die Spielminute automatisch übernommen
- **Ereignistyp** per Schnellauswahl: Fußvergehen · Oberkörpervergehen · Handspiel · Unsportlichkeit · Tätlichkeit · Abseits · Vorteil · Torentscheidung · Sonstiges
- **Beteiligte Spieler** (Täter / Gefoulter) per Rückennummer-Chips aus der Aufstellung
- **Schiedsrichterentscheidung** als Raster: Freistoß, indirekter Freistoß, Strafstoß, Vorteil, Weiterspielen, Karten, Eckstoß, Abstoß, Einwurf, Tor …
- **Bewertung** im 2×2-Raster: *korrekt / falsch* × *erwartbar / komplex*
- Optionale **Szenennotiz**
- **Speichern mit einem Tap**, versehentlich erfasste Ereignisse lassen sich im Seitenpanel direkt löschen
- **Spielstand & Torschützen** (inkl. Eigentor) werden aus den Torentscheidungen abgeleitet und unter den Teamnamen angezeigt
- **Seitenpanel** mit den zuletzt erfassten Ereignissen, Aufstellung jederzeit im Spiel korrigierbar

### 3. Nach dem Spiel: Nachbereitung & Coaching
- **Szenenliste** chronologisch, filterbar nach Ereignistyp, Korrekt/Falsch, Karte, Coaching
- Szenen nachträglich **bearbeiten**
- Szenen per Tap **für das Coaching markieren** und mit einer eigenen **Coaching-Notiz** versehen
- **Coaching-Ansicht** nur mit den markierten Szenen, plus eine **allgemeine Notiz** zum ganzen Spiel

### 4. Statistik & Analyse
- **Heatmap**: Ereignisdichte auf dem Spielfeld als kontinuierliche Dichteverteilung (KDE)
- **Zeitachse**: Ereignisse pro 15-Minuten-Phase, macht Belastungsphasen sichtbar
- **Spieler-Ranking**: welche Spieler am häufigsten als Täter auffielen
- **Vergehen pro Team und Halbzeit**: Fuß-, Oberkörper- und andere Vergehen im Vergleich

---

## Leitprinzipien

| Prinzip | Bedeutung |
|---|---|
| **Offline-first** | Auf dem Sportplatz gibt es meist kein Internet. Alles läuft lokal, Daten liegen in einer SQLite-Datenbank auf dem Gerät. |
| **Geschwindigkeit** | Der Beobachter schaut aufs Spiel, nicht aufs Display: große Tap-Ziele, kaum Pflichtfelder (nur Ereignistyp + Entscheidung), möglichst ein Tap pro Schritt. |
| **Robuste Spieluhr** | Die Uhr rechnet mit Zeitstempeln statt mit Intervallen. Sie läuft korrekt weiter, auch wenn die App im Hintergrund war oder neu gestartet wurde. |
| **Plattformübergreifend** | Native App für iOS, Android und Windows (Surface), optimiert für Tablets im Querformat. |
| **Deutsch** | Oberfläche und alle Texte sind ausschließlich deutsch. |

Eine Synchronisation mit einem Server ist für später angedacht. Die Architektur ist dafür vorbereitet, im MVP aber bewusst nicht enthalten.

---

## Technik im Überblick

| Bereich | Technologie |
|---|---|
| Framework | Flutter 3.41.7 / Dart 3.11.5 |
| Datenbank | [Drift](https://drift.simonbinder.eu/) 2.31 (typsicherer SQLite-Wrapper), Schema-Version 6 |
| State Management | [Riverpod](https://riverpod.dev/) 2.6.1 |
| IDs | `uuid` |
| CSV-Import | `file_picker` + eigener Parser für DFB/FLVW-Presseberichte |
| Desktop-Fenster | `window_manager` (maximiert, feste Größe unter Windows/macOS) |
| Tests | `flutter_test`, `integration_test`, `mocktail` |
| Zielplattformen | iOS · Android · Windows (Surface) · macOS |

---

## Architektur

Drei Schichten mit Repository-Pattern:

```
UI (Flutter Widgets + Riverpod Provider)
  ↓
Repository-Schicht (abstrakte Interfaces, später gegen Remote austauschbar)
  ↓
Datenschicht (Drift / SQLite, lokal)
```

Wichtige Designentscheidungen:

- **Zeitstempel-basierte Spieluhr:** `aktuelleZeit = bisherVergangen + (jetzt − Startzeitpunkt)`. Der sekündliche Ticker aktualisiert nur die Anzeige, der Zustand liegt in der Datenbank.
- **Normalisierte Koordinaten:** Spielfeldpositionen werden als Werte von 0.0 bis 1.0 gespeichert und sind damit unabhängig von der Auflösung.
- **Abgeleiteter Spielstand:** Der Spielstand wird nie gespeichert, sondern immer aus den Torentscheidungen berechnet.
- **Kaskadierendes Löschen:** `PRAGMA foreign_keys = ON`, Spiel → Ereignisse → beteiligte Spieler.
- **Drift-Datenklassen** heißen `GameRow`, `EventRow` usw. und kollidieren so nicht mit den Domain-Entities.

### Projektstruktur (`src/lib/`)

```
domain/
  entities/       Game · Event · EventPlayer · Squad · TimerState · Score
  enums/          EventType · RefDecision · CardType · Assessment · TeamSide · PlayerRole · GamePhase
  repositories/   Abstrakte Interfaces
data/
  database/       Drift-Tabellen + AppDatabase
  repositories/   Konkrete Implementierungen
core/
  timer_service.dart              Hintergrundsichere Spieluhr mit Phasensteuerung
  pressebericht_csv_parser.dart   CSV-Parser (DFB/FLVW)
presentation/
  providers/      Riverpod-Provider
  screens/        game_list · game_setup · live · review
  widgets/        pitch_canvas · heatmap_canvas · timer_display · assessment_grid · squad_input · squad_edit_dialog
```

---

## Domänenmodell

Das zentrale Objekt ist das **Ereignis** (`Event`):

| Feld | Bedeutung |
|---|---|
| `elapsedMs` | Spielzeit in Millisekunden seit Anpfiff |
| `type` / `customTypeLabel` | Ereignistyp, bei „Sonstiges" mit Freitext |
| `locationX` / `locationY` | Ort auf dem Spielfeld (0.0–1.0) |
| `refDecision` | Entscheidung des Schiedsrichters |
| `card` | Gelb · Gelb-Rot · Rot (optional) |
| `assessment` | Bewertung: korrekt/falsch × erwartbar/komplex |
| `sceneNote` | Notiz zur Szene (live erfasst) |
| `coachingFlag` / `coachingNote` | Markierung und Notiz fürs Coaching-Gespräch |
| `goalScorerTeam` / `goalScorerNumber` / `ownGoal` | Torschütze bei Torentscheidungen |

Dazu kommen `Game` (Spieldaten), `Squad` (Aufstellungen), `EventPlayer` (beteiligte Spieler mit Rolle Täter/Gefoulter) und `TimerState` (Zustand der Spieluhr inkl. Spielphase).

---

## Loslegen

Voraussetzung: [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.41.x.

```bash
cd src/

flutter pub get                       # Abhängigkeiten installieren
flutter pub run build_runner build    # Drift-Code generieren (einmalig und nach Schema-Änderungen)
flutter analyze                       # Statische Analyse
flutter test                          # Unit- & Widget-Tests
flutter run                           # App starten (Simulator, Emulator oder Gerät)
```

Eine Beispiel-CSV für den Import liegt unter [`resources/`](resources/).

---

## User Stories

Die Anforderungen sind in fünf Epics gegliedert. Die vollständigen Stories mit Akzeptanzkriterien stehen in [`docs/`](docs/).

**Legende:** ✅ umgesetzt · 🟡 umgesetzt, einzelne Kriterien (meist Filter) noch offen

### Epic 1 — Spielverwaltung · [details](docs/02_us_spielverwaltung.md)

| ID | Story | Status |
|---|---|---|
| US-101 | **Neues Spiel anlegen** mit Datum, Ort, Teams, Liga und Spieltag | ✅ |
| US-102 | **Aufstellungen erfassen**: Rückennummern beider Teams | ✅ |
| US-103 | **Spieluhr starten und stoppen** per Knopfdruck | ✅ |
| US-104 | **Gespeicherte Spiele aufrufen** in einer Übersicht | ✅ |
| US-105 | **Pressebericht-CSV importieren**: Spieldaten und Aufstellungen automatisch übernehmen | ✅ |
| US-106 | **Spiel löschen** inkl. aller Ereignisse | ✅ |
| US-107 | **Fenstergröße fixiert** auf die Geräteauflösung (Windows/Surface) | ✅ |
| US-108 | **Fenstergröße fixiert** auf macOS | ✅ |
| US-109 | **Laufendes Spiel fortsetzen** direkt aus der Spielliste („Läuft"-Badge) | ✅ |
| US-110 | **Aufstellung während des Spiels korrigieren** | ✅ |

### Epic 2 — Live-Ereigniserfassung · [details](docs/02_us_live_erfassung.md)

| ID | Story | Status |
|---|---|---|
| US-201 | **Ereignis per Feldtipp starten**: Ort und Spielzeit werden automatisch erfasst | ✅ |
| US-202 | **Ereignistyp wählen** per Schnellauswahl | ✅ |
| US-203 | **Beteiligte Spieler angeben** (Täter und Gefoulter) | ✅ |
| US-204 | **Schiedsrichterentscheidung erfassen** per Tap | ✅ |
| US-205 | **Karte als Attribut erfassen** (Gelb, Gelb-Rot, Rot) | ✅ |
| US-206 | **Ereignis bewerten**: Entscheidung korrekt/falsch, Szene erwartbar/komplex | ✅ |
| US-207 | **Szenennotiz hinzufügen** (optional, Freitext) | ✅ |
| US-208 | **Ereignis speichern** mit einem Tap | ✅ |
| US-209 | **Ereignis nachträglich bearbeiten** | ✅ |
| US-210 | **Spieluhr mit Halbzeiten und Nachspielzeit** (`45+X`, `90+X`) | ✅ |
| US-211 | **Verlängerung starten und verwalten** (2 × 15 Min.) | ✅ |
| US-212 | **Spiel endgültig beenden**: danach keine neue Erfassung mehr, Nachbereitung bleibt möglich | ✅ |
| US-213 | **Ereignisliste im Live-Seitenpanel** | ✅ |
| US-214 | **Spielstand und Torschütze** inkl. Eigentor | ✅ |

### Epic 3 — Spielnachbereitung & Coaching · [details](docs/02_us_spielnachbereitung.md)

| ID | Story | Status |
|---|---|---|
| US-301 | **Chronologische Szenenliste** aller Ereignisse | ✅ |
| US-302 | **Szenen filtern** nach Typ, Korrekt/Falsch, Karte, Coaching | 🟡 |
| US-303 | **Szene für Coaching markieren** mit einem Tap | ✅ |
| US-304 | **Coaching-Notiz erfassen**, getrennt von der Szenennotiz | ✅ |
| US-305 | **Coaching-Ansicht**: nur die markierten Szenen | ✅ |
| US-306 | **Szenen- und Coaching-Notizen** direkt in der Coaching-Ansicht | ✅ |
| US-307 | **Allgemeine Coaching-Notiz** zum gesamten Spiel | ✅ |

### Epic 4 — Statistik & Analyse · [details](docs/02_us_statistik.md)

| ID | Story | Status |
|---|---|---|
| US-401 | **Heatmap** der Ereignisorte als Dichteverteilung (KDE) | 🟡 |
| US-402 | **Zeitachse**: Ereignisse pro 15-Minuten-Phase | 🟡 |
| US-403 | **Spieler-Ranking**: auffälligste Täter | 🟡 |
| US-404 | **Vergehen pro Team und Halbzeit** | ✅ |

### Epic 5 — Datenpersistenz & Offline · [details](docs/02_us_datenpersistenz.md)

| ID | Story | Status |
|---|---|---|
| US-501 | **Automatisches lokales Speichern** jedes Ereignisses | ✅ |
| US-502 | **Offline-Betrieb**: volle Funktion ohne Internet | ✅ |

### Ideen für später
- Synchronisation mit einem Server
- Export der Nachbereitung (PDF, E-Mail)
- Sprachnotizen während des Spiels
- Spieldaten direkt aus einer externen Quelle laden

---

## Dokumentation & Entwicklungsprozess

Jedes Feature durchläuft eine feste Reihenfolge: **User Story → UX-Flow → Testfälle → Implementierung → Abnahme**. Die Ergebnisse jeder Phase liegen in [`docs/`](docs/):

| Datei | Inhalt |
|---|---|
| [`01_epics.md`](docs/01_epics.md) | MVP-Epics, priorisiert für den Live-Einsatz |
| `02_us_*.md` | User Stories mit Akzeptanzkriterien, je Epic |
| [`03_ux_review.md`](docs/03_ux_review.md) / [`04_ux_design.md`](docs/04_ux_design.md) | UX-Review, Wireframes, User Flows |
| [`05_arch_review.md`](docs/05_arch_review.md) / [`06_architecture.md`](docs/06_architecture.md) | Architektur-Review, Datenmodell, UML |
| [`07_implementation.md`](docs/07_implementation.md) | Implementierungsnotizen, bekannte Einschränkungen |
| [`08_test_report.md`](docs/08_test_report.md) | Teststrategie und QA-Bericht |
| `09`–`22_*.md` | UX-Flows und Testfälle zu einzelnen Features |

Die ursprüngliche App-Idee steht in [`idea.md`](idea.md). Unter [`prompts/`](prompts/) liegen rollenbasierte Prompts (Product Owner, UX, Architekt, Entwickler, Tester), mit denen [`run.sh`](run.sh) die komplette Design-Pipeline durchläuft.
