//This screen will be used to record a new climbing session.
import 'package:climbing_companion/components/climb_list_session.dart';
import 'package:climbing_companion/components/clock.dart';
import 'package:climbing_companion/services/isar_service.dart';
import 'package:climbing_companion/models/climb.dart' as model_climb;
import 'package:flutter/material.dart';

class SessionLogScreen extends StatefulWidget {
  const SessionLogScreen({super.key});

  @override
  State<SessionLogScreen> createState() => _SessionLogScreenState();
}

class _SessionLogScreenState extends State<SessionLogScreen> {
  final GlobalKey<SessionClockState> _clockKey = GlobalKey<SessionClockState>();
  final GlobalKey<ClimbListSessionState> _climbListKey = GlobalKey<ClimbListSessionState>();

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
          ClimbListSession(
            key: _climbListKey,
            currentTimeProvider: () => _currentStopwatchTime,
          ),
        ],
      ),
    );
  }

  void _onClockStop() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetSession();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text('Reset', style: TextStyle(fontSize: 22),),
                ),
              ),

              /*ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: open manual add climb UI.
                },
                child: const Text('Manual Add'),
              ),*/

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
                  await IsarService.saveSession(DateTime.now(), _currentStopwatchTime, climbs);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text('Save & Exit', style: TextStyle(fontSize: 22),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetSession() {
    _clockKey.currentState?.resetStopwatch();
    _climbListKey.currentState?.clearClimbs();
    setState(() {
      _currentStopwatchTime = '00:00:00';
    });
  }
}
