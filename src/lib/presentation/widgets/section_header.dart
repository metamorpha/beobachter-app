import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Abschnittsüberschrift in Versalien, z. B. „ENTSCHEIDUNG" (US-601).
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final label = Text(
      title.toUpperCase(),
      style: context.text.labelSmall
          ?.copyWith(color: context.scheme.onSurfaceVariant),
    );
    if (trailing == null) return label;
    return Row(children: [Expanded(child: label), trailing!]);
  }
}
