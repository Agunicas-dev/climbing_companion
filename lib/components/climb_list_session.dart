import 'package:climbing_companion/components/climb_log_card.dart';
import 'package:flutter/material.dart';

class ClimbItem {
  final String id;
  final String time;
  final DateTime createdAt;
  String? grade;
  String? completion;

  ClimbItem({required this.id, required this.time, required this.createdAt, this.grade, this.completion});
}

class ClimbListSession extends StatefulWidget {
  final String Function() currentTimeProvider;

  const ClimbListSession({super.key, required this.currentTimeProvider});

  @override
  State<ClimbListSession> createState() => ClimbListSessionState();
}

class ClimbListSessionState extends State<ClimbListSession> {
  final List<ClimbItem> _climbs = [];

  void addClimb() {
    setState(() {
      _climbs.add(
        ClimbItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          time: widget.currentTimeProvider(),
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  void clearClimbs() {
    setState(() {
      _climbs.clear();
    });
  }

  void removeClimb(int index) {
    setState(() {
      _climbs.removeAt(index);
    });
  }

  List<ClimbItem> getItems() => List.unmodifiable(_climbs);

  @override
  Widget build(BuildContext context) {
    final sortedClimbs = [..._climbs]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
          _climbs.isEmpty
              ? const Center(child: Text('No climbs added yet.'))
              : Expanded(
                child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: sortedClimbs.length,
                    separatorBuilder: (context, index) => const SizedBox.shrink(),
                    itemBuilder: (context, index) {
                      final climb = sortedClimbs[index];
                      return ClimbLogCard(
                        key: ValueKey(climb.id),
                        time: climb.time,
                        selectedGrade: climb.grade,
                        selectedCompletion: climb.completion,
                        onGradeChanged: (value) {
                          setState(() {
                            climb.grade = value;
                          });
                        },
                        onCompletionChanged: (value) {
                          setState(() {
                            climb.completion = value;
                          });
                        },
                        onDelete: () {
                          final originalIndex = _climbs.indexWhere((item) => item.id == climb.id);
                          if (originalIndex != -1) {
                            removeClimb(originalIndex);
                          }
                        },
                      );
                    },
                  ),
              ),
        ],
      ),
    );
  }
}
