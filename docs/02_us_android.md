# User Stories — Epic 7: Android-Smartphone

> Fokus: Die App lässt sich neben dem Windows-Tablet (Surface) auch auf einem Android-Smartphone bedienen.
> Gerät: Android-Smartphone. Live-Erfassung im **Querformat**, Spielliste, Spiel-Setup und Nachbereitung im **Hochformat**.
> Verteilung: APK zum direkten Installieren (kein Play Store).
> Rahmen: Geschäftslogik und die Windows-Oberfläche bleiben unverändert.

**Gilt für alle Stories dieses Epics:**
- [ ] Unter `domain/`, `data/` und `core/` sowie in `providers.dart` ändert sich keine Zeile
- [ ] Das Smartphone-Layout wird über die Bildschirmgröße gewählt (`shortestSide < 600` dp), nicht über die Plattform. Darüber (Windows-Surface, Android-Tablets) gilt das bestehende Layout unverändert
- [ ] Die bestehenden Golden-Tests (1280 × 800) bleiben ohne neue Referenzbilder grün
- [ ] Neue Golden-Tests decken die Smartphone-Layouts ab (Hochformat 390 × 844, Querformat 844 × 390)
- [ ] Alle Widget-Keys und UI-Texte bleiben erhalten; neue Texte sind deutsch
- [ ] Auf keinem Screen tritt in Smartphone-Größe ein Layout-Overflow auf
- [ ] Tippflächen sind mindestens 48 × 48 dp groß; der Inhalt respektiert Notch und Gestenleiste (`SafeArea`)
- [ ] `flutter analyze` ist fehlerfrei, alle bestehenden Tests sind grün

---

### US-701 · Live-Erfassung auf dem Smartphone

**Als** Schiedsrichterbeobachter  
**möchte ich** Ereignisse auch auf dem Smartphone schnell erfassen können,  
**damit** ich ohne Tablet beobachten kann.

**Akzeptanzkriterien:**
- [ ] Der Live-Screen ist auf dem Smartphone im Querformat fixiert
- [ ] Das Spielfeld nimmt den größten Teil des Bildschirms ein
- [ ] Eine kompakte Kopfzeile zeigt Heim-/Gastteam (gekürzt), Spielstand, Spielphase und Uhr; die „+ Tor"-Buttons je Team bleiben erreichbar
- [ ] Phasen-Button, „Aufstellung" und „Szenen" sind als Aktionsleiste mit dem Daumen erreichbar; „Aufstellung" und „Szenen" erscheinen nur als Icon (mit Tooltip)
- [ ] Ein Tap aufs Spielfeld öffnet das Erfassungsformular im Vollbild bzw. als großes Sheet; Speichern und Abbrechen verhalten sich wie bisher
- [ ] Ein Ereignis lässt sich weiterhin in unter 10 Sekunden erfassen
- [ ] „Letzte Ereignisse" ist über einen Button erreichbar und öffnet sich als Sheet; Löschen funktioniert wie bisher (US-213)
- [ ] Tor-Dialog und Aufstellungs-Dialog passen auf den Bildschirm und sind bedienbar
- [ ] Die Android-Zurück-Taste bzw. -Geste verlässt den Live-Screen nicht unbeabsichtigt: ist ein Formular oder Sheet offen, schließt sie dieses; sonst fragt die App nach, bevor sie zur Spielliste zurückgeht
- [ ] Nach dem Verlassen des Live-Screens gilt wieder die Ausrichtung des jeweiligen Screens

---

### US-702 · Display bleibt während des Spiels an

**Als** Schiedsrichterbeobachter  
**möchte ich**, dass das Display des Smartphones während des Spiels nicht ausgeht, ich das aber bei Bedarf abschalten kann,  
**damit** ich nicht vor jeder Erfassung entsperren muss, aber Akku sparen kann, wenn ich will.

**Akzeptanzkriterien:**
- [ ] Auf Android bleibt das Display an, solange der Live-Screen offen ist (Standard: an)
- [ ] Im Live-Screen gibt es einen Schalter (Icon-Button mit klar erkennbarem Zustand an/aus), mit dem ich das während des Spiels ein- und ausschalten kann
- [ ] Nach dem Verlassen des Live-Screens geht das Display wieder normal aus
- [ ] Die Einstellung gilt für die laufende Sitzung im Live-Screen; beim nächsten Öffnen ist sie wieder an
- [ ] Unter Windows ändert sich nichts: kein Schalter, keine Wirkung

---

### US-703 · Spielliste, Spiel-Setup und Aufstellung auf dem Smartphone

**Als** Schiedsrichterbeobachter  
**möchte ich** Spiele auf dem Smartphone anlegen, importieren, fortsetzen und löschen können,  
**damit** ich die App vollständig ohne Tablet nutzen kann.

**Akzeptanzkriterien:**
- [ ] Spielliste, Spiel-Setup und Nachbereitung laufen im Hochformat
- [ ] Die Spielliste ist einspaltig; Badge „Läuft", Fortsetzen (US-109) und Löschen funktionieren wie bisher
- [ ] Im Spiel-Setup stehen Spieldaten und Aufstellungen untereinander; die Bildschirmtastatur verdeckt kein aktives Eingabefeld
- [ ] Der CSV-Import (US-105) öffnet die Android-Dateiauswahl und importiert wie unter Windows
- [ ] Dialoge passen ihre Breite dem Bildschirm an (kein horizontales Abschneiden)

---

### US-704 · Nachbereitung und Statistik auf dem Smartphone

**Als** Schiedsrichterbeobachter  
**möchte ich** Szenen, Coaching-Notizen und Statistik auch auf dem Smartphone ansehen und bearbeiten,  
**damit** ich direkt nach dem Spiel nachbereiten kann.

**Akzeptanzkriterien:**
- [ ] Die Tabs Szenen, Coaching und Statistik bleiben
- [ ] Die Filterleiste der Szenenliste ist horizontal scrollbar; Filter funktionieren wie bisher (US-302)
- [ ] Szene bearbeiten (US-209) öffnet das Formular im Vollbild statt als Dialog
- [ ] Die Statistik-Karten (Heatmap, Zeitachse, Ranking, Tore, Vergehen pro Team) stehen untereinander und sind scrollbar

---

### US-705 · Android-App-Grundlagen

**Als** Schiedsrichterbeobachter  
**möchte ich** die App wie eine normale Android-App installieren und starten,  
**damit** ich sie auf dem Homescreen finde und Updates ohne Datenverlust einspielen kann.

**Akzeptanzkriterien:**
- [ ] Die App heißt auf dem Homescreen „Beobachter" und hat ein eigenes App-Icon
- [ ] Die App benötigt keine Netzwerk- oder Speicher-Berechtigung (Offline-Betrieb, CSV über die Systemdateiauswahl)
- [ ] Die APK ist mit einem festen Release-Schlüssel signiert, sodass eine neue Version über die alte installiert werden kann und die lokalen Spieldaten erhalten bleiben
  *Hinweis: Ein Play Store ist dafür nicht nötig. Der Schlüssel wird einmalig selbst erzeugt und als GitHub-Secret hinterlegt. Ohne festen Schlüssel signiert jeder CI-Lauf mit einem anderen Debug-Schlüssel — dann muss die App vor jedem Update deinstalliert werden, und die Spieldaten gehen verloren.*
- [ ] Nach Hintergrund oder Neustart durch Android läuft die Spieluhr korrekt weiter (US-501, zeitstempelbasiert)

---

### US-706 · Getrennte Builds für Windows und Android

**Als** Entwickler  
**möchte ich** Windows- und Android-Build getrennt voneinander auslösen können,  
**damit** ich die jeweilige Plattform unabhängig bauen und verteilen kann.

**Akzeptanzkriterien:**
- [ ] Es gibt zwei getrennte Workflows: `build-windows.yml` (bestehend) und `build-android.yml` (neu)
- [ ] Beide laufen bei jedem Push auf `main` und lassen sich zusätzlich einzeln manuell starten (`workflow_dispatch`)
- [ ] Ein Fehler in einem Workflow beeinflusst den anderen nicht
- [ ] Der Android-Workflow führt `flutter analyze` und `flutter test` aus und baut anschließend `flutter build apk --release` mit Flutter 3.47.7
- [ ] Die APK steht als Artefakt `beobachter-app-android` 30 Tage zum Download bereit
- [ ] Der Release-Schlüssel kommt aus GitHub-Secrets; fehlen sie, baut der Workflow trotzdem (mit Debug-Signatur) und weist im Log darauf hin
- [ ] Wie der Schlüssel erzeugt und als Secret hinterlegt wird, ist in der README beschrieben
