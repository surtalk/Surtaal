import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'reset_password_screen.dart';
import '../features/admin_dashboard/screens/dashboard_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
  
}

class _LoginScreenState extends State<LoginScreen> {
  double _logoOpacity = 0.0; // Initial opacity for fade-in effect
  @override
  void initState() {
    super.initState();
    
    // Trigger the fade-in animation after a small delay
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _logoOpacity = 1.0;
      });
    });
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: '685933490724-o6mvp6vfc1kbg52g1r47caqinjmc3bur.apps.googleusercontent.com',);

   Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
  // Login function
   Future<User?> signInWithGoogle() async {
  try {
    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    // Create a new credential for Firebase authentication
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase using the Google credentials
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    print("got backfrom google");
    User? user = userCredential.user;

    if (user != null) {
      // Redirect to the Home screen after successful login
     Fluttertoast.showToast(msg: "Login Successful!");
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

          if (userDoc.exists) {
            String role = userDoc['role']; // Get the user's role from Firestore

            // Redirect based on the role
            if (role == 'admin') {
              // Navigate to admin home screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
            } else {
              // Navigate to user home screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            }
            }
    }
    return userCredential.user;
  } catch (e) {
    print("Google Sign-In Error: $e");
    return null;
  }
}
 void signIn() async {
  if (_formKey.currentState!.validate()) {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = userCredential.user;

      if (user != null) {
        if (user.emailVerified) {
          Fluttertoast.showToast(msg: "Login Successful!");
          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

          if (userDoc.exists) {
            String role = userDoc['role']; // Get the user's role from Firestore

            // Redirect based on the role
            if (role == 'admin') {
              // Navigate to admin home screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
            } else {
              // Navigate to user home screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            }
          }
         
        } else {
          Fluttertoast.showToast(msg: "Please verify your email before logging in.");
          await user.sendEmailVerification(); // Resend verification email
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Login"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo with Fade-in Effect
            AnimatedOpacity(
              opacity: _logoOpacity, // Controls the animation
              duration: Duration(seconds: 2), // Fade-in duration
              curve: Curves.easeIn, // Smooth ease-in effect
              child: Image.asset(
                'assets/images/surtaal_logo.jpg', // Ensure your logo is in the assets folder
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: 20), // Space between logo and form fields
         Center(     
        child: Form(
          key: _formKey,
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value!.isEmpty || !value.contains("@")) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
                validator: (value) {
                  if (value!.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: signIn,
                child: Text("Login"),
              ),
                
              // Google Sign-In Button
              ElevatedButton(
                onPressed: () async {
                  User? user = await signInWithGoogle();
                  if (user != null) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));                   
                  }
                },
                 child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/google_logo.png',  // Path to your Google logo
                          height: 50,  // Adjust the size of the logo
                        ),                        
                      ],
                    ),              
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupScreen()));
                },
                child: Text("Don't have an account? Sign Up"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                  );
                },
                child: Text("Forgot Password?"),
              ),
            ],
          ),
        ),
         )
      ]
      ),    
    ),
    );  
  }
}
