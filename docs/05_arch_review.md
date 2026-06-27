# Architektur-Review — Beobachter-App MVP

> Rolle: Software-Architekt, Offline-First Mobile
> Input: docs/02_user_stories.md, docs/04_ux_design.md

---

## Gesamtbewertung

Das UX-Design ist technisch solide und umsetzbar. Die kritischen Pfade (Spielfeld-Tap → Formular → Speichern) sind technisch unkompliziert. Es gibt **zwei architekturkritische Risiken** und **eine strategische Entscheidung**, die vor Beginn der Implementierung geklärt werden müssen.

---

## Technische Machbarkeit

### Spielfeld-Sketch als interaktiver Canvas

**Bewertung: unkompliziert**

Ein Fußballfeld als SVG oder Canvas mit Tap-Handler ist auf allen Zielplattformen gut lösbar. Die Tap-Koordinate wird als relative Position (0.0–1.0 in X/Y) gespeichert — unabhängig von der Bildschirmauflösung. Das erlaubt eine korrekte Darstellung der Heatmap und Marker auf jedem Gerät.

### Side Panel neben Spielfeld (40/60 Split)

**Bewertung: unkompliziert**

Standard-Flexbox-Layout im Querformat. Kein technisches Risiko.

### 2×2-Bewertungs-Grid, Ereignistyp-Grid, Entscheidungs-Grid

**Bewertung: unkompliziert**

Alle Grids sind einfache Button-Grids ohne dynamisches Verhalten. Implementierung in < 1 Stunde.

### Heatmap

**Bewertung: machbar, aber nicht trivial**

Eine Heatmap auf einem Spielfeld-Canvas erfordert entweder eine dedizierte Bibliothek oder eine eigene Kernel-Density-Implementierung (Gaussian Blur über Punktwolke). Für MVP reicht eine vereinfachte Variante: Spielfeld in Zonen unterteilen (z. B. 6×4-Grid), Häufigkeit pro Zone als Farbintensität darstellen. Das ist in wenigen Stunden implementierbar und visuell ausreichend.

---

## Risiko 1 (kritisch): Spieluhr im Hintergrund

**Problem:** iOS beendet `setInterval`-basierte Timer, sobald die App in den Hintergrund geht (z. B. Nutzer schaut kurz auf andere App). Die Spieluhr würde einfrieren.

**Lösung:** Timestamp-Ansatz statt laufendem Timer:
- Bei „Start": `startTimestamp = Date.now()` + `elapsedBeforeLastStop` speichern
- Angezeigte Zeit = `elapsedBeforeLastStop + (Date.now() - startTimestamp)`
- Bei „Stop": `elapsedBeforeLastStop += (Date.now() - startTimestamp)` speichern
- Dieser Ansatz ist background-safe, da keine laufenden Timer benötigt werden
- Die Anzeige wird nur aktualisiert, wenn die App im Vordergrund ist — aber der Wert ist immer korrekt

**Konsequenz:** Die Uhr zeigt die korrekte Zeit, sobald die App wieder aktiv ist. Kein Datenverlust.

---

## Risiko 2 (kritisch): Cross-Platform Framework-Wahl

**Problem:** Die Zielplattformen sind iOS, Android und Windows Surface (Win32/UWP). Das schränkt die Framework-Wahl erheblich ein.

| Framework | iOS | Android | Windows | Reife | Empfehlung |
|-----------|-----|---------|---------|-------|------------|
| **Flutter** | ✅ | ✅ | ✅ (Desktop-stable) | Hoch | **Empfohlen** |
| React Native | ✅ | ✅ | ⚠️ (Community, instabil) | Mittel | Riskant |
| Capacitor/Ionic | ✅ | ✅ | ✅ (WebView) | Mittel | Nicht nativ |
| .NET MAUI | ✅ | ✅ | ✅ | Mittel | Möglich |

**Empfehlung: Flutter**
- Stabile Desktop-Unterstützung für Windows (seit Flutter 2.10)
- Eine Codebase für alle drei Plattformen
- Canvas-API (`CustomPainter`) ideal für Spielfeld-Sketch und Heatmap
- SQLite-Support via `drift` (type-safe, migrationsfreundlich)
- Aktives Ökosystem

**Alternativ: .NET MAUI**, falls der Entwickler C#/.NET bevorzugt und kein Dart lernen möchte. MAUI hat ebenfalls solide Cross-Platform-Unterstützung, ist aber in der Community kleiner.

---

## Datenmodell-Vollständigkeit

Das UX-Design impliziert folgende Entitäten. Alle sind vollständig abgedeckt — ein Feld fehlt (siehe unten):

| Entität | Vollständig? | Anmerkung |
|---------|-------------|-----------|
| Game | ✅ | Datum, Teams, Ort |
| Squad | ✅ | Rückennummern je Team |
| TimerState | ✅ | Muss `elapsedMs` + `startTimestamp` + `isRunning` speichern |
| Event | ✅ | Typ, Koordinaten, Entscheidung, Karte, Bewertung, Notizen |
| EventPlayer | ✅ | Fouler + Gefoulter mit Team-Zuordnung |

**Fehlendes Feld:** `Event.customTypeLabel` — bei Ereignistyp „Sonstiges" wird ein Freitext-Label benötigt. Muss im Datenmodell explizit vorgesehen werden.

**Koordinaten:** Als normalisierte Float-Werte (x: 0.0–1.0, y: 0.0–1.0) speichern, nicht als Pixel. Damit sind Heatmap und Marker auflösungsunabhängig.

---

## Persistenzstrategie

**Empfehlung: SQLite mit lokalem Repository-Pattern**

- Alle Daten lokal in SQLite
- Repository-Layer abstrahiert die Datenbankzugriffe (später austauschbar gegen Remote-API)
- Kein ORM-Overhead: Flutter + `drift` (type-safe SQLite wrapper) ist ideal
- Jedes Event wird sofort nach „Speichern" geschrieben (kein Batching, kein Risiko)

---

## Offene Fragen (vor Architekturphase zu klären)

| # | Frage | Einfluss |
|---|-------|---------|
| A1 | Flutter oder .NET MAUI? (Dart vs. C#) | Gesamte Technologiewahl |
| A2 | Soll die App mehrsprachig sein (DE/EN)? | i18n-Infrastruktur |
| A3 | Soll es eine Undo-Funktion für versehentlich gespeicherte Events geben? | Event-Lifecycle |