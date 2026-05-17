//This screen will be used to record a new climbing session.
import 'package:climbing_companion/components/climb_list_session.dart';
import 'package:climbing_companion/components/clock.dart';
import 'package:flutter/material.dart';

class SessionLogScreen extends StatefulWidget {
  const SessionLogScreen({super.key});

  @override
  State<SessionLogScreen> createState() => _SessionLogScreenState();
}

class _SessionLogScreenState extends State<SessionLogScreen> {
  String _currentStopwatchTime = '00:00:00';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log a new session', style: TextStyle(fontWeight: FontWeight.bold)),
        shadowColor: Colors.black,
        elevation: 3,
        
      ),
      body: Column(
        children: [
          SessionClock(
            onTimeChanged: (value) {
              setState(() {
                _currentStopwatchTime = value;
              });
            },
          ),
          const Divider(),
          ClimbListSession(currentTimeProvider: () => _currentStopwatchTime),
        ],
      ),
    );
  }
}
