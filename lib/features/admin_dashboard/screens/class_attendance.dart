
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
///
/// ClassAttendanceScreen: Admin chooses a class, selects a date,
/// and marks attendance for all students in the class.
///
class ClassAttendanceScreen extends StatefulWidget {
  @override
  _ClassAttendanceScreenState createState() => _ClassAttendanceScreenState();
}

class _ClassAttendanceScreenState extends State<ClassAttendanceScreen> {
  String? selectedClassId;
  String? selectedClassName;
  DateTime? selectedDate;
  // Map to store attendance status for each student (studentId -> present)
  Map<String, bool> attendance = {};

  Future<List<Map<String, dynamic>>> fetchClasses() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('classes')
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
        'students': doc['students'] ?? [],
      };
    }).toList();
  }

  void onClassSelected(Map<String, dynamic> selectedClass) {
    setState(() {
      selectedClassId = selectedClass['id'];
      selectedClassName = selectedClass['name'];
      attendance = {};
      List<dynamic> students = selectedClass['students'] ?? [];
      for (var student in students) {
        attendance[student['id']] = false;
      }
    });
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _saveAttendance() async {
    if (selectedClassId == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select a class and date")));
      return;
    }

    // Build attendance list including student name.
    // (Assumes that the selected class's student list contains student names.)
    List<Map<String, dynamic>> attendanceData = [];
    List<Map<String, dynamic>> studentList = [];
    // We fetch the class document to get student details.
    DocumentSnapshot classDoc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(selectedClassId)
        .get();
    Map<String, dynamic> classData =
        classDoc.data() as Map<String, dynamic>? ?? {};
    List<dynamic> students = classData['students'] ?? [];
    for (var student in students) {
      String id = student['id'];
      String name = student['name'];
      bool present = attendance[id] ?? false;
      attendanceData.add({
        'studentId': id,
        'studentName': name,
        'present': present,
      });
    }

    await FirebaseFirestore.instance.collection('attendance').add({
      'classId': selectedClassId,
      'className': selectedClassName,
      'date': selectedDate,
      'attendance': attendanceData,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Attendance saved successfully")));

    setState(() {
      selectedClassId = null;
      selectedClassName = null;
      selectedDate = null;
      attendance = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Class Attendance"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchClasses(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          List<Map<String, dynamic>> classes = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Map<String, dynamic> selected =
                          classes.firstWhere((cls) => cls['id'] == value);
                      onClassSelected(selected);
                    }
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDate == null
                            ? "No date selected"
                            : "Selected Date: ${selectedDate!.toLocal().toString().split(' ')[0]}",
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _selectDate,
                      child: Text("Select Date"),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (attendance.isNotEmpty) ...[
                  Text(
                    "Mark Attendance:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: attendance.length,
                    itemBuilder: (context, index) {
                      String studentId = attendance.keys.elementAt(index);
                      bool present = attendance[studentId]!;
                      // Find the student name from the selected class's list.
                      var selectedClass = classes.firstWhere(
                          (cls) => cls['id'] == selectedClassId);
                      List<dynamic> students = selectedClass['students'] ?? [];
                      String studentName = "Unknown";
                      for (var stu in students) {
                        if (stu['id'] == studentId) {
                          studentName = stu['name'];
                          break;
                        }
                      }
                      return CheckboxListTile(
                        title: Text(studentName),
                        value: present,
                        onChanged: (bool? value) {
                          setState(() {
                            attendance[studentId] = value ?? false;
                          });
                        },
                      );
                    },
                  ),
                ],
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveAttendance,
                    child: Text("Save Attendance"),
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