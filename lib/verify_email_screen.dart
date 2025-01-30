import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VerifyEmailScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void sendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      Fluttertoast.showToast(msg: "Verification email sent again!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Email")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Please check your email to verify your account."),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendVerificationEmail,
              child: Text("Resend Verification Email"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              child: Text("Back to Login"),
            ),
          ],
        ),
      ),
    );
  }
}
