import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:techxcel11/Models/ReusedElements.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({Key? key}) : super(key: key);

  @override
  State<AdminProfile> createState() => _AdminProfile();
}

class _AdminProfile extends State<AdminProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBarAdmin(),
      appBar: buildAppBar('My profile'),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminEditProfile()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromRGBO(37, 6, 81, 0.898),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Edit Profile',
                      style: TextStyle(
                          color: Color.fromARGB(255, 254, 254, 254),
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Image.asset(
                'assets/Backgrounds/defaultUserPic.png',
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              Text(
                'Your Role: Admin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You need to maintain integrity in this platform and ensure compliance with the rules and guidelines.',
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminEditProfile extends StatefulWidget {
  const AdminEditProfile({Key? key}) : super(key: key);

  @override
  State<AdminEditProfile> createState() => _AdminEditProfile();
}

class _AdminEditProfile extends State<AdminEditProfile> {
  String _loggedInPassword = '';
  String _loggedInEmail = '';
  bool isModified = false;
  bool isPasswordchange = false;
  // Modified by user:
  String newPassword = ''; // changed or not (changed means user wants to edit)
  bool showPassword = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('Admin')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs[0].data();
      final password = userData['password'] ?? '';
      newPassword = '';
      isPasswordchange = false;

      setState(() {
        _loggedInEmail = email;
        _loggedInPassword = password;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar('Edit Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Email
            Row(
              children: [
                SizedBox(width: 30),
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 5),
                Tooltip(
                 decoration: BoxDecoration(
                      color: Color.fromARGB(177, 40, 0, 75), 
                      borderRadius: BorderRadius.circular(8.0), 
                    ),
                  message: 'Email address cannot be changed',
                  padding: EdgeInsets.all(20),
                  showDuration: Duration(seconds: 4),
                  textStyle: TextStyle(color: Colors.white),
                  preferBelow: false,
                  child: Icon(
                    Icons.warning_rounded,
                    size: 18,
                    color: Color.fromARGB(255, 195, 0, 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email,
                          color: Color.fromARGB(255, 0, 0, 0)),
                      labelStyle: const TextStyle(
                        color: Colors.black54,
                      ),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: const Color.fromARGB(255, 119, 119, 119)
                          .withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    enabled: false,
                    readOnly: true,
                    controller: TextEditingController(text: _loggedInEmail),
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
            const SizedBox(height: 20),
            // Password
            Row(
              children: [
                const SizedBox(width: 30),
                Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 5),
                Tooltip(
                  message:
                      'Password must be at least 6 characters long\nand no white spaces are allowed',
                  padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                      color: Color.fromARGB(177, 40, 0, 75), 
                      borderRadius: BorderRadius.circular(8.0), 
                    ),
                 showDuration: const Duration(seconds: 3),
                  textStyle: TextStyle(color: Colors.white),
                  preferBelow: false,
                  child: Icon(
                    Icons.live_help_rounded,
                    size: 18,
                    color: const Color.fromARGB(255, 178, 178, 178),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock,
                          color: Color.fromARGB(255, 0, 0, 0)),
                      labelStyle: const TextStyle(
                        color: Colors.black54,
                      ),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      fillColor: const Color.fromARGB(255, 228, 228, 228)
                          .withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(showPassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                    enabled: true,
                    readOnly: false,
                    obscureText: !showPassword,
                    onChanged: (value) {
                      setState(() {
                        newPassword = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (await validatePassword()) if (isModified == true) {
                      _showSnackBar2(
                          "Your information has been changed successfully");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdminProfile()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdminProfile()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 6, 107, 10),
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> validatePassword() async {
    // Check if the new password is equal to the existing password
    if (newPassword == '' || hashPassword(newPassword) == _loggedInPassword) {
      return true; // Nothing changed (user doesn't want to modify)
    } else
    // Check password length
    if (newPassword.length < 6) {
      toastMessage('Password should not be less than 6 characters.');
      return false;
    } else
    // Check for white spaces in the password
    if (newPassword.contains(' ')) {
      toastMessage('Password should not contain spaces.');
      return false;
    } else
    // Update the password in the database and Firebase Authentication
    if (await updatePasswordByEmail()) {
      return true;
    }

    return false;
  }

  Future<bool> updatePasswordByEmail() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Admin')
        .where('email', isEqualTo: _loggedInEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String userId = userDoc.id;
      final String hashedPassword =
          hashPassword(newPassword); // Hash the new password

      await FirebaseFirestore.instance
          .collection('Admin')
          .doc(userId)
          .update({'password': hashedPassword});

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await user.updatePassword(newPassword);
          isModified = true;
          return true;
        } catch (e) {}
      }
    }

    return false;
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _showSnackBar2(String message) {
    double snackBarHeight = 440;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.only(
          bottom: snackBarHeight + 180,
          right: 20,
          left: 20,
        ),
        backgroundColor: Color.fromARGB(255, 12, 118, 51),
      ),
    );
  }
}
