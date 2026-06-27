# Testfälle: Spiel löschen (US-DEL)

Referenz-UX: `docs/04_ux_design.md` (Flow 4)

---

## TC-DEL-01 — Löschen-Icon in jeder Kachel sichtbar

**Vorbedingung:** Mindestens ein Spiel in der Übersicht.  
**Aktion:** Spielübersicht öffnen.  
**Erwartung:** Jede Spielkachel zeigt ein 🗑-Icon rechts neben dem Chevron (›). Das Icon ist immer sichtbar, ohne Swipe-Geste.

---

## TC-DEL-02 — Tap auf 🗑 öffnet Bestätigungs-Dialog

**Vorbedingung:** Spiel „DJK TuS Hordel – SC Westfalia Herne" ist in der Liste.  
**Aktion:** 🗑-Icon dieser Kachel tippen.  
**Erwartung:** Ein AlertDialog erscheint mit:
- Titel: „Spiel löschen?"
- Text enthält „DJK TuS Hordel – SC Westfalia Herne"
- Button „Abbrechen" und Button „Löschen" (rot)

---

## TC-DEL-03 — „Abbrechen" schließt Dialog ohne Änderung

**Vorbedingung:** Bestätigungs-Dialog ist geöffnet.  
**Aktion:** „Abbrechen" tippen.  
**Erwartung:** Dialog schließt sich. Das Spiel ist weiterhin in der Liste vorhanden.

---

## TC-DEL-04 — „Löschen" entfernt Kachel aus der Übersicht

**Vorbedingung:** Bestätigungs-Dialog ist geöffnet.  
**Aktion:** „Löschen" tippen.  
**Erwartung:** Dialog schließt sich. Die Kachel des gelöschten Spiels ist nicht mehr in der Liste sichtbar. Andere Spiele bleiben unberührt.

---

## TC-DEL-05 — Cascade: Ereignisse werden mitgelöscht

**Vorbedingung:** Spiel mit mindestens 3 erfassten Ereignissen.  
**Aktion:** Spiel über Dialog löschen.  
**Erwartung:** Nach dem Löschen existieren keine Ereignisse zu diesem Spiel mehr in der Datenbank (überprüfbar durch erneutes Anlegen eines Spiels mit gleicher ID — nicht möglich — oder Widget-Test gegen AppDatabase).

---

## TC-DEL-06 — Cascade: Aufstellungen werden mitgelöscht

**Vorbedingung:** Spiel mit importierten Aufstellungen (Heim + Gast, je 20 Spieler).  
**Aktion:** Spiel über Dialog löschen.  
**Erwartung:** Alle Squad-Einträge dieses Spiels sind gelöscht. Keine verwaisten Datenbankzeilen.

---

## TC-DEL-07 — Cascade: Timer-State wird mitgelöscht

**Vorbedingung:** Spiel, dessen Spieluhr mindestens einmal gestartet wurde.  
**Aktion:** Spiel über Dialog löschen.  
**Erwartung:** Der zugehörige TimerState ist gelöscht. Keine verwaisten Datenbankzeilen.

---

## TC-DEL-08 — Letztes Spiel löschen → Leer-Hinweis erscheint

**Vorbedingung:** Genau ein Spiel in der Übersicht.  
**Aktion:** Dieses Spiel löschen (Bestätigung: „Löschen").  
**Erwartung:** Die Liste ist leer; der Hinweistext „Noch keine Spiele erfasst." wird angezeigt. Der FAB „+ Neues Spiel" bleibt sichtbar.

---

## TC-DEL-09 — Dialog zeigt „Unbenanntes Spiel" bei fehlendem Teamnamen

**Vorbedingung:** Spiel ohne Teamnamen (beide Felder leer) ist in der Liste.  
**Aktion:** 🗑-Icon dieser Kachel tippen.  
**Erwartung:** Dialog-Text enthält „Unbenanntes Spiel" (nicht zwei leere Bindestriche oder nur „–").

---

## TC-DEL-10 — Spiel mit 0 Ereignissen kann gelöscht werden

**Vorbedingung:** Neues Spiel ohne erfasste Ereignisse.  
**Aktion:** Spiel löschen.  
**Erwartung:** Löschen funktioniert fehlerfrei; kein Absturz oder Fehler-Toast.

---

## TC-DEL-11 — Tap auf Kachel-Text/Chevron öffnet das Spiel (kein versehentliches Löschen)

**Vorbedingung:** Mindestens ein Spiel in der Liste.  
**Aktion:** Auf den Spielnamen oder den Chevron (›) tippen (nicht auf das 🗑-Icon).  
**Erwartung:** Navigation zum Setup-Screen. Kein Bestätigungs-Dialog erscheint.

---

## TC-DEL-12 — 🗑-Icon löst keine Navigation aus

**Vorbedingung:** Mindestens ein Spiel in der Liste.  
**Aktion:** 🗑-Icon tippen, dann im Dialog „Abbrechen" wählen.  
**Erwartung:** Es findet keine Navigation zum Setup-Screen statt. Man bleibt in der Spielübersicht.

---

## TC-DEL-13 — Mehrere Spiele: nur das gewählte wird gelöscht

**Vorbedingung:** Drei Spiele A, B, C in der Liste.  
**Aktion:** Spiel B löschen (Bestätigung: „Löschen").  
**Erwartung:** Spiele A und C sind weiterhin in der Liste. Reihenfolge und Inhalte unverändert.
