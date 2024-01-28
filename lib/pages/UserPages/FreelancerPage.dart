import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/pages/UserPages/UserProfileView.dart';
import '../../providers/profile_provider.dart';

class FreelancerPage extends StatefulWidget {
  const FreelancerPage({Key? key}) : super(key: key);

  @override
  State<FreelancerPage> createState() => _FreelancerPageState();
}

int _currentIndex = 0;

class _FreelancerPageState extends State<FreelancerPage> {
  String _loggedInImage = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _freelancers = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchFreelancers();
  }

  // Fetch user data for the logged-in user
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

      final imageURL = userData['imageURL'] ?? '';

      setState(() {
        _loggedInImage = imageURL;
      });
    }
  }

  // Fetch freelancers data
  Future<void> fetchFreelancers() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('RegularUser')
        .where('userType', isEqualTo: 'Freelancer')
        .get();

    final List<Map<String, dynamic>> freelancers =
        snapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      _freelancers = freelancers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBarUser(),
      appBar: buildAppBarUser('Freelancers', _loggedInImage),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
          itemCount: _freelancers.length,
          separatorBuilder: (context, index) => SizedBox(height: 10),
          itemBuilder: (context, index) {
            final freelancer = _freelancers[index];
            final username = freelancer['username'] as String;
            final imageURL = freelancer['imageURL'] as String;
            final skills = freelancer['skills'] as List<dynamic>;
            final userId = freelancer['email'] as String;

            return Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromARGB(114, 233, 224, 244),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(imageURL),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (userId != null &&
                                    userId.isNotEmpty &&
                                    userId != "DeactivatedUser") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UserProfileView(userId: userId),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                username,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 24, 8, 53),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            const Icon(
                              Icons.verified,
                              color: Color.fromARGB(255, 0, 91, 228),
                              size: 19,
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                context
                                    .read<ProfileProvider>()
                                    .gotoChat(context, userId);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: const Icon(
                                  FontAwesomeIcons.solidMessage,
                                  color: Color.fromARGB(255, 135, 135, 135),
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color.fromARGB(255, 209, 196, 25),
                              size: 19,
                            ),
                            Text(" 4.8 / 5"),
                          ],
                        ),
                        Container(
                          width:
                              280, // Set a fixed width for the skills container
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                skills.length,
                                (skillIndex) {
                                  final skill = skills[skillIndex] as String;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: Chip(
                                      label: Text(
                                        skill,
                                        style: TextStyle(fontSize: 12.0),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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
