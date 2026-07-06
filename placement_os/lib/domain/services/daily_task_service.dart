import '../entities/entities.dart';
import '../../data/repositories/repositories.dart';
import 'daily_new_questions_service.dart';
import 'smart_revision_service.dart';
import 'star_revision_service.dart';

class DailyTaskService {
  DailyTaskService(
    this._tasks,
    this._problems,
    this._settings,
    this._revision,
    this._newQuestions,
    this._starRevision,
  );

  final TaskRepository _tasks;
  final ProblemRepository _problems;
  final SettingsRepository _settings;
  final SmartRevisionService _revision;
  final DailyNewQuestionsService _newQuestions;
  final StarRevisionService _starRevision;

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  TodayTasksState getTodayState() {
    final settings = _settings.get();
    final userTasks = todayTasks().where((t) => t.type == TaskType.user).toList();
    final newItems = _itemsForType(TaskType.newQuestion);
    final revItems = _itemsForType(TaskType.revision);
    final starItems = _itemsForType(TaskType.starRevision);

    return TodayTasksState(
      newQuestions: newItems,
      revisions: revItems,
      starRevisions: starItems,
      userTasks: userTasks,
      newQuestionsDone: newItems.where((t) => t.completed).length,
      newQuestionsTarget: settings.dailyNewQuestions,
      revisionsDone: revItems.where((t) => t.completed).length,
      revisionsTarget: settings.revisionsPerDay,
      starRevisionsDone: starItems.where((t) => t.completed).length,
      starRevisionsTarget: settings.dailyStarRevision,
    );
  }

  List<TodayProblemTask> _itemsForType(TaskType type) {
    final today = dateKey(DateTime.now());
    final tasks = _tasks
        .getAll()
        .where((t) => t.type == type && t.scheduledDate == today)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return tasks
        .map((task) {
          final id = task.problemId;
          if (id == null) return null;
          final problem = _problems.getById(id);
          if (problem == null) return null;
          return TodayProblemTask(
            problem: problem,
            completed: task.completed,
            taskId: task.id,
          );
        })
        .whereType<TodayProblemTask>()
        .toList();
  }

  Future<void> syncForToday() async {
    final today = dateKey(DateTime.now());
    final settings = _settings.get();
    if (settings.lastTaskSyncDate != null &&
        dateKey(settings.lastTaskSyncDate!) == today) {
      await _ensureTodayAutoTasks();
      return;
    }

    final existing = _tasks.getAll();
    final incompleteUser = existing
        .where((t) => t.type == TaskType.user && !t.completed)
        .toList();

    await _tasks.clearAutoTasks();

    var order = 0;
    for (final t in incompleteUser) {
      await _tasks.save(t.copyWith(scheduledDate: today, order: order++));
    }

    await _settings.save(settings.copyWith(
      lastTaskSyncDate: DateTime.now(),
      todayRevisionDayStartIndex: settings.revisionQueueIndex,
      todayStarRevisionDayStartIndex: settings.starRevisionQueueIndex,
      todayRevisionCount: 0,
      todayNewQuestionsCount: 0,
      todayStarRevisionCount: 0,
      lastRevisionCountDate: null,
      lastNewQuestionsCountDate: null,
      lastStarRevisionCountDate: null,
    ));

    await _persistAutoTasks(today, order);
  }

  Future<void> _ensureTodayAutoTasks() async {
    final today = dateKey(DateTime.now());
    final settings = _settings.get();
    final now = DateTime.now();
    var order = _nextTaskOrder(today);

    if (!_hasTypeToday(TaskType.newQuestion, today)) {
      final solvedToday = _problems
          .getAllProblems()
          .where((p) => p.dateSolved != null && _sameDay(p.dateSolved!, now))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      final perDay = settings.dailyNewQuestions;
      final doneToday = solvedToday.take(perDay).toList();
      for (final p in doneToday) {
        await _tasks.save(TaskEntity(
          id: 'new_${today}_${p.id}',
          title: p.name,
          scheduledDate: today,
          order: order++,
          type: TaskType.newQuestion,
          problemId: p.id,
          completed: true,
        ));
      }
      final remaining = perDay - doneToday.length;
      if (remaining > 0) {
        for (final p in _newQuestions.unsolvedInOrder.take(remaining)) {
          await _tasks.save(TaskEntity(
            id: 'new_${today}_${p.id}',
            title: p.name,
            scheduledDate: today,
            order: order++,
            type: TaskType.newQuestion,
            problemId: p.id,
            completed: false,
          ));
        }
      }
    }

    if (!_hasTypeToday(TaskType.revision, today)) {
      for (final p in _revisionSnapshot(settings)) {
        await _tasks.save(TaskEntity(
          id: 'rev_${today}_${p.id}',
          title: p.name,
          scheduledDate: today,
          order: order++,
          type: TaskType.revision,
          problemId: p.id,
          completed: _revisedToday(p, now),
        ));
      }
    }

    if (!_hasTypeToday(TaskType.starRevision, today)) {
      for (final p in _starRevisionSnapshot(settings)) {
        await _tasks.save(TaskEntity(
          id: 'star_${today}_${p.id}',
          title: p.name,
          scheduledDate: today,
          order: order++,
          type: TaskType.starRevision,
          problemId: p.id,
          completed: _revisedToday(p, now),
        ));
      }
    }
  }

  bool _hasTypeToday(TaskType type, String today) {
    return _tasks.getAll().any((t) => t.type == type && t.scheduledDate == today);
  }

  int _nextTaskOrder(String today) {
    final orders = _tasks
        .getAll()
        .where((t) => t.scheduledDate == today)
        .map((t) => t.order);
    if (orders.isEmpty) return 0;
    return orders.reduce((a, b) => a > b ? a : b) + 1;
  }

  List<ProblemEntity> _revisionSnapshot(AppSettingsEntity settings) {
    final solved = _revision.solvedInOrder;
    if (solved.isEmpty) return [];
    final start = settings.todayRevisionDayStartIndex % solved.length;
    return _takeRotating(solved, start, settings.revisionsPerDay);
  }

  List<ProblemEntity> _starRevisionSnapshot(AppSettingsEntity settings) {
    final starred = _starRevision.starredInOrder;
    if (starred.isEmpty) return [];
    final start = settings.todayStarRevisionDayStartIndex % starred.length;
    return _takeRotating(starred, start, settings.dailyStarRevision);
  }

  List<ProblemEntity> _takeRotating(List<ProblemEntity> list, int start, int count) {
    if (list.isEmpty || count <= 0) return [];
    final result = <ProblemEntity>[];
    for (var i = 0; i < count; i++) {
      result.add(list[(start + i) % list.length]);
    }
    return result;
  }

  bool _revisedToday(ProblemEntity p, DateTime now) {
    final date = p.revisionDate;
    if (date == null) return false;
    return _sameDay(date, now);
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _persistAutoTasks(String today, int startOrder) async {
    var order = startOrder;

    for (final p in _newQuestions.todayBatch) {
      await _tasks.save(TaskEntity(
        id: 'new_${today}_${p.id}',
        title: p.name,
        scheduledDate: today,
        order: order++,
        type: TaskType.newQuestion,
        problemId: p.id,
      ));
    }
    for (final p in _revision.getState().todayBatch) {
      await _tasks.save(TaskEntity(
        id: 'rev_${today}_${p.id}',
        title: p.name,
        scheduledDate: today,
        order: order++,
        type: TaskType.revision,
        problemId: p.id,
      ));
    }
    for (final p in _starRevision.todayBatch) {
      await _tasks.save(TaskEntity(
        id: 'star_${today}_${p.id}',
        title: p.name,
        scheduledDate: today,
        order: order++,
        type: TaskType.starRevision,
        problemId: p.id,
      ));
    }
  }

  List<TaskEntity> todayTasks() {
    final today = dateKey(DateTime.now());
    return _tasks.getAll().where((t) => t.scheduledDate == today).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  List<TaskEntity> notificationTasks() {
    return todayTasks().where((t) => !t.completed).toList();
  }

  TaskEntity? _autoTask(TaskType type, String problemId) {
    final today = dateKey(DateTime.now());
    for (final t in _tasks.getAll()) {
      if (t.type == type && t.problemId == problemId && t.scheduledDate == today) {
        return t;
      }
    }
    return null;
  }

  Future<void> toggleNewQuestion(String problemId, bool completed) async {
    final task = _autoTask(TaskType.newQuestion, problemId);
    if (task == null || task.completed == completed) return;

    if (completed) {
      await _newQuestions.recordNewQuestionSolved();
      final problem = _problems.getById(problemId);
      if (problem != null && !problem.solved) {
        await _problems.toggleSolved(problemId);
      }
    } else {
      await _newQuestions.undoNewQuestionSolved();
      final problem = _problems.getById(problemId);
      if (problem != null && problem.solved) {
        await _problems.toggleSolved(problemId);
      }
    }
    await _tasks.update(task.id, completed: completed);
  }

  Future<void> toggleRevision(String problemId, bool completed) async {
    final task = _autoTask(TaskType.revision, problemId);
    if (task == null || task.completed == completed) return;

    if (completed) {
      await _revision.completeSequentialRevision(problemId);
    } else {
      await _revision.undoSequentialRevision();
    }
    await _tasks.update(task.id, completed: completed);
  }

  Future<void> toggleStarRevision(String problemId, bool completed) async {
    final task = _autoTask(TaskType.starRevision, problemId);
    if (task == null || task.completed == completed) return;

    if (completed) {
      await _starRevision.completeStarRevision(problemId);
    } else {
      await _starRevision.undoStarRevision();
    }
    await _tasks.update(task.id, completed: completed);
  }

  Future<void> completeNewQuestion(String problemId) =>
      toggleNewQuestion(problemId, true);

  Future<void> completeRevision(String problemId) => toggleRevision(problemId, true);

  Future<void> completeStarRevision(String problemId) =>
      toggleStarRevision(problemId, true);

  Future<void> completeTask(TaskEntity task) async {
    if (task.type == TaskType.user) {
      await _tasks.update(task.id, completed: true);
      return;
    }
    if (task.problemId == null) return;
    switch (task.type) {
      case TaskType.newQuestion:
        await toggleNewQuestion(task.problemId!, true);
      case TaskType.revision:
        await toggleRevision(task.problemId!, true);
      case TaskType.starRevision:
        await toggleStarRevision(task.problemId!, true);
      case TaskType.user:
        break;
    }
  }

  Future<void> reorderUserTasks(List<TaskEntity> userTasks) async {
    final auto = getTodayState();
    var order = auto.newQuestions.length + auto.revisions.length + auto.starRevisions.length;
    for (var i = 0; i < userTasks.length; i++) {
      await _tasks.save(userTasks[i].copyWith(order: order + i));
    }
  }
}
