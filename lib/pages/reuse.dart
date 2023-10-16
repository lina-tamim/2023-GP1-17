
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
        padding: EdgeInsets.zero, // top
        children: [
          UserAccountsDrawerHeader(
            // +++++++++++++modify

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
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfilePage()),
            ), 
          ),
          Divider(),

          // my Post
          ListTile(
            leading: Icon(Icons.post_add),
            title: Text('My Interactions'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserPostsPage()),
            ), 
          ),
          Divider(),

          // Bookmarke
          ListTile(
            leading: Icon(Icons.bookmark),
            title: Text('Bookmarke'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BookmarkPage()),
            ), 
          ),
          Divider(),

          // calendar
          ListTile(
            leading: Icon(Icons.calendar_month),
            title: Text('Calendar'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalendarPage()),
            ), 
          ),

          // about us 
          ListTile(
            leading: Icon(Icons.groups_2_rounded),
            title: Text('About Us'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutUsPage()),
            ),
          ),
SizedBox(height: 80),
Divider(),
               ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FHomePage()),
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
            decoration: BoxDecoration(
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
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminProfile()),
            ), // change it to page name +++++++++++++++++
          ),

          // about us - contact us
          ListTile(
            leading: Icon(Icons.groups_2_rounded),
            title: Text('Dashboard'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminHome()),
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
      ? Color.fromARGB(255, 200, 176, 185).withOpacity(0.3)
      : Color.fromARGB(255, 165, 165, 165);

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
    iconTheme: IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
    backgroundColor: Color.fromRGBO(37, 6, 81, 0.898),
    toolbarHeight: 100, // Adjust the height of the AppBar
    elevation: 0, // Adjust the position of the AppBar
    shape: ContinuousRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(130),
        bottomRight: Radius.circular(130),
      ),
    ),
    title: Text(
      titleText,
      style: TextStyle(
        fontSize: 18, // Adjust the font size
        fontFamily: "Poppins",
        color: Colors.white,
      ),
    ),
  );
}


/*
class NavBarBottom2 extends StatefulWidget {
  final Function(int) onIconPressed;

  NavBarBottom2({required this.onIconPressed});

  @override
  _NavBarBottom2State createState() => _NavBarBottom2State();
}

class _NavBarBottom2State extends State<NavBarBottom2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(), // Replace with your page content
      bottomNavigationBar: BottomNavigationBar(
        onTap: widget.onIconPressed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_outlined),
            label: 'Freelancers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 219, 219, 219),
        selectedItemColor: Color.fromARGB(255, 40, 0, 57),
        unselectedItemColor: Colors.grey,
        iconSize: 20,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}*/