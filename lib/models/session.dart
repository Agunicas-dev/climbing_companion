import 'package:isar/isar.dart';
import 'climb.dart';

part 'session.g.dart';

@Collection()
class Session {
  Id id = Isar.autoIncrement;
  late DateTime date;
  String totalTime = '';

  @Embedded()
  List<Climb> climbs = [];
}
