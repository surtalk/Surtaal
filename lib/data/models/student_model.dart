import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  String name;
  String imageUrl;
  String docId;
  String myobId;
  String mobile;
  String email;
  Timestamp dob;
  Timestamp startDate; 
  bool isAddedToClass; // This will be updated dynamically
  Student({required this.name, required this.imageUrl,required this.docId,required this.myobId,required this.mobile,required this.email,required this.dob, required this.startDate,this.isAddedToClass = false,});


  // Convert Firestore document to Student object
  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Student(
      docId: doc.id,
      name: data['name'] ?? '',
      myobId: data['myob_Id'] ?? '',
      email: data['email'] ?? '',
      mobile: data['mobile'] ?? '',
      dob: data['dob'] ?? '',
      startDate: data['startDate'] ?? '',
      imageUrl: data['imageUrl'],
      isAddedToClass: false, // Will be updated dynamically
    );
  }

}