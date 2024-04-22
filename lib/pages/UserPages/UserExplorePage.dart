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
      toolbarHeight: 90, 
      elevation: 0, 
       flexibleSpace: Stack(
    children: [
      Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(bottom: 1),
        child: Container(
          height: 3,
          color: const Color.fromARGB(60, 158, 158, 158), // Set the color of the horizontal bar
        ),
      ),
      Container(),
    ],
  ),
     /* shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(130),
          bottomRight: Radius.circular(130),
        ),
      ),*/
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(builder: (context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Icon(Icons.menu),
                );
              }),
              Text(
                'Explore',
                style: TextStyle(
                  fontSize: 18, // Adjust the font size
                  fontFamily: "Poppins",
                  color:const Color.fromRGBO(0, 0, 0, 0.894),
                ),
              ),
              Spacer(),
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
          SizedBox(
            height: 0,
          ),
          if (showSearchBar)
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                ),
                isDense: true,
              ),
              onChanged: (text) {
                setState(() {});
              },
            ),
        ],
      ),
      bottom: TabBar(
        controller: tabController, 
        indicator: BoxDecoration(),
        tabs: [
           Tab(
            child: Text('Courses and Events',
              style: TextStyle(
                fontSize: 16,
                color:const Color.fromRGBO(0, 0, 0, 0.894),
              ),
            ),
          ),
          Tab(
            child: Text(
              'Pathways',
              style: TextStyle(
                fontSize: 16,
                color:const Color.fromRGBO(0, 0, 0, 0.894), 
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
