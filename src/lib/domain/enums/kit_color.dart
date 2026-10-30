/// Trikotfarbe eines Teams — feste Palette, eine Farbe pro Team (US-111).
enum KitColor {
  white,
  black,
  grey,
  red,
  burgundy,
  orange,
  yellow,
  green,
  lightBlue,
  blue,
  purple,
}

extension KitColorLabel on KitColor {
  String get label => switch (this) {
    KitColor.white => 'Weiß',
    KitColor.black => 'Schwarz',
    KitColor.grey => 'Grau',
    KitColor.red => 'Rot',
    KitColor.burgundy => 'Bordeaux',
    KitColor.orange => 'Orange',
    KitColor.yellow => 'Gelb',
    KitColor.green => 'Grün',
    KitColor.lightBlue => 'Hellblau',
    KitColor.blue => 'Blau',
    KitColor.purple => 'Lila',
  };

  /// Unbekannte oder leere DB-Werte ergeben `null` → Standardfarbe.
  static KitColor? tryParse(String? name) {
    for (final k in KitColor.values) {
      if (k.name == name) return k;
    }
    return null;
  }
}
