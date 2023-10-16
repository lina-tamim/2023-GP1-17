import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/pages/cardFandT.dart';
import 'package:techxcel11/pages/cardQuestion.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techxcel11/pages/answer.dart';
import 'package:techxcel11/pages/reuse.dart';
import 'form.dart';

class FHomePage extends StatefulWidget {
  const FHomePage({Key? key}) : super(key: key);

  @override
  __FHomePageState createState() => __FHomePageState();
}

class __FHomePageState extends State<FHomePage> {
  Future<String> fetchusername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    return username;
  }

  bool showSearchBar = false;

  TextEditingController searchController = TextEditingController();

  Future<int> getPostCount(String dropdownValue) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('dropdownvalue', isEqualTo: dropdownValue)
        .get();

    return snapshot.size;
  }

  void _toggleFormVisibility() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormWidget()),
    );
  }

  Stream<List<CardQuestion>> readQuestion() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('dropdownValue', isEqualTo: 'Question')
        .where('largeTextFieldValue',
            isGreaterThanOrEqualTo: searchController.text)
        .where('largeTextFieldValue',
            isLessThanOrEqualTo: searchController.text + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data();
              data['docId'] = doc.id;
              return CardQuestion.fromJson(data);
            }).toList());
  }

  Widget buildQuestionCard(CardQuestion question) => Card(
        child: FutureBuilder<String>(
          future: fetchusername(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final username = snapshot.data ?? '';
              return Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircleAvatar(
                            //backgroundImage: NetworkImage(question.userPhotoUrl),
                            ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text(question.title),
                    subtitle: Text(question.description),
                  ),
                  Wrap(
                    spacing: 4.0,
                    runSpacing: 2.0,
                    children: question.topics
                        .map(
                          (topic) => Chip(
                            label: Text(
                              topic,
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.bookmark),
                        // Replace `icon1` with the desired icon
                        onPressed: () {
                          // Add your functionality for the button here
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.comment),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AnswerPage(questionId: question.id)),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.report),
                        // Replace `icon4` with the desired icon
                        onPressed: () {
                          // Add your functionality for the button here
                        },
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      );

//team collab

  Stream<List<CardFT>> readTeam() => FirebaseFirestore.instance
      .collection('posts')
      .where('dropdownValue', isEqualTo: 'Team Collab')
      .where('textFieldValue', isGreaterThanOrEqualTo: searchController.text)
      .where('textFieldValue',
          isLessThanOrEqualTo: searchController.text + '\uf8ff')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['docId'] = doc.id;
            return CardFT.fromJson(data);
          }).toList());

  Stream<List<CardFT>> readProject() => FirebaseFirestore.instance
      .collection('posts')
      .where('dropdownValue', isEqualTo: 'Freelancer')
      .where('textFieldValue', isGreaterThanOrEqualTo: searchController.text)
      .where('textFieldValue',
          isLessThanOrEqualTo: searchController.text + '\uf8ff')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['docId'] = doc.id;
            return CardFT.fromJson(data);
          }).toList());

  Widget buildTeamCard(CardFT fandT) => Card(
        child: FutureBuilder<String>(
          future: fetchusername(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final username = snapshot.data ?? '';
              return Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircleAvatar(
                            //backgroundImage: NetworkImage(question.userPhotoUrl),
                            ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text(fandT.title),
                    subtitle: Text(fandT.description),
                  ),
                  Wrap(
                    spacing: 4.0,
                    runSpacing: 2.0,
                    children: fandT.topics
                        .map(
                          (topic) => Chip(
                            label: Text(
                              topic,
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.bookmark),
                        // Replace `icon1` with the desired icon
                        onPressed: () {
                          // Add your functionality for the button here
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.comment),
                        // Replace `icon2` with the desired icon
                        onPressed: () {
                          // Add your functionality for the button here
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.report),
                        // Replace `icon4` with the desired icon
                        onPressed: () {
                          // Add your functionality for the button here
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.chat_bubble),
                        // Replace `icon4` with the desired icon
                        onPressed: () {
                          // Add your functionality for the button here
                        },
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade200,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'Deadline: ${fandT.date}',
                              // Replace with the actual deadline date
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(248, 241, 243, 1),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          iconTheme:
              IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
          backgroundColor: Color.fromRGBO(37, 6, 81, 0.898),
          toolbarHeight: 100,
          // Adjust the height of the AppBar
          elevation: 0,
          // Adjust the position of the AppBar
          shape: ContinuousRectangleBorder(
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
                        icon: Icon(Icons.menu));
                  }),
                  Text(
                    'Homepage',
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
                      icon:
                          Icon(showSearchBar ? Icons.search_off : Icons.search))
                ],
              ),
              SizedBox(
                height: 0,
              ),
              if (showSearchBar)
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                    ),
                    isDense: true,
                  ),
                  onChanged: (text) {
                    setState(() {});
                    // Handle search input changes
                  },
                ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Question'),
              Tab(text: 'Collaberation Request'),
              Tab(text: 'Projects'),
            ],
          ),
        ),

        drawer: NavBarUser(
            // Drawer content here
            ),

       /* bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: const Color.fromRGBO(248, 241, 243, 1),
          color: const Color.fromARGB(255, 237, 212, 242),
          animationDuration: const Duration(milliseconds: 300),
          onTap: (index) {
            // Use it to navigate to different pages
          },
          items: const [
            Icon(Icons.home),
            Icon(Icons.work),
            Icon(Icons.book),
            Icon(Icons.chat_bubble),
          ],
        ),*/

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _toggleFormVisibility();
          },
          backgroundColor: Colors.purple,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        //CARDS DISPLAY

        body: TabBarView(
          children: [
            // Display Question Cards
            StreamBuilder<List<CardQuestion>>(
              stream: readQuestion(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final q = snapshot.data!;
                  if (q.isEmpty) {
                    return Center(
                      child: Text(searchController.text.isNotEmpty
                          ? 'No matches found'
                          : 'No posts found'),
                    );
                  }
                  return ListView(
                    children: q.map(buildQuestionCard).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),

            StreamBuilder<List<CardFT>>(
              stream: readTeam(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final t = snapshot.data!;
                  if (t.isEmpty) {
                    return Center(
                      child: Text(searchController.text.isNotEmpty
                          ? 'No matches found'
                          : 'No posts found'),
                    );
                  }
                  return ListView(
                    children: t.map(buildTeamCard).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),

            StreamBuilder<List<CardFT>>(
              stream: readProject(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final p = snapshot.data!;
                  if (p.isEmpty) {
                    return Center(
                      child: Text(searchController.text.isNotEmpty
                          ? 'No matches found'
                          : 'No posts found'),
                    );
                  }
                  return ListView(
                    children: p.map(buildTeamCard).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
