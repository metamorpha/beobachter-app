enum GamePhase {
  bereit,
  ersteHalbzeit,
  ersteHalbzeitNachspielzeit,
  halbzeit,
  zweiteHalbzeit,
  zweiteHalbzeitNachspielzeit,
  beendet,
  verlaengerungErsteHalbzeit,
  verlaengerungErsteHalbzeitNachspielzeit,
  verlaengerungHalbzeit,
  verlaengerungZweiteHalbzeit,
  verlaengerungZweiteHalbzeitNachspielzeit,
  beendetVerlaengerung,
}

extension GamePhaseX on GamePhase {
  String get label {
    switch (this) {
      case GamePhase.bereit:
        return '';
      case GamePhase.ersteHalbzeit:
        return '1. Halbzeit';
      case GamePhase.ersteHalbzeitNachspielzeit:
        return 'Nachspielzeit';
      case GamePhase.halbzeit:
        return 'Halbzeitpause';
      case GamePhase.zweiteHalbzeit:
        return '2. Halbzeit';
      case GamePhase.zweiteHalbzeitNachspielzeit:
        return 'Nachspielzeit';
      case GamePhase.beendet:
        return 'Beendet';
      case GamePhase.verlaengerungErsteHalbzeit:
        return 'Verl. 1. HZ';
      case GamePhase.verlaengerungErsteHalbzeitNachspielzeit:
        return 'Nachspielzeit';
      case GamePhase.verlaengerungHalbzeit:
        return 'Verl. Halbzeit';
      case GamePhase.verlaengerungZweiteHalbzeit:
        return 'Verl. 2. HZ';
      case GamePhase.verlaengerungZweiteHalbzeitNachspielzeit:
        return 'Nachspielzeit';
      case GamePhase.beendetVerlaengerung:
        return 'Beendet';
    }
  }

  /// MS-Schwelle, ab der diese Phase automatisch in die Nachspielzeit wechselt.
  int? get nachspielzeitSchwelle {
    switch (this) {
      case GamePhase.ersteHalbzeit:
        return 45 * 60 * 1000;
      case GamePhase.zweiteHalbzeit:
        return 90 * 60 * 1000;
      case GamePhase.verlaengerungErsteHalbzeit:
        return 105 * 60 * 1000;
      case GamePhase.verlaengerungZweiteHalbzeit:
        return 120 * 60 * 1000;
      default:
        return null;
    }
  }

  /// Nachspielzeit-Phase, die nach Erreichen der Schwelle folgt.
  GamePhase? get nachspielzeitPhase {
    switch (this) {
      case GamePhase.ersteHalbzeit:
        return GamePhase.ersteHalbzeitNachspielzeit;
      case GamePhase.zweiteHalbzeit:
        return GamePhase.zweiteHalbzeitNachspielzeit;
      case GamePhase.verlaengerungErsteHalbzeit:
        return GamePhase.verlaengerungErsteHalbzeitNachspielzeit;
      case GamePhase.verlaengerungZweiteHalbzeit:
        return GamePhase.verlaengerungZweiteHalbzeitNachspielzeit;
      default:
        return null;
    }
  }

  /// Formatiert [ms] phasengerecht als Anzeigestring.
  static String formatMs(int ms, GamePhase phase) {
    switch (phase) {
      case GamePhase.ersteHalbzeitNachspielzeit:
        final extra = (ms - 45 * 60 * 1000) ~/ 60000 + 1;
        return '45+${extra.toString().padLeft(2, '0')}';
      case GamePhase.zweiteHalbzeitNachspielzeit:
        final extra = (ms - 90 * 60 * 1000) ~/ 60000 + 1;
        return '90+${extra.toString().padLeft(2, '0')}';
      case GamePhase.verlaengerungErsteHalbzeitNachspielzeit:
        final extra = (ms - 105 * 60 * 1000) ~/ 60000 + 1;
        return '105+${extra.toString().padLeft(2, '0')}';
      case GamePhase.verlaengerungZweiteHalbzeitNachspielzeit:
        final extra = (ms - 120 * 60 * 1000) ~/ 60000 + 1;
        return '120+${extra.toString().padLeft(2, '0')}';
      default:
        final minutes = ms ~/ 60000;
        final seconds = (ms % 60000) ~/ 1000;
        return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
