import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/data/repositories/event_repository_impl.dart';
import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/entities/event_player.dart';
import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';
import 'package:beobachter_app/domain/enums/kit_color.dart';
import 'package:beobachter_app/domain/enums/player_role.dart';
import 'package:beobachter_app/domain/enums/ref_decision.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';
import 'package:beobachter_app/domain/repositories/event_repository.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/review/review_screen.dart';
import 'package:beobachter_app/presentation/theme/kit_colors.dart';
import 'package:beobachter_app/presentation/widgets/scene_info.dart';
import 'package:beobachter_app/presentation/widgets/team_dot.dart';

import 'golden/golden_harness.dart';

/// Testfälle aus docs/29_szeneninfos_tests.md (US-308).
///
/// Golden-Testdaten (Spiel g1, SV Westfalia – FC Ruhrtal), u. a.:
///   6'  Fußvergehen       Fouler Gast #6, Fortsetzung Freistoß
///   23' Oberkörperverg.   Fouler Heim #4, Gefoult Gast #10 (Altdaten),
///                         Gelb, Falsch · Erwartbar, Notiz, Coaching

const _tablet = Size(1280, 800);
const _phone = Size(390, 844);

Event _event({
  EventType type = EventType.footFoul,
  String? customLabel,
  RefDecision? decision,
  bool coaching = false,
  int elapsedMs = 30 * 1000,
}) => Event(
  id: '',
  gameId: 'g1',
  elapsedMs: elapsedMs,
  gamePhase: GamePhase.ersteHalbzeit,
  type: type,
  customTypeLabel: customLabel,
  locationX: 0.5,
  locationY: 0.5,
  refDecision: decision,
  coachingFlag: coaching,
  createdAt: DateTime(2026, 10, 30),
);

EventPlayer _p(PlayerRole role, TeamSide team, int? number) => EventPlayer(
  id: '',
  eventId: '',
  role: role,
  team: team,
  jerseyNumber: number,
);

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  Size size = _tablet,
  List<Override> overrides = const [],
  Future<void> Function(ProviderContainer c)? afterSeed,
}) async {
  final c = await pumpGoldenScreen(
    tester,
    ReviewScreen(game: goldenGame),
    size: size,
    overrides: overrides,
    afterSeed: afterSeed,
  );
  debugDisableShadows = true;
  return c;
}

/// Legt [event] mit [players] an (Minute 0 → erste Karte der Szenenliste).
Future<void> Function(ProviderContainer) _seed(
  Event event, [
  List<EventPlayer> players = const [],
]) => (c) => c.read(eventRepositoryProvider).createEvent(event, players);

Finder _infoLineOf(bool Function(Event e) match) => find.byWidgetPredicate(
  (w) => w is SceneInfoLine && match(w.event),
);

Future<void> _openCoaching(WidgetTester tester) async {
  await tester.tap(find.text('Coaching'));
  await tester.pumpAndSettle();
}

class _CountingEventRepository implements EventRepository {
  final EventRepository _inner;
  int playerLoads = 0;

  _CountingEventRepository(this._inner);

  @override
  Future<List<EventPlayer>> getPlayersForGame(String gameId) {
    playerLoads++;
    return _inner.getPlayersForGame(gameId);
  }

  @override
  Future<Event> createEvent(Event event, List<EventPlayer> players) =>
      _inner.createEvent(event, players);
  @override
  Future<List<Event>> getEvents(String gameId) => _inner.getEvents(gameId);
  @override
  Future<Event?> getEvent(String id) => _inner.getEvent(id);
  @override
  Future<void> updateEvent(Event event, List<EventPlayer> players) =>
      _inner.updateEvent(event, players);
  @override
  Future<void> deleteEvent(String id) => _inner.deleteEvent(id);
  @override
  Future<void> updateCoachingNote(String eventId, String? note) =>
      _inner.updateCoachingNote(eventId, note);
  @override
  Future<void> updateCoachingFlag(String eventId, bool flag) =>
      _inner.updateCoachingFlag(eventId, flag);
}

void main() {
  group('Szenenliste (US-308)', () {
    testWidgets('TC-308-01: Fouler mit Rückennummer in Trikotfarbe', (
      tester,
    ) async {
      await _pump(
        tester,
        afterSeed: (c) => c
            .read(gameRepositoryProvider)
            .updateKitColor('g1', TeamSide.home, KitColor.red),
      );
      // Szenen 6' und 61': beide Gast #6
      expect(find.text('FC Ruhrtal #6'), findsNWidgets(2));
      expect(find.text('SV Westfalia #4'), findsOneWidget);

      final player = find.ancestor(
        of: find.text('SV Westfalia #4'),
        matching: find.byType(ScenePlayer),
      );
      final dot = tester.widget<TeamDot>(
        find.descendant(of: player, matching: find.byType(TeamDot)),
      );
      expect(dot.color, KitColor.red.color);
    });

    testWidgets('TC-308-02: Fouler ohne Rückennummer → nur Team', (
      tester,
    ) async {
      await _pump(
        tester,
        afterSeed: _seed(_event(), [
          _p(PlayerRole.fouler, TeamSide.away, null),
        ]),
      );
      expect(find.text('FC Ruhrtal'), findsOneWidget);
    });

    testWidgets('TC-308-03/04: Ohne Spieler nur Fortsetzung mit Präfix', (
      tester,
    ) async {
      await _pump(
        tester,
        afterSeed: _seed(_event(decision: RefDecision.throwIn)),
      );
      final line = _infoLineOf((e) => e.refDecision == RefDecision.throwIn);
      expect(
        find.descendant(of: line, matching: find.text('Fortsetzung: Einwurf')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: line, matching: find.byType(ScenePlayer)),
        findsNothing,
      );
      expect(
        find.descendant(of: line, matching: find.text('  ·  ')),
        findsNothing,
      );
    });

    testWidgets('TC-308-05: Ohne Fouler und Fortsetzung keine Infozeile', (
      tester,
    ) async {
      await _pump(tester, afterSeed: _seed(_event(type: EventType.violent)));
      final line = _infoLineOf((e) => e.type == EventType.violent);
      expect(line, findsOneWidget);
      expect(
        find.descendant(of: line, matching: find.byType(Text)),
        findsNothing,
      );
    });

    testWidgets('TC-308-06: Eigener Ereignistyp statt „Sonstiges"', (
      tester,
    ) async {
      await _pump(
        tester,
        afterSeed: _seed(
          _event(
            type: EventType.custom,
            customLabel: 'Zeitspiel',
            coaching: true,
          ),
        ),
      );
      expect(find.text('Zeitspiel'), findsOneWidget);

      await tester.tap(find.text('Zeitspiel'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.textContaining('— Zeitspiel'), findsOneWidget);
      Navigator.of(tester.element(find.byType(ReviewScreen))).pop();
      await tester.pumpAndSettle();

      await _openCoaching(tester);
      expect(find.text('Zeitspiel'), findsOneWidget);
    });

    test('TC-308-07: Leerer Teamname → „Heim"/„Gast"', () {
      final game = Game(
        id: 'x',
        date: DateTime(2026, 10, 30),
        homeTeamName: '',
        awayTeamName: ' ',
        createdAt: DateTime(2026, 10, 30),
      );
      expect(
        playerText(_p(PlayerRole.fouler, TeamSide.home, 5), game),
        'Heim #5',
      );
      expect(
        playerText(_p(PlayerRole.fouler, TeamSide.away, null), game),
        'Gast',
      );
    });

    testWidgets('TC-308-08: Fouler-Änderung sofort sichtbar', (tester) async {
      final c = await _pump(tester);
      expect(find.text('SV Westfalia #4'), findsOneWidget);

      final repo = c.read(eventRepositoryProvider);
      final event = await tester.runAsync(() => repo.getEvent('c'));
      await tester.runAsync(
        () => repo.updateEvent(event!, [
          _p(PlayerRole.fouler, TeamSide.away, 9),
        ]),
      );
      // Wie onSaved im Bearbeiten-Dialog
      c.invalidate(eventsProvider('g1'));
      await tester.pumpAndSettle();

      expect(find.text('SV Westfalia #4'), findsNothing);
      expect(find.text('FC Ruhrtal #9'), findsOneWidget);
    });

    testWidgets('TC-308-09: Smartphone — Fouler und Fortsetzung untereinander', (
      tester,
    ) async {
      await _pump(tester, size: _phone);
      expect(tester.takeException(), isNull);
      final line = tester.widget<SceneInfoLine>(
        _infoLineOf((e) => e.id == 'a'),
      );
      expect(line.stacked, isTrue);
      final foulerY = tester.getTopLeft(find.text('FC Ruhrtal #6')).dy;
      final decisionY = tester
          .getTopLeft(find.text('Fortsetzung: Freistoß').first)
          .dy;
      expect(decisionY, greaterThan(foulerY));
    });
  });

  group('Detail-Sheet (US-308)', () {
    Future<void> openDetail(WidgetTester tester, String typeText) async {
      // Szenenkarte, nicht der gleichnamige Filter-Chip
      await tester.tap(
        find.descendant(of: find.byType(Card), matching: find.text(typeText)),
      );
      await tester.pumpAndSettle();
    }

    Finder inSheet(Finder f) =>
        find.descendant(of: find.byType(BottomSheet), matching: f);

    testWidgets('TC-308-10/12: Alle Infos inkl. Gefoultem (Altdaten)', (
      tester,
    ) async {
      final c = await _pump(tester);
      final event = (await tester.runAsync(
        () => c.read(eventRepositoryProvider).getEvent('c'),
      ))!;
      await openDetail(tester, 'Oberkörperverg.');

      expect(
        inSheet(find.text('${event.elapsedLabel} — Oberkörperverg.')),
        findsOneWidget,
      );
      expect(inSheet(find.text('1. Halbzeit')), findsOneWidget);
      for (final label in [
        'Fouler',
        'Gefoult',
        'Fortsetzung',
        'Karte',
        'Bewertung',
        'Szenennotiz',
      ]) {
        expect(inSheet(find.text(label)), findsOneWidget, reason: label);
      }
      expect(inSheet(find.text('SV Westfalia #4')), findsOneWidget);
      expect(inSheet(find.text('FC Ruhrtal #10')), findsOneWidget);
      expect(inSheet(find.text('Gelb')), findsWidgets);
      expect(inSheet(find.text('Zu spät, Ellbogen im Spiel')), findsOneWidget);
      expect(inSheet(find.byType(TextField)), findsOneWidget);

      // Szenenkarte zeigt nur den Fouler, nicht den Gefoulten
      Navigator.of(tester.element(find.byType(ReviewScreen))).pop();
      await tester.pumpAndSettle();
      expect(find.text('FC Ruhrtal #10'), findsNothing);
    });

    testWidgets('TC-308-11: Nicht erfasste Felder entfallen', (tester) async {
      await _pump(tester, afterSeed: _seed(_event(type: EventType.violent)));
      await openDetail(tester, 'Tätlichkeit');
      for (final label in [
        'Fouler',
        'Gefoult',
        'Fortsetzung',
        'Karte',
        'Bewertung',
        'Szenennotiz',
      ]) {
        expect(inSheet(find.text(label)), findsNothing, reason: label);
      }
      expect(inSheet(find.text('Coaching-Notiz:')), findsOneWidget);
    });

    testWidgets('TC-308-13: Coaching-Notiz weiterhin speicherbar', (
      tester,
    ) async {
      final c = await _pump(tester);
      await openDetail(tester, 'Abseits');
      await tester.enterText(inSheet(find.byType(TextField)), 'Stellung');
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      final event = (await tester.runAsync(
        () => c.read(eventRepositoryProvider).getEvent('b'),
      ))!;
      expect(event.coachingNote, 'Stellung');
      expect(event.coachingFlag, isTrue);
    });
  });

  group('Coaching-Ansicht (US-308)', () {
    testWidgets('TC-308-14: Fouler und Fortsetzung im Coaching-Eintrag', (
      tester,
    ) async {
      await _pump(tester);
      await _openCoaching(tester);

      expect(
        find.text('Oberkörperverg. · Gelb · Falsch · Erwartbar'),
        findsOneWidget,
      );
      expect(find.text('SV Westfalia #4'), findsOneWidget);
      expect(find.text('Fortsetzung: Gelb'), findsOneWidget);
      expect(find.text('SV Westfalia #3'), findsOneWidget);
      expect(find.text('Fortsetzung: Strafstoß'), findsOneWidget);
      expect(find.text('Zu spät, Ellbogen im Spiel'), findsOneWidget);
    });

    testWidgets('TC-308-15: Ohne Spieler/Fortsetzung keine Infozeile', (
      tester,
    ) async {
      await _pump(
        tester,
        afterSeed: _seed(_event(type: EventType.violent, coaching: true)),
      );
      await _openCoaching(tester);
      final line = _infoLineOf((e) => e.type == EventType.violent);
      expect(line, findsOneWidget);
      expect(
        find.descendant(of: line, matching: find.byType(Text)),
        findsNothing,
      );
      expect(find.widgetWithText(TextField, 'Coaching-Notiz …'), findsWidgets);
    });
  });

  testWidgets('TC-308-16: Spieler werden einmal pro Spiel geladen', (
    tester,
  ) async {
    late _CountingEventRepository repo;
    await _pump(
      tester,
      overrides: [
        eventRepositoryProvider.overrideWith((ref) {
          return repo = _CountingEventRepository(
            EventRepositoryImpl(ref.watch(databaseProvider)),
          );
        }),
      ],
      afterSeed: (c) async {
        for (var i = 0; i < 4; i++) {
          await c
              .read(eventRepositoryProvider)
              .createEvent(_event(elapsedMs: i * 1000), const []);
        }
      },
    );
    // 10 Szenen, sichtbare Karten lesen alle aus demselben Provider
    expect(find.byType(SceneInfoLine), findsWidgets);
    expect(repo.playerLoads, 1);

    await _openCoaching(tester);
    expect(repo.playerLoads, 1);
  });
}
