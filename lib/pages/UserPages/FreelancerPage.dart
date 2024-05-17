import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/pages/UserPages/UserProfileView.dart';
import '../../providers/profile_provider.dart';

class FreelancerPage extends StatefulWidget {
  const FreelancerPage({Key? key}) : super(key: key);

  @override
  State<FreelancerPage> createState() => _FreelancerPageState();
}

int _currentIndex = 0;

class _FreelancerPageState extends State<FreelancerPage> {
  String _loggedInImage = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _freelancers = [];
bool showSearchBar = false;
  TextEditingController searchController = TextEditingController();

 final Algolia algolia = Algolia.init(
    applicationId: 'PTLT3VDSB8',
    apiKey: '6236d82b883664fa54ad458c616d39ca',
  );

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchFreelancers();
  }

  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  searchController.addListener(onSearchTextChanged);
}

void onSearchTextChanged() {
  fetchFreelancers();
}

  // Fetch user data for the logged-in user
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
  List<String> searchFreelancerIds = [];

Future<List<String>> searchOldReportAlgolia() async {
  final AlgoliaQuerySnapshot response = await algolia
      .instance
      .index('RegularUser_index')
      .query(searchController.text)
      .facetFilter('userType:Freelancer')
      .getObjects();

searchFreelancerIds.clear();

  final List<AlgoliaObjectSnapshot> hits = response.hits;
  final List<String> objectIDs =
      hits.map((snapshot) => snapshot.objectID).toList();

searchFreelancerIds.addAll(objectIDs);

  return searchFreelancerIds;
}

  // Fetch freelancers data
Future<void> fetchFreelancers() async {
  if (searchController.text.isNotEmpty) {
    if (searchFreelancerIds.isNotEmpty) {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('RegularUser')
          .where('userType', isEqualTo: 'Freelancer')
          .where(FieldPath.documentId, whereIn: searchFreelancerIds)
          .get();

      final List<Map<String, dynamic>> freelancers =
          snapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        _freelancers = freelancers;
      });
    } else {
      setState(() {
        _freelancers = []; // Clear the freelancers list when the searchFreelancerIds list is empty
      });
    }
  } else {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('RegularUser')
        .where('userType', isEqualTo: 'Freelancer')
        .get();

    final List<Map<String, dynamic>> freelancers =
        snapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      _freelancers = freelancers;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBarUser(),
      appBar:AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: Color.fromARGB(255, 242, 241, 243),
  elevation: 0,
  iconTheme: IconThemeData(
    color: Color.fromRGBO(37, 6, 81, 0.898),
  ),
  toolbarHeight: 100,
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
            Expanded(
              child: Row(
                children: [
                  Text(
                    "Freelancers",
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: "Poppins",
                      color: Color.fromRGBO(0, 0, 0, 0.894),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        showSearchBar = !showSearchBar;
                      });
                    },
                    icon: Icon(
                      showSearchBar ? Icons.search_off : Icons.search,
                    ),
                  ),
                ],
              ),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                isDense: false,
              ),
              style: TextStyle(color: Colors.black, fontSize: 14.0),
              onChanged: (text) {
                setState(() {
                  // Perform search or filtering based on the entered text
                  searchOldReportAlgolia();
                });
              },
            ),
          ),
      ],
    ),
  ),
),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child:  _freelancers.isEmpty
      ? Center(
          child: Text(
            'No freelancers',
            style: TextStyle(fontSize: 16),
          ),
        )
        :ListView.separated(
          itemCount: _freelancers.length,
          separatorBuilder: (context, index) => SizedBox(height: 10),
          itemBuilder: (context, index) {
            final freelancer = _freelancers[index];
            final username = freelancer['username'] as String;
            final imageURL = freelancer['imageURL'] as String;
            final skills = freelancer['skills'] as List<dynamic>;
            final userId = freelancer['email'] as String;
            final userScore = freelancer['userScore'];

            return Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromARGB(121, 235, 235, 235),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(imageURL),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (userId != null &&
                                    userId.isNotEmpty &&
                                    userId != "DeactivatedUser") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UserProfileView(userId: userId),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                username,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 24, 8, 53),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            const Icon(
                              Icons.verified,
                              color: Colors.deepPurple,
                              size: 19,
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                context
                                    .read<ProfileProvider>()
                                    .gotoChat(context, userId);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: const Icon(
                                  FontAwesomeIcons.solidMessage,
                                  color: Color.fromARGB(255, 135, 135, 135),
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Tooltip(
                              child: const Icon(
                                Icons.star_rounded,
                                color: Color.fromARGB(255, 209, 196, 25),
                                size: 19,
                              ),
                              message:
                                  'This is the total number of Upvote received \nfor positive interactions!',
                              padding: EdgeInsets.all(10),
                              showDuration: Duration(seconds: 3),
                              textStyle: TextStyle(color: Colors.white),
                              preferBelow: false,
                            ),
                            Tooltip(
                              child: Text(userScore.toString()),
                              message:
                                  'This is the total number of Upvote received \nfor positive interactions!',
                              padding: EdgeInsets.all(10),
                              showDuration: Duration(seconds: 3),
                              textStyle: TextStyle(color: Colors.white),
                              preferBelow: false,
                            ),
                          ],
                        ),
                        Container(
                          width:
                              280, // Set a fixed width for the skills container
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                skills.length,
                                (skillIndex) {
                                  final skill = skills[skillIndex] as String;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: Chip(
                                      label: Text(
                                        skill,
                                        style: TextStyle(fontSize: 12.0),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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
