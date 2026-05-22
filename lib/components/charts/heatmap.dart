import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class ClimbingHeatmapChart extends StatelessWidget {
  final List<HeatmapChartPoint> data;
  final String title;
  final double height;

  const ClimbingHeatmapChart({
    super.key,
    required this.data,
    required this.title,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _EmptyChart(title: title, height: height);
    }

    return _ChartSection(
      title: title,
      height: height,
      child: Chart<HeatmapChartPoint>(
        data: data,
        variables: {
          'x': Variable<HeatmapChartPoint, String>(
            accessor: (point) => point.x,
          ),
          'y': Variable<HeatmapChartPoint, String>(
            accessor: (point) => point.y,
          ),
          'value': Variable<HeatmapChartPoint, num>(
            accessor: (point) => point.value,
            scale: LinearScale(min: 0),
          ),
        },
        marks: [
          PolygonMark(
            color: ColorEncode(
              variable: 'value',
              values: const [
                Color(0xffdbeafe),
                Color(0xff38bdf8),
                Color(0xff1d4ed8),
              ],
            ),
          ),
        ],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
      ),
    );
  }
}

class HeatmapChartPoint {
  final String x;
  final String y;
  final num value;

  const HeatmapChartPoint({
    required this.x,
    required this.y,
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
