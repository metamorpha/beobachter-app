# User Stories — Epic 7: Android-Smartphone

> Fokus: Die App lässt sich neben dem Windows-Tablet (Surface) auch auf einem Android-Smartphone bedienen.
> Gerät: Android-Smartphone. Live-Erfassung im **Querformat**, Spielliste, Spiel-Setup und Nachbereitung im **Hochformat**.
> Verteilung: APK zum direkten Installieren (kein Play Store).
> Rahmen: Geschäftslogik und die Windows-Oberfläche bleiben unverändert.

**Gilt für alle Stories dieses Epics:**
- [x] Unter `domain/`, `data/` und `core/` sowie in `providers.dart` ändert sich keine Zeile
- [x] Das Smartphone-Layout wird über die Bildschirmgröße gewählt (`shortestSide < 600` dp), nicht über die Plattform. Darüber (Windows-Surface, Android-Tablets) gilt das bestehende Layout unverändert
- [x] Die bestehenden Golden-Tests (1280 × 800) bleiben ohne neue Referenzbilder grün
- [x] Neue Golden-Tests decken die Smartphone-Layouts ab (Hochformat 390 × 844, Querformat 844 × 390)
  *Umsetzung: 7 Goldens in `test/golden/phone_golden_test.dart`; Testdaten mit den Tablet-Goldens geteilt (`golden_harness.dart`).*
- [x] Alle Widget-Keys und UI-Texte bleiben erhalten; neue Texte sind deutsch
- [x] Auf keinem Screen tritt in Smartphone-Größe ein Layout-Overflow auf
- [x] Tippflächen sind mindestens 48 × 48 dp groß; der Inhalt respektiert Notch und Gestenleiste (`SafeArea`)
- [x] `flutter analyze` ist fehlerfrei, alle bestehenden Tests sind grün

---

### US-701 · Live-Erfassung auf dem Smartphone

**Als** Schiedsrichterbeobachter  
**möchte ich** Ereignisse auch auf dem Smartphone schnell erfassen können,  
**damit** ich ohne Tablet beobachten kann.

**Akzeptanzkriterien:**
- [x] Der Live-Screen ist auf dem Smartphone im Querformat fixiert
- [x] Das Spielfeld nimmt den größten Teil des Bildschirms ein
- [x] Eine kompakte Kopfzeile zeigt Heim-/Gastteam (gekürzt), Spielstand, Spielphase und Uhr; die „+ Tor"-Buttons je Team bleiben erreichbar
- [x] Phasen-Button, „Aufstellung" und „Szenen" sind als Aktionsleiste mit dem Daumen erreichbar; „Aufstellung" und „Szenen" erscheinen nur als Icon (mit Tooltip)
  *Umsetzung: Phasen-Buttons in einer linken Leiste, Icons in einer rechten Leiste; bei genug Höhe steht eine kurze Beschriftung (12 pt) unter dem Icon, sonst nur Icon + Tooltip.*
- [x] Ein Tap aufs Spielfeld öffnet das Erfassungsformular im Vollbild bzw. als großes Sheet; Speichern und Abbrechen verhalten sich wie bisher
- [x] Ein Ereignis lässt sich weiterhin in unter 10 Sekunden erfassen
- [x] „Letzte Ereignisse" ist über einen Button erreichbar und öffnet sich als Sheet; Löschen funktioniert wie bisher (US-213)
- [x] Tor-Dialog und Aufstellungs-Dialog passen auf den Bildschirm und sind bedienbar
- [x] Die Android-Zurück-Taste bzw. -Geste verlässt den Live-Screen nicht unbeabsichtigt: ist ein Formular oder Sheet offen, schließt sie dieses; sonst fragt die App nach, bevor sie zur Spielliste zurückgeht
- [x] Nach dem Verlassen des Live-Screens gilt wieder die Ausrichtung des jeweiligen Screens

---

### US-702 · Display bleibt während des Spiels an

**Als** Schiedsrichterbeobachter  
**möchte ich**, dass das Display des Smartphones während des Spiels nicht ausgeht, ich das aber bei Bedarf abschalten kann,  
**damit** ich nicht vor jeder Erfassung entsperren muss, aber Akku sparen kann, wenn ich will.

**Akzeptanzkriterien:**
- [x] Auf Android bleibt das Display an, solange der Live-Screen offen ist (Standard: an)
  *Umsetzung: `FLAG_KEEP_SCREEN_ON` über einen eigenen Methodenkanal in `MainActivity` — kein zusätzliches Paket, keine Auswirkung auf den Windows-Build.*
- [x] Im Live-Screen gibt es einen Schalter (Icon-Button mit klar erkennbarem Zustand an/aus), mit dem ich das während des Spiels ein- und ausschalten kann
- [x] Nach dem Verlassen des Live-Screens geht das Display wieder normal aus
- [x] Die Einstellung gilt für die laufende Sitzung im Live-Screen; beim nächsten Öffnen ist sie wieder an
- [x] Unter Windows ändert sich nichts: kein Schalter, keine Wirkung

---

### US-703 · Spielliste, Spiel-Setup und Aufstellung auf dem Smartphone

**Als** Schiedsrichterbeobachter  
**möchte ich** Spiele auf dem Smartphone anlegen, importieren, fortsetzen und löschen können,  
**damit** ich die App vollständig ohne Tablet nutzen kann.

**Akzeptanzkriterien:**
- [x] Spielliste, Spiel-Setup und Nachbereitung laufen im Hochformat
- [x] Die Spielliste ist einspaltig; Badge „Läuft", Fortsetzen (US-109) und Löschen funktionieren wie bisher
- [x] Im Spiel-Setup stehen Spieldaten und Aufstellungen untereinander; die Bildschirmtastatur verdeckt kein aktives Eingabefeld
- [x] Der CSV-Import (US-105) öffnet die Android-Dateiauswahl und importiert wie unter Windows
  *Geprüft am 2026-10-26 auf einem Pixel 8 Pro (TC-7046).*
- [x] Dialoge passen ihre Breite dem Bildschirm an (kein horizontales Abschneiden)

---

### US-704 · Nachbereitung und Statistik auf dem Smartphone

**Als** Schiedsrichterbeobachter  
**möchte ich** Szenen, Coaching-Notizen und Statistik auch auf dem Smartphone ansehen und bearbeiten,  
**damit** ich direkt nach dem Spiel nachbereiten kann.

**Akzeptanzkriterien:**
- [x] Die Tabs Szenen, Coaching und Statistik bleiben
- [x] Die Filterleiste der Szenenliste ist horizontal scrollbar; Filter funktionieren wie bisher (US-302)
- [x] Szene bearbeiten (US-209) öffnet das Formular im Vollbild statt als Dialog
  *Zusätzlich: Typ, Entscheidung, Bewertung und Notiz einer Szene stehen untereinander, damit nichts abgeschnitten wird.*
- [x] Die Statistik-Karten (Heatmap, Zeitachse, Ranking, Tore, Vergehen pro Team) stehen untereinander und sind scrollbar

---

### US-705 · Android-App-Grundlagen

**Als** Schiedsrichterbeobachter  
**möchte ich** die App wie eine normale Android-App installieren und starten,  
**damit** ich sie auf dem Homescreen finde und Updates ohne Datenverlust einspielen kann.

**Akzeptanzkriterien:**
- [x] Die App heißt auf dem Homescreen „Beobachter" und hat ein eigenes App-Icon
  *Am 2026-10-29 auf einem Pixel 8 Pro bestätigt (TC-7061).*
- [ ] Die App benötigt keine Netzwerk- oder Speicher-Berechtigung (Offline-Betrieb, CSV über die Systemdateiauswahl)
  *Offen: Das App-Manifest fordert keine Berechtigung an. Ob Plugins (z. B. `file_picker`) beim Zusammenführen eine hinzufügen, prüft TC-7061 an der gebauten APK. Dafür listet der Schritt „Check permissions“ im Android-Workflow die Berechtigungen bei jedem Build auf.*
- [x] Die APK ist mit einem festen Release-Schlüssel signiert, sodass eine neue Version über die alte installiert werden kann und die lokalen Spieldaten erhalten bleiben
  *Umsetzung: Signierung über `android/key.properties`, in der CI aus GitHub-Secrets erzeugt. Der Schlüssel selbst muss einmalig angelegt werden (README).*
  *Am 2026-10-29 auf einem Pixel 8 Pro geprüft: Das Update über die alte Version funktioniert ohne Datenverlust (TC-7062, TC-7074).*
  *Hinweis: Ein Play Store ist dafür nicht nötig. Der Schlüssel wird einmalig selbst erzeugt und als GitHub-Secret hinterlegt. Ohne festen Schlüssel signiert jeder CI-Lauf mit einem anderen Debug-Schlüssel — dann muss die App vor jedem Update deinstalliert werden, und die Spieldaten gehen verloren.*
- [x] Nach Hintergrund oder Neustart durch Android läuft die Spieluhr korrekt weiter (US-501, zeitstempelbasiert)
  *Am 2026-10-29 auf einem Pixel 8 Pro geprüft (TC-7063).*

---

### US-706 · Getrennte Builds für Windows und Android

**Als** Entwickler  
**möchte ich** Windows- und Android-Build getrennt voneinander auslösen können,  
**damit** ich die jeweilige Plattform unabhängig bauen und verteilen kann.

**Akzeptanzkriterien:**
- [x] Es gibt zwei getrennte Workflows: `build-windows.yml` (bestehend) und `build-android.yml` (neu)
- [x] Beide laufen bei jedem Push auf `main` und lassen sich zusätzlich einzeln manuell starten (`workflow_dispatch`)
- [x] Beide laufen außerdem bei jedem Pull Request gegen `main`, damit ein PR vor dem Merge für beide Plattformen gebaut und getestet ist
  *Ergänzt am 2026-10-26 (TC-7077).*
- [x] Ein Fehler in einem Workflow beeinflusst den anderen nicht
- [x] Der Android-Workflow führt `flutter analyze` und `flutter test` aus und baut anschließend `flutter build apk --release` mit Flutter 3.47.7
  *Hinweis: Lokal ist kein Android-SDK installiert; der erste echte APK-Build läuft in der CI (TC-7073).*
- [x] Die APK steht als Artefakt `beobachter-app-android` 30 Tage zum Download bereit
- [x] Der Release-Schlüssel kommt aus GitHub-Secrets; fehlen sie, baut der Workflow trotzdem (mit Debug-Signatur) und weist im Log darauf hin
- [x] Wie der Schlüssel erzeugt und als Secret hinterlegt wird, ist in der README beschrieben
