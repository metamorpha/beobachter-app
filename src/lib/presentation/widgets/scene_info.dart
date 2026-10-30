import 'package:flutter/material.dart';

import '../../domain/entities/event.dart';
import '../../domain/entities/event_player.dart';
import '../../domain/entities/game.dart';
import '../../domain/enums/event_type.dart';
import '../../domain/enums/player_role.dart';
import '../../domain/enums/ref_decision.dart';
import '../../domain/enums/team_side.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/kit_colors.dart';
import 'team_dot.dart';

/// Gemeinsame Darstellung von Szeneninfos in der Nachbereitung (US-308):
/// Szenenliste, Detail-Sheet und Coaching-Ansicht.
extension EventDisplay on Event {
  /// Ereignistyp bzw. eigene Bezeichnung bei „Sonstiges".
  String get typeLabel {
    final custom = customTypeLabel?.trim();
    return type == EventType.custom && custom != null && custom.isNotEmpty
        ? custom
        : type.label;
  }
}

/// Erster Spieler mit [role] oder `null`.
EventPlayer? playerWithRole(List<EventPlayer> players, PlayerRole role) =>
    players.where((p) => p.role == role).firstOrNull;

/// „Teamname #Nr." bzw. nur „Teamname"; leerer Name → „Heim"/„Gast".
String playerText(EventPlayer player, Game game) {
  final name = player.team == TeamSide.home
      ? game.homeTeamName
      : game.awayTeamName;
  final team = name.trim().isEmpty ? player.team.label : name;
  final number = player.jerseyNumber;
  return number == null ? team : '$team #$number';
}

/// Teamfarbpunkt + „Teamname #Nr.".
class ScenePlayer extends StatelessWidget {
  final EventPlayer player;
  final Game game;
  final TeamKits kits;
  final TextStyle? style;

  const ScenePlayer({
    super.key,
    required this.player,
    required this.game,
    required this.kits,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TeamDot(color: kits.color(context, player.team)),
        const SizedBox(width: AppSpacing.s - 2),
        Flexible(
          child: Text(
            playerText(player, game),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}

/// Infozeile „● Team #Nr. · Fortsetzung: Freistoß". Entfällt ganz, wenn
/// weder Fouler noch Fortsetzung erfasst sind. [stacked] = untereinander
/// (Smartphone).
class SceneInfoLine extends StatelessWidget {
  final Event event;
  final List<EventPlayer> players;
  final Game game;
  final TeamKits kits;
  final bool stacked;

  const SceneInfoLine({
    super.key,
    required this.event,
    required this.players,
    required this.game,
    required this.kits,
    this.stacked = false,
  });

  @override
  Widget build(BuildContext context) {
    final fouler = playerWithRole(players, PlayerRole.fouler);
    final decision = event.refDecision;
    if (fouler == null && decision == null) return const SizedBox.shrink();

    final style = context.text.bodyMedium?.copyWith(
      color: context.scheme.onSurfaceVariant,
    );
    final foulerWidget = fouler == null
        ? null
        : ScenePlayer(player: fouler, game: game, kits: kits, style: style);
    final decisionWidget = decision == null
        ? null
        : Text(
            'Fortsetzung: ${decision.label}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          );

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [?foulerWidget, ?decisionWidget],
      );
    }
    return Row(
      children: [
        if (foulerWidget != null) Flexible(child: foulerWidget),
        if (foulerWidget != null && decisionWidget != null)
          Text('  ·  ', style: style),
        if (decisionWidget != null) Flexible(child: decisionWidget),
      ],
    );
  }
}
