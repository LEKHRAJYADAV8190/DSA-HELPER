import '../entities/entities.dart';
import '../../data/repositories/repositories.dart';

class SmartRevisionService {
  SmartRevisionService(this._problems, this._settings);

  final ProblemRepository _problems;
  final SettingsRepository _settings;

  List<ProblemEntity> get solvedInOrder {
    final settings = _settings.get();
    var list = _problems
        .getAllProblems()
        .where((p) => p.solved)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final pattern = settings.activePatternFilter;
    if (pattern != null && pattern.isNotEmpty) {
      list = list.where((p) => p.hasPattern(pattern)).toList();
    }
    return list;
  }

  bool isRevisionDue(ProblemEntity p) {
    if (!p.solved) return false;
    return getState().todayBatch.any((x) => x.id == p.id);
  }

  RevisionQueueState getState() {
    final solved = solvedInOrder;
    final settings = _settings.get();
    final perDay = settings.revisionsPerDay;
    final position =
        solved.isEmpty ? 0 : settings.revisionQueueIndex % solved.length;
    final dayStart = solved.isEmpty
        ? 0
        : settings.todayRevisionDayStartIndex % solved.length;
    final completed = position;
    final remaining = solved.isEmpty ? 0 : solved.length - position;
    final queueRemaining =
        solved.isEmpty ? <ProblemEntity>[] : solved.sublist(position);

    final todayCompleted = _todayCompletedCount(settings);
    final isTodayComplete =
        todayCompleted >= perDay || queueRemaining.isEmpty || solved.isEmpty;

    final todayBatch = isTodayComplete
        ? <ProblemEntity>[]
        : queueRemaining.take(perDay).toList();

    final tomorrowIndex = (dayStart + perDay) % (solved.isEmpty ? 1 : solved.length);
    final tomorrowBatch = _batchFrom(solved, tomorrowIndex, perDay);

    final cycle =
        solved.isEmpty ? 0 : (settings.revisionQueueIndex ~/ solved.length) + 1;

    return RevisionQueueState(
      solvedCount: solved.length,
      revisionCompleted: completed,
      remaining: remaining,
      currentPosition: solved.isEmpty ? 0 : position + 1,
      todayBatch: todayBatch,
      tomorrowBatch: tomorrowBatch,
      queueRemaining: queueRemaining,
      cycleNumber: cycle,
      todayCompleted: todayCompleted,
      todayTarget: perDay,
      isTodayComplete: isTodayComplete,
    );
  }

  List<ProblemEntity> _batchFrom(List<ProblemEntity> solved, int start, int count) {
    if (solved.isEmpty || count <= 0) return [];
    final result = <ProblemEntity>[];
    for (var i = 0; i < count; i++) {
      result.add(solved[(start + i) % solved.length]);
    }
    return result;
  }

  int _todayCompletedCount(AppSettingsEntity settings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (settings.lastRevisionCountDate == null ||
        !_isSameDay(settings.lastRevisionCountDate!, today)) {
      return 0;
    }
    return settings.todayRevisionCount;
  }

  bool isInTodayBatch(String problemId) {
    return getState().todayBatch.any((p) => p.id == problemId);
  }

  Future<void> completeSequentialRevision(String problemId, {int confidence = 0}) async {
    final solved = solvedInOrder;
    if (solved.isEmpty) return;

    await _problems.recordRevision(problemId, confidence: confidence);

    final settings = _settings.get();
    final newIndex = settings.revisionQueueIndex + 1;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var todayRevision = settings.todayRevisionCount;
    if (settings.lastRevisionCountDate == null ||
        !_isSameDay(settings.lastRevisionCountDate!, today)) {
      todayRevision = 1;
    } else {
      todayRevision += 1;
    }

    var accuracyTotal = settings.revisionAccuracyTotal;
    var accuracyCount = settings.revisionAccuracyCount;
    if (confidence > 0) {
      accuracyTotal += confidence;
      accuracyCount += 1;
    }

    await _settings.save(settings.copyWith(
      revisionQueueIndex: newIndex,
      todayRevisionCount: todayRevision,
      lastRevisionCountDate: today,
      revisionAccuracyTotal: accuracyTotal,
      revisionAccuracyCount: accuracyCount,
    ));
  }

  Future<void> setPatternFilter(String? pattern) async {
    final s = _settings.get();
    await _settings.save(
      pattern == null
          ? s.copyWith(clearPatternFilter: true)
          : s.copyWith(activePatternFilter: pattern),
    );
  }

  Future<void> undoSequentialRevision() async {
    final settings = _settings.get();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (settings.lastRevisionCountDate == null ||
        !_isSameDay(settings.lastRevisionCountDate!, today) ||
        settings.todayRevisionCount <= 0) {
      return;
    }
    await _settings.save(settings.copyWith(
      revisionQueueIndex: settings.revisionQueueIndex - 1,
      todayRevisionCount: settings.todayRevisionCount - 1,
    ));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
