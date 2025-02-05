import 'package:flutter/material.dart';


/// Animated Background with Gradient Effect
class AnimatedBackground extends StatefulWidget {
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  Gradient _gradient1 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.blueAccent, Colors.purpleAccent],
  );

  Gradient _gradient2 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.orangeAccent, Colors.redAccent],
  );

  Gradient _currentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.blueAccent, Colors.purpleAccent],
  );

  void _toggleGradient() {
    setState(() {
      _currentGradient = _currentGradient == _gradient1 ? _gradient2 : _gradient1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleGradient,
      child: AnimatedContainer(
        duration: Duration(seconds: 2),
        decoration: BoxDecoration(
          gradient: _currentGradient,
        ),
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}