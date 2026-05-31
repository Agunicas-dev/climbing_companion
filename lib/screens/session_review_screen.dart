/*
  This screen is used to review a session entry on the database.
  It shows the session date, total time, and the list of climbs recorded for that session.
*/

import 'package:climbing_companion/services/isar_service.dart';
import 'package:flutter/material.dart';
import '../components/charts/grade_completion_bar_chart.dart';
import '../components/charts/horizontal_bar_chart.dart';
import '../components/charts/pie_chart.dart';
import '../components/statistics/session_statistics_summary.dart';
import '../models/session.dart';
import '../services/statistics_service.dart';

//Constructor for the session review screen, which takes a Session object as a parameter and displays its details and statistics.
class SessionReviewScreen extends StatefulWidget {
  final Session session;

  const SessionReviewScreen({super.key, required this.session});

  @override
  State<SessionReviewScreen> createState() => _SessionReviewScreenState();
}

class _SessionReviewScreenState extends State<SessionReviewScreen> {
  final ScrollController _climbsScrollController = ScrollController();

  @override
  void dispose() {
    _climbsScrollController.dispose();
    super.dispose();
  }

  //Method to confirm the deletion of a session, showing a dialog to the user and deleting the session from the database if confirmed.
  Future<void> _confirmDeletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text('Are you sure you want to delete this session? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await IsarService.deleteSession(widget.session.id);
      if (context.mounted) {
        Navigator.pop(context); // Go back after deletion
      }
    }
  }

  //Method to format the session date into a readable string format.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session details'),
        shadowColor: Colors.black,
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDeletion(context),
          ),
        ],
      ),

      //Layout builder used to contain the climbs list to a percentage of the screen height, allowing for better use of space and a more balanced layout.
      body: LayoutBuilder(
        builder: (context, constraints) {
          //Calculating the statistics for the session using the StatisticsService and determining the heights for the climbs list and charts based on the available screen height.
          //The part for the height calculation is thanks to the help of copilot because i had no idea how to do it but some things were off in proportions.
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
          final groupedChartHeight =
              (constraints.maxHeight - climbsListHeight - 180)
                  .clamp(220.0, 280.0)
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
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(label: Text(widget.session.environmentLabel)),
                      Chip(label: Text(widget.session.disciplineLabel)),
                    ],
                  ),

                  //Section used to show the session statistics.
                  const SizedBox(height: 16),
                  SessionStatisticsSummary(statistics: statistics),
                  const SizedBox(height: 16),

                  //Section used to show the list of climbs for the session.
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
                      child:
                      
                      //If there are no climbs, show a message. Otherwise, show the list of climbs using a
                      //ListView and displaying the time, grade and completion status for each climb.
                      widget.session.climbs.isEmpty
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
                                                  climb.grade ?? 'Unknown',//If grade is null, show 'Unknown'.
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  climb.completion ?? 'Unknown',//If completion status is null, show 'Unknown'.
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

                  /*Show the statistics charts for the session, including grade distribution,
                  outcomes by grade and completion distribution, using the calculated statistics from the StatisticsService.*/
                  const SizedBox(height: 16),
                  ClimbingHorizontalBarChart(
                    title: 'Grade distribution',
                    data: statistics.gradeDistribution,
                    height: chartHeight,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  GradeCompletionBarChart(
                    title: 'Outcomes by grade',
                    data: statistics.gradeCompletionBreakdown,
                    height: groupedChartHeight,
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
