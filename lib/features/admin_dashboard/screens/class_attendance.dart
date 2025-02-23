import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  // If an attendance record exists for the selected class and date, its document ID is stored here.
  String? existingAttendanceDocId;

  /// Fetches a list of classes from Firestore.
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

  /// Called when a class is selected.
  void onClassSelected(Map<String, dynamic> selectedClass) {
    setState(() {
      selectedClassId = selectedClass['id'];
      selectedClassName = selectedClass['name'];
      // Reset attendance map
      attendance = {};
      List<dynamic> students = selectedClass['students'] ?? [];
      for (var student in students) {
        attendance[student['id']] = false; // default: absent
      }
    });
    // If a date is already selected, check if attendance exists.
    if (selectedDate != null) {
      _checkExistingAttendance();
    }
  }

  /// Opens a date picker and then checks for an existing attendance record.
  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      // Normalize the date to remove time component (if needed)
      DateTime normalized = DateTime(picked.year, picked.month, picked.day);
      setState(() {
        selectedDate = normalized;
      });
      // If a class is selected, check if attendance exists.
      if (selectedClassId != null) {
        _checkExistingAttendance();
      }
    }
  }

  /// Checks Firestore for an existing attendance record for the selected class and date.
  Future<void> _checkExistingAttendance() async {
    if (selectedClassId == null || selectedDate == null) return;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('classId', isEqualTo: selectedClassId)
        .where('date', isEqualTo: Timestamp.fromDate(selectedDate!))
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Assume only one record exists per class and date.
      var doc = snapshot.docs.first;
      existingAttendanceDocId = doc.id;
      // Pre-populate the attendance map from the existing record.
      List<dynamic> attendanceList = doc['attendance'] ?? [];
      setState(() {
        attendance = {};
        for (var record in attendanceList) {
          // record is expected to have 'studentId' and 'present'
          attendance[record['studentId']] = record['present'];
        }
      });
    } else {
       // No attendance record exists: reset the form.
      existingAttendanceDocId = null;
      // Reinitialize attendance based on the current class's student list.
      DocumentSnapshot classDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(selectedClassId)
          .get();
      Map<String, dynamic> classData =
          classDoc.data() as Map<String, dynamic>? ?? {};
      List<dynamic> students = classData['students'] ?? [];
      setState(() {
        attendance = {};
        for (var student in students) {
          attendance[student['id']] = false; // default: absent
        }
      });
    }
  }

  /// Saves the attendance record.
  Future<void> _saveAttendance() async {
    if (selectedClassId == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select a class and date")));
      return;
    }

    // Build attendance list with student details.
    // Here we fetch the class document to get the student names.
    DocumentSnapshot classDoc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(selectedClassId)
        .get();
    Map<String, dynamic> classData =
        classDoc.data() as Map<String, dynamic>? ?? {};
    List<dynamic> students = classData['students'] ?? [];
    List<Map<String, dynamic>> attendanceData = [];
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

    Map<String, dynamic> attendanceRecord = {
      'classId': selectedClassId,
      'className': selectedClassName,
      'date': selectedDate,
      'attendance': attendanceData,
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (existingAttendanceDocId != null) {
      // Update the existing attendance record.
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(existingAttendanceDocId)
          .update(attendanceRecord);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Attendance updated successfully")));
    } else {
      // Create a new attendance record.
      await FirebaseFirestore.instance
          .collection('attendance')
          .add(attendanceRecord);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Attendance saved successfully")));
    }

    // Optionally, reset selections (or keep them for further updates)
    setState(() {
      // Keep class selection but clear date and attendance map if desired.
      selectedDate = null;
      attendance = {};
      existingAttendanceDocId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Class - Attendance"),
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
                // Class selection dropdown.
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
                // Date selection.
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
                // Attendance checkboxes for each student.
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
                    return FutureBuilder<String>(
                                future: _fetchStudentImage(studentId),
                                builder: (context, snapshot) {
                                  final imageUrl = snapshot.data ?? "";

                                  return GestureDetector(
                                    onLongPress: () => _showStudentImage(context, studentId, studentName),
                                    child: CheckboxListTile(
                                      title: Text(studentName),
                                      secondary: CircleAvatar(
                                        backgroundImage: imageUrl.isNotEmpty
                                            ? NetworkImage(imageUrl)
                                            : AssetImage("assets/images/surtaal_logo.jpg") as ImageProvider,
                                      ),
                                      value: present,
                                      onChanged: (bool? value) {
                                          setState(() {
                                              attendance[studentId] = value ?? false;
                                            });
                                        },
                                    ),
                                  );
                                },
                              );

                      // return CheckboxListTile(
                      //   title: Text(studentName),
                      //   value: present,
                      //   onChanged: (bool? value) {
                      //     setState(() {
                      //       attendance[studentId] = value ?? false;
                      //     });
                      //   },
                      // );




                    },
                  ),
                ],
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveAttendance,
                    child: Text(existingAttendanceDocId != null
                        ? "Update Attendance"
                        : "Save Attendance"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<String> _fetchStudentImage(String studentId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection("students").doc(studentId).get();
      if (doc.exists && doc.data()!.containsKey("imageUrl")) {
        return doc["imageUrl"];
      }
    } catch (e) {
      print("Error fetching image: $e");
    }
    return ""; // Return empty string if no image found
  }

  void _showStudentImage(BuildContext context, String studentId, String studentName) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<String>(
          future: _fetchStudentImage(studentId),
          builder: (context, snapshot) {
            String imageUrl = snapshot.data ?? "";
            return AlertDialog(
              title: Text(studentName),
              content: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Image.asset("assets/images/surtaal_logo.jpg", fit: BoxFit.cover),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
