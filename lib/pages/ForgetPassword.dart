import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Enter your email and we will send\nyou a password reset link',
            style: TextStyle(fontSize: 14), // Adjust the font size as needed
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              resetPassword(context);
            },
            child: Text('Reset Password Now'),
          ),
        ],
      ),
    );
  }

  Future<void> resetPassword(BuildContext context) async {
    try {
      String email = emailController.text.trim();

  
      // Email is registered, send password reset link
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Password reset link has been sent! Check your email'),
          );
        },
      );
    } catch (e) {
      print('Error: $e');

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('An error occurred. Please try again later.'),
          );
        },
      );
    }
  }
}