import 'package:flutter/material.dart';

//A card widget that represents a single climb log entry. It displays the time of the climb,
//allows the user to select the grade and completion status, and provides a delete button to remove the log entry.
//The grade dropdown includes all standard bouldering grades, and if a non-standard grade is selected, it
//is added to the top of the dropdown list for easy access. The completion dropdown includes options for "Sent",
//"Failed", and "Flash". This widget is used in the session review screen to display and edit individual climb logs.

class ClimbLogCard extends StatelessWidget {
  final String time;
  final VoidCallback? onDelete;
  final String? selectedGrade;
  final String? selectedCompletion;
  final List<String> grades;
  final ValueChanged<String?>? onGradeChanged;
  final ValueChanged<String?>? onCompletionChanged;

  const ClimbLogCard({
    super.key,
    required this.time,
    this.onDelete,
    this.selectedGrade,
    this.selectedCompletion,
    this.grades = const [
      'VB',
      'V0',
      'V1',
      'V2',
      'V3',
      'V4',
      'V5',
      'V6',
      'V7',
      'V8',
      'V9',
      'V10',
      'V11',
      'V12',
      'V13',
    ],
    this.onGradeChanged,
    this.onCompletionChanged,
  });

  static const List<String> completions = ['Sent', 'Failed', 'Flash'];

  @override
  Widget build(BuildContext context) {
    final gradeOptions =
        selectedGrade != null && !grades.contains(selectedGrade)
        ? [selectedGrade!, ...grades]
        : grades;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DropdownButton<String>(
                value: selectedGrade,
                hint: const Text('Grade'),
                items: gradeOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: onGradeChanged,
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: selectedCompletion,
                hint: const Text('Completion'),
                items: completions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: onCompletionChanged,
              ),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.close), onPressed: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}
