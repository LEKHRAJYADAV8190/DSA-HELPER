import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/constants/note_template.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class ProblemDetailScreen extends ConsumerStatefulWidget {
  const ProblemDetailScreen({super.key, required this.problemId});
  final String problemId;

  @override
  ConsumerState<ProblemDetailScreen> createState() => _ProblemDetailScreenState();
}

class _ProblemDetailScreenState extends ConsumerState<ProblemDetailScreen> {
  late TextEditingController _notesController;
  Timer? _saveTimer;
  int _confidence = 0;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  void _scheduleSave(String notes, ProblemRepository repo, String id) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), () async {
      await repo.saveNotes(id, notes);
      refresh(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final problem = ref.watch(problemProvider(widget.problemId));
    final deletedNote = ref.watch(deletedNoteProvider);
    final queue = ref.watch(revisionQueueStateProvider);

    if (problem == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Problem not found')));
    }

    if (_notesController.text != problem.notes) {
      _notesController.text = problem.notes;
    }
    if (problem.lastConfidence > 0) {
      _confidence = problem.lastConfidence;
    }

    final history = ref.read(problemRepoProvider).historyFor(problem.id);
    final repo = ref.read(problemRepoProvider);
    final inTodayBatch = queue.todayBatch.any((p) => p.id == problem.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(problem.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              problem.starred ? Icons.star : Icons.star_border,
              color: problem.starred ? AppColors.warning : null,
            ),
            onPressed: () async {
              await repo.toggleStar(problem.id);
              refresh(ref);
            },
          ),
          IconButton(
            icon: Icon(
              problem.notesStarred ? Icons.bookmark : Icons.bookmark_border,
              color: problem.notesStarred ? AppColors.primaryLight : null,
            ),
            onPressed: () async {
              await repo.toggleNotesStar(problem.id);
              refresh(ref);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(
            children: [
              DifficultyChip(difficulty: problem.difficulty),
              const SizedBox(width: 8),
              Expanded(child: Text('Topic: ${problem.topicName}')),
              ProblemStatusIcons(problem: problem, revisionDue: inTodayBatch),
            ],
          ),
          if (problem.patterns.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: problem.patterns.map((p) => PatternChip(label: p)).toList(),
            ),
          ],
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Solved'),
                  value: problem.solved,
                  onChanged: (_) async {
                    await repo.toggleSolved(problem.id);
                    if (!problem.solved) {
                      await ref.read(settingsRepoProvider).recordSolved();
                    }
                    refresh(ref);
                  },
                ),
                if (problem.dateSolved != null)
                  ListTile(
                    leading: const Icon(Icons.calendar_today, size: 20),
                    title: Text(
                      'Date Solved: ${DateFormat('MMM d, yyyy').format(problem.dateSolved!)}',
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.refresh, size: 20),
                  title: Text('Revisions completed: ${problem.revisionCount}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Notes', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: () {
                  if (_notesController.text.trim().isEmpty) {
                    _notesController.text = emptyNoteFromTemplate();
                    _scheduleSave(_notesController.text, repo, problem.id);
                    setState(() {});
                  }
                },
                icon: const Icon(Icons.description, size: 18),
                label: const Text('Use Template'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 16,
            decoration: const InputDecoration(
              hintText: 'Pattern, Core Idea, Algorithm, Complexity...',
              alignLabelWithHint: true,
            ),
            onChanged: (v) => _scheduleSave(v, repo, problem.id),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (problem.notesUpdatedAt != null)
                Expanded(
                  child: Text(
                    'Auto-saved · ${DateFormat('MMM d, h:mm a').format(problem.notesUpdatedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              TextButton(
                onPressed: problem.hasNotes
                    ? () async {
                        await repo.deleteNotes(problem.id);
                        _notesController.clear();
                        refresh(ref);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Notes deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () async {
                                  await repo.undoDeleteNotes();
                                  refresh(ref);
                                },
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                child: const Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
          if (deletedNote?.problemId == problem.id)
            AppCard(
              child: Row(
                children: [
                  const Expanded(child: Text('Notes recently deleted')),
                  TextButton(
                    onPressed: () async {
                      await repo.undoDeleteNotes();
                      refresh(ref);
                    },
                    child: const Text('Undo'),
                  ),
                ],
              ),
            ),
          if (_notesController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppCard(child: MarkdownBody(data: _notesController.text)),
          ],
          const SizedBox(height: 16),
          Text('Confidence (1-5)', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: (_confidence == 0 ? 3 : _confidence).toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '${_confidence == 0 ? 3 : _confidence}',
            onChanged: (v) => setState(() => _confidence = v.round()),
          ),
          if (problem.solved && inTodayBatch)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await ref.read(smartRevisionProvider).completeSequentialRevision(
                        problem.id,
                        confidence: _confidence,
                      );
                  final tasks = ref.read(dailyTaskServiceProvider).todayTasks();
                  final revTask = tasks.where(
                    (t) => t.isRevision && t.problemId == problem.id && !t.completed,
                  );
                  for (final t in revTask) {
                    await ref.read(taskRepoProvider).update(t.id, completed: true);
                  }
                  refresh(ref);
                  await NotificationService.instance.updateOngoingTasks(
                    ref.read(dailyTaskServiceProvider).todayTasks(),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Revision completed')),
                    );
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Mark Revision Done'),
              ),
            ),
          const SizedBox(height: 16),
          Text('Revision History', style: Theme.of(context).textTheme.titleMedium),
          if (history.isEmpty)
            const Padding(padding: EdgeInsets.all(8), child: Text('No revisions yet'))
          else
            ...history.map(
              (h) => ListTile(
                dense: true,
                leading: const Icon(Icons.history, size: 18),
                title: Text(DateFormat('MMM d, yyyy h:mm a').format(h.completedAt)),
                trailing: h.confidence > 0 ? Text('★ ${h.confidence}/5') : null,
              ),
            ),
        ],
      ),
    );
  }
}
