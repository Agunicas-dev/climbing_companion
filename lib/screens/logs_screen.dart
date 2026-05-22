import 'package:climbing_companion/services/isar_service.dart';
import 'package:flutter/material.dart';

import '../models/session.dart';
import 'climbing_log_screen.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  //Formatting for the date in order to make it readable.
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
        title: const Text('Saved Sessions'),
        shadowColor: Colors.black,
        elevation: 3,
      ),

      //Using FutureBuilder to load sessions from Isar and display them in a ListView.
      body: FutureBuilder<List<Session>>(
        future: IsarService.getAllSessions(),
        builder: (context, snapshot) {

          //Show loading indicator when waiting for the data to load.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          //Error handling if something goes wrong while loading sessions from Isar.
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading sessions: ${snapshot.error}'),//Show the error.
              ),
            );
          }

          //Load the sessions into a collection.
          final sessions = snapshot.data ?? [];
          //Display a message if there are no saved sessions yet.
          if (sessions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No saved sessions yet.'),
              ),
            );
          }

          //Listview for the sessions, showing the date, total time, and number of climbs for each session.
          return ListView.separated(
            padding: const EdgeInsets.all(16),

            //Separator between list items.
            itemCount: sessions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),

            //Building each item in the collection as a card with the session info.
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  title: Text(_formatSessionDate(session.date)),
                  subtitle: Text(
                    'Total time: ${session.totalTime}\nClimbs: ${session.climbs.length}',
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClimbingLog(session: session),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
