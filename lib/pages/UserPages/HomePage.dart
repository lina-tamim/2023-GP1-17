import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/Models/FormCard.dart';
import 'package:techxcel11/Models/PostCard.dart';
import 'package:techxcel11/Models/QuestionCard.dart';
import 'package:techxcel11/pages/UserPages/AnswerPage.dart';

class FHomePage extends StatefulWidget {
  const FHomePage({Key? key}) : super(key: key);

  @override
  __FHomePageState createState() => __FHomePageState();
}

int _currentIndex = 0;

class __FHomePageState extends State<FHomePage> {
  void _toggleFormVisibility() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormWidget()),
    );
  }

 bool showSearchBar = false;
 TextEditingController searchController = TextEditingController();



  void showInputDialog() {
    showAlertDialog(
      context,
      FormWidget(),
    );
  }

  Stream<List<CardQuestion>> readQuestion() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('Question');
    //.where('dropdownValue', isEqualTo: 'Question');

    if (searchController.text.isNotEmpty) {
      String searchText = searchController.text;
      query = query.where(
        FieldPath(['postDescription']),
        isGreaterThanOrEqualTo: searchText.toLowerCase(),
        isLessThanOrEqualTo: searchText.toLowerCase() + '\uf8ff',
      );
    } else {
      query = query.orderBy('postedDate', descending: true);
    }

    return query.snapshots().asyncMap((snapshot) async {
      final questions = snapshot.docs
          .map((doc) =>
              CardQuestion.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      if (questions.isEmpty) return [];

      final userIds = questions.map((question) => question.userId).toList();
      final userDocs = await FirebaseFirestore.instance
          .collection('RegularUser')
          .where('email', whereIn: userIds)
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(
          userDocs.docs.map((doc) => MapEntry(doc.data()['email'] as String,
              doc.data() as Map<String, dynamic>)));

      questions.forEach((question) {
        final userDoc = userMap[question.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';
        question.username = username;
        question.userPhotoUrl = userPhotoUrl;
      });

      final userIdsNotFound =
          userIds.where((userId) => !userMap.containsKey(userId)).toList();
      userIdsNotFound.forEach((userId) {
        questions.forEach((question) {
          if (question.userId == userId) {
            question.username = 'DeactivatedUser';
            question.userPhotoUrl = '';
          }
        });
      });

      return questions;
    });
  }

  Stream<List<CardFT>> readTeam() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('Team');
    //.where('dropdownValue', isEqualTo: 'Team Collaberation');

    if (searchController.text.isNotEmpty) {
      String searchText = searchController.text
          .toLowerCase(); // Convert search text to lowercase
      query = query
          .where('postTitle', isGreaterThanOrEqualTo: searchText)
          .where('postTitle', isLessThanOrEqualTo: searchText + '\uf8ff');
    } else {
      query = query.orderBy('postedDate', descending: true);
    }

    return query.snapshots().asyncMap((snapshot) async {
      final questions = snapshot.docs
          .map((doc) => CardFT.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      if (questions.isEmpty) return [];
      final userIds = questions.map((question) => question.userId).toList();
      final userDocs = await FirebaseFirestore.instance
          .collection('RegularUser')
          .where('email', whereIn: userIds)
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(
          userDocs.docs.map((doc) => MapEntry(doc.data()['email'] as String,
              doc.data() as Map<String, dynamic>)));

      questions.forEach((question) {
        final userDoc = userMap[question.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';
        question.username = username;
        question.userPhotoUrl = userPhotoUrl;
      });

      final userIdsNotFound =
          userIds.where((userId) => !userMap.containsKey(userId)).toList();
      userIdsNotFound.forEach((userId) {
        questions.forEach((question) {
          if (question.userId == userId) {
            question.username = 'DeactivatedUser';
            question.userPhotoUrl = '';
          }
        });
      });
      return questions;
    });
  }

  Stream<List<CardFT>> readProjects() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('Project');
    //.where('dropdownValue', isEqualTo: 'Project');

    if (searchController.text.isNotEmpty) {
      String searchText = searchController.text
          .toLowerCase(); // Convert search text to lowercase
      query = query
          .where('postTitle', isGreaterThanOrEqualTo: searchText)
          .where('postTitle', isLessThanOrEqualTo: searchText + '\uf8ff');
    } else {
      query = query.orderBy('postedDate', descending: true);
    }

    return query.snapshots().asyncMap((snapshot) async {
      final questions = snapshot.docs
          .map((doc) => CardFT.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      if (questions.isEmpty) return [];
      final userIds = questions.map((question) => question.userId).toList();
      final userDocs = await FirebaseFirestore.instance
          .collection('RegularUser')
          .where('email', whereIn: userIds)
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(
          userDocs.docs.map((doc) => MapEntry(doc.data()['email'] as String,
              doc.data() as Map<String, dynamic>)));

      questions.forEach((question) {
        final userDoc = userMap[question.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';
        question.username = username;
        question.userPhotoUrl = userPhotoUrl;
      });

      final userIdsNotFound =
          userIds.where((userId) => !userMap.containsKey(userId)).toList();
      userIdsNotFound.forEach((userId) {
        questions.forEach((question) {
          if (question.userId == userId) {
            question.username = 'DeactivatedUser';
            question.userPhotoUrl = '';
          }
        });
      });
      return questions;
    });
  }

  Widget buildQuestionCard(CardQuestion question) => Card(
        child: ListTile(
          leading: CircleAvatar(
            radius: 30, // Adjust the radius to make the avatar bigger
            backgroundImage: question.userPhotoUrl != ''
                ? NetworkImage(question.userPhotoUrl!)
                : const AssetImage('assets/Backgrounds/defaultUserPic.png')
                    as ImageProvider<Object>, // Cast to ImageProvider<Object>
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Text(
                question.username ?? '', // Display the username
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                    fontSize: 16),
              ),
              SizedBox(height: 5),
              Text(
                question.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(question.description),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    onPressed: () {
                      // Add functionality in upcoming sprints
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
                    onPressed: () {
                      // Add functionality in upcoming sprints
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget buildTeamCard(CardFT team) {
  DateTime deadlineDate = team.date as DateTime; 
  DateTime currentDate = DateTime.now();

    final formattedDate =
        DateFormat.yMMMMd().format(team.date); 

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: team.userPhotoUrl != ''
                  ? NetworkImage(team.userPhotoUrl!)
                  : const AssetImage('assets/Backgrounds/defaultUserPic.png')
                      as ImageProvider<Object>, // Cast to ImageProvider<Object>
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.username ?? '', // Display the username
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  team.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(team.description),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 4.0,
                  runSpacing: 2.0,
                  children: team.topics
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
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.solidMessage,
                  size: 18.5,
                ),
                onPressed: () {
                  // Add your functionality next sprints
                },
              ),
              IconButton(
                icon: Icon(Icons.report),
                onPressed: () {
                  // Add your functionality next sprints
                },
              ),
            ],
          ),
          Container(
              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: deadlineDate.isBefore(currentDate) ? Colors.red : Color.fromARGB(255, 11, 0, 135),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Deadline: $formattedDate', 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                ),
              ),
            ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

//team collab

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: const NavBarUser(),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
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
                  const Text(
                    'Homepage ',
                    style: TextStyle(
                      fontSize: 18, // Adjust the font size
                      fontFamily: "Poppins",
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
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
              const SizedBox(
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
                    // Handle search input changes
                  },
                ),
            ],
          ),
          bottom: const TabBar(
            indicator: BoxDecoration(),
            tabs: [
              Tab(
                child: Text(
                  'Questions',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(
                        255, 245, 227, 255), // Set the desired color here
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Build Team',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(
                        255, 245, 227, 255), // Set the desired color here
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Projects',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(
                        255, 245, 227, 255), // Set the desired color here
                  ),
                ),
              ),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () async {
            showInputDialog();
          },
          backgroundColor: Color.fromARGB(255, 156, 147, 176),
          child: const Icon(
            Icons.add,
            color: Color.fromARGB(255, 255, 255, 255),
            size: 25,
          ),
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
                      child: Text('No Posts Yet'),
                    );
                  }
                  return ListView(
                    children: q.map(buildQuestionCard).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error:${snapshot.error}'),
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
                      child: Text('No posts yet'),
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
              stream: readProjects(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final p = snapshot.data!;
                  if (p.isEmpty) {
                    return Center(
                      child: Text('No posts yet'),
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

 