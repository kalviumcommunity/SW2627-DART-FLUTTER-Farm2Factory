import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/batch_list_screen.dart';
import 'package:flutter_application_1/screens/batch_detail_screen.dart';

void main() {
  group('Lesson 3.14 - Screen Navigation (3-Screen Flow Tests)', () {
    testWidgets('Each screen is wrapped in its own Scaffold with an AppBar', (tester) async {
      // Test Screen 1: HomeScreen has Scaffold & AppBar
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Test Screen 2: BatchListScreen has Scaffold & AppBar
      await tester.pumpWidget(
        const MaterialApp(
          home: BatchListScreen(),
        ),
      );
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Milk Dispatch Batches'), findsOneWidget);

      // Test Screen 3: BatchDetailScreen has Scaffold & AppBar
      final sampleBatch = BatchListScreen.sampleBatches.first;
      await tester.pumpWidget(
        MaterialApp(
          home: BatchDetailScreen(batch: sampleBatch),
        ),
      );
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(sampleBatch.id), findsOneWidget);
    });

    testWidgets('Forward and backward navigation across complete 3-screen flow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Stack level 1: [HomeScreen]
      expect(find.text('Farm2Factory Home'), findsOneWidget);
      expect(find.text('Browse Milk Batches (Navigation Flow)'), findsOneWidget);

      // Scroll to ensure button is visible and tap to trigger forward navigation
      await tester.ensureVisible(find.text('Browse Milk Batches (Navigation Flow)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Browse Milk Batches (Navigation Flow)'));
      await tester.pumpAndSettle(); // Complete route push animation

      // Stack level 2: [HomeScreen, BatchListScreen]
      expect(find.text('Milk Dispatch Batches'), findsOneWidget);
      expect(find.text('BATCH-20261027-AM-01'), findsOneWidget);
      expect(find.text('BATCH-20261027-AM-02'), findsOneWidget);
      expect(find.text('Navigation Stack: [Home] -> [Batches List]'), findsOneWidget);

      // Tap on the first batch to navigate forward to DetailScreen
      await tester.tap(find.text('BATCH-20261027-AM-01'));
      await tester.pumpAndSettle(); // Complete route push animation

      // Stack level 3: [HomeScreen, BatchListScreen, BatchDetailScreen]
      expect(find.text('Batch Telemetry'), findsOneWidget);
      expect(find.text('1450.0 Litres'), findsOneWidget);
      expect(find.text('Average Fat'), findsOneWidget);
      expect(find.text('4.30%'), findsOneWidget);
      expect(find.text('Done (Back to Batch List)'), findsOneWidget);

      // Backward navigation 1: Tap programmatic 'Done (Back to Batch List)' button (Navigator.pop)
      await tester.ensureVisible(find.text('Done (Back to Batch List)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done (Back to Batch List)'));
      await tester.pumpAndSettle(); // Complete route pop animation

      // Back to Stack level 2: [HomeScreen, BatchListScreen]
      expect(find.text('Milk Dispatch Batches'), findsOneWidget);
      expect(find.text('Batch Telemetry'), findsNothing);

      // Backward navigation 2: Tap AppBar automatic back button
      final backButton = find.byTooltip('Back');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle(); // Complete route pop animation

      // Back to Stack level 1: [HomeScreen]
      expect(find.text('Farm2Factory Home'), findsOneWidget);
      expect(find.text('Milk Dispatch Batches'), findsNothing);
    });

    testWidgets('BatchListScreen Programmatic Return to Home Button pops back to HomeScreen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.ensureVisible(find.text('Browse Milk Batches (Navigation Flow)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Browse Milk Batches (Navigation Flow)'));
      await tester.pumpAndSettle();

      expect(find.text('Milk Dispatch Batches'), findsOneWidget);

      // Tap Return to Home Screen button at bottom of list screen
      await tester.tap(find.text('Return to Home Screen'));
      await tester.pumpAndSettle();

      // Verified returned to HomeScreen
      expect(find.text('Farm2Factory Home'), findsOneWidget);
      expect(find.text('Milk Dispatch Batches'), findsNothing);
    });
  });
}
