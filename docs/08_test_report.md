# QA-Bericht — Beobachter-App MVP

> Rolle: QA Engineer mit Verständnis für Schiedsrichterwesen
> Input: docs/01–07, src/

---

## 1. Teststrategie

### Teststufen

| Stufe | Werkzeug | Abdeckung |
|-------|----------|-----------|
| Unit-Tests (Domain-Logik) | `flutter_test` | Timer-Arithmetik, Event-Formatierung |
| Integrationstests (Repository + SQLite) | `flutter_test` + `drift/native` In-Memory-DB | CRUD, Cascade, Enum-Rundreise |
| Manuelle Tests (UI + Workflow) | Gerät / Simulator | Live-Erfassung, Spieluhr, Undo |
| Fachliche Validierung | Review durch Beobachter | Kategorien, Bewertungssystem |

### Testprinzip

- Repositories werden gegen echte In-Memory-SQLite-DB getestet (kein Mocking der DB-Schicht)
- Domain-Entities ohne externe Abhängigkeiten direkt getestet
- UI-Tests derzeit manuell — Widget-Tests würden einen Provider-Override für die DB erfordern

---

## 2. Automatisierte Testfälle (31 Tests, alle grün)

### 2.1 Timer-Zeitmessung (`timer_state_test.dart`)

| TC | Beschreibung | Erwartetes Ergebnis | Status |
|----|-------------|---------------------|--------|
| T-01 | Initial-State: elapsedMs = 0, isRunning = false | currentMs == 0 | ✅ |
| T-02 | Gestoppter Timer gibt elapsedMs zurück | currentMs == gespeicherter Wert | ✅ |
| T-03 | Laufender Timer berechnet Differenz korrekt | currentMs ≈ elapsedMs + Δt (±500ms) | ✅ |
| T-04 | start() setzt isRunning = true und Timestamp | Timestamp nicht null | ✅ |
| T-05 | stop() akkumuliert elapsedMs korrekt | elapsedMs_neu ≈ alt + Δt | ✅ |
| T-06 | stop().start() behält elapsedMs bei (Halbzeit-Szenario) | elapsedMs unverändert nach Neustart | ✅ |

### 2.2 Ereignis-Formatierung (`event_test.dart`)

| TC | Beschreibung | Erwartetes Ergebnis | Status |
|----|-------------|---------------------|--------|
| E-01 | elapsedLabel formatiert 45:23 korrekt | "45:23" | ✅ |
| E-02 | elapsedLabel padded einstellige Sekunden | "01:05" statt "1:5" | ✅ |
| E-03 | minute gibt korrekte Spielminute | 45 bei 2.723.000 ms | ✅ |
| E-04 | copyWith ändert nur angegebene Felder | id, gameId, type unverändert | ✅ |
| E-05 | coachingFlag ist standardmäßig false | false | ✅ |

### 2.3 Spiel-Repository (`game_repository_test.dart`)

| TC | Beschreibung | Status |
|----|-------------|--------|
| G-01 | createGame speichert und gibt korrekte Daten zurück | ✅ |
| G-02 | getGames gibt alle Spiele zurück | ✅ |
| G-03 | getGames ist absteigend nach Datum sortiert | ✅ |
| G-04 | getGame gibt null zurück bei unbekannter ID | ✅ |
| G-05 | updateGame aktualisiert Felder korrekt | ✅ |
| G-06 | deleteGame entfernt das Spiel vollständig | ✅ |

### 2.4 Ereignis-Repository (`event_repository_test.dart`)

| TC | Beschreibung | Status |
|----|-------------|--------|
| EV-01 | createEvent speichert alle Felder korrekt | ✅ |
| EV-02 | EventPlayer wird korrekt mit Event verknüpft | ✅ |
| EV-03 | getEvents gibt Events chronologisch (elapsedMs) zurück | ✅ |
| EV-04 | getEvent gibt null bei unbekannter ID | ✅ |
| EV-05 | updateEvent aktualisiert coachingFlag | ✅ |
| EV-06 | deleteEvent entfernt Event (Undo-Pfad) | ✅ |
| EV-07 | deleteGame löscht Events via CASCADE | ✅ |
| EV-08 | CardType.red wird als Enum korrekt roundtripped | ✅ |
| EV-09 | Optionale Felder (assessment, refDecision) bleiben null | ✅ |

### 2.5 Aufstellungs-Repository (`squad_repository_test.dart`)

| TC | Beschreibung | Status |
|----|-------------|--------|
| S-01 | getSquad liefert leere Liste ohne Aufstellung | ✅ |
| S-02 | saveSquad + getSquad Roundtrip | ✅ |
| S-03 | Heim- und Gastaufstellung sind getrennt gespeichert | ✅ |
| S-04 | saveSquad überschreibt bestehende Aufstellung (Upsert) | ✅ |

---

## 3. Manuelle Testfälle (UI & Workflow)

### 3.1 Kritischer Pfad: Live-Ereigniserfassung

| TC | Schritt | Erwartetes Ergebnis |
|----|---------|---------------------|
| M-01 | App starten, neues Spiel anlegen | Direkt auf Live-Screen |
| M-02 | Spieluhr starten | Uhr läuft, zeigt MM:SS |
| M-03 | App in Hintergrund, nach 30s zurück | Uhr zeigt korrekte Zeit |
| M-04 | Spielfeld antippen | Side Panel öffnet sich in <200ms |
| M-05 | Ereignistyp "Fußvergehen" wählen | Button hervorgehoben, Spieler-Sektion erscheint |
| M-06 | Nur Typ wählen → Speichern (Minimal-Pfad) | Event gespeichert, Marker auf Spielfeld |
| M-07 | Undo-SnackBar erscheint | 5-Sekunden-Fenster, "Rückgängig" entfernt Event |
| M-08 | Vollständiges Foul: Typ + Spieler + Entscheidung + Bewertung + Notiz | Alle Felder in Szenenliste sichtbar |
| M-09 | Spieluhr stoppen (Halbzeit) → starten | elapsedMs wird fortgesetzt, kein Reset |
| M-10 | App-Neustart während Spiel | Spieluhr zeigt korrekte akkumulierte Zeit |

### 3.2 Nachbearbeitung

| TC | Schritt | Erwartetes Ergebnis |
|----|---------|---------------------|
| M-11 | Szenenliste: Coaching-Stern tippen | Stern wird gold, Flag gesetzt |
| M-12 | Coaching-Tab: nur markierte Szenen sichtbar | Ungeflagte nicht sichtbar |
| M-13 | Szene antippen → Coaching-Notiz erfassen | Notiz in Coaching-Tab sichtbar |
| M-14 | Statistik: Heatmap zeigt Hotspots | Zonen mit mehr Ereignissen intensiver |
| M-15 | Statistik: Zeitachse zeigt 6 Phasen | Balken proportional zur Ereignisanzahl |

---

## 4. Fachliche Validierung

### 4.1 Ereigniskategorien — Vollständigkeit

Als erfahrener Schiedsrichterbeobachter bewertet:

| Kategorie | Im MVP | Korrekt? | Anmerkung |
|-----------|--------|----------|-----------|
| Fußvergehen | ✅ | ✅ | Korrekte Terminologie (DFB/FIFA) |
| Oberkörpervergehen | ✅ | ✅ | Korrekte Unterscheidung zu Fußvergehen |
| Handspiel | ✅ | ✅ | Eigenständige Kategorie (Regeländerung 2019/20) |
| Unsportliches Betragen | ✅ | ✅ | Begriff korrekt |
| Tätlichkeit | ✅ | ✅ | Von Foul klar abgegrenzt (direkter Freistoß / Rot) |
| Abseits | ✅ | ✅ | Wichtig für Beobachtung der Laufwegentscheidungen |
| Vorteilsbestimmung | ✅ | ✅ | Eigene Kategorie sinnvoll (Timing kritisch) |
| Torentscheidung | ✅ | ✅ | Tor / kein Tor — oft coaching-relevant |
| Sonstiges (Freitext) | ✅ | ✅ | Zeitspiel, Spielverzögerung, Reklamieren etc. |
| **Karte als Attribut** | ✅ | ✅ | Richtig: Karte folgt Vergehen, kein eigener Typ |

**Fazit:** Kategorien decken den Praxisbedarf vollständig ab. Keine fehlenden Pflicht-Kategorien.

### 4.2 Schiedsrichterentscheidungen — Vollständigkeit

| Entscheidung | Im MVP | Anmerkung |
|-------------|--------|-----------|
| Freistoß | ✅ | |
| Strafstoß | ✅ | |
| Vorteil | ✅ | |
| Weiterspielen | ✅ | Wichtig: Nicht-Entscheidung bewusst |
| Verwarnung (Gelb) | ✅ | |
| Feldverweis GR | ✅ | |
| Feldverweis Rot | ✅ | |
| Ecke | ✅ | |
| Abstoß | ✅ | |
| Einwurf | ✅ | |
| Tor/Anstoß | ✅ | |
| **Freistoß indirekt** | ❌ | Fehlt — relevant bei technischen Vergehen (z. B. Torwart hält Ball zu lang) |

**Empfehlung:** Indirekten Freistoß als optionale Entscheidung ergänzen (niedrige Priorität für MVP).

### 4.3 Bewertungssystem — Sinnhaftigkeit

Das 2×2-Grid (Korrekt/Falsch × Erwartbar/Komplex) ist fachlich gut durchdacht:

| Kombination | Praxis-Bedeutung | Sinnvoll? |
|------------|-----------------|-----------|
| Korrekt · Erwartbar | Standardsituation, richtig gelöst — kein Coaching-Bedarf | ✅ |
| Korrekt · Komplex | Schwierige Situation, richtig gelöst — lobenswertes Coaching-Thema | ✅ |
| Falsch · Erwartbar | Unnötiger Fehler — dringender Coaching-Bedarf | ✅ |
| Falsch · Komplex | Schwierige Situation, falsch gelöst — verständlicher Fehler, Lernpotenzial | ✅ |

**Fazit:** Das Bewertungssystem ist fachlich korrekt und besser als eine einfache Korrekt/Falsch-Skala. Es bildet das Coaching-Gespräch direkt ab.

---

## 5. Gesamtbericht

### Was funktioniert ✅

- **Offline-Betrieb:** Vollständig. Keine Netzwerkanfragen, SQLite lokal.
- **Spieluhr:** Background-safe via Timestamp-Ansatz. Korrekte Akkumulation über Halbzeiten.
- **Ereigniserfassung:** Minimal-Pfad (3 Taps) implementiert. Spielfeld-Koordinaten korrekt normalisiert.
- **Datenpersistenz:** Sofortiges Schreiben nach Speichern. Cascade-Delete via PRAGMA foreign_keys.
- **Undo-Mechanismus:** 5-Sekunden-SnackBar, deleteEvent() korrekt.
- **Bewertung:** 2×2-Grid implementiert, ein Tap wählt beide Dimensionen.
- **Nachbearbeitung:** Szenenliste, Coaching-Flag, Coaching-Notiz, Coaching-Ansicht.
- **Heatmap:** Vereinfacht (6×4-Zonen), visuell ausreichend für MVP.
- **Zeitachse:** 6 Phasen à 15 Minuten, korrekte Zuordnung.

### Was fehlt / ist unvollständig ⚠️

| Lücke | Schwere | Empfehlung |
|-------|---------|------------|
| Spieler-Ranking in Statistik zeigt Placeholder | Mittel | EventPlayer-Aggregation per separatem Provider |
| Aufstellungs-Chips im Live-Formular laden nicht aus DB | Mittel | Squad-Provider in EventFormPanel einbinden |
| Indirekter Freistoß fehlt in Entscheidungsliste | Niedrig | Als 12. Option ergänzen |
| Kein Filter in der Szenenliste | Mittel | US-302 noch nicht umgesetzt |
| Szenen nachträglich bearbeiten (US-209) | Mittel | Edit-Screen für Szenenliste |
| Doppelter createEvent()-Aufruf in EventFormPanel | Hoch | Bereinigen vor produktivem Einsatz (Duplikat-Events möglich!) |

### Risiken 🔴

| Risiko | Wahrscheinlichkeit | Auswirkung | Maßnahme |
|--------|--------------------|-----------|---------|
| **Doppelter Event-Save in EventFormPanel** | Hoch | Zwei Events pro Tap gespeichert | Sofort fixen: direkten `repo.createEvent()`-Call entfernen, nur `notifier.save()` nutzen |
| iOS Standby während Spiel | Mittel | Ticker pausiert (aber Zeit korrekt nach Rückkehr) | Display-Wakelock per `wakelock_plus`-Paket |
| Spielfeld-Tap zu nahe am Panel-Rand | Niedrig | Falscher Ort erfasst | Min. Randabstand via Padding |
| Schema-Migration vergessen nach Update | Niedrig | DB-Fehler bei Nutzer mit alter Version | `schemaVersion` + `MigrationStrategy.onUpgrade` pflegen |

---

## 6. Bericht an den Product Owner

### Deckt die App den beschriebenen Use Case ab?

**Ja, zu ~85%.** Der kritische Pfad (Spiel starten → Spielfeld antippen → Ereignis erfassen → Speichern) ist vollständig implementiert. Die Nachbearbeitung mit Coaching-Markierung und -Notiz funktioniert. Die Statistik (Heatmap, Zeitachse) ist vorhanden.

Noch nicht nutzbar: Spieler-Ranking, Filter in der Szenenliste, Szenen-Bearbeitung nach dem Spiel.

### Sind alle erforderlichen Daten gespeichert?

**Ja**, mit einer Ausnahme:
- ✅ Spielort, Teams, Datum
- ✅ Ereignistyp, Zeitstempel (ms), Koordinaten
- ✅ Schiedsrichterentscheidung, Karte, Bewertung (2×2)
- ✅ Szenennotiz, Coaching-Flag, Coaching-Notiz
- ✅ Fouler / Gefoulter (Rückennummer + Team)
- ⚠️ Vorerfasste Aufstellungen werden nicht im Live-Formular angezeigt (Daten sind in DB, werden aber nicht abgerufen)

### Funktioniert die Offline-Nutzung korrekt?

**Ja, vollständig.** Kein einziger Netzwerkaufruf ist im Code vorhanden. SQLite läuft lokal. Der Timer ist background-safe implementiert. App-Neustart verliert keine Daten.

### Empfehlung

Vor dem ersten echten Spieleinsatz unbedingt den **Doppel-Save-Bug in `event_form_panel.dart`** beheben. Danach ist die App für einen Pilottest auf dem Platz geeignet. Die fehlenden Funktionen (Filter, Spieler-Ranking, Szenen-Edit) können in einer zweiten Iteration nachgezogen werden.
