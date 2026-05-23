import 'package:climbing_companion/services/statistics_service.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class ClimbingPieChart extends StatelessWidget {
  final List<CategoryChartPoint> data;
  final String title;
  final double height;
  final bool donut;

  const ClimbingPieChart({
    super.key,
    required this.data,
    required this.title,
    this.height = 220,
    this.donut = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _EmptyChart(title: title, height: height);
    }

    return _ChartSection(
      title: title,
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Chart<CategoryChartPoint>(
              key: ValueKey(data),
              data: data,
              variables: {
                'category': Variable<CategoryChartPoint, String>(
                  accessor: (point) => point.category,
                  scale: OrdinalScale(inflate: true),
                ),
                'count': Variable<CategoryChartPoint, num>(
                  accessor: (point) => point.value,
                  scale: LinearScale(min: 0),
                ),
              },
              transforms: [Proportion(variable: 'count', as: 'percent')],
              marks: [
                IntervalMark(
                  position: Varset('percent') / Varset('category'),
                  color: ColorEncode(
                    variable: 'category',
                    values: Defaults.colors10,
                  ),
                  modifiers: [StackModifier()],
                ),
              ],
              coord: PolarCoord(
                transposed: true,
                dimCount: 1,
                startRadius: donut ? 0.45 : 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _Legend(data: data),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final List<CategoryChartPoint> data;

  const _Legend({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (sum, point) => sum + point.value);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data
            .asMap()
            .entries
            .map((entry) {
              final point = entry.value;
              final color =
                  Defaults.colors10[entry.key % Defaults.colors10.length];
              final percent = total == 0 ? 0 : (point.value / total * 100);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${point.category}: ${percent.round()}%',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  final String title;
  final double height;
  final Widget child;

  const _ChartSection({
    required this.title,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SizedBox(height: height, width: double.infinity, child: child),
      ],
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String title;
  final double height;

  const _EmptyChart({required this.title, required this.height});

  @override
  Widget build(BuildContext context) {
    return _ChartSection(
      title: title,
      height: height,
      child: Center(
        child: Text(
          'No data yet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
