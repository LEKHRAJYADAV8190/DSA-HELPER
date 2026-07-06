import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import '../../core/constants/app_branding.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return Future.value(true);
  });
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await Workmanager().initialize(callbackDispatcher);
    _ready = true;
  }

  Future<void> updateOngoingTasks(List<TaskEntity> tasks) async {
    if (tasks.isEmpty) {
      await _plugin.cancel(NotificationIds.ongoingTasks);
      return;
    }

    final pending = tasks.where((t) => !t.completed).toList();
    if (pending.isEmpty) {
      await _plugin.cancel(NotificationIds.ongoingTasks);
      return;
    }

    final body = pending.map((t) => '☐ ${t.title}').join('\n');
    final androidDetails = AndroidNotificationDetails(
      'tasks_ongoing',
      '${AppBranding.name} — Today\'s Tasks',
      channelDescription: 'Persistent daily task reminder',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: false,
    );

    await _plugin.show(
      NotificationIds.ongoingTasks,
      '${AppBranding.name} — Tasks (${pending.length} remaining)',
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  Future<void> scheduleRevisionReminders(AppSettingsEntity settings) async {
    await _plugin.cancel(NotificationIds.morningRevision);
    await _plugin.cancel(NotificationIds.eveningRevision);

    await _scheduleDaily(
      id: NotificationIds.morningRevision,
      channelId: 'revision_morning',
      channelName: 'Morning Revision',
      title: 'Good Morning — ${AppBranding.name}',
      body: 'Start your daily DSA revision batch',
      hour: settings.morningNotificationHour,
      minute: settings.morningNotificationMinute,
    );

    await _scheduleDaily(
      id: NotificationIds.eveningRevision,
      channelId: 'revision_evening',
      channelName: 'Evening Revision Reminder',
      title: 'Revision Pending',
      body: 'Complete today\'s revision tasks before the day ends',
      hour: settings.eveningNotificationHour,
      minute: settings.eveningNotificationMinute,
    );
  }

  Future<void> _scheduleDaily({
    required int id,
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelName,
      importance: Importance.high,
      priority: Priority.high,
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Exact alarms may fail on some devices without permission — skip silently.
    }
  }

  Future<void> showEveningRevisionPending(int pendingCount) async {
    if (pendingCount <= 0) return;
    const androidDetails = AndroidNotificationDetails(
      'revision_evening_now',
      'Evening Revision Reminder',
      channelDescription: 'Evening revision reminder when tasks pending',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _plugin.show(
      NotificationIds.eveningRevision + 1,
      'Revision Pending',
      '$pendingCount revision task${pendingCount == 1 ? '' : 's'} remaining today',
      const NotificationDetails(android: androidDetails),
    );
  }
}
