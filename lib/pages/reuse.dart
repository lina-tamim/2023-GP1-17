
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/pages/AdminProfilePage.dart';
import 'package:techxcel11/pages/Admin_home.dart';
import 'package:techxcel11/pages/ChatPage.dart';
import 'package:techxcel11/pages/AdminCoursesAndEventsPage.dart';
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
            currentAccountPicture: loggedImage.isNotEmpty
                ? CircleAvatar(
                    child: ClipOval(
                      child: Image.network(
                        loggedImage,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : SizedBox(),
            decoration: BoxDecoration(
              color: Color.fromARGB(
                  255, 62, 0, 61), // Set the desired background color here

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
              print("******$loggedInEmail");
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
          SizedBox(height: 110),
          Divider(),
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
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(loggedInUsername),
            accountEmail: Text(
              loggedInEmail,
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset(
                  'assets/Backgrounds/defaultUserPic.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 39, 0, 73),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            iconColor: Colors.black,
            title: const Text('Profile'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminProfile()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.groups_2_rounded),
            iconColor: Colors.black,
            title: const Text('Dashboard'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminHome()),
            ),
          ),
          SizedBox(height: 280),
          Divider(),
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
    TextEditingController controller, bool modifiable,
    {int? maxLines}) {
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
    maxLines: isPasswordType ? 1 : maxLines,
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

void showSnackBar(String message, context) {
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
      backgroundColor: Color.fromARGB(255, 63, 12, 118),
    ),
  );
}

void toastMessage(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Color.fromRGBO(37, 6, 81, 0.898),
      textColor: Color(0xffffffff),
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1);
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
          MaterialPageRoute(builder: (context) => const AdminCoursesAndEventsPage()),
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
              setState(() {
                _currentTappedIndex = 0;
              });
              _navigateToPage(context, 0);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.solidMessage,
                  size: 18.5,
                  color: Colors.black,
                ),
                Text(
                  'Chat',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _currentTappedIndex = 1;
              });
              _navigateToPage(context, 1);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.handshakeSimple,
                  size: 20,
                  color: Colors.black,
                ),
                Text(
                  'Freelancer',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _currentTappedIndex = 2;
              });
              _navigateToPage(context, 2);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.home,
                  size: 20,
                  color: Colors.black,
                ),
                Text(
                  ' Home',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _currentTappedIndex = 3;
              });
              _navigateToPage(context, 3);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.explore,
                  size: 22.5,
                  color: Colors.black,
                ),
                Text(
                  'Explore',
                  style: TextStyle(fontSize: 10),
                ),
              ],
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
  final SnackBar snackBar = SnackBar(
    content: Text(message),
    //behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    //margin: EdgeInsets.only(
    //bottom: MediaQuery.of(context).size.height - 80,
    //right: 20,
    //left: 20,
    //),
    backgroundColor: Color.fromARGB(255, 63, 12, 118),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

////Dropdown widget to show dropdown in Courses or Events Post Screen
class DropDownWidget extends StatefulWidget {
  DropDownWidget({
    Key? key,
    required this.selectedItem,
    required this.list,
    required this.onItemSelected,
    this.fontSize = 16,
  }) : super(key: key);
  late final String selectedItem;
  final void Function(String?) onItemSelected;
  final List<String> list;
  final double fontSize;

  @override
  State<DropDownWidget> createState() => _DropDownWidgetState();
}

class DropDownMenu extends StatelessWidget {
  const DropDownMenu({
    Key? key,
    required this.gender,
    required this.onTap,
    required this.items,
    this.fontSize = 16,
  }) : super(key: key);
  final String gender;
  final List<String> items;
  final double fontSize;
  final ValueChanged<String?> onTap;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: gender,
      icon: Text(""),
      isExpanded: false,
      decoration: InputDecoration(border: InputBorder.none),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
                fontSize: 16, color: Color.fromRGBO(37, 6, 81, 0.898)),
          ),
        );
      }).toList(),
      onChanged: onTap,
    );
  }
}

class _DropDownWidgetState extends State<DropDownWidget> {
  // List<String> get stringList => widget.list.map((item) => item.toString()).toList();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: 190,
      // padding:
      // EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
          //     color: Color.fromARGB(255, 228, 228, 228).withOpacity(0.3),
          // border: Border.all(
          //   color: mainColor.withOpacity(0.6),
          // ),
          // boxShadow: ([
          //   BoxShadow(
          //       color: mainColor.withOpacity(0.2),
          //       spreadRadius: 1,
          //       blurRadius: 4,
          //       offset: Offset(
          //           0,3
          //       )
          //   )
          // ]),
          borderRadius: BorderRadius.circular(12)),
      child: DropDownMenu(
          gender: widget.selectedItem,
          onTap: widget.onItemSelected,
          // onTap: (value) {
          //   setState(() {
          //     widget.selectedItem = value!;
          //     print("selectedGender$widget.selectedItem");
          //   });
          // },
          fontSize: widget.fontSize,
          items: widget.list),
    );
  }
}

//////Pop to show in Events Post Screen
showAlertDialog(context, Widget child,
    {okButtonText = 'Ok',
    onPress = null,
    showCancelButton = true,
    dismissible = true}) {
  String icon;
  showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: dismissible,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 400),
      transitionBuilder: (_, anim, __, child) {
        var begin = 0.5;
        var end = 1.0;
        var curve = Curves.bounceOut;
        if (anim.status == AnimationStatus.reverse) {
          curve = Curves.fastLinearToSlowEaseIn;
        }
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return ScaleTransition(
          scale: anim.drive(tween),
          child: child,
        );
      },
      pageBuilder: (BuildContext alertContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setState) {
            return WillPopScope(
              onWillPop: () {
                return Future.value(dismissible);
              },
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(25),
                  child: SingleChildScrollView(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                      child: Material(
                        child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(5),
                            child: child),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      });
}
