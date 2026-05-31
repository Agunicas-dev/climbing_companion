import '../models/climb.dart';
import '../models/session.dart';
import 'grade_scale_service.dart';
import 'isar_service.dart';

//Service responsible for calculating various climbing statistics based on the sessions and climbs data stored in Isar.
//It provides methods to retrieve global statistics across all sessions, as well as specific statistics for individual sessions or sets of climbs.


class StatisticsService {
  const StatisticsService._();
  /*_________________________________________________________________________________________________
  Section dedicated to calculating global statistics across all sessions using the data stored in Isar.
  ____________________________________________________________________________________________________*/

  //Reads every saved session from Isar.
  static Future<GlobalClimbingStatistics> getGlobalStatistics() async {
    final sessions = await IsarService.getAllSessions();
    return GlobalClimbingStatistics.fromSessions(sessions);
  }

  //Gets the number of climbs for each session, used for the climbs by session statistic.
  static Future<List<SessionChartPoint>> getGlobalClimbsBySession() async {
    final statistics = await getGlobalStatistics();
    return statistics.climbsBySession;
  }

  //Gets the total duration for each session, used for the duration by session statistic.
  static Future<List<SessionChartPoint>> getGlobalDurationBySession() async {
    final statistics = await getGlobalStatistics();
    return statistics.durationBySession;
  }

  //Gets the grade distribution for all climbs, used for the grade distribution chart.
  static Future<List<CategoryChartPoint>> getGlobalGradeDistribution() async {
    final statistics = await getGlobalStatistics();
    return statistics.gradeDistribution;
  }

  //Gets the completion distribution for all climbs, used for the completion distribution chart.
  static Future<List<CategoryChartPoint>>
  getGlobalCompletionDistribution() async {
    final statistics = await getGlobalStatistics();
    return statistics.completionDistribution;
  }

/*_______________________________________________________________________________________________________________________________________
  Section dedicated to calculating statistics for a specific session or set of climbs, based on the data of that session or those climbs.
  ______________________________________________________________________________________________________________________________________*/

  //Getter for loading only the session or climbs passed to it.
  static SessionClimbingStatistics getSessionStatistics(Session session) {
    return SessionClimbingStatistics.fromSession(session);
  }

  //Gets the statistics for a specific set of climbs and then formats the total time of the session to be displayed in the session statistics summary.
  static SessionClimbingStatistics getStatisticsForClimbs({
    required DateTime date,
    required String totalTime,
    required List<Climb> climbs,
  }) {
    return SessionClimbingStatistics(
      date: date,
      totalTime: totalTime,
      totalDuration: _durationFromStopwatch(totalTime),
      climbs: List<Climb>.unmodifiable(climbs),
    );
  }

  //
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
  final List<Climb> allClimbs;
  final int totalClimbs;
  final Duration totalDuration;
  final List<CategoryChartPoint> gradeDistribution;
  final List<CategoryChartPoint> completionDistribution;
  final List<CategoryChartPoint> successDistribution;
  final List<SessionChartPoint> maxGradeTimeline;
  final List<SessionChartPoint> climbsBySession;
  final List<SessionChartPoint> durationBySession;
  final Duration averageRestTime;

  //Private constructor to initialize all the statistics fields, used by the factory constructor to create an instance from a list of sessions.
  const GlobalClimbingStatistics._({
    required this.sessions,
    required this.allClimbs,
    required this.totalClimbs,
    required this.totalDuration,
    required this.gradeDistribution,
    required this.completionDistribution,
    required this.successDistribution,
    required this.maxGradeTimeline,
    required this.climbsBySession,
    required this.durationBySession,
    required this.averageRestTime,
  });

  //Factory constructor to create an instance of GlobalClimbingStatistics from a list of sessions, calculating all the relevant statistics based on the climbs data of those sessions.
  factory GlobalClimbingStatistics.fromSessions(List<Session> sessions) {
    final sortedSessions = [...sessions]
      ..sort((a, b) => a.date.compareTo(b.date));
    final immutableSessions = List<Session>.unmodifiable(sortedSessions);

    final allClimbs = List<Climb>.unmodifiable(
      immutableSessions.expand((session) => session.climbs),
    );

    final totalClimbs = allClimbs.length;

    final totalDuration = immutableSessions.fold(Duration.zero, (total, session) {
      return total +
          StatisticsService._durationFromStopwatch(session.totalTime);
    });

    final gradeDistribution = _categoryDistribution(
      allClimbs.map((climb) => climb.grade),
      sortGrades: true,
    );

    final completionDistribution = _categoryDistribution(
      allClimbs.map((climb) => climb.completion),
    );

    //Calculating the success distribution.
    final successCounts = <String, int>{'Sends': 0, 'Flashes': 0, 'Fails': 0};
    for (final climb in allClimbs) {
      final completion = _cleanCategory(climb.completion);
      if (completion == 'Sent') {
        successCounts['Sends'] = successCounts['Sends']! + 1;
      } else if (completion == 'Flash') {
        successCounts['Flashes'] = successCounts['Flashes']! + 1;
      } else if (completion == 'Failed') {
        successCounts['Fails'] = successCounts['Fails']! + 1;
      }
    }
    final successDistribution = successCounts.entries
        .map((e) => CategoryChartPoint(category: e.key, value: e.value))
        .toList();

    final maxGradeTimeline = <SessionChartPoint>[];
    if (immutableSessions.isNotEmpty) {
      var currentMaxRank = -1;
      String? currentMaxGrade;

      for (final session in immutableSessions) {
        var sessionMaxRank = -1;
        String? sessionMaxGrade;

        for (final climb in session.climbs) {
          final grade = _cleanCategory(climb.grade);
          final rank = _gradeValue(grade);
          if (rank > sessionMaxRank) {
            sessionMaxRank = rank;
            sessionMaxGrade = grade;
          }
        }

        if (sessionMaxRank > currentMaxRank) {
          currentMaxRank = sessionMaxRank;
          currentMaxGrade = sessionMaxGrade;
        }

        maxGradeTimeline.add(SessionChartPoint(
          date: session.date,
          value: currentMaxRank,
          label: _shortDateLabel(session.date),
          extra: currentMaxGrade,
        ));
      }
    }

    //Calculating the climbs by session and duration by session statistics, creating a SessionChartPoint for each session with the relevant data.
    final climbsBySession = immutableSessions.map((session) {
      return SessionChartPoint(
        date: session.date,
        value: session.climbs.length,
        label: _shortDateLabel(session.date),
      );
    }).toList();

    //Calculating the duration by session statistic, creating a SessionChartPoint for each session with the total duration of that session in minutes.
    final durationBySession = immutableSessions.map((session) {
      return SessionChartPoint(
        date: session.date,
        value: StatisticsService._durationFromStopwatch(session.totalTime)
            .inMinutes,
        label: _shortDateLabel(session.date),
      );
    }).toList();

    //Calculating the average rest time between climbs across all sessions, by first calculating the gaps between climbs in each session and then averaging those gaps.
    final gaps = <int>[];
    for (final session in immutableSessions) {
      final climbSeconds =
          session.climbs
              .map(
                (climb) => StatisticsService._durationFromStopwatch(
                  climb.time,
                ).inSeconds,
              )
              .toList()
            ..sort();

      for (var index = 1; index < climbSeconds.length; index++) {
        final gap = climbSeconds[index] - climbSeconds[index - 1];
        if (gap > 0) gaps.add(gap);
      }
    }
    final averageRestTime = gaps.isEmpty
        ? Duration.zero
        : Duration(
          seconds: gaps.fold<int>(0, (total, gap) => total + gap) ~/ gaps.length,
        );


    return GlobalClimbingStatistics._(
      sessions: immutableSessions,
      allClimbs: allClimbs,
      totalClimbs: totalClimbs,
      totalDuration: totalDuration,
      gradeDistribution: gradeDistribution,
      completionDistribution: completionDistribution,
      successDistribution: successDistribution,
      maxGradeTimeline: List<SessionChartPoint>.unmodifiable(maxGradeTimeline),
      climbsBySession: List<SessionChartPoint>.unmodifiable(climbsBySession),
      durationBySession: List<SessionChartPoint>.unmodifiable(durationBySession),
      averageRestTime: averageRestTime,
    );
  }

  //Calculating some simple statistics per session.
  int get sessionCount => sessions.length;

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

  //Calculating the flash grade, which is the hardest grade with a flash rate of at least 60%,
  //by first grouping climbs by grade and then calculating the flash rate for each grade and display the highest.
  String? get flashGrade {
    final climbsByGrade = <String, List<Climb>>{};
    for (final climb in allClimbs) {
      final grade = _cleanCategory(climb.grade);
      if (_gradeValue(grade) == -1) continue;
      climbsByGrade.putIfAbsent(grade, () => []).add(climb);
    }

    String? highestFlashGrade;
    var highestGradeValue = -1;
    for (final entry in climbsByGrade.entries) {
      final flashCount = entry.value
          .where((climb) => climb.completion == 'Flash')
          .length;
      final flashRate = flashCount / entry.value.length;
      final gradeValue = _gradeValue(entry.key);
      if (flashRate >= 0.6 && gradeValue > highestGradeValue) {
        highestFlashGrade = entry.key;
        highestGradeValue = gradeValue;
      }
    }

    return highestFlashGrade;
  }


  //Calculating the number of months since the first session, used for the sessions timeline statistic to determine how many months to display.
  List<SessionChartPoint> sessionsLastNMonths(int n) {
    final now = DateTime.now();
    final localNow = DateTime(now.year, now.month, now.day);
    final monthsToGenerate = n <= 0 ? _monthsSinceFirstSession(localNow) : n;
    
    final lastNMonths = List.generate(monthsToGenerate, (i) {
      return DateTime(localNow.year, localNow.month - (monthsToGenerate - 1 - i), 1);
    });

    final counts = <DateTime, int>{};
    for (final month in lastNMonths) {
      counts[month] = 0;
    }

    for (final session in sessions) {
      final localDate = session.date.toLocal();
      final sessionMonth = DateTime(localDate.year, localDate.month, 1);
      if (counts.containsKey(sessionMonth)) {
        counts[sessionMonth] = counts[sessionMonth]! + 1;
      }
    }

    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return lastNMonths.asMap().entries.map((entry) {
      final i = entry.key;
      final month = entry.value;
      
      String label;
      if (monthsToGenerate > 12) {
        // For long ranges, only show the year for the first month of each year
        // Use zero-width spaces to keep labels unique while appearing empty
        if (month.month == 1 || i == 0) {
          label = "'${month.year.toString().substring(2)}";
        } else {
          label = '\u200B' * i;
        }
      } else {
        label = monthNames[month.month - 1];
      }

      return SessionChartPoint(
        date: month,
        value: counts[month]!,
        label: label,
      );
    }).toList();
  }

  int _monthsSinceFirstSession(DateTime now) {
    if (sessions.isEmpty) return 1;
    final first = sessions.first.date.toLocal();
    return (now.year - first.year) * 12 + now.month - first.month + 1;
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
      climbs: List<Climb>.unmodifiable(session.climbs),
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

  List<GradeCompletionChartPoint> get gradeCompletionBreakdown {
    return _gradeCompletionBreakdown(climbs);
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
  final dynamic extra;

  const SessionChartPoint({
    required this.date,
    required this.value,
    required this.label,
    this.extra,
  });

  Map<String, Object> toMap() {
    return {
      'date': date,
      'value': value,
      'label': label,
      if (extra != null) 'extra': extra as Object,
    };
  }
}

class GradeCompletionChartPoint {
  final String grade;
  final String completion;
  final int value;

  const GradeCompletionChartPoint({
    required this.grade,
    required this.completion,
    required this.value,
  });

  Map<String, Object> toMap() {
    return {'grade': grade, 'completion': completion, 'value': value};
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

class HeatmapChartPoint {
  final String x;
  final String y;
  final num value;

  const HeatmapChartPoint({
    required this.x,
    required this.y,
    required this.value,
  });
}

List<GradeCompletionChartPoint> _gradeCompletionBreakdown(List<Climb> climbs) {
  final grades =
      climbs.map((climb) => _cleanCategory(climb.grade)).toSet().toList()
        ..sort((a, b) => _gradeValue(a).compareTo(_gradeValue(b)));
  const completions = ['Sent', 'Flash', 'Failed'];
  final counts = <String, Map<String, int>>{};

  for (final climb in climbs) {
    final grade = _cleanCategory(climb.grade);
    final completion = _cleanCategory(climb.completion);
    if (!completions.contains(completion)) continue;

    counts.putIfAbsent(grade, () => {});
    counts[grade]![completion] = (counts[grade]![completion] ?? 0) + 1;
  }

  return [
    for (final grade in grades)
      for (final completion in completions)
        GradeCompletionChartPoint(
          grade: grade,
          completion: completion,
          value: counts[grade]?[completion] ?? 0,
        ),
  ];
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
  return GradeScaleService.gradeRank(grade);
}

String _shortDateLabel(DateTime date) {
  final local = date.toLocal();
  final year = local.year.toString().substring(2);
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$month/$day/\'$year';
}
