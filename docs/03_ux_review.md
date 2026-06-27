# UX Review — Beobachter-App MVP

> Rolle: UX/UI Designer für mobile Apps in zeitkritischen Szenarien
> Input: docs/02_user_stories.md
> Empfänger: Product Owner

---

## Gesamtbewertung

Die User Stories sind inhaltlich solide, aber an zwei kritischen Stellen unterschätzen sie die Eingabekomplexität unter Zeitdruck. Das Ziel „unter 10 Sekunden" (US-208) ist mit dem aktuellen Formularumfang nur erreichbar, wenn das UI-Design kompromisslos auf One-Tap-Interaktionen ausgerichtet wird. Hier gibt es konkreten Klärungsbedarf.

---

## Kritische Befunde

### 1. Das Ereignisformular hat zu viele Schritte für 10 Sekunden

**Problem:** Ein vollständiges Foul-Ereignis umfasst aktuell:
1. Tap auf Spielfeld → Formular öffnet sich
2. Ereignistyp wählen (9 Optionen)
3. Fouler wählen (Rückennummer + Team)
4. Gefoulten wählen (Rückennummer + Team)
5. Entscheidung wählen (11 Optionen)
6. Karte wählen (optional)
7. Bewertung: Korrekt/Falsch
8. Bewertung: Trivial/Komplex
9. Speichern

Das sind bis zu 9 Interaktionen. Unter 10 Sekunden ist das nur machbar, wenn Schritte 3–4 und 6–8 wirklich als ein einziger Tap ausgeführt werden können — also großflächige, gut erreichbare Buttons ohne Scrollen.

**Empfehlung an PO:**
- Definiere ein „Minimal-Event": Nur Schritt 1, 2 und 9 sind Pflicht (Ort + Typ + Speichern).
- Alle anderen Felder sind optional und können nachträglich ergänzt werden.
- Das reduziert den kritischen Pfad auf 3 Interaktionen.

---

### 2. Spielerauswahl ist im Schnellmodus riskant

**Problem:** US-203 beschreibt die Spielerauswahl als „vorerfasste Rückennummern als Schnellauswahl". Das klingt einfach, ist aber unter Zeitdruck fehleranfällig:
- Zwei Teams × bis zu 16 Nummern = bis zu 32 Buttons
- Fouler-Team und Gefoulter-Team müssen korrekt zugeordnet werden
- Bei ähnlichen Nummern (z. B. Nr. 7 Heim vs. Nr. 7 Gast) ist Verwechslung wahrscheinlich

**Empfehlung an PO:**
- Spielerauswahl in zwei klar getrennten Spalten (Heim / Gast) mit Teamfarben
- Alternative: Spieler komplett aus dem Live-Formular entfernen und nur in der Nachbearbeitung erfassen — die meisten Ereignisse geschehen zu schnell für eine akkurate Spielerzuordnung
- **Klärungsbedarf:** Wie oft kennt der Beobachter die Rückennummer im Moment des Vergehens? Oder tippt er sie eher nachher nach?

---

### 3. „Sonstiges" mit Tastatur bricht den Live-Flow

**Problem:** US-202 sieht bei Ereignistyp „Sonstiges" ein Freitextfeld vor. Das bedeutet: Tastatur erscheint → Tipp-Unterbrechung → mehrere Sekunden verloren.

**Empfehlung an PO:**
- „Sonstiges" im Live-Modus nur mit einem Pflichthalter speichern (Typ = „Sonstiges", keine weitere Angabe notwendig)
- Freitext-Bezeichnung nachträglich in der Szenenliste ergänzen
- Alternativ: Eine kleine Liste häufiger Zusatzkategorien (z. B. „Zeitspiel", „Reklamieren") als vordefinierte Schnellauswahl

---

### 4. 11 Entscheidungsoptionen — Lesbarkeit im Grid

**Problem:** US-204 fordert alle 11 Optionen als Buttons ohne Scrollen. Auf einem Tablet im Querformat ist das machbar, aber die Labels müssen sehr kurz sein. Einige Optionen sind lang:
- „Feldverweis nach Gelb-Roter Karte" → passt nicht in einen kompakten Button

**Empfehlung an PO:**
- Kurz-Labels definieren, z. B.: `Freistoß · Strafstoß · Vorteil · Weiter · Gelb · GR · Rot · Eck · Abstoß · Einwurf · Tor`
- Bitte bestätigen, ob diese Abkürzungen für erfahrene Beobachter ausreichen

---

### 5. Zwei Bewertungsdimensionen — Positionierung kritisch

**Problem:** US-206 sieht zwei Toggle-Paare vor (Korrekt/Falsch + Trivial/Komplex). Das ist konzeptionell gut, aber im Formular riskieren beide Toggle-Paare, übersehen zu werden, wenn sie nicht prominent platziert sind.

**Empfehlung:**
- Die Bewertung sollte im Formular visuell hervorstechen (eigene Sektion, größere Buttons)
- Erwäge ein 2×2-Grid als kombinierte Darstellung (z. B. vier Felder: Korrekt-Trivial / Korrekt-Komplex / Falsch-Trivial / Falsch-Komplex) — ein einziger Tap statt zwei

---

### 6. Formular-Layout: Scrolling darf nicht passieren

**Problem:** Mit Spielfeld-Sketch, Ereignistyp-Grid, Spielerauswahl, Entscheidungs-Grid, Karte, zwei Bewertungen und optionaler Notiz droht ein Formular, das auf dem Tablet scrollbar wird. Das ist im Live-Betrieb inakzeptabel.

**Empfehlung:**
- Das Formular muss als Side Panel (rechts neben dem Spielfeld) oder als Bottom Sheet designt werden, das maximal 60–70 % der Bildschirmhöhe einnimmt
- Das Spielfeld-Sketch bleibt immer sichtbar (Rückversicherung, ob der Tipp-Ort stimmt)
- Weniger wichtige Felder (Notiz, Coaching-Markierung) kommen in einen ausklappbaren „Details"-Bereich

---

## Nicht-kritische Anmerkungen

- **US-103 (Spieluhr):** Anforderung, dass die Uhr bei Standby weiterläuft, ist technisch nicht trivial (iOS Background-Timer). Sollte in der Architekturphase explizit adressiert werden.
- **US-104 (Spielübersicht):** „Dauerhaft gespeichert bis manuell gelöscht" — sollte eine Bestätigungsabfrage vor dem Löschen geben.
- **US-305 (Coaching-Ansicht):** Unklar, ob die Coaching-Ansicht druckbar/exportierbar sein soll — für MVP wohl nicht, aber als zukünftige Anforderung vormerken.

---

## Entscheidungen (PO-Antworten)

| # | Frage | Entscheidung |
|---|-------|-------------|
| F1 | Spielerauswahl live oder Nachbearbeitung? | **Live** — bleibt im Ereignisformular |
| F2 | Kurz-Labels für 11 Entscheidungen? | **Bestätigt**, Korrektur: `Ecke` statt `Eck` |
| F3 | 2×2-Grid statt zwei Toggles für Bewertung? | **Ja** — ein Tap wählt Korrekt/Falsch + Erwartbar/Komplex |
| F4 | Minimal-Event erlaubt (nur Ort + Typ)? | **Ja** — alle anderen Felder optional |