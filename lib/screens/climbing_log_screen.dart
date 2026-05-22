/*
  This screen is used to review a climbing log session entry.
  It shows the session date, total time, and the list of climbs recorded for that session.
*/

import 'package:flutter/material.dart';
import '../components/charts/horizontal_bar_chart.dart';
import '../components/charts/pie_chart.dart';
import '../models/session.dart';
import '../services/statistics_service.dart';

class ClimbingLog extends StatefulWidget {
  final Session session;

  const ClimbingLog({super.key, required this.session});

  @override
  State<ClimbingLog> createState() => _ClimbingLogState();
}

class _ClimbingLogState extends State<ClimbingLog> {
  final ScrollController _climbsScrollController = ScrollController();

  @override
  void dispose() {
    _climbsScrollController.dispose();
    super.dispose();
  }

  String _formatSessionDate(DateTime date) {
    final local = date.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }

  Widget _buildStatisticsSummary(
    BuildContext context,
    SessionClimbingStatistics statistics,
  ) {
    final averageRestTime = statistics.averageTimeBetweenClimbs;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Total climbs',
            value: '${statistics.totalClimbs}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            label: 'Successful climbs',
            value: '${statistics.completedClimbs}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            label: 'Failed attempts',
            value: '${statistics.failedClimbs}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            label: 'Best grade',
            value: statistics.hardestSuccessfulGrade ?? 'N/A',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            label: 'Avg rest',
            value: _formatDuration(averageRestTime),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session details'),
        shadowColor: Colors.black,
        elevation: 3,
      ),

      //Layout builder used to contain the climbs list to a percentage of the screen height, allowing for better use of space and a more balanced layout.
      body: LayoutBuilder(
        builder: (context, constraints) {
          final statistics = StatisticsService.getSessionStatistics(
            widget.session,
          );
          final climbsListHeight = constraints.maxHeight * 0.35;
          final chartHeight = (constraints.maxHeight - climbsListHeight - 220)
              .clamp(140.0, 200.0)
              .toDouble();
          final pieChartHeight =
              (constraints.maxHeight - climbsListHeight - 220)
                  .clamp(150.0, 240.0)
                  .toDouble();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatSessionDate(widget.session.date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total time: ${widget.session.totalTime}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildStatisticsSummary(context, statistics),
                  const SizedBox(height: 16),
                  const Text(
                    'Climbs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: climbsListHeight,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: widget.session.climbs.isEmpty
                          ? const Center(
                              child: Text(
                                'No climbs recorded for this session.',
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8),
                              child: Scrollbar(
                                controller: _climbsScrollController,
                                thumbVisibility: true,
                                child: ListView.separated(
                                  controller: _climbsScrollController,
                                  padding: const EdgeInsets.only(right: 12),
                                  itemCount: widget.session.climbs.length,
                                  separatorBuilder: (context, _) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final climb = widget.session.climbs[index];
                                    return Card(
                                      elevation: 2,
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 32,
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                climb.time,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  climb.grade ?? 'Unknown',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  climb.completion ?? 'Unknown',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.color,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClimbingHorizontalBarChart(
                    title: 'Grade distribution',
                    data: statistics.gradeDistribution,
                    height: chartHeight,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  ClimbingPieChart(
                    title: 'Completion',
                    data: statistics.completionDistribution,
                    height: pieChartHeight,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 34,
            child: Center(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
