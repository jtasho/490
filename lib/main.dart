import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schedule2/firebase_options.dart';
import 'package:schedule2/pages/login.dart';
import 'package:schedule2/pages/map.dart'; // Make sure this file exists
import 'package:schedule2/pages/home.dart';  // Import your home.dart file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await requestCameraPermission();

  runApp(MyApp());
}

Future<void> requestCameraPermission() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    await Permission.camera.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Declared const constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Tracker',
      home: Login(),
    );
  }
}
