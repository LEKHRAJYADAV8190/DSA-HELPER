import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color background = Color(0xFF0D0B14);
  static const Color surface = Color(0xFF161222);
  static const Color card = Color(0xFF211C33);
  static const Color primary = Color(0xFF9D4EDD);
  static const Color primaryLight = Color(0xFFC77DFF);
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFBE0B);
  static const Color error = Color(0xFFFF006E);
  static const Color overdue = Color(0xFFFF6B6B);
  static const Color textPrimary = Color(0xFFF8F7FF);
  static const Color textSecondary = Color(0xFFB8B3CC);
  static const Color textMuted = Color(0xFF7A7590);
  static const Color divider = Color(0xFF2D2840);
  static const Color easy = Color(0xFF06D6A0);
  static const Color medium = Color(0xFFFFBE0B);
  static const Color hard = Color(0xFFFF006E);
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double full = 999;
}

abstract final class RevisionConfig {
  static const int intervalDays = 7;
}

abstract final class HiveBoxes {
  static const String problems = 'problems';
  static const String tasks = 'tasks';
  static const String settings = 'settings';
  static const String revisionHistory = 'revision_history';
  static const String shortNotes = 'short_notes';
}

abstract final class AppRoutes {
  static const String home = '/';
  static const String dsaSheet = '/dsa';
  static const String revision = '/revision';
  static const String notes = '/notes';
  static const String dryRun = '/dry-run';
  static const String settings = '/settings';
  static const String problem = '/problem/:id';
  static const String search = '/search';
  static const String patterns = '/patterns';
  static const String patternDetail = '/patterns/:name';
}

abstract final class NotificationIds {
  static const int ongoingTasks = 1001;
  static const int morningRevision = 1002;
  static const int eveningRevision = 1003;
}
