import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schedule2/firebase_options.dart';
import 'package:schedule2/pages/home.dart';
import 'package:schedule2/pages/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only if it hasn't been initialized already
  /*if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }*/

  await requestCameraPermission();

  runApp(const MyApp());
}

Future<void> requestCameraPermission() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    await Permission.camera.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Tracker',
      home: HomePage(), // Ensure this is the first screen
    );
  }
}
