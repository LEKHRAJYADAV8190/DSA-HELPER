import '../entities/entities.dart';
import '../../data/repositories/repositories.dart';

class DailyNewQuestionsService {
  DailyNewQuestionsService(this._problems, this._settings);

  final ProblemRepository _problems;
  final SettingsRepository _settings;

  List<ProblemEntity> get unsolvedInOrder {
    return _problems
        .getAllProblems()
        .where((p) => !p.solved)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  List<ProblemEntity> get todayBatch {
    final settings = _settings.get();
    final perDay = settings.dailyNewQuestions;
    if (_todayCompleted(settings) >= perDay) return [];
    final unsolved = unsolvedInOrder;
    if (unsolved.isEmpty) return [];
    return unsolved.take(perDay).toList();
  }

  bool get isTodayComplete {
    final settings = _settings.get();
    return _todayCompleted(settings) >= settings.dailyNewQuestions ||
        unsolvedInOrder.isEmpty;
  }

  int _todayCompleted(AppSettingsEntity settings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (settings.lastNewQuestionsCountDate == null ||
        !_sameDay(settings.lastNewQuestionsCountDate!, today)) {
      return 0;
    }
    return settings.todayNewQuestionsCount;
  }

  Future<void> recordNewQuestionSolved() async {
    final settings = _settings.get();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var count = settings.todayNewQuestionsCount;
    if (settings.lastNewQuestionsCountDate == null ||
        !_sameDay(settings.lastNewQuestionsCountDate!, today)) {
      count = 1;
    } else {
      count += 1;
    }
    await _settings.save(settings.copyWith(
      todayNewQuestionsCount: count,
      lastNewQuestionsCountDate: today,
    ));
  }

  Future<void> undoNewQuestionSolved() async {
    final settings = _settings.get();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (settings.lastNewQuestionsCountDate == null ||
        !_sameDay(settings.lastNewQuestionsCountDate!, today) ||
        settings.todayNewQuestionsCount <= 0) {
      return;
    }
    await _settings.save(settings.copyWith(
      todayNewQuestionsCount: settings.todayNewQuestionsCount - 1,
    ));
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
