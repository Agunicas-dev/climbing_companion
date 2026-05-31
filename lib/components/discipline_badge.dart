import 'package:flutter/material.dart';

// A simple badge widget to indicate climbing disciplines (bouldering or lead). It is used in the profile card and
//session review screens to visually represent the user's preferences and session types.
//The badge adapts its icon based on the current theme (light or dark) for better visibility.


enum DisciplineBadgeType { bouldering, lead }

class DisciplineBadge extends StatelessWidget {
  final DisciplineBadgeType type;

  const DisciplineBadge({super.key, required this.type});

  String get _label => switch (type) {
    DisciplineBadgeType.bouldering => 'Bouldering',
    DisciplineBadgeType.lead => 'Lead',
  };

  String _iconPath(BuildContext context) {
    final iconSuffix = Theme.of(context).brightness == Brightness.dark
        ? 'light'
        : 'dark';
    final iconName = switch (type) {
      DisciplineBadgeType.bouldering => 'holds',
      DisciplineBadgeType.lead => 'rope',
    };
    return 'lib/assets/images/${iconName}_$iconSuffix.png';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            _iconPath(context),
            width: 16,
            height: 16,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
