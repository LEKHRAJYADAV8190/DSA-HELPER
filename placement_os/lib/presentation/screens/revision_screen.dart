import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';
import '../../domain/entities/entities.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class RevisionScreen extends ConsumerStatefulWidget {
  const RevisionScreen({super.key});

  @override
  ConsumerState<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends ConsumerState<RevisionScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<ProblemEntity> _activeCards = [];
  bool _showTomorrow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncCards());
  }

  void _syncCards() {
    final queue = ref.read(revisionQueueStateProvider);
    if (!queue.isTodayComplete) {
      setState(() {
        _activeCards = List.from(queue.todayBatch);
        _showTomorrow = false;
      });
    }
  }

  Future<void> _completeRevision(ProblemEntity problem) async {
    final index = _activeCards.indexWhere((p) => p.id == problem.id);
    if (index < 0) return;

    final removed = _activeCards[index];
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildCard(removed, animation, completing: true),
      duration: const Duration(milliseconds: 350),
    );
    setState(() => _activeCards.removeAt(index));

    await ref.read(smartRevisionProvider).completeSequentialRevision(problem.id);

    final tasks = ref.read(dailyTaskServiceProvider).todayTasks();
    for (final t in tasks.where((t) => t.problemId == problem.id && !t.completed)) {
      await ref.read(taskRepoProvider).update(t.id, completed: true);
    }

    refresh(ref);

    final queue = ref.read(revisionQueueStateProvider);
    if (queue.isTodayComplete) {
      setState(() => _showTomorrow = false);
      await NotificationService.instance.updateOngoingTasks(
        ref.read(dailyTaskServiceProvider).todayTasks(),
      );
      return;
    }

    final next = queue.todayBatch.where((p) => _activeCards.every((c) => c.id != p.id));
    ProblemEntity? incoming;
    for (final p in next) {
      incoming = p;
      break;
    }
    if (incoming != null) {
      _activeCards.add(incoming);
      _listKey.currentState?.insertItem(
        _activeCards.length - 1,
        duration: const Duration(milliseconds: 350),
      );
      setState(() {});
    }

    await NotificationService.instance.updateOngoingTasks(
      ref.read(dailyTaskServiceProvider).todayTasks(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(revisionQueueStateProvider);
    final settings = ref.watch(settingsProvider);

    if (_activeCards.isEmpty && !queue.isTodayComplete && queue.todayBatch.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_activeCards.isEmpty) _syncCards();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revision'),
        actions: [
          if (settings.activePatternFilter != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(settings.activePatternFilter!, style: const TextStyle(fontSize: 11)),
                onDeleted: () async {
                  await ref.read(smartRevisionProvider).setPatternFilter(null);
                  refresh(ref);
                  _syncCards();
                },
              ),
            ),
        ],
      ),
      body: queue.solvedCount == 0
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Solve some problems first.\nRevision follows Striver A2Z order among solved questions.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Revision Queue', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      _InfoRow('Solved', '${queue.solvedCount}'),
                      _InfoRow('Completed', '${queue.revisionCompleted}'),
                      _InfoRow('Remaining', '${queue.remaining}'),
                      _InfoRow('Current Position', '${queue.currentPosition}'),
                      _InfoRow('Next Revision', queue.todayBatch.isNotEmpty
                          ? queue.todayBatch.first.name
                          : queue.tomorrowBatch.isNotEmpty
                              ? queue.tomorrowBatch.first.name
                              : '—'),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: queue.progress,
                        color: AppColors.primary,
                        backgroundColor: AppColors.divider,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today's Revision", style: Theme.of(context).textTheme.titleMedium),
                    Text('${queue.todayCompleted}/${queue.todayTarget}'),
                  ],
                ),
                const SizedBox(height: 8),
                if (queue.isTodayComplete)
                  _CompletionCard(
                    completed: queue.todayCompleted,
                    target: queue.todayTarget,
                    tomorrow: queue.tomorrowBatch,
                    showTomorrow: _showTomorrow,
                    onToggleTomorrow: () => setState(() => _showTomorrow = !_showTomorrow),
                    onHome: () => context.go(AppRoutes.home),
                  )
                else
                  AnimatedList(
                    key: _listKey,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    initialItemCount: _activeCards.length,
                    itemBuilder: (context, index, animation) {
                      if (index >= _activeCards.length) return const SizedBox.shrink();
                      return _buildCard(_activeCards[index], animation);
                    },
                  ),
                const SizedBox(height: 16),
                Text('Queue', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...queue.queueRemaining.take(20).toList().asMap().entries.map((entry) {
                  final idx = entry.key;
                  final p = entry.value;
                  final due = queue.todayBatch.any((x) => x.id == p.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      onTap: () => context.push('/problem/${p.id}'),
                      child: Row(
                        children: [
                          Text(
                            '${queue.revisionCompleted + idx + 1}',
                            style: TextStyle(
                              color: due ? AppColors.primaryLight : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name),
                                Wrap(
                                  spacing: 4,
                                  children: p.patterns.take(2).map((pat) => PatternChip(label: pat)).toList(),
                                ),
                              ],
                            ),
                          ),
                          ProblemStatusIcons(problem: p, revisionDue: due),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildCard(ProblemEntity p, Animation<double> animation, {bool completing = false}) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(p.name, style: Theme.of(context).textTheme.titleMedium),
                    ),
                    DifficultyChip(difficulty: p.difficulty),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Topic: ${p.topicName}', style: Theme.of(context).textTheme.bodySmall),
                if (p.patterns.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: p.patterns.map((pat) => PatternChip(label: pat)).toList(),
                  ),
                ],
                const SizedBox(height: 12),
                if (!completing)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _completeRevision(p),
                      icon: const Icon(Icons.check),
                      label: const Text('Revision Complete'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({
    required this.completed,
    required this.target,
    required this.tomorrow,
    required this.showTomorrow,
    required this.onToggleTomorrow,
    required this.onHome,
  });

  final int completed;
  final int target;
  final List<ProblemEntity> tomorrow;
  final bool showTomorrow;
  final VoidCallback onToggleTomorrow;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text("Today's Revision Completed", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('$completed / $target Finished'),
          const SizedBox(height: 16),
          FilledButton(onPressed: onHome, child: const Text('Return Home')),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onToggleTomorrow,
            child: Text(showTomorrow ? 'Hide Tomorrow' : "See Tomorrow's Revision"),
          ),
          if (showTomorrow && tomorrow.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...tomorrow.map(
              (p) => ListTile(
                dense: true,
                leading: const Icon(Icons.schedule, color: AppColors.primaryLight),
                title: Text(p.name),
                subtitle: Text(p.patterns.join(', ')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
