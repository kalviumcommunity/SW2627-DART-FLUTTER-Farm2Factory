import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
<<<<<<< HEAD
=======
import 'firebase_options.dart';
>>>>>>> origin/main

import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
<<<<<<< HEAD

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

=======
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
>>>>>>> origin/main
  runApp(const Farm2FactoryApp());
}