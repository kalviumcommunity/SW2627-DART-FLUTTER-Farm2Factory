import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/services/database_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final seeder = DatabaseSeeder();
  final results = await seeder.seedAll();

  // Print results
  debugPrint('Database Seeding Completed Successfully:');
  results.forEach((collection, count) {
    debugPrint(' - $collection: $count documents seeded');
  });
}
