import '../entities/entities.dart';
import '../../data/repositories/repositories.dart';

class StarRevisionService {
  StarRevisionService(this._problems, this._settings);

  final ProblemRepository _problems;
  final SettingsRepository _settings;

  List<ProblemEntity> get starredInOrder {
    return _problems
        .getAllProblems()
        .where((p) => p.starred)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  List<ProblemEntity> get todayBatch {
    final starred = starredInOrder;
    final settings = _settings.get();
    final perDay = settings.dailyStarRevision;
    if (starred.isEmpty) return [];
    if (_todayCompleted(settings) >= perDay) return [];

    final position = settings.starRevisionQueueIndex % starred.length;
    final queue = starred.sublist(position) + starred.sublist(0, position);
    return queue.take(perDay).toList();
  }

  bool get isTodayComplete {
    final settings = _settings.get();
    return starredInOrder.isEmpty ||
        _todayCompleted(settings) >= settings.dailyStarRevision;
  }

  int _todayCompleted(AppSettingsEntity settings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (settings.lastStarRevisionCountDate == null ||
        !_sameDay(settings.lastStarRevisionCountDate!, today)) {
      return 0;
    }
    return settings.todayStarRevisionCount;
  }

  Future<void> completeStarRevision(String problemId) async {
    final starred = starredInOrder;
    if (starred.isEmpty) return;

    await _problems.recordRevision(problemId);

    final settings = _settings.get();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var count = settings.todayStarRevisionCount;
    if (settings.lastStarRevisionCountDate == null ||
        !_sameDay(settings.lastStarRevisionCountDate!, today)) {
      count = 1;
    } else {
      count += 1;
    }

    await _settings.save(settings.copyWith(
      starRevisionQueueIndex: settings.starRevisionQueueIndex + 1,
      todayStarRevisionCount: count,
      lastStarRevisionCountDate: today,
    ));
  }

  Future<void> undoStarRevision() async {
    final settings = _settings.get();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (settings.lastStarRevisionCountDate == null ||
        !_sameDay(settings.lastStarRevisionCountDate!, today) ||
        settings.todayStarRevisionCount <= 0) {
      return;
    }
    await _settings.save(settings.copyWith(
      starRevisionQueueIndex: settings.starRevisionQueueIndex - 1,
      todayStarRevisionCount: settings.todayStarRevisionCount - 1,
    ));
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
