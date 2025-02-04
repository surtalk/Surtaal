import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../login_screen.dart';
import 'class_management.dart';
import 'class_attendance.dart';
import 'attendance_report.dart';
import '../../../features/admin_dashboard/screens/student_screen.dart';
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
      drawer: Drawer(
      child: ListView(
        children: [
           DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Admin Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
          ListTile(
            title: Text("Manage Students"),
            leading: Icon(Icons.people),
            onTap: () {
              // Navigate to Students Management screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StudentsScreen()),
              );
            },
          ),
           ListTile(
              leading: Icon(Icons.class_),
              title: Text("Manage Classes"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClassesManagementScreen()),
                );
              },
            ),
             ListTile(
              leading: Icon(Icons.check),
              title: Text("Class Attendance"),
              onTap: () {
                // Close the drawer and navigate to ClassAttendanceScreen.
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClassAttendanceScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text("Attendance Report"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AttendanceReportScreen()),
                );
              },
            ),
        ],
     ),
    ),
    );
  }
}