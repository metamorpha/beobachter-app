import 'package:beobachter_app/core/pressebericht_csv_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Minimal valid CSV row matching the real Pressebericht format
  const _header =
      'Spielberichtsnummer;Bearbeitungsstatus;Bearbeiter;Hinweise-Fehler;'
      'Liganame;Spieltag;Spielnummer;Spieltyp;Spieldatum;Anstoßzeit;Stadion;Ort;'
      'Schiedsrichter;Assistent-1;Assistent-2;Vierter-Offizieller;'
      'Heimmannschaft;H-Trainer;H-Trainerassistent;H-Torwarttrainer;H-Arzt;'
      'H-Physiotherapeut;H-Doping-Beauftragter;H-Mannschaftsverantwortlicher;'
      'H-Betreuer;H-2.-Betreuer;H-Zeugwart;H-Offizieller;H-2.-Offizieller;'
      'H-Leiter-Ordnungsdienst;H-Weiterer-Offizieller;'
      'H-S1-Nr;H-S1-Spieler;H-S1-Hinweis;H-S1-Status;'
      'H-S2-Nr;H-S2-Spieler;H-S2-Hinweis;H-S2-Status;'
      'H-S3-Nr;H-S3-Spieler;H-S3-Hinweis;H-S3-Status;'
      'H-S4-Nr;H-S4-Spieler;H-S4-Hinweis;H-S4-Status;'
      'H-S5-Nr;H-S5-Spieler;H-S5-Hinweis;H-S5-Status;'
      'H-S6-Nr;H-S6-Spieler;H-S6-Hinweis;H-S6-Status;'
      'H-S7-Nr;H-S7-Spieler;H-S7-Hinweis;H-S7-Status;'
      'H-S8-Nr;H-S8-Spieler;H-S8-Hinweis;H-S8-Status;'
      'H-S9-Nr;H-S9-Spieler;H-S9-Hinweis;H-S9-Status;'
      'H-S10-Nr;H-S10-Spieler;H-S10-Hinweis;H-S10-Status;'
      'H-S11-Nr;H-S11-Spieler;H-S11-Hinweis;H-S11-Status;'
      'H-A1-Nr;H-A1-Spieler;H-A1-Hinweis;H-A1-Status;'
      'H-A2-Nr;H-A2-Spieler;H-A2-Hinweis;H-A2-Status;'
      'H-A3-Nr;H-A3-Spieler;H-A3-Hinweis;H-A3-Status;'
      'H-A4-Nr;H-A4-Spieler;H-A4-Hinweis;H-A4-Status;'
      'H-A5-Nr;H-A5-Spieler;H-A5-Hinweis;H-A5-Status;'
      'H-A6-Nr;H-A6-Spieler;H-A6-Hinweis;H-A6-Status;'
      'H-A7-Nr;H-A7-Spieler;H-A7-Hinweis;H-A7-Status;'
      'H-A8-Nr;H-A8-Spieler;H-A8-Hinweis;H-A8-Status;'
      'H-A9-Nr;H-A9-Spieler;H-A9-Hinweis;H-A9-Status;'
      'Gastmannschaft;G-Trainer;G-Trainerassistent;G-Torwarttrainer;G-Arzt;'
      'G-Physiotherapeut;G-Doping-Beauftragter;G-Mannschaftsverantwortlicher;'
      'G-Betreuer;G-2.-Betreuer;G-Zeugwart;G-Offizieller;G-2.-Offizieller;'
      'G-Leiter-Ordnungsdienst;G-Weiterer-Offizieller;'
      'G-S1-Nr;G-S1-Spieler;G-S1-Hinweis;G-S1-Status;'
      'G-S2-Nr;G-S2-Spieler;G-S2-Hinweis;G-S2-Status;'
      'G-S3-Nr;G-S3-Spieler;G-S3-Hinweis;G-S3-Status;'
      'G-S4-Nr;G-S4-Spieler;G-S4-Hinweis;G-S4-Status;'
      'G-S5-Nr;G-S5-Spieler;G-S5-Hinweis;G-S5-Status;'
      'G-S6-Nr;G-S6-Spieler;G-S6-Hinweis;G-S6-Status;'
      'G-S7-Nr;G-S7-Spieler;G-S7-Hinweis;G-S7-Status;'
      'G-S8-Nr;G-S8-Spieler;G-S8-Hinweis;G-S8-Status;'
      'G-S9-Nr;G-S9-Spieler;G-S9-Hinweis;G-S9-Status;'
      'G-S10-Nr;G-S10-Spieler;G-S10-Hinweis;G-S10-Status;'
      'G-S11-Nr;G-S11-Spieler;G-S11-Hinweis;G-S11-Status;'
      'G-A1-Nr;G-A1-Spieler;G-A1-Hinweis;G-A1-Status;'
      'G-A2-Nr;G-A2-Spieler;G-A2-Hinweis;G-A2-Status;'
      'G-A3-Nr;G-A3-Spieler;G-A3-Hinweis;G-A3-Status;'
      'G-A4-Nr;G-A4-Spieler;G-A4-Hinweis;G-A4-Status;'
      'G-A5-Nr;G-A5-Spieler;G-A5-Hinweis;G-A5-Status;'
      'G-A6-Nr;G-A6-Spieler;G-A6-Hinweis;G-A6-Status;'
      'G-A7-Nr;G-A7-Spieler;G-A7-Hinweis;G-A7-Status;'
      'G-A8-Nr;G-A8-Spieler;G-A8-Hinweis;G-A8-Status;'
      'G-A9-Nr;G-A9-Spieler;G-A9-Hinweis;G-A9-Status';

  // Build a data row with the given overrides; all other fields empty.
  String _dataRow({
    String spielbericht = '1',
    String liganame = 'Testliga',
    String spieltag = '5',
    String spieldatum = '15.06.2026',
    String anstosszeit = '15:30',
    String stadion = 'Teststadion',
    String ort = 'Teststadt',
    String heim = 'FC Heim',
    String gast = 'SC Gast',
    List<String> heimStartelf = const [],
    List<String> heimAuswechsler = const [],
    List<String> gastStartelf = const [],
    List<String> gastAuswechsler = const [],
  }) {
    final cols = _header.split(';');
    final vals = List<String>.filled(cols.length, '');

    void set(String key, String val) {
      final idx = cols.indexOf(key);
      if (idx >= 0) vals[idx] = val;
    }

    set('Spielberichtsnummer', spielbericht);
    set('Liganame', liganame);
    set('Spieltag', spieltag);
    set('Spieldatum', spieldatum);
    set('Anstoßzeit', anstosszeit);
    set('Stadion', stadion);
    set('Ort', ort);
    set('Heimmannschaft', heim);
    set('Gastmannschaft', gast);

    for (int i = 0; i < heimStartelf.length && i < 11; i++) {
      set('H-S${i + 1}-Nr', heimStartelf[i]);
    }
    for (int i = 0; i < heimAuswechsler.length && i < 9; i++) {
      set('H-A${i + 1}-Nr', heimAuswechsler[i]);
    }
    for (int i = 0; i < gastStartelf.length && i < 11; i++) {
      set('G-S${i + 1}-Nr', gastStartelf[i]);
    }
    for (int i = 0; i < gastAuswechsler.length && i < 9; i++) {
      set('G-A${i + 1}-Nr', gastAuswechsler[i]);
    }

    return vals.join(';');
  }

  String _csv({
    String? customHeader,
    String? customData,
    String heim = 'FC Heim',
    String gast = 'SC Gast',
    String liganame = 'Testliga',
    String spieltag = '5',
    String spieldatum = '15.06.2026',
    String anstosszeit = '15:30',
    String stadion = 'Teststadion',
    String ort = 'Teststadt',
    List<String> heimStartelf = const [],
    List<String> heimAuswechsler = const [],
    List<String> gastStartelf = const [],
    List<String> gastAuswechsler = const [],
  }) {
    final header = customHeader ?? _header;
    final data = customData ??
        _dataRow(
          heim: heim,
          gast: gast,
          liganame: liganame,
          spieltag: spieltag,
          spieldatum: spieldatum,
          anstosszeit: anstosszeit,
          stadion: stadion,
          ort: ort,
          heimStartelf: heimStartelf,
          heimAuswechsler: heimAuswechsler,
          gastStartelf: gastStartelf,
          gastAuswechsler: gastAuswechsler,
        );
    return '$header\n$data\n';
  }

  group('PresskBerichtCsvParser', () {
    group('Teamnamen', () {
      test('importiert Heim- und Gastmannschaft', () {
        final result = PresskBerichtCsvParser.parse(
            _csv(heim: 'DJK TuS Hordel', gast: 'SC Westfalia Herne'));
        expect(result.homeTeamName, 'DJK TuS Hordel');
        expect(result.awayTeamName, 'SC Westfalia Herne');
      });

      test('wirft CsvFormatException wenn beide Teamnamen fehlen', () {
        expect(
          () => PresskBerichtCsvParser.parse(_csv(heim: '', gast: '')),
          throwsA(isA<CsvFormatException>()),
        );
      });

      test('importiert auch wenn nur Heimteam vorhanden', () {
        final result = PresskBerichtCsvParser.parse(_csv(heim: 'FC Test', gast: ''));
        expect(result.homeTeamName, 'FC Test');
        expect(result.awayTeamName, isNull);
      });
    });

    group('Meta-Daten', () {
      test('importiert Liga und Spieltag', () {
        final result = PresskBerichtCsvParser.parse(
            _csv(liganame: 'Westfalenliga Staffel 2', spieltag: '23'));
        expect(result.liga, 'Westfalenliga Staffel 2');
        expect(result.spieltag, '23');
      });

      test('importiert Datum und Uhrzeit korrekt', () {
        final result = PresskBerichtCsvParser.parse(
            _csv(spieldatum: '11.04.2026', anstosszeit: '18:00'));
        expect(result.date, DateTime(2026, 4, 11, 18, 0));
      });

      test('gibt null für Datum zurück wenn Format ungültig', () {
        final result =
            PresskBerichtCsvParser.parse(_csv(spieldatum: '32.13.2026'));
        expect(result.date, isNull);
      });

      test('kombiniert Stadion und Ort zu location', () {
        final result = PresskBerichtCsvParser.parse(
            _csv(stadion: 'Hordeler Heide', ort: 'Bochum'));
        expect(result.location, 'Hordeler Heide, Bochum');
      });

      test('gibt nur Ort zurück wenn Stadion leer', () {
        final result =
            PresskBerichtCsvParser.parse(_csv(stadion: '', ort: 'Bochum'));
        expect(result.location, 'Bochum');
      });

      test('gibt null für location zurück wenn beides leer', () {
        final result =
            PresskBerichtCsvParser.parse(_csv(stadion: '', ort: ''));
        expect(result.location, isNull);
      });
    });

    group('Spielernummern Heim', () {
      test('importiert Startelf (S1–S11)', () {
        final result = PresskBerichtCsvParser.parse(
            _csv(heimStartelf: ['21', '4', '5', '10', '14', '16', '17', '22', '23', '27', '29']));
        expect(result.homeNumbers, containsAll([4, 5, 10, 14, 16, 17, 21, 22, 23, 27, 29]));
        expect(result.homeNumbers.length, 11);
      });

      test('importiert Auswechsler (A1–A9)', () {
        final result = PresskBerichtCsvParser.parse(
            _csv(heimAuswechsler: ['1', '6', '7', '9', '11']));
        expect(result.homeNumbers, containsAll([1, 6, 7, 9, 11]));
      });

      test('importiert Startelf + Auswechsler zusammen (bis 20 Spieler)', () {
        final startelf = List.generate(11, (i) => '${i + 1}');
        final bank = List.generate(9, (i) => '${i + 12}');
        final result = PresskBerichtCsvParser.parse(
            _csv(heimStartelf: startelf, heimAuswechsler: bank));
        expect(result.homeNumbers.length, 20);
      });

      test('ignoriert Nummern außerhalb 1–99', () {
        final result = PresskBerichtCsvParser.parse(
            _csv(heimStartelf: ['0', '100', '50']));
        expect(result.homeNumbers, [50]);
      });

      test('ignoriert nicht-numerische Werte (TW, C, leer)', () {
        final result = PresskBerichtCsvParser.parse(
            _csv(heimStartelf: ['TW', 'C', '', '9']));
        expect(result.homeNumbers, [9]);
      });

      test('dedupliziert doppelte Nummern', () {
        final result = PresskBerichtCsvParser.parse(
            _csv(heimStartelf: ['10', '10'], heimAuswechsler: ['10']));
        expect(result.homeNumbers.where((n) => n == 10).length, 1);
      });

      test('gibt sortierte Liste zurück', () {
        final result = PresskBerichtCsvParser.parse(
            _csv(heimStartelf: ['9', '1', '5']));
        expect(result.homeNumbers, [1, 5, 9]);
      });
    });

    group('Spielernummern Gast', () {
      test('importiert Gast-Startelf korrekt', () {
        final result = PresskBerichtCsvParser.parse(
            _csv(gastStartelf: ['44', '4', '6', '9', '10']));
        expect(result.awayNumbers, containsAll([4, 6, 9, 10, 44]));
      });

      test('importiert Gast-Auswechsler korrekt', () {
        final result = PresskBerichtCsvParser.parse(
            _csv(gastAuswechsler: ['2', '5', '7']));
        expect(result.awayNumbers, containsAll([2, 5, 7]));
      });
    });

    group('Warnungen', () {
      test('keine Warnungen bei vollständigem Import', () {
        final result = PresskBerichtCsvParser.parse(_csv(
          heimStartelf: ['1', '2', '3'],
          gastStartelf: ['4', '5', '6'],
        ));
        expect(result.warnings, isEmpty);
      });

      test('warnt wenn Aufstellung Heim leer (aber Spalte vorhanden)', () {
        final result = PresskBerichtCsvParser.parse(_csv());
        expect(result.warnings, contains('Aufstellung Heim'));
      });

      test('warnt wenn Aufstellung Gast leer (aber Spalte vorhanden)', () {
        final result = PresskBerichtCsvParser.parse(_csv());
        expect(result.warnings, contains('Aufstellung Gast'));
      });
    });

    group('Fehlerbehandlung', () {
      test('wirft CsvFormatException bei leerer Datei', () {
        expect(
          () => PresskBerichtCsvParser.parse(''),
          throwsA(isA<CsvFormatException>()),
        );
      });

      test('wirft CsvFormatException bei nur einer Zeile', () {
        expect(
          () => PresskBerichtCsvParser.parse(_header),
          throwsA(isA<CsvFormatException>()),
        );
      });

      test('toleriert Windows-Zeilenenden CRLF', () {
        final csv = _csv(heim: 'FC Test', gast: 'SC Test').replaceAll('\n', '\r\n');
        final result = PresskBerichtCsvParser.parse(csv);
        expect(result.homeTeamName, 'FC Test');
      });

      test('toleriert quoted Felder mit Semikolon drin', () {
        final cols = _header.split(';');
        final vals = List<String>.filled(cols.length, '');
        vals[cols.indexOf('Heimmannschaft')] = '"FC;Test"';
        vals[cols.indexOf('Gastmannschaft')] = 'SC Gast';
        final csv = '$_header\n${vals.join(';')}\n';
        final result = PresskBerichtCsvParser.parse(csv);
        expect(result.homeTeamName, 'FC;Test');
      });

      test('wirft keine Exception bei mehr als 2 Zeilen (nimmt erste Datenzeile)', () {
        final csv = '${_csv(heim: 'Team A', gast: 'Team B')}'
            '${_dataRow(heim: 'Team C', gast: 'Team D')}\n';
        final result = PresskBerichtCsvParser.parse(csv);
        expect(result.homeTeamName, 'Team A');
      });
    });
  });
}
