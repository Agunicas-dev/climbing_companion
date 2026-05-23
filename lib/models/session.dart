import 'package:isar/isar.dart';
import 'climb.dart';
import 'session_type.dart';

part 'session.g.dart';

//Class for the climbing session, which will be stored in Isar. It contains a date, total time, and a list of climbs.
@Collection()
class Session {
  Id id = Isar.autoIncrement;
  late DateTime date;
  String totalTime = '';
  String environment = SessionEnvironment.indoor.storageValue;
  String discipline = SessionDiscipline.boulder.storageValue;

  // ignore: invalid_annotation_target
  @Embedded()
  List<Climb> climbs = [];

  @ignore
  String get environmentLabel => sessionEnvironmentLabel(environment);

  @ignore
  String get disciplineLabel => sessionDisciplineLabel(discipline);
}
