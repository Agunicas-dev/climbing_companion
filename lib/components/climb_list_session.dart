import 'package:climbing_companion/components/climb_log_card.dart';
import 'package:flutter/material.dart';

class ClimbListSession extends StatefulWidget {
  final String Function() currentTimeProvider;

  const ClimbListSession({super.key, required this.currentTimeProvider});

  @override
  State<ClimbListSession> createState() => _ClimbListSessionState();
}

class _ClimbListSessionState extends State<ClimbListSession> {
  final List<String> _climbTimes = [];

  void addClimb() {
    setState(() {
      _climbTimes.insert(0, widget.currentTimeProvider());
    });
  }

  void removeClimb(int index) {
    setState(() {
      _climbTimes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: addClimb,
                child: const Text('Add Climb', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Grade',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Tries',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          _climbTimes.isEmpty
              ? const Center(child: Text('No climbs added yet.'))
              : Expanded(
                child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: _climbTimes.length,
                    separatorBuilder: (_, __) => const SizedBox.shrink(),
                    itemBuilder: (context, index) {
                      return ClimbLogCard(
                        time: _climbTimes[index],
                        onDelete: () => removeClimb(index),
                      );
                    },
                  ),
              ),
        ],
      ),
    );
  }
}
