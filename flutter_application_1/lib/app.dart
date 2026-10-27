import 'package:flutter/material.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

/// Root widget: sets the theme mode and hands navigation to go_router.
class Farm2FactoryApp extends StatelessWidget {
  const Farm2FactoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final mode = ThemeController.instance.themeMode;
        final isDark = ThemeController.instance.isDark;
        return MaterialApp.router(
          key: ValueKey('f2f_theme_${mode.name}_$isDark'),
          title: 'Farm2Factory',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
