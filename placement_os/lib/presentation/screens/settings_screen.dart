import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_branding.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/entities/entities.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final stats = ref.watch(statsProvider);
    final settingsRepo = ref.read(settingsRepoProvider);
    final problemRepo = ref.read(problemRepoProvider);
    final pdfExport = ref.read(pdfExportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Statistics', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ProgressRing(
                      progress: stats.total == 0 ? 0 : stats.solved / stats.total,
                      size: 64,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Solved: ${stats.solved} / ${stats.total}'),
                          Text('Remaining: ${stats.remaining}'),
                          Text("Today's solved: ${stats.todaySolved}"),
                          Text("Today's revision: ${stats.todayRevision}"),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text('Revision: ${stats.revisionCompleted} done · ${stats.revisionRemaining} left'),
                Text('Revision accuracy: ${stats.revisionAccuracy.toStringAsFixed(0)}%'),
                Text('Current streak: ${stats.streak} days'),
                Text('Longest streak: ${stats.longestStreak} days'),
                Text('Total notes: ${stats.totalNotes}'),
                Text('Starred: ${stats.starredQuestions}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(AppBranding.name, style: Theme.of(context).textTheme.titleLarge),
                Text(AppBranding.tagline),
                const SizedBox(height: 4),
                Text('Personal DSA revision app — Striver A2Z Sheet'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                _CountTile(
                  title: 'Daily New Questions',
                  value: settings.dailyNewQuestions,
                  onChanged: (v) async {
                    await settingsRepo.save(settings.copyWith(dailyNewQuestions: v));
                    refresh(ref);
                  },
                ),
                _CountTile(
                  title: 'Daily Revision Questions',
                  value: settings.revisionsPerDay,
                  onChanged: (v) async {
                    await settingsRepo.save(settings.copyWith(revisionsPerDay: v));
                    refresh(ref);
                  },
                ),
                _CountTile(
                  title: 'Daily Star Revision',
                  value: settings.dailyStarRevision,
                  onChanged: (v) async {
                    await settingsRepo.save(settings.copyWith(dailyStarRevision: v));
                    refresh(ref);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.wb_sunny),
                  title: const Text('Morning Notification'),
                  subtitle: Text(
                    '${settings.morningNotificationHour.toString().padLeft(2, '0')}:${settings.morningNotificationMinute.toString().padLeft(2, '0')}',
                  ),
                  onTap: () => _pickTime(
                    context,
                    ref,
                    settings,
                    settingsRepo,
                    morning: true,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.nightlight),
                  title: const Text('Evening Reminder'),
                  subtitle: Text(
                    '${settings.eveningNotificationHour.toString().padLeft(2, '0')}:${settings.eveningNotificationMinute.toString().padLeft(2, '0')}',
                  ),
                  onTap: () => _pickTime(
                    context,
                    ref,
                    settings,
                    settingsRepo,
                    morning: false,
                  ),
                ),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Always on — premium dark theme'),
                  value: settings.darkMode,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('Export Notes PDF'),
                  subtitle: Text(
                    '${stats.totalNotes} problem notes + ${ref.watch(shortNotesProvider).length} short notes',
                  ),
                  onTap: () async {
                    try {
                      await pdfExport.shareNotesPdf(
                        problemRepo.getAllProblems(),
                        shortNotes: ref.read(shortNotesRepoProvider).getAll(),
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Export failed: $e')),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.upload),
                  title: const Text('Backup Data'),
                  onTap: () async {
                    final data = await problemRepo.exportData();
                    final json = const JsonEncoder.withIndent('  ').convert(data);
                    final dir = await getTemporaryDirectory();
                    final file = File('${dir.path}/lekhraj_backup.json');
                    await file.writeAsString(json);
                    await Share.shareXFiles([XFile(file.path)], text: AppBranding.backupLabel);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Restore Data'),
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['json'],
                    );
                    if (result == null || result.files.single.path == null) return;
                    final content = await File(result.files.single.path!).readAsString();
                    await problemRepo.importData(json.decode(content) as Map<String, dynamic>);
                    refresh(ref);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data restored')),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: AppColors.error),
                  title: const Text('Reset Progress'),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset all progress?'),
                        content: const Text(
                          'This clears solved status, notes, stars, tasks, and revision queue.',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await problemRepo.resetProgress();
                      await settingsRepo.resetRevisionQueue();
                      await ref.read(taskRepoProvider).clearAutoTasks();
                      refresh(ref);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    AppSettingsEntity settings,
    SettingsRepository settingsRepo, {
    required bool morning,
  }) async {
    final initial = morning
        ? TimeOfDay(
            hour: settings.morningNotificationHour,
            minute: settings.morningNotificationMinute,
          )
        : TimeOfDay(
            hour: settings.eveningNotificationHour,
            minute: settings.eveningNotificationMinute,
          );
    final time = await showTimePicker(context: context, initialTime: initial);
    if (time == null) return;

    final updated = morning
        ? settings.copyWith(
            morningNotificationHour: time.hour,
            morningNotificationMinute: time.minute,
          )
        : settings.copyWith(
            eveningNotificationHour: time.hour,
            eveningNotificationMinute: time.minute,
          );
    await settingsRepo.save(updated);
    await NotificationService.instance.scheduleRevisionReminders(updated);
    refresh(ref);
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({required this.title, required this.value, required this.onChanged});
  final String title;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value <= 1 ? null : () => onChanged(value - 1),
          ),
          Text('$value'),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: value >= 10 ? null : () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}
