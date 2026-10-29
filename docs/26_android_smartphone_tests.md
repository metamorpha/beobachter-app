# Testfälle — Android-Smartphone (US-701 – US-706)

> Automatisiert in `test/android_smartphone_test.dart` und `test/golden/phone_golden_test.dart`, sofern nicht als **manuell** markiert.
> Prüfgrößen für Widget-Tests: Smartphone-Querformat **844 × 390 dp**, Smartphone-Hochformat **390 × 844 dp**, Tablet **1280 × 800 dp** (Gegenprobe).
> Technik:
> - Bildschirmgröße über `tester.view.physicalSize` / `devicePixelRatio = 1.0`
> - Plattform über `debugDefaultTargetPlatformOverride` (Android bzw. Windows)
> - Ausrichtung: Aufrufe von `SystemChrome.setPreferredOrientations` über einen Mock-Handler auf `SystemChannels.platform` mitschreiben
> - Display-Sperre: Wakelock hinter einem überschreibbaren Provider; im Test ein Fake, der `enable`/`disable` mitschreibt
> - Overflow: Jeder Widget-Test schlägt fehl, wenn `tester.takeException()` einen `FlutterError` (RenderFlex overflowed) liefert

---

## Regression (alle Stories)

### TC-7001: Bestehende Testsuite bleibt grün

**Schritte:** `flutter analyze` und `flutter test` ausführen.

**Erwartetes Ergebnis:** Keine Analyse-Befunde, alle bestehenden Tests grün — ohne Änderung an bestehenden Erwartungen.

---

### TC-7002: Tablet-/Windows-Goldens unverändert

**Schritte:** `flutter test --tags golden` auf macOS, **ohne** `--update-goldens`.

**Erwartetes Ergebnis:** Alle bestehenden 8 Golden-Tests (1280 × 800) sind grün; im Diff gibt es keine geänderten Dateien unter `test/golden/goldens/` außer neuen `phone_*.png`.

---

### TC-7003: Logik-Schichten unverändert (**manuell**)

**Schritte:** `git diff --stat main -- src/lib/domain src/lib/data src/lib/core src/lib/presentation/providers/providers.dart`

**Erwartetes Ergebnis:** Keine Änderungen.

---

### TC-7004: Layout-Weiche nach Größe, nicht nach Plattform

**Schritte:** Live-Screen jeweils aufbauen mit
a) 844 × 390 dp, Plattform Android,
b) 1280 × 800 dp, Plattform Android,
c) 1280 × 800 dp, Plattform Windows.

**Erwartetes Ergebnis:**
a) Smartphone-Layout (rechte Icon-Leiste vorhanden, kein Seitenpanel).
b) und c) Tablet-Layout (Seitenpanel „Letzte Ereignisse" sichtbar, keine rechte Icon-Leiste).

---

### TC-7005: Kein Overflow in Smartphone-Größe

**Schritte:** Spielliste (leer und mit 3 Spielen), Spiel-Setup, Live-Screen (vor Anpfiff, 1. HZ, nach Abpfiff mit zwei Phasen-Buttons, abgeschlossen), Erfassungsformular, Tor-Dialog, Aufstellung, Nachbereitung (alle drei Tabs) jeweils in der zugehörigen Smartphone-Größe aufbauen. Teamnamen mit 30 Zeichen verwenden.

**Erwartetes Ergebnis:** Keine Overflow-Fehler; lange Teamnamen werden mit „…" gekürzt.

---

## US-701 · Live-Erfassung auf dem Smartphone

### TC-7011: Querformat beim Öffnen, Hochformat beim Verlassen

**Schritte:** Smartphone-Größe, Plattform Android. Live-Screen öffnen, dann zurück zur Spielliste.

**Erwartetes Ergebnis:** Beim Öffnen wird `setPreferredOrientations([landscapeLeft, landscapeRight])` aufgerufen, beim Verlassen `setPreferredOrientations([portraitUp])`.

---

### TC-7012: Keine Ausrichtungs-Vorgabe auf Tablet/Windows

**Schritte:** Wie TC-7011, aber 1280 × 800 dp mit Plattform Windows bzw. Android.

**Erwartetes Ergebnis:** `setPreferredOrientations` wird nicht aufgerufen.

---

### TC-7013: Kompakte Kopfzeile

**Schritte:** Live-Screen in 844 × 390 dp, 1. HZ läuft, Spielstand 2 : 1.

**Erwartetes Ergebnis:** Kopfzeile ≤ 56 dp hoch; sichtbar sind beide Teamnamen, „2 : 1", Phase und Uhr; beide „+ Tor"-Buttons sind vorhanden (Keys wie bisher) und ≥ 48 dp hoch.

---

### TC-7014: Aktionsleisten in Daumenreichweite

**Schritte:** Live-Screen in 844 × 390 dp, Plattform Android.

**Erwartetes Ergebnis:**
- Phasen-Button liegt in der linken Leiste und ist ≥ 144 × 56 dp.
- Rechte Leiste enthält in dieser Reihenfolge: Ereignisse, Aufstellung (`btn_aufstellung`), Szenen (`btn_szenen`), Display; jeder Button ≥ 56 × 56 dp mit Tooltip.

---

### TC-7015: Zwei Phasen-Buttons nach Abpfiff

**Schritte:** Live-Screen in 844 × 390 dp nach Abpfiff der 2. HZ.

**Erwartetes Ergebnis:** „Verlängerung" und „Spiel beenden" stehen untereinander in der linken Leiste; kein Overflow.

---

### TC-7016: Ereignis erfassen im Vollbild-Formular

**Schritte:** 844 × 390 dp. Uhr starten, aufs Spielfeld tippen, Typ „Fußvergehen", Entscheidung „Freistoß", Bewertung „✓ Erwartbar", „Speichern".

**Erwartetes Ergebnis:**
- Das Formular öffnet sich als Vollbild-Dialog; „Speichern" ist ohne Scrollen sichtbar.
- Nach dem Speichern ist der Dialog geschlossen, das Ereignis ist gespeichert (Repository) und als Marker auf dem Spielfeld sichtbar.
- Höchstens 5 Taps vom Spielfeld bis zum gespeicherten Ereignis (gleich wie Tablet).

---

### TC-7017: Formular abbrechen

**Schritte:** Formular öffnen, Typ wählen, ✕ tippen.

**Erwartetes Ergebnis:** Dialog geschlossen, kein Ereignis gespeichert.

---

### TC-7018: „Letzte Ereignisse" als Seitenleiste

**Schritte:** 844 × 390 dp, zwei Ereignisse und ein Tor vorhanden. „Ereignisse" in der rechten Leiste tippen.

**Erwartetes Ergebnis:** Seitenleiste von rechts, Breite ≤ 50 % des Bildschirms; Einträge chronologisch, neuestes oben (wie TC-215-12); jede Zeile ≥ 56 dp.

---

### TC-7019: Löschen und Tor bearbeiten aus der Seitenleiste

**Schritte:** In der Seitenleiste 🗑 eines Ereignisses tippen; danach auf das Tor tippen.

**Erwartetes Ergebnis:** Das Ereignis ist gelöscht (`deleteEvent()`), die Liste aktualisiert sich; der Tap auf das Tor öffnet „Tor bearbeiten" (vorausgefüllt).

---

### TC-7020: Tor-Dialog und Aufstellung im Vollbild

**Schritte:** 844 × 390 dp. „+ Tor" (Heim) tippen → speichern. Danach „Aufstellung" tippen → Nummer hinzufügen → schließen.

**Erwartetes Ergebnis:** Beide öffnen als Vollbild-Dialog ohne Overflow; Tor ist gespeichert, Spielstand in der Kopfzeile aktualisiert; die Aufstellung enthält die neue Nummer.

---

### TC-7021: Zurück schließt zuerst das oberste Element

**Schritte:** 844 × 390 dp. a) Formular offen → Zurück. b) Seitenleiste offen → Zurück.

**Erwartetes Ergebnis:** a) Formular geschlossen, Live-Screen bleibt. b) Seitenleiste geschlossen, Live-Screen bleibt. Kein Bestätigungsdialog.

---

### TC-7022: Zurück im Live-Screen fragt nach

**Schritte:** 844 × 390 dp, Spiel läuft, nichts geöffnet. Zurück → „Bleiben"; erneut Zurück → „Verlassen".

**Erwartetes Ergebnis:**
- Dialog „Live-Erfassung verlassen?" mit dem Hinweis, dass die Uhr weiterläuft.
- „Bleiben": Live-Screen bleibt offen, Uhr läuft weiter.
- „Verlassen": Spielliste wird angezeigt, das Spiel trägt das Badge „Läuft".

---

### TC-7023: Keine Nachfrage bei abgeschlossenem Spiel

**Schritte:** 844 × 390 dp, Spiel abgeschlossen. Zurück.

**Erwartetes Ergebnis:** Direkt zurück zur Spielliste, kein Dialog.

---

### TC-7024: Tablet-Verhalten der Zurück-Taste unverändert

**Schritte:** 1280 × 800 dp, Plattform Windows, Spiel läuft. Zurück (Navigator-Pop).

**Erwartetes Ergebnis:** Verhalten wie vor Epic 7 (kein neuer Bestätigungsdialog).

---

## US-702 · Display bleibt während des Spiels an

### TC-7031: Display-Sperre beim Öffnen aktiv

**Schritte:** Plattform Android, 844 × 390 dp, Live-Screen öffnen (Wakelock-Fake).

**Erwartetes Ergebnis:** `enable` wurde einmal aufgerufen; Display-Button zeigt Zustand „an" (Icon `light_mode`, Tooltip „Display bleibt an …").

---

### TC-7032: Schalter aus und wieder an

**Schritte:** Display-Button tippen, dann erneut tippen.

**Erwartetes Ergebnis:** Erster Tap: `disable`, Icon `light_mode_outlined`, Tooltip „Display geht automatisch aus …". Zweiter Tap: `enable`, Zustand „an".

---

### TC-7033: Sperre wird beim Verlassen aufgehoben

**Schritte:** Live-Screen öffnen (Sperre an), zur Spielliste zurückgehen.

**Erwartetes Ergebnis:** `disable` wurde beim Verlassen aufgerufen.

---

### TC-7034: Beim erneuten Öffnen wieder an

**Schritte:** Live-Screen öffnen, Schalter aus, verlassen, Live-Screen erneut öffnen.

**Erwartetes Ergebnis:** Zustand „an", `enable` erneut aufgerufen.

---

### TC-7035: Schalter auf Android-Tablet

**Schritte:** Plattform Android, 1280 × 800 dp, Live-Screen öffnen.

**Erwartetes Ergebnis:** Display-Button erscheint in der Aktionsleiste unten links; Verhalten wie TC-7031/7032.

---

### TC-7036: Kein Schalter, keine Wirkung unter Windows

**Schritte:** Plattform Windows, 1280 × 800 dp, Live-Screen öffnen und verlassen.

**Erwartetes Ergebnis:** Kein Display-Button vorhanden; Wakelock-Fake wurde nie aufgerufen.

---

## US-703 · Spielliste, Spiel-Setup und Aufstellung auf dem Smartphone

### TC-7041: Hochformat außerhalb des Live-Screens

**Schritte:** Smartphone-Größe, Plattform Android, App starten.

**Erwartetes Ergebnis:** Beim Start wird `setPreferredOrientations([portraitUp])` aufgerufen. Auf Tablet-Größe bzw. Windows nicht.

---

### TC-7042: Spielliste einspaltig

**Schritte:** 390 × 844 dp, drei Spiele, eines davon läuft.

**Erwartetes Ergebnis:** Eine Spalte; das laufende Spiel zeigt „Läuft"; Tap darauf öffnet den Live-Screen (US-109); Löschen funktioniert wie bisher.

---

### TC-7043: Spiel-Setup untereinander, „Spiel starten" fix

**Schritte:** 390 × 844 dp, Spiel-Setup öffnen.

**Erwartetes Ergebnis:** Spieldaten stehen über den Aufstellungen; „Spiel starten" ist ohne Scrollen sichtbar und ≥ 56 dp hoch.

---

### TC-7044: Tastatur verdeckt kein Eingabefeld

**Schritte:** 390 × 844 dp, `viewInsets.bottom = 300`. Feld „Aufstellung Gast" fokussieren.

**Erwartetes Ergebnis:** Das fokussierte Feld liegt vollständig oberhalb der Tastatur.

---

### TC-7045: Dialoge passen sich der Breite an

**Schritte:** 390 × 844 dp. Bestätigungsdialog „Spiel löschen" öffnen.

**Erwartetes Ergebnis:** Der Dialog ist höchstens Bildschirmbreite − 32 dp breit; kein Overflow. (Vollbild-Dialoge prüfen TC-7020 und TC-7053.)

---

### TC-7046: CSV-Import auf Android (**manuell**)

**Schritte:** Auf einem Android-Gerät eine Pressebericht-CSV (aus `10_csv_import_tests.md`) über „Aus Pressebericht importieren" auswählen.

**Erwartetes Ergebnis:** Die System-Dateiauswahl öffnet sich; Felder und Aufstellungen werden wie unter Windows befüllt; Warnungen erscheinen als Banner.

---

## US-704 · Nachbereitung und Statistik auf dem Smartphone

### TC-7051: Tabs vorhanden

**Schritte:** 390 × 844 dp, Nachbereitung öffnen.

**Erwartetes Ergebnis:** Tabs Szenen, Coaching, Statistik.

---

### TC-7052: Filterleiste horizontal scrollbar

**Schritte:** Szenen-Tab, Filterleiste nach links wischen, Filter „Abseits" wählen.

**Erwartetes Ergebnis:** Die Leiste scrollt horizontal (kein Umbruch, kein Overflow); die Liste zeigt nur Abseits-Szenen (wie US-302).

---

### TC-7053: Szene bearbeiten im Vollbild

**Schritte:** ✎ an einer Szene tippen, Bewertung ändern, speichern.

**Erwartetes Ergebnis:** Formular öffnet als Vollbild-Dialog mit vorausgefüllten Werten; Änderung ist gespeichert.

---

### TC-7054: Statistik-Karten untereinander

**Schritte:** Statistik-Tab, bis ans Ende scrollen.

**Erwartetes Ergebnis:** Karten Heatmap, Zeitachse, Spieler-Ranking, Tore, Vergehen pro Team stehen untereinander und sind alle erreichbar; kein Overflow.

---

## US-705 · Android-App-Grundlagen

### TC-7061: App-Name und Berechtigungen (**manuell**, Build-Prüfung)

**Schritte:** `src/android/app/src/main/AndroidManifest.xml` prüfen; APK installieren.

**Erwartetes Ergebnis:** `android:label="Beobachter"`; keine `uses-permission`-Einträge im Release-Manifest (`aapt dump permissions`); auf dem Homescreen erscheint „Beobachter" mit grünem App-Icon.

---

### TC-7062: Update ohne Datenverlust (**manuell**)

**Schritte:** APK aus CI-Lauf A installieren, ein Spiel mit Ereignissen anlegen. APK aus späterem CI-Lauf B (gleicher Release-Schlüssel) darüber installieren.

**Erwartetes Ergebnis:** Installation ohne Deinstallation möglich; das Spiel und alle Ereignisse sind vorhanden.

---

### TC-7063: Uhr nach Hintergrund und Prozess-Ende (**manuell**)

**Schritte:** Auf dem Gerät Spiel starten, App in den Hintergrund, 2 Minuten warten. Danach App in der Übersicht wegwischen, neu öffnen, Spiel fortsetzen.

**Erwartetes Ergebnis:** Die Uhr zeigt jeweils die korrekt weitergelaufene Zeit (± 1 s).

---

### TC-7064: Display bleibt an (**manuell**)

**Schritte:** Bildschirm-Timeout auf 30 s stellen. Live-Screen 2 Minuten ohne Eingabe offen lassen; dann Schalter aus und 1 Minute warten.

**Erwartetes Ergebnis:** Mit Schalter „an" bleibt das Display an; mit „aus" geht es nach dem Timeout aus.

---

### TC-7065: Drehen und Notch (**manuell**)

**Schritte:** Gerät mit Kamera-Loch. Live-Screen in beiden Querlagen, Spielliste im Hochformat ansehen; Gerät drehen.

**Erwartetes Ergebnis:** Kein Inhalt unter Kamera-Loch oder Gestenleiste; Live-Screen bleibt quer, Spielliste bleibt hoch.

---

## US-706 · Getrennte Builds für Windows und Android

### TC-7071: Beide Workflows bei Push auf `main` (**manuell**)

**Schritte:** Nach dem Merge Push auf `main`; GitHub → Actions.

**Erwartetes Ergebnis:** „Build Windows" und „Build Android" laufen als zwei getrennte Workflows.

---

### TC-7072: Einzeln manuell startbar (**manuell**)

**Schritte:** Actions → „Build Android" → „Run workflow"; danach dasselbe für „Build Windows".

**Erwartetes Ergebnis:** Es startet jeweils nur der gewählte Workflow.

---

### TC-7073: Android-Artefakt (**manuell**)

**Schritte:** Erfolgreichen Lauf von „Build Android" öffnen.

**Erwartetes Ergebnis:** Analyse und Tests sind gelaufen; Artefakt `beobachter-app-android` enthält eine installierbare `app-release.apk`; Aufbewahrung 30 Tage.

---

### TC-7074: Signatur mit Release-Schlüssel (**manuell**)

**Schritte:** `apksigner verify --print-certs app-release.apk` für zwei verschiedene Läufe.

**Erwartetes Ergebnis:** Beide Läufe zeigen dasselbe Zertifikat, nicht `CN=Android Debug`.

---

### TC-7075: Build ohne Secrets (**manuell**)

**Schritte:** Workflow in einem Fork ohne die Signatur-Secrets starten.

**Erwartetes Ergebnis:** Build ist grün, APK ist debug-signiert; das Log enthält einen deutlichen Hinweis auf die fehlende Release-Signatur.

---

### TC-7076: Workflows unabhängig (**manuell**)

**Schritte:** Auf einem Test-Branch einen absichtlichen Fehler nur im Android-Build provozieren (z. B. ungültige Gradle-Einstellung) und beide Workflows starten.

**Erwartetes Ergebnis:** „Build Android" schlägt fehl, „Build Windows" ist grün.

---

### TC-7077: Beide Workflows bei Pull Request (**manuell**)

**Schritte:** Pull Request von einem Feature-Branch gegen `main` öffnen; danach einen weiteren Commit auf den Branch pushen.

**Erwartetes Ergebnis:** „Build Windows" und „Build Android" erscheinen als getrennte Checks im PR und laufen nach dem neuen Commit erneut; das Android-Artefakt steht im jeweiligen Lauf zum Download bereit.

---

## Übersicht

| Bereich | TCs | davon manuell |
|---|---|---|
| Regression | 5 | 1 |
| US-701 Live | 14 | 0 |
| US-702 Display | 6 | 0 |
| US-703 Spielliste/Setup | 6 | 1 |
| US-704 Nachbereitung | 4 | 0 |
| US-705 Grundlagen | 5 | 5 |
| US-706 CI | 7 | 7 |
| **Summe** | **47** | **14** |

Zusätzlich neue Golden-Tests in `test/golden/phone_golden_test.dart`: Spielliste, Spiel-Setup, Szenenliste und Statistik (390 × 844); Live-Screen, Erfassungsformular und Seitenleiste „Letzte Ereignisse" (844 × 390).

## Ergebnis (2026-10-25)

- Automatisiert: alle 33 automatisierten TCs grün (40 Testfunktionen in `test/android_smartphone_test.dart`), 7 Smartphone-Goldens erzeugt.
- Regression: `flutter analyze` ohne Befunde, `flutter test` 297 Tests grün; die 8 Tablet-Goldens unverändert (TC-7002).
- TC-7003: keine Änderungen unter `domain/`, `data/`, `core/` und in `providers.dart`.
- Offen (manuell, Gerät bzw. GitHub nötig): TC-7046, TC-7061 – TC-7065, TC-7071 – TC-7076.

## Ergebnis (2026-10-26)

- TC-7046 bestanden: Die App wurde auf einem Pixel 8 Pro installiert, und der CSV-Import funktioniert.
- TC-7064 bestanden: Die Display-Sperre funktioniert auf dem Pixel 8 Pro.
- TC-7073 bestanden: „Build Android“ ist grün (inkl. Analyse und Tests); das Artefakt `beobachter-app-android` enthält die APK.
- TC-7077 bestanden: Im PR laufen „Build Windows“ und „Build Android“ als getrennte Checks, beide grün. Der Commit mit diesem Eintrag stößt beide erneut an.
- Release-Signatur eingerichtet (Secrets hinterlegt); „Build Android“ läuft ohne Warnung „Keine Release-Signatur“.
- TC-7062 bestanden: Auf dem Pixel 8 Pro ließ sich eine neue APK über die alte installieren; die Spieldaten blieben erhalten.
- TC-7074 bestanden: Das Update zwischen zwei CI-Läufen hat geklappt, beide APKs tragen also denselben Release-Schlüssel (Android lehnt ein Update mit anderer Signatur ab).
- TC-7061 teilweise: App-Name „Beobachter“ und grünes Icon auf dem Homescreen bestätigt; die Berechtigungsprüfung (`aapt dump permissions`) steht noch aus.
- Weiterhin offen (manuell): TC-7061 (Berechtigungen), TC-7063, TC-7065, TC-7071, TC-7072, TC-7075, TC-7076.
