import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';

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
      home: LoginScreen(), // Start with the Login Screen
    );
     }
   }