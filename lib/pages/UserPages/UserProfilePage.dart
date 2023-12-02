import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:techxcel11/pages/UserPages/EditUserProfilePage.dart';
import 'package:techxcel11/Models/ReusedElements.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _loggedInUsername = '';
  String _loggedInCountry = '';
  String _loggedInCity = '';
  String _loggedInUserType = '';
  String _loggedInGithub = '';
  List<String> _userSkills = [];
  List<String> _userInterests = [];
  String _loggedInImage = '';
  bool showSkills = false;
  bool showInterests = false;
  String _url = '';
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
        .collection('RegularUser')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs[0].data();

      final username = userData['username'] ?? '';
      final country = userData['country'] ?? '';
      final city = userData['city'] ?? '';
      final github = userData['githubLink'] ?? '';
      final skills = List<String>.from(userData['skills'] ?? []);
      final interests = List<String>.from(userData['interests'] ?? []);
      final userType = userData['userType'] ?? '';
      final imageURL = userData['imageURL'] ?? '';

      setState(() {
        _loggedInUsername = username;
        _loggedInCountry = country;
        _loggedInCity = city;
        _loggedInGithub = github;
        _userSkills = skills;
        _userInterests = interests;
        _loggedInUserType = userType;
        _loggedInImage = imageURL;
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
                width: 180,
                height: 40,
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

              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 5),
              if (_loggedInImage.isNotEmpty)
                Container(
                  width: 110,
                  height: 110,
                  child: CircleAvatar(
                    child: ClipOval(
                      child: Image.network(
                        _loggedInImage,
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
                    '$_loggedInUsername ',
                    style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_loggedInUserType ==
                      "Freelancer") 
                    const Icon(
                      Icons.verified,
                      color: Color.fromARGB(255, 0, 91, 228),
                      size: 25, 
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
                    _loggedInCity == 'null'
                        ? _loggedInCountry
                        : '$_loggedInCountry, $_loggedInCity',
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
                      _url = _loggedInGithub;
                      launchURL(_url);
                    },
                    child: Text(
                      _loggedInGithub.isEmpty
                          ? 'Add your GitHub account now!'
                          : '   $_loggedInGithub',
                      style: TextStyle(
                        fontSize: 16,
                        color: _loggedInGithub.isEmpty
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : Colors.blueAccent,
                        decoration: _loggedInGithub.isEmpty
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
                  children: _userInterests.map((interest) {
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
                    if (_userSkills.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text("You haven't added any skills yet!"),
                      )
                    else
                      ..._userSkills.map((skill) {
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

//LinaFri