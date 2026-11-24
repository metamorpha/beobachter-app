import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/entities/event_player.dart';
import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/entities/timer_state.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/domain/enums/kit_color.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';
import 'package:beobachter_app/domain/repositories/event_repository.dart';
import 'package:beobachter_app/domain/repositories/game_repository.dart';
import 'package:beobachter_app/domain/repositories/timer_repository.dart';
import 'package:beobachter_app/presentation/platform/speech_input.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/live/event_form_panel.dart';
import 'package:beobachter_app/presentation/screens/review/review_screen.dart';
import 'package:beobachter_app/presentation/widgets/dictation_button.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

/// Spracherkennung zum Steuern aus dem Test: [say] liefert Zwischenstände,
/// [finish] beendet die Aufnahme (optional mit Fehler).
class _FakeSpeech implements SpeechInput {
  final bool available;
  int listenCalls = 0;
  int stopCalls = 0;
  void Function(String)? _onResult;
  void Function(DictationError?)? _onDone;

  _FakeSpeech({this.available = true});

  bool get isListening => _onDone != null;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> listen({
    required void Function(String words) onResult,
    required void Function(DictationError? error) onDone,
  }) async {
    listenCalls++;
    finish();
    _onResult = onResult;
    _onDone = onDone;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  void say(String words) => _onResult?.call(words);

  void finish([DictationError? error]) {
    final done = _onDone;
    _onDone = null;
    _onResult = null;
    done?.call(error);
  }
}

class _FakeEventRepository implements EventRepository {
  final List<Event> _events;
  Event? lastCreated;
  String? lastCoachingNote;

  _FakeEventRepository([List<Event> events = const []])
      : _events = List.of(events);

  @override
  Future<Event> createEvent(Event event, List<EventPlayer> players) async {
    lastCreated = event;
    return event;
  }

  @override
  Future<List<Event>> getEvents(String gameId) async =>
      _events.where((e) => e.gameId == gameId).toList();

  @override
  Future<Event?> getEvent(String id) async =>
      _events.where((e) => e.id == id).firstOrNull;

  @override
  Future<void> updateEvent(Event event, List<EventPlayer> players) async {}

  @override
  Future<void> deleteEvent(String id) async {}

  @override
  Future<List<EventPlayer>> getPlayersForGame(String gameId) async => [];

  @override
  Future<void> updateCoachingNote(String eventId, String? note) async {
    lastCoachingNote = note;
  }

  @override
  Future<void> updateCoachingFlag(String eventId, bool flag) async {}
}

class _FakeGameRepository implements GameRepository {
  String? lastCoachingNote;

  @override
  Future<Game> createGame(Game game) async => game;

  @override
  Future<List<Game>> getGames() async => [];

  @override
  Future<Game?> getGame(String id) async => null;

  @override
  Future<void> updateGame(Game game) async {}

  @override
  Future<void> deleteGame(String id) async {}

  @override
  Future<void> updateCoachingNote(String gameId, String? note) async {
    lastCoachingNote = note;
  }

  @override
  Future<void> updateKitColor(
    String gameId,
    TeamSide team,
    KitColor kit,
  ) async {}
}

class _FakeTimerRepository implements TimerRepository {
  @override
  Future<TimerState?> getTimerState(String gameId) async => null;

  @override
  Future<void> saveTimerState(TimerState state) async {}

  @override
  Stream<TimerState?> watchTimerState(String gameId) =>
      Stream.value(null);
}

// ── Hilfsfunktionen ───────────────────────────────────────────────────────────

const _gameId = 'g-test';

final _mic = find.byKey(const Key('btn_dictation'));

/// Mikrofon im Feld mit dem Hinweistext [hint].
Finder _micIn(String hint) => find.descendant(
      of: find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == hint,
      ),
      matching: _mic,
    );

/// Ein oder mehrere schlichte Felder mit Mikrofon.
Widget _fieldsApp(_FakeSpeech speech, List<TextEditingController> ctrls) =>
    ProviderScope(
      overrides: [speechInputProvider.overrideWithValue(speech)],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) => Column(
              children: [
                for (var i = 0; i < ctrls.length; i++)
                  TextField(
                    key: Key('field_$i'),
                    controller: ctrls[i],
                    decoration: InputDecoration(
                      hintText: 'Feld $i',
                      suffixIcon: DictationButton.suffix(ref, ctrls[i]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

Game _game() => Game(
      id: _gameId,
      date: DateTime(2026, 10, 1),
      homeTeamName: 'Heim',
      awayTeamName: 'Gast',
      createdAt: DateTime(2026, 10, 1),
    );

Event _coachingEvent() => Event(
      id: 'e-1',
      gameId: _gameId,
      elapsedMs: 15 * 60 * 1000,
      type: EventType.footFoul,
      locationX: 0.5,
      locationY: 0.5,
      coachingFlag: true,
      createdAt: DateTime(2026, 10, 1, 15),
    );

Widget _reviewApp(
  _FakeSpeech speech,
  _FakeEventRepository eventRepo,
  _FakeGameRepository gameRepo,
) =>
    ProviderScope(
      overrides: [
        speechInputProvider.overrideWithValue(speech),
        eventRepositoryProvider.overrideWithValue(eventRepo),
        gameRepositoryProvider.overrideWithValue(gameRepo),
      ],
      child: MaterialApp(home: ReviewScreen(game: _game())),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('Text anhängen (US-218)', () {
    test('TC-218-04: an vorhandenen Text mit Leerzeichen', () {
      expect(
        DictationButton.append('Vorteil zu spät', 'Hand am Trikot'),
        'Vorteil zu spät Hand am Trikot',
      );
    });

    test('TC-218-05: leeres Feld ohne führendes Leerzeichen', () {
      expect(DictationButton.append('', 'Hand am Trikot'), 'Hand am Trikot');
    });

    test('TC-218-06: kein doppeltes Leerzeichen', () {
      expect(DictationButton.append('Vorteil ', 'zu spät'), 'Vorteil zu spät');
      expect(DictationButton.append('Zeile\n', 'zwei'), 'Zeile\nzwei');
    });

    test('Fehlercodes der Plattformen', () {
      expect(SpeechToTextInput.errorFor('error_permission'),
          DictationError.permission);
      expect(SpeechToTextInput.errorFor('error_network'),
          DictationError.unavailable);
      expect(SpeechToTextInput.errorFor('error_language_unavailable'),
          DictationError.unavailable);
      expect(
          SpeechToTextInput.errorFor('error_no_match'), DictationError.noMatch);
      expect(SpeechToTextInput.errorFor('error_xyz'), DictationError.other);
    });
  });

  group('Mikrofon-Button (US-218)', () {
    testWidgets('TC-218-02/03: Start, Live-Vorschau ohne Dopplung',
        (tester) async {
      final speech = _FakeSpeech();
      final ctrl = TextEditingController();
      await tester.pumpWidget(_fieldsApp(speech, [ctrl]));
      await tester.pump();

      expect(find.byTooltip('Diktieren'), findsOneWidget);
      await tester.tap(_mic);
      await tester.pump();

      expect(speech.listenCalls, 1);
      expect(find.byTooltip('Aufnahme beenden'), findsOneWidget);

      speech.say('Hand');
      await tester.pump();
      expect(ctrl.text, 'Hand');

      speech.say('Hand am Trikot');
      await tester.pump();
      expect(ctrl.text, 'Hand am Trikot');
      expect(ctrl.selection.baseOffset, ctrl.text.length);
    });

    testWidgets('TC-218-04: hängt an vorhandenen Text an', (tester) async {
      final speech = _FakeSpeech();
      final ctrl = TextEditingController(text: 'Vorteil zu spät');
      await tester.pumpWidget(_fieldsApp(speech, [ctrl]));
      await tester.pump();

      await tester.tap(_mic);
      await tester.pump();
      speech.say('Hand am Trikot');
      await tester.pump();

      expect(ctrl.text, 'Vorteil zu spät Hand am Trikot');
    });

    testWidgets('TC-218-07: zweiter Tap beendet die Aufnahme', (tester) async {
      final speech = _FakeSpeech();
      final ctrl = TextEditingController();
      await tester.pumpWidget(_fieldsApp(speech, [ctrl]));
      await tester.pump();

      await tester.tap(_mic);
      await tester.pump();
      speech.say('Hand');
      await tester.tap(_mic);
      await tester.pump();

      expect(speech.stopCalls, 1);
      expect(find.byTooltip('Diktieren'), findsOneWidget);
      expect(ctrl.text, 'Hand');
    });

    testWidgets('TC-218-08/09: Ende nach Pause, danach editierbar',
        (tester) async {
      final speech = _FakeSpeech();
      final ctrl = TextEditingController();
      await tester.pumpWidget(_fieldsApp(speech, [ctrl]));
      await tester.pump();

      await tester.tap(_mic);
      await tester.pump();
      speech
        ..say('Hand am Trikot')
        ..finish();
      await tester.pumpAndSettle();

      expect(find.byTooltip('Diktieren'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('field_0')),
          '${ctrl.text}, Vorteil zu spät');
      expect(ctrl.text, 'Hand am Trikot, Vorteil zu spät');
    });

    testWidgets('TC-218-23: getippter Text bleibt, Tastatur schließt beim Start',
        (tester) async {
      final speech = _FakeSpeech();
      final ctrl = TextEditingController();
      await tester.pumpWidget(_fieldsApp(speech, [ctrl]));
      await tester.pump();

      final field = find.byKey(const Key('field_0'));
      await tester.tap(field);
      await tester.enterText(field, 'Eröffnung');
      await tester.pump();
      expect(tester.testTextInput.hasAnyClients, isTrue);

      await tester.tap(_mic);
      await tester.pump();

      // Feld ohne Fokus → die Tastatur kann den Text nicht mehr überschreiben
      expect(tester.testTextInput.hasAnyClients, isFalse);
      speech.say('Guten Abend');
      await tester.pump();
      expect(ctrl.text, 'Eröffnung Guten Abend');
    });

    testWidgets('TC-218-24: leeres Ergebnis löscht das Diktat nicht',
        (tester) async {
      final speech = _FakeSpeech();
      final ctrl = TextEditingController(text: 'Eröffnung');
      await tester.pumpWidget(_fieldsApp(speech, [ctrl]));
      await tester.pump();

      await tester.tap(_mic);
      await tester.pump();
      speech
        ..say('Guten Abend')
        ..say('')
        ..finish();
      await tester.pumpAndSettle();

      expect(ctrl.text, 'Eröffnung Guten Abend');
    });

    testWidgets('TC-218-13: Schließen beendet die Aufnahme', (tester) async {
      final speech = _FakeSpeech();
      final ctrl = TextEditingController();
      await tester.pumpWidget(_fieldsApp(speech, [ctrl]));
      await tester.pump();

      await tester.tap(_mic);
      await tester.pump();
      await tester.pumpWidget(const SizedBox());

      expect(speech.stopCalls, 1);
      speech.say('zu spät');
      expect(ctrl.text, isEmpty);
    });

    testWidgets('TC-218-14: nur eine Aufnahme gleichzeitig', (tester) async {
      final speech = _FakeSpeech();
      final a = TextEditingController();
      final b = TextEditingController();
      await tester.pumpWidget(_fieldsApp(speech, [a, b]));
      await tester.pump();

      await tester.tap(_mic.first);
      await tester.pump();
      speech.say('erstes');
      await tester.tap(_mic.last);
      await tester.pump();
      speech.say('zweites');
      await tester.pump();

      expect(a.text, 'erstes');
      expect(b.text, 'zweites');
      expect(find.byTooltip('Aufnahme beenden'), findsOneWidget);
      expect(find.byTooltip('Diktieren'), findsOneWidget);
    });

    testWidgets('TC-218-16: ohne Spracherkennung kein Mikrofon',
        (tester) async {
      await tester.pumpWidget(
        _fieldsApp(_FakeSpeech(available: false), [TextEditingController()]),
      );
      await tester.pumpAndSettle();

      expect(_mic, findsNothing);
      final field = tester.widget<TextField>(find.byKey(const Key('field_0')));
      expect(field.decoration?.suffixIcon, isNull);
    });

    for (final (tc, error, text) in [
      ('TC-218-17', DictationError.permission, 'Mikrofon nicht freigegeben'),
      (
        'TC-218-18',
        DictationError.unavailable,
        'Spracherkennung nicht verfügbar – Internet oder '
            'Offline-Sprachpaket Deutsch erforderlich',
      ),
      (
        'TC-218-19',
        DictationError.noMatch,
        'Nichts erkannt – bitte noch einmal versuchen',
      ),
    ]) {
      testWidgets('$tc: Hinweis bei Fehler ${error.name}', (tester) async {
        final speech = _FakeSpeech();
        final ctrl = TextEditingController(text: 'bisher');
        await tester.pumpWidget(_fieldsApp(speech, [ctrl]));
        await tester.pump();

        await tester.tap(_mic);
        await tester.pump();
        speech.finish(error);
        await tester.pump();

        expect(find.text(text), findsOneWidget);
        expect(find.byTooltip('Diktieren'), findsOneWidget);
        expect(ctrl.text, 'bisher');
      });
    }
  });

  group('Einbau in die Notizfelder (US-218)', () {
    testWidgets('TC-218-01/10: Szenennotiz diktieren und speichern',
        (tester) async {
      final speech = _FakeSpeech();
      final eventRepo = _FakeEventRepository();
      Event? saved;
      await tester.pumpWidget(ProviderScope(
        overrides: [
          speechInputProvider.overrideWithValue(speech),
          timerRepositoryProvider.overrideWithValue(_FakeTimerRepository()),
          eventRepositoryProvider.overrideWithValue(eventRepo),
          homeSquadProvider(_gameId).overrideWith((_) async => []),
          awaySquadProvider(_gameId).overrideWith((_) async => []),
          gameProvider(_gameId).overrideWith((_) async => null),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: EventFormPanel(
              gameId: _gameId,
              locationX: 0.5,
              locationY: 0.5,
              onClose: () {},
              onSaved: (e) => saved = e,
            ),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byKey(const Key('event_type_offside')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Notiz'));
      await tester.tap(find.text('Notiz'));
      await tester.pumpAndSettle();

      final mic = _micIn('Szenennotiz …');
      expect(mic, findsOneWidget);
      await tester.ensureVisible(mic);
      await tester.tap(mic);
      await tester.pump();
      speech
        ..say('Abseits knapp')
        ..finish();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_save_event')));
      await tester.pump();

      expect(saved?.sceneNote, 'Abseits knapp');
    });

    testWidgets('TC-218-11: Coaching-Notiz je Szene wird automatisch gespeichert',
        (tester) async {
      final speech = _FakeSpeech();
      final eventRepo = _FakeEventRepository([_coachingEvent()]);
      await tester.pumpWidget(
        _reviewApp(speech, eventRepo, _FakeGameRepository()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coaching'));
      await tester.pumpAndSettle();

      final mic = _micIn('Coaching-Notiz …');
      expect(mic, findsOneWidget);
      await tester.tap(mic);
      await tester.pump();
      speech
        ..say('Laufweg ansprechen')
        ..finish();
      await tester.pumpAndSettle();

      expect(eventRepo.lastCoachingNote, 'Laufweg ansprechen');
    });

    testWidgets('TC-218-25: Coaching – getippter und diktierter Text bleiben',
        (tester) async {
      final speech = _FakeSpeech();
      final gameRepo = _FakeGameRepository();
      await tester.pumpWidget(
        _reviewApp(speech, _FakeEventRepository(), gameRepo),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coaching'));
      await tester.pumpAndSettle();

      final field = find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            w.decoration?.hintText == 'Eröffnungsworte, allgemeines Fazit …',
      );
      await tester.tap(field);
      await tester.enterText(field, 'Eröffnung:');
      await tester.pump();

      await tester.tap(_micIn('Eröffnungsworte, allgemeines Fazit …'));
      await tester.pump();
      speech.say('Guten Abend');
      await tester.pump();
      expect(gameRepo.lastCoachingNote, 'Eröffnung:');
      speech.finish();
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(field).controller!.text,
        'Eröffnung: Guten Abend',
      );
      expect(gameRepo.lastCoachingNote, 'Eröffnung: Guten Abend');
    });

    testWidgets('TC-218-12: Allgemeine Notiz wird automatisch gespeichert',
        (tester) async {
      final speech = _FakeSpeech();
      final gameRepo = _FakeGameRepository();
      await tester.pumpWidget(
        _reviewApp(speech, _FakeEventRepository(), gameRepo),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coaching'));
      await tester.pumpAndSettle();

      final mic = _micIn('Eröffnungsworte, allgemeines Fazit …');
      expect(mic, findsOneWidget);
      await tester.tap(mic);
      await tester.pump();
      speech
        ..say('Gute Leistung')
        ..finish();
      await tester.pumpAndSettle();

      expect(gameRepo.lastCoachingNote, 'Gute Leistung');
    });

    testWidgets('TC-218-01: Mikrofon in der Coaching-Notiz des Detail-Sheets',
        (tester) async {
      await tester.pumpWidget(_reviewApp(
        _FakeSpeech(),
        _FakeEventRepository([_coachingEvent()]),
        _FakeGameRepository(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(of: find.byType(Card), matching: find.text('Fußvergehen')),
      );
      await tester.pumpAndSettle();

      expect(
        _micIn('Was möchte ich mit dem Schiedsrichter besprechen?'),
        findsOneWidget,
      );
    });
  });
}
