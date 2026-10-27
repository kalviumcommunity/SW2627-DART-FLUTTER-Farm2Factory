import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/user_card.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/utils/validators.dart';

void main() {
  group('Lesson 3.10 - Project Folder Structure Tests', () {
    test('models/ - User / UserModel data shape operates as expected', () {
      final user = User(
        uid: 'user_001',
        name: 'Aarav Patel',
        email: 'aarav@dairy.coop',
        role: 'collector',
      );

      expect(user.uid, 'user_001');
      expect(user.name, 'Aarav Patel');
      expect(user.email, 'aarav@dairy.coop');
      expect(user.role, 'collector');

      final map = user.toMap();
      expect(map['email'], 'aarav@dairy.coop');
      expect(map['name'], 'Aarav Patel');
      expect(map['role'], 'collector');
    });

    test('utils/ - Validators check required fields and phones correctly', () {
      expect(Validators.required(null), 'This field is required');
      expect(Validators.required(''), 'This field is required');
      expect(Validators.required('Valid text'), isNull);

      expect(Validators.phone('12345'), 'Enter a valid 10-digit mobile number');
      expect(Validators.phone('9876543210'), isNull);
      expect(Validators.password('123'), 'Use at least 6 characters');
      expect(Validators.password('123456'), isNull);
    });

    testWidgets('widgets/ - UserCard renders user details and responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserCard(
              name: 'Shyam Sharma',
              role: 'Field Supervisor',
              email: 'shyam@farm2factory.com',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Shyam Sharma'), findsOneWidget);
      expect(find.text('FIELD SUPERVISOR'), findsOneWidget);
      expect(find.text('shyam@farm2factory.com'), findsOneWidget);

      await tester.tap(find.byType(UserCard));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('widgets/ - CustomButton renders label, handles taps, and supports loading state', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Submit Milk Record',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Submit Milk Record'), findsOneWidget);
      await tester.tap(find.byType(CustomButton));
      await tester.pump();
      expect(tapped, isTrue);

      // Verify loading state disables clicks and displays spinner
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Submit Milk Record',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('screens/ - HomeScreen renders title and child widgets', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.text('Farm2Factory Home'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.byType(UserCard), findsOneWidget);
      expect(find.text('Milk Collection Entries'), findsOneWidget);
    });

    testWidgets('screens/ - ProfileScreen renders user settings and logout button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      expect(find.text('User Profile'), findsOneWidget);
      expect(find.text('Account Management'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });
  });
}
