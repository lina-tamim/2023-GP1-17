//Full code, m s
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rive/rive.dart';
import 'dart:ui';
import 'package:techxcel11/pages/Login.dart';
class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            left: 100,
            child: Image.asset('assets/Backgrounds/Spline.png'),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          const RiveAnimation.asset('assets/RiveAssets/shapes.riv'),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            top: MediaQuery.of(context).size.height * 0.1,
            bottom: MediaQuery.of(context).size.height * 0.1,
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Login(), // Replace Login with your actual Login screen
                                ),
                              );
                            },
                            child: Icon(
                              Icons.arrow_back,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 30),
                          Text(
                            'No Worries!',
                            style:
                                TextStyle(fontSize: 24, fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 7,
                      ),
                      child: Text(
                        'Enter your email and we will send\nyou a password reset link',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      width: 300, // Adjust the width as needed
                      child: Divider(
                        color: const Color.fromARGB(255, 211, 211, 211),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 15, right: 15),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    SizedBox(
                      width: 250,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          resetPassword(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 198, 180, 247),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 10,
                          shadowColor:
                              Color.fromARGB(255, 0, 0, 0).withOpacity(1),
                        ),
                        child: Text(
                          'Reset Password Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> resetPassword(BuildContext context) async {
  String email = emailController.text.trim();
  if (await doesEmailExists(email) == false) {
   showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: const Text('This email does not exist! Please enter a valid one'),
        actions: [
          TextButton(
            onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },
            child: const Text('Ok'),
          ),
        ],
      );
    },
  );
  } else {
    try {
      // Email is registered, send password reset link
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: const Text('Password reset link has been sent! Check your email'),
        actions: [
          TextButton(
            onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },
            child: const Text('Ok'),
          ),
        ],
      );
    },
  );
    } catch (e) {
     print('Error: $e');
     showDialog(
     context: context,
     builder: (BuildContext context) {
      return AlertDialog(
        content: const Text('An error occured. Please try again later.'),
        actions: [
          TextButton(
            onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },
            child: const Text('Ok'),
          ),
        ],
      );
    },
  );
    }
  }
}
Future<bool> doesEmailExists(String email) async {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  QuerySnapshot querySnapshot = await usersCollection
      .where('email', isEqualTo: email.toLowerCase())
      .get();
  if (querySnapshot.docs.isNotEmpty) {
    return true; // Email already exists
  } else {
    return false; // Email does not exist
  }
}
}
