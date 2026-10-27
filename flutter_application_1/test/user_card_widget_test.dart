import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/widgets/user_card.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/screens/team_screen.dart';

void main() {
  group('Lesson 3.11 - Stateless Widgets (UserCard Tests)', () {
    test('UserCard extends StatelessWidget and has immutable fields', () {
      const card = UserCard(
        name: 'Meera Patel',
        role: 'Dispatcher',
      );

      expect(card, isA<StatelessWidget>());
      expect(card.name, 'Meera Patel');
      expect(card.role, 'Dispatcher');
      expect(card.email, isNull);
    });

    testWidgets('UserCard renders initials, name, and role badge correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserCard(
              name: 'Arjun Singh',
              role: 'Delivery Executive',
              email: 'arjun@farm2factory.com',
              phone: '+91 98765 22222',
            ),
          ),
        ),
      );

      // Verify initials derived from name
      expect(find.text('AS'), findsOneWidget);
      // Verify name
      expect(find.text('Arjun Singh'), findsOneWidget);
      // Verify role badge
      expect(find.text('DELIVERY EXECUTIVE'), findsOneWidget);
      // Verify email and phone
      expect(find.text('arjun@farm2factory.com'), findsOneWidget);
      expect(find.text('+91 98765 22222'), findsOneWidget);
    });

    testWidgets('UserCard responds to tap event when onTap is provided', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserCard(
              name: 'Karthik Rao',
              role: 'Admin',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(UserCard));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('UserCard supports optional custom colors and trailing widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserCard(
              name: 'Anita Joshi',
              role: 'Quality Inspector',
              avatarColor: Colors.deepPurple,
              badgeColor: Colors.amber,
              badgeTextColor: Colors.black,
              trailing: Icon(Icons.check_circle, key: Key('verified-icon')),
            ),
          ),
        ),
      );

      expect(find.text('AJ'), findsOneWidget);
      expect(find.text('Anita Joshi'), findsOneWidget);
      expect(find.text('QUALITY INSPECTOR'), findsOneWidget);
      expect(find.byKey(const Key('verified-icon')), findsOneWidget);
    });

    testWidgets('HomeScreen reuses UserCard with multiple distinct inputs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Check the 4 UserCard instances in HomeScreen:
      // 1. Active Supervisor: Shyam Sharma
      // 2. Dispatcher: Meera
      // 3. Delivery Executive: Arjun
      // 4. Admin: Karthik
      expect(find.byType(UserCard), findsNWidgets(4));
      expect(find.text('Shyam Sharma'), findsOneWidget);
      expect(find.text('Meera'), findsOneWidget);
      expect(find.text('Arjun'), findsOneWidget);
      expect(find.text('Karthik'), findsOneWidget);
      expect(find.text('DISPATCHER'), findsOneWidget);
      expect(find.text('DELIVERY EXECUTIVE'), findsOneWidget);
      expect(find.text('ADMIN'), findsOneWidget);
    });

    testWidgets('ProfileScreen reuses UserCard for operator profile details', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      expect(find.byType(UserCard), findsOneWidget);
      expect(find.text('COOPERATIVE ADMIN'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('TeamScreen reuses UserCard across directory list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TeamScreen(),
        ),
      );

      expect(find.text('Cooperative Team'), findsOneWidget);
      // Check multiple team members rendered using UserCard
      expect(find.byType(UserCard), findsNWidgets(5));
      expect(find.text('Meera Patel'), findsOneWidget);
      expect(find.text('Arjun Singh'), findsOneWidget);
      expect(find.text('Karthik Rao'), findsOneWidget);
      expect(find.text('Pooja Verma'), findsOneWidget);
      expect(find.text('Ramesh Kumar'), findsOneWidget);
    });
  });
}
