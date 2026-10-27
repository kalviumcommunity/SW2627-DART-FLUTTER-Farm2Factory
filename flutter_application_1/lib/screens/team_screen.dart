import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/routes/app_router.dart';
import '../core/theme/app_theme.dart';
import '../widgets/user_card.dart';

/// Full page screen showcasing a directory of cooperative personnel.
///
/// Fully composed using the reusable [UserCard] Stateless Widget.
class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teamMembers = [
      {
        'name': 'Meera Patel',
        'role': 'Dispatcher',
        'email': 'meera@farm2factory.com',
        'phone': '+91 98765 11111',
        'avatarColor': const Color(0xFFD97706),
      },
      {
        'name': 'Arjun Singh',
        'role': 'Delivery Executive',
        'email': 'arjun@farm2factory.com',
        'phone': '+91 98765 22222',
        'avatarColor': const Color(0xFF0284C7),
      },
      {
        'name': 'Karthik Rao',
        'role': 'Admin',
        'email': 'karthik@farm2factory.com',
        'phone': '+91 98765 33333',
        'avatarColor': const Color(0xFFDC2626),
      },
      {
        'name': 'Pooja Verma',
        'role': 'Collector',
        'email': 'pooja@farm2factory.com',
        'phone': '+91 98765 44444',
        'avatarColor': const Color(0xFF7C3AED),
      },
      {
        'name': 'Ramesh Kumar',
        'role': 'Farmer Liaison',
        'email': 'ramesh@farm2factory.com',
        'phone': '+91 98765 55555',
        'avatarColor': const Color(0xFF16A34A),
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg,
        title: const Text(
          'Cooperative Team',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home, color: Color(0xFF1E293B)),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          final member = teamMembers[index];
          return UserCard(
            name: member['name'] as String,
            role: member['role'] as String,
            email: member['email'] as String,
            phone: member['phone'] as String,
            avatarColor: member['avatarColor'] as Color,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Member profile: ${member['name']}')),
              );
            },
          );
        },
      ),
    );
  }
}
