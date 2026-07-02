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

---

### US-210 · Spieluhr mit Halbzeit-Phasensteuerung und Nachspielzeit

**Als** Schiedsrichterbeobachter  
**möchte ich** dass die Spieluhr die realen Spielphasen (Halbzeiten, Nachspielzeiten) abbildet,  
**damit** alle erfassten Ereignisse der richtigen Spielminute zugeordnet sind und ich mit einem Tap zwischen den Phasen wechseln kann.

**Akzeptanzkriterien:**

*1. Halbzeit (0:00 – 45:00)*
- [ ] Nach dem Spielstart läuft die Uhr von 0:00 aufwärts im Format MM:SS (z. B. `23:45`)
- [ ] Ab 45:00 wechselt die Anzeige automatisch in das Nachspielzeit-Format `45+01`, `45+02`, ...

*Halbzeitpause*
- [ ] Im Live-Screen ist ein Button **„Halbzeit"** sichtbar, solange die 1. Halbzeit (inkl. deren Nachspielzeit) läuft
- [ ] Ein Tap stoppt die Uhr; der Timer-Zustand wechselt in den Status `halbzeit`
- [ ] In der Halbzeitpause zeigt der Screen einen Button **„2. Halbzeit starten"**

*2. Halbzeit (45:00 – 90:00)*
- [ ] „2. Halbzeit starten" setzt die Uhr bei 45:00 fort (kein Neustart bei 0:00)
- [ ] Die Anzeige läuft MM:SS weiter (z. B. `67:12`)
- [ ] Ab 90:00 wechselt die Anzeige automatisch in das Nachspielzeit-Format `90+01`, `90+02`, ...

*Spielende / Abpfiff*
- [ ] Im Live-Screen ist ein Button **„Abpfiff"** sichtbar, solange die 2. Halbzeit (inkl. deren Nachspielzeit) läuft
- [ ] Ein Tap stoppt die Uhr; der Timer-Zustand wechselt in den Status `beendet`
- [ ] Nach dem Abpfiff erscheint optional der Button **„Verlängerung starten"** (→ US-211)

*Ereignis-Zeitstempel*
- [ ] Ein Ereignis, das während der Nachspielzeit der 1. Halbzeit erfasst wird, erhält den Zeitstempel im Format `45+X` (z. B. `45+02`)
- [ ] Ein Ereignis, das während der Nachspielzeit der 2. Halbzeit erfasst wird, erhält den Zeitstempel im Format `90+X`
- [ ] In Ereignisformular und Szenenliste wird der Zeitstempel immer im jeweils geltenden Format angezeigt

---

### US-211 · Verlängerung starten und verwalten

**Als** Schiedsrichterbeobachter  
**möchte ich** bei Bedarf eine Verlängerung (2 × 15 Min.) starten können,  
**damit** auch Ereignisse in der Verlängerung mit der korrekten Spielminute erfasst werden.

**Akzeptanzkriterien:**

*Verlängerung 1. Halbzeit (90:00 – 105:00)*
- [ ] Nach dem Abpfiff der regulären Spielzeit (Status `beendet`) erscheint der Button **„Verlängerung starten"**
- [ ] Ein Tap startet die Verlängerung: die Uhr setzt bei 90:00 fort
- [ ] Ab 105:00 wechselt die Anzeige automatisch in das Nachspielzeit-Format `105+01`, `105+02`, ...
- [ ] Ein Button **„Halbzeit (Verl.)"** ist sichtbar, solange die 1. Hälfte der Verlängerung (inkl. Nachspielzeit) läuft
- [ ] Ein Tap stoppt die Uhr; der Timer-Zustand wechselt in den Status `halbzeit_verlaengerung`

*Verlängerung 2. Halbzeit (105:00 – 120:00)*
- [ ] In der Halbzeitpause der Verlängerung erscheint der Button **„2. Verlängerung starten"**
- [ ] Ein Tap setzt die Uhr bei 105:00 fort
- [ ] Ab 120:00 wechselt die Anzeige automatisch in das Nachspielzeit-Format `120+01`, `120+02`, ...
- [ ] Ein Button **„Abpfiff (Verl.)"** ist sichtbar, solange die 2. Hälfte der Verlängerung (inkl. Nachspielzeit) läuft
- [ ] Ein Tap stoppt die Uhr; der Timer-Zustand wechselt in den Status `beendet`

*Ereignis-Zeitstempel*
- [ ] Ereignisse in der Verlängerung 1. HZ erhalten Zeitstempel im Format `90:XX` bzw. `105+X`
- [ ] Ereignisse in der Verlängerung 2. HZ erhalten Zeitstempel im Format `105:XX` bzw. `120+X`

---

### US-212 · Spiel endgültig beenden

**Als** Schiedsrichterbeobachter  
**möchte ich** nach dem Abpfiff der 2. Halbzeit wählen können, ob das Spiel beendet ist oder in die Verlängerung geht,  
**damit** ein abgeschlossenes Spiel nicht versehentlich weiterläuft, ich aber weiterhin auf Statistik, Szenen und Notizen zugreifen kann.

**Akzeptanzkriterien:**

*Wahlmöglichkeit nach Abpfiff*
- [x] Nach dem Abpfiff der 2. Halbzeit (Status `beendet`) zeigt der Live-Screen zwei Buttons: **„Verlängerung starten"** und **„Spiel beenden"**
- [x] Nach dem Abpfiff der Verlängerung (Status `beendetVerlaengerung`) zeigt der Live-Screen den Button **„Spiel beenden"**
- [x] Ein Tap auf „Spiel beenden" öffnet einen Bestätigungsdialog (Hinweis: nicht rückgängig machbar); erst „Beenden" im Dialog schließt das Spiel ab

*Abgeschlossenes Spiel*
- [x] Ein abgeschlossenes Spiel kann nicht erneut gestartet werden: keine Phasen-Buttons mehr, die Spieluhr bleibt stehen
- [x] Im abgeschlossenen Spiel können keine neuen Ereignisse mehr erfasst werden (Feldtipp öffnet kein Formular)
- [x] Der Abgeschlossen-Zustand überlebt App-Neustart (Persistenz)

*Zugriff auf Nachbereitung bleibt erhalten*
- [x] Statistik (Heatmap, Zeitachse, Ranking), Szenenliste und Coaching-Tab bleiben vollständig erreichbar
- [x] Bestehende Szenen können weiterhin bearbeitet werden (US-209), inkl. Szenen- und Coaching-Notizen
- [x] In der Spielliste wird ein abgeschlossenes Spiel als „Beendet" gekennzeichnet
- [x] Tap auf ein abgeschlossenes Spiel in der Spielliste öffnet direkt die Nachbereitung (Review) statt des Live-Screens
