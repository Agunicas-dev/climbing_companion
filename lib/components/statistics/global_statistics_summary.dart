import 'package:climbing_companion/components/statistics_grid.dart';
import 'package:climbing_companion/services/statistics_service.dart';
import 'package:flutter/material.dart';


//Widget to display a summary of global climbing statistics in a grid format using the StatisticsSummaryGrid component and StatisticsService data.
class GlobalStatisticsSummary extends StatelessWidget {
  final GlobalClimbingStatistics statistics;

  const GlobalStatisticsSummary({super.key, required this.statistics});

  //Method or function to format the duration of the average rest time calculation into a more readable string.
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }


  /*Method to build the widget for the global statistics summary, creating a list of items
  and calling the StatisticsSummaryGrid component to display them in a grid.*/
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
