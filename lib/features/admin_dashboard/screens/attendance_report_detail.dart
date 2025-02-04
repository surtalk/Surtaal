import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

///
/// AttendanceReportDetailScreen: Shows details for a selected attendance record,
/// including a list of students with their present/absent status.
///
class AttendanceReportDetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot attendanceDoc;

  AttendanceReportDetailScreen({required this.attendanceDoc});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data =
        attendanceDoc.data() as Map<String, dynamic>? ?? {};
    DateTime date = (data['date'] as Timestamp).toDate();
    List<dynamic> attendanceList = data['attendance'] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Class: ${data['className'] ?? 'Unknown'}",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Date: ${date.toLocal().toString().split(' ')[0]}",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: attendanceList.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> record =
                      Map<String, dynamic>.from(attendanceList[index]);
                  String studentName = record['studentName'] ?? "Unknown";
                  bool present = record['present'] ?? false;
                  return ListTile(
                    title: Text(studentName),
                    trailing: Icon(
                      present ? Icons.check_circle : Icons.cancel,
                      color: present ? Colors.green : Colors.red,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}