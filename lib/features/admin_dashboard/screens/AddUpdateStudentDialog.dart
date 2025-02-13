
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/repositories/student_repository.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class AddStudentDialog extends StatefulWidget {

  String? existingName;
  String? studentId;
String? myobId;
String? phone;
DateTime? dob;
String? email;
DateTime? startDate;

   AddStudentDialog({this.existingName, this.studentId, this.myobId, this.phone, this.dob, this.email, this.startDate});

  @override
  _AddupdatestudentdialogState createState() => _AddupdatestudentdialogState();
}
class _AddupdatestudentdialogState extends State<AddStudentDialog> {
   final StudentRepository _firestoreService = StudentRepository();
// Controllers
   late TextEditingController _nameController;
   late TextEditingController _myobIdController;
   late TextEditingController _phoneController;
   late TextEditingController _emailController;
  DateTime? _selectedDob;
  DateTime? _startDate;
  String? docId;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingName ?? "");
    _myobIdController = TextEditingController(text: widget.myobId ?? "");
    _phoneController = TextEditingController(text: widget.phone ?? "");
    _emailController = TextEditingController(text: widget.email ?? "");
    _selectedDob = widget.dob;
    _startDate = widget.startDate;
    docId = widget.studentId;
  }

    TextEditingController dobController = TextEditingController();
    void _selectDate(BuildContext context) async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );

    setState(() {
        _selectedDob = picked;
        dobController.text = "${picked!.day}/${picked!.month}/${picked!.year}"; // Format date
      });
      }
    TextEditingController startDateController = TextEditingController();
    
    void _selectStartDateDate(BuildContext context) async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );   

      setState(() {
          _startDate = picked;
          startDateController.text = "${picked!.day}/${picked!.month}/${picked!.year}"; // Format date
        });
        }
  Uint8List? _imageBytes = null;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  // Function to Pick an Image

  // Function to Pick Image (Camera or Gallery)
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Take Photo"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickImage(source: ImageSource.camera);    
                 print("Image selected: ${pickedFile!.path}");  // Debugging             
                if (pickedFile != null) {  
                    final bytes = await pickedFile.readAsBytes();
                    Future.delayed(Duration(milliseconds: 1500), () { 
                     setState(() {
                     print("set stage after a delay:");
                    _image = File(pickedFile!.path);
                    _imageBytes = bytes;
                  });
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                print("Image selected: ${pickedFile!.path}"); 
                if (pickedFile != null) {                               
                  final bytes = await pickedFile.readAsBytes();
                     Future.delayed(Duration(milliseconds: 1500), () {    
                     print("set stage after a delay:");
                      setState(() {                    
                      print("Image selected set stage path ${pickedFile!.path}"); 
                      _image = File(pickedFile!.path);                   
                      _imageBytes = bytes;
                  });
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }


 @override
  Widget build(BuildContext context) {
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
                GestureDetector(
                  onTap: () {
                    print("Image picker tapped!");  // Prints when the widget is tapped
                    _pickImage();  // Calls the function
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imageBytes != null
                        ? MemoryImage(_imageBytes!) // Display image from bytes
                        : null,
                    child: (_imageBytes == null)
                        ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                        : null,
                  ),
                ),                   
            SizedBox(height: 20),            
            SizedBox(height: 10),
            SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(             
              onPressed: () async { 
                String? imageUrl;
               print("on save the image url: ${imageUrl}"); 
                if (_nameController.text.isNotEmpty && _myobIdController.text.isNotEmpty && _phoneController.text.isNotEmpty && _selectedDob != null) {
                  if (_imageBytes != null) {
                      final storageRef = FirebaseStorage.instance.ref().child('students').child(DateTime.now().toString());
                      await storageRef.putData(_imageBytes!);
                      imageUrl = await storageRef.getDownloadURL();                      
                    }
                  if (docId == null) {
                    _firestoreService.addStudent(
                      _nameController.text, _myobIdController.text, _phoneController.text, _selectedDob!, _emailController.text, _startDate! , imageUrl!
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student added successfully")));
                  } else {
                    _firestoreService.updateStudent(
                      docId, _nameController.text, _myobIdController.text, _phoneController.text, _selectedDob!, _emailController.text, _startDate!, imageUrl!
                    );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student updated successfully")));
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(docId == null ? "Add" : "Update"),
            ),
          ],
        );
      }
}