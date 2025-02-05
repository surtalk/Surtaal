import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '../features/animation/animated_launch.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    );
  print('Firebase initialized!'); 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
     @override
     Widget build(BuildContext context) {
      return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AnimatedLaunchScreen(), // Start with the Login Screen r
    );
     }
   }