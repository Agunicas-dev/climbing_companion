import '../models/climb.dart';
import '../models/session.dart';
import 'isar_service.dart';

class StatisticsService {
  const StatisticsService._();

  //Global statistics: reads every saved session from Isar.
  static Future<GlobalClimbingStatistics> getGlobalStatistics() async {
    final sessions = await IsarService.getAllSessions();
    return GlobalClimbingStatistics.fromSessions(sessions);
  }

  static Future<List<SessionChartPoint>> getGlobalClimbsBySession() async {
    final statistics = await getGlobalStatistics();
    return statistics.climbsBySession;
  }

  static Future<List<SessionChartPoint>> getGlobalDurationBySession() async {
    final statistics = await getGlobalStatistics();
    return statistics.durationBySession;
  }

  static Future<List<CategoryChartPoint>> getGlobalGradeDistribution() async {
    final statistics = await getGlobalStatistics();
    return statistics.gradeDistribution;
  }

  static Future<List<CategoryChartPoint>>
  getGlobalCompletionDistribution() async {
    final statistics = await getGlobalStatistics();
    return statistics.completionDistribution;
  }

  //Session statistics: uses only the session or climbs passed to it.
  static SessionClimbingStatistics getSessionStatistics(Session session) {
    return SessionClimbingStatistics.fromSession(session);
  }

  static SessionClimbingStatistics getStatisticsForClimbs({
    required DateTime date,
    required String totalTime,
    required List<Climb> climbs,
  }) {
    return SessionClimbingStatistics(
      date: date,
      totalTime: totalTime,
      totalDuration: _durationFromStopwatch(totalTime),
      climbs: List.unmodifiable(climbs),
    );
  }

  static Duration _durationFromStopwatch(String value) {
    final parts = value.split(':').map(int.tryParse).toList();
    if (parts.length == 3 && parts.every((part) => part != null)) {
      return Duration(hours: parts[0]!, minutes: parts[1]!, seconds: parts[2]!);
    }
    if (parts.length == 2 && parts.every((part) => part != null)) {
      return Duration(minutes: parts[0]!, seconds: parts[1]!);
    }
    return Duration.zero;
  }
}

//Class used to calculate and store various climbing statistics based on the sessions and climbs data.
class GlobalClimbingStatistics {
  final List<Session> sessions;

  const GlobalClimbingStatistics._(this.sessions);

  factory GlobalClimbingStatistics.fromSessions(List<Session> sessions) {
    final sortedSessions = [...sessions]
      ..sort((a, b) => a.date.compareTo(b.date));
    return GlobalClimbingStatistics._(List.unmodifiable(sortedSessions));
  }

  int get sessionCount => sessions.length;

  int get totalClimbs =>
      sessions.fold(0, (total, session) => total + session.climbs.length);

  Duration get totalDuration {
    return sessions.fold(Duration.zero, (total, session) {
      return total +
          StatisticsService._durationFromStopwatch(session.totalTime);
    });
  }

  double get averageClimbsPerSession {
    if (sessionCount == 0) return 0;
    return totalClimbs / sessionCount;
  }

  Duration get averageSessionDuration {
    if (sessionCount == 0) return Duration.zero;
    return Duration(seconds: totalDuration.inSeconds ~/ sessionCount);
  }

  int get completedClimbs => _countWhereCompletion(
    (completion) => _isSuccessfulCompletion(completion),
  );

  int get failedClimbs =>
      _countWhereCompletion((completion) => completion == 'Failed');

  int get flashClimbs =>
      _countWhereCompletion((completion) => completion == 'Flash');

  double get completionRate {
    if (totalClimbs == 0) return 0;
    return completedClimbs / totalClimbs;
  }

  String? get hardestGrade {
    return _hardestGrade(allClimbs.map((climb) => climb.grade));
  }

  String? get hardestSuccessfulGrade {
    return _hardestGrade(
      allClimbs
          .where((climb) => _isSuccessfulCompletion(climb.completion))
          .map((climb) => climb.grade),
    );
  }

  List<Climb> get allClimbs {
    return List.unmodifiable(sessions.expand((session) => session.climbs));
  }

  List<SessionChartPoint> get climbsBySession {
    return sessions
        .map((session) {
          return SessionChartPoint(
            date: session.date,
            value: session.climbs.length,
            label: _shortDateLabel(session.date),
          );
        })
        .toList(growable: false);
  }

  List<SessionChartPoint> get durationBySession {
    return sessions
        .map((session) {
          return SessionChartPoint(
            date: session.date,
            value: StatisticsService._durationFromStopwatch(
              session.totalTime,
            ).inMinutes,
            label: _shortDateLabel(session.date),
          );
        })
        .toList(growable: false);
  }

  List<CategoryChartPoint> get gradeDistribution {
    return _categoryDistribution(
      allClimbs.map((climb) => climb.grade),
      sortGrades: true,
    );
  }

  List<CategoryChartPoint> get completionDistribution {
    return _categoryDistribution(allClimbs.map((climb) => climb.completion));
  }

  int _countWhereCompletion(bool Function(String? completion) test) {
    return allClimbs.where((climb) => test(climb.completion)).length;
  }
}

//Class used to calculate and store various climbing statistics for a specific session based on the climbs data of that session.
class SessionClimbingStatistics {
  final DateTime date;
  final String totalTime;
  final Duration totalDuration;
  final List<Climb> climbs;

  const SessionClimbingStatistics({
    required this.date,
    required this.totalTime,
    required this.totalDuration,
    required this.climbs,
  });

  factory SessionClimbingStatistics.fromSession(Session session) {
    return SessionClimbingStatistics(
      date: session.date,
      totalTime: session.totalTime,
      totalDuration: StatisticsService._durationFromStopwatch(
        session.totalTime,
      ),
      climbs: List.unmodifiable(session.climbs),
    );
  }

  int get totalClimbs => climbs.length;

  int get completedClimbs =>
      climbs.where((climb) => _isSuccessfulCompletion(climb.completion)).length;

  int get failedClimbs =>
      climbs.where((climb) => climb.completion == 'Failed').length;

  int get flashClimbs =>
      climbs.where((climb) => climb.completion == 'Flash').length;

  double get completionRate {
    if (totalClimbs == 0) return 0;
    return completedClimbs / totalClimbs;
  }

  String? get hardestGrade {
    return _hardestGrade(climbs.map((climb) => climb.grade));
  }

  String? get hardestSuccessfulGrade {
    return _hardestGrade(
      climbs
          .where((climb) => _isSuccessfulCompletion(climb.completion))
          .map((climb) => climb.grade),
    );
  }

  Duration get averageTimePerClimb {
    if (climbs.isEmpty) return Duration.zero;
    return Duration(seconds: totalDuration.inSeconds ~/ climbs.length);
  }

  Duration get averageTimeBetweenClimbs {
    if (climbs.length < 2) return Duration.zero;

    final climbSeconds =
        climbs
            .map(
              (climb) => StatisticsService._durationFromStopwatch(
                climb.time,
              ).inSeconds,
            )
            .toList()
          ..sort();
    final gaps = <int>[];
    for (var index = 1; index < climbSeconds.length; index++) {
      gaps.add(climbSeconds[index] - climbSeconds[index - 1]);
    }

    final totalGapSeconds = gaps.fold(0, (total, gap) => total + gap);
    return Duration(seconds: totalGapSeconds ~/ gaps.length);
  }

  List<CategoryChartPoint> get gradeDistribution {
    return _categoryDistribution(
      climbs.map((climb) => climb.grade),
      sortGrades: true,
    );
  }

  List<CategoryChartPoint> get completionDistribution {
    return _categoryDistribution(climbs.map((climb) => climb.completion));
  }

  List<ClimbTimelinePoint> get climbTimeline {
    return climbs
        .asMap()
        .entries
        .map((entry) {
          final climb = entry.value;
          return ClimbTimelinePoint(
            climbNumber: entry.key + 1,
            time: climb.time,
            grade: climb.grade ?? 'Unknown',
            completion: climb.completion ?? 'Unknown',
            secondsFromStart: StatisticsService._durationFromStopwatch(
              climb.time,
            ).inSeconds,
          );
        })
        .toList(growable: false);
  }
}

class CategoryChartPoint {
  final String category;
  final int value;

  const CategoryChartPoint({required this.category, required this.value});

  Map<String, Object> toMap() {
    return {'category': category, 'value': value};
  }
}

class SessionChartPoint {
  final DateTime date;
  final num value;
  final String label;

  const SessionChartPoint({
    required this.date,
    required this.value,
    required this.label,
  });

  Map<String, Object> toMap() {
    return {'date': date, 'value': value, 'label': label};
  }
}

class ClimbTimelinePoint {
  final int climbNumber;
  final String time;
  final String grade;
  final String completion;
  final int secondsFromStart;

  const ClimbTimelinePoint({
    required this.climbNumber,
    required this.time,
    required this.grade,
    required this.completion,
    required this.secondsFromStart,
  });

  Map<String, Object> toMap() {
    return {
      'climbNumber': climbNumber,
      'time': time,
      'grade': grade,
      'completion': completion,
      'secondsFromStart': secondsFromStart,
    };
  }
}

List<CategoryChartPoint> _categoryDistribution(
  Iterable<String?> values, {
  bool sortGrades = false,
}) {
  final counts = <String, int>{};
  for (final value in values) {
    final category = _cleanCategory(value);
    counts[category] = (counts[category] ?? 0) + 1;
  }

  final entries = counts.entries.toList();
  if (sortGrades) {
    entries.sort((a, b) => _gradeValue(a.key).compareTo(_gradeValue(b.key)));
  } else {
    entries.sort((a, b) => a.key.compareTo(b.key));
  }

  return entries
      .map((entry) {
        return CategoryChartPoint(category: entry.key, value: entry.value);
      })
      .toList(growable: false);
}

String _cleanCategory(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return 'Unknown';
  return trimmed;
}

bool _isSuccessfulCompletion(String? completion) {
  return completion == 'Sent' || completion == 'Flash';
}

String? _hardestGrade(Iterable<String?> grades) {
  String? hardest;
  var hardestValue = -1;

  for (final grade in grades) {
    final cleanGrade = _cleanCategory(grade);
    final value = _gradeValue(cleanGrade);
    if (value > hardestValue) {
      hardest = cleanGrade;
      hardestValue = value;
    }
  }

  return hardestValue == -1 ? null : hardest;
}

int _gradeValue(String grade) {
  final match = RegExp(
    r'^V(\d+)$',
    caseSensitive: false,
  ).firstMatch(grade.trim());
  if (match == null) return -1;
  return int.tryParse(match.group(1) ?? '') ?? -1;
}

String _shortDateLabel(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$month/$day';
}
