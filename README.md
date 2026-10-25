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
| **Plattformübergreifend** | Native App für iOS, Android und Windows (Surface), optimiert für Tablets im Querformat. Auf Android-Smartphones gibt es ein eigenes Layout: Live-Erfassung quer, alles andere hoch. |
| **Lesbar draußen** | Ein helles, kontraststarkes Design für alle Screens. Zeitkritische Buttons liegen in Daumenreichweite: die Spieluhr unten links, Speichern unten rechts. |
| **Deutsch** | Oberfläche und alle Texte sind ausschließlich deutsch. |

Eine Synchronisation mit einem Server ist für später angedacht. Die Architektur ist dafür vorbereitet, im MVP aber bewusst nicht enthalten.

---

## Technik im Überblick

| Bereich | Technologie |
|---|---|
| Framework | Flutter 3.47.7 / Dart 3.13.5 |
| Datenbank | [Drift](https://drift.simonbinder.eu/) 2.31 (typsicherer SQLite-Wrapper), Schema-Version 6 |
| State Management | [Riverpod](https://riverpod.dev/) 2.6.1 |
| IDs | `uuid` |
| CSV-Import | `file_picker` + eigener Parser für DFB/FLVW-Presseberichte |
| Desktop-Fenster | `window_manager` (maximiert, feste Größe unter Windows/macOS) |
| Design | Material 3, ein helles Theme mit Design-Tokens (`presentation/theme/`), Schrift [Inter](https://rsms.me/inter/) gebündelt (SIL OFL) |
| Tests | `flutter_test`, `integration_test`, `mocktail`, Golden-Tests der Hauptscreens |
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
  theme/          app_theme · app_colors · app_spacing · app_motion · event_type_style
  widgets/        pitch_canvas · heatmap_canvas · timer_display · assessment_grid · select_tile · squad_input · …
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

Voraussetzung: [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.47.x.

```bash
cd src/

flutter pub get                       # Abhängigkeiten installieren
flutter pub run build_runner build    # Drift-Code generieren (einmalig und nach Schema-Änderungen)
flutter analyze                       # Statische Analyse
flutter test                          # Unit-, Widget- & Golden-Tests
flutter run                           # App starten (Simulator, Emulator oder Gerät)

# Nach gewollten UI-Änderungen die Referenzbilder neu erzeugen
flutter test --update-goldens --tags golden
```

Eine Beispiel-CSV für den Import liegt unter [`resources/`](resources/).

### Builds (GitHub Actions)

Windows und Android werden in zwei getrennten Workflows gebaut. Beide laufen bei jedem Push auf `main` und lassen sich unter **Actions** einzeln über **Run workflow** starten:

| Workflow | Datei | Artefakt |
|---|---|---|
| Build Windows | [`build-windows.yml`](.github/workflows/build-windows.yml) | `beobachter-app-windows` (Release-Ordner) |
| Build Android | [`build-android.yml`](.github/workflows/build-android.yml) | `beobachter-app-android` (`app-release.apk`) |

Die APK wird direkt auf dem Gerät installiert (kein Play Store; ggf. „Installation aus unbekannten Quellen" erlauben).

### Android-Release-Schlüssel einrichten

Damit eine neue APK über die alte installiert werden kann und die **lokalen Spieldaten erhalten bleiben**, muss jede Version mit demselben Schlüssel signiert sein. Ohne Schlüssel signiert jeder CI-Lauf mit einem anderen Debug-Schlüssel – dann muss die App vor jedem Update deinstalliert werden, und die Daten gehen verloren.

Einmalig (benötigt ein JDK, z. B. aus Android Studio):

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 \
        -validity 10000 -alias beobachter
base64 -i upload-keystore.jks | pbcopy      # macOS; Linux: base64 -w0 upload-keystore.jks
```

Dann unter **GitHub → Settings → Secrets and variables → Actions** anlegen:

| Secret | Inhalt |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Base64 der `.jks`-Datei |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore-Passwort |
| `ANDROID_KEY_ALIAS` | `beobachter` |
| `ANDROID_KEY_PASSWORD` | Schlüssel-Passwort |

Den Keystore und die Passwörter sicher aufbewahren – geht der Schlüssel verloren, lässt sich die App nicht mehr ohne Deinstallation aktualisieren. Für lokale Release-Builds eine `src/android/key.properties` anlegen (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`); sie ist per `.gitignore` ausgeschlossen. Fehlen Schlüssel oder Secrets, entsteht weiterhin eine debug-signierte APK.

---

## User Stories

Die Anforderungen sind in sieben Epics gegliedert. Die vollständigen Stories mit Akzeptanzkriterien stehen in [`docs/`](docs/).

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

### Epic 6 — UI-Modernisierung · [details](docs/02_us_ui_redesign.md)

| ID | Story | Status |
|---|---|---|
| US-601 | **Einheitliches helles Design** mit Inter und hohem Kontrast für den Außeneinsatz | ✅ |
| US-602 | **Live-Screen in Daumenreichweite**: Spieluhr, Aufstellung und Szenen unten links | ✅ |
| US-603 | **Erfassungsformular mit großen Auswahlflächen**, Speichern fest unten rechts | ✅ |
| US-604 | **Spielliste als Karten**, Setup zweispaltig mit fester Startleiste | ✅ |
| US-605 | **Nachbereitung als Karten**, Statistik als Dashboard | ✅ |
| US-606 | **Flüssige Übergänge**, ohne Taps zu verzögern; „Bewegung reduzieren" wird beachtet | ✅ |

### Epic 7 — Android-Smartphone · [details](docs/02_us_android.md)

| ID | Story | Status |
|---|---|---|
| US-701 | **Live-Erfassung auf dem Smartphone** im Querformat: Formular im Vollbild, Ereignisse als Seitenleiste | ✅ |
| US-702 | **Display bleibt während des Spiels an**, im Live-Screen abschaltbar | ✅ |
| US-703 | **Spielliste, Setup und Aufstellung** im Hochformat | ✅ |
| US-704 | **Nachbereitung und Statistik** auf dem Smartphone | ✅ |
| US-705 | **Android-App-Grundlagen**: Name, Icon, feste Signatur | ✅ |
| US-706 | **Getrennte Builds** für Windows und Android | ✅ |

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
| [`23_ui_redesign_plan.md`](docs/23_ui_redesign_plan.md) / [`24_ui_redesign_tests.md`](docs/24_ui_redesign_tests.md) | Plan und Testfälle des UI-Redesigns |
| [`26_android_smartphone_tests.md`](docs/26_android_smartphone_tests.md) | Testfälle Android-Smartphone und CI-Builds |

Die ursprüngliche App-Idee steht in [`idea.md`](idea.md). Unter [`prompts/`](prompts/) liegen rollenbasierte Prompts (Product Owner, UX, Architekt, Entwickler, Tester), mit denen [`run.sh`](run.sh) die komplette Design-Pipeline durchläuft.
