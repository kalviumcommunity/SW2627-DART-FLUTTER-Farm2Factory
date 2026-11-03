import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

/// Interactive button for switching themes with support for Light, Dark, and System Auto.
class ThemeModeButton extends StatelessWidget {
  final bool compact;
  final bool showLabel;

  const ThemeModeButton({
    super.key,
    this.compact = true,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final mode = ThemeController.instance.themeMode;
        final isDark = ThemeController.instance.isDark;

        final IconData icon = mode == ThemeMode.system
            ? (isDark ? Icons.brightness_auto : Icons.brightness_auto_outlined)
            : (isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded);

        final Color iconColor = isDark
            ? const Color(0xFFFBBF24) // Warm amber moonlight
            : const Color(0xFF0F5132); // Deep emerald sunlight

        final String tooltip = mode == ThemeMode.system
            ? 'Theme: System (${isDark ? "Dark" : "Light"})'
            : (isDark ? 'Theme: Dark Mode' : 'Theme: Light Mode');

        if (!showLabel) {
          return IconButton(
            tooltip: '$tooltip (Tap to toggle, long-press for options)',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                icon,
                key: ValueKey(mode),
                color: iconColor,
                size: compact ? 20 : 22,
              ),
            ),
            onPressed: () => ThemeController.instance.toggleTheme(),
            onLongPress: () => showThemeSelectionDialog(context),
          );
        }

        return InkWell(
          onTap: () => ThemeController.instance.toggleTheme(),
          onLongPress: () => showThemeSelectionDialog(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.creamSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.creamBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  mode == ThemeMode.system
                      ? 'Auto'
                      : (isDark ? 'Dark' : 'Light'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Dialog / BottomSheet for explicitly selecting Light, Dark, or System mode.
void showThemeSelectionDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.cardSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return ListenableBuilder(
        listenable: ThemeController.instance,
        builder: (ctx, _) {
          final currentMode = ThemeController.instance.themeMode;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Appearance & Theme',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: AppTheme.textSecondary,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose your visual preference for the entire application.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 18),
                  _themeOptionTile(
                    title: 'System Default',
                    subtitle: 'Automatically match your device appearance settings',
                    icon: Icons.brightness_auto,
                    selected: currentMode == ThemeMode.system,
                    onTap: () {
                      ThemeController.instance.setThemeMode(ThemeMode.system);
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 10),
                  _themeOptionTile(
                    title: 'Light Mode',
                    subtitle: 'Clean executive canvas with crisp emerald accents',
                    icon: Icons.wb_sunny_rounded,
                    selected: currentMode == ThemeMode.light,
                    onTap: () {
                      ThemeController.instance.setThemeMode(ThemeMode.light);
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 10),
                  _themeOptionTile(
                    title: 'Dark Mode',
                    subtitle: 'Midnight Obsidian theme with high contrast OLED surfaces',
                    icon: Icons.dark_mode_rounded,
                    selected: currentMode == ThemeMode.dark,
                    onTap: () {
                      ThemeController.instance.setThemeMode(ThemeMode.dark);
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _themeOptionTile({
  required String title,
  required String subtitle,
  required IconData icon,
  required bool selected,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected
            ? AppTheme.brandGreen.withOpacity(0.12)
            : AppTheme.creamSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppTheme.brandGreen : AppTheme.creamBorder,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.brandGreen
                  : AppTheme.subtleBorder.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? (AppTheme.isDark ? AppTheme.brandGreenLight : AppTheme.brandGreen)
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            Icon(
              Icons.check_circle_rounded,
              color: AppTheme.isDark ? AppTheme.brandGreenLight : AppTheme.brandGreen,
              size: 20,
            ),
        ],
      ),
    ),
  );
}
