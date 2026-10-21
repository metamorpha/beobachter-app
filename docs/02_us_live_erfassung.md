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

---

### US-213 · Ereignisliste im Live-Seitenpanel

**Als** Schiedsrichterbeobachter  
**möchte ich** im Seitenpanel des Live-Screens so viele erfasste Ereignisse sehen, wie mein Bildschirm Platz bietet, und diese sicher antippen können,  
**damit** ich auch während des Spiels den Überblick über alle Szenen behalte und unter Zeitdruck nicht versehentlich das falsche Ereignis lösche.

**Akzeptanzkriterien:**

*Länge der Liste*
- [x] Das Seitenpanel „Letzte Ereignisse" zeigt alle Ereignisse des Spiels — nicht mehr nur die letzten 5
- [x] Die Liste füllt die gesamte verfügbare Höhe des Panels; die Anzahl sichtbarer Zeilen ergibt sich aus der Bildschirmhöhe
- [x] Passen nicht alle Ereignisse in das Panel, ist die Liste vertikal scrollbar; Überschrift „Letzte Ereignisse" und Trennlinie bleiben dabei fest stehen
- [x] Das neueste Ereignis steht oben; ein neu gespeichertes Ereignis erscheint sofort oben in der Liste
- [x] Ohne Ereignisse zeigt das Panel nur Überschrift und Trennlinie (kein Fehler, kein Platzhalter-Layoutbruch)

*Zeilengröße / Fehltipp-Schutz*
- [x] Jede Zeile hat eine Mindesthöhe von 44 dp (bisher ca. 18 dp)
- [x] Zwischen den Zeilen trennt eine dezente Linie, damit die Zeilen optisch klar unterscheidbar sind
- [x] Schriftgröße von Zeitstempel und Ereignistyp steigt von 12 auf 14
- [x] Der Lösch-Button hat eine Tippfläche von mindestens 44 × 44 dp (Icon 22 dp), auch wenn das Icon selbst kleiner wirkt
- [x] Die Panelbreite (200 dp) bleibt unverändert; lange Ereignistypen werden weiterhin mit „…" gekürzt

*Bestehendes Verhalten bleibt erhalten*
- [x] Der Lösch-Button entfernt das Ereignis wie bisher; die Liste aktualisiert sich sofort
- [x] Im abgeschlossenen Spiel (US-212) bleibt die Liste sichtbar

---

### US-214 · Spielstand und Torschütze

**Als** Schiedsrichterbeobachter  
**möchte ich** bei einer Torentscheidung den Torschützen (inkl. Eigentor) erfassen und den aktuellen Spielstand jederzeit unter den Mannschaftsnamen sehen,  
**damit** ich den Spielverlauf ohne eigene Strichliste im Blick behalte.

**Akzeptanzkriterien:**

*Zählregel*
- [x] Ein Ereignis zählt für den Spielstand genau dann, wenn Typ = **Torentscheidung**, Entscheidung = **Tor** und ein Torschützen-Team gewählt ist
- [x] Ohne Eigentor wird das Tor dem Team des Torschützen gutgeschrieben, bei **Eigentor** dem gegnerischen Team
- [x] Torentscheidungen mit anderer Entscheidung (z. B. Indir. FS wegen Abseits) gelten als aberkannt und ändern den Spielstand nicht
- [x] Bestehende Torentscheidungen ohne Torschützen-Team (vor diesem Feature erfasst) zählen nicht und verursachen keinen Fehler

*Erfassung im Ereignisformular*
- [x] Bei Typ Torentscheidung erscheint ein Abschnitt **„Tor"** an der Stelle, an der bei Vergehen der Abschnitt „Spieler" steht
- [x] Beim Wählen von Torentscheidung ist die Entscheidung **„Tor"** vorausgewählt; sie kann abgewählt oder durch eine andere ersetzt werden
- [x] Torschütze: Team-Auswahl Heim/Gast, dann Rückennummer per Kader-Chip oder Zahleneingabe — Bedienung identisch zu Fouler/Gefoulter
- [x] Die Rückennummer ist optional; für den Spielstand genügt das Team
- [x] Ein Schalter **„Eigentor"** kennzeichnet das Tor als Eigentor; Team und Nummer bezeichnen dabei den Spieler, der das Tor verursacht hat
- [x] Eine Vorschau-Zeile zeigt vor dem Speichern das Ergebnis:
  - Tor zählt: „Tor für HEIM · #9 → 2 : 1"
  - Eigentor: „Eigentor #4 (Heim) → Tor für GAST · 1 : 2"
  - Entscheidung ≠ Tor: „Tor aberkannt – Spielstand bleibt 1 : 1" (grau)
  - Entscheidung = Tor, aber kein Team: „Team wählen, damit das Tor zählt" (orange)
- [x] Speichern ist auch ohne Torschützen-Team möglich (kein Blockieren unter Zeitdruck)
- [x] Wechselt der Typ von Torentscheidung zu einem anderen Typ, werden Torschütze und Eigentor verworfen

*Spielstand im Live-Screen*
- [x] Unter den Mannschaftsnamen in der Kopfzeile steht der aktuelle Spielstand im Format „2 : 1" (groß, fett, gleich breite Ziffern)
- [x] Ohne gezählte Tore zeigt die Kopfzeile „0 : 0"
- [x] Der Spielstand aktualisiert sich sofort nach Speichern, Bearbeiten, Löschen und Rückgängig-Machen eines Ereignisses *(Hinweis: Eine Undo-SnackBar existiert im Code aktuell nicht — Rückgängig entspricht dem Löschen und ist damit abgedeckt)*
- [x] Ändert sich der Spielstand, wird er kurz (ca. 0,6 s) hervorgehoben
- [x] Im Seitenpanel „Letzte Ereignisse" zeigt ein gezähltes Tor „⚽ Tor 2:1" (Spielstand nach diesem Tor) statt „Torentsch."; aberkannte Tore behalten „Torentsch."

*Bearbeiten & Persistenz*
- [x] Beim nachträglichen Bearbeiten (US-209) sind Torschützen-Team, Nummer und Eigentor vorausgefüllt; Änderungen wirken sich sofort auf den Spielstand aus
- [x] Torschützen-Team, Nummer und Eigentor werden lokal gespeichert und überleben einen App-Neustart
- [x] Die DB-Migration (Schema v4 → v5) erhält alle bestehenden Spiele und Ereignisse
- [x] Torschützen erscheinen nicht im Spieler-Ranking der Statistik
