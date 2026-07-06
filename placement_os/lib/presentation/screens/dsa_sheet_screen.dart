import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class DsaSheetScreen extends ConsumerStatefulWidget {
  const DsaSheetScreen({super.key});

  @override
  ConsumerState<DsaSheetScreen> createState() => _DsaSheetScreenState();
}

class _DsaSheetScreenState extends ConsumerState<DsaSheetScreen> {
  ProblemFilter _filter = ProblemFilter.all;
  String? _pattern;
  Difficulty? _difficulty;

  @override
  Widget build(BuildContext context) {
    final topics = ref.watch(topicsProvider);
    final stats = ref.watch(statsProvider);
    final patterns = ref.watch(problemRepoProvider).getAllPatterns();
    final revisionDue = ref.watch(revisionDueIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DSA Sheet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => context.push(AppRoutes.patterns),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push(AppRoutes.search),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Striver A2Z — ${stats.solved}/${stats.total}'),
                  Text('${((stats.solved / stats.total) * 100).toStringAsFixed(0)}%'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _pattern,
                    decoration: const InputDecoration(labelText: 'Pattern', isDense: true),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All patterns')),
                      ...patterns.map((p) => DropdownMenuItem(value: p, child: Text(p))),
                    ],
                    onChanged: (v) => setState(() => _pattern = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<Difficulty?>(
                    value: _difficulty,
                    decoration: const InputDecoration(labelText: 'Difficulty', isDense: true),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...Difficulty.values.map(
                        (d) => DropdownMenuItem(value: d, child: Text(d.name)),
                      ),
                    ],
                    onChanged: (v) => setState(() => _difficulty = v),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ProblemFilter.values.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_filterLabel(f)),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: topics.length,
              itemBuilder: (context, i) => _TopicTile(
                topic: topics[i],
                filter: _filter,
                pattern: _pattern,
                difficulty: _difficulty,
                revisionDue: revisionDue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(ProblemFilter f) => switch (f) {
        ProblemFilter.all => 'All',
        ProblemFilter.starred => 'Starred',
        ProblemFilter.solved => 'Solved',
        ProblemFilter.unsolved => 'Unsolved',
        ProblemFilter.hasNotes => 'Notes',
        ProblemFilter.revisionDue => 'Rev. Due',
      };
}

class _TopicTile extends ConsumerStatefulWidget {
  const _TopicTile({
    required this.topic,
    required this.filter,
    required this.pattern,
    required this.difficulty,
    required this.revisionDue,
  });
  final TopicEntity topic;
  final ProblemFilter filter;
  final String? pattern;
  final Difficulty? difficulty;
  final Set<String> revisionDue;

  @override
  ConsumerState<_TopicTile> createState() => _TopicTileState();
}

class _TopicTileState extends ConsumerState<_TopicTile> {
  bool _expanded = false;

  bool _matches(ProblemEntity p) {
    if (widget.filter == ProblemFilter.starred && !p.starred) return false;
    if (widget.filter == ProblemFilter.solved && !p.solved) return false;
    if (widget.filter == ProblemFilter.unsolved && p.solved) return false;
    if (widget.filter == ProblemFilter.hasNotes && !p.hasNotes) return false;
    if (widget.filter == ProblemFilter.revisionDue && !widget.revisionDue.contains(p.id)) {
      return false;
    }
    if (widget.pattern != null && !p.hasPattern(widget.pattern!)) return false;
    if (widget.difficulty != null && p.difficulty != widget.difficulty) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final allProblems =
        ref.watch(allProblemsProvider).where((p) => p.topicId == widget.topic.id).toList();
    final problems = allProblems.where(_matches).toList();
    if (problems.isEmpty &&
        (widget.filter != ProblemFilter.all || widget.pattern != null || widget.difficulty != null)) {
      return const SizedBox.shrink();
    }
    final solved = allProblems.where((p) => p.solved).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.topic.name, style: Theme.of(context).textTheme.titleMedium),
                          Text('$solved/${allProblems.length} solved'),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: allProblems.isEmpty ? 0 : solved / allProblems.length,
                            color: AppColors.primary,
                            backgroundColor: AppColors.divider,
                          ),
                        ],
                      ),
                    ),
                    Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
              ),
            ),
            if (_expanded)
              ...problems.map(
                (p) => _ProblemRow(problem: p, revisionDue: widget.revisionDue.contains(p.id)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProblemRow extends ConsumerWidget {
  const _ProblemRow({required this.problem, required this.revisionDue});
  final ProblemEntity problem;
  final bool revisionDue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(problemRepoProvider);

    return InkWell(
      onTap: () => context.push('/problem/${problem.id}'),
      child: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: problem.solved,
                  onChanged: (_) async {
                    await repo.toggleSolved(problem.id);
                    if (!problem.solved) {
                      await ref.read(settingsRepoProvider).recordSolved();
                    }
                    refresh(ref);
                  },
                ),
                Expanded(child: Text(problem.name)),
                ProblemStatusIcons(problem: problem, revisionDue: revisionDue),
                IconButton(
                  icon: Icon(
                    Icons.star,
                    color: problem.starred ? AppColors.warning : AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () async {
                    await repo.toggleStar(problem.id);
                    refresh(ref);
                  },
                ),
                DifficultyChip(difficulty: problem.difficulty),
              ],
            ),
            if (problem.patterns.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 48, bottom: 4),
                child: Wrap(
                  spacing: 4,
                  children: problem.patterns.take(3).map((p) => PatternChip(label: p)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
