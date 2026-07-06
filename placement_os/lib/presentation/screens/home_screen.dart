import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_branding.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/entities/entities.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _taskController = TextEditingController();
  String _quote = 'Consistency beats intensity.';

  @override
  void initState() {
    super.initState();
    _loadQuote();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(dailyTaskServiceProvider).syncForToday();
        await ref.read(settingsRepoProvider).recordActivity();
        refresh(ref);
        await _syncTasksNotification();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _loadQuote() async {
    try {
      final str =
          await DefaultAssetBundle.of(context).loadString('assets/quotes/quotes.json');
      final quotes = (json.decode(str) as Map)['quotes'] as List;
      if (quotes.isNotEmpty) {
        final q = quotes[Random().nextInt(quotes.length)] as Map;
        if (mounted) setState(() => _quote = '${q['text']} — ${q['author']}');
      }
    } catch (_) {}
  }

  Future<void> _syncTasksNotification() async {
    try {
      final tasks = ref.read(dailyTaskServiceProvider).notificationTasks();
      await NotificationService.instance.updateOngoingTasks(tasks);
    } catch (_) {}
  }

  Future<void> _toggleNew(ProblemEntity p, bool completed) async {
    if (completed) {
      await ref.read(settingsRepoProvider).recordSolved();
    }
    await ref.read(dailyTaskServiceProvider).toggleNewQuestion(p.id, completed);
    refresh(ref);
    await _syncTasksNotification();
  }

  Future<void> _toggleRev(ProblemEntity p, bool completed) async {
    await ref.read(dailyTaskServiceProvider).toggleRevision(p.id, completed);
    refresh(ref);
    await _syncTasksNotification();
  }

  Future<void> _toggleStar(ProblemEntity p, bool completed) async {
    await ref.read(dailyTaskServiceProvider).toggleStarRevision(p.id, completed);
    refresh(ref);
    await _syncTasksNotification();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final settings = ref.watch(settingsProvider);
    final today = ref.watch(todayTasksStateProvider);
    final queue = ref.watch(revisionQueueStateProvider);
    final progress = stats.total == 0 ? 0.0 : stats.solved / stats.total;
    final taskRepo = ref.read(taskRepoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppBranding.name, style: Theme.of(context).textTheme.titleLarge),
            Text(
              AppBranding.tagline,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => context.push(AppRoutes.search)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '${settings.streak}',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  icon: Icons.check_circle,
                  label: 'Solved',
                  value: '${stats.solved}/${stats.total}',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ProgressRing(progress: progress, size: 56, label: '${(progress * 100).round()}%'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text("Today's Tasks", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _sectionHeader('New Questions', '${today.newQuestionsDone}/${today.newQuestionsTarget}'),
          _ProblemSection(
            items: today.newQuestions,
            emptyLabel: 'No unsolved questions left',
            color: AppColors.success,
            onToggle: _toggleNew,
          ),
          const Divider(height: 24),
          _sectionHeader('Revision', '${today.revisionsDone}/${today.revisionsTarget}'),
          _ProblemSection(
            items: today.revisions,
            emptyLabel: 'Solve questions to unlock revision',
            color: AppColors.primaryLight,
            onToggle: _toggleRev,
          ),
          const Divider(height: 24),
          _sectionHeader('Star Revision', '${today.starRevisionsDone}/${today.starRevisionsTarget}'),
          _ProblemSection(
            items: today.starRevisions,
            emptyLabel: 'Star questions to enable star revision',
            color: AppColors.warning,
            onToggle: _toggleStar,
          ),
          const Divider(height: 24),
          _sectionHeader('User Tasks', ''),
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(hintText: 'Add task...', border: InputBorder.none),
                    onSubmitted: (v) => _addTask(v, taskRepo),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTask(_taskController.text, taskRepo),
                ),
              ],
            ),
          ),
          ...today.userTasks.map(
            (t) => _UserTaskRow(
              key: ValueKey(t.id),
              task: t,
              onToggle: (completed) async {
                await taskRepo.update(t.id, completed: completed);
                refresh(ref);
                await _syncTasksNotification();
              },
              onDelete: () async {
                await taskRepo.delete(t.id);
                refresh(ref);
                await _syncTasksNotification();
              },
              onEdit: () => _editTask(t),
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Revision Queue', style: Theme.of(context).textTheme.titleMedium),
                Text('${queue.revisionCompleted}/${queue.solvedCount} revised · ${queue.remaining} left'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickBtn(icon: Icons.grid_view, label: 'DSA Sheet', onTap: () => context.go(AppRoutes.dsaSheet)),
              _QuickBtn(icon: Icons.refresh, label: 'Revision', onTap: () => context.go(AppRoutes.revision)),
              _QuickBtn(icon: Icons.category, label: 'Patterns', onTap: () => context.push(AppRoutes.patterns)),
              _QuickBtn(icon: Icons.note_alt, label: 'Notes', onTap: () => context.go(AppRoutes.notes)),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.format_quote, color: AppColors.primaryLight),
                const SizedBox(width: 12),
                Expanded(child: Text(_quote, style: const TextStyle(fontStyle: FontStyle.italic))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryLight)),
          if (progress.isNotEmpty) Text(progress, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Future<void> _addTask(String v, TaskRepository taskRepo) async {
    if (v.trim().isEmpty) return;
    await taskRepo.addUserTask(v.trim());
    _taskController.clear();
    refresh(ref);
    await _syncTasksNotification();
  }

  Future<void> _editTask(TaskEntity task) async {
    final controller = TextEditingController(text: task.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      await ref.read(taskRepoProvider).update(task.id, title: result.trim());
      refresh(ref);
      await _syncTasksNotification();
    }
  }
}

class _ProblemSection extends StatelessWidget {
  const _ProblemSection({
    required this.items,
    required this.emptyLabel,
    required this.color,
    required this.onToggle,
  });

  final List<TodayProblemTask> items;
  final String emptyLabel;
  final Color color;
  final Future<void> Function(ProblemEntity problem, bool completed) onToggle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(emptyLabel, style: const TextStyle(color: AppColors.textMuted)),
      );
    }

    return Column(
      children: items.map((item) {
        return _ProblemTaskRow(
          key: ValueKey(item.taskId),
          item: item,
          color: color,
          onToggle: onToggle,
        );
      }).toList(),
    );
  }
}

class _ProblemTaskRow extends StatefulWidget {
  const _ProblemTaskRow({
    super.key,
    required this.item,
    required this.color,
    required this.onToggle,
  });

  final TodayProblemTask item;
  final Color color;
  final Future<void> Function(ProblemEntity problem, bool completed) onToggle;

  @override
  State<_ProblemTaskRow> createState() => _ProblemTaskRowState();
}

class _ProblemTaskRowState extends State<_ProblemTaskRow> {
  late bool _completed;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _completed = widget.item.completed;
  }

  @override
  void didUpdateWidget(covariant _ProblemTaskRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.taskId != widget.item.taskId ||
        oldWidget.item.completed != widget.item.completed) {
      _completed = widget.item.completed;
    }
  }

  Future<void> _toggle(bool? value) async {
    if (_busy || value == null || value == _completed) return;
    setState(() {
      _completed = value;
      _busy = true;
    });
    try {
      await widget.onToggle(widget.item.problem, value);
    } catch (_) {
      if (mounted) setState(() => _completed = !value);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        onTap: () => context.push('/problem/${widget.item.problem.id}'),
        child: Row(
          children: [
            Checkbox(
              value: _completed,
              onChanged: _busy ? null : _toggle,
              activeColor: widget.color,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.problem.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: _completed ? TextDecoration.lineThrough : null,
                          color: _completed ? AppColors.textMuted : null,
                        ),
                  ),
                  Text(
                    widget.item.problem.topicName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          decoration: _completed ? TextDecoration.lineThrough : null,
                          color: _completed ? AppColors.textMuted : null,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  const _QuickBtn({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(avatar: Icon(icon, size: 18), label: Text(label), onPressed: onTap);
  }
}

class _UserTaskRow extends StatefulWidget {
  const _UserTaskRow({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });
  final TaskEntity task;
  final Future<void> Function(bool completed) onToggle;
  final Future<void> Function() onDelete;
  final VoidCallback onEdit;

  @override
  State<_UserTaskRow> createState() => _UserTaskRowState();
}

class _UserTaskRowState extends State<_UserTaskRow> {
  late bool _completed;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _completed = widget.task.completed;
  }

  @override
  void didUpdateWidget(covariant _UserTaskRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id || oldWidget.task.completed != widget.task.completed) {
      _completed = widget.task.completed;
    }
  }

  Future<void> _toggle() async {
    if (_busy) return;
    final next = !_completed;
    setState(() {
      _completed = next;
      _busy = true;
    });
    try {
      await widget.onToggle(next);
    } catch (_) {
      if (mounted) setState(() => _completed = !next);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: _completed,
              onChanged: _busy ? null : (_) => _toggle(),
            ),
            Expanded(
              child: Text(
                widget.task.title,
                style: TextStyle(decoration: _completed ? TextDecoration.lineThrough : null),
              ),
            ),
            IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: widget.onEdit),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      try {
                        await widget.onDelete();
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
