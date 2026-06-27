# User Stories — Epic 5: Datenpersistenz & Offline-Betrieb

> Fokus: minimale Interaktion pro Ereignis, so wenig Eingaben wie möglich während des Spiels.
> Gerät: Tablet, Querformat.

---

### US-501 · Automatisches lokales Speichern

**Als** Schiedsrichterbeobachter  
**möchte ich** dass jedes Ereignis sofort nach dem Speichern lokal persistiert wird,  
**damit** kein Datenverlust entsteht, auch wenn die App abstürzt oder das Gerät neu startet.

**Akzeptanzkriterien:**
- [x] Jedes Ereignis wird unmittelbar nach dem Tap auf „Speichern" in die lokale Datenbank geschrieben
- [x] Nach einem App-Neustart sind alle Daten vollständig wiederhergestellt
- [x] Es ist keine Internetverbindung erforderlich

---

### US-502 · Offline-Betrieb sicherstellen

**Als** Schiedsrichterbeobachter  
**möchte ich** die App vollständig ohne Internetverbindung nutzen können,  
**damit** ich auf Sportplätzen ohne WLAN oder Mobilfunk nicht eingeschränkt bin.

**Akzeptanzkriterien:**
- [x] Alle Funktionen (Live-Erfassung, Nachbereitung, Statistik) sind ohne Netzwerk nutzbar
- [x] Die App zeigt keine Fehler oder Einschränkungen bei fehlender Verbindung
- [x] Kein Netzwerk-Request ist für den Betrieb notwendig
