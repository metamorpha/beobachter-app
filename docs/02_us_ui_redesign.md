# User Stories — Epic 6: UI-Modernisierung

> Fokus: moderne, gut lesbare Oberfläche mit Bedienelementen in Daumenreichweite und flüssigen Übergängen.
> Gerät: Tablet, Querformat, überwiegend draußen bei Tageslicht.
> Rahmen: Businesslogik, Persistenz und Navigation bleiben unverändert. Plan und Begründungen: [`23_ui_redesign_plan.md`](23_ui_redesign_plan.md).

**Gilt für alle Stories dieses Epics:**
- [x] Unter `domain/`, `data/` und `core/` sowie in `providers.dart` ändert sich keine Zeile
- [x] Screens, Routen, Dialoge und Tabs sind dieselben wie vorher, nur das Aussehen ändert sich
- [x] Alle Widget-Keys und alle UI-Texte bleiben erhalten
- [x] `flutter analyze` ist fehlerfrei, alle bestehenden Tests sind grün (angepasst werden nur Finder nach Widget-Typ oder Icon, nie die Erwartung)
  *Umsetzung: `ElevatedButton` → `FilledButton` in 5 Findern. Zusätzlich zwei Testschritte ohne Änderung der Erwartung: TC-1101 sucht den Titel „Aufstellung" jetzt im Dialog (der neue Button trägt dieselbe Beschriftung), TC-EFR-05 scrollt den Coaching-Stern per `ensureVisible` ins Bild (größere Felder).*
- [x] Es gibt keine Vibration und kein haptisches Feedback

---

### US-601 · Einheitliches helles Design

**Als** Schiedsrichterbeobachter  
**möchte ich**, dass alle Screens ein einheitliches, helles Design mit hohem Kontrast haben,  
**damit** ich die App draußen bei Sonnenlicht gut ablesen kann und sie sich wie aus einem Guss anfühlt.

**Akzeptanzkriterien:**
- [x] Alle Screens, auch der Live-Screen, nutzen dasselbe helle Theme; es gibt kein Dark Theme
- [x] Farben, Schriftgrößen, Abstände und Radien kommen zentral aus `presentation/theme/`; Screens und Widgets enthalten keine hartkodierten `Colors.*` mehr (Ausnahme: transparente Overlays im Spielfeld-Rendering)
  *Hinweis: Einzelne Schriftgrößen sind bewusst direkt gesetzt: Uhr (34 pt), Spielstand (30 pt) und die Ereignisliste (14 pt, von TC-2136 gefordert). Die Typ-Markerfarben stehen in `theme/event_type_style.dart`.*
- [x] Farbe trägt feste Bedeutung und ist überall gleich: Heim, Gast, korrekt, falsch, Gelb, Gelb-Rot, Rot, Coaching
- [x] Als Schrift wird Inter verwendet, als Asset gebündelt; die App lädt zur Laufzeit nichts aus dem Netz
- [x] Uhr, Spielstand und Rückennummern nutzen gleich breite Ziffern
- [x] Text hat mindestens 4,5:1 Kontrast zum Hintergrund (geprüft mit `textContrastGuideline`)
- [x] Fließtext ist mindestens 14 pt groß, Beschriftungen mindestens 12 pt

---

### US-602 · Live-Screen: Bedienung in Daumenreichweite

**Als** Schiedsrichterbeobachter  
**möchte ich** die Spieluhr, die Aufstellung und die Szenenliste mit dem linken Daumen bedienen können, während ich das Tablet quer halte,  
**damit** ich unter Zeitdruck nicht umgreifen und nicht suchen muss.

**Akzeptanzkriterien:**
- [x] Oben steht eine schlanke Leiste nur zur Anzeige: Heimteam, Spielstand, Gastteam, Spielphase und Uhr
- [x] Die Phasen-Buttons (Start, Halbzeit, 2. HZ starten, Abpfiff, Verlängerung, Spiel beenden usw.) stehen in einer Aktionsleiste **unten links** unter dem Spielfeld
- [x] Der jeweilige Phasen-Button ist mindestens 64 dp hoch und 160 dp breit; seine Farbe zeigt die Art der Aktion (Start, Pause, Ende)
- [x] „Aufstellung" und „Szenen" stehen als beschriftete Buttons (Icon + Text, mindestens 56 dp) in derselben Aktionsleiste
- [x] Phasenwechsel, Bestätigungsdialog bei „Spiel beenden" und gesperrte Erfassung nach Spielende verhalten sich wie bisher
- [x] Solange die Uhr läuft, zeigt die Phasenanzeige das durch einen dezent pulsierenden Punkt
- [x] Das Spielfeld zeigt Rasenstreifen; Marker haben die Farbe ihres Ereignistyps
- [x] Ein Tap aufs Spielfeld gibt sofort sichtbare Rückmeldung an der Tap-Stelle
- [x] In der Ereignisliste im Seitenpanel ist jede Zeile mindestens 56 dp hoch, das Lösch-Icon hat eine Tippfläche von mindestens 48 × 48 dp und bleibt dauerhaft sichtbar

---

### US-603 · Erfassungsformular mit großen Auswahlflächen

**Als** Schiedsrichterbeobachter  
**möchte ich** Ereignistyp, Spieler, Entscheidung und Bewertung über große, gut lesbare Flächen auswählen,  
**damit** ich auch mit abgelenktem Blick sicher treffe und ein Ereignis weiterhin in unter 10 Sekunden erfasse.

**Akzeptanzkriterien:**
- [x] Felder, Reihenfolge, Pflichtfelder und Speicherlogik des Formulars bleiben unverändert (auch im Bearbeiten-Modus aus US-209)
- [x] Ereignistypen erscheinen als Raster aus Kacheln mit Icon und Label, jede Kachel mindestens 56 dp hoch
- [x] Schiedsrichterentscheidungen erscheinen als Raster mit Tippflächen von mindestens 56 dp
- [x] Heim/Gast wird über einen Umschalter mit mindestens 56 dp Höhe gewählt
- [x] Rückennummern-Chips haben eine Tippfläche von mindestens 48 × 48 dp
- [x] Die Bewertungsfelder (2 × 2) sind mindestens 64 dp hoch und auch ohne Farbe am Symbol (✓/✗) unterscheidbar
- [x] Eine Auswahl wird sofort durch Farbwechsel und eine kurze Größenanimation bestätigt
- [x] „Speichern" steht fest unten rechts im Panel (scrollt nicht weg), ist mindestens 64 dp hoch und zeigt deutlich, ob Speichern möglich ist
- [x] Nach dem Speichern bestätigt eine kurze Animation den Vorgang, dann schließt das Panel
  *Umsetzung: Das Panel schließt sofort (kein Warten unter Zeitdruck). Gleichzeitig blendet über dem Spielfeld „Ereignis gespeichert" ein und der neue Marker ploppt auf.*

---

### US-604 · Spielliste und Spiel-Setup modernisieren

**Als** Schiedsrichterbeobachter  
**möchte ich** meine Spiele als übersichtliche Karten sehen und ein Spiel auf einem aufgeräumten Setup-Screen vorbereiten,  
**damit** ich vor dem Anpfiff schnell starte und nichts suchen muss.

**Akzeptanzkriterien:**

*Spielliste*
- [x] Spiele erscheinen als Karten in einem zweispaltigen Raster (Querformat)
- [x] Jede Karte zeigt Heim- und Gastteam groß, darunter Datum, Liga und Spieltag; vorhandene Phasen-Badges („Läuft", „Beendet") bleiben erhalten
  *Hinweis: Die Paarung steht als eine Zeile „Heim – Gast" (die Integrationstests suchen genau diesen Text). Zusätzlich zeigt die Karte den Spielstand, sobald das Spiel läuft.*
- [x] Das Badge „Läuft" pulsiert dezent
  *Umsetzung: dreimal nach dem Erscheinen, dann ruhig — eine Endlos-Animation würde die Liste nie zur Ruhe kommen lassen.*
- [x] Ohne Spiele erscheint ein gestalteter Leer-Zustand mit Hinweis auf „Neues Spiel"
- [x] „Neues Spiel" bleibt als Button unten rechts, mindestens 56 dp hoch
- [x] Das Lösch-Icon bleibt dauerhaft sichtbar (US-106), Tippfläche mindestens 48 × 48 dp

*Spiel-Setup*
- [x] Spieldaten stehen links, die Aufstellungen beider Teams rechts (zwei Spalten)
- [x] Der CSV-Import steht als hervorgehobene Karte ganz oben
- [x] „Spiel starten" steht in einer fest sichtbaren Leiste unten rechts und muss nicht erst per Scrollen gesucht werden
- [x] Import-Warnungen erscheinen als Banner im neuen Design; Inhalt und Verhalten bleiben gleich

---

### US-605 · Nachbereitung und Statistik als Dashboard

**Als** Schiedsrichterbeobachter  
**möchte ich** Szenen, Coaching-Notizen und Statistiken übersichtlich in Karten sehen,  
**damit** ich das Coaching-Gespräch schnell vorbereite und Auffälligkeiten auf einen Blick erkenne.

**Akzeptanzkriterien:**
- [x] Die drei Tabs Szenen, Coaching und Statistik bleiben; der aktive Tab ist klar hervorgehoben
- [x] Szenen erscheinen als Karten mit Zeit-Badge, Typ, Entscheidung, Bewertung und Karten-Symbol
- [x] Bearbeiten und Coaching-Stern haben Tippflächen von mindestens 48 × 48 dp
- [x] Filter erscheinen als Chips; aktive Filter sind klar sichtbar und einzeln entfernbar (wie US-302)
- [x] In der Coaching-Ansicht steht die allgemeine Notiz als eigene Karte oben; jede Szene zeigt ihre Szenennotiz und darunter die bearbeitbare Coaching-Notiz
- [x] Die Statistik ist ein 2 × 2-Dashboard aus Karten: Heatmap, Zeitachse, Spieler-Ranking, Vergehen pro Team
- [x] Die Zeitachse ist ein Balkendiagramm (eigener Painter, keine neue Bibliothek); Werte und Phasen bleiben dieselben
  *Umsetzung: mit Flutter-Widgets statt `CustomPainter` gebaut, damit Werte und Beschriftungen als Text lesbar und testbar bleiben. Keine neue Bibliothek.*
- [x] Der Bearbeiten-Dialog für Szenen bleibt ein Dialog und nutzt das neue Formular-Design aus US-603

---

### US-606 · Flüssige Übergänge

**Als** Schiedsrichterbeobachter  
**möchte ich**, dass Screens, Panels und Auswahlen weich wechseln statt hart umzuspringen,  
**damit** ich jederzeit sehe, was gerade passiert, und die App sich hochwertig anfühlt.

**Akzeptanzkriterien:**
- [x] Seitenwechsel blenden über (ca. 350 ms)
  *Hinweis: Auf iOS bleibt der native Seitenwechsel mit Wisch-zurück-Geste erhalten (Navigation unverändert).*
- [x] Das Erfassungsformular gleitet von rechts ein und wieder hinaus (ca. 250 ms); das Spielfeld wird dabei weich abgedunkelt
- [x] Ein neuer Marker auf dem Spielfeld erscheint mit kurzer Einblend-Animation
- [x] Phasen-Button wechselt Farbe und Beschriftung animiert
- [x] Balken der Zeitachse wachsen beim Öffnen der Statistik hoch
- [x] Die Hervorhebung des Spielstands bei einem Tor bleibt erhalten (US-214)
- [x] Keine Animation verzögert eine Eingabe: Taps werden sofort angenommen, auch während eine Animation läuft
- [x] Ist in den Systemeinstellungen „Bewegung reduzieren" aktiv, entfallen die Animationen
