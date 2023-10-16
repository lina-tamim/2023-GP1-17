import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:techxcel11/pages/reuse.dart';
import 'package:techxcel11/pages/Fhome.dart';
import 'package:lottie/lottie.dart';
import 'package:techxcel11/pages/start.dart';
import 'package:techxcel11/pages/ForgetPassword.dart';
import 'package:techxcel11/pages/Admin_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:techxcel11/pages/Signup.dart';



class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  TextEditingController _password = TextEditingController();
  TextEditingController _email = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

@override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

void logUserIn() async {
  final String email = _email.text.toLowerCase();
  final String password = _password.text.trim();

  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Email and password match a user in the database
    final uid = userCredential.user!.uid;

    // Fetch the user document from Firestore based on the uid
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (snapshot.exists) {
      final user = snapshot.data()!;

      // Save the user's email in shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('loggedInEmail', email);
      _showSnackBar("Welcome Back!");

      // Redirect the user based on the user type
      if (user['userType'] == 'Admin') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminHome()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FHomePage()),
        );
      }
    } else {
      _showSnackBar("Login failed, please enter correct credentials");
    }
  } catch (e) {
    // Handle login errors here
    print('Login error: $e');
    _showSnackBar("Login failed, please enter correct credentials");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevent screen resize when keyboard appears
      body: Stack(
        children: [
          //BG
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

          // Add your signup content here
          // White square with content...
          Positioned(
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            top: MediaQuery.of(context).size.height * 0.1,
            bottom: MediaQuery.of(context).size.height * 0.1,
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                //height: MediaQuery.of(context).size.height * 1,

                ///++++
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // Title
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

                    Container(
                      width: 300, // Adjust the width as needed
                      child: Divider(
                        color: const Color.fromARGB(255, 211, 211, 211),
                        thickness: 1,
                      ),
                    ),

                    // Email
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

                    //password
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
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                reusableTextField("Please Enter Your Password",
                                    Icons.password, true, _password, true),
                          TextButton(
                                  // FORGET PASSWORD
                                  onPressed: () {
                                    // Navigate to ForgetPassword page
                                    Navigator.push(
                                      // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ForgetPassword()),
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
                    signUpOption(), // Add the signUpOption widget here
  
                    GestureDetector(
                      onTap: 
                        logUserIn,
                      child: Container(
                        height: 174,
                        child: Lottie.network(
                          'https://lottie.host/702b54d8-e453-4d3b-93c5-f7ebf587554a/bS3nChV9sx.json', // Replace with the actual path to your Lottie animation file
                          fit: BoxFit.contain,
                        ),
                      ),
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(255, 182, 184, 185),
                          ),
                          child: Icon(
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
              MaterialPageRoute(builder: (context) => Signup()),
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
  var bytes = utf8.encode(password); // Encode the password as bytes
  var digest = sha256.convert(bytes); // Hash the bytes using SHA-256
  return digest.toString(); // Convert the hash to a string
} 

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
