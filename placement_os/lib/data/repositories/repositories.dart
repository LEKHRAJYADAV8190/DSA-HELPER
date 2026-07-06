import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../data/datasources/roadmap_datasource.dart';
import '../../domain/entities/entities.dart';
import '../datasources/hive_service.dart';

String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class SeedService {
  SeedService(this._hive);
  final HiveService _hive;
  static const _seedKey = 'seed_v5';

  Future<int> seedIfNeeded() async {
    if (_hive.get(HiveBoxes.settings, _seedKey)?['done'] == true) {
      await _migrateProblems();
      await _syncPatternsFromAsset();
      return _totalQuestions();
    }

    // Legacy seed keys — migrate fields without wiping progress
    if (_hive.get(HiveBoxes.settings, 'seed_v4')?['done'] == true ||
        _hive.get(HiveBoxes.settings, 'seed_v3')?['done'] == true ||
        _hive.get(HiveBoxes.settings, 'seed_v2')?['done'] == true) {
      await _migrateProblems();
      await _syncPatternsFromAsset();
      await _hive.put(HiveBoxes.settings, _seedKey, {'done': true});
      return _totalQuestions();
    }

    await _hive.clear(HiveBoxes.problems);
    final jsonStr = await rootBundle.loadString(RoadmapRegistry.active.assetPath);
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final topics = data['topics'] as List<dynamic>;
    final problems = data['problems'] as List<dynamic>;
    final topicNames = <String, String>{};

    for (final topic in topics) {
      final map = Map<String, dynamic>.from(topic as Map);
      topicNames[map['id'] as String] = map['name'] as String;
      await _hive.put(HiveBoxes.problems, 'topic_${map['id']}', map);
    }

    for (final problem in problems) {
      final map = Map<String, dynamic>.from(problem as Map);
      final topicId = map['topicId'] as String;
      map['roadmapId'] = RoadmapRegistry.active.id;
      map['topicName'] = topicNames[topicId] ?? topicId;
      map['solved'] = false;
      map['starred'] = false;
      map['notes'] = '';
      map['notesStarred'] = false;
      map['revisionCount'] = 0;
      map['lastConfidence'] = 0;
      map['patterns'] = (map['patterns'] as List<dynamic>?)?.cast<String>() ?? [];
      await _hive.put(HiveBoxes.problems, map['id'] as String, map);
    }

    await _hive.put(HiveBoxes.settings, _seedKey, {'done': true});
    await _hive.put(HiveBoxes.settings, 'meta', {
      'totalQuestions': data['totalQuestions'] ?? problems.length,
      'roadmapId': 'striver_a2z',
    });

    return problems.length;
  }

  Future<void> _migrateProblems() async {
    for (final item in _hive.getAll(HiveBoxes.problems)) {
      if (!item.containsKey('topicId') || item.containsKey('problemIds')) continue;
      final map = Map<String, dynamic>.from(item);
      map['roadmapId'] ??= 'striver_a2z';
      map['notesStarred'] ??= false;
      map['revisionCount'] ??= 0;
      map['lastConfidence'] ??= 0;
      map['patterns'] ??= [];
      map.remove('nextRevision');
      await _hive.put(HiveBoxes.problems, map['id'] as String, map);
    }
  }

  Future<void> _syncPatternsFromAsset() async {
    final jsonStr = await rootBundle.loadString(RoadmapRegistry.active.assetPath);
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final problems = data['problems'] as List<dynamic>;
    for (final problem in problems) {
      final map = Map<String, dynamic>.from(problem as Map);
      final id = map['id'] as String;
      final existing = _hive.get(HiveBoxes.problems, id);
      if (existing == null || existing.containsKey('problemIds')) continue;
      final merged = Map<String, dynamic>.from(existing);
      merged['patterns'] = (map['patterns'] as List<dynamic>?)?.cast<String>() ?? [];
      await _hive.put(HiveBoxes.problems, id, merged);
    }
  }

  int _totalQuestions() {
    return _hive.get(HiveBoxes.settings, 'meta')?['totalQuestions'] as int? ??
        _hive.getAll(HiveBoxes.problems).where((e) => e.containsKey('topicId')).length;
  }
}

class ProblemRepository {
  ProblemRepository(this._hive);
  final HiveService _hive;

  int get totalQuestions {
    return _hive.get(HiveBoxes.settings, 'meta')?['totalQuestions'] as int? ??
        getAllProblems().length;
  }

  List<TopicEntity> getTopics() {
    return _hive
        .getAll(HiveBoxes.problems)
        .where((e) => e.containsKey('problemIds'))
        .map(_toTopic)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  List<ProblemEntity> getAllProblems() {
    return _hive
        .getAll(HiveBoxes.problems)
        .where((e) => e.containsKey('topicId') && !e.containsKey('problemIds'))
        .map(_toProblem)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  List<ProblemEntity> filter(ProblemFilter f, {Set<String>? revisionDueIds}) {
    final all = getAllProblems();
    return switch (f) {
      ProblemFilter.all => all,
      ProblemFilter.starred => all.where((p) => p.starred).toList(),
      ProblemFilter.solved => all.where((p) => p.solved).toList(),
      ProblemFilter.unsolved => all.where((p) => !p.solved).toList(),
      ProblemFilter.hasNotes => all.where((p) => p.hasNotes).toList(),
      ProblemFilter.revisionDue => all
          .where((p) => revisionDueIds?.contains(p.id) ?? false)
          .toList(),
    };
  }

  List<String> getAllPatterns() {
    final patterns = <String>{};
    for (final p in getAllProblems()) {
      patterns.addAll(p.patterns);
    }
    return patterns.toList()..sort();
  }

  List<PatternStats> getPatternStats() {
    final map = <String, PatternStats>{};
    for (final p in getAllProblems()) {
      for (final pattern in p.patterns) {
        final current = map[pattern];
        if (current == null) {
          map[pattern] = PatternStats(
            name: pattern,
            total: 1,
            solved: p.solved ? 1 : 0,
            remaining: p.solved ? 0 : 1,
          );
        } else {
          map[pattern] = PatternStats(
            name: pattern,
            total: current.total + 1,
            solved: current.solved + (p.solved ? 1 : 0),
            remaining: current.remaining + (p.solved ? 0 : 1),
          );
        }
      }
    }
    return map.values.toList()..sort((a, b) => b.total.compareTo(a.total));
  }

  List<ProblemEntity> byPattern(String pattern) {
    return getAllProblems()
        .where((p) => p.hasPattern(pattern))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  List<ProblemEntity> queryProblems(
    ProblemSearchQuery q, {
    Set<String>? revisionDueIds,
  }) {
    var list = getAllProblems();
    if (q.filter != ProblemFilter.all) {
      list = filter(q.filter, revisionDueIds: revisionDueIds);
    }
    if (q.topicId != null) {
      list = list.where((p) => p.topicId == q.topicId).toList();
    }
    if (q.pattern != null && q.pattern!.isNotEmpty) {
      list = list.where((p) => p.hasPattern(q.pattern!)).toList();
    }
    if (q.difficulty != null) {
      list = list.where((p) => p.difficulty == q.difficulty).toList();
    }
    if (q.text.trim().isNotEmpty) {
      final text = q.text.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(text) ||
            p.topicName.toLowerCase().contains(text) ||
            p.notes.toLowerCase().contains(text) ||
            p.patterns.any((pat) => pat.toLowerCase().contains(text)) ||
            p.difficulty.name.contains(text);
      }).toList();
    }
    return list;
  }

  ProblemEntity? getById(String id) {
    final data = _hive.get(HiveBoxes.problems, id);
    return data == null ? null : _toProblem(data);
  }

  Future<ProblemEntity> toggleSolved(String id) async {
    final problem = getById(id);
    if (problem == null) throw StateError('Problem not found');
    final updated = problem.copyWith(
      solved: !problem.solved,
      dateSolved: !problem.solved ? DateTime.now() : null,
      clearDateSolved: problem.solved,
    );
    await _save(updated);
    return updated;
  }

  Future<ProblemEntity> toggleStar(String id) async {
    final problem = getById(id);
    if (problem == null) throw StateError('Problem not found');
    final updated = problem.copyWith(starred: !problem.starred);
    await _save(updated);
    return updated;
  }

  Future<ProblemEntity> saveNotes(String id, String notes) async {
    final problem = getById(id);
    if (problem == null) throw StateError('Problem not found');
    final updated = problem.copyWith(
      notes: notes,
      notesUpdatedAt: DateTime.now(),
    );
    await _save(updated);
    return updated;
  }

  Future<ProblemEntity> toggleNotesStar(String id) async {
    final problem = getById(id);
    if (problem == null) throw StateError('Problem not found');
    final updated = problem.copyWith(notesStarred: !problem.notesStarred);
    await _save(updated);
    return updated;
  }

  Future<void> deleteNotes(String id) async {
    final problem = getById(id);
    if (problem == null || !problem.hasNotes) return;
    await _hive.put(HiveBoxes.settings, 'deleted_note', {
      'problemId': id,
      'notes': problem.notes,
      'deletedAt': DateTime.now().toIso8601String(),
    });
    await _save(problem.copyWith(notes: '', notesUpdatedAt: DateTime.now()));
  }

  Future<bool> undoDeleteNotes() async {
    final data = _hive.get(HiveBoxes.settings, 'deleted_note');
    if (data == null) return false;
    final id = data['problemId'] as String;
    final notes = data['notes'] as String;
    final problem = getById(id);
    if (problem == null) return false;
    await _save(problem.copyWith(notes: notes, notesUpdatedAt: DateTime.now()));
    await _hive.delete(HiveBoxes.settings, 'deleted_note');
    return true;
  }

  DeletedNoteEntity? getDeletedNote() {
    final data = _hive.get(HiveBoxes.settings, 'deleted_note');
    if (data == null) return null;
    return DeletedNoteEntity(
      problemId: data['problemId'] as String,
      notes: data['notes'] as String,
      deletedAt: DateTime.parse(data['deletedAt'] as String),
    );
  }

  Future<ProblemEntity> recordRevision(String id, {int confidence = 0}) async {
    final problem = getById(id);
    if (problem == null) throw StateError('Problem not found');
    final now = DateTime.now();
    final updated = problem.copyWith(
      revisionCount: problem.revisionCount + 1,
      revisionDate: now,
      lastConfidence: confidence > 0 ? confidence : problem.lastConfidence,
    );
    await _save(updated);
    await _hive.put(HiveBoxes.revisionHistory, '${id}_${now.millisecondsSinceEpoch}', {
      'id': '${id}_${now.millisecondsSinceEpoch}',
      'problemId': id,
      'completedAt': now.toIso8601String(),
      'confidence': confidence,
    });
    return updated;
  }

  List<RevisionHistoryEntity> historyFor(String problemId) {
    return _hive
        .getAll(HiveBoxes.revisionHistory)
        .where((e) => e['problemId'] == problemId)
        .map((e) => RevisionHistoryEntity(
              id: e['id'] as String,
              problemId: e['problemId'] as String,
              completedAt: DateTime.parse(e['completedAt'] as String),
              confidence: e['confidence'] as int? ?? 0,
            ))
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  int get solvedCount => getAllProblems().where((p) => p.solved).length;
  int get starredCount => getAllProblems().where((p) => p.starred).length;
  int get notesCount => getAllProblems().where((p) => p.hasNotes).length;

  List<ProblemEntity> search(String query, {ProblemFilter? filter, Set<String>? revisionDueIds}) {
    if (query.trim().isEmpty) return [];
    return queryProblems(
      ProblemSearchQuery(text: query, filter: filter ?? ProblemFilter.all),
      revisionDueIds: revisionDueIds,
    );
  }

  List<ProblemEntity> notesList({NotesSort sort = NotesSort.topic, String? query}) {
    var list = getAllProblems().where((p) => p.hasNotes).toList();
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.notes.toLowerCase().contains(q) ||
          p.topicName.toLowerCase().contains(q)).toList();
    }
    switch (sort) {
      case NotesSort.topic:
        list.sort((a, b) {
          final c = a.topicName.compareTo(b.topicName);
          return c != 0 ? c : a.order.compareTo(b.order);
        });
      case NotesSort.recentlyUpdated:
        list.sort((a, b) =>
            (b.notesUpdatedAt ?? DateTime(0)).compareTo(a.notesUpdatedAt ?? DateTime(0)));
      case NotesSort.starred:
        list.sort((a, b) {
          if (a.notesStarred != b.notesStarred) return a.notesStarred ? -1 : 1;
          return a.name.compareTo(b.name);
        });
    }
    return list;
  }

  Future<void> _save(ProblemEntity entity) async {
    await _hive.put(HiveBoxes.problems, entity.id, _fromProblem(entity));
  }

  Future<void> resetProgress() async {
    for (final p in getAllProblems()) {
      await _save(p.copyWith(
        solved: false,
        starred: false,
        notes: '',
        notesStarred: false,
        clearDateSolved: true,
        revisionCount: 0,
        lastConfidence: 0,
        clearRevisionDate: true,
      ));
    }
    await _hive.clear(HiveBoxes.revisionHistory);
    await _hive.clear(HiveBoxes.tasks);
  }

  Future<Map<String, dynamic>> exportData() async {
    return {
      'problems': getAllProblems().map(_fromProblem).toList(),
      'tasks': _hive.getAll(HiveBoxes.tasks),
      'settings': _hive.get(HiveBoxes.settings, 'user'),
      'revisionHistory': _hive.getAll(HiveBoxes.revisionHistory),
      'shortNotes': _hive.getAll(HiveBoxes.shortNotes),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    for (final item in data['problems'] as List<dynamic>? ?? []) {
      final map = Map<String, dynamic>.from(item as Map);
      await _hive.put(HiveBoxes.problems, map['id'] as String, map);
    }
    await _hive.clear(HiveBoxes.tasks);
    for (final item in data['tasks'] as List<dynamic>? ?? []) {
      final map = Map<String, dynamic>.from(item as Map);
      await _hive.put(HiveBoxes.tasks, map['id'] as String, map);
    }
    await _hive.clear(HiveBoxes.revisionHistory);
    for (final item in data['revisionHistory'] as List<dynamic>? ?? []) {
      final map = Map<String, dynamic>.from(item as Map);
      await _hive.put(HiveBoxes.revisionHistory, map['id'] as String, map);
    }
    final settings = data['settings'];
    if (settings != null) {
      await _hive.put(HiveBoxes.settings, 'user', Map<String, dynamic>.from(settings as Map));
    }
    await _hive.clear(HiveBoxes.shortNotes);
    for (final item in data['shortNotes'] as List<dynamic>? ?? []) {
      final map = Map<String, dynamic>.from(item as Map);
      await _hive.put(HiveBoxes.shortNotes, map['id'] as String, map);
    }
  }

  TopicEntity _toTopic(Map<String, dynamic> json) => TopicEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        order: json['order'] as int? ?? 0,
        problemIds: (json['problemIds'] as List<dynamic>).cast<String>(),
      );

  ProblemEntity _toProblem(Map<String, dynamic> json) => ProblemEntity(
        id: json['id'] as String,
        roadmapId: json['roadmapId'] as String? ?? 'striver_a2z',
        topicId: json['topicId'] as String,
        topicName: json['topicName'] as String? ?? '',
        name: json['name'] as String,
        difficulty: _difficulty(json['difficulty'] as String? ?? 'medium'),
        order: json['order'] as int? ?? 0,
        patterns: (json['patterns'] as List<dynamic>?)?.cast<String>() ?? [],
        solved: json['solved'] as bool? ?? false,
        starred: json['starred'] as bool? ?? false,
        notes: json['notes'] as String? ?? '',
        notesStarred: json['notesStarred'] as bool? ?? false,
        notesUpdatedAt: json['notesUpdatedAt'] != null
            ? DateTime.parse(json['notesUpdatedAt'] as String)
            : null,
        dateSolved: json['dateSolved'] != null
            ? DateTime.parse(json['dateSolved'] as String)
            : null,
        revisionDate: json['revisionDate'] != null
            ? DateTime.parse(json['revisionDate'] as String)
            : null,
        revisionCount: json['revisionCount'] as int? ?? 0,
        lastConfidence: json['lastConfidence'] as int? ?? 0,
      );

  Map<String, dynamic> _fromProblem(ProblemEntity e) => {
        'id': e.id,
        'roadmapId': e.roadmapId,
        'topicId': e.topicId,
        'topicName': e.topicName,
        'name': e.name,
        'difficulty': e.difficulty.name,
        'order': e.order,
        'patterns': e.patterns,
        'solved': e.solved,
        'starred': e.starred,
        'notes': e.notes,
        'notesStarred': e.notesStarred,
        'notesUpdatedAt': e.notesUpdatedAt?.toIso8601String(),
        'dateSolved': e.dateSolved?.toIso8601String(),
        'revisionDate': e.revisionDate?.toIso8601String(),
        'revisionCount': e.revisionCount,
        'lastConfidence': e.lastConfidence,
      };

  Difficulty _difficulty(String value) {
    switch (value.toLowerCase()) {
      case 'easy':
        return Difficulty.easy;
      case 'hard':
        return Difficulty.hard;
      default:
        return Difficulty.medium;
    }
  }
}

class TaskRepository {
  TaskRepository(this._hive);
  final HiveService _hive;

  List<TaskEntity> getAll() {
    return _hive
        .getAll(HiveBoxes.tasks)
        .map(_toTask)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<TaskEntity> addUserTask(String title) async {
    final today = _dateKey(DateTime.now());
    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final task = TaskEntity(
      id: id,
      title: title,
      scheduledDate: today,
      order: getAll().length,
      type: TaskType.user,
    );
    await save(task);
    return task;
  }

  Future<TaskEntity> update(String id, {String? title, bool? completed}) async {
    final task = getAll().firstWhere((t) => t.id == id);
    final updated = task.copyWith(title: title, completed: completed);
    await save(updated);
    return updated;
  }

  Future<void> delete(String id) => _hive.delete(HiveBoxes.tasks, id);

  Future<void> save(TaskEntity task) async {
    await _hive.put(HiveBoxes.tasks, task.id, _fromTask(task));
  }

  Future<void> clearAutoTasks() async {
    for (final t in getAll().where((t) => t.isAuto)) {
      await delete(t.id);
    }
  }

  Future<void> clearAutoRevisionTasks() => clearAutoTasks();

  bool get allCompletedToday {
    final today = _dateKey(DateTime.now());
    final tasks = getAll().where((t) => t.scheduledDate == today);
    return tasks.isNotEmpty && tasks.every((t) => t.completed);
  }

  double progressToday() {
    final today = _dateKey(DateTime.now());
    final tasks = getAll().where((t) => t.scheduledDate == today).toList();
    if (tasks.isEmpty) return 0;
    return tasks.where((t) => t.completed).length / tasks.length;
  }

  TaskEntity _toTask(Map<String, dynamic> e) {
    final typeStr = e['type'] as String? ?? 'user';
    final type = switch (typeStr) {
      'revision' => TaskType.revision,
      'newQuestion' => TaskType.newQuestion,
      'starRevision' => TaskType.starRevision,
      _ => TaskType.user,
    };
    return TaskEntity(
        id: e['id'] as String,
        title: e['title'] as String,
        scheduledDate: e['scheduledDate'] as String? ?? _dateKey(DateTime.now()),
        completed: e['completed'] as bool? ?? false,
        order: e['order'] as int? ?? 0,
        type: type,
        problemId: e['problemId'] as String?,
      );
  }

  Map<String, dynamic> _fromTask(TaskEntity t) => {
        'id': t.id,
        'title': t.title,
        'scheduledDate': t.scheduledDate,
        'completed': t.completed,
        'order': t.order,
        'type': switch (t.type) {
          TaskType.revision => 'revision',
          TaskType.newQuestion => 'newQuestion',
          TaskType.starRevision => 'starRevision',
          TaskType.user => 'user',
        },
        'problemId': t.problemId,
      };
}

class SettingsRepository {
  SettingsRepository(this._hive);
  final HiveService _hive;

  AppSettingsEntity get() {
    final data = _hive.get(HiveBoxes.settings, 'user');
    if (data == null) return const AppSettingsEntity();
    return AppSettingsEntity(
      darkMode: data['darkMode'] as bool? ?? true,
      dailyNewQuestions: data['dailyNewQuestions'] as int? ?? 3,
      revisionsPerDay: data['revisionsPerDay'] as int? ?? 3,
      dailyStarRevision: data['dailyStarRevision'] as int? ?? 2,
      revisionQueueIndex: data['revisionQueueIndex'] as int? ?? 0,
      starRevisionQueueIndex: data['starRevisionQueueIndex'] as int? ?? 0,
      morningNotificationHour: data['morningNotificationHour'] as int? ?? 9,
      morningNotificationMinute: data['morningNotificationMinute'] as int? ?? 0,
      eveningNotificationHour: data['eveningNotificationHour'] as int? ?? 19,
      eveningNotificationMinute: data['eveningNotificationMinute'] as int? ?? 0,
      streak: data['streak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      lastActiveDate: data['lastActiveDate'] != null
          ? DateTime.parse(data['lastActiveDate'] as String)
          : null,
      todaySolved: data['todaySolved'] as int? ?? 0,
      lastSolvedDate: data['lastSolvedDate'] != null
          ? DateTime.parse(data['lastSolvedDate'] as String)
          : null,
      todayRevisionCount: data['todayRevisionCount'] as int? ?? 0,
      todayNewQuestionsCount: data['todayNewQuestionsCount'] as int? ?? 0,
      todayStarRevisionCount: data['todayStarRevisionCount'] as int? ?? 0,
      lastRevisionCountDate: data['lastRevisionCountDate'] != null
          ? DateTime.parse(data['lastRevisionCountDate'] as String)
          : null,
      lastNewQuestionsCountDate: data['lastNewQuestionsCountDate'] != null
          ? DateTime.parse(data['lastNewQuestionsCountDate'] as String)
          : null,
      lastStarRevisionCountDate: data['lastStarRevisionCountDate'] != null
          ? DateTime.parse(data['lastStarRevisionCountDate'] as String)
          : null,
      lastTaskSyncDate: data['lastTaskSyncDate'] != null
          ? DateTime.parse(data['lastTaskSyncDate'] as String)
          : null,
      revisionAccuracyTotal: data['revisionAccuracyTotal'] as int? ?? 0,
      revisionAccuracyCount: data['revisionAccuracyCount'] as int? ?? 0,
      activePatternFilter: data['activePatternFilter'] as String?,
      todayRevisionDayStartIndex: data['todayRevisionDayStartIndex'] as int? ?? 0,
      todayStarRevisionDayStartIndex: data['todayStarRevisionDayStartIndex'] as int? ?? 0,
    );
  }

  Future<AppSettingsEntity> save(AppSettingsEntity settings) async {
    await _hive.put(HiveBoxes.settings, 'user', {
      'darkMode': settings.darkMode,
      'dailyNewQuestions': settings.dailyNewQuestions,
      'revisionsPerDay': settings.revisionsPerDay,
      'dailyStarRevision': settings.dailyStarRevision,
      'revisionQueueIndex': settings.revisionQueueIndex,
      'starRevisionQueueIndex': settings.starRevisionQueueIndex,
      'morningNotificationHour': settings.morningNotificationHour,
      'morningNotificationMinute': settings.morningNotificationMinute,
      'eveningNotificationHour': settings.eveningNotificationHour,
      'eveningNotificationMinute': settings.eveningNotificationMinute,
      'streak': settings.streak,
      'longestStreak': settings.longestStreak,
      'lastActiveDate': settings.lastActiveDate?.toIso8601String(),
      'todaySolved': settings.todaySolved,
      'lastSolvedDate': settings.lastSolvedDate?.toIso8601String(),
      'todayRevisionCount': settings.todayRevisionCount,
      'todayNewQuestionsCount': settings.todayNewQuestionsCount,
      'todayStarRevisionCount': settings.todayStarRevisionCount,
      'lastRevisionCountDate': settings.lastRevisionCountDate?.toIso8601String(),
      'lastNewQuestionsCountDate': settings.lastNewQuestionsCountDate?.toIso8601String(),
      'lastStarRevisionCountDate': settings.lastStarRevisionCountDate?.toIso8601String(),
      'lastTaskSyncDate': settings.lastTaskSyncDate?.toIso8601String(),
      'revisionAccuracyTotal': settings.revisionAccuracyTotal,
      'revisionAccuracyCount': settings.revisionAccuracyCount,
      'activeRoadmapId': settings.activeRoadmapId,
      'activePatternFilter': settings.activePatternFilter,
      'todayRevisionDayStartIndex': settings.todayRevisionDayStartIndex,
      'todayStarRevisionDayStartIndex': settings.todayStarRevisionDayStartIndex,
    });
    return settings;
  }

  Future<AppSettingsEntity> recordActivity() async {
    final s = get();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var streak = s.streak;
    var longest = s.longestStreak;

    if (s.lastActiveDate != null) {
      final last = DateTime(s.lastActiveDate!.year, s.lastActiveDate!.month, s.lastActiveDate!.day);
      final diff = today.difference(last).inDays;
      if (diff == 1) {
        streak += 1;
      } else if (diff > 1) {
        streak = 1;
      }
    } else {
      streak = 1;
    }
    if (streak > longest) longest = streak;

    return save(s.copyWith(streak: streak, longestStreak: longest, lastActiveDate: today));
  }

  Future<AppSettingsEntity> recordSolved() async {
    final s = get();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var todaySolved = s.todaySolved;
    if (s.lastSolvedDate == null ||
        !DateTime(s.lastSolvedDate!.year, s.lastSolvedDate!.month, s.lastSolvedDate!.day)
            .isAtSameMomentAs(today)) {
      todaySolved = 1;
    } else {
      todaySolved += 1;
    }
    return save(s.copyWith(todaySolved: todaySolved, lastSolvedDate: today));
  }

  Future<void> resetRevisionQueue() async {
    final s = get();
    await save(s.copyWith(
      revisionQueueIndex: 0,
      starRevisionQueueIndex: 0,
      todayRevisionCount: 0,
      todayNewQuestionsCount: 0,
      todayStarRevisionCount: 0,
    ));
  }
}

class ShortNotesRepository {
  ShortNotesRepository(this._hive);
  final HiveService _hive;

  List<ShortNoteEntity> getAll() {
    return _hive
        .getAll(HiveBoxes.shortNotes)
        .map(_toNote)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<ShortNoteEntity> add({required String text, String title = ''}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Note text cannot be empty');
    }
    final now = DateTime.now();
    final note = ShortNoteEntity(
      id: 'sn_${now.millisecondsSinceEpoch}',
      title: title.trim(),
      text: trimmed,
      createdAt: now,
      updatedAt: now,
      order: getAll().length,
    );
    await save(note);
    return note;
  }

  Future<ShortNoteEntity> update(String id, {String? title, String? text}) async {
    final note = getAll().firstWhere((n) => n.id == id);
    final updated = note.copyWith(
      title: title ?? note.title,
      text: text?.trim() ?? note.text,
      updatedAt: DateTime.now(),
    );
    await save(updated);
    return updated;
  }

  Future<void> delete(String id) => _hive.delete(HiveBoxes.shortNotes, id);

  Future<void> save(ShortNoteEntity note) async {
    await _hive.put(HiveBoxes.shortNotes, note.id, _fromNote(note));
  }

  ShortNoteEntity _toNote(Map<String, dynamic> e) => ShortNoteEntity(
        id: e['id'] as String,
        title: e['title'] as String? ?? '',
        text: e['text'] as String,
        createdAt: DateTime.parse(e['createdAt'] as String),
        updatedAt: e['updatedAt'] != null ? DateTime.parse(e['updatedAt'] as String) : null,
        order: e['order'] as int? ?? 0,
      );

  Map<String, dynamic> _fromNote(ShortNoteEntity n) => {
        'id': n.id,
        'title': n.title,
        'text': n.text,
        'createdAt': n.createdAt.toIso8601String(),
        'updatedAt': n.updatedAt?.toIso8601String(),
        'order': n.order,
      };
}
