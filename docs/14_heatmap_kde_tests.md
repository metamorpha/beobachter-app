# Testfälle — US-401: Heatmap als kontinuierliche Dichteverteilung (KDE)

> Abgedeckte User Story: US-401 (Heatmap anzeigen — KDE-Erweiterung)
> Gerät: Tablet, Querformat · Screen: Review → Statistik-Tab
> Umsetzung: Unit-Tests auf der reinen Dichteberechnung (`HeatmapDensity`) + Widget-Tests (`HeatmapCanvas`)

---

## Gruppe A — Dichteberechnung (Unit, `HeatmapDensity`)

### TC-1401 · Leere Ereignisliste ergibt Nullgitter

**Vorbedingung:** —
**Aktion:** Dichtegitter aus leerer Ereignisliste berechnen
**Erwartetes Ergebnis:** Alle Gitterzellen haben Dichte 0.0; kein Fehler; Maximum ist 0
**Kriterium:** US-401 AK „Spiel ohne Ereignisse → kein Heatmap-Overlay"

---

### TC-1402 · Einzelereignis: Maximum an der Ereignisposition

**Vorbedingung:** —
**Aktion:** Dichtegitter aus einem Ereignis in Feldmitte (0.5 / 0.5) berechnen
**Erwartetes Ergebnis:** Zelle an Position (0.5 / 0.5) hat die maximale Dichte (1.0 nach Normalisierung); Dichte fällt mit wachsendem Abstand monoton ab
**Kriterium:** US-401 AK „punktgenaue Lage"

---

### TC-1403 · Zwei identische Positionen: Normalisierung auf 1.0

**Vorbedingung:** —
**Aktion:** Dichtegitter aus zwei Ereignissen an exakt derselben Position berechnen
**Erwartetes Ergebnis:** Maximum ist genau 1.0 (normalisiert); die Verteilung ist identisch geformt wie bei einem Einzelereignis
**Kriterium:** US-401 AK „Überlagerungen addieren sich"

---

### TC-1404 · Zwei weit entfernte Einzelereignisse gleich intensiv

**Vorbedingung:** —
**Aktion:** Dichtegitter aus zwei Ereignissen an (0.2 / 0.5) und (0.8 / 0.5) berechnen
**Erwartetes Ergebnis:** Beide Positionen haben dieselbe Dichte 1.0 (gemeinsames Maximum); dazwischen fällt die Dichte deutlich ab
**Kriterium:** US-401 AK „Einzelereignisse sichtbar"

---

### TC-1405 · Ereignis in Feldecke ohne Fehler

**Vorbedingung:** —
**Aktion:** Dichtegitter aus Ereignissen an (0.0 / 0.0) und (1.0 / 1.0) berechnen
**Erwartetes Ergebnis:** Kein Index-Fehler; die Eckzellen tragen die maximale Dichte; der Kernel wird am Feldrand abgeschnitten
**Kriterium:** Robustheit (Randfälle der normierten Koordinaten)

---

### TC-1406 · Cluster intensiver als Einzelereignis, Einzelereignis bleibt sichtbar

**Vorbedingung:** —
**Aktion:** Dichtegitter aus 5 eng benachbarten Ereignissen (Abstand ≤ 0.02) + 1 entferntem Einzelereignis berechnen
**Erwartetes Ergebnis:** Cluster-Zentrum hat Dichte 1.0; Position des Einzelereignisses hat Dichte deutlich > 0 (im Rendering über Mindest-Alpha sichtbar)
**Kriterium:** US-401 AK „Hotspot intensiver" + „Einzelereignisse sichtbar"

---

### TC-1407 · Kernel ist symmetrisch in x und y

**Vorbedingung:** —
**Aktion:** Dichtegitter aus einem Ereignis in Feldmitte berechnen; Dichte in gleichem Zellabstand links/rechts bzw. oben/unten vom Maximum vergleichen
**Erwartetes Ergebnis:** Dichtewerte in x-Richtung und y-Richtung sind bei gleichem normierten Abstand gleich (radialsymmetrischer Gauß-Kernel)
**Kriterium:** Korrektheit der Dichteberechnung

---

## Gruppe B — Widget (`HeatmapCanvas`)

### TC-1408 · Widget rendert ohne Fehler bei 0, 1 und 50 Ereignissen

**Vorbedingung:** —
**Aktion:** `HeatmapCanvas` mit leerer Liste, 1 Ereignis und 50 zufällig verteilten Ereignissen pumpen
**Erwartetes Ergebnis:** Kein Exception/Overflow; CustomPaint wird gebaut
**Kriterium:** US-401 AK „Rendering flüssig bei typischer Ereignisanzahl"

---

### TC-1409 · Repaint bei geänderter Ereignisliste

**Vorbedingung:** —
**Aktion:** `shouldRepaint` des Painters mit alter vs. neuer Ereignisliste aufrufen
**Erwartetes Ergebnis:** `true` bei geänderter Liste, `false` bei identischer Liste
**Kriterium:** Korrektes Update-Verhalten nach Filterwechsel/Neuladen

---

## Gruppe C — Manuelle Prüfung (Simulator/Gerät)

### TC-1410 · Visueller Eindruck: weiche Verläufe ohne Rasterkanten

**Vorbedingung:** Spiel mit einem dichten Ereigniscluster und mehreren Einzelereignissen
**Aktion:** Review → Statistik-Tab öffnen
**Erwartetes Ergebnis:** Hotspot erscheint als weicher rot-oranger Fleck mit punktgenauer Lage; keine sichtbaren Rasterkanten; Einzelereignisse als weiche gelbe Flecken; Feldlinien bleiben erkennbar
**Kriterium:** US-401 AK Farbverlauf + punktgenaue Lage

---

## Ergebnisübersicht

| TC | Gruppe | Art | Status |
|----|--------|-----|--------|
| TC-1401 | A — Dichteberechnung | Unit | ✅ |
| TC-1402 | A — Dichteberechnung | Unit | ✅ |
| TC-1403 | A — Dichteberechnung | Unit | ✅ |
| TC-1404 | A — Dichteberechnung | Unit | ✅ |
| TC-1405 | A — Dichteberechnung | Unit | ✅ |
| TC-1406 | A — Dichteberechnung | Unit | ✅ |
| TC-1407 | A — Dichteberechnung | Unit | ✅ |
| TC-1408 | B — Widget | Widget | ✅ |
| TC-1409 | B — Widget | Unit | ✅ |
| TC-1410 | C — Manuelle Prüfung | Manuell | ✅ (bestanden am 02.07.2026) |
