//This screen will be used to record a new climbing session.
import 'package:climbing_companion/components/climb_list_session.dart';
import 'package:climbing_companion/components/clock.dart';
import 'package:climbing_companion/models/session_type.dart';
import 'package:climbing_companion/screens/climbing_log_screen.dart';
import 'package:climbing_companion/services/isar_service.dart';
import 'package:climbing_companion/models/climb.dart' as model_climb;
import 'package:flutter/material.dart';

class SessionLogScreen extends StatefulWidget {
  final SessionType sessionType;

  const SessionLogScreen({super.key, required this.sessionType});

  @override
  State<SessionLogScreen> createState() => _SessionLogScreenState();
}

class _SessionLogScreenState extends State<SessionLogScreen> {
  //Defining GlobalKeys for the clock and climb list in order to be able to access their state and methods from this screen.
  final GlobalKey<SessionClockState> _clockKey = GlobalKey<SessionClockState>();
  final GlobalKey<ClimbListSessionState> _climbListKey =
      GlobalKey<ClimbListSessionState>();

  //Variable to store the stopwatch time.
  String _currentStopwatchTime = '00:00:00';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Log a new session',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shadowColor: Colors.black,
        elevation: 3,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Chip(
                  avatar: Icon(
                    widget.sessionType.environment == SessionEnvironment.indoor
                        ? Icons.home_work
                        : Icons.landscape,
                  ),
                  label: Text(widget.sessionType.environment.label),
                ),
                const SizedBox(width: 8),
                Chip(
                  avatar: Icon(
                    widget.sessionType.discipline == SessionDiscipline.boulder
                        ? Icons.terrain
                        : Icons.vertical_align_top,
                  ),
                  label: Text(widget.sessionType.discipline.label),
                ),
              ],
            ),
          ),
          //Add the Clock widget and handling the time changes and when the clock stops.
          SessionClock(
            key: _clockKey,
            onStop: _onClockStop,
            onTimeChanged: (value) {
              setState(() {
                _currentStopwatchTime = value;
              });
            },
          ),

          const Divider(),

          //Add the Climb List widget and providing the current stopwatch time to it in order to be able to add climbs with the correct time. Also, using a GlobalKey to be able to access the climb list state and methods from this screen.
          ClimbListSession(
            key: _climbListKey,
            discipline: widget.sessionType.discipline,
            currentTimeProvider: () => _currentStopwatchTime,
          ),
        ],
      ),
    );
  }

  //Function to handle when the clock stops, showing a bottom sheet with the options to reset the session, or save and exit.
  void _onClockStop() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //Button to reset the session, which will reset the clock and clear the climb list.
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetSession();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text('Reset', style: TextStyle(fontSize: 22)),
                ),
              ),

              /*TODO: Add an "Add manually" button that will allow the user to add a climb manually
                in case they forgot to add it during the session.*/

              //Button to save and exit, which will save the session to Isar and then pop the screen.
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final items = _climbListKey.currentState?.getItems() ?? [];
                  final climbs = items.map((i) {
                    final c = model_climb.Climb();
                    c.time = i.time;
                    c.grade = i.grade;
                    c.completion = i.completion;
                    return c;
                  }).toList();
                  final session = await IsarService.saveSession(
                    DateTime.now(),
                    _currentStopwatchTime,
                    climbs,
                    environment: widget.sessionType.environment.storageValue,
                    discipline: widget.sessionType.discipline.storageValue,
                  );
                  if (!mounted) return;
                  // Replace current screen with the log details screen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ClimbingLog(session: session),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Save & Exit',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Reset the session when the user clicks the reset button in the BottomModalForm.
  void _resetSession() {
    _clockKey.currentState?.resetStopwatch();
    _climbListKey.currentState?.clearClimbs();
    setState(() {
      _currentStopwatchTime = '00:00:00';
    });
  }
}
