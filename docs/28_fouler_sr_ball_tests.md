# Testfälle — Nur Fouler erfassen (US-216) · SR-Ball (US-217)

---

## US-216 — Nur den Fouler erfassen

### TC-216-01: Formular zeigt nur die Fouler-Zeile

**Vorbedingung:** Live-Screen, Ereignisformular geöffnet, Ereignistyp „Fußfoul".

**Aktion:** Abschnitt „Spieler" ansehen.

**Erwartetes Ergebnis:** Es gibt genau eine Zeile „Fouler" mit Team-Umschalter und Rückennummer. Eine Zeile „Gefoulter" und deren Widgets (`fouled_*`) existieren nicht.

---

### TC-216-02: Fouler wird wie bisher gespeichert

**Aktion:** Fouler Team „Heim", Nummer 7 wählen, Entscheidung „Freistoß", Speichern.

**Erwartetes Ergebnis:** Zum Ereignis ist genau ein `EventPlayer` gespeichert: Rolle `fouler`, Team Heim, Nummer 7. Es gibt keinen Eintrag mit Rolle `fouled`.

---

### TC-216-03: Fouler nur mit Team, ohne Nummer

**Aktion:** Fouler Team „Gast" ohne Rückennummer wählen, Speichern.

**Erwartetes Ergebnis:** Ein `EventPlayer` mit Rolle `fouler`, Team Gast, Nummer `null` (US-404 unverändert).

---

### TC-216-04: Ereignis ohne Spielerangabe

**Aktion:** Nur Ereignistyp und Entscheidung wählen, Speichern.

**Erwartetes Ergebnis:** Das Ereignis wird gespeichert, ohne `EventPlayer`.

---

### TC-216-05: Bearbeiten eines Altereignisses mit Gefoultem

**Vorbedingung:** Gespeichertes Ereignis mit Fouler (Heim #4) und Gefoultem (Gast #10).

**Aktion:** Ereignis zum Bearbeiten öffnen (US-209).

**Erwartetes Ergebnis:** Die Fouler-Zeile ist mit Heim #4 vorausgefüllt. Eine Gefoulten-Zeile wird nicht angezeigt.

---

### TC-216-06: Gefoulter bleibt beim erneuten Speichern erhalten

**Vorbedingung:** wie TC-216-05.

**Aktion:** Fouler auf Heim #6 ändern, „Änderungen speichern".

**Erwartetes Ergebnis:** Gespeichert sind Fouler Heim #6 und unverändert Gefoulter Gast #10.

---

### TC-216-07: Fouler entfernen bei Altereignis

**Vorbedingung:** wie TC-216-05.

**Aktion:** Fouler-Team abwählen, speichern.

**Erwartetes Ergebnis:** Kein Fouler mehr gespeichert; der Gefoulte Gast #10 bleibt erhalten.

---

### TC-216-08: Auswertungen unverändert

**Vorbedingung:** Spiel mit Altereignissen inkl. Gefoulten.

**Aktion:** „Vergehen pro Team" (US-404) und Spieler-Ranking berechnen.

**Erwartetes Ergebnis:** Beide zählen nur Fouler; die Werte sind identisch zu vorher (bestehende Tests aus `team_vergehen_test.dart` und `tor_erfassung_test.dart` bleiben grün).

---

### TC-216-09: Smartphone-Formular

**Vorbedingung:** Smartphone-Größe (Querformat, z. B. 844 × 390 dp).

**Aktion:** Ereignisformular öffnen.

**Erwartetes Ergebnis:** Nur die Fouler-Zeile, kein Overflow.

---

## US-217 — SR-Ball als Spielfortsetzung

### TC-217-01: Enum und Bezeichnung

**Aktion:** `RefDecision.droppedBall.label` lesen.

**Erwartetes Ergebnis:** `SR-Ball`. Der Wert steht in `RefDecision.values` direkt nach `throwIn` und vor `goal`.

---

### TC-217-02: Kachel im Entscheidungs-Grid

**Aktion:** Ereignisformular öffnen.

**Erwartetes Ergebnis:** Die Kachel „SR-Ball" (`decision_droppedBall`) ist sichtbar und folgt direkt auf „Einwurf". Insgesamt gibt es 12 wählbare Entscheidungen; „Tor" bleibt ausgeblendet.

---

### TC-217-03: Auswählen und Abwählen

**Aktion:** „SR-Ball" tippen, dann erneut tippen.

**Erwartetes Ergebnis:** Erster Tap: Kachel ausgewählt, eine zuvor gewählte andere Entscheidung ist abgewählt. Zweiter Tap: keine Entscheidung gewählt.

---

### TC-217-04: Speichern und Laden

**Aktion:** Ereignis mit Entscheidung „SR-Ball" speichern und über das Repository neu laden.

**Erwartetes Ergebnis:** `refDecision == RefDecision.droppedBall`. In der Datenbank steht der Text `droppedBall`.

---

### TC-217-05: Vorauswahl beim Bearbeiten

**Vorbedingung:** Ereignis mit „SR-Ball" gespeichert.

**Aktion:** Ereignis zum Bearbeiten öffnen.

**Erwartetes Ergebnis:** Die Kachel „SR-Ball" ist ausgewählt.

---

### TC-217-06: Anzeige in der Nachbereitung

**Vorbedingung:** Abgeschlossenes Spiel mit einer Szene „SR-Ball".

**Aktion:** Szenenliste öffnen.

**Erwartetes Ergebnis:** Die Szene zeigt die Entscheidung „SR-Ball".

---

### TC-217-07: Grid-Layout ohne Überlauf

**Aktion:** Ereignisformular auf Tablet (1280 × 800, Panel 40 %), Smartphone (844 × 390) und schmalem Panel rendern.

**Erwartetes Ergebnis:** Kein Overflow; die Spaltenzahl ergibt sich aus der Breite (≤ 6). Die Goldens `live_form` (Panel, 5 Spalten) und `review_edit` (Dialog, 6 Spalten) zeigen nur die Fouler-Zeile und die Kachel „SR-Ball".

---

### TC-217-08: Kein Schemawechsel

**Aktion:** `AppDatabase.schemaVersion` prüfen.

**Erwartetes Ergebnis:** Weiterhin 8. Bestehende Ereignisse mit allen bisherigen Entscheidungen laden unverändert.

---

## Manuelle Prüfung (Gerät)

### TC-216/217-M1: Erfassung im laufenden Spiel

**Aktion:** Auf Tablet und Android-Smartphone ein Foul mit Fouler und „SR-Ball" erfassen, App neu starten, Ereignis öffnen.

**Erwartetes Ergebnis:** Nur Fouler-Zeile sichtbar; „SR-Ball" vorausgewählt; Kacheln vollständig lesbar.

---

## Ergebnis (2026-10-30)

| TC | Status | Umsetzung |
|---|---|---|
| 216-01 – 216-04 | ✅ | `test/fouler_sr_ball_test.dart` (Widget-Tests mit echter In-Memory-DB und Golden-Testdaten) |
| 216-05 – 216-07 | ✅ | `test/fouler_sr_ball_test.dart` — Altereignis mit Gefoultem im Edit-Modus; Gefoulter bleibt erhalten |
| 216-08 | ✅ | Unit-Test `TeamFouls.fromEvents` in `test/fouler_sr_ball_test.dart`; bestehende Tests in `team_vergehen_test.dart` und `tor_erfassung_test.dart` unverändert grün |
| 216-09 | ✅ | TC-217-07 „Smartphone quer" (844 × 390) ohne Overflow; `phone_live_form` unverändert (zeigt das Formular vor der Typwahl) |
| 217-01 – 217-06 | ✅ | `test/fouler_sr_ball_test.dart` |
| 217-07 | ✅ | Layout-Tests bei 512, 300 und 844 dp Breite; Goldens `live_form` und `review_edit` neu erzeugt |
| 217-08 | ✅ | Schema bleibt v8; Text `droppedBall` direkt in der Tabelle `events` geprüft |
| M1 | offen | Manuelle Prüfung auf Tablet und Android-Smartphone |

`flutter analyze` ohne Befund; `flutter test`: 335 Tests grün (davon 17 Golden).
