# Testfälle — Coaching-Notizen (US-306 / US-307)

---

## US-307 · Allgemeine Coaching-Notiz

### TC-3071: Allgemeines Notizfeld immer sichtbar

**Vorbedingung:** Coaching-Tab offen, keine Szenen für Coaching markiert.

**Erwartetes Ergebnis:**
- Abschnitt „Allgemeine Notiz" mit leerem Textfeld und Platzhalter ist sichtbar
- Hinweistext „Noch keine Szenen für das Coaching markiert." erscheint darunter

---

### TC-3072: Allgemeine Notiz erfassen und autosave

**Schritte:** Allgemeines Notizfeld antippen → Text eingeben → Anderes Element antippen (FocusLoss).

**Erwartetes Ergebnis:**
- Text wird gespeichert (in `games.coaching_note`)
- Nach App-Neustart / Tab-Wechsel: Text ist wieder vorhanden

---

### TC-3073: Allgemeine Notiz löschen

**Vorbedingung:** Allgemeine Notiz enthält Text.

**Schritte:** Textfeld leeren → FocusLoss.

**Erwartetes Ergebnis:** `games.coaching_note` wird auf `null` gesetzt (nicht leerer String).

---

### TC-3074: Allgemeine Notiz vorausgefüllt bei erneutem Öffnen

**Vorbedingung:** Allgemeine Notiz gespeichert.

**Schritte:** Coaching-Tab verlassen → zurückkehren.

**Erwartetes Ergebnis:** Notiz ist vorausgefüllt (aus DB geladen).

---

### TC-3075: DB-Migration — coaching_note Spalte vorhanden

**Erwartetes Ergebnis:** Schema-Version 4 enthält Spalte `coaching_note` in Tabelle `games` (nullable Text).

---

## US-306 · Szenennotizen in der Coaching-Ansicht

### TC-3061: Szenennotiz wird angezeigt (falls vorhanden)

**Vorbedingung:** Ereignis mit `coachingFlag = true` und `sceneNote = "Klare Fehlentscheidung"`.

**Erwartetes Ergebnis:**
- In der Coaching-Ansicht ist unter der Ereignis-Headerzeile „📋 Klare Fehlentscheidung" sichtbar
- Text ist nicht editierbar (read-only)

---

### TC-3062: Szenennotiz nicht angezeigt wenn null

**Vorbedingung:** Ereignis mit `coachingFlag = true`, `sceneNote = null`.

**Erwartetes Ergebnis:** Kein 📋-Bereich sichtbar für dieses Ereignis.

---

### TC-3063: Coaching-Notiz inline editierbar

**Vorbedingung:** Coaching-Tab offen, mindestens eine markierte Szene.

**Schritte:** Coaching-Notizfeld einer Szene antippen → Text eingeben → FocusLoss.

**Erwartetes Ergebnis:**
- Text gespeichert in `events.coaching_note` für dieses Event
- Kein Dialog, kein extra Speichern-Button erforderlich

---

### TC-3064: Coaching-Notiz vorausgefüllt

**Vorbedingung:** Ereignis mit `coachingNote = "Gute Reaktion"` und `coachingFlag = true`.

**Erwartetes Ergebnis:** Coaching-Notizfeld zeigt „Gute Reaktion" beim Öffnen.

---

### TC-3065: Coaching-Notiz löschen

**Vorbedingung:** Coaching-Notiz vorhanden.

**Schritte:** Feld leeren → FocusLoss.

**Erwartetes Ergebnis:** `events.coaching_note` wird `null`.

---

### TC-3066: Coaching-Flag Toggle in Coaching-Ansicht

**Vorbedingung:** Ereignis mit `coachingFlag = true` in Coaching-Ansicht sichtbar.

**Schritte:** ⭐ antippen.

**Erwartetes Ergebnis:**
- Ereignis verschwindet aus der Coaching-Ansicht
- `coachingFlag = false` in DB

---

### TC-3067: Szenennotiz und Coaching-Notiz visuell unterschieden

**Erwartetes Ergebnis:**
- Szenennotiz: grauer Text mit 📋-Icon (read-only-Stil)
- Coaching-Notiz: editierbares TextField mit Platzhaltertext „Coaching-Notiz …"
- Kein visuelles Verwechslungsrisiko

---

### TC-3068: Coaching-Ansicht zeigt alle markierten Szenen mit Notizfeldern

**Vorbedingung:** 3 Ereignisse mit `coachingFlag = true`, davon 2 mit `sceneNote`.

**Erwartetes Ergebnis:**
- Alle 3 Ereignisse erscheinen chronologisch
- 2 zeigen Szenennotiz, alle 3 haben ein Coaching-Notizfeld
- Allgemeine Notiz steht oben
