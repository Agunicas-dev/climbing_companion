import 'package:flutter/material.dart';

class ClimbLogCard extends StatelessWidget {
  final String time;
  final VoidCallback? onDelete;
  final String? selectedGrade;
  final String? selectedCompletion;
  final ValueChanged<String?>? onGradeChanged;
  final ValueChanged<String?>? onCompletionChanged;

  const ClimbLogCard({
    super.key,
    required this.time,
    this.onDelete,
    this.selectedGrade,
    this.selectedCompletion,
    this.onGradeChanged,
    this.onCompletionChanged,
  });

  static const List<String> grades = [
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
  ];
  static const List<String> completions = ['Sent', 'Failed', 'Flash'];

  @override
  Widget build(BuildContext context) {
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
                items: grades.map((String value) {
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
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
