import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

/// Interactive button for switching themes with support for Light, Dark, System Auto, and Warm Peach.
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
        final pref = ThemeController.instance.themePreference;
        final isDark = ThemeController.instance.isDark;
        final isPeach = ThemeController.instance.isPeach;

        final IconData icon = isPeach
            ? Icons.palette_rounded
            : (pref == 'system'
                ? (isDark ? Icons.brightness_auto : Icons.brightness_auto_outlined)
                : (isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded));

        final Color iconColor = isPeach
            ? AppTheme.brandPeachDark
            : (isDark
                ? const Color(0xFFFBBF24) // Warm amber moonlight
                : const Color(0xFF0F5132)); // Deep emerald sunlight

        final String label = isPeach
            ? 'Peach'
            : (pref == 'system' ? 'Auto' : (isDark ? 'Dark' : 'Light'));

        final String tooltip = isPeach
            ? 'Theme: Warm Peach'
            : (pref == 'system'
                ? 'Theme: System (${isDark ? "Dark" : "Light"})'
                : (isDark ? 'Theme: Dark Mode' : 'Theme: Light Mode'));

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
                key: ValueKey(pref),
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
                  label,
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

/// Dialog / BottomSheet for explicitly selecting Light, Dark, System, or Warm Peach mode.
void showThemeSelectionDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.cardSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return ListenableBuilder(
        listenable: ThemeController.instance,
        builder: (ctx, _) {
          final currentPref = ThemeController.instance.themePreference;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  const SizedBox(height: 4),
                  Text(
                    'Choose your visual preference for the entire application.',
                    style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  _themeOptionTile(
                    title: 'System Default',
                    subtitle: 'Automatically match your device appearance settings',
                    icon: Icons.brightness_auto,
                    selected: currentPref == 'system',
                    onTap: () {
                      ThemeController.instance.setThemePreference('system');
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 8),
                  _themeOptionTile(
                    title: 'Light Mode',
                    subtitle: 'Clean executive canvas with crisp emerald & peach accents',
                    icon: Icons.wb_sunny_rounded,
                    selected: currentPref == 'light',
                    onTap: () {
                      ThemeController.instance.setThemePreference('light');
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 8),
                  _themeOptionTile(
                    title: 'Dark Mode',
                    subtitle: 'Midnight Obsidian theme with high contrast OLED surfaces',
                    icon: Icons.dark_mode_rounded,
                    selected: currentPref == 'dark',
                    onTap: () {
                      ThemeController.instance.setThemePreference('dark');
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 8),
                  _themeOptionTile(
                    title: 'Warm Peach Mode',
                    subtitle: 'Cozy harvest peach canvas with warm terracotta accents',
                    icon: Icons.palette_rounded,
                    selected: currentPref == 'peach',
                    accentColor: AppTheme.brandPeachDark,
                    onTap: () {
                      ThemeController.instance.setThemePreference('peach');
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 8),
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
  Color? accentColor,
}) {
  final primaryAccent = accentColor ??
      (AppTheme.isDark ? AppTheme.brandGreenLight : AppTheme.brandGreen);

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected
            ? primaryAccent.withOpacity(0.12)
            : AppTheme.creamSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? primaryAccent : AppTheme.creamBorder,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected
                  ? primaryAccent
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
                    color: selected ? primaryAccent : AppTheme.textPrimary,
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
              color: primaryAccent,
              size: 20,
            ),
        ],
      ),
    ),
  );
}
