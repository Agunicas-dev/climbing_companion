import 'package:climbing_companion/services/statistics_service.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class ClimbingVerticalBarChart extends StatelessWidget {
  final List<CategoryChartPoint> data;
  final String title;
  final double height;
  final Color color;

  const ClimbingVerticalBarChart({
    super.key,
    required this.data,
    required this.title,
    this.height = 220,
    this.color = const Color(0xff16a34a),
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _EmptyChart(title: title, height: height);
    }

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
            scale: LinearScale(min: 0),
          ),
        },
        marks: [
          IntervalMark(
            position: Varset('category') * Varset('count'),
            color: ColorEncode(value: color),
            shape: ShapeEncode(
              value: RectShape(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(5),
                ),
              ),
            ),
          ),
        ],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
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
