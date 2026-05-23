import 'package:climbing_companion/models/session_type.dart';
import 'package:flutter/material.dart';

class SessionTypeDialog extends StatefulWidget {
  const SessionTypeDialog({super.key});

  @override
  State<SessionTypeDialog> createState() => _SessionTypeDialogState();
}

class _SessionTypeDialogState extends State<SessionTypeDialog> {
  SessionEnvironment _environment = SessionType.defaultType.environment;
  SessionDiscipline _discipline = SessionType.defaultType.discipline;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start session'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Location', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<SessionEnvironment>(
              segments: const [
                ButtonSegment(
                  value: SessionEnvironment.indoor,
                  icon: Icon(Icons.home_work),
                  label: Text('Indoor'),
                ),
                ButtonSegment(
                  value: SessionEnvironment.outdoor,
                  icon: Icon(Icons.landscape),
                  label: Text('Outdoor'),
                ),
              ],
              selected: {_environment},
              onSelectionChanged: (values) {
                setState(() {
                  _environment = values.first;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Text('Style', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<SessionDiscipline>(
              segments: const [
                ButtonSegment(
                  value: SessionDiscipline.boulder,
                  icon: Icon(Icons.terrain),
                  label: Text('Boulder'),
                ),
                ButtonSegment(
                  value: SessionDiscipline.lead,
                  icon: Icon(Icons.vertical_align_top),
                  label: Text('Lead'),
                ),
              ],
              selected: {_discipline},
              onSelectionChanged: (values) {
                setState(() {
                  _discipline = values.first;
                });
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              SessionType(environment: _environment, discipline: _discipline),
            );
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}
