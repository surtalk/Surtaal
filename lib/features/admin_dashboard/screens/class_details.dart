import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/student_model.dart';
import 'add_student_to_class.dart';

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
  TextEditingController searchController = TextEditingController();
  List<Student> allStudents = []; 
  List<Student> filteredStudents = [];

 

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

Future<void> openAddStudentDialog(BuildContext context, String classId) async {
  showDialog(
    context: context,
    builder: (context) => AddStudentDialog(classId: classId),
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
                  onPressed: () async {
                    await  openAddStudentDialog(context, widget.classDocId); // Wait for dialog to close
                    setState(() {}); // 👈 Always refresh after dialog closes
                  },                 
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