import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRepository {
 final CollectionReference studentsCollection =
      FirebaseFirestore.instance.collection('students');

Future<DocumentReference?> addStudent(String name, String myobId, String phone, DateTime dob, String email, DateTime startDate, String imageUrl) async {
  return await studentsCollection.add({
    'name': name,
    'myob_Id': myobId,
    'mobile': phone,
    'dob': Timestamp.fromDate(dob?? DateTime(2000, 1, 1)),
    'email': email,
    'startDate': Timestamp.fromDate(startDate?? DateTime(2000, 1, 1)),    
    'imageUrl': imageUrl ?? '', 
  }).then((docRef) {
    print("Student added with ID: ${docRef.id}");
  }).catchError((error) {
    print("Error adding student: $error");
  });
}
// Update Student
  Future<void> updateStudent(String? docId, String name, String myobId, String phone, DateTime dob, String email, DateTime startDate,String imageUrl) async {
    await studentsCollection.doc(docId).update({
      'name': name,
      'myob_Id': myobId,
      'mobile': phone,
      'dob': Timestamp.fromDate(dob?? DateTime(2000, 1, 1)),
      'email': email,
      'startDate': Timestamp.fromDate(startDate?? DateTime(2000, 1, 1)),
      'imageUrl': imageUrl ?? '', 
    });
  }

  // Delete Student
  Future<void> deleteStudent(String docId) async {
    await studentsCollection.doc(docId).delete();
  }

  // Fetch Students (Stream for Live Updates)
  Stream<QuerySnapshot> getStudents() {
    return studentsCollection.orderBy('myob_Id', descending: true).snapshots();
  }
}
