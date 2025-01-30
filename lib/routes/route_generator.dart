import 'package:flutter/material.dart';
import '../features/auth/screens/admin_login_screen.dart';
import '../features/admin_dashboard/screens/dashboard_screen.dart';
import '/routes/app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.adminLogin:
        return MaterialPageRoute(builder: (_) => AdminLoginScreen());
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}