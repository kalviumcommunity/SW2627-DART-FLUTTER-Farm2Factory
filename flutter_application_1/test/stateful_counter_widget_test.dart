import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/widgets/milk_counter_widget.dart';
import 'package:flutter_application_1/screens/home_screen.dart';

void main() {
  group('Lesson 3.12 - Stateful Widgets (MilkCounterWidget Tests)', () {
    test('MilkCounterWidget is a StatefulWidget', () {
      const widget = MilkCounterWidget(initialLitres: 12.0);
      expect(widget, isA<StatefulWidget>());
      expect(widget.initialLitres, 12.0);
    });

    testWidgets('Renders initial state with correct quantity, cans, and payout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MilkCounterWidget(initialLitres: 10.0),
          ),
        ),
      );

      // Verify initial 10.0 L readout
      expect(find.text('10.0 L'), findsOneWidget);
      // Verify initial can count (10L <= 40L = 1 can)
      expect(find.textContaining('1 standard dairy can'), findsOneWidget);
      // Verify default Cow Milk estimated payout (10.0 * 45.50 = ₹455.00)
      expect(find.text('₹455.00'), findsOneWidget);
      // Verify initial logged counter
      expect(find.text('0 Logged'), findsOneWidget);
    });

    testWidgets('Tapping increment (+) button updates quantity and payout via setState()', (tester) async {
      double? reportedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MilkCounterWidget(
              initialLitres: 10.0,
              onQuantityChanged: (val) => reportedValue = val,
            ),
          ),
        ),
      );

      // Find and tap the increase (+) button
      final addButton = find.byTooltip('Increase 0.5L');
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pump(); // Triggers scheduled rebuild from setState()

      // 10.0 + 0.5 = 10.5 L
      expect(find.text('10.5 L'), findsOneWidget);
      // 10.5 * 45.50 = ₹477.75
      expect(find.text('₹477.75'), findsOneWidget);
      expect(reportedValue, 10.5);
    });

    testWidgets('Tapping decrement (-) button reduces quantity via setState()', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MilkCounterWidget(initialLitres: 5.0),
          ),
        ),
      );

      final removeButton = find.byTooltip('Decrease 0.5L');
      expect(removeButton, findsOneWidget);

      await tester.tap(removeButton);
      await tester.pump();

      // 5.0 - 0.5 = 4.5 L
      expect(find.text('4.5 L'), findsOneWidget);
    });

    testWidgets('Quick increment chips (+5L) update state and recalculate can capacity', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MilkCounterWidget(initialLitres: 38.0),
          ),
        ),
      );

      // 38L fits in 1 can
      expect(find.textContaining('1 standard dairy can'), findsOneWidget);

      // Tap +5L chip
      await tester.tap(find.text('+5 L'));
      await tester.pump();

      // 38 + 5 = 43 L -> exceeds 40L, requires 2 cans
      expect(find.text('43.0 L'), findsOneWidget);
      expect(find.textContaining('2 standard dairy cans'), findsOneWidget);
    });

    testWidgets('Toggling milk type to Buffalo Milk updates rate and estimated payout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MilkCounterWidget(initialLitres: 10.0),
          ),
        ),
      );

      // Initial Cow rate: 10 * 45.50 = ₹455.00
      expect(find.text('₹455.00'), findsOneWidget);

      // Tap Buffalo Milk choice chip
      await tester.tap(find.text('Buffalo Milk (₹65.00/L)'));
      await tester.pump();

      // Buffalo rate: 10 * 65.00 = ₹650.00
      expect(find.text('₹650.00'), findsOneWidget);
    });

    testWidgets('Reset chip restores initial quantity', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MilkCounterWidget(initialLitres: 10.0),
          ),
        ),
      );

      // Increase to 20L
      await tester.tap(find.text('+10 L'));
      await tester.pump();
      expect(find.text('20.0 L'), findsOneWidget);

      // Tap Reset
      await tester.tap(find.text('Reset'));
      await tester.pump();

      // Restored to initial 10.0 L
      expect(find.text('10.0 L'), findsOneWidget);
    });

    testWidgets('Logging a collection increments logged count and shows SnackBar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MilkCounterWidget(initialLitres: 15.0),
          ),
        ),
      );

      expect(find.text('0 Logged'), findsOneWidget);

      // Tap Log Collection
      await tester.tap(find.text('Log Collection'));
      await tester.pump(); // Start SnackBar animation & rebuild

      expect(find.text('1 Logged'), findsOneWidget);
      expect(find.textContaining('Recorded entry #1: 15.0L'), findsOneWidget);
    });

    testWidgets('HomeScreen mounts MilkCounterWidget and facilitates user interaction', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.byType(MilkCounterWidget), findsOneWidget);
      expect(find.text('Interactive Collection Calculator'), findsOneWidget);
      expect(find.text('15.0 L'), findsOneWidget);

      // Scroll until visible and interact with counter on HomeScreen
      await tester.ensureVisible(find.text('+1 L'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+1 L'));
      await tester.pump();

      expect(find.text('16.0 L'), findsOneWidget);
    });
  });
}
