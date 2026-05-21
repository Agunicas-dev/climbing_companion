import 'package:isar/isar.dart';

part 'climb.g.dart';

//Class for the climb, which will be embedded in the session. It contains the time, grade, and completion status of the climb.
@Embedded()
class Climb {
  late String time;
  String? grade;
  String? completion;

  Climb();
}
