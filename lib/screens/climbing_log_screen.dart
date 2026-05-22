/*
  This screen is used to review a climbing log session entry.
  It shows the session date, total time, and the list of climbs recorded for that session.
*/

import 'package:flutter/material.dart';
import '../models/session.dart';

class ClimbingLog extends StatelessWidget {
  final Session session;

  const ClimbingLog({super.key, required this.session});

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatSessionDate(session.date),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Total time: ${session.totalTime}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Climbs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: session.climbs.isEmpty
                  ? const Center(child: Text('No climbs recorded for this session.'))
                  : ListView.separated(
                      itemCount: session.climbs.length,
                      separatorBuilder: (context, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final climb = session.climbs[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Climb ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text('Time: ${climb.time}'),
                                Text('Grade: ${climb.grade ?? 'Unknown'}'),
                                Text('Completion: ${climb.completion ?? 'Unknown'}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
