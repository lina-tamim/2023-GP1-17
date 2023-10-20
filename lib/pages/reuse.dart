import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/pages/AdminProfilePage.dart';
import 'package:techxcel11/pages/Admin_home.dart';
import 'package:techxcel11/pages/ChatPage.dart';
import 'package:techxcel11/pages/CoursesAndEventsPage.dart';
import 'package:techxcel11/pages/Fhome.dart';
import 'package:techxcel11/pages/FreelancerPage.dart';
import 'package:techxcel11/pages/UserProfilePage.dart';
import 'package:techxcel11/pages/aboutus.dart';
import 'package:techxcel11/pages/bookmark.dart';
import 'package:techxcel11/pages/CalendarPage.dart';
import 'package:techxcel11/pages/user_posts_page.dart'; //m
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:techxcel11/pages/start.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NavBarUser extends StatefulWidget {
  const NavBarUser({super.key});

  @override
  _NavBarUserState createState() => _NavBarUserState();
}

class _NavBarUserState extends State<NavBarUser> {
  String loggedInUsername = '';
  String loggedInEmail = '';
  String loggedImage = '';

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
      final imageUrl = userData['imageUrl'] ?? '';

      setState(() {
        loggedInUsername = username;
        loggedInEmail = email;
        loggedImage = imageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              loggedInUsername,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            accountEmail: Text(
              loggedInEmail,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  loggedImage,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue, // Set the desired background color here

              image: DecorationImage(
                image: AssetImage('assets/Backgrounds/bg11.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            iconColor: Colors.black,
            title: const Text('Profile'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfilePage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.post_add),
            iconColor: Colors.black,
            title: const Text('My Interactions'),
            onTap: () async {
              await fetchUserData(); // Fetch user data and assign the value to 'loggedInEmail'
              print("**************$loggedInEmail");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserPostsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            iconColor: Colors.black,
            title: const Text('Bookmark'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookmarkPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            iconColor: Colors.black,
            title: const Text('Calendar'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalendarPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.groups_2_rounded),
            iconColor: Colors.black,
            title: const Text('About Us'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsPage()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            iconColor: Colors.black,
            title: const Text('Logout'),
            onTap: () {
              showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }
}

// admin NAVBAR
class NavBarAdmin extends StatefulWidget {
  const NavBarAdmin({super.key});

  @override
  _NavBarAdminState createState() => _NavBarAdminState();
}

class _NavBarAdminState extends State<NavBarAdmin> {
  String loggedInUsername = '';
  String loggedInEmail = '';
  String loggedImage = '';

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
      final imageUrl = userData['imageUrl'] ?? '';

      setState(() {
        loggedInUsername = username;
        loggedInEmail = email;
        loggedImage = imageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // top
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(loggedInUsername),
            accountEmail: Text(
              loggedInEmail,
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  loggedImage,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: Color.fromARGB(117, 230, 227, 236), // if img not show up
              image: DecorationImage(
                image: NetworkImage(
                    'https://4kwallpapers.com/images/walls/thumbs_2t/7898.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // profile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminProfile()),
            ), // change it to page name +++++++++++++++++
          ),

          // about us - contact us
          ListTile(
            leading: const Icon(Icons.groups_2_rounded),
            title: const Text('Dashboard'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminHome()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            iconColor: Colors.black,
            title: const Text('Logout'),
            onTap: () {
              showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }
}

TextField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller, bool modifiable) {
  Color boxColor = modifiable
      ? const Color.fromARGB(255, 200, 176, 185).withOpacity(0.3)
      : const Color.fromARGB(255, 165, 165, 165);

  return TextField(
    enabled: modifiable,
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: const Color.fromARGB(255, 43, 3, 101),
    style: TextStyle(
      color: const Color.fromARGB(255, 1, 9, 111).withOpacity(0.9),
      fontSize: 14,
    ),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: const Color.fromARGB(255, 63, 12, 118)),
      labelText: text,
      labelStyle: const TextStyle(
        color: Colors.black54,
      ),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: const Color.fromARGB(255, 228, 228, 228).withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        //borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

AppBar buildAppBar(String titleText) {
  return AppBar(
    iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
    backgroundColor: const Color.fromRGBO(37, 6, 81, 0.898),
    toolbarHeight: 100, // Adjust the height of the AppBar
    elevation: 0, // Adjust the position of the AppBar
    shape: const ContinuousRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(130),
        bottomRight: Radius.circular(130),
      ),
    ),
    title: Text(
      titleText,
      style: const TextStyle(
        fontSize: 18, // Adjust the font size
        fontFamily: "Poppins",
        color: Colors.white,
      ),
    ),
  );
}

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentTappedIndex = -1;

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FreelancerPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FHomePage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CoursesAndEventsPage()),
        );
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FHomePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatPage()),
              );
            },
            child: Icon(
              FontAwesomeIcons.solidMessage,
              size: 22,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FreelancerPage()),
              );
            },
            child: Icon(
              FontAwesomeIcons.handshakeSimple,
              size: 22,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FHomePage()),
              );
            },
            child: Icon(
              FontAwesomeIcons.home,
              size: 22,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CoursesAndEventsPage()),
              );
            },
            child: Icon(
              Icons.explore,
              size: 28,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

void showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              logUserOut(context);
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

void logUserOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInEmail');
    _showSnackBar(context, "Logged out successfully");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  } catch (e) {
    print('$e');
    _showSnackBar(context, "Logout failed");
  }
}

void _showSnackBar(BuildContext context, String message) {
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
//TECHXCEL-LINA
