import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'class_details.dart';

///
/// ClassesManagementScreen: Allows the admin to create, view, and delete classes.
/// Each class document in Firestore includes a 'name' and an array field 'students'.
///
///import 'package:flutter/material.dart';
///
class ClassesManagementScreen extends StatefulWidget {
  @override
  _ClassesManagementScreenState createState() => _ClassesManagementScreenState();
}

class _ClassesManagementScreenState extends State<ClassesManagementScreen> {
  final TextEditingController _classNameController = TextEditingController();

  // Add a new class document to Firestore.
  Future<void> _addClass(String className) async {
    await FirebaseFirestore.instance.collection('classes').add({
      'name': className,
      'students': [],
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Show a dialog to input a new class name.
  void _showAddClassDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Class"),
          content: TextField(
            controller: _classNameController,
            decoration: InputDecoration(hintText: "Enter class name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _classNameController.clear();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_classNameController.text.isNotEmpty) {
                  await _addClass(_classNameController.text);
                }
                Navigator.of(context).pop();
                _classNameController.clear();
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Delete a class document from Firestore.
  Future<void> _deleteClass(String classId) async {
    await FirebaseFirestore.instance.collection('classes').doc(classId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Classes"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final classDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: classDocs.length,
            itemBuilder: (context, index) {
              var doc = classDocs[index];
              return ListTile(
                title: Text(doc['name']),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteClass(doc.id),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDetailScreen(
                        classDocId: doc.id,
                        className: doc['name'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClassDialog,
        child: Icon(Icons.add),
        tooltip: "Add New Class",
      ),
    );
  }
}