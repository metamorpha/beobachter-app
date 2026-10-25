import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/form_factor.dart';

/// Öffnet einen Dialog: auf dem Smartphone als Vollbild, der von unten
/// einfährt; sonst wie bisher per [showDialog] (US-701, US-704).
Future<T?> showAppDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  if (!FormFactor.isPhone(context)) {
    return showDialog<T>(context: context, builder: builder);
  }
  return showGeneralDialog<T>(
    context: context,
    barrierColor: context.scheme.scrim.withValues(alpha: 0.4),
    transitionDuration: AppMotion.of(context, AppMotion.medium),
    pageBuilder: (ctx, _, _) => builder(ctx),
    transitionBuilder: (_, anim, _, child) => SlideTransition(
      position: Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: AppMotion.curve)),
      child: child,
    ),
  );
}

/// Vollbild-Rahmen für Inhalte, die Kopf und Speichern selbst mitbringen
/// (z. B. das Erfassungsformular).
class FullscreenDialog extends StatelessWidget {
  final Widget child;

  const FullscreenDialog({super.key, required this.child});

  @override
  Widget build(BuildContext context) =>
      Dialog.fullscreen(child: SafeArea(child: child));
}

/// Vollbild-Dialog für das Smartphone: ✕ und Titel oben, Inhalt scrollt,
/// Aktionen stehen fest unten (US-701).
class PhoneDialogFrame extends StatelessWidget {
  final Widget title;
  final Widget body;
  final List<Widget> actions;

  const PhoneDialogFrame({
    super.key,
    required this.title,
    required this.body,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return FullscreenDialog(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.l,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Schließen',
                  constraints: const BoxConstraints(
                    minWidth: AppSizes.tap,
                    minHeight: AppSizes.tap,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: context.text.titleLarge,
                    child: title,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: body,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.s,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final (i, a) in actions.indexed) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.s),
                  a,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
