import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_record_list.dart';

class AttendanceReportScreen extends StatefulWidget {
  @override
  _AttendanceReportScreenState createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  String? selectedClassId;
  String? selectedClassName;

  Future<List<Map<String, dynamic>>> fetchClasses() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('classes')
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Report"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchClasses(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          List<Map<String, dynamic>> classes = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Select Class"),
                  value: selectedClassId,
                  items: classes.map((cls) {
                    return DropdownMenuItem<String>(
                      value: cls['id'],
                      child: Text(cls['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedClassId = value;
                        selectedClassName =
                            classes.firstWhere((cls) => cls['id'] == value)['name'];
                      });
                    }
                  },
                ),
                SizedBox(height: 16),
                Expanded(
                  child: selectedClassId == null
                      ? Center(child: Text("Please select a class"))
                      : AttendanceRecordsList(
                          classId: selectedClassId!,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
