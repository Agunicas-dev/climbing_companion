import 'package:climbing_companion/components/statistics/statistics_summary_grid.dart';
import 'package:climbing_companion/services/statistics_service.dart';
import 'package:flutter/material.dart';

class SessionStatisticsSummary extends StatelessWidget {
  final SessionClimbingStatistics statistics;

  const SessionStatisticsSummary({super.key, required this.statistics});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final tiles = [
      StatisticSummaryItem(
        icon: Icons.terrain,
        label: 'Total climbs',
        value: '${statistics.totalClimbs}',
      ),
      StatisticSummaryItem(
        icon: Icons.check_circle,
        label: 'Successful climbs',
        value: '${statistics.completedClimbs}',
      ),
      StatisticSummaryItem(
        icon: Icons.cancel,
        label: 'Failed attempts',
        value: '${statistics.failedClimbs}',
      ),
      StatisticSummaryItem(
        icon: Icons.grade,
        label: 'Best grade',
        value: statistics.hardestSuccessfulGrade ?? 'N/A',
      ),
      StatisticSummaryItem(
        icon: Icons.timer,
        label: 'Average rest',
        value: _formatDuration(statistics.averageTimeBetweenClimbs),
      ),
    ];

    return StatisticsSummaryGrid(items: tiles, padding: EdgeInsets.zero);
  }
}
