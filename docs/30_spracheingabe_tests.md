# Testfälle — Notiz per Sprache diktieren (US-218)

Automatisierte Tests verwenden eine `FakeSpeechInput` (Provider-Override von `speechInputProvider`), die Erkennungsergebnisse, Status und Fehler gezielt auslöst. Manuelle Tests (M) laufen auf echten Geräten.

---

## Bedienung

### TC-218-01: Mikrofon in allen Notizfeldern

**Aktion:** Ereignisformular → „Notiz" aufklappen; Szenen-Detail öffnen; Coaching-Ansicht öffnen.

**Erwartetes Ergebnis:** In Szenennotiz, Coaching-Notiz (Detail-Sheet), Coaching-Notiz je Szene und Allgemeiner Notiz steht rechts im Feld ein Mikrofon-Symbol (Tooltip „Diktieren").

---

### TC-218-02: Aufnahme starten

**Aktion:** Tap auf 🎤.

**Erwartetes Ergebnis:** Die Aufnahme startet (Deutsch); das Symbol wechselt auf „hört zu" (Tooltip „Aufnahme beenden").

---

### TC-218-03: Live-Vorschau

**Aktion:** Während der Aufnahme liefert die Erkennung Zwischenergebnisse „Hand", dann „Hand am Trikot".

**Erwartetes Ergebnis:** Das Feld zeigt jeweils den aktuellen Zwischenstand; „Hand" steht nicht doppelt im Feld.

---

### TC-218-04: Anhängen an vorhandenen Text

**Vorbedingung:** Feld enthält „Vorteil zu spät".

**Aktion:** Diktat „Hand am Trikot".

**Erwartetes Ergebnis:** Feld enthält „Vorteil zu spät Hand am Trikot"; Cursor am Ende.

---

### TC-218-05: Leeres Feld

**Aktion:** Diktat „Hand am Trikot" in leeres Feld.

**Erwartetes Ergebnis:** Feld enthält genau „Hand am Trikot" (kein führendes Leerzeichen).

---

### TC-218-06: Vorhandener Text endet mit Leerzeichen

**Vorbedingung:** Feld enthält „Vorteil ".

**Erwartetes Ergebnis:** Nach Diktat „zu spät" steht „Vorteil zu spät" (kein doppeltes Leerzeichen).

---

### TC-218-07: Aufnahme per zweitem Tap beenden

**Aktion:** Aufnahme läuft → Tap auf 🎤.

**Erwartetes Ergebnis:** Erkennung wird gestoppt, Symbol zurück auf „bereit"; erkannter Text bleibt im Feld.

---

### TC-218-08: Automatisches Ende nach Sprechpause

**Aktion:** Die Erkennung meldet Status „fertig" (Pause).

**Erwartetes Ergebnis:** Symbol zurück auf „bereit", Text bleibt.

---

### TC-218-09: Danach normal editierbar

**Aktion:** Nach dem Diktat per Tastatur Text ergänzen und speichern.

**Erwartetes Ergebnis:** Gespeicherte Notiz enthält diktierten und getippten Text.

---

### TC-218-10: Szenennotiz wird mit dem Ereignis gespeichert

**Aktion:** Ereignistyp + Entscheidung wählen, Notiz diktieren, „Speichern".

**Erwartetes Ergebnis:** `sceneNote` des gespeicherten Ereignisses entspricht dem diktierten Text.

---

### TC-218-11: Coaching-Notiz je Szene wird automatisch gespeichert

**Aktion:** Coaching-Ansicht → Diktat in die Coaching-Notiz einer Szene, Aufnahme endet.

**Erwartetes Ergebnis:** `updateCoachingNote` wird mit dem diktierten Text aufgerufen, ohne dass das Feld verlassen werden muss.

---

### TC-218-12: Allgemeine Notiz wird automatisch gespeichert

**Aktion:** Coaching-Ansicht → Diktat in „Allgemeine Notiz", Aufnahme endet.

**Erwartetes Ergebnis:** Die allgemeine Coaching-Notiz des Spiels ist gespeichert.

---

### TC-218-13: Formular schließen beendet Aufnahme

**Aktion:** Aufnahme läuft → Formular abbrechen bzw. Dialog schließen.

**Erwartetes Ergebnis:** Die Erkennung wird gestoppt; kein Fehler, keine weitere Textänderung.

---

### TC-218-14: Nur eine Aufnahme gleichzeitig

**Aktion:** Aufnahme in Feld A läuft → Tap auf 🎤 in Feld B.

**Erwartetes Ergebnis:** Aufnahme in A endet, B nimmt auf; neuer Text landet nur in B.

---

### TC-218-15: Spieluhr läuft weiter (M)

**Aktion:** Live-Screen, Uhr läuft → Ereignis erfassen und Notiz 20 s diktieren.

**Erwartetes Ergebnis:** Die Spieluhr zeigt danach 20 s mehr; Ereigniszeit ist die des Feldtipps.

---

### TC-218-23: Getippter Text bleibt, Tastatur schließt beim Start

**Vorbedingung:** Text „Eröffnung“ per Tastatur getippt, das Feld hat noch den Fokus und die Tastatur ist offen.

**Aktion:** Tap auf 🎤, „Guten Abend“ diktieren.

**Erwartetes Ergebnis:** Die Tastatur schließt sich beim Start und das Feld verliert den Fokus. Das Feld enthält „Eröffnung Guten Abend“, auch nachdem die Aufnahme geendet hat. Die Tastatur darf das Diktat nicht mit ihrem alten Textstand überschreiben.

---

### TC-218-24: Leeres Ergebnis löscht nichts

**Aktion:** Die Erkennung liefert „Guten Abend“ und danach ein leeres Ergebnis.

**Erwartetes Ergebnis:** Das Feld enthält weiterhin „Eröffnung Guten Abend“.

---

### TC-218-25: Coaching-Ansicht: getippter und diktierter Text

**Aktion:** In der Coaching-Ansicht „Eröffnung:“ in die Allgemeine Notiz tippen, dann „Guten Abend“ diktieren, bis die Aufnahme endet.

**Erwartetes Ergebnis:** Das Feld zeigt „Eröffnung: Guten Abend“, und genau dieser Text wird gespeichert.

---

## Fehler & Verfügbarkeit

### TC-218-16: Keine Spracherkennung vorhanden

**Vorbedingung:** Initialisierung der Spracherkennung schlägt fehl.

**Erwartetes Ergebnis:** Kein Mikrofon-Symbol; Feld per Tastatur nutzbar.

---

### TC-218-17: Mikrofon verweigert

**Aktion:** Tap auf 🎤, Freigabe wird verweigert (Fehler `permission`).

**Erwartetes Ergebnis:** SnackBar „Mikrofon nicht freigegeben"; Symbol bleibt „bereit".

---

### TC-218-18: Keine Verbindung / kein Sprachpaket

**Aktion:** Erkennung meldet Netzwerk- bzw. Sprachpaket-Fehler.

**Erwartetes Ergebnis:** SnackBar „Spracherkennung nicht verfügbar – Internet oder Offline-Sprachpaket Deutsch erforderlich"; Aufnahme beendet, bisheriger Text unverändert.

---

### TC-218-19: Nichts erkannt

**Aktion:** Erkennung meldet „no match".

**Erwartetes Ergebnis:** SnackBar „Nichts erkannt – bitte noch einmal versuchen".

---

## Geräte (manuell)

### TC-218-20: Android offline (M)

**Vorbedingung:** Offline-Sprachpaket Deutsch installiert, Flugmodus.

**Erwartetes Ergebnis:** Diktat funktioniert. Ohne Sprachpaket erscheint der Hinweis aus TC-218-18.

---

### TC-218-21: iOS (M)

**Erwartetes Ergebnis:** Beim ersten Tap fragt iOS nach Mikrofon- und Spracherkennungs-Freigabe (deutsche Texte); danach funktioniert das Diktat, im Flugmodus auf dem Gerät (iOS 13+).

---

### TC-218-22: Windows / Surface (M)

**Erwartetes Ergebnis:** Mit aktivierter Windows-Spracherkennung funktioniert das Diktat; ist sie nicht verfügbar, wird kein Mikrofon angezeigt (TC-218-16).
