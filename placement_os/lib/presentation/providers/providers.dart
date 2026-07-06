import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/hive_service.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/daily_new_questions_service.dart';
import '../../domain/services/daily_task_service.dart';
import '../../domain/services/pdf_export_service.dart';
import '../../domain/services/smart_revision_service.dart';
import '../../domain/services/star_revision_service.dart';

final hiveProvider = Provider((ref) => HiveService.instance);

final seedProvider = FutureProvider<int>((ref) async {
  return SeedService(ref.watch(hiveProvider)).seedIfNeeded();
});

final problemRepoProvider =
    Provider((ref) => ProblemRepository(ref.watch(hiveProvider)));

final taskRepoProvider =
    Provider((ref) => TaskRepository(ref.watch(hiveProvider)));

final shortNotesRepoProvider =
    Provider((ref) => ShortNotesRepository(ref.watch(hiveProvider)));

final settingsRepoProvider =
    Provider((ref) => SettingsRepository(ref.watch(hiveProvider)));

final smartRevisionProvider = Provider((ref) {
  ref.watch(refreshProvider);
  return SmartRevisionService(
    ref.watch(problemRepoProvider),
    ref.watch(settingsRepoProvider),
  );
});

final dailyNewQuestionsProvider = Provider((ref) {
  ref.watch(refreshProvider);
  return DailyNewQuestionsService(
    ref.watch(problemRepoProvider),
    ref.watch(settingsRepoProvider),
  );
});

final starRevisionProvider = Provider((ref) {
  ref.watch(refreshProvider);
  return StarRevisionService(
    ref.watch(problemRepoProvider),
    ref.watch(settingsRepoProvider),
  );
});

final dailyTaskServiceProvider = Provider((ref) {
  ref.watch(refreshProvider);
  return DailyTaskService(
    ref.watch(taskRepoProvider),
    ref.watch(problemRepoProvider),
    ref.watch(settingsRepoProvider),
    ref.watch(smartRevisionProvider),
    ref.watch(dailyNewQuestionsProvider),
    ref.watch(starRevisionProvider),
  );
});

final pdfExportProvider = Provider((ref) => PdfExportService());

final refreshProvider = StateProvider<int>((ref) => 0);

void refresh(WidgetRef ref) => ref.read(refreshProvider.notifier).state++;

final topicsProvider = Provider((ref) {
  ref.watch(refreshProvider);
  return ref.watch(problemRepoProvider).getTopics();
});

final allProblemsProvider = Provider((ref) {
  ref.watch(refreshProvider);
  return ref.watch(problemRepoProvider).getAllProblems();
});

final shortNotesProvider = Provider((ref) {
  ref.watch(refreshProvider);
  return ref.watch(shortNotesRepoProvider).getAll();
});

final todayTasksStateProvider = Provider((ref) {
  ref.watch(refreshProvider);
  return ref.watch(dailyTaskServiceProvider).getTodayState();
});

final tasksProvider = Provider((ref) {
  ref.watch(refreshProvider);
  return ref.watch(dailyTaskServiceProvider).todayTasks();
});

final settingsProvider = Provider((ref) {
  ref.watch(refreshProvider);
  return ref.watch(settingsRepoProvider).get();
});

final problemProvider = Provider.family<ProblemEntity?, String>((ref, id) {
  ref.watch(refreshProvider);
  return ref.watch(problemRepoProvider).getById(id);
});

final revisionQueueStateProvider = Provider((ref) {
  ref.watch(refreshProvider);
  return ref.watch(smartRevisionProvider).getState();
});

final revisionDueIdsProvider = Provider((ref) {
  ref.watch(refreshProvider);
  final batch = ref.watch(revisionQueueStateProvider).todayBatch;
  return batch.map((p) => p.id).toSet();
});

final patternStatsProvider = Provider((ref) {
  ref.watch(refreshProvider);
  return ref.watch(problemRepoProvider).getPatternStats();
});

final statsProvider = Provider((ref) {
  ref.watch(refreshProvider);
  final repo = ref.watch(problemRepoProvider);
  final settings = ref.watch(settingsRepoProvider).get();
  final queue = ref.watch(smartRevisionProvider).getState();
  return AppStats(
    total: repo.totalQuestions,
    solved: repo.solvedCount,
    remaining: repo.totalQuestions - repo.solvedCount,
    todaySolved: settings.todaySolved,
    todayRevision: settings.todayRevisionCount,
    revisionAccuracy: settings.revisionAccuracy,
    streak: settings.streak,
    longestStreak: settings.longestStreak,
    totalNotes: repo.notesCount,
    starredQuestions: repo.starredCount,
    revisionCompleted: queue.revisionCompleted,
    revisionRemaining: queue.remaining,
    pendingRevisionToday: queue.isTodayComplete
        ? 0
        : queue.todayTarget - queue.todayCompleted,
  );
});

final deletedNoteProvider = Provider((ref) {
  ref.watch(refreshProvider);
  return ref.watch(problemRepoProvider).getDeletedNote();
});
