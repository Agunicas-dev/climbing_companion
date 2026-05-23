import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class Stacked100BarChart extends StatelessWidget {
  final List<StackedBarData> data;
  final String title;
  final double height;

  const Stacked100BarChart({
    super.key,
    required this.data,
    required this.title,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _EmptyChart(title: title, height: height);
    }

    return _ChartSection(
      title: title,
      height: height,
      child: Chart<StackedBarData>(
        key: ValueKey(data),
        data: data,
        variables: {
          'group': Variable<StackedBarData, String>(
            accessor: (point) => point.group,
            scale: OrdinalScale(inflate: true),
          ),
          'category': Variable<StackedBarData, String>(
            accessor: (point) => point.category,
            scale: OrdinalScale(inflate: true),
          ),
          'value': Variable<StackedBarData, num>(
            accessor: (point) => point.value,
            scale: LinearScale(min: 0, max: 100),
          ),
        },
        marks: [
          IntervalMark(
            position: Varset('group') * Varset('value') / Varset('category'),
            color: ColorEncode(
              variable: 'category',
              values: Defaults.colors10,
            ),
            modifiers: [StackModifier()],
          ),
        ],
        coord: RectCoord(transposed: true),
        axes: [
          Defaults.horizontalAxis,
          Defaults.verticalAxis,
        ],
      ),
    );
  }
}

class StackedBarData {
  final String group;
  final String category;
  final num value;

  const StackedBarData({
    required this.group,
    required this.category,
    required this.value,
  });
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
