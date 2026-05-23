import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/session.dart';
import '../models/climb.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> openIsar() async {
    if (_isar != null) return _isar!;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([SessionSchema], directory: dir.path);
    return _isar!;
  }

  static Future<Session> saveSession(
    DateTime date,
    String totalTime,
    List<Climb> climbs, {
    required String environment,
    required String discipline,
  }) async {
    final isar = await openIsar();
    final session = Session()
      ..date = date
      ..totalTime = totalTime
      ..environment = environment
      ..discipline = discipline
      ..climbs = climbs;

    await isar.writeTxn(() async {
      await isar.sessions.put(session);
    });
    
    return session;
  }

  static Future<List<Session>> getAllSessions() async {
    final isar = await openIsar();
    return await isar.sessions.where().sortByDateDesc().findAll();
  }

  static Future<Session?> getSessionById(int id) async {
    final isar = await openIsar();
    return await isar.sessions.get(id);
  }

  static Future<bool> deleteSession(int id) async {
    final isar = await openIsar();
    return await isar.writeTxn(() async {
      return await isar.sessions.delete(id);
    });
  }
}
