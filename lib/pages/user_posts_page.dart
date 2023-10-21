import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/models/cardFTview.dart';
import 'package:techxcel11/models/cardQview.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techxcel11/models/cardAview.dart';
import 'package:techxcel11/pages/answer.dart';
import 'package:techxcel11/pages/reuse.dart';
import '../models/cardFandT.dart';
import '../models/cardQuestion.dart';
import 'form.dart';

class UserPostsPage extends StatefulWidget {
  const UserPostsPage({Key? key}) : super(key: key);

  @override
  _UserPostsPageState createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  int _currentIndex = 0;

  String? email;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('loggedInEmail');
      setState(() {
        this.email = email;
        log('MK: user email is $email');
      });
    });
    super.initState();
  }

  Future<String> fetchusername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    return username;
  }

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

  Stream<List<CardQuestion>> readQuestion() => FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: email)
          .where('dropdownValue', isEqualTo: 'Question')
          .orderBy('postedDate', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        final questions = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['docId'] = doc.id;
          return CardQuestion.fromJson(data);
        }).toList();
        final userIds = questions.map((question) => question.userId).toList();
        final userDocs = await FirebaseFirestore.instance
            .collection('users')
            .where('email', whereIn: userIds)
            .get();

        final userMap = Map<String, Map<String, dynamic>>.fromEntries(
            userDocs.docs.map((doc) => MapEntry(doc.data()['email'] as String,
                doc.data() as Map<String, dynamic>)));

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
          .where('userId', isEqualTo: email)
          .where('dropdownValue', isEqualTo: 'Team Collaberation')
          .orderBy('postedDate', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        final questions = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['docId'] = doc.id;
          return CardFT.fromJson(data);
        }).toList();
        final userIds = questions.map((question) => question.userId).toList();
        final userDocs = await FirebaseFirestore.instance
            .collection('users')
            .where('email', whereIn: userIds)
            .get();

        final userMap = Map<String, Map<String, dynamic>>.fromEntries(
            userDocs.docs.map((doc) => MapEntry(doc.data()['email'] as String,
                doc.data() as Map<String, dynamic>)));

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
          .where('userId', isEqualTo: email)
          .where('dropdownValue', isEqualTo: 'Freelancer')
          .snapshots()
          .asyncMap((snapshot) async {
        final questions = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['docId'] = doc.id;
          return CardFT.fromJson(data);
        }).toList();
        final userIds = questions.map((question) => question.userId).toList();
        final userDocs = await FirebaseFirestore.instance
            .collection('users')
            .where('email', whereIn: userIds)
            .get();

        final userMap = Map<String, Map<String, dynamic>>.fromEntries(
            userDocs.docs.map((doc) => MapEntry(doc.data()['email'] as String,
                doc.data() as Map<String, dynamic>)));

        questions.forEach((question) {
          final userDoc = userMap[question.userId];
          final username = userDoc?['f'] as String? ?? '';
          final userPhotoUrl = userDoc?['imageUrl'] as String? ?? '';
          question.username = username;
          question.userPhotoUrl = userPhotoUrl;
        });

        return questions;
      });

  Stream<List<CardAview>> myAnswers() => FirebaseFirestore.instance
      .collection('answers')
      .where('userId', isEqualTo: email)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['docId'] = doc.id;
            return CardAview.fromJson(data);
          }).toList());

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
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
          elevation: 0,
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
                    'My Interactions',
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
                    color: Color.fromARGB(255, 245, 227, 255),
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Answers',
                  style: TextStyle(
                    color: Color.fromARGB(255, 245, 227, 255),
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Build Team',
                  style: TextStyle(
                    color: Color.fromARGB(255, 245, 227, 255),
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Projects',
                  style: TextStyle(
                    color: Color.fromARGB(255, 245, 227, 255),
                  ),
                ),
              ),
            ],
          ),
        ),

        //drawer: NavBar(),

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
            if (email == null || email == '')
              SizedBox()
            else
              // Display Question Cards
              StreamBuilder<List<CardQuestion>>(
                stream: readQuestion(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final q = snapshot.data!;
                    if (q.isEmpty) {
                      return Center(
                        child: Text('You didn’t post anything yet'),
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
            if (email == null || email == '')
              SizedBox()
            else
              StreamBuilder<List<CardAview>>(
                stream: myAnswers(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final p = snapshot.data!;
                    if (p.isEmpty) {
                      return Center(
                        child: Text('You didn’t post any answers yet'),
                      );
                    }
                    return ListView(
                      children: p.map(buildAnswerCard).toList(),
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
            if (email == null || email == '')
              SizedBox()
            else
              StreamBuilder<List<CardFT>>(
                stream: readTeam(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final t = snapshot.data!;
                    if (t.isEmpty) {
                      return Center(
                        child: Text('You didn’t post anything yet'),
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
            if (email == null || email == '')
              SizedBox()
            else
              StreamBuilder<List<CardFT>>(
                stream: readProjects(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final p = snapshot.data!;
                    if (p.isEmpty) {
                      return Center(
                        child: Text('You didn’t post anything yet'),
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

  Widget buildAnswerCard(CardAview answer) {
    int upvoteCount = answer.upvoteCount ?? 0;
    bool isUpvoted = false; // Track the upvote state

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AnswerPage(questionId: answer.questionId)),
        );
      },
      child: Card(
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
                        child: CircleAvatar(),
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
                    title: Text(answer.answerText),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Text('$upvoteCount'),
                          IconButton(
                            icon: Icon(isUpvoted
                                ? Icons.arrow_downward
                                : Icons.arrow_upward),
                            onPressed: () {
                              setState(() {
                                if (isUpvoted) {
                                  // Decrement the upvote count
                                  upvoteCount--;

                                  // Update the upvote count in Firestore
                                  FirebaseFirestore.instance
                                      .collection('answers')
                                      .doc(answer.answerId)
                                      .update({
                                    'upvoteCount': FieldValue.increment(-1)
                                  }).then((_) {
                                    print(
                                        'Upvote count decremented successfully');
                                  }).catchError((error) {
                                    print(
                                        'Failed to decrement upvote count: $error');
                                    // Handle error if the update fails
                                  });
                                } else {
                                  // Increment the upvote count
                                  upvoteCount++;

                                  // Update the upvote count in Firestore
                                  FirebaseFirestore.instance
                                      .collection('answers')
                                      .doc(answer.answerId)
                                      .update({
                                    'upvoteCount': FieldValue.increment(1)
                                  }).then((_) {
                                    print(
                                        'Upvote count incremented successfully');
                                  }).catchError((error) {
                                    print(
                                        'Failed to increment upvote count: $error');
                                    // Handle error if the update fails
                                  });
                                }

                                // Toggle the upvote state
                                isUpvoted = !isUpvoted;
                              });
                            },
                          ),
                        ],
                      ),
                      PostDeleteButton(
                        docId: answer.docId,
                        type: 'answer',
                      ),
                      IconButton(
                        icon: Icon(Icons.report),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class PostDeleteButton extends StatelessWidget {
  const PostDeleteButton({super.key, required this.docId, this.type = 'post'});

  final String docId;
  final String type;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: Colors.red,
      icon: Icon(Icons.delete),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Deletion'),
              content: Text('Are you sure you want to delete this $type?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    // Delete the document here
                    await FirebaseFirestore.instance
                        .collection(type == 'answer' ? 'answers' : 'posts')
                        .doc(docId)
                        .delete();
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

void _showSnackBar(BuildContext context, String message) {
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
