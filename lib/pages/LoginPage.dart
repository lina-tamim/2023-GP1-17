import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:techxcel11/pages/UserPages/SignUpPage.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/pages/UserPages/HomePage.dart';
import 'package:techxcel11/pages/StartPage.dart';
import 'package:techxcel11/pages/ForgetPasswordPage.dart';
import 'package:techxcel11/pages/AdminPages/AdminHomePage.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _email = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void logUserIn() async {
    final String email = _email.text.toLowerCase();
    final String password = _password.text.trim();

    setState(() {
      _isLoading = true;
    });

    if (email.isEmpty && password.isEmpty) {
      toastMessage('Please enter an email and password');
      return;
    }
    if (email.isEmpty) {
      toastMessage('Please enter an email');
      return;
    }

    if (password.isEmpty) {
      toastMessage('Please enter a password');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (!userCredential.user!.emailVerified) {
        toastMessage(
            "Verify your email before logging in.\nIf not found, please check your junk folder.");
        return;
      }

      final uid = userCredential.user!.uid;

      // Check RegularUser collection
      DocumentSnapshot<Map<String, dynamic>> regularUserSnapshot =
          await FirebaseFirestore.instance
              .collection('RegularUser')
              .doc(uid)
              .get();

      if (regularUserSnapshot.exists) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('loggedInEmail', email);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FHomePage()),
        );
      } else {
        // Check Admin collection
        logUserInAdmin();
      }
    } catch (e) {
      toastMessage("Login failed, please enter correct credentials");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void logUserInAdmin() async {
    final String email = _email.text.toLowerCase();
    final String password = _password.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;
      DocumentSnapshot<Map<String, dynamic>> adminSnapshot =
          await FirebaseFirestore.instance.collection('Admin').doc(uid).get();

      if (adminSnapshot.exists) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('loggedInEmail', email);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminHome()),
        );
      } else {
        toastMessage("Login failed, user not found");
      }
    } catch (e) {
      toastMessage("Login failed, please enter correct credentials");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            bottom: MediaQuery.of(context).viewInsets.bottom > 0
                ? 0
                : MediaQuery.of(context).size.height * 0.1,
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 34, fontFamily: "Poppins"),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 7,
                      ),
                      child: Text(
                        'Unlock your potential with TechXcel!\n'
                        'Login now and embark on an exciting journey!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (_isLoading)
                      IgnorePointer(
                        child: Opacity(
                          opacity: 1,
                          child: Container(
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(
                      width: 300,
                      child: Divider(
                        color: Color.fromARGB(255, 211, 211, 211),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15.0, bottom: 8.0),
                            child: Text(
                              'Email Address',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          reusableTextField("Please Enter Your Email",
                              Icons.email, false, _email, true),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15.0, bottom: 8.0),
                            child: Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                reusableTextField("Please Enter Your Password",
                                    Icons.lock, true, _password, true),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ForgetPassword()),
                                    );
                                  },
                                  child: const Text(
                                    'Forgot Password?',
                                    style:
                                        TextStyle(color: Colors.blue, shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 2.0,
                                        offset: Offset(0.1, 0.5),
                                      )
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    signUpOption(),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: logUserIn,
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
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const OnboardingScreen()),
                          );
                        },
                        child: Container(
                          width: 70,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 182, 184, 185),
                          ),
                          child: const Icon(
                            Icons.highlight_remove_sharp,
                            color: Colors.white,
                            size: 50,
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

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Color.fromARGB(255, 60, 6, 99)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Signup()),
            );
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}

 