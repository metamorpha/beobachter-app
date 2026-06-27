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

### US-305 · Coaching-Ansicht aufrufen

**Als** Schiedsrichterbeobachter  
**möchte ich** eine gefilterte Ansicht nur der für das Coaching markierten Szenen sehen,  
**damit** ich das Coaching-Gespräch strukturiert führen kann.

**Akzeptanzkriterien:**
- [x] Ein Tap auf „Coaching-Ansicht" zeigt nur die markierten Szenen, chronologisch
- [x] Pro Eintrag werden angezeigt: Spielzeit, Ereignistyp, Entscheidung, Bewertung, Coaching-Notiz
- [x] Die Coaching-Ansicht ist auch ohne Internetverbindung zugänglich
