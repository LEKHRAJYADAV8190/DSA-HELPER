import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DSA Notes'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Problem Notes'),
              Tab(text: 'Yaad Rakhna'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ProblemNotesTab(),
            _ShortNotesTab(),
          ],
        ),
      ),
    );
  }
}

class _ProblemNotesTab extends ConsumerStatefulWidget {
  const _ProblemNotesTab();

  @override
  ConsumerState<_ProblemNotesTab> createState() => _ProblemNotesTabState();
}

class _ProblemNotesTabState extends ConsumerState<_ProblemNotesTab> {
  String _search = '';
  NotesSort _sort = NotesSort.topic;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(problemRepoProvider);
    final problems = repo.notesList(sort: _sort, query: _search.isEmpty ? null : _search);

    final grouped = <String, List<ProblemEntity>>{};
    for (final p in problems) {
      grouped.putIfAbsent(p.topicName, () => []).add(p);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search notes, questions, topics...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('By Topic'),
                      selected: _sort == NotesSort.topic,
                      onSelected: (_) => setState(() => _sort = NotesSort.topic),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Recently Updated'),
                      selected: _sort == NotesSort.recentlyUpdated,
                      onSelected: (_) => setState(() => _sort = NotesSort.recentlyUpdated),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Starred'),
                      selected: _sort == NotesSort.starred,
                      onSelected: (_) => setState(() => _sort = NotesSort.starred),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: problems.isEmpty
              ? const Center(child: Text('No notes yet. Open a problem to add notes.'))
              : _sort == NotesSort.topic
                  ? ListView(
                      padding: const EdgeInsets.all(12),
                      children: grouped.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                entry.key,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.primaryLight,
                                    ),
                              ),
                            ),
                            ...entry.value.map((p) => _NoteCard(problem: p)),
                          ],
                        );
                      }).toList(),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: problems.length,
                      itemBuilder: (context, i) => _NoteCard(problem: problems[i]),
                    ),
        ),
      ],
    );
  }
}

class _ShortNotesTab extends ConsumerStatefulWidget {
  const _ShortNotesTab();

  @override
  ConsumerState<_ShortNotesTab> createState() => _ShortNotesTabState();
}

class _ShortNotesTabState extends ConsumerState<_ShortNotesTab> {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    await ref.read(shortNotesRepoProvider).add(
          text: text,
          title: _titleController.text.trim(),
        );
    _titleController.clear();
    _textController.clear();
    refresh(ref);
    if (mounted) FocusScope.of(context).unfocus();
  }

  Future<void> _editNote(ShortNoteEntity note) async {
    final titleController = TextEditingController(text: note.title);
    final textController = TextEditingController(text: note.text);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Short Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Topic (optional)',
                  hintText: 'e.g. Arrays, DP, Graph',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Yaad rakhna',
                  hintText: 'e.g. Array format: int arr[] = new int[n]',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (saved == true && textController.text.trim().isNotEmpty) {
      await ref.read(shortNotesRepoProvider).update(
            note.id,
            title: titleController.text.trim(),
            text: textController.text.trim(),
          );
      refresh(ref);
    }
    titleController.dispose();
    textController.dispose();
  }

  Future<void> _deleteNote(ShortNoteEntity note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This will remove it from PDF export too.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(shortNotesRepoProvider).delete(note.id);
      refresh(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(shortNotesProvider);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Short Notes — Yaad Rakhna',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryLight),
              ),
              const SizedBox(height: 4),
              Text(
                'Formats, mistakes, tricks jo yaad rakhne hain. PDF ke end mein "Mistakes" section mein aayenge.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Topic (optional)',
                  hintText: 'Arrays, Recursion, DP...',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'e.g. Array ka format: int arr[] = new int[n]',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _addNote,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (notes.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(
              child: Text(
                'Koi short note nahi. Upar add karo — PDF export mein last mein dikhega.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          )
        else
          ...notes.map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (note.title.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    note.title,
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              Text(note.text, style: Theme.of(context).textTheme.bodyLarge),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _editNote(note),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _deleteNote(note),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.problem});
  final ProblemEntity problem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: () => context.push('/problem/${problem.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(problem.name, style: Theme.of(context).textTheme.titleMedium),
                ),
                if (problem.notesStarred)
                  const Icon(Icons.star, color: AppColors.warning, size: 18),
              ],
            ),
            Text(problem.topicName, style: Theme.of(context).textTheme.bodySmall),
            if (problem.notesUpdatedAt != null)
              Text(
                'Updated ${_formatDate(problem.notesUpdatedAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            const SizedBox(height: 8),
            MarkdownBody(
              data: problem.notes.length > 200
                  ? '${problem.notes.substring(0, 200)}...'
                  : problem.notes,
              styleSheet: MarkdownStyleSheet(p: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
