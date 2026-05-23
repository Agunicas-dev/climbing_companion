import 'package:climbing_companion/components/statistics/statistics_summary_grid.dart';
import 'package:climbing_companion/services/statistics_service.dart';
import 'package:flutter/material.dart';

class GlobalStatisticsSummary extends StatelessWidget {
  final GlobalClimbingStatistics statistics;

  const GlobalStatisticsSummary({super.key, required this.statistics});

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
        icon: Icons.bolt,
        label: 'Flash grade',
        value: statistics.flashGrade ?? 'N/A',
      ),
      StatisticSummaryItem(
        icon: Icons.terrain,
        label: 'Total climbs',
        value: '${statistics.totalClimbs}',
      ),
      StatisticSummaryItem(
        icon: Icons.bookmark_added,
        label: 'Total sessions',
        value: '${statistics.sessionCount}',
      ),
      StatisticSummaryItem(
        icon: Icons.timer,
        label: 'Average rest',
        value: _formatDuration(statistics.averageRestTime),
      ),
    ];

    return StatisticsSummaryGrid(items: tiles);
  }
}
