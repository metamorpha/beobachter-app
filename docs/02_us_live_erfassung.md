# User Stories — Epic 2: Live-Ereigniserfassung

> Fokus: minimale Interaktion pro Ereignis, so wenig Eingaben wie möglich während des Spiels.
> Gerät: Tablet, Querformat.

---

### US-201 · Ereignis per Feldtipp starten

**Als** Schiedsrichterbeobachter  
**möchte ich** ein Ereignis durch Antippen des Spielfeldsketchs starten,  
**damit** der Ort des Geschehens sofort festgehalten ist und die Eingabe beginnt.

**Akzeptanzkriterien:**
- [x] Der Live-Screen zeigt eine Draufsicht des Fußballfelds (Sketch, proportional korrekt)
- [x] Ein Tap auf das Feld öffnet das Ereignis-Eingabeformular
- [x] Die Koordinate des Taps wird als Ort des Ereignisses gespeichert (relativ zum Feld)
- [x] Die aktuelle Spieluhrzeit wird automatisch als Zeitstempel übernommen
- [x] Das Formular öffnet sich innerhalb von 200 ms (gefühlslos schnell)
- [x] Der getippte Ort ist im Formular als Marker auf einer Mini-Feldvorschau sichtbar

---

### US-202 · Ereignistyp wählen

**Als** Schiedsrichterbeobachter  
**möchte ich** den Typ des Ereignisses schnell auswählen,  
**damit** die Kategorisierung ohne Scrollen oder Tippen möglich ist.

**Akzeptanzkriterien:**
- [x] Das Formular zeigt alle Ereignistypen als tippbare Buttons (kein Dropdown):
  - Fußvergehen · Oberkörpervergehen · Handspiel · Unsportlichkeit · Tätlichkeit
  - Abseits · Vorteilsbestimmung · Torentscheidung · Sonstiges
- [x] Ein Tap wählt den Typ aus (visuelles Feedback durch Hervorhebung)
- [x] Bei „Sonstiges" erscheint ein Freitextfeld für eine eigene Bezeichnung
- [x] Der gewählte Typ kann im selben Formular geändert werden

---

### US-203 · Beteiligte Spieler angeben

**Als** Schiedsrichterbeobachter  
**möchte ich** angeben, welche Spieler an einem Foul beteiligt waren,  
**damit** die Ereignisse später spielerbezogen ausgewertet werden können.

**Akzeptanzkriterien:**
- [x] Ich kann einen „Fouler" und einen „Gefoulten" angeben (je Rückennummer + Team)
- [x] Die Spielerauswahl zeigt die vorerfassten Rückennummern beider Teams als Schnellauswahl
- [x] Ich kann auch eine Nummer manuell eintippen, die nicht in der Aufstellung steht
- [x] Die Spielerangabe ist optional — das Ereignis kann ohne Spieler gespeichert werden
- [x] Bei Ereignistypen ohne Foulcharakter (Abseits, Torentscheidung) ist das Feld ausgeblendet, kann aber bei Bedarf eingeblendet werden

---

### US-204 · Schiedsrichterentscheidung erfassen

**Als** Schiedsrichterbeobachter  
**möchte ich** die Entscheidung des Schiedsrichters per Tap auswählen,  
**damit** ich keine Zeit mit Tippen verliere.

**Akzeptanzkriterien:**
- [x] Alle 11 Entscheidungsoptionen sind als Buttons sichtbar (Grid, kein Scrollen):
  - Freistoß · Strafstoß · Vorteil · Weiterspielen
  - Verwarnung · Feldverweis (GR) · Feldverweis (R)
  - Eckstoß · Abstoß · Einwurf · Tor/Anstoß
- [x] Ein Tap wählt die Entscheidung aus
- [x] Die Auswahl ist optional

---

### US-205 · Karte als Attribut erfassen

**Als** Schiedsrichterbeobachter  
**möchte ich** angeben, ob bei einem Ereignis eine Karte gezeigt wurde,  
**damit** Kartenvergaben dem richtigen Ereignis zugeordnet sind.

**Akzeptanzkriterien:**
- [x] Im Formular gibt es einen optionalen Bereich „Karte": Gelb / Gelb-Rot / Rot
- [x] Ein Tap wählt die Kartenfarbe aus; erneuter Tap deselektiert
- [x] Karte kann unabhängig von der Schiedsrichterentscheidung gesetzt werden

---

### US-206 · Ereignis bewerten

**Als** Schiedsrichterbeobachter  
**möchte ich** die Entscheidung und die Szene jeweils mit einem Tap bewerten,  
**damit** ich ohne Ablenkung meine Einschätzung festhalten kann.

**Akzeptanzkriterien:**
- [x] Zwei unabhängige Toggle-Paare, je mit einem Tap umschaltbar:
  - Entscheidung: **Korrekt** / **Falsch**
  - Szene: **Erwartbar** / **Komplex**
- [x] Beide Bewertungen sind optional (kein Zwang zur Angabe)
- [x] Die gewählte Option ist klar hervorgehoben

---

### US-207 · Szenennotiz hinzufügen

**Als** Schiedsrichterbeobachter  
**möchte ich** optional eine kurze Freitextnotiz zur Szene erfassen,  
**damit** ich Details festhalte, die sich nicht in Kategorien pressen lassen.

**Akzeptanzkriterien:**
- [x] Das Formular enthält ein optionales Freitextfeld „Notiz"
- [x] Das Feld ist standardmäßig minimiert und kann mit einem Tap aufgeklappt werden
- [x] Es gibt keine Zeichenbegrenzung

---

### US-208 · Ereignis speichern

**Als** Schiedsrichterbeobachter  
**möchte ich** ein Ereignis mit einem Tap speichern und sofort zum Spielfeld zurückkehren,  
**damit** ich das Spielgeschehen nicht länger als nötig aus den Augen verliere.

**Akzeptanzkriterien:**
- [x] Ein gut erreichbarer „Speichern"-Button schliesst das Formular und speichert das Ereignis
- [x] Die App kehrt sofort zum Live-Screen (Spielfeld-Sketch) zurück
- [x] Das Ereignis ist dauerhaft lokal gespeichert (auch bei App-Absturz)
- [ ] Der Zeitraum vom ersten Tap auf das Feld bis zum Speichern soll unter 10 Sekunden möglich sein (alle Pflichtfelder: nur Ereignistyp + Entscheidung)
- [x] Ich kann ein Ereignis auch abbrechen (Schließen ohne Speichern)

---

### US-209 · Ereignis nachträglich bearbeiten

**Als** Schiedsrichterbeobachter  
**möchte ich** ein bereits gespeichertes Ereignis korrigieren können,  
**damit** Fehler bei der schnellen Eingabe im Nachhinein korrigiert werden können.

**Akzeptanzkriterien:**
- [x] Aus der Szenenliste (Epic 3) kann ich jedes Ereignis antippen und bearbeiten
- [x] Alle Felder sind editierbar (inkl. Zeitstempel und Ort)
- [x] Änderungen werden lokal gespeichert
