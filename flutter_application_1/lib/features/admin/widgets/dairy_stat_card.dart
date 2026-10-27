import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Clean rounded card matching the Farm2Factory cow + milk aesthetic.
class DairyStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? cardBgColor;
  final String title;
  final String value;
  final String? subtitle;
  final String? badgeText;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const DairyStatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    this.cardBgColor,
    required this.title,
    required this.value,
    this.subtitle,
    this.badgeText,
    this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardBgColor ?? AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.creamBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.creamSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.creamBorder),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? AppTheme.brandGreen).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: (badgeColor ?? AppTheme.brandGreen).withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      badgeText!,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: badgeColor ?? AppTheme.brandGreenDark,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
