import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../login_screen.dart';
class DashboardScreen extends StatelessWidget {
  final _authRepository = AuthRepository();

  Future<void> _logout(BuildContext context) async {
    await _authRepository.logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to the Admin Dashboard!'),
      ),
    );
  }
}