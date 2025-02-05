import 'package:flutter/material.dart';
import '../../../login_screen.dart';
import 'package:lottie/lottie.dart';
import 'animated_background.dart';

/// Animated Launch Screen
class AnimatedLaunchScreen extends StatefulWidget {
  @override
  _AnimatedLaunchScreenState createState() => _AnimatedLaunchScreenState();
}

class _AnimatedLaunchScreenState extends State<AnimatedLaunchScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 3 seconds and then navigate to the Login Screen
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBackground(),
          // Lottie animation centered on the screen
          Align(
            alignment: Alignment.center,
            child: Lottie.asset(
              'assets/launch_animation.json',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
          // App name or tagline
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Welcome to Surtaal Cultural Association",
                style: TextStyle( 
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black45,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}