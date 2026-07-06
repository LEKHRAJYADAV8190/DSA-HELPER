import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  int _index(String location) {
    if (location.startsWith(AppRoutes.dsaSheet)) return 1;
    if (location.startsWith(AppRoutes.revision)) return 2;
    if (location.startsWith(AppRoutes.dryRun)) return 3;
    if (location.startsWith(AppRoutes.notes)) return 4;
    if (location.startsWith(AppRoutes.settings)) return 5;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index(location),
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go(AppRoutes.home);
            case 1:
              context.go(AppRoutes.dsaSheet);
            case 2:
              context.go(AppRoutes.revision);
            case 3:
              context.go(AppRoutes.dryRun);
            case 4:
              context.go(AppRoutes.notes);
            case 5:
              context.go(AppRoutes.settings);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'DSA',
          ),
          NavigationDestination(
            icon: Icon(Icons.refresh_outlined),
            selectedIcon: Icon(Icons.refresh),
            label: 'Revision',
          ),
          NavigationDestination(
            icon: Icon(Icons.draw_outlined),
            selectedIcon: Icon(Icons.draw),
            label: 'Dry Run',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
