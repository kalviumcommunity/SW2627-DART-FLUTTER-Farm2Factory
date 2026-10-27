import 'package:flutter/material.dart';

/// Reusable Stateless Widget that displays user profile details.
///
/// Takes all its data through constructor arguments and renders a consistent,
/// self-contained card UI with an avatar, name, contact details, and role badge.
class UserCard extends StatelessWidget {
  final String name;
  final String role;
  final String? email;
  final String? phone;
  final Color? avatarColor;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const UserCard({
    super.key,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    this.avatarColor,
    this.badgeColor,
    this.badgeTextColor,
    this.onTap,
    this.trailing,
  });

  /// Derive user initials from full name (e.g. "Arjun Singh" -> "AS").
  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  /// Get fallback role badge color based on role name if not explicitly provided.
  Color _resolveBadgeColor() {
    if (badgeColor != null) return badgeColor!;
    final lower = role.toLowerCase();
    if (lower.contains('admin')) return const Color(0xFFFEE2E2); // soft red
    if (lower.contains('dispatch')) return const Color(0xFFFEF3C7); // soft amber
    if (lower.contains('collector')) return const Color(0xFFE0E7FF); // soft indigo
    if (lower.contains('farmer')) return const Color(0xFFDCFCE7); // soft green
    return const Color(0xFFF1F5F9); // slate
  }

  /// Get fallback role text color based on role name if not explicitly provided.
  Color _resolveBadgeTextColor() {
    if (badgeTextColor != null) return badgeTextColor!;
    final lower = role.toLowerCase();
    if (lower.contains('admin')) return const Color(0xFFB91C1C); // dark red
    if (lower.contains('dispatch')) return const Color(0xFFB45309); // dark amber
    if (lower.contains('collector')) return const Color(0xFF4338CA); // dark indigo
    if (lower.contains('farmer')) return const Color(0xFF15803D); // dark green
    return const Color(0xFF475569); // slate
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAvatarColor = avatarColor ?? const Color(0xFF16A34A);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              // Avatar with calculated initials
              CircleAvatar(
                radius: 24,
                backgroundColor: effectiveAvatarColor,
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // User information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (email != null && email!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (phone != null && phone!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        phone!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _resolveBadgeColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: _resolveBadgeTextColor(),
                  ),
                ),
              ),

              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
