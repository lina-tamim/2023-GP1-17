import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  AppBar buildAppBarWithTabs(String titleText, TabController tabController) {
    return AppBar(
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
      backgroundColor: const Color.fromRGBO(37, 6, 81, 0.898),
      toolbarHeight: 100, 
      elevation: 0, 
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(130),
          bottomRight: Radius.circular(130),
        ),
      ),
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
                  color: Colors.white,
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
            child: Text(
              'Courses and Events',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(
                    255, 245, 227, 255), 
              ),
            ),
          ),
          Tab(
            child: Text(
              'Pathways',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(
                    255, 245, 227, 255), 
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
