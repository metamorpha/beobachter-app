import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';
import 'package:beobachter_app/domain/enums/kit_color.dart';
import 'package:beobachter_app/domain/repositories/game_repository.dart';
import 'package:beobachter_app/domain/repositories/squad_repository.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/game_setup/game_setup_screen.dart';

// ── Fake FilePicker ───────────────────────────────────────────────────────────

class _FakeFilePicker extends FilePicker with MockPlatformInterfaceMixin {
  final Uint8List bytes;
  final String filename;

  _FakeFilePicker({required this.bytes, required this.filename});

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    return FilePickerResult([
      PlatformFile(name: filename, size: bytes.length, bytes: bytes),
    ]);
  }
}

// ── Fake Repositories ─────────────────────────────────────────────────────────

class _FakeGameRepository implements GameRepository {
  final List<Game> _games = [];
  Game? lastUpdated;

  @override
  Future<Game> createGame(Game game) async {
    _games.add(game);
    return game;
  }

  @override
  Future<List<Game>> getGames() async => List.of(_games);

  @override
  Future<Game?> getGame(String id) async =>
      _games.where((g) => g.id == id).firstOrNull;

  @override
  Future<void> updateGame(Game game) async {
    lastUpdated = game;
    final idx = _games.indexWhere((g) => g.id == game.id);
    if (idx >= 0) _games[idx] = game;
  }

  @override
  Future<void> deleteGame(String id) async {
    _games.removeWhere((g) => g.id == id);
  }

  @override
  Future<void> updateCoachingNote(String gameId, String? note) async {}
  @override
  Future<void> updateKitColor(
    String gameId,
    TeamSide team,
    KitColor kit,
  ) async {}
}

class _FakeSquadRepository implements SquadRepository {
  final Map<String, List<int>> _squads = {};

  @override
  Future<void> saveSquad(String gameId, TeamSide team, List<int> numbers) async {
    _squads['$gameId-${team.name}'] = numbers;
  }

  @override
  Future<List<int>> getSquad(String gameId, TeamSide team) async =>
      _squads['$gameId-${team.name}'] ?? [];
}

// ── Minimales CSV ─────────────────────────────────────────────────────────────

// Baut einen minimalen, parserfähigen Pressebericht-CSV-String.
const _csvHeader =
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

String _buildCsv({
  String heim = 'FC Heim',
  String gast = 'SC Gast',
  String liganame = 'Bundesliga',
  String spieltag = '12',
  String spieldatum = '21.10.2026',
  String ort = 'Musterstadt',
}) {
  final cols = _csvHeader.split(';');
  final vals = List<String>.filled(cols.length, '');

  void set(String key, String val) {
    final idx = cols.indexOf(key);
    if (idx >= 0) vals[idx] = val;
  }

  set('Spielberichtsnummer', '1');
  set('Liganame', liganame);
  set('Spieltag', spieltag);
  set('Spieldatum', spieldatum);
  set('Ort', ort);
  set('Heimmannschaft', heim);
  set('Gastmannschaft', gast);

  return '$_csvHeader\n${vals.join(';')}';
}

// ── Hilfsfunktionen ───────────────────────────────────────────────────────────

// Neues Spiel hat leere Teamnamen — exakt wie game_list_screen es anlegt.
Game _defaultGame() => Game(
      id: 'g-setup',
      date: DateTime(2026, 10, 21),
      homeTeamName: '',
      awayTeamName: '',
      createdAt: DateTime(2026, 10, 21, 9),
    );

Widget _buildApp({
  required Game game,
  required _FakeGameRepository gameRepo,
  required _FakeSquadRepository squadRepo,
}) =>
    ProviderScope(
      overrides: [
        gameRepositoryProvider.overrideWithValue(gameRepo),
        squadRepositoryProvider.overrideWithValue(squadRepo),
      ],
      child: MaterialApp(home: GameSetupScreen(game: game)),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('GameSetupScreen — CSV-Import Persistenz (Regression)', () {
    late _FakeGameRepository gameRepo;
    late _FakeSquadRepository squadRepo;

    setUp(() {
      gameRepo = _FakeGameRepository();
      squadRepo = _FakeSquadRepository();
    });

    testWidgets(
        'TC-GS-01: Import persistiert Teamnamen ohne "Spiel starten" '
        '(Regression: Daten gingen beim Zurücknavigieren verloren)',
        (tester) async {
      final csv = _buildCsv(heim: 'VfB Stuttgart', gast: 'FC Bayern');
      FilePicker.platform = _FakeFilePicker(
        bytes: utf8.encode(csv),
        filename: 'bericht.csv',
      );

      await tester.pumpWidget(_buildApp(
        game: _defaultGame(),
        gameRepo: gameRepo,
        squadRepo: squadRepo,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aus Pressebericht importieren'));
      await tester.pumpAndSettle();

      // updateGame muss nach dem Import aufgerufen worden sein —
      // unabhängig davon, ob der Nutzer "Spiel starten" drückt.
      expect(gameRepo.lastUpdated, isNotNull,
          reason: 'updateGame muss nach Import aufgerufen werden');
      expect(gameRepo.lastUpdated!.homeTeamName, 'VfB Stuttgart');
      expect(gameRepo.lastUpdated!.awayTeamName, 'FC Bayern');
      // TC-111-06: Der Import setzt keine Trikotfarben
      expect(gameRepo.lastUpdated!.homeKitColor, isNull);
      expect(gameRepo.lastUpdated!.awayKitColor, isNull);
    });

    testWidgets(
        'TC-GS-02: Import persistiert Liga, Spieltag und Ort',
        (tester) async {
      final csv = _buildCsv(
        liganame: 'Regionalliga West',
        spieltag: '8',
        ort: 'Münster',
      );
      FilePicker.platform = _FakeFilePicker(
        bytes: utf8.encode(csv),
        filename: 'bericht.csv',
      );

      await tester.pumpWidget(_buildApp(
        game: _defaultGame(),
        gameRepo: gameRepo,
        squadRepo: squadRepo,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aus Pressebericht importieren'));
      await tester.pumpAndSettle();

      expect(gameRepo.lastUpdated?.liga, 'Regionalliga West');
      expect(gameRepo.lastUpdated?.spieltag, '8');
      expect(gameRepo.lastUpdated?.location, 'Münster');
    });

    testWidgets(
        'TC-GS-03: Aufstellungen und Spieldaten werden beide persistiert',
        (tester) async {
      final csv = _buildCsv(heim: 'FC Test', gast: 'SV Probe');
      FilePicker.platform = _FakeFilePicker(
        bytes: utf8.encode(csv),
        filename: 'bericht.csv',
      );

      await tester.pumpWidget(_buildApp(
        game: _defaultGame(),
        gameRepo: gameRepo,
        squadRepo: squadRepo,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aus Pressebericht importieren'));
      await tester.pumpAndSettle();

      // Aufstellungen gespeichert (via saveSquad)
      final homeSquad = await squadRepo.getSquad('g-setup', TeamSide.home);
      final awaySquad = await squadRepo.getSquad('g-setup', TeamSide.away);
      expect(homeSquad, isNotNull);
      expect(awaySquad, isNotNull);

      // Spieldaten gespeichert (via updateGame) — nicht erst bei "Spiel starten"
      expect(gameRepo.lastUpdated?.homeTeamName, 'FC Test');
      expect(gameRepo.lastUpdated?.awayTeamName, 'SV Probe');
    });
  });
}
