//Full code, m s
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:techxcel11/pages/EditProfile2.dart';
import 'package:techxcel11/pages/Login.dart';
import 'package:techxcel11/pages/reuse.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart'; //
import 'dart:math' as math;

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String loggedInUsername = '';
  String loggedInCountry = '';
  String loggedInCity = '';
  String loggedInUserType = '';
  String loggedInGithub = '';
  List<String> userSkills = [];
  List<String> userInterests = [];
  String loggedInImage = '';
  bool showSkills = false;
  bool showInterests = false;
  String url = '';
  int _currentIndex = 0;

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
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs[0].data();

      final username = userData['userName'] ?? '';
      final country = userData['country'] ?? '';
      final city = userData['city'] ?? '';
      final github = userData['GithubLink'] ?? '';
      final skills = List<String>.from(userData['skills'] ?? []);
      final interests = List<String>.from(userData['interests'] ?? []);
      final userType = userData['userType'] ?? '';
      final imageUrl = userData['imageUrl'] ?? '';

      setState(() {
        loggedInUsername = username;
        loggedInCountry = country;
        loggedInCity = city;
        loggedInGithub = github;
        userSkills = skills;
        userInterests = interests;
        loggedInUserType = userType;
        loggedInImage = imageUrl;
      });
    }
  }

  void toggleSkills() {
    setState(() {
      showSkills = !showSkills;
    });
  }

  void toggleInterests() {
    setState(() {
      showInterests = !showInterests;
    });
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                logUserOut();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void logUserOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('loggedInEmail');
      _showSnackBar("Logged out successfully");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } catch (e) {
      print('$e');
      _showSnackBar("Logout failed");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 80,
          right: 20,
          left: 20,
        ),
        backgroundColor:
            Color.fromARGB(255, 63, 12, 118), // Customize the background color
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBarUser(),
      appBar: buildAppBar('My Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          child: Column(
            children: [
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditProfile2()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 10, 1, 95),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Edit Profile',
                      style:
                          TextStyle(color: Color.fromARGB(255, 254, 254, 254))),
                ),
              ),

              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 5),
              if (loggedInImage.isNotEmpty)
                Container(
                  width: 110,
                  height: 110,
                  child: CircleAvatar(
                    child: ClipOval(
                      child: Image.network(
                        loggedInImage,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$loggedInUsername ',
                    style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (loggedInUserType ==
                      "Freelancer") // Replace "userType" with the actual variable representing the user type
                    const Icon(
                      Icons.verified,
                      color: Color.fromARGB(255, 0, 91, 228),
                      size: 25, // Adjust the size of the star icon as desired
                    ),
                ],
              ),
              // Country and City
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 4),
                  Text(
                    loggedInCity == 'null'
                        ? loggedInCountry
                        : '$loggedInCountry, $loggedInCity',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              // Github
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 5),
                  Icon(
                    FontAwesomeIcons.github,
                    size: 18,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      url = loggedInGithub;
                      launchURL(url);
                    },
                    child: Text(
                      loggedInGithub.isEmpty
                          ? 'Add your GitHub account now!'
                          : '   $loggedInGithub',
                      style: TextStyle(
                        fontSize: 16,
                        color: loggedInGithub.isEmpty
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : Colors.blueAccent,
                        decoration: loggedInGithub.isEmpty
                            ? TextDecoration.none
                            : TextDecoration.none,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 20),
              InkWell(
                onTap: toggleInterests,
                child: Row(
                  children: [
                    Transform.rotate(
                      angle: showInterests ? math.pi / 2 : 0,
                      child: const Icon(
                        Icons.arrow_right,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Interests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (showInterests)
                Column(
                  children: userInterests.map((interest) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(interest),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
              const Divider(),
              InkWell(
                onTap: toggleSkills,
                child: Row(
                  children: [
                    Transform.rotate(
                      angle: showSkills ? math.pi / 2 : 0,
                      child: const Icon(
                        Icons.arrow_right,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Skills',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (showSkills)
                Column(
                  children: [
                    if (userSkills.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text("You haven't added any skills yet!"),
                      )
                    else
                      ...userSkills.map((skill) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(skill),
                        );
                      }).toList(),
                  ],
                ),
              const SizedBox(height: 26),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

//TECHXCEL-LINA

