import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/student_repository.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentDialog extends StatefulWidget {

  String? existingName;
  String? studentId;
  String? myobId;
  String? phone;
  DateTime? dob;
  String? email;
  DateTime? startDate;
  String? imageUrl;
  String? selectedClassId;

   AddStudentDialog({this.existingName, this.studentId, this.myobId, this.phone, this.dob, this.email, this.startDate, this.selectedClassId, this.imageUrl});

  @override
  _AddupdatestudentdialogState createState() => _AddupdatestudentdialogState();
}
class _AddupdatestudentdialogState extends State<AddStudentDialog> {
   bool isSaving = false; // Track saving state
    final _formKey = GlobalKey<FormState>(); // Form key for validation
   final StudentRepository _firestoreService = StudentRepository();
// Controllers
   late TextEditingController _nameController;
   late TextEditingController _myobIdController;
   late TextEditingController _phoneController;
   late TextEditingController _emailController;
  DateTime? _selectedDob;
  DateTime? _startDate;
  String? docId;
  String? imageUrl;
  String? selectedClassId;
  
  TextEditingController dobController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  List<Map<String, dynamic>> classList = []; // Stores fetched classes
  
  @override
  void initState() {
    super.initState();
    fetchClasses();
    _nameController = TextEditingController(text: widget.existingName ?? "");
    _myobIdController = TextEditingController(text: widget.myobId ?? "");
    _phoneController = TextEditingController(text: widget.phone ?? "");
    _emailController = TextEditingController(text: widget.email ?? "");
    _selectedDob = widget.dob;    
    _startDate = widget.startDate;
    docId = widget.studentId;
    selectedClassId = widget.selectedClassId;
    imageUrl=widget.imageUrl;
    if(_selectedDob !=null){
        dobController.text="${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}";
    }
    if(_startDate !=null){
        startDateController.text="${_startDate!.day}/${_startDate!.month}/${_startDate!.year}";
    }
      }    

    void _selectDate(BuildContext context) async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDob ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );

    setState(() {
        _selectedDob = picked;
        dobController.text = "${picked!.day}/${picked!.month}/${picked!.year}"; // Format date
      });
      }
    
     /// Fetch available classes from Firestore
      Future<void> fetchClasses() async {
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('classes').get();            

        List<Map<String, dynamic>> fetchedClasses = querySnapshot.docs
            .map((doc) => {'id': doc.id, 'name': doc['name']})
            .toList();

        setState(() {
          classList = fetchedClasses;
        });
      }
    
    void _selectStartDateDate(BuildContext context) async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _startDate ??DateTime.now(),
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
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Name"),
                  validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },),
                TextFormField(controller: _myobIdController, decoration: InputDecoration(labelText: "MYOB ID")),
                TextFormField(controller: _phoneController, decoration: InputDecoration(labelText: "Mobile")),
                TextFormField(controller: _emailController, 
                         keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(labelText: "Email"),
                          ),
                TextFormField(
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
                validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Date of Birth is required";
                        }
                        return null;
                      },
                ),
                SizedBox(height: 20),                
                TextFormField(
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
                validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Start Date is required";
                        }
                        return null;
                      },
                ),
                SizedBox(height: 20),
                 // Class Dropdown
                  if (widget.studentId == null) 
          DropdownButtonFormField<String>(
            value: selectedClassId,
            items: classList
                .map((cls) => DropdownMenuItem<String>(
                      value: cls['id'],
                      child: Text(cls['name']),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedClassId = value;
              });
            },
            decoration: InputDecoration(labelText: 'Select Class'),
          ),
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
                        : (imageUrl != null
                          ? NetworkImage(imageUrl!)
                          : null),                    
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
             isSaving
                ? CircularProgressIndicator() // Show loading when saving
                : ElevatedButton(
                    onPressed: saveStudentData,
                    child: Text(docId == null ? "Add" : "Update"),
                  ),           
          ],
        );
      }

      Future<void> saveStudentData() async {
         if (!_formKey.currentState!.validate()) {
              return; // Stop if validation fails
           }
          setState(() {
            isSaving = true; // Show loading
          });                
        if (_nameController.text.isNotEmpty) {
          if (_imageBytes != null) {
              final storageRef = FirebaseStorage.instance.ref().child('students').child(DateTime.now().toString());
              await storageRef.putData(_imageBytes!);
              imageUrl = await storageRef.getDownloadURL();   
              
                print("came to update and got image ur ${imageUrl}");               
            }
            print("didnot saved new image  ${imageUrl}");     
          if (docId == null) {
             DocumentReference? studentRef = await _firestoreService.addStudent(
              _nameController.text,
              _myobIdController.text.trim().isNotEmpty?_myobIdController.text.trim():"TBC",
              _phoneController.text.trim().isNotEmpty?_phoneController.text.trim():"TBC",
              _selectedDob!, // default value is getting set before save
              _emailController.text.trim().isNotEmpty?_emailController.text.trim():"TBC",
              _startDate!,
               imageUrl!
            );
                await FirebaseFirestore.instance.collection('classes').doc(selectedClassId).update({
            'students': FieldValue.arrayUnion([
              {'id': studentRef?.id, 'name': _nameController.text}
            ])
          });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student added successfully")));
          } else {
            _firestoreService.updateStudent(
              docId, _nameController.text, _myobIdController.text, _phoneController.text, _selectedDob!, _emailController.text, _startDate!, imageUrl!
            );
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student updated successfully")));
          }                   
          Navigator.pop(context, true); 
        }
        setState(() {
            isSaving = false; // Hide loading
          });
      }
}