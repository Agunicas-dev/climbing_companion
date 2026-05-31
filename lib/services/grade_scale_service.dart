import 'package:climbing_companion/models/session_type.dart';
import 'package:climbing_companion/models/settings.dart';


/*Service responsible for managing the grading systems used in the app, including the Hueco (V-Scale) and Font
(Fontainebleau) systems. It provides functions to get the appropriate grading system based on user settings and
session discipline, as well as utility functions to normalize system names and calculate grade ranks for sorting purposes.*/


class GradeScaleService {
  const GradeScaleService._();

  static const hueco = 'hueco';
  static const font = 'font';

  static const List<String> huecoGrades = [
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
  ];

  static const List<String> fontGrades = [
    '3',
    '4',
    '5',
    '5+',
    '6A / 6A+',
    '6B / 6B+',
    '6C',
    '6C+ / 7A',
    '7A+',
    '7B / 7B+',
    '7C',
    '7C+',
    '8A',
    '8A+',
    '8B',
  ];

  static const List<String> supportedSystems = [hueco, font];

  //Returns a user-friendly label for the specified grading system, used in the UI to display the current system.
  static String labelForSystem(String system) {
    return switch (normalizeSystem(system)) {
      font => 'Font',
      _ => 'Hueco (V-Scale)',
    };
  }

  //Normalizes the grading system name to a standard format for internal use, allowing for flexible user input.
  static String normalizeSystem(String system) {
    final normalized = system.trim().toLowerCase();
    return switch (normalized) {
      'font' || 'fontainebleau' => font,
      _ => hueco,
    };
  }

  //Determines the appropriate grading system to use based on user settings and the discipline of the climbing session.
  static String systemForDiscipline({
    required Settings settings,
    required SessionDiscipline discipline,
  }) {
    if (!settings.useDisciplineGradeSystems) {
      return normalizeSystem(settings.gradingSystem);
    }

    return switch (discipline) {
      SessionDiscipline.boulder => hueco,
      SessionDiscipline.lead => font,
    };
  }

  //Returns the appropriate list of grades based on the specified grading system.
  static List<String> gradesForSystem(String system) {
    return switch (normalizeSystem(system)) {
      font => fontGrades,
      _ => huecoGrades,
    };
  }

  //Utility function to get a numeric rank for a given grade, used for sorting sessions by grade.
  static int gradeRank(String grade) {
    final normalizedGrade = grade.trim().toUpperCase();
    final huecoIndex = huecoGrades
        .map((grade) => grade.toUpperCase())
        .toList()
        .indexOf(normalizedGrade);
    if (huecoIndex != -1) return huecoIndex;

    final fontIndex = fontGrades
        .map((grade) => grade.toUpperCase())
        .toList()
        .indexOf(normalizedGrade);
    if (fontIndex != -1) return fontIndex;

    final vGradeMatch = RegExp(r'^V(\d+)$').firstMatch(normalizedGrade);
    if (vGradeMatch != null) {
      final value = int.tryParse(vGradeMatch.group(1) ?? '');
      if (value != null) return value + 1;
    }

    return -1;
  }
}
