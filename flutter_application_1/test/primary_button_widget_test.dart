import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/widgets/primary_button.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/widgets/milk_counter_widget.dart';

void main() {
  group('Lesson 3.13 - Reusable Widgets (PrimaryButton Tests)', () {
    test('PrimaryButton extends StatelessWidget and accepts flexible parameters', () {
      const button = PrimaryButton(
        label: 'Submit Collection',
        onPressed: null,
        color: Colors.blue,
        fullWidth: false,
        borderRadius: 16.0,
      );

      expect(button, isA<StatelessWidget>());
      expect(button.label, 'Submit Collection');
      expect(button.color, Colors.blue);
      expect(button.fullWidth, isFalse);
      expect(button.borderRadius, 16.0);
    });

    testWidgets('Renders label and executes onPressed callback when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Proceed',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Proceed'), findsOneWidget);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('Renders icon and applies custom color and fullWidth', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Download Report',
              icon: Icons.file_download,
              color: Colors.purple,
              fullWidth: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Download Report'), findsOneWidget);
      expect(find.byIcon(Icons.file_download), findsOneWidget);

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, double.infinity);
    });

    testWidgets('Renders outlined variant when outlined = true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Secondary Action',
              outlined: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Secondary Action'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('Displays loading spinner and prevents taps when isLoading = true', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Submitting...',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // The text is replaced by the spinner to keep layout clean
      expect(find.text('Submitting...'), findsNothing);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('HomeScreen reuses PrimaryButton across multiple actions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Verify PrimaryButton instances in HomeScreen (Quick Actions + embedded counter)
      expect(find.byType(PrimaryButton), findsAtLeastNWidgets(4));
      expect(find.text('Milk Collection Entries'), findsOneWidget);
      expect(find.text('Farmers Directory'), findsOneWidget);
      expect(find.text('Reports & Export'), findsOneWidget);
      expect(find.text('Cooperative Team Directory'), findsOneWidget);
    });

    testWidgets('ProfileScreen reuses PrimaryButton for navigation and dangerous logout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      expect(find.byType(PrimaryButton), findsNWidgets(2));
      expect(find.text('Return to Home'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('MilkCounterWidget reuses PrimaryButton as compact inline action', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MilkCounterWidget(initialLitres: 10.0),
          ),
        ),
      );

      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.text('Log Collection'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });
}
