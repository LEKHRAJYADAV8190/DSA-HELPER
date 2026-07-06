import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../../presentation/screens/dry_run_screen.dart';
import '../../presentation/screens/dsa_sheet_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/main_shell.dart';
import '../../presentation/screens/notes_screen.dart';
import '../../presentation/screens/problem_detail_screen.dart';
import '../../presentation/screens/revision_screen.dart';
import '../../presentation/screens/search_screen.dart';
import '../../presentation/screens/patterns_screen.dart';
import '../../presentation/screens/settings_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
          GoRoute(path: AppRoutes.dsaSheet, builder: (_, __) => const DsaSheetScreen()),
          GoRoute(path: AppRoutes.revision, builder: (_, __) => const RevisionScreen()),
          GoRoute(path: AppRoutes.dryRun, builder: (_, __) => const DryRunScreen()),
          GoRoute(path: AppRoutes.notes, builder: (_, __) => const NotesScreen()),
          GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsScreen()),
        ],
      ),
      GoRoute(
        path: AppRoutes.problem,
        builder: (_, state) => ProblemDetailScreen(problemId: state.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.search, builder: (_, __) => const SearchScreen()),
      GoRoute(path: AppRoutes.patterns, builder: (_, __) => const PatternsScreen()),
      GoRoute(
        path: AppRoutes.patternDetail,
        builder: (_, state) => PatternDetailScreen(
          patternName: state.pathParameters['name']!,
        ),
      ),
    ],
  );
}
