# Testfälle — Vergehen pro Team und Halbzeit (US-404)

---

## Zählregel (Unit)

### TC-4041: Kategorien werden korrekt zugeordnet

**Vorbedingung:** 1. HZ, Täter Heim: je ein Fußvergehen, Oberkörpervergehen, Handspiel, Unsportlichkeit, Tätlichkeit, Sonstiges.

**Erwartetes Ergebnis:** 1. HZ Heim: Fuß 1, Oberkörper 1, Andere 4, Summe 6. Alle Gast-Werte 0.

---

### TC-4042: Abseits, Vorteil und Torentscheidung zählen nicht

**Vorbedingung:** Je ein Ereignis `offside`, `advantage`, `goalDecision`, jeweils mit Täter Heim.

**Erwartetes Ergebnis:** Alle Werte 0.

---

### TC-4043: Team-Zuordnung über den Täter

**Vorbedingung:** Fußvergehen mit Täter Gast und Gefoultem Heim.

**Erwartetes Ergebnis:** Gast Fuß 1, Heim Fuß 0.

---

### TC-4044: Ereignis ohne Täter-Team zählt nicht

**Vorbedingung:** Fußvergehen nur mit Gefoultem (Heim), ohne Täter.

**Erwartetes Ergebnis:** Alle Werte 0.

---

### TC-4045: Nachspielzeit zählt zur jeweiligen Halbzeit

**Vorbedingung:** Fußvergehen Heim in `ersteHalbzeitNachspielzeit`, Oberkörpervergehen Gast in `zweiteHalbzeitNachspielzeit`.

**Erwartetes Ergebnis:** 1. HZ Heim Fuß 1; 2. HZ Gast Oberkörper 1.

---

### TC-4046: Verlängerung wird separat gezählt

**Vorbedingung:** Fußvergehen Heim in `verlaengerungErsteHalbzeit`, Fußvergehen Gast in `verlaengerungZweiteHalbzeitNachspielzeit`.

**Erwartetes Ergebnis:** Verl. Heim Fuß 1, Verl. Gast Fuß 1; 1. und 2. HZ unverändert 0; `hasExtraTime` = true.

---

## Statistik-Tab (Widget)

### TC-4047: Tabelle ohne Verlängerung

**Vorbedingung:** Spiel mit Vergehen nur in der regulären Spielzeit.

**Erwartetes Ergebnis:** Überschrift „Vergehen pro Team", Spaltengruppen „1. HZ" und „2. HZ", keine Spalte „Verl.". Zeilen Fußvergehen, Oberkörperv., Andere, Summe mit den erwarteten Zahlen.

---

### TC-4048: Spalte „Verl." bei Ereignissen in der Verlängerung

**Vorbedingung:** Mindestens ein Ereignis in einer Verlängerungsphase.

**Erwartetes Ergebnis:** Spaltengruppe „Verl." wird angezeigt.

---

### TC-4049: Leeres Spiel zeigt Nullen

**Vorbedingung:** Spiel ohne Ereignisse.

**Erwartetes Ergebnis:** Tabelle wird angezeigt, alle Zellen „0".

---

## Persistenz & Formular

### TC-4050: Täter-Team ohne Rückennummer wird gespeichert

**Vorbedingung:** Ereignisformular: Fußvergehen, Fouler-Team „G" gewählt, keine Nummer. Speichern.

**Erwartetes Ergebnis:** Repository erhält einen `EventPlayer` mit Rolle `fouler`, Team Gast, `jerseyNumber` = null. Beim erneuten Öffnen ist „G" vorausgewählt.

---

### TC-4051: Spielereintrag ohne Nummer überlebt Speichern/Laden

**Vorbedingung:** `createEvent` mit `EventPlayer` ohne Rückennummer.

**Erwartetes Ergebnis:** `getPlayersForGame` liefert den Eintrag mit korrektem Team und `jerseyNumber` = null.

---

### TC-4052: Migration v5 → v6

**Vorbedingung:** v5-Datenbank mit bestehendem `event_players`-Eintrag (Nummer 7).

**Erwartetes Ergebnis:** Schema-Version 6; `jersey_number` ist nullable; bestehender Eintrag inkl. Nummer 7 bleibt erhalten.

---

### TC-4053: Spieler-Ranking ignoriert Einträge ohne Nummer

**Vorbedingung:** Fouler Heim ohne Nummer, Fouler Heim #4.

**Erwartetes Ergebnis:** `playerRankingProvider` liefert nur #4 (1×).
