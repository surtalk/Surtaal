import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/repositories/student_repository.dart';

class StudentsScreen extends StatefulWidget {
  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final StudentRepository _firestoreService = StudentRepository();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _myobIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
  DateTime? _selectedDob;
    DateTime? _startDate;

  // Show Add/Edit Dialog
  void _showStudentDialog({String? docId, String? name, String? myobId, String? phone, DateTime? dob, String? email, DateTime? startDate}) {
    _nameController.text = name ?? "";
    _myobIdController.text = myobId ?? "";
    _phoneController.text = phone ?? "";
    _emailController.text = email ?? "";
    
    _selectedDob = dob;
    _startDate = startDate;

    TextEditingController dobController = TextEditingController();
    void _selectDate(BuildContext context) async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        dobController.text = "${picked.day}/${picked.month}/${picked.year}"; // Format date
      });
    }
    }
    TextEditingController startDateController = TextEditingController();
    void _selectStartDateDate(BuildContext context) async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        startDateController.text = "${picked.day}/${picked.month}/${picked.year}"; // Format date
      });
    }
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? "Add Student" : "Edit Student"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                TextField(controller: _nameController, decoration: InputDecoration(labelText: "Name")),
                TextField(controller: _myobIdController, decoration: InputDecoration(labelText: "MYOB ID")),
                TextField(controller: _phoneController, decoration: InputDecoration(labelText: "Mobile")),
                TextFormField(controller: _emailController, 
                         keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(labelText: "Email"),
                          ),
                TextField(
                controller: dobController,
                readOnly: true, // Prevent manual input
                decoration: InputDecoration(
                  labelText: "Date of Birth",
                  hintText: "Select your DOB",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                ),
                SizedBox(height: 20),                
                TextField(
                controller: startDateController,
                readOnly: true, // Prevent manual input
                decoration: InputDecoration(
                  labelText: "Start Date",
                  hintText: "First Class",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectStartDateDate(context),
                  ),
                ),
                ),
                SizedBox(height: 20),               
            
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty && _myobIdController.text.isNotEmpty && _phoneController.text.isNotEmpty && _selectedDob != null) {
                  if (docId == null) {
                    _firestoreService.addStudent(
                      _nameController.text, _myobIdController.text, _phoneController.text, _selectedDob!, _emailController.text, _startDate!
                    );
                  } else {
                    _firestoreService.updateStudent(
                      docId, _nameController.text, _myobIdController.text, _phoneController.text, _selectedDob!, _emailController.text, _startDate!
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(docId == null ? "Add" : "Update"),
            ),
          ],
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Students")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("No students found"));

          var students = snapshot.data!.docs;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index];
              DateTime dob = (student['dob'] as Timestamp).toDate();
              String formattedDob = "${dob.day}-${dob.month}-${dob.year}";

              DateTime startDate = (student['startDate'] as Timestamp).toDate();
              String formattedstartDate = "${dob.day}-${dob.month}-${dob.year}";

              return Card(
                child: ListTile(
                  title: Text(student['name']),
                  subtitle: Text("MYOB ID: ${student['myob_Id']} | Phone: ${student['mobile']} | DOB: $formattedDob | E-mail: ${student['email']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () {
                        _showStudentDialog(
                          docId: student.id,
                          name: student['name'],
                          myobId: student['myob_Id'],
                          phone: student['mobile'],
                          email: student['email'],
                          dob: dob,
                          startDate: startDate,
                        );
                      }),
                      IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () {
                        _deleteStudent(student.id);
                      }),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showStudentDialog(),
      ),
    );
  }
}
