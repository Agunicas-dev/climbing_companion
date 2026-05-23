import 'package:climbing_companion/services/statistics_service.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class ClimbingLineChart extends StatelessWidget {
  final List<SessionChartPoint> data;
  final String title;
  final String valueLabel;
  final double height;
  final Color color;
  final List<String>? yLabels;

  const ClimbingLineChart({
    super.key,
    required this.data,
    required this.title,
    this.valueLabel = 'Value',
    this.height = 220,
    this.color = const Color(0xff2563eb),
    this.yLabels,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _EmptyChart(title: title, height: height);
    }

    return _ChartSection(
      title: title,
      height: height,
      child: Chart<SessionChartPoint>(
        key: ValueKey(data),
        data: data,
        padding: (size) => const EdgeInsets.fromLTRB(40, 8, 12, 32),
        variables: {
          'session': Variable<SessionChartPoint, String>(
            accessor: (point) => point.label,
            scale: OrdinalScale(inflate: true),
          ),
          valueLabel: Variable<SessionChartPoint, num>(
            accessor: (point) => point.value,
            scale: LinearScale(
              min: 0,
              formatter: (value) {
                if (yLabels != null) {
                  final index = value.toInt();
                  if (index >= 0 && index < yLabels!.length) {
                    return yLabels![index];
                  }
                }
                return value.toInt().toString();
              },
            ),
          ),
        },
        marks: [
          LineMark(
            position: Varset('session') * Varset(valueLabel),
            color: ColorEncode(value: color),
            shape: ShapeEncode(value: BasicLineShape(smooth: true)),
            size: SizeEncode(value: 2.5),
          ),
          PointMark(
            position: Varset('session') * Varset(valueLabel),
            color: ColorEncode(value: color),
            size: SizeEncode(value: 5),
          ),
        ],
        axes: [
          Defaults.horizontalAxis,
          AxisGuide(
            variable: valueLabel,
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
