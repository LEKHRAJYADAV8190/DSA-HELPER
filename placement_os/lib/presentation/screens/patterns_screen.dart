import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class PatternsScreen extends ConsumerWidget {
  const PatternsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patterns = ref.watch(patternStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patterns'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: patterns.isEmpty
          ? const Center(child: Text('No patterns loaded'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: patterns.length,
              itemBuilder: (context, i) {
                final p = patterns[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    onTap: () => context.push('/patterns/${Uri.encodeComponent(p.name)}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${p.name} (${p.total})',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text('${p.solved} solved'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: p.progress,
                          color: AppColors.primary,
                          backgroundColor: AppColors.divider,
                        ),
                        const SizedBox(height: 6),
                        Text('${p.remaining} remaining'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class PatternDetailScreen extends ConsumerStatefulWidget {
  const PatternDetailScreen({super.key, required this.patternName});
  final String patternName;

  @override
  ConsumerState<PatternDetailScreen> createState() => _PatternDetailScreenState();
}

class _PatternDetailScreenState extends ConsumerState<PatternDetailScreen> {
  ProblemFilter _filter = ProblemFilter.all;

  @override
  Widget build(BuildContext context) {
    final decoded = Uri.decodeComponent(widget.patternName);
    final revisionDue = ref.watch(revisionDueIdsProvider);
    var problems = ref.read(problemRepoProvider).byPattern(decoded);

    problems = switch (_filter) {
      ProblemFilter.all => problems,
      ProblemFilter.solved => problems.where((p) => p.solved).toList(),
      ProblemFilter.unsolved => problems.where((p) => !p.solved).toList(),
      ProblemFilter.starred => problems.where((p) => p.starred).toList(),
      ProblemFilter.revisionDue =>
        problems.where((p) => revisionDue.contains(p.id)).toList(),
      ProblemFilter.hasNotes => problems.where((p) => p.hasNotes).toList(),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(decoded),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await ref.read(smartRevisionProvider).setPatternFilter(decoded);
              refresh(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Quick Pattern Revision: $decoded')),
                );
                context.go(AppRoutes.revision);
              }
            },
            icon: const Icon(Icons.flash_on, size: 18),
            label: const Text('Quick Rev.'),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ProblemFilter.all,
                ProblemFilter.solved,
                ProblemFilter.unsolved,
                ProblemFilter.starred,
                ProblemFilter.revisionDue,
              ].map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_label(f)),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: problems.length,
              itemBuilder: (context, i) {
                final p = problems[i];
                final due = revisionDue.contains(p.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    onTap: () => context.push('/problem/${p.id}'),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: Theme.of(context).textTheme.titleMedium),
                              Text(p.topicName, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        ProblemStatusIcons(problem: p, revisionDue: due),
                        const SizedBox(width: 8),
                        DifficultyChip(difficulty: p.difficulty),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _label(ProblemFilter f) => switch (f) {
        ProblemFilter.all => 'All',
        ProblemFilter.solved => 'Solved',
        ProblemFilter.unsolved => 'Unsolved',
        ProblemFilter.starred => 'Starred',
        ProblemFilter.revisionDue => 'Revision Due',
        ProblemFilter.hasNotes => 'Notes',
      };
}
