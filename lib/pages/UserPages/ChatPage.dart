import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/pages/CommonPages/chat/conversations_screen.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

int _currentIndex = 0;

class _ChatPageState extends State<ChatPage> {
  String _loggedInImage = '';

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

      final imageURL = userData['imageURL'] ?? '';

      setState(() {
        _loggedInImage = imageURL;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBarUser(),
      appBar: buildAppBarUser('Chat', _loggedInImage),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: true
            ? ConversationsScreen()
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'TeXel',
                      style: GoogleFonts.orbitron(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Image.asset('assets/Backgrounds/XlogoSmall.png'),
                    const SizedBox(height: 30),
                    Text(
                      'Coming soon !',
                      style: TextStyle(
                          fontFamily: AutofillHints.familyName,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )
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
