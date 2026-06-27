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
- [x] Liste der Rückennummern sortiert nach Häufigkeit der Ereignisbeteiligung (Fouler + Gefoulter)
- [ ] Team-Filter (Heimteam / Gastteam)
- [ ] Ereignistyp-Filter
