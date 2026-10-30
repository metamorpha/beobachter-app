# Testfälle — Vollständige Szeneninfos in Szenenliste und Coaching-Ansicht (US-308)

Testspiel: Heim „SV Musterstadt" (Trikot Rot), Gast „FC Beispiel" (ohne Trikotfarbe → Standard-Gastfarbe).

---

## Szenenliste

### TC-308-01: Fouler mit Rückennummer

**Vorbedingung:** Szene „Fußfoul", Fouler Heim #7, Fortsetzung „Freistoß".

**Aktion:** Nachbereitung → Tab „Szenen".

**Erwartetes Ergebnis:** Die Szenenkarte zeigt „SV Musterstadt #7" mit Punkt in Trikotfarbe Rot.

---

### TC-308-02: Fouler ohne Rückennummer

**Vorbedingung:** Szene mit Fouler Gast ohne Nummer.

**Erwartetes Ergebnis:** Die Karte zeigt „FC Beispiel" (ohne „#") mit Punkt in Gastfarbe.

---

### TC-308-03: Szene ohne Spieler

**Vorbedingung:** Szene ohne `EventPlayer`, Fortsetzung „Einwurf".

**Erwartetes Ergebnis:** Keine Fouler-Angabe, kein verwaister Trenner; „Fortsetzung: Einwurf" ist sichtbar.

---

### TC-308-04: Fortsetzung mit Präfix

**Vorbedingung:** Szene mit Fortsetzung „SR-Ball".

**Erwartetes Ergebnis:** Karte zeigt „Fortsetzung: SR-Ball".

---

### TC-308-05: Szene ohne Fortsetzung und ohne Spieler

**Vorbedingung:** Szene nur mit Ereignistyp.

**Erwartetes Ergebnis:** Die Infozeile entfällt vollständig; die Karte zeigt nur Typ (und ggf. Bewertung/Notiz).

---

### TC-308-06: Eigener Ereignistyp

**Vorbedingung:** Szene Typ `custom`, Bezeichnung „Zeitspiel".

**Erwartetes Ergebnis:** Karte, Detail-Sheet und Coaching-Eintrag zeigen „Zeitspiel" statt „Sonstiges".

---

### TC-308-07: Teamname leer

**Vorbedingung:** Spiel ohne Heim-Teamname, Fouler Heim #5.

**Erwartetes Ergebnis:** Anzeige „Heim #5".

---

### TC-308-08: Aktualisierung nach Bearbeiten

**Aktion:** Szene über ✎ bearbeiten, Fouler von Heim #7 auf Gast #9 ändern, speichern.

**Erwartetes Ergebnis:** Die Szenenkarte zeigt sofort „FC Beispiel #9".

---

### TC-308-09: Smartphone-Layout

**Vorbedingung:** Smartphone (kürzere Seite < 600 dp), Szene mit langem Teamnamen, Fouler und Fortsetzung.

**Erwartetes Ergebnis:** Fouler und Fortsetzung stehen in eigenen Zeilen; kein Overflow-Fehler.

---

## Detail-Sheet

### TC-308-10: Alle Infos sichtbar

**Vorbedingung:** Szene 23:45, 1. Halbzeit, „Fußfoul", Fouler Heim #7, Fortsetzung „Freistoß", Karte Gelb, Bewertung „Korrekt · Trivial", Szenennotiz „Zu spät gepfiffen".

**Aktion:** Tap auf Szenenkarte.

**Erwartetes Ergebnis:** Sheet zeigt Überschrift „23:45 — Fußfoul", „1. Halbzeit", Zeilen Fouler · Fortsetzung · Karte (Gelb) · Bewertung · Szenennotiz, darunter das Coaching-Notiz-Feld.

---

### TC-308-11: Leere Felder entfallen

**Vorbedingung:** Szene nur mit Typ.

**Erwartetes Ergebnis:** Keine Zeilen „Fouler", „Fortsetzung", „Karte", „Bewertung", „Szenennotiz".

---

### TC-308-12: Altdaten mit Gefoultem

**Vorbedingung:** Szene mit `EventPlayer` Rolle `fouler` (Heim #7) und Rolle `fouled` (Gast #4).

**Erwartetes Ergebnis:** Detail-Sheet zeigt „Fouler: SV Musterstadt #7" und „Gefoult: FC Beispiel #4". Die Szenenkarte zeigt nur den Fouler.

---

### TC-308-13: Coaching-Notiz weiterhin speicherbar

**Aktion:** Im Sheet Coaching-Notiz eingeben, „Speichern".

**Erwartetes Ergebnis:** Notiz gespeichert, Coaching-Flag gesetzt (Verhalten wie bisher).

---

## Coaching-Ansicht

### TC-308-14: Fouler und Fortsetzung im Coaching-Eintrag

**Vorbedingung:** Markierte Szene mit Fouler Heim #7, Fortsetzung „Freistoß", Karte Gelb, Bewertung.

**Aktion:** Tab „Coaching".

**Erwartetes Ergebnis:** Kopfzeile „Fußfoul · Gelb · <Bewertung>"; darunter „SV Musterstadt #7" und „Fortsetzung: Freistoß"; Szenennotiz und Coaching-Notizfeld wie bisher.

---

### TC-308-15: Coaching-Eintrag ohne Spieler/Fortsetzung

**Vorbedingung:** Markierte Szene nur mit Typ.

**Erwartetes Ergebnis:** Keine Infozeile, Coaching-Notizfeld vorhanden.

---

### TC-308-16: Spieler werden einmal pro Spiel geladen

**Vorbedingung:** Spiel mit 10 Szenen.

**Erwartetes Ergebnis:** `getPlayersForGame` wird beim Öffnen der Nachbereitung einmal aufgerufen, nicht pro Szene (Fake-Repository zählt Aufrufe).
