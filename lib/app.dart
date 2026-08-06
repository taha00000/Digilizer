import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

/// Root widget. Watches the selected theme so the whole app re-skins live,
/// exactly like the prototype's in-app theme switcher.
class EwayApp extends ConsumerWidget {
  const EwayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeId = ref.watch(themeControllerProvider);
    return MaterialApp.router(
      title: 'eWay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeFor(themeId),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
