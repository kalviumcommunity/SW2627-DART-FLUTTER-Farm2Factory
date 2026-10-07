import 'package:flutter_test/flutter_test.dart';

// If your package name is not flutter_application_1, change it here.
import 'package:flutter_application_1/app.dart';

void main() {
  testWidgets('App starts on splash, then shows login', (tester) async {
    await tester.pumpWidget(const Farm2FactoryApp());
    expect(find.text('Farm2Factory'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3)); // wait out the splash timer
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
