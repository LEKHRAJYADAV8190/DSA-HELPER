import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'data/datasources/hive_service.dart';
import 'presentation/providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await HiveService.instance.init();
  } catch (e, st) {
    debugPrint('Hive init failed: $e\n$st');
  }

  try {
    await NotificationService.instance.init();
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }

  final container = ProviderContainer();

  try {
    await container.read(seedProvider.future);
    final dailyTasks = container.read(dailyTaskServiceProvider);
    await dailyTasks.syncForToday();

    final settings = container.read(settingsRepoProvider).get();
    await NotificationService.instance.scheduleRevisionReminders(settings);

    final tasks = dailyTasks.notificationTasks();
    await NotificationService.instance.updateOngoingTasks(tasks);
  } catch (e, st) {
    debugPrint('Startup sync failed: $e\n$st');
  }

  runApp(UncontrolledProviderScope(container: container, child: const PlacementOSApp()));
}
