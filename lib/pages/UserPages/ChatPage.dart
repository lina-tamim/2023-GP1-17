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

  bool showSearchBar = false;
  final _searchTextController = TextEditingController();

  AppBar buildAppBarSearch(String titleText) {
    return AppBar(
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(
        color: Color.fromRGBO(37, 6, 81, 0.898),
      ),
      backgroundColor: Color.fromARGB(255, 242, 241, 243),
      toolbarHeight: 90,
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
                  '   $titleText',
                  style: TextStyle(
                    fontSize: 18, // Adjust the font size
                    fontFamily: "Poppins",
                    color: const Color.fromRGBO(0, 0, 0, 0.894),
                  ),
                ),
                Spacer(),
                if (!showSearchBar) const SizedBox(width: 150),
                if (showSearchBar) const SizedBox(width: 200),
                IconButton(
                  onPressed: () {
                    setState(() {
                      showSearchBar = !showSearchBar;
                    });
                    _searchTextController.clear();
                  },
                  icon: Icon(showSearchBar ? Icons.search_off : Icons.search),
                ),
              ],
            ),
            if (showSearchBar)
              Container(
                height: 40.0, // Adjust the height as needed
                child: TextField(
                  controller: _searchTextController,
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget searchField = TextField(
      controller: _searchTextController,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
          // border: InputBorder.none,
          hintText: 'Search users',
          prefixIcon: Icon(Icons.search)),
    );
    Widget searchButton = IconButton(
      onPressed: () {
        setState(() {
          showSearchBar = !showSearchBar;
        });
        _searchTextController.clear();
      },
      icon: Icon(showSearchBar ? Icons.search_off : Icons.search),
    );
    return Scaffold(
      drawer: const NavBarUser(),
      appBar: buildAppBarSearch('Chat'),
      // buildAppBarUser(
      //   'Chat',
      //   _loggedInImage,
      //   actionWidget: showSearchBar ? SizedBox() : searchButton,
      //   flexibleWidget: (!showSearchBar)
      //       ? SizedBox()
      //       : Row(
      //           children: [
      //             Expanded(child: searchField),
      //             searchButton,
      //           ],
      //         ),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Expanded(
              child: true
                  ? ConversationsScreen(
                      searchTextController: _searchTextController,
                    )
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
          ],
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
