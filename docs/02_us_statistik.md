# User Stories — Epic 4: Statistik & Analyse

> Fokus: minimale Interaktion pro Ereignis, so wenig Eingaben wie möglich während des Spiels.
> Gerät: Tablet, Querformat.

---

### US-401 · Heatmap anzeigen

**Als** Schiedsrichterbeobachter  
**möchte ich** eine Heatmap der Ereignisorte auf dem Spielfeld sehen,  
**damit** ich räumliche Häufungen (Hotspots) auf einen Blick erkenne.

**Akzeptanzkriterien:**
- [x] Das Spielfeld wird als Draufsicht dargestellt mit Farbintensität proportional zur Ereignisdichte
- [x] Die Heatmap wird als kontinuierliche Dichteverteilung (KDE) gerendert, nicht als festes Zonenraster
- [x] Nah beieinanderliegende Ereignisse bilden einen gemeinsamen, intensiveren Hotspot mit punktgenauer Lage
- [x] Farbverlauf: transparent (keine Dichte) → gelb (niedrig) → orange → rot (Maximum)
- [x] Einzelereignisse sind als weiche Flecken sichtbar (Mindest-Sichtbarkeit)
- [x] Rendering bleibt bei typischer Ereignisanzahl (< 200) flüssig
- [ ] Ich kann nach Ereignistyp filtern (z. B. nur Fouls)
- [ ] Ich kann nach Team filtern (Heimteam / Gastteam)

---

### US-402 · Zeitachse anzeigen

**Als** Schiedsrichterbeobachter  
**möchte ich** sehen, in welchen Spielphasen besonders viele Ereignisse auftraten,  
**damit** ich Belastungsphasen des Schiedsrichters identifizieren kann.

**Akzeptanzkriterien:**
- [x] Balkendiagramm: Ereignisse pro 15-Minuten-Phase (0–15, 15–30, 30–45, 45–60, 60–75, 75–90)
- [ ] Nachspielzeit wird der letzten Phase zugeordnet
- [ ] Filter nach Ereignistyp möglich

---

### US-403 · Spieler-Ranking anzeigen

**Als** Schiedsrichterbeobachter  
**möchte ich** sehen, welche Spieler besonders oft an Ereignissen beteiligt waren,  
**damit** ich auffällige Spieler im Coaching-Gespräch gezielt ansprechen kann.

**Akzeptanzkriterien:**
- [x] Liste der Rückennummern sortiert nach Häufigkeit der Ereignisbeteiligung — nur Täter (Fouler), gefoulte Spieler werden nicht gezählt
- [ ] Team-Filter (Heimteam / Gastteam)
- [ ] Ereignistyp-Filter

---

### US-404 · Vergehen pro Team und Halbzeit

**Als** Schiedsrichterbeobachter  
**möchte ich** auf der Statistikseite sehen, wie viele Fuß- und Oberkörpervergehen sowie andere Vergehen jedes Team pro Halbzeit verschuldet hat,  
**damit** ich die Spielcharakteristik und die Linie des Schiedsrichters im Coaching-Gespräch einordnen kann.

**Akzeptanzkriterien:**
- [x] Kompakte Tabelle „Vergehen pro Team" unterhalb des Spieler-Rankings
- [x] Zeilen: Fußvergehen · Oberkörpervergehen · Andere · Summe
- [x] „Andere" umfasst Handspiel, Unsportlichkeit, Tätlichkeit und Sonstiges; Abseits, Vorteil und Torentscheidung werden nicht gezählt
- [x] Spalten: 1. HZ (Heim | Gast) · 2. HZ (Heim | Gast)
- [x] Nachspielzeit zählt zur jeweiligen Halbzeit
- [x] Spalte „Verl." (Heim | Gast) erscheint nur, wenn Ereignisse in der Verlängerung erfasst wurden (inkl. deren Nachspielzeit)
- [x] Team-Zuordnung über das Team des Täters (Fouler); Ereignisse ohne Täter-Team werden nicht gezählt
- [x] Im Ereignisformular wird das Täter-/Gefoulten-Team auch **ohne Rückennummer** gespeichert (DB-Schema v6, Rückennummer optional)
- [x] Spieler-Ranking (US-403) ignoriert Einträge ohne Rückennummer
- [x] Leere Zellen zeigen „0"; Tabelle aktualisiert sich nach Bearbeiten oder Löschen einer Szene
