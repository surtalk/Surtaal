
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/repositories/student_repository.dart';

import '../../../data/models/student_model.dart';

import 'AddUpdateStudentDialog.dart';

class StudentsScreen extends StatefulWidget {
  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}
  

class _StudentsScreenState extends State<StudentsScreen> {
  final StudentRepository _firestoreService = StudentRepository();
  List<String> studentsInClasses = []; // Student IDs in classes
   bool showUnassignedOnly = false; // Checkbox state

 @override
  void initState() {
    super.initState();  
    fetchStudentsInClasses();
  }

  // Show Add/Edit Dialog 
  void _showStudentDialog(BuildContext context,{String? docId, String? name, String? myobId, String? phone,
   DateTime? dob, String? email, DateTime? startDate, String? imageUrl}) {
     showDialog(
      context: context,
      builder: (context) {
        return AddStudentDialog(existingName: name, studentId: docId , myobId:  myobId, phone :phone,
                                dob: dob, email:  email, startDate:  startDate ,imageUrl: imageUrl);
      },
    );   
   }

  // Delete Student Confirmation
  void _deleteStudent(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Student?"),
          content: Text("Are you sure you want to delete this student?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                _firestoreService.deleteStudent(docId);
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }


// section to display list of student 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Students")),
      body: Column(
        children: [
          // Checkbox to filter unassigned students
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: showUnassignedOnly,
                onChanged: (bool? value) {
                  setState(() {
                    showUnassignedOnly = value ?? false;
                  });
                },
              ),
              Text('Show students not in any class'),
            ],
          ),

          // Fetch students from Firestore and display them
          Expanded(
            child: FutureBuilder<List<Student>>(
        future: _fetchStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No students found'));
          }

          var students = snapshot.data!;
          // Filter students based on checkbox state
          var filteredStudents = showUnassignedOnly
              ? students.where((s) => !studentsInClasses.contains(s.docId)).toList()
              : students;
          return ListView.builder(
            itemCount: filteredStudents.length,
            itemBuilder: (context, index) {
              var student = filteredStudents[index];
              DateTime dob = (student.dob).toDate();
              String formattedDob = "${dob.day}-${dob.month}-${dob.year}";
              DateTime startDate = (student.startDate).toDate();
              //String formattedstartDate = "${student.startDate.day}-${student.startDate.month}-${student.startDate.year}";

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                  backgroundImage: NetworkImage(student.imageUrl),  // Using image bytes
                  radius: 30,
                ),
                  title: Text(student.name),
                  subtitle: Text("MYOB ID: ${student.myobId} | Phone: ${student.mobile} | E-mail: ${student.email} | DOB: $formattedDob"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () async {                        
                        _showStudentDialog(context,
                          docId: student.docId,
                          name: student.name,
                          myobId: student.myobId,
                          phone: student.mobile,
                          email: student.email,
                          dob: dob,
                          startDate: startDate,  
                          imageUrl:student.imageUrl,                        
                        );
                      }),
                      IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () {
                        _deleteStudent(student.docId);
                      }),                       
                    ],
                  ),
                ),
                 
              );
            },
          );
        },
      ),
       ),
        ],
      ),   
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showStudentDialog(context)  
      )       
      );   
       
  }
  
Future<List<Student>> _fetchStudents() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var snapshot = await firestore.collection('students').get();
    List<Student> students = [];

    for (var doc in snapshot.docs) {
      var name = doc['name'];
      var imageUrl = doc['imageUrl'];
      var docId = doc.id;
      var myobId = doc['myob_Id'];
      var mobile = doc['mobile'];
      var email = doc['email'];
      var startDate = doc['startDate'];
      var dob = doc['dob'];
      students.add(Student(name: name, imageUrl: imageUrl, docId:docId ,myobId:myobId,mobile:mobile,email:email,dob:dob,startDate:startDate ));
    }
      return students;
    }  

    /// Fetch student IDs assigned to classes
  Future<void> fetchStudentsInClasses() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('classes').get();

    List<String> assignedStudents = [];

    for (var doc in querySnapshot.docs) {
      List studentsList = doc['students'] ?? [];
      assignedStudents.addAll(
          studentsList.map((s) => s['id'].toString()).toList());
    }

    setState(() {
      studentsInClasses = assignedStudents.toSet().toList();
    });
  }
  
}
