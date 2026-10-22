# Testfälle — Laufendes Spiel aus der Spielliste fortsetzen (US-109)

---

## Laufend-Regel (Unit)

### TC-1091: Phasen, die als laufend gelten

**Vorbedingung:** Alle Werte von `GamePhase`.

**Erwartetes Ergebnis:** `istLaufend` ist `false` für `bereit` und `abgeschlossen`, `true` für alle übrigen Phasen (inkl. `halbzeit`, Nachspielzeiten, Verlängerung, `beendet`, `beendetVerlaengerung`).

---

## Spielliste (Widget)

### TC-1092: Badge „Läuft" nur für laufende Spiele

**Vorbedingung:** Spiel g1 in `zweiteHalbzeit`, g2 `abgeschlossen`, g3 ohne Timer-Zustand.

**Erwartetes Ergebnis:** g1 zeigt „Läuft" (kein „Beendet"); g2 zeigt „Beendet" (kein „Läuft"); g3 zeigt kein Badge.

---

### TC-1093: Tap auf laufendes Spiel öffnet den Live-Screen

**Vorbedingung:** Spiel in `ersteHalbzeit`, Uhr läuft.

**Aktion:** Tap auf die Kachel.

**Erwartetes Ergebnis:** `LiveScreen` ist sichtbar, `ReviewScreen` und `GameSetupScreen` nicht.

---

### TC-1094: Tap auf Spiel nach dem Abpfiff öffnet den Live-Screen

**Vorbedingung:** Spiel in `beendet` (Abpfiff, noch nicht „Spiel beenden").

**Erwartetes Ergebnis:** `LiveScreen` ist sichtbar.

---

### TC-1095: Nicht gestartetes Spiel öffnet weiterhin die Nachbereitung

**Vorbedingung:** Spiel ohne Timer-Zustand.

**Erwartetes Ergebnis:** `ReviewScreen` ist sichtbar.

---

### TC-1096: Abgeschlossenes Spiel öffnet weiterhin die Nachbereitung

**Vorbedingung:** Spiel in `abgeschlossen`.

**Erwartetes Ergebnis:** `ReviewScreen` ist sichtbar.

---

### TC-1097: Uhr und Phase bleiben beim Fortsetzen unverändert

**Vorbedingung:** Spiel in `zweiteHalbzeit`, Uhr läuft seit Startzeitpunkt T mit `elapsedMs` = 50 min.

**Aktion:** Tap auf die Kachel.

**Erwartetes Ergebnis:** Gespeicherter Timer-Zustand nach dem Öffnen ist unverändert (Phase `zweiteHalbzeit`, `isRunning` = true, Startzeitpunkt T, `elapsedMs` = 50 min). Kein neuer Start, kein Reset.

---

### TC-1098: Zurück vom Live-Screen führt zur Spielliste

**Vorbedingung:** Live-Screen über die Spielliste geöffnet (TC-1093).

**Aktion:** Zurück.

**Erwartetes Ergebnis:** Spielliste ist sichtbar, das Spiel trägt weiterhin „Läuft".
