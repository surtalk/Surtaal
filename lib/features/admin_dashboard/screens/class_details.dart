import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

///
/// ClassDetailScreen: Displays the details of a specific class and allows the admin to manage the student list.
/// Uses Firestore's arrayUnion and arrayRemove operations to add or remove students.
///
class ClassDetailScreen extends StatefulWidget {
  final String classDocId;
  final String className;

  ClassDetailScreen({required this.classDocId, required this.className});

  @override
  _ClassDetailScreenState createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  final TextEditingController _studentController = TextEditingController();

// Adds a student to the class document.
  // Here, we store a map with the student's id and name.
  Future<void> _addStudent(Map<String, dynamic> studentData) async {
    await FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classDocId)
        .update({
      'students': FieldValue.arrayUnion([studentData]),
    });
  }

 // Remove a student from the class document.
  Future<void> _removeStudent(Map<String, dynamic> studentData) async {
    await FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classDocId)
        .update({
      'students': FieldValue.arrayRemove([studentData]),
    });
  }
  // Show a dialog that displays a list of existing students from Firestore.
  // The admin can tap one to add them to the class.
  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select a Student"),
          content: Container(
            // Set a fixed height for the list
            height: 300,
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('students')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final studentDocs = snapshot.data!.docs;
                if (studentDocs.isEmpty) {
                  return Center(child: Text("No students found."));
                }
                return ListView.builder(
                  itemCount: studentDocs.length,
                  itemBuilder: (context, index) {
                    var doc = studentDocs[index];
                    // Create a student data map.
                    Map<String, dynamic> studentData = {
                      'id': doc.id,
                      'name': doc['name'],
                    };
                    return ListTile(
                      title: Text(doc['name']),
                      onTap: () async {
                        // Add the selected student to the class.
                        await _addStudent(studentData);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Class: ${widget.className}"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .doc(widget.classDocId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: CircularProgressIndicator());
          }
          final classData = snapshot.data!.data() as Map<String, dynamic>;
          // The 'students' field is expected to be a List of Maps.
          final List<dynamic> students = classData['students'] ?? [];
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    // Each student is stored as a Map with 'id' and 'name'
                    Map<String, dynamic> studentData = Map<String, dynamic>.from(students[index]);
                    return ListTile(
                      title: Text(studentData['name']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _removeStudent(studentData),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _showAddStudentDialog,
                  child: Text("Add Student from List"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}