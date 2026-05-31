import 'package:flutter/material.dart';

class StatisticSummaryItem {
  final IconData icon;
  final String label;
  final String value;

  const StatisticSummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class StatisticsSummaryGrid extends StatelessWidget {
  final List<StatisticSummaryItem> items;
  final EdgeInsetsGeometry padding;

  const StatisticsSummaryGrid({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 520 ? 4 : 2;
          return GridView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: constraints.maxWidth >= 520 ? 1.55 : 1.35,
            ),
            itemBuilder: (context, index) {
              return _StatisticTile(item: items[index]);
            },
          );
        },
      ),
    );
  }
}

class _StatisticTile extends StatelessWidget {
  final StatisticSummaryItem item;

  const _StatisticTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(item.icon, color: colorScheme.primary),
            Text(
              item.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              item.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
