enum CardType {
  yellow,    // Gelb
  yellowRed, // Gelb-Rot
  red,       // Rot
}

extension CardTypeLabel on CardType {
  String get label => switch (this) {
    CardType.yellow    => 'Gelb',
    CardType.yellowRed => 'GR',
    CardType.red       => 'Rot',
  };
}
