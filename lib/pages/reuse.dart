
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
import 'package:techxcel11/pages/user_posts_page.dart';

class NavBarUser extends StatefulWidget {
  const NavBarUser({super.key});

  @override
  _NavBarUserState createState() => _NavBarUserState();
}

class _NavBarUserState extends State<NavBarUser> {
  String loggedInUsername = '';
  String loggedInEmail = '';

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

      setState(() {
        loggedInUsername = username;
        loggedInEmail = email;
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
            accountName: Text(loggedInUsername),
            accountEmail: Text(
              loggedInEmail,
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  'https://img.freepik.com/free-icon/user_318-563642.jpg',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
       decoration: BoxDecoration(
  image: DecorationImage(
    image: AssetImage('assets/Backgrounds/navbarbg2.png'),
    fit: BoxFit.cover,
  ),
),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfilePage()),
            ), 
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.post_add),
            title: const Text('My Interactions'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfilePage()),
            ), 
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Bookmark'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookmarkPage()),
            ), 
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Calendar'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalendarPage()),
            ), 
          ),
          ListTile(
            leading: const Icon(Icons.groups_2_rounded),
            title: const Text('About Us'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsPage()),
            ),
          ),
const SizedBox(height: 80),
const Divider(),
               ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FHomePage()),
            ),
          ),
/*logout will be from user profile, ADMIN AS WELL ?
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => Login(), // change it to page name +++++++++++++++++
          ), */
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

      setState(() {
        loggedInUsername = username;
        loggedInEmail = email;
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
                  'https://img.freepik.com/free-icon/user_318-563642.jpg',
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
          
/*logout will be from user profile, ADMIN AS WELL ?
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => Login(), // change it to page name +++++++++++++++++
          ), */
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


class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  void _navigateToPage(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = ChatPage();
        break;
      case 1:
        page = FreelancerPage();
        break;
      case 2:
        page = FHomePage();
        break;
      case 3:
        page = CoursesAndEventsPage();
        break;
      default:
        page = FHomePage();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
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
              onTap(0);
            },
            child: Icon(
              Icons.chat,
              color: currentIndex == 0 ? Colors.blue : Colors.grey,
            ),
          ),
          GestureDetector(
            onTap: () {
              onTap(1);
            },
            child: Icon(
              Icons.handshake,
              color: currentIndex == 1 ? Colors.blue : Colors.grey,
            ),
          ),
          GestureDetector(
            onTap: () {
              onTap(2);
            },
            child: Icon(
              Icons.home,
              color: currentIndex == 2 ? Colors.blue : Colors.grey,
            ),
          ),
          GestureDetector(
            onTap: () {
              onTap(3);
            },
            child: Icon(
              Icons.explore,
              color: currentIndex == 3 ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}