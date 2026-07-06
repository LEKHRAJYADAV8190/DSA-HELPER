import 'package:equatable/equatable.dart';

enum Difficulty { easy, medium, hard }

enum TaskType { user, revision, newQuestion, starRevision }

enum ProblemFilter {
  all,
  starred,
  solved,
  unsolved,
  hasNotes,
  revisionDue,
}

enum NotesSort { topic, recentlyUpdated, starred }

class ProblemSearchQuery extends Equatable {
  const ProblemSearchQuery({
    this.text = '',
    this.filter = ProblemFilter.all,
    this.topicId,
    this.pattern,
    this.difficulty,
  });

  final String text;
  final ProblemFilter filter;
  final String? topicId;
  final String? pattern;
  final Difficulty? difficulty;

  @override
  List<Object?> get props => [text, filter, topicId, pattern, difficulty];
}

class ProblemEntity extends Equatable {
  const ProblemEntity({
    required this.id,
    required this.roadmapId,
    required this.topicId,
    required this.topicName,
    required this.name,
    required this.difficulty,
    required this.order,
    this.patterns = const [],
    this.solved = false,
    this.starred = false,
    this.notes = '',
    this.notesStarred = false,
    this.notesUpdatedAt,
    this.dateSolved,
    this.revisionDate,
    this.revisionCount = 0,
    this.lastConfidence = 0,
  });

  final String id;
  final String roadmapId;
  final String topicId;
  final String topicName;
  final String name;
  final Difficulty difficulty;
  final int order;
  final List<String> patterns;
  final bool solved;
  final bool starred;
  final String notes;
  final bool notesStarred;
  final DateTime? notesUpdatedAt;
  final DateTime? dateSolved;
  final DateTime? revisionDate;
  final int revisionCount;
  final int lastConfidence;

  String get title => name;
  bool get hasNotes => notes.trim().isNotEmpty;

  bool hasPattern(String pattern) =>
      patterns.any((p) => p.toLowerCase() == pattern.toLowerCase());

  ProblemEntity copyWith({
    bool? solved,
    bool? starred,
    String? notes,
    bool? notesStarred,
    DateTime? notesUpdatedAt,
    DateTime? dateSolved,
    DateTime? revisionDate,
    int? revisionCount,
    int? lastConfidence,
    List<String>? patterns,
    bool clearDateSolved = false,
    bool clearRevisionDate = false,
  }) {
    return ProblemEntity(
      id: id,
      roadmapId: roadmapId,
      topicId: topicId,
      topicName: topicName,
      name: name,
      difficulty: difficulty,
      order: order,
      patterns: patterns ?? this.patterns,
      solved: solved ?? this.solved,
      starred: starred ?? this.starred,
      notes: notes ?? this.notes,
      notesStarred: notesStarred ?? this.notesStarred,
      notesUpdatedAt: notesUpdatedAt ?? this.notesUpdatedAt,
      dateSolved: clearDateSolved ? null : (dateSolved ?? this.dateSolved),
      revisionDate: clearRevisionDate ? null : (revisionDate ?? this.revisionDate),
      revisionCount: revisionCount ?? this.revisionCount,
      lastConfidence: lastConfidence ?? this.lastConfidence,
    );
  }

  @override
  List<Object?> get props =>
      [id, solved, starred, notes, notesStarred, revisionCount, patterns];
}

class TopicEntity extends Equatable {
  const TopicEntity({
    required this.id,
    required this.name,
    required this.order,
    required this.problemIds,
  });

  final String id;
  final String name;
  final int order;
  final List<String> problemIds;

  @override
  List<Object?> get props => [id, name, problemIds];
}

class PatternStats extends Equatable {
  const PatternStats({
    required this.name,
    required this.total,
    required this.solved,
    required this.remaining,
  });

  final String name;
  final int total;
  final int solved;
  final int remaining;

  double get progress => total == 0 ? 0 : solved / total;

  @override
  List<Object?> get props => [name, total, solved];
}

class TaskEntity extends Equatable {
  const TaskEntity({
    required this.id,
    required this.title,
    required this.scheduledDate,
    this.completed = false,
    this.order = 0,
    this.type = TaskType.user,
    this.problemId,
  });

  final String id;
  final String title;
  final String scheduledDate;
  final bool completed;
  final int order;
  final TaskType type;
  final String? problemId;

  bool get isRevision => type == TaskType.revision;
  bool get isNewQuestion => type == TaskType.newQuestion;
  bool get isStarRevision => type == TaskType.starRevision;
  bool get isAuto => type != TaskType.user;

  TaskEntity copyWith({
    String? title,
    bool? completed,
    int? order,
    String? scheduledDate,
  }) {
    return TaskEntity(
      id: id,
      title: title ?? this.title,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completed: completed ?? this.completed,
      order: order ?? this.order,
      type: type,
      problemId: problemId,
    );
  }

  @override
  List<Object?> get props => [id, title, completed, order, scheduledDate];
}

class RevisionHistoryEntity extends Equatable {
  const RevisionHistoryEntity({
    required this.id,
    required this.problemId,
    required this.completedAt,
    this.confidence = 0,
  });

  final String id;
  final String problemId;
  final DateTime completedAt;
  final int confidence;

  @override
  List<Object?> get props => [id, problemId, completedAt];
}

class RevisionQueueState extends Equatable {
  const RevisionQueueState({
    required this.solvedCount,
    required this.revisionCompleted,
    required this.remaining,
    required this.currentPosition,
    required this.todayBatch,
    required this.tomorrowBatch,
    required this.queueRemaining,
    required this.cycleNumber,
    required this.todayCompleted,
    required this.todayTarget,
    required this.isTodayComplete,
  });

  final int solvedCount;
  final int revisionCompleted;
  final int remaining;
  final int currentPosition;
  final List<ProblemEntity> todayBatch;
  final List<ProblemEntity> tomorrowBatch;
  final List<ProblemEntity> queueRemaining;
  final int cycleNumber;
  final int todayCompleted;
  final int todayTarget;
  final bool isTodayComplete;

  double get progress =>
      solvedCount == 0 ? 0 : revisionCompleted / solvedCount;

  @override
  List<Object?> get props =>
      [solvedCount, revisionCompleted, remaining, todayCompleted, isTodayComplete];
}

class DeletedNoteEntity extends Equatable {
  const DeletedNoteEntity({
    required this.problemId,
    required this.notes,
    required this.deletedAt,
  });

  final String problemId;
  final String notes;
  final DateTime deletedAt;

  @override
  List<Object?> get props => [problemId, notes];
}

class TodayProblemTask extends Equatable {
  const TodayProblemTask({
    required this.problem,
    required this.completed,
    required this.taskId,
  });

  final ProblemEntity problem;
  final bool completed;
  final String taskId;

  @override
  List<Object?> get props => [taskId, problem.id, completed];
}

class TodayTasksState extends Equatable {
  const TodayTasksState({
    required this.newQuestions,
    required this.revisions,
    required this.starRevisions,
    required this.userTasks,
    required this.newQuestionsDone,
    required this.newQuestionsTarget,
    required this.revisionsDone,
    required this.revisionsTarget,
    required this.starRevisionsDone,
    required this.starRevisionsTarget,
  });

  final List<TodayProblemTask> newQuestions;
  final List<TodayProblemTask> revisions;
  final List<TodayProblemTask> starRevisions;
  final List<TaskEntity> userTasks;
  final int newQuestionsDone;
  final int newQuestionsTarget;
  final int revisionsDone;
  final int revisionsTarget;
  final int starRevisionsDone;
  final int starRevisionsTarget;

  @override
  List<Object?> get props => [
        newQuestionsDone,
        newQuestionsTarget,
        revisionsDone,
        revisionsTarget,
        starRevisionsDone,
        starRevisionsTarget,
        ...newQuestions.map((t) => '${t.taskId}:${t.completed}:${t.problem.id}'),
        ...revisions.map((t) => '${t.taskId}:${t.completed}:${t.problem.id}'),
        ...starRevisions.map((t) => '${t.taskId}:${t.completed}:${t.problem.id}'),
        ...userTasks.map((t) => '${t.id}:${t.completed}:${t.title}'),
      ];
}

class AppSettingsEntity extends Equatable {
  const AppSettingsEntity({
    this.darkMode = true,
    this.dailyNewQuestions = 3,
    this.revisionsPerDay = 3,
    this.dailyStarRevision = 2,
    this.revisionQueueIndex = 0,
    this.starRevisionQueueIndex = 0,
    this.morningNotificationHour = 9,
    this.morningNotificationMinute = 0,
    this.eveningNotificationHour = 19,
    this.eveningNotificationMinute = 0,
    this.streak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.todaySolved = 0,
    this.lastSolvedDate,
    this.todayRevisionCount = 0,
    this.todayNewQuestionsCount = 0,
    this.todayStarRevisionCount = 0,
    this.lastRevisionCountDate,
    this.lastNewQuestionsCountDate,
    this.lastStarRevisionCountDate,
    this.lastTaskSyncDate,
    this.revisionAccuracyTotal = 0,
    this.revisionAccuracyCount = 0,
    this.activeRoadmapId = 'striver_a2z',
    this.activePatternFilter,
    this.todayRevisionDayStartIndex = 0,
    this.todayStarRevisionDayStartIndex = 0,
  });

  final bool darkMode;
  final int dailyNewQuestions;
  final int revisionsPerDay;
  final int dailyStarRevision;
  final int revisionQueueIndex;
  final int starRevisionQueueIndex;
  final int morningNotificationHour;
  final int morningNotificationMinute;
  final int eveningNotificationHour;
  final int eveningNotificationMinute;
  final int streak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final int todaySolved;
  final DateTime? lastSolvedDate;
  final int todayRevisionCount;
  final int todayNewQuestionsCount;
  final int todayStarRevisionCount;
  final DateTime? lastRevisionCountDate;
  final DateTime? lastNewQuestionsCountDate;
  final DateTime? lastStarRevisionCountDate;
  final DateTime? lastTaskSyncDate;
  final int revisionAccuracyTotal;
  final int revisionAccuracyCount;
  final String activeRoadmapId;
  final String? activePatternFilter;
  final int todayRevisionDayStartIndex;
  final int todayStarRevisionDayStartIndex;

  int get dailyRevisionQuestions => revisionsPerDay;

  double get revisionAccuracy =>
      revisionAccuracyCount == 0
          ? 0
          : revisionAccuracyTotal / revisionAccuracyCount / 5 * 100;

  AppSettingsEntity copyWith({
    bool? darkMode,
    int? dailyNewQuestions,
    int? revisionsPerDay,
    int? dailyStarRevision,
    int? revisionQueueIndex,
    int? starRevisionQueueIndex,
    int? morningNotificationHour,
    int? morningNotificationMinute,
    int? eveningNotificationHour,
    int? eveningNotificationMinute,
    int? streak,
    int? longestStreak,
    DateTime? lastActiveDate,
    int? todaySolved,
    DateTime? lastSolvedDate,
    int? todayRevisionCount,
    int? todayNewQuestionsCount,
    int? todayStarRevisionCount,
    DateTime? lastRevisionCountDate,
    DateTime? lastNewQuestionsCountDate,
    DateTime? lastStarRevisionCountDate,
    DateTime? lastTaskSyncDate,
    int? revisionAccuracyTotal,
    int? revisionAccuracyCount,
    String? activePatternFilter,
    bool clearPatternFilter = false,
    int? todayRevisionDayStartIndex,
    int? todayStarRevisionDayStartIndex,
  }) {
    return AppSettingsEntity(
      darkMode: darkMode ?? this.darkMode,
      dailyNewQuestions: dailyNewQuestions ?? this.dailyNewQuestions,
      revisionsPerDay: revisionsPerDay ?? this.revisionsPerDay,
      dailyStarRevision: dailyStarRevision ?? this.dailyStarRevision,
      revisionQueueIndex: revisionQueueIndex ?? this.revisionQueueIndex,
      starRevisionQueueIndex: starRevisionQueueIndex ?? this.starRevisionQueueIndex,
      morningNotificationHour:
          morningNotificationHour ?? this.morningNotificationHour,
      morningNotificationMinute:
          morningNotificationMinute ?? this.morningNotificationMinute,
      eveningNotificationHour:
          eveningNotificationHour ?? this.eveningNotificationHour,
      eveningNotificationMinute:
          eveningNotificationMinute ?? this.eveningNotificationMinute,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      todaySolved: todaySolved ?? this.todaySolved,
      lastSolvedDate: lastSolvedDate ?? this.lastSolvedDate,
      todayRevisionCount: todayRevisionCount ?? this.todayRevisionCount,
      todayNewQuestionsCount: todayNewQuestionsCount ?? this.todayNewQuestionsCount,
      todayStarRevisionCount: todayStarRevisionCount ?? this.todayStarRevisionCount,
      lastRevisionCountDate:
          lastRevisionCountDate ?? this.lastRevisionCountDate,
      lastNewQuestionsCountDate:
          lastNewQuestionsCountDate ?? this.lastNewQuestionsCountDate,
      lastStarRevisionCountDate:
          lastStarRevisionCountDate ?? this.lastStarRevisionCountDate,
      lastTaskSyncDate: lastTaskSyncDate ?? this.lastTaskSyncDate,
      revisionAccuracyTotal:
          revisionAccuracyTotal ?? this.revisionAccuracyTotal,
      revisionAccuracyCount:
          revisionAccuracyCount ?? this.revisionAccuracyCount,
      activeRoadmapId: activeRoadmapId,
      activePatternFilter: clearPatternFilter
          ? null
          : (activePatternFilter ?? this.activePatternFilter),
      todayRevisionDayStartIndex:
          todayRevisionDayStartIndex ?? this.todayRevisionDayStartIndex,
      todayStarRevisionDayStartIndex:
          todayStarRevisionDayStartIndex ?? this.todayStarRevisionDayStartIndex,
    );
  }

  @override
  List<Object?> get props =>
      [streak, revisionQueueIndex, revisionsPerDay, dailyNewQuestions];
}

class AppStats extends Equatable {
  const AppStats({
    required this.total,
    required this.solved,
    required this.remaining,
    required this.todaySolved,
    required this.todayRevision,
    required this.revisionAccuracy,
    required this.streak,
    required this.longestStreak,
    required this.totalNotes,
    required this.starredQuestions,
    required this.revisionCompleted,
    required this.revisionRemaining,
    required this.pendingRevisionToday,
  });

  final int total;
  final int solved;
  final int remaining;
  final int todaySolved;
  final int todayRevision;
  final double revisionAccuracy;
  final int streak;
  final int longestStreak;
  final int totalNotes;
  final int starredQuestions;
  final int revisionCompleted;
  final int revisionRemaining;
  final int pendingRevisionToday;

  @override
  List<Object?> get props => [total, solved, revisionCompleted];
}

class ShortNoteEntity extends Equatable {
  const ShortNoteEntity({
    required this.id,
    required this.text,
    this.title = '',
    required this.createdAt,
    this.updatedAt,
    this.order = 0,
  });

  final String id;
  final String title;
  final String text;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int order;

  ShortNoteEntity copyWith({
    String? title,
    String? text,
    DateTime? updatedAt,
    int? order,
  }) {
    return ShortNoteEntity(
      id: id,
      title: title ?? this.title,
      text: text ?? this.text,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, title, text, order, updatedAt];
}
