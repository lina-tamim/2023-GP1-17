import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import the FontAwesome Flutter package
import 'package:techxcel11/pages/EditProfile2.dart';
import 'package:techxcel11/pages/Login.dart';
import 'package:techxcel11/pages/NavBar.dart';
import 'package:techxcel11/pages/reuse.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String loggedInUsername = '';
  String loggedInCountry = '';
  String loggedInCity = '';
  String loggedInGithub = '';
  List<String> userSkills = [];
  List<String> userInterests = [];
  bool showSkills = false;
  bool showInterests = false;

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

      setState(() {
        loggedInUsername = username;
        loggedInCountry = country;
        loggedInCity = city;
        loggedInGithub = github;
        userSkills = skills;
        userInterests = interests;
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
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 2),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfile2()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 49, 0, 70),
                    onPrimary: Colors.white,
                    side: BorderSide.none ,
                    shape: StadiumBorder(),
                  ),
                  child: const Text('Edit Profile', style: TextStyle(color: Color.fromARGB(255, 254, 254, 254))),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
             Image.network(
                  'https://img.freepik.com/free-icon/user_318-563642.jpg',
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              // Username
              SizedBox(height: 16),
          Text(
  loggedInUsername,
  style: GoogleFonts.orbitron ( // chakraPetch blackOpsOne orbitron
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
                textAlign: TextAlign.center,
              ),
              // Country and City
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 4),
                  Text(
                    loggedInCity == 'null' ? '$loggedInCountry' : '$loggedInCountry, $loggedInCity',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              // Github
              SizedBox(height: 4), 
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   SizedBox(width: 5),
                  Icon(
                    FontAwesomeIcons.github,
                    size: 18,
                    color: Colors.grey[700],
                  ),
                  SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      final url = ' https://github.com';
                      launchURL(url);
                    },
                    child: Text(
                      loggedInGithub.isEmpty ? 'Add your GitHub account now!' : '   $loggedInGithub',
                      style: TextStyle(
                        fontSize: 16,
                        color: loggedInGithub.isEmpty ? const Color.fromARGB(255, 0, 0, 0) : Colors.blueAccent,
                        decoration: loggedInGithub.isEmpty ? TextDecoration.none : TextDecoration.none,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              const Divider(),
              SizedBox(height: 20),
InkWell(
          onTap: toggleInterests,
          child: Row(
            children: [
              Transform.rotate(
                angle: showInterests ? math.pi / 2 : 0,
                child: Icon(
                  Icons.arrow_right ,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 5),
              Text(
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
              SizedBox(height: 20),
              const Divider(),
               InkWell(
          onTap: toggleSkills,
          child: Row(
            children: [
              Transform.rotate(
                angle: showSkills ? math.pi / 2 : 0,
                child: Icon(
                  Icons.arrow_right,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 5),
              Text(
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
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
              SizedBox(height: 80),
InkWell(
  onTap: showLogoutConfirmationDialog,
  child: ListTile(
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.red,
      ),
      child: Icon(
        Icons.logout,
        color: Colors.white,
      ),
    ),
    title: Text(
      'Logout',
      style: Theme.of(context).textTheme.bodyText1?.apply(
            color: Colors.black87,
            fontWeightDelta: 2,
          ),
    ),
    trailing: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18.0,
        color: Colors.grey,
      ),
    ),
  ),
            
)
            
            ],
          ),
        ),
      ),
    );
  }
}
