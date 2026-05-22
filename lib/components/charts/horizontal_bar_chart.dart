import 'package:climbing_companion/services/statistics_service.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class ClimbingHorizontalBarChart extends StatelessWidget {
  final List<CategoryChartPoint> data;
  final String title;
  final double height;
  final Color color;

  const ClimbingHorizontalBarChart({
    super.key,
    required this.data,
    required this.title,
    this.height = 220,
    this.color = const Color(0xff0891b2),
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _EmptyChart(title: title, height: height);
    }

    final maxValue = data
        .map((point) => point.value)
        .fold<num>(0, (max, value) => value > max ? value : max)
        .ceil();
    final tickStep = maxValue <= 4 ? 1 : (maxValue / 4).ceil();
    final countTicks = <num>[
      for (var tick = 0; tick <= maxValue; tick += tickStep) tick,
      if (maxValue > 0 && maxValue % tickStep != 0) maxValue,
    ];

    return _ChartSection(
      title: title,
      height: height,
      child: Chart<CategoryChartPoint>(
        data: data,
        variables: {
          'category': Variable<CategoryChartPoint, String>(
            accessor: (point) => point.category,
          ),
          'count': Variable<CategoryChartPoint, num>(
            accessor: (point) => point.value,
            scale: LinearScale(
              min: 0,
              max: maxValue == 0 ? 1 : maxValue,
              ticks: countTicks,
              formatter: (value) => value.toInt().toString(),
            ),
          ),
        },
        marks: [
          IntervalMark(
            position: Varset('category') * Varset('count'),
            color: ColorEncode(value: color),
            shape: ShapeEncode(
              value: RectShape(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(5),
                ),
              ),
            ),
          ),
        ],
        coord: RectCoord(transposed: true),
        padding: (_) => const EdgeInsets.fromLTRB(48, 8, 12, 40),
        axes: [
          AxisGuide(
            dim: Dim.y,
            variable: 'count',
            line: Defaults.strokeStyle,
            label: LabelStyle(
              textStyle: Defaults.textStyle,
              offset: const Offset(0, 16),
            ),
          ),
          AxisGuide(
            dim: Dim.x,
            variable: 'category',
            line: Defaults.strokeStyle,
            label: LabelStyle(
              textStyle: Defaults.textStyle,
              offset: const Offset(-8, 0),
            ),
            grid: Defaults.strokeStyle,
          ),
        ],
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
