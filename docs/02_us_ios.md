# User Stories — Epic 8: iOS (iPhone & iPad)

> Fokus: Die App läuft als native App auf iPhone und iPad.
> Verteilung: TestFlight an einen kleinen Kreis (< 100 Personen), kein öffentlicher App Store.
> Rahmen: Geschäftslogik, Datenmodell und die Oberflächen für Android und Windows bleiben unverändert.

> **Stand der Prüfung (2026-11-24):** Abgehakt ist, was im Code umgesetzt und automatisch getestet ist (`test/android_smartphone_test.dart`, Gruppe „US-803–805 · iOS“). Offen sind die Punkte, die nur die CI, App Store Connect oder ein echtes Gerät bestätigen können (`31_ios_tests.md`, Fälle mit (M)). Lokal fehlt die iOS-Plattform in Xcode, deshalb wird iOS erst in der CI gebaut.

**Gilt für alle Stories dieses Epics:**
- [x] Unter `domain/`, `data/` und `core/` sowie in `providers.dart` ändert sich keine Zeile
- [x] Das Layout wird wie bisher über die Bildschirmgröße gewählt (`FormFactor.isPhone`, kürzere Seite < 600 dp), nicht über die Plattform: iPhone → Smartphone-Layout, iPad → Tablet-Layout
- [x] Bestehende Tests und Goldens bleiben ohne neue Referenzbilder grün
- [x] Die Builds für Android und Windows ändern sich nicht
  *Hinweis: Im Live-Screen sehr schmaler Smartphones (iPhone SE quer) zeigen die Tor-Buttons „+“ statt „+ Tor“ (US-804). Das gilt nach Größe, also auch für entsprechend kleine Android-Geräte. Bei 844 × 390 und auf Tablets ändert sich nichts.*
- [x] `flutter analyze` ist fehlerfrei, alle Tests sind grün

---

### US-801 · iOS-Build in der CI

**Als** Entwickler  
**möchte ich**, dass GitHub Actions die iOS-App automatisch baut,  
**damit** ich ohne eigenen Build-Rechner neue Versionen erzeuge und Fehler früh sehe.

**Akzeptanzkriterien:**
- [x] Ein eigener Workflow `build-ios.yml` läuft auf einem macOS-Runner mit derselben Flutter-Version wie die anderen Workflows
- [x] Er führt `flutter analyze` und `flutter test` aus
- [ ] Bei Pull Requests und Pushes auf `main` baut er die App ohne Signierung (reine Kompilierprüfung, keine Secrets nötig)
- [ ] Manuell (`workflow_dispatch`) und bei Tags `v*` baut er eine signierte `.ipa` und legt sie als Artifact ab
- [x] Fehlen die Signier-Secrets, gibt es eine verständliche Warnung, und der Lauf baut unsigniert statt abzubrechen (wie bei Android)
- [x] Die Build-Nummer steigt mit jedem Lauf automatisch; die Versionsnummer kommt aus `pubspec.yaml`
- [x] Die README beschreibt, welche Secrets anzulegen sind und woher sie kommen

---

### US-802 · Verteilung über TestFlight

**Als** Schiedsrichterbeobachter mit iPhone oder iPad  
**möchte ich** die App über einen Einladungslink installieren und automatisch aktualisiert bekommen,  
**damit** ich ohne App Store und ohne Mac an neue Versionen komme.

**Akzeptanzkriterien:**
- [ ] Ein signierter CI-Lauf lädt den Build automatisch zu TestFlight hoch
- [x] Die App erscheint als „Beobachter“ mit dem bestehenden App-Icon
- [ ] Kollegen installieren die App über die App „TestFlight“ und einen öffentlichen Einladungslink
- [ ] Ein Update über TestFlight behält alle lokalen Spieldaten
- [x] Beim Hochladen fragt Apple nicht jedes Mal nach Exportbeschränkungen für Verschlüsselung
- [x] Die README beschreibt die einmaligen Schritte bei Apple: Developer Program, App in App Store Connect, Zertifikat, Profil, API-Key, Testgruppe mit Link. Sie weist darauf hin, dass TestFlight-Builds nach 90 Tagen ablaufen

---

### US-803 · Display bleibt während des Spiels an (iOS)

**Als** Schiedsrichterbeobachter  
**möchte ich**, dass das Display auch auf iPhone und iPad während des Spiels nicht ausgeht, ich das aber abschalten kann,  
**damit** ich nicht vor jeder Erfassung entsperren muss.

> Überträgt US-702 auf iOS.

**Akzeptanzkriterien:**
- [ ] Auf iPhone und iPad bleibt das Display an, solange der Live-Screen offen ist (Standard: an)
- [x] Der Schalter im Live-Screen aus US-702 erscheint auch unter iOS und schaltet das ein und aus
- [x] Nach dem Verlassen des Live-Screens geht das Display wieder normal aus
- [x] Kein zusätzliches Paket; gleicher Methodenkanal wie unter Android
- [x] Unter Windows ändert sich nichts

---

### US-804 · Live-Screen quer auf dem iPhone

**Als** Schiedsrichterbeobachter mit iPhone  
**möchte ich** den Live-Screen im Querformat und alle anderen Screens im Hochformat,  
**damit** die Bedienung genauso ist wie auf dem Android-Smartphone.

> Überträgt die Ausrichtung aus US-701/US-703 auf das iPhone.

**Akzeptanzkriterien:**
- [x] Auf dem iPhone ist der Live-Screen quer fixiert, Spielliste, Spiel-Setup und Nachbereitung sind hochkant
- [x] Nach dem Verlassen des Live-Screens gilt wieder Hochformat
- [x] Auf dem iPad bleibt die Ausrichtung frei (wie auf Tablets unter Android)

---

### US-805 · iPad

**Als** Schiedsrichterbeobachter mit iPad  
**möchte ich** die App im Tablet-Layout nutzen,  
**damit** ich die gleiche Oberfläche habe wie auf dem Surface.

**Akzeptanzkriterien:**
- [x] Alle Screens nutzen auf dem iPad das Tablet-Layout, hoch und quer, ohne Layout-Overflow
- [ ] Notch, Home-Indikator und Statusleiste verdecken keine Bedienelemente
- [ ] Spracheingabe (US-218), CSV-Import (US-105) und Offline-Betrieb funktionieren wie auf den anderen Plattformen
- [ ] Nach Hintergrund oder Neustart läuft die Spieluhr korrekt weiter (US-501)
