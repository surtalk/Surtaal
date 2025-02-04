import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_report_detail.dart';

///
/// AttendanceRecordsList: Lists attendance records for a given class.
///
class AttendanceRecordsList extends StatelessWidget {
  final String classId;

  AttendanceRecordsList({required this.classId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance')
          .where('classId', isEqualTo: classId)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text("Error: ${snapshot.error}"));
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty)
          return Center(child: Text("No attendance records found."));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var doc = docs[index];
            DateTime date = (doc['date'] as Timestamp).toDate();
            // A simple summary can show date and count of present vs. total.
            List<dynamic> attendanceList = doc['attendance'] ?? [];
            int total = attendanceList.length;
            int presentCount = attendanceList
                .where((record) => record['present'] == true)
                .length;
            return ListTile(
              title: Text(
                  "${date.toLocal().toString().split(' ')[0]} - Present: $presentCount/$total"),
              subtitle: Text(doc['className'] ?? "Unknown Class"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AttendanceReportDetailScreen(attendanceDoc: doc),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}