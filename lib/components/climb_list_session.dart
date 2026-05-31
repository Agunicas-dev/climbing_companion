import 'package:climbing_companion/components/climb_log_card.dart';
import 'package:climbing_companion/models/session_type.dart';
import 'package:climbing_companion/services/grade_scale_service.dart';
import 'package:climbing_companion/services/settings_service.dart';
import 'package:flutter/material.dart';

/*Component in charge of managin the list of climbs when recording a session.
It allows the user to add or remove climbs, and set the grade and completion status for each one.*/

//
class ClimbItem {
  final String id;
  final String time;
  final DateTime createdAt;
  String? grade;
  String? completion;

  ClimbItem({
    required this.id,
    required this.time,
    required this.createdAt,
    this.grade,
    this.completion,
  });
}

class ClimbListSession extends StatefulWidget {
  final String Function() currentTimeProvider;
  final SessionDiscipline discipline;

  const ClimbListSession({
    super.key,
    required this.currentTimeProvider,
    required this.discipline,
  });

  @override
  State<ClimbListSession> createState() => ClimbListSessionState();
}

class ClimbListSessionState extends State<ClimbListSession> {
  final List<ClimbItem> _climbs = [];//List to store the climbs added during the session.
  /*List to store the grade options based on the user's settings and discipline. By default, it is
  set to hueco grades until the settings are loaded and the correct grading system is determined.*/
  List<String> _gradeOptions = GradeScaleService.huecoGrades;

  //Load grading system selected by the user.
  @override
  void initState() {
    super.initState();
    _loadGradeOptions();
  }

  //Method to load the grade options based on the user's settings and the discipline of the session.
  Future<void> _loadGradeOptions() async {
    final settings = await SettingsService.loadSettings();
    final gradeSystem = GradeScaleService.systemForDiscipline(
      settings: settings,
      discipline: widget.discipline,
    );
    if (!mounted) return;
    setState(() {
      _gradeOptions = GradeScaleService.gradesForSystem(gradeSystem);
    });
  }

  //Method to add a new climb to the list with the current time and a unique ID.
  void addClimb() {
    setState(() {
      _climbs.add(
        /*Adding the new climb with the current time provided by the currentTimeProvider
        function and a unique ID based on the current timestamp.*/
        ClimbItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          time: widget.currentTimeProvider(),
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  //Method to clear all climbs from the list.
  void clearClimbs() {
    setState(() {
      _climbs.clear();
    });
  }

  //Method to remove a climb from the list based on its index.
  void removeClimb(int index) {
    setState(() {
      _climbs.removeAt(index);
    });
  }
  
  List<ClimbItem> getItems() => List.unmodifiable(_climbs);

  /*Build method to display the list of climbs and the button to add new climbs. Uses a ListView to display
  the climbs and the ClimbLogCard component for each climb item in the list.*/
  @override
  Widget build(BuildContext context) {
    //Sorting the climbs to show the most recent climb at the top.
    final sortedClimbs = [..._climbs]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Expanded(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              
              //Button to add a new climb, which calls the addClimb method when pressed.
              child: ElevatedButton(
                onPressed: addClimb,
                child: const Text(
                  'Add Climb',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                ),
              ),


            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:


            //In this section we show the user the meaning of each column in the climb list, with a title for each one.
            Row(
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
          //If there are no climbs, show a message. Otherwise, show the list of climbs using a ListView and the ClimbLogCard component for each climb.
          _climbs.isEmpty
              ? const Center(child: Text('No climbs added yet.'))
              : Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: sortedClimbs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox.shrink(),
                    itemBuilder: (context, index) {
                      final climb = sortedClimbs[index];
                      return ClimbLogCard(
                        key: ValueKey(climb.id),
                        time: climb.time,
                        grades: _gradeOptions,
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
                          final originalIndex = _climbs.indexWhere(
                            (item) => item.id == climb.id,
                          );
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
