# User Stories — Epic 3: Spielnachbereitung & Coaching-Vorbereitung

> Fokus: minimale Interaktion pro Ereignis, so wenig Eingaben wie möglich während des Spiels.
> Gerät: Tablet, Querformat.

---

### US-301 · Chronologische Szenenliste anzeigen

**Als** Schiedsrichterbeobachter  
**möchte ich** nach dem Spiel alle Ereignisse in chronologischer Reihenfolge sehen,  
**damit** ich einen Überblick über den Spielverlauf habe.

**Akzeptanzkriterien:**
- [x] Die Liste zeigt alle Ereignisse aufsteigend nach Spielzeit
- [x] Pro Eintrag sichtbar: Spielzeit, Ereignistyp, beteiligte Spieler (falls vorhanden), Entscheidung, Bewertung (Korrekt/Falsch + Trivial/Komplex), Coaching-Flag
- [x] Die Liste ist scrollbar, Einträge sind kompakt (mindestens 8–10 Szenen auf einen Blick)

---

### US-302 · Szenen filtern

**Als** Schiedsrichterbeobachter  
**möchte ich** die Szenenliste filtern können,  
**damit** ich gezielt interessante Szenen finde.

**Akzeptanzkriterien:**
- [ ] Filter: Ereignistyp (Mehrfachauswahl), Entscheidung (Korrekt/Falsch), Szene (Trivial/Komplex), Karte (ja/nein), Coaching-Flag (ja/nein)
- [x] Aktive Filter sind klar sichtbar und einzeln entfernbar
- [x] Ohne aktive Filter werden alle Szenen angezeigt

---

### US-303 · Szene für Coaching markieren

**Als** Schiedsrichterbeobachter  
**möchte ich** eine Szene mit einem Tap als Coaching-relevant markieren,  
**damit** ich im Gespräch mit dem Schiedsrichter gezielt darauf eingehen kann.

**Akzeptanzkriterien:**
- [x] Jede Szene in der Liste hat ein Coaching-Flag (Toggle, ein Tap)
- [x] Markierte Szenen sind visuell hervorgehoben
- [x] Das Flag kann jederzeit gesetzt und entfernt werden

---

### US-304 · Coaching-Notiz erfassen

**Als** Schiedsrichterbeobachter  
**möchte ich** zu einer für das Coaching markierten Szene eine separate Coaching-Notiz hinterlegen,  
**damit** ich festhalte, was ich mit dem Schiedsrichter besprechen möchte.

**Akzeptanzkriterien:**
- [x] Jede Szene hat ein optionales Freitextfeld „Coaching-Notiz" (getrennt von der Szenennotiz)
- [ ] Die Coaching-Notiz ist nur in der Nachbearbeitung erfassbar (nicht im Live-Screen)
- [x] Die Notiz wird lokal gespeichert

---

### US-306 · Szenen- und Coaching-Notizen in der Coaching-Ansicht

**Als** Schiedsrichterbeobachter  
**möchte ich** in der Coaching-Ansicht zu jeder Szene die Live-Szenennotiz sehen und eine separate Coaching-Notiz direkt inline bearbeiten können,  
**damit** ich im Coaching-Gespräch alle relevanten Informationen auf einen Blick habe und keine Notizen in einem separaten Dialog suchen muss.

**Akzeptanzkriterien:**
- [x] Pro Szene in der Coaching-Ansicht wird die Szenennotiz (aus dem Live-Screen) angezeigt, falls vorhanden
- [x] Pro Szene ist die Coaching-Notiz direkt als bearbeitbares Textfeld (inline, kein Dialog) sichtbar — auch wenn noch keine Notiz vorhanden ist
- [x] Änderungen an der Coaching-Notiz werden beim Verlassen des Feldes (onEditingComplete / FocusLoss) automatisch gespeichert
- [x] Ist noch keine Coaching-Notiz vorhanden, zeigt das Feld den Platzhalter „Coaching-Notiz …"
- [x] Das Setzen / Entfernen des Coaching-Flags (⭐) bleibt weiterhin per Tap möglich
- [x] Szenennotiz und Coaching-Notiz sind visuell klar voneinander unterschieden (📋-Icon + grauer Text vs. editierbares TextField)

---

### US-307 · Allgemeine Coaching-Notiz

**Als** Schiedsrichterbeobachter  
**möchte ich** in der Coaching-Ansicht eine übergreifende Notiz zum gesamten Spiel hinterlegen können,  
**damit** ich allgemeine Eindrücke, Eröffnungsworte oder ein Fazit festhalten kann, die keiner einzelnen Szene zugeordnet sind.

**Akzeptanzkriterien:**
- [x] Am Anfang der Coaching-Ansicht gibt es einen eigenen Abschnitt „Allgemeine Notiz" mit einem mehrzeiligen Textfeld
- [x] Die Notiz wird automatisch gespeichert beim Verlassen des Felds (FocusLoss)
- [x] Die Notiz bleibt lokal gespeichert und ist offline verfügbar
- [x] Der Abschnitt ist auch sichtbar, wenn noch keine Szenen für das Coaching markiert wurden
- [x] DB-Migration: `coaching_note`-Spalte in der `games`-Tabelle (nullable Text, Default null), Schema-Version 4

---

### US-305 · Coaching-Ansicht aufrufen

**Als** Schiedsrichterbeobachter  
**möchte ich** eine gefilterte Ansicht nur der für das Coaching markierten Szenen sehen,  
**damit** ich das Coaching-Gespräch strukturiert führen kann.

**Akzeptanzkriterien:**
- [x] Ein Tap auf „Coaching-Ansicht" zeigt nur die markierten Szenen, chronologisch
- [x] Pro Eintrag werden angezeigt: Spielzeit, Ereignistyp, Entscheidung, Bewertung, Coaching-Notiz
- [x] Die Coaching-Ansicht ist auch ohne Internetverbindung zugänglich

---

### US-308 · Vollständige Szeneninfos in Szenenliste und Coaching-Ansicht

**Als** Schiedsrichterbeobachter  
**möchte ich** in der Szenenliste und in der Coaching-Ansicht zu jeder Szene sehen, welcher Spieler das Vergehen begangen hat und wie das Spiel fortgesetzt wurde — und im Detail alle erfassten Infos der Szene,  
**damit** ich die Szene im Nachgang und im Coaching-Gespräch ohne Öffnen des Bearbeiten-Formulars vollständig nachvollziehen kann.

**Akzeptanzkriterien:**

*Szenenliste (Karte pro Szene)*
- [x] Der Fouler wird angezeigt: Teamfarbe (Punkt in Trikotfarbe, US-111) + Teamname + Rückennummer, z. B. „● SV Musterstadt #7"; ohne Rückennummer nur Team („● SV Musterstadt"); ohne erfassten Spieler entfällt die Angabe
- [x] Die Fortsetzung (`refDecision`) wird mit Präfix angezeigt, z. B. „Fortsetzung: Freistoß"; bei eigenem Typ (`custom`) wird die eigene Bezeichnung statt „Sonstiges" angezeigt
- [x] Karte (Gelb/GR/Rot), Bewertung, Szenennotiz und Coaching-Flag bleiben wie bisher sichtbar
- [x] Smartphone (US-704): Fouler und Fortsetzung stehen in eigenen Zeilen, nichts wird horizontal abgeschnitten außer der Szenennotiz (1 Zeile)

*Detailansicht (Tap auf Szene in der Szenenliste)*
- [x] Zeigt alle Infos: Spielzeit inkl. Halbzeit/Nachspielzeit (`elapsedLabel`) und Spielphase, Ereignistyp (bzw. eigene Bezeichnung), Fouler, Fortsetzung, Karte, Bewertung, Szenennotiz (vollständig, mehrzeilig), Coaching-Notiz (bearbeitbar wie bisher)
- [x] Nicht erfasste Felder werden ausgelassen (keine leeren Zeilen / „–")
- [x] Altdaten mit Gefoultem (US-216) zeigen zusätzlich „Gefoult: ● Team #Nr."

*Coaching-Ansicht (pro markierter Szene)*
- [x] Zeigt dieselben Infos wie die Detailansicht: Spielzeit, Ereignistyp, Fouler, Fortsetzung, Karte, Bewertung, Szenennotiz, Coaching-Notiz (inline bearbeitbar wie in US-306)
- [x] Die Kopfzeile bleibt kompakt (Spielzeit · Typ · Karte · Bewertung · ⭐); Fouler und Fortsetzung stehen in einer Infozeile darunter

*Allgemein*
- [x] Gemeinsame Darstellung von Fouler/Fortsetzung in einem wiederverwendbaren Widget (keine doppelte Logik zwischen Szenenliste, Detail und Coaching)
- [x] Kein Schemawechsel — Spielerdaten kommen aus `event_players` (bereits vorhanden, `getPlayersForGame`)
- [x] Offline verfügbar, keine zusätzliche Ladezeit spürbar (Spieler werden einmal pro Spiel geladen, nicht pro Szene)
