class CsvImportResult {
  final String? homeTeamName;
  final String? awayTeamName;
  final DateTime? date;
  final String? location;
  final String? liga;
  final String? spieltag;
  final List<int> homeNumbers;
  final List<int> awayNumbers;
  final List<String> warnings;

  const CsvImportResult({
    this.homeTeamName,
    this.awayTeamName,
    this.date,
    this.location,
    this.liga,
    this.spieltag,
    required this.homeNumbers,
    required this.awayNumbers,
    required this.warnings,
  });
}

class CsvFormatException implements Exception {
  final String message;
  const CsvFormatException(this.message);
  @override
  String toString() => message;
}

class PresskBerichtCsvParser {
  PresskBerichtCsvParser._();

  static CsvImportResult parse(String content) {
    // Normalize line endings and split rows
    final lines = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.length < 2) {
      throw const CsvFormatException(
          'Die Datei enthält keine Datenzeile.');
    }

    final headers = _splitRow(lines[0]);
    final values = _splitRow(lines[1]);

    if (headers.isEmpty) {
      throw const CsvFormatException('Keine Spaltenüberschriften gefunden.');
    }

    // Build lookup map: header name → value
    final Map<String, String> data = {};
    for (int i = 0; i < headers.length; i++) {
      final key = headers[i].trim();
      final val = i < values.length ? values[i].trim() : '';
      if (key.isNotEmpty) data[key] = val;
    }

    final homeTeam = _notEmpty(data['Heimmannschaft']);
    final awayTeam = _notEmpty(data['Gastmannschaft']);

    if (homeTeam == null && awayTeam == null) {
      throw const CsvFormatException(
          'Teambezeichnungen (Heimmannschaft/Gastmannschaft) nicht gefunden. '
          'Bitte eine Pressebericht-CSV auswählen.');
    }

    final warnings = <String>[];

    // Date + time
    final date = _parseDate(data['Spieldatum'], data['Anstoßzeit']);
    if (data.containsKey('Spieldatum') &&
        (data['Spieldatum']?.isNotEmpty ?? false) &&
        date == null) {
      warnings.add('Datum (ungültiges Format)');
    }

    // Location
    final location = _buildLocation(data['Stadion'], data['Ort']);

    // Liga + Spieltag
    final liga = _notEmpty(data['Liganame']);
    final spieltag = _notEmpty(data['Spieltag']);

    // Home players: S1–S11 (starting) + A1–A9 (substitutes)
    final homeNumbers = _extractNumbers(data, 'H-S', 1, 11)
      ..addAll(_extractNumbers(data, 'H-A', 1, 9));
    _dedup(homeNumbers);

    // Away players: G-S1–G-S11 + G-A1–G-A9
    final awayNumbers = _extractNumbers(data, 'G-S', 1, 11)
      ..addAll(_extractNumbers(data, 'G-A', 1, 9));
    _dedup(awayNumbers);

    if (homeNumbers.isEmpty && data.containsKey('H-S1-Nr')) {
      warnings.add('Aufstellung Heim');
    }
    if (awayNumbers.isEmpty && data.containsKey('G-S1-Nr')) {
      warnings.add('Aufstellung Gast');
    }

    return CsvImportResult(
      homeTeamName: homeTeam,
      awayTeamName: awayTeam,
      date: date,
      location: location,
      liga: liga,
      spieltag: spieltag,
      homeNumbers: homeNumbers,
      awayNumbers: awayNumbers,
      warnings: warnings,
    );
  }

  // Splits one CSV row, respecting double-quoted fields.
  static List<String> _splitRow(String row) {
    final fields = <String>[];
    final buf = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < row.length; i++) {
      final ch = row[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < row.length && row[i + 1] == '"') {
          buf.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ';' && !inQuotes) {
        fields.add(buf.toString());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    fields.add(buf.toString());
    return fields;
  }

  static List<int> _extractNumbers(
      Map<String, String> data, String prefix, int from, int to) {
    final result = <int>[];
    for (int i = from; i <= to; i++) {
      final val = data['$prefix$i-Nr']?.trim() ?? '';
      final n = int.tryParse(val);
      if (n != null && n >= 1 && n <= 99) result.add(n);
    }
    return result;
  }

  static void _dedup(List<int> list) {
    final seen = <int>{};
    list.retainWhere(seen.add);
    list.sort();
  }

  static DateTime? _parseDate(String? dateStr, String? timeStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      final parts = dateStr.split('.');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      if (month < 1 || month > 12 || day < 1 || day > 31 || year < 1900) {
        return null;
      }
      int hour = 0, minute = 0;
      if (timeStr != null && timeStr.isNotEmpty) {
        final tp = timeStr.split(':');
        if (tp.length >= 2) {
          hour = int.tryParse(tp[0]) ?? 0;
          minute = int.tryParse(tp[1]) ?? 0;
        }
      }
      return DateTime(year, month, day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  static String? _buildLocation(String? stadion, String? ort) {
    final s = stadion?.trim() ?? '';
    final o = ort?.trim() ?? '';
    if (s.isNotEmpty && o.isNotEmpty) return '$s, $o';
    if (s.isNotEmpty) return s;
    if (o.isNotEmpty) return o;
    return null;
  }

  static String? _notEmpty(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v.trim();
}
