# Epics — Beobachter-App MVP

> Priorisiert nach Nutzen im Live-Spiel. Kritische Epics (1–2) müssen für den MVP vollständig sein.

---

## Epic 1 — Spielverwaltung

**Ziel:** Ein Spiel anlegen, Aufstellungen erfassen und die Spieluhr bedienen.

**Warum kritisch:** Ohne Spiel keine Ereignisse. Die Uhr liefert die automatische Zeitstempelung.

**Scope MVP:**
- Neues Spiel anlegen: Datum, Ort, Heimmannschaft, Gastmannschaft, Liga, Spieltag
- Aufstellungen: Rückennummern beider Teams manuell eingeben
- **CSV-Import:** Spieldaten und Aufstellungen aus Pressebericht-CSV (DFB/FLVW-Format) importieren
- Spieluhr mit Start/Stop-Button (laufende Uhr, sichtbar während des Spiels)
- Stop = Halbzeit oder Spielende; Start = Wiederanpfiff
- Spiel lokal auf dem Gerät speichern (offline-first)
- Liste gespeicherter Spiele (Spielübersicht)

**Außerhalb MVP:**
- Server-Sync

---

## Epic 2 — Live-Ereigniserfassung

**Ziel:** Ein beobachtetes Ereignis in unter 10 Sekunden vollständig erfassen.

**Warum kritisch:** Das ist der Kern der App. Jede Sekunde Verzögerung bedeutet verpasste Details.

**Scope MVP:**
- Spielfeld-Sketch (Draufsicht) antippen → Ereignis-Erfassung startet
- Ort des Vergehens = Antippen-Koordinate auf dem Sketch
- Automatische Übernahme der aktuellen Spielzeit
- Ereignistyp wählen (Schnellauswahl):
  - Fußvergehen
  - Oberkörpervergehen
  - Handspiel
  - Unsportlichkeit
  - Tätlichkeit
  - Abseits
  - Vorteilsbestimmung
  - Torentscheidung
  - Sonstiges (Freitext-Label)
- Beteiligte Spieler: Fouler (Rückennummer + Team) und Gefoulter (Rückennummer + Team) — optional bei nicht-Foul-Ereignissen
- Schiedsrichterentscheidung wählen (11 Optionen als Grid):
  - Freistoß · Strafstoß · Vorteil · Weiterspielen
  - Verwarnung · Feldverweis (GR) · Feldverweis (R)
  - Eckstoß · Abstoß · Einwurf · Tor/Anstoß
- Karte als optionales Attribut: Gelb, Gelb-Rot, Rot (nur bei entsprechender Entscheidung sinnvoll)
- Bewertung — zwei unabhängige Dimensionen:
  - Entscheidung: Korrekt / Falsch
  - Szene: Trivial / Komplex
- Optionale Szenennotiz (Freitext)
- Ereignis speichern mit einem Tap

**Außerhalb MVP:**
- Sprachnotiz
- Automatische Kartenzählung

---

## Epic 3 — Spielnachbereitung & Coaching-Vorbereitung

**Ziel:** Nach dem Spiel die erfassten Szenen strukturiert aufbereiten und für das Coaching-Gespräch vorbereiten.

**Warum wichtig:** Kernoutput der Beobachtertätigkeit — ohne Nachbereitung kein Mehrwert.

**Scope MVP:**
- Chronologische Szenenliste (alle Ereignisse des Spiels)
- Filter: nach Ereignistyp, Korrekt/Falsch, Trivial/Komplex
- Coaching-Flag pro Szene setzen/entfernen (ein Tap)
- Optionale Coaching-Notiz pro Szene (getrennt von Szenennotiz)
- Coaching-Ansicht: nur markierte Szenen, geordnet nach Spielzeit

**Außerhalb MVP:**
- Export (PDF, E-Mail)
- Geteilte Coaching-Session

---

## Epic 4 — Statistik & Analyse

**Ziel:** Muster im Spielgeschehen erkennen: Hotspots, Spielphasen, auffällige Spieler.

**Warum wichtig:** Liefert objektive Grundlage für das Coaching-Gespräch.

**Scope MVP:**
- **Heatmap:** Spielfeld mit Vergehen-Dichte (Häufung sichtbar durch Farbintensität)
- **Zeitachse:** Vergehen pro Spielphase (z. B. 0–15, 15–30, 30–45, 45–60, 60–75, 75–90 Min.)
- **Spieler-Ranking:** Rückennummern mit Häufigkeit von Ereignisbeteiligung
- Filter: Ereignistyp, Team, Korrekt/Falsch

**Außerhalb MVP:**
- Vergleich mehrerer Spiele
- Schiedsrichter-übergreifende Statistiken

---

## Epic 5 — Datenpersistenz & Offline-Betrieb

**Ziel:** Alle Daten zuverlässig lokal speichern — ohne Netzwerk, ohne Datenverlust.

**Warum kritisch (technisch):** Fundament für alle anderen Epics. Kein Netz auf dem Sportplatz.

**Scope MVP:**
- Lokale Datenbank (alle Spiele, Ereignisse, Bewertungen, Notizen)
- Automatisches Speichern nach jedem Ereignis (kein manuelles Speichern nötig)
- App-Neustart ohne Datenverlust
- Gerät: Tablet, Querformat (iOS, Android, Windows Surface)

**Außerhalb MVP:**
- Server-Sync
- Cloud-Backup
- Export/Import zwischen Geräten

---

## Priorisierung

| Priorität | Epic | Begründung |
|-----------|------|------------|
| P0 | Epic 2 — Live-Ereigniserfassung | Kernwert der App |
| P0 | Epic 5 — Datenpersistenz | Fundament, alles andere hängt davon ab |
| P1 | Epic 1 — Spielverwaltung | Voraussetzung für Epic 2 |
| P2 | Epic 3 — Nachbereitung & Coaching | Output der Beobachtertätigkeit |
| P3 | Epic 4 — Statistik & Analyse | Mehrwert, aber nicht live-kritisch |