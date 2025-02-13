import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/student_model.dart';

class AddStudentDialog extends StatefulWidget {
final String classId;
AddStudentDialog({required this.classId});
  
  @override
  _AddStudentDialogState createState() => _AddStudentDialogState();
}
class _AddStudentDialogState extends State<AddStudentDialog> {

TextEditingController searchController = TextEditingController();
  List<Student> allStudents = []; 
  List<Student> filteredStudents = [];
  List<String> studentsInClass = [];  // List to store student IDs already in class


  @override
  void initState() {
    super.initState();
    _fetchStudents(); 
    _fetchClassData();// Fetch all students when the dialog is created
  }
  

 // Fetch students and check if they are already in the class
   // Fetch all students and set initial state
  _fetchStudents() async {
    List<Student> students = await fetchAllStudents();
    setState(() {
      allStudents = students;
      filteredStudents = students; // Initially, show all students
    });
  }

  // Fetch all students from Firestore
  Future<List<Student>> fetchAllStudents() async {
    List<Student> students = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('students').get();

      for (var doc in snapshot.docs) {
        students.add(Student.fromFirestore(doc));
      }
    } catch (e) {
      print("Error fetching students: $e");
    }
    filteredStudents = students;
    return students;
  }

 _fetchClassData() async {
    try {
      // Fetch the class document
      DocumentSnapshot classSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .get();

      // If the class exists and the 'students' field is not empty
      if (classSnapshot.exists) {
        List<dynamic> students = classSnapshot['students'] ?? [];
        // Store student IDs already in the class
        studentsInClass = students.map((student) => student['id'] as String).toList();
      }
    } catch (e) {
      print("Error fetching class data: $e");
    }
  }

  // Adds a student to the class document.
  // Here, we store a map with the student's id and name.
  Future<void> addStudent(Student student) async {
     DocumentReference classRef = FirebaseFirestore.instance.collection('classes').doc(widget.classId);
           
   await classRef.update({
        'students': FieldValue.arrayUnion([
          {
            'id': student.docId,
            'name': student.name,
          },
        ]),
      });
  }

 // Filter students based on search input
  void filterStudents(String query) {
    List<Student> filtered = allStudents.where((student) {
      return student.name.toLowerCase().contains(query.toLowerCase()) ||
             student.email.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredStudents = filtered; // Update the filtered list
    });
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: 
         Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Students',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (text) {
                    // Handle search filter if needed
                    filterStudents(text);
                  },
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child:filteredStudents.isEmpty
                  ? Center(child: Text('No students found'))
                  : ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {                      
                      Student student = filteredStudents[index];
                      bool isAlreadyInClass = studentsInClass.contains(student.docId);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: student.imageUrl != null
                              ? NetworkImage(student.imageUrl!)
                              : AssetImage('assets/default_avatar.png') as ImageProvider,
                        ),
                        title: Text(student.name),
                        subtitle: Text(student.email),
                        trailing:isAlreadyInClass
                              ? Icon(Icons.check, color: Colors.green)  // Flag icon if student is already in the class
                              :  IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            // Add student to class
                            addStudent(student);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            )                  
      ),
    );
  }  
}
