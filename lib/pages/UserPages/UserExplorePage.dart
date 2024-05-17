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

 AppBar buildAppBarWithTabs(String titleText, TabController tabController) {
    return AppBar(
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(
    color: Color.fromRGBO(37, 6, 81, 0.898),
  ),
      backgroundColor:   Color.fromARGB(255, 242, 241, 243),
       toolbarHeight: 70,
            title: Builder(
              builder: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (_loggedInImage.isNotEmpty && !showSearchBar)
                        GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: CircleAvatar(
                            radius: 35,
                            backgroundImage: NetworkImage(_loggedInImage),
                          ),
                        ),
              Text(
                '   Explore',
                style: TextStyle(
                  fontSize: 18, // Adjust the font size
                  fontFamily: "Poppins",
                  color:const Color.fromRGBO(0, 0, 0, 0.894),
                ),
              ),
              Spacer(),
               if (!showSearchBar) const SizedBox(width: 100),
                      if (showSearchBar) const SizedBox(width: 150),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showSearchBar = !showSearchBar;
                          });
                        },
                        icon: Icon(
                            showSearchBar ? Icons.search_off : Icons.search),
                      ),
                    ],
                  ),
                  if (showSearchBar)
                    Container(
                      height: 40.0, // Adjust the height as needed
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Color.fromARGB(255, 242, 241, 243),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            //borderSide: BorderSide.bottom ,
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10.0),
                          isDense: false,
                        ),
                        style: TextStyle(color: Colors.black, fontSize: 14.0),
              onChanged: (text) {
                setState(() {});
              },
            ),
                    ),
        ],
      ),
            ),
      bottom: TabBar(
        controller: tabController, 
        tabs: [
          Tab(
            child: Text(
              'Courses and events',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ),
          Tab(
            child: Text(
              'Pathways',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWithTabs('Explore', _tabController),
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
