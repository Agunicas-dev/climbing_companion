import 'package:climbing_companion/services/statistics_service.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class GradeCompletionBarChart extends StatelessWidget {
  final List<GradeCompletionChartPoint> data;
  final String title;
  final double height;

  const GradeCompletionBarChart({
    super.key,
    required this.data,
    required this.title,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    final visibleData = data.where((point) => point.value > 0).toList();
    if (visibleData.isEmpty) {
      return _EmptyChart(title: title, height: height);
    }

    final maxValue = data
        .map((point) => point.value)
        .fold<int>(0, (max, value) => value > max ? value : max);
    final tickStep = maxValue <= 4 ? 1 : (maxValue / 4).ceil();
    final countTicks = <num>[
      for (var tick = 0; tick <= maxValue; tick += tickStep) tick,
      if (maxValue > 0 && maxValue % tickStep != 0) maxValue,
    ];
    final colors = [
      const Color(0xff2563eb),
      const Color(0xff16a34a),
      const Color(0xffdc2626),
      ...Defaults.colors10,
    ];

    return _ChartSection(
      title: title,
      height: height,
      child: Column(
        children: [
          Expanded(
            child: Chart<GradeCompletionChartPoint>(
              key: ValueKey(data),
              data: data,
              variables: {
                'grade': Variable<GradeCompletionChartPoint, String>(
                  accessor: (point) => point.grade,
                  scale: OrdinalScale(inflate: true),
                ),
                'count': Variable<GradeCompletionChartPoint, num>(
                  accessor: (point) => point.value,
                  scale: LinearScale(
                    min: 0,
                    max: maxValue == 0 ? 1 : maxValue,
                    ticks: countTicks,
                    formatter: (value) => value.toInt().toString(),
                  ),
                ),
                'completion': Variable<GradeCompletionChartPoint, String>(
                  accessor: (point) => point.completion,
                  scale: OrdinalScale(inflate: true),
                ),
              },
              marks: [
                IntervalMark(
                  position:
                      Varset('grade') * Varset('count') / Varset('completion'),
                  color: ColorEncode(variable: 'completion', values: colors),
                  modifiers: [DodgeModifier()],
                  shape: ShapeEncode(
                    value: RectShape(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
              padding: (size) {
                final rightPadding = (size.width * 0.08)
                    .clamp(24.0, 48.0)
                    .toDouble();
                final leftPadding = (size.width * 0.1)
                    .clamp(36.0, 56.0)
                    .toDouble();
                return EdgeInsets.fromLTRB(leftPadding, 8, rightPadding, 32);
              },
              axes: [
                Defaults.horizontalAxis,
                AxisGuide(
                  variable: 'count',
                  label: LabelStyle(
                    textStyle: Defaults.textStyle,
                    offset: const Offset(-7.5, 0),
                  ),
                  grid: Defaults.strokeStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _Legend(colors: colors),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final List<Color> colors;

  const _Legend({required this.colors});

  @override
  Widget build(BuildContext context) {
    const labels = ['Sent', 'Flash', 'Failed'];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 6,
      children: [
        for (var index = 0; index < labels.length; index++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors[index],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(labels[index], style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
      ],
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
