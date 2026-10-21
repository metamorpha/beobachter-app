# Testfälle — Ereignisliste im Live-Seitenpanel (US-213)

---

## Länge der Liste

### TC-2131: Mehr als 5 Ereignisse auf hohem Bildschirm sichtbar

**Vorbedingung:** Spiel mit 20 Ereignissen, Bildschirm 1280 × 1000 (Querformat Tablet).

**Erwartetes Ergebnis:**
- Im Panel „Letzte Ereignisse" sind deutlich mehr als 5 Zeilen sichtbar
- Die Liste füllt die Panelhöhe bis zum unteren Rand

---

### TC-2132: Anzahl sichtbarer Zeilen wächst mit der Bildschirmhöhe

**Vorbedingung:** Spiel mit 30 Ereignissen.

**Schritte:** Live-Screen einmal mit 1280 × 600 und einmal mit 1280 × 1200 darstellen.

**Erwartetes Ergebnis:** Bei 1200 px Höhe sind mehr Zeilen sichtbar als bei 600 px.

---

### TC-2133: Liste scrollbar, Überschrift bleibt fix

**Vorbedingung:** Spiel mit 30 Ereignissen, Bildschirm 1280 × 600 (nicht alle passen).

**Schritte:** Liste nach oben wischen bis zum Ende.

**Erwartetes Ergebnis:**
- Das älteste Ereignis (erstes erfasstes) wird sichtbar
- Überschrift „Letzte Ereignisse" ist weiterhin sichtbar

---

### TC-2134: Neuestes Ereignis steht oben

**Vorbedingung:** Ereignisse bei 05:00 (Abseits), 10:00 (Handspiel), 15:00 (Fußvergehen) in dieser Reihenfolge erfasst.

**Erwartetes Ergebnis:** Reihenfolge im Panel von oben: 15:00 Fußvergehen, 10:00 Handspiel, 05:00 Abseits.

---

### TC-2135: Leere Liste

**Vorbedingung:** Spiel ohne Ereignisse.

**Erwartetes Ergebnis:** Überschrift „Letzte Ereignisse" und Trennlinie sichtbar, keine Zeilen, kein Layout-Fehler.

---

## Zeilengröße / Fehltipp-Schutz

### TC-2136: Mindesthöhe der Zeilen

**Vorbedingung:** Spiel mit mindestens 1 Ereignis.

**Erwartetes Ergebnis:**
- Jede Zeile ist mindestens 44 dp hoch
- Zeitstempel und Ereignistyp in Schriftgröße 14
- Zwischen zwei Zeilen ist eine dezente Trennlinie sichtbar

---

### TC-2137: Tippfläche des Lösch-Buttons

**Erwartetes Ergebnis:** Der Lösch-Button jeder Zeile hat eine Tippfläche von mindestens 44 × 44 dp; das Icon ist 22 dp groß.

---

### TC-2138: Lange Ereignistypen werden gekürzt

**Vorbedingung:** Ereignis vom Typ „Oberkörperverg." (längstes Label) mit Nachspielzeit-Zeitstempel (z. B. `45+02`), Panelbreite 200 dp.

**Erwartetes Ergebnis:** Text wird mit „…" gekürzt, kein Overflow-Fehler, Lösch-Button bleibt sichtbar.

---

## Bestehendes Verhalten

### TC-2139: Löschen aus der Liste

**Vorbedingung:** Spiel mit 3 Ereignissen.

**Schritte:** Lösch-Button des obersten Ereignisses antippen.

**Erwartetes Ergebnis:** Ereignis wird gelöscht (`deleteEvent` mit dessen ID), Liste zeigt sofort nur noch 2 Zeilen.

---

### TC-2140: Liste im abgeschlossenen Spiel sichtbar

**Vorbedingung:** Spiel im Status `abgeschlossen` mit Ereignissen.

**Erwartetes Ergebnis:** Panel „Letzte Ereignisse" mit allen Ereignissen ist sichtbar (vgl. TC-1510).
