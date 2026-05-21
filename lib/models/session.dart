import 'package:isar/isar.dart';
import 'climb.dart';

part 'session.g.dart';

//Class for the climbing session, which will be stored in Isar. It contains a date, total time, and a list of climbs.
@Collection()
class Session {
  Id id = Isar.autoIncrement;
  late DateTime date;
  String totalTime = '';

  // ignore: invalid_annotation_target
  @Embedded()
  List<Climb> climbs = [];
}
