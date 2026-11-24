# Testfälle — iOS: iPhone & iPad (US-801–805)

Automatisierte Tests stehen in `test/android_smartphone_test.dart`, Gruppe „US-803–805 · iOS“. Die Plattform wird dort über `isMobileProvider` gesetzt. Manuelle Tests (M) laufen auf echten Geräten mit einem TestFlight-Build.

---

## US-801 · iOS-Build in der CI

### TC-801-01: Unsignierter Build bei Pull Requests

**Aktion:** Pull Request gegen `main` öffnen.

**Erwartetes Ergebnis:** Der Workflow „Build iOS“ läuft auf macOS: analyze, test und `flutter build ios --no-codesign` sind grün. Es werden keine Secrets gebraucht, und es gibt kein Artefakt.

---

### TC-801-02: Ohne Secrets

**Aktion:** „Run workflow“, Secrets nicht angelegt.

**Erwartetes Ergebnis:** Warnung „Keine iOS-Signatur“. Der Lauf baut unsigniert und ist grün.

---

### TC-801-03: Signierter Build (M)

**Vorbedingung:** Die Secrets für Zertifikat, Profil und Team-ID sind angelegt.

**Aktion:** „Run workflow“ oder Tag `v1.0.0` pushen.

**Erwartetes Ergebnis:** Artefakt `beobachter-app-ios` mit `.ipa`. Die Build-Nummer ist die Laufnummer, die Version kommt aus `pubspec.yaml`.

---

## US-802 · TestFlight

### TC-802-01: Upload (M)

**Vorbedingung:** Die Secrets für den API-Key sind zusätzlich angelegt.

**Erwartetes Ergebnis:** Der Schritt „Upload to TestFlight“ ist grün. Der Build erscheint nach der Verarbeitung in App Store Connect unter TestFlight, ohne Frage nach Exportbeschränkungen.

---

### TC-802-02: Installation über Einladungslink (M)

**Aktion:** Öffentlichen Link auf einem iPhone öffnen und über die App „TestFlight“ installieren.

**Erwartetes Ergebnis:** Die App heißt auf dem Home-Bildschirm „Beobachter“ und zeigt das Ball-Icon auf Grün.

---

### TC-802-03: Update behält Daten (M)

**Aktion:** Spiel mit Ereignissen anlegen, dann neuen Build über TestFlight installieren.

**Erwartetes Ergebnis:** Spiel und Ereignisse sind unverändert vorhanden.

---

## US-803 · Display bleibt an

### TC-803-01: Gleicher Kanal wie unter Android

**Erwartetes Ergebnis:** `MethodChannelScreenWakeLock` ruft auf `de.beobachter/screen` die Methode `setKeepScreenOn` mit `true` bzw. `false` auf. `AppDelegate.swift` bedient genau diesen Aufruf.

---

### TC-803-02: Display bleibt an (M)

**Aktion:** Live-Screen öffnen und das Gerät 5 Minuten nicht berühren (automatische Sperre: 30 s).

**Erwartetes Ergebnis:** Das Display bleibt an. Nach Tippen auf den Display-Schalter oder nach Verlassen des Live-Screens geht es wieder nach 30 s aus.

---

## US-804 · Live-Screen quer auf dem iPhone

### TC-804-01: Ausrichtung

**Aktion:** iPhone SE (375 × 667): Spielliste, dann Live-Screen öffnen und zurück.

**Erwartetes Ergebnis:** Die Spielliste ist hochkant, der Live-Screen quer, nach dem Zurückgehen wieder hochkant. Es gibt keinen Overflow.

---

### TC-804-02: Kleinstes iPhone quer, alle Spielphasen

**Aktion:** Live-Screen mit langen Teamnamen bei 667 × 375 in jeder Spielphase.

**Erwartetes Ergebnis:** Kein Overflow. Die Tor-Buttons zeigen „+“, und die Teamnamen fallen weg, wenn der Platz nicht reicht. Die Display-Sperre ist aktiv.

---

### TC-804-03: Gerät mit Notch (M)

**Aktion:** iPhone mit Notch oder Dynamic Island quer halten, in beide Richtungen.

**Erwartetes Ergebnis:** Notch und Home-Indikator verdecken weder Kopfzeile noch Seitenleisten.

---

## US-805 · iPad

### TC-805-01: Live-Screen hoch und quer

**Aktion:** iPad (820 × 1180 und 1180 × 820) mit einem Ereignis.

**Erwartetes Ergebnis:** Tablet-Layout ohne Overflow. Der Display-Schalter steht in der Aktionsleiste, die Display-Sperre ist beim Öffnen an und beim Verlassen aus. Es gibt keine Ausrichtungs-Vorgabe.

---

### TC-805-02: Übrige Screens hoch und quer

**Erwartetes Ergebnis:** Spielliste, Spiel-Setup und alle Tabs der Nachbereitung haben auf dem iPad keinen Overflow und keine Ausrichtungs-Vorgabe.

---

### TC-805-03: Funktionen auf dem Gerät (M)

**Aktion:** Im Flugmodus ein Spiel per CSV importieren (Dateien-App) und Ereignisse erfassen. Eine Notiz diktieren. Die App beenden und neu starten.

**Erwartetes Ergebnis:**
- Der Import funktioniert.
- Das Diktat funktioniert: Beim ersten Mal erscheinen die deutschen Freigabe-Dialoge, und ohne Netz läuft die Erkennung auf dem Gerät.
- Nach dem Neustart sind die Daten da, und die Spieluhr läuft korrekt weiter.
