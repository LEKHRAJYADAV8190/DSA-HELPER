import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';
  ProblemFilter _filter = ProblemFilter.all;
  String? _pattern;
  String? _topicId;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(problemRepoProvider);
    final topics = ref.watch(topicsProvider);
    final patterns = repo.getAllPatterns();
    final revisionDue = ref.watch(revisionDueIdsProvider);

    final results = _query.isEmpty && _filter == ProblemFilter.all && _pattern == null && _topicId == null
        ? <ProblemEntity>[]
        : repo.queryProblems(
            ProblemSearchQuery(
              text: _query,
              filter: _filter,
              pattern: _pattern,
              topicId: _topicId,
            ),
            revisionDueIds: revisionDue,
          );

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Name, topic, pattern, notes...',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _topicId,
                    decoration: const InputDecoration(labelText: 'Topic', isDense: true),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All topics')),
                      ...topics.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))),
                    ],
                    onChanged: (v) => setState(() => _topicId = v),
                  ),
                ),
                const SizedBox(width: 8),
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
                    label: Text(_label(f)),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text(
                      _query.isEmpty && _filter == ProblemFilter.all
                          ? 'Start typing or apply filters'
                          : 'No results',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final p = results[i];
                      final due = revisionDue.contains(p.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          onTap: () => context.push('/problem/${p.id}'),
                          child: ListTile(
                            title: Text(p.name),
                            subtitle: Text(
                              '${p.topicName} · ${p.patterns.take(2).join(', ')}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ProblemStatusIcons(problem: p, revisionDue: due),
                                const SizedBox(width: 8),
                                DifficultyChip(difficulty: p.difficulty),
                              ],
                            ),
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
        ProblemFilter.starred => 'Starred',
        ProblemFilter.solved => 'Solved',
        ProblemFilter.unsolved => 'Unsolved',
        ProblemFilter.hasNotes => 'Notes',
        ProblemFilter.revisionDue => 'Rev. Due',
      };
}
