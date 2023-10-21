import 'dart:io';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/models/cardFandT.dart';
import 'package:techxcel11/models/cardQuestion.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techxcel11/pages/answer.dart';
import 'package:techxcel11/pages/reuse.dart';
import 'form.dart'; //

class FHomePage extends StatefulWidget {
  const FHomePage({Key? key}) : super(key: key);

  @override
  __FHomePageState createState() => __FHomePageState();
}

int _currentIndex = 0;

class __FHomePageState extends State<FHomePage> {
  void _toggleFormVisibility() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormWidget()),
    );
  }

Stream<List<CardQuestion>> readQuestion() => FirebaseFirestore.instance
    .collection('posts')
    .where('dropdownValue', isEqualTo: 'Question')
    .orderBy('postedDate', descending: true)
    .snapshots()
    .asyncMap((snapshot) async {
      final questions = snapshot.docs
          .map((doc) => CardQuestion.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      final userIds = questions.map((question) => question.userId).toList();
      final userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('email', whereIn: userIds)
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(userDocs.docs.map(
          (doc) => MapEntry(doc.data()['email'] as String, doc.data() as Map<String, dynamic>)));

      questions.forEach((question) {
        final userDoc = userMap[question.userId];
        final username = userDoc?['userName'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageUrl'] as String? ?? '';
        question.username = username;
        question.userPhotoUrl = userPhotoUrl;
      });

      return questions;
    });
Stream<List<CardFT>> readTeam() => FirebaseFirestore.instance
    .collection('posts')
    .where('dropdownValue', isEqualTo: 'Team Collaberation')
    .orderBy('postedDate', descending: true)
    .snapshots()
    .asyncMap((snapshot) async {
      final questions = snapshot.docs
          .map((doc) => CardFT.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      final userIds = questions.map((question) => question.userId).toList();
      final userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('email', whereIn: userIds)
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(userDocs.docs.map(
          (doc) => MapEntry(doc.data()['email'] as String, doc.data() as Map<String, dynamic>)));

      questions.forEach((question) {
        final userDoc = userMap[question.userId];
        final username = userDoc?['userName'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageUrl'] as String? ?? '';
        question.username = username;
        question.userPhotoUrl = userPhotoUrl;
      });

      return questions;
    });
    
Stream<List<CardFT>> readProjects() => FirebaseFirestore.instance
    .collection('posts')
    .where('dropdownValue', isEqualTo: 'Project')
    .orderBy('postedDate', descending: true)
    .snapshots()
    .asyncMap((snapshot) async {
      final questions = snapshot.docs
          .map((doc) => CardFT.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      final userIds = questions.map((question) => question.userId).toList();
      final userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('email', whereIn: userIds)
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(userDocs.docs.map(
          (doc) => MapEntry(doc.data()['email'] as String, doc.data() as Map<String, dynamic>)));

      questions.forEach((question) {
        final userDoc = userMap[question.userId];
        final username = userDoc?['userName'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageUrl'] as String? ?? '';
        question.username = username;
        question.userPhotoUrl = userPhotoUrl;
      });

      return questions;
    });

  Widget buildQuestionCard(CardQuestion question) => Card(
        child: ListTile(
            leading: CircleAvatar(
          backgroundImage: question.userPhotoUrl != null
              ? NetworkImage(question.userPhotoUrl!)
              : null, // Handle null value
        ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Text(
                question.username ?? '', // Display the username
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.deepPurple),
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
                    onPressed: () {
                      // Add your functionality for the button here
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  Widget buildTeamCard(CardFT team) {
    final formattedDate =
        DateFormat.yMMMMd().format(team.date); // Format the date

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
          backgroundImage: team.userPhotoUrl != null
              ? NetworkImage(team.userPhotoUrl!)
              : null, // Handle null value
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
                icon: Icon(Icons.bookmark),
                onPressed: () {
                  // Add your functionality for the button here
                },
              ),
              IconButton(
                icon: Icon(Icons.comment),
                onPressed: () {
                  // Add your functionality for the button here
                },
              ),
              IconButton(
                icon: Icon(Icons.report),
                onPressed: () {
                  // Add your functionality for the button here
                },
              ),
              IconButton(
                icon: Icon(Icons.chat_rounded),
                onPressed: () {
                  // Add your functionality for the button here
                },
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.purple.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              'Deadline: $formattedDate', // Use the formatted date
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
          toolbarHeight: 100, // Adjust the height of the AppBar
          elevation: 0, // Adjust the position of the AppBar
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
                    'Homepage ',
                    style: TextStyle(
                      fontSize: 18, // Adjust the font size
                      fontFamily: "Poppins",
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottom: const TabBar(
            indicator: BoxDecoration(),
            tabs: [
              Tab(
                child: Text(
                  'Question',
                  style: TextStyle(
                    color: Color.fromARGB(
                        255, 245, 227, 255), // Set the desired color here
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Build Team',
                  style: TextStyle(
                    color: Color.fromARGB(
                        255, 245, 227, 255), // Set the desired color here
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Projects',
                  style: TextStyle(
                    color: Color.fromARGB(
                        255, 245, 227, 255), // Set the desired color here
                  ),
                ),
              ),
            ],
          ),
        ),

        

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _toggleFormVisibility();
          },
          backgroundColor: Color.fromARGB(255, 156, 147, 176),
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
                    child: Text('No Posts Yet '),
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
                    child: Text('No Posts Yet '),
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

//TECHXCEL-Lina 
