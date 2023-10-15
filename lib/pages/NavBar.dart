import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/pages/Login.dart';
import 'package:techxcel11/pages/UserProfilePage.dart';
import 'package:techxcel11/pages/aboutus.dart';
import 'package:techxcel11/pages/bookmark.dart';
import 'package:techxcel11/pages/calender.dart';


class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  String loggedInUsername = '';
  String loggedInEmail='';
  

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
            accountEmail: Text(loggedInEmail),
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
              color: Color.fromARGB(117, 35, 0, 106), // if img not show up
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
), // change it to page name +++++++++++++++++
          ),
          Divider(),


          // my Post
          ListTile(
            leading: Icon(Icons.post_add),
            title: Text('My Post'),
            onTap: () => null, // change it to page name +++++++++++++++++
          ),
          Divider(),

          // Bookmarke
          ListTile(
            leading: Icon(Icons.bookmark),
            title: Text('Bookmarke'),
                       onTap: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => BookmarkPage()),
), // change it to page name +++++++++++++++++
          ),
          Divider(),

          // calendar
          ListTile(
            leading: Icon(Icons.calendar_month),
            title: Text('Calendar'),
                      onTap: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => CalenderPage()),
), // change it to page name +++++++++++++++++
          ),

          // about us - contact us
          ListTile(
            leading: Icon(Icons.groups_2_rounded),
            title: Text('About Us'),
            onTap: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => AboutUsPage()),
),
// change it to page name +++++++++++++++++
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



















/*import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // top
        children: [
          UserAccountsDrawerHeader(
            // +++++++++++++modify

            accountName: Text('Lina-tamim'),
            accountEmail: Text('Linatamim@hotmail.com'),
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
              color: Color.fromARGB(255, 218, 200, 255), // if img not show up
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
            onTap: () => null, // change it to page name +++++++++++++++++
          ),
          Divider(),
          // my Post
          ListTile(
            leading: Icon(Icons.post_add),
            title: Text('My Post'),
            onTap: () => null, // change it to page name +++++++++++++++++
          ),
          Divider(),

          // Bookmarke
          ListTile(
            leading: Icon(Icons.bookmark),
            title: Text('Bookmarke'),
            onTap: () => null, // change it to page name +++++++++++++++++
          ),
          Divider(),

          // calendar
          ListTile(
            leading: Icon(Icons.calendar_month),
            title: Text('Calendar'),
            onTap: () => null, // change it to page name +++++++++++++++++
          ),

          // about us - contact us
          ListTile(
            leading: Icon(Icons.groups_2_rounded),
            title: Text('About Us'),
            onTap: () => null, // change it to page name +++++++++++++++++
          ),
//logout
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => null, // change it to page name +++++++++++++++++
          ),
        ],
      ),
    );
  }
}
*/ }