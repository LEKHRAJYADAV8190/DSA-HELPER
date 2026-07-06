import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_branding.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/providers.dart';

class PlacementOSApp extends ConsumerWidget {
  const PlacementOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seed = ref.watch(seedProvider);
    final router = createRouter();

    return seed.when(
      loading: () => MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF9D4EDD)))),
      ),
      error: (e, _) => MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: Center(child: Text('${AppBranding.name}: Failed to load: $e'))),
      ),
      data: (_) => MaterialApp.router(
        title: AppBranding.name,
        theme: AppTheme.dark,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
