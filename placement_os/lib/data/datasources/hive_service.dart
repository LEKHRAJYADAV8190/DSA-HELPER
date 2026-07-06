import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';

class HiveService {
  HiveService._();
  static final HiveService instance = HiveService._();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Map>(HiveBoxes.problems),
      Hive.openBox<Map>(HiveBoxes.tasks),
      Hive.openBox<Map>(HiveBoxes.settings),
      Hive.openBox<Map>(HiveBoxes.revisionHistory),
      Hive.openBox<Map>(HiveBoxes.shortNotes),
    ]);
    _ready = true;
  }

  Box<Map> box(String name) => Hive.box<Map>(name);

  Future<void> put(String boxName, String key, Map<String, dynamic> value) {
    return box(boxName).put(key, value);
  }

  Map<String, dynamic>? get(String boxName, String key) {
    final data = box(boxName).get(key);
    return data == null ? null : Map<String, dynamic>.from(data);
  }

  Future<void> delete(String boxName, String key) => box(boxName).delete(key);

  List<Map<String, dynamic>> getAll(String boxName) {
    return box(boxName).values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> clear(String boxName) => box(boxName).clear();
}
