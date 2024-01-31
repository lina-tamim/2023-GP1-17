import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/pages/UserPages/UserCoursesAndEventsPage.dart';
import 'package:techxcel11/pages/UserPages/UserPathwaysPage.dart';
import 'package:techxcel11/Models/ReusedElements.dart';

class UserExplorePage extends StatefulWidget {
  @override
  _UserExplorePageState createState() => _UserExplorePageState();
}

class _UserExplorePageState extends State<UserExplorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool showSearchBar = false;
  final searchController = TextEditingController();

  String _loggedInImage = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _tabController = TabController(length: 2, vsync: this);
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  AppBar buildAppBarWithTabs(
      String titleText, TabController tabController, _loggedInImage) {
    return AppBar(
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(
        color: Color.fromRGBO(37, 6, 81, 0.898),
      ),
      toolbarHeight: 100,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Backgrounds/bg11.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_loggedInImage.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(_loggedInImage),
                    ),
                  ),
                const SizedBox(width: 8),
                const Text(
                  'Explore',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Poppins",
                    color: Color.fromRGBO(37, 6, 81, 0.898),
                  ),
                ),
                const SizedBox(width: 120),
                IconButton(
                  onPressed: () {
                    setState(() {
                      showSearchBar = !showSearchBar;
                    });
                  },
                  icon: Icon(showSearchBar ? Icons.search_off : Icons.search),
                ),
              ],
            ),
          ],
        ),
      ),
      bottom: TabBar(
        controller: tabController,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 5.0,
            color: Color.fromARGB(
                255, 27, 5, 230), // Set the color of the underline
          ),
          // Adjust the insets if needed
        ),
        labelColor: Color.fromARGB(255, 27, 5, 230),
        tabs: [
          Tab(
            child: Text(
              'Courses and Events',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Tab(
            child: Text(
              'Pathways',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWithTabs('Explore', _tabController, _loggedInImage),
      drawer: NavBarUser(),
      body: TabBarView(
        controller: _tabController,
        children: [
          UserCoursesAndEventsPage(
            searchQuery: searchController.text,
            key: UniqueKey(),
          ),
          UserPathwaysPage(
            searchQuery: searchController.text,
            key: UniqueKey(),
          ),
        ],
      ),
    );
  }
}
