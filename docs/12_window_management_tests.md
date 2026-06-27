# Testfälle — US-107: Fenstergröße fixiert auf Gerätauflösung

> Plattform-Fokus: Windows (Surface). iOS/Android verhalten sich nativ wie erwartet.
> Testgerät: Microsoft Surface (Windows 11) im Querformat.

---

## TC-1201 · App startet maximiert (Windows)

**Vorbedingung:** App war geschlossen; kein gespeicherter Fensterzustand  
**Aktion:** App per Doppelklick / Taskleiste starten  
**Erwartetes Ergebnis:** Das App-Fenster öffnet sich sofort in voller Bildschirmgröße (maximiert), ohne dass der Nutzer etwas tut  
**Kriterium:** AK1

---

## TC-1202 · Resize-Handle links deaktiviert (Windows)

**Vorbedingung:** App läuft maximiert  
**Aktion:** Mauszeiger an den linken Fensterrand bewegen  
**Erwartetes Ergebnis:** Kein Resize-Cursor (↔) erscheint; Ziehen am Rand verändert die Fenstergröße nicht  
**Kriterium:** AK2

---

## TC-1203 · Resize-Handle rechts deaktiviert (Windows)

**Vorbedingung:** App läuft maximiert  
**Aktion:** Mauszeiger an den rechten Fensterrand bewegen  
**Erwartetes Ergebnis:** Kein Resize-Cursor (↔) erscheint; Ziehen am Rand verändert die Fenstergröße nicht  
**Kriterium:** AK2

---

## TC-1204 · Resize-Handle unten deaktiviert (Windows)

**Vorbedingung:** App läuft maximiert  
**Aktion:** Mauszeiger an den unteren Fensterrand bewegen  
**Erwartetes Ergebnis:** Kein Resize-Cursor (↕) erscheint; Ziehen am Rand verändert die Fenstergröße nicht  
**Kriterium:** AK2

---

## TC-1205 · Resize-Handle Ecken deaktiviert (Windows)

**Vorbedingung:** App läuft maximiert  
**Aktion:** Mauszeiger an alle vier Fensterecken nacheinander bewegen  
**Erwartetes Ergebnis:** Kein diagonaler Resize-Cursor (↗↙ / ↖↘) erscheint; Ziehen an Ecken verändert die Fenstergröße nicht  
**Kriterium:** AK2

---

## TC-1206 · Minimieren möglich (Windows)

**Vorbedingung:** App läuft maximiert  
**Aktion:** Tap/Klick auf den Minimieren-Button in der Titelleiste  
**Erwartetes Ergebnis:** App verschwindet in die Taskleiste; andere Fenster werden sichtbar  
**Kriterium:** AK3

---

## TC-1207 · Wiederherstellen nach Minimieren nimmt volle Fenstergröße ein (Windows)

**Vorbedingung:** App wurde minimiert (TC-1206)  
**Aktion:** Tap auf App-Icon in der Taskleiste  
**Erwartetes Ergebnis:** App kehrt in maximiertem Zustand zurück — keine verkleinerte Darstellung  
**Kriterium:** AK4

---

## TC-1208 · iOS — natives Vollbild unverändert

**Vorbedingung:** App auf iPad (iOS) installiert und gestartet  
**Aktion:** App starten, Gerät drehen (Quer/Hoch)  
**Erwartetes Ergebnis:** App verhält sich wie bisher — volles Bildschirm-Layout, kein Regressionsverhalten durch window_manager-Paket  
**Kriterium:** AK5

---

## TC-1209 · Android — natives Vollbild unverändert

**Vorbedingung:** App auf Android-Tablet installiert und gestartet  
**Aktion:** App starten  
**Erwartetes Ergebnis:** App verhält sich wie bisher — volles Bildschirm-Layout, kein Regressionsverhalten durch window_manager-Paket  
**Kriterium:** AK5

---

## TC-1210 · Kein Nutzer-Eingriff beim Start erforderlich (Windows)

**Vorbedingung:** App war geschlossen  
**Aktion:** App starten und direkt mit der Bedienung beginnen  
**Erwartetes Ergebnis:** Der maximierte Zustand ist sofort beim ersten Frame aktiv — kein Flackern, kein sichtbares Vergrößern nach dem Start  
**Kriterium:** AK6

---

## Testfall-Übersicht — US-107 (Windows)

| TC | Beschreibung | AK | Plattform | Status |
|----|-------------|----|-----------| -------|
| TC-1201 | App startet maximiert | AK1 | Windows | ⬜ offen |
| TC-1202 | Resize links deaktiviert | AK2 | Windows | ⬜ offen |
| TC-1203 | Resize rechts deaktiviert | AK2 | Windows | ⬜ offen |
| TC-1204 | Resize unten deaktiviert | AK2 | Windows | ⬜ offen |
| TC-1205 | Resize Ecken deaktiviert | AK2 | Windows | ⬜ offen |
| TC-1206 | Minimieren möglich | AK3 | Windows | ⬜ offen |
| TC-1207 | Wiederherstellen = maximiert | AK4 | Windows | ⬜ offen |
| TC-1208 | iOS Regression | AK5 | iOS | ⬜ offen |
| TC-1209 | Android Regression | AK5 | Android | ⬜ offen |
| TC-1210 | Kein Flackern beim Start | AK6 | Windows | ⬜ offen |

---

## US-108 — macOS Fensterverwaltung

## TC-1211 · App startet maximiert (macOS)

**Vorbedingung:** App war geschlossen; kein gespeicherter Fensterzustand  
**Aktion:** App starten  
**Erwartetes Ergebnis:** Das App-Fenster öffnet sich sofort in voller Bildschirmgröße (maximiert), ohne Nutzereingriff  
**Kriterium:** AK1

---

## TC-1212 · Resize-Handles deaktiviert (macOS)

**Vorbedingung:** App läuft maximiert  
**Aktion:** Mauszeiger an alle Fensterränder und -ecken bewegen, Ziehversuch  
**Erwartetes Ergebnis:** Kein Resize-Cursor erscheint; Fenstergröße bleibt unverändert  
**Kriterium:** AK2

---

## TC-1213 · Minimieren in Dock möglich (macOS)

**Vorbedingung:** App läuft maximiert  
**Aktion:** Klick auf den gelben Minimieren-Button in der Titelleiste  
**Erwartetes Ergebnis:** App verschwindet ins Dock; andere Fenster werden sichtbar  
**Kriterium:** AK3

---

## TC-1214 · Wiederherstellen aus Dock nimmt volle Fenstergröße ein (macOS)

**Vorbedingung:** App wurde minimiert (TC-1213)  
**Aktion:** Klick auf App-Icon im Dock  
**Erwartetes Ergebnis:** App kehrt maximiert zurück — keine verkleinerte Darstellung  
**Kriterium:** AK4

---

## TC-1215 · Windows-Regression nach macOS-Änderung

**Vorbedingung:** App auf Windows-Gerät installiert  
**Aktion:** App starten, Resize-Versuch, Minimieren  
**Erwartetes Ergebnis:** Verhalten identisch zu vor der Änderung (TC-1201 bis TC-1207 weiterhin erfüllt)  
**Kriterium:** AK5

---

## TC-1216 · Kein Flackern beim Start (macOS)

**Vorbedingung:** App war geschlossen  
**Aktion:** App starten  
**Erwartetes Ergebnis:** Fenster erscheint direkt maximiert — kein sichtbares Vergrößern oder Flackern  
**Kriterium:** AK6

---

## Testfall-Übersicht — US-108 (macOS)

| TC | Beschreibung | AK | Plattform | Status |
|----|-------------|----|-----------| -------|
| TC-1211 | App startet maximiert | AK1 | macOS | ⬜ offen |
| TC-1212 | Resize-Handles deaktiviert | AK2 | macOS | ⬜ offen |
| TC-1213 | Minimieren in Dock möglich | AK3 | macOS | ⬜ offen |
| TC-1214 | Wiederherstellen aus Dock = maximiert | AK4 | macOS | ⬜ offen |
| TC-1215 | Windows-Regression | AK5 | Windows | ⬜ offen |
| TC-1216 | Kein Flackern beim Start | AK6 | macOS | ⬜ offen |
