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
import 'form.dart';

class UserPostsPage extends StatefulWidget {
  const UserPostsPage({Key? key}) : super(key: key);

  @override
  _UserPostsPageState createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  int _currentIndex = 0;

  Future<String> fetchuseremail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final emaill = prefs.getString('loggedInEmail') ?? '';
    return emaill;
  }

  String? email;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('loggedInEmail');
      setState(() {
        this.email = email;
        log('******************************MK: user email is $email');
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

  Stream<List<CardQview>> readQuestion() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('dropdownValue', isEqualTo: 'Question')
        .where('userId', isEqualTo: email)
        .snapshots()
        .asyncMap((snapshot) async {
      final questions = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['docId'] = doc.id;
        return CardQview.fromJson(data);
      }).toList();
      if (questions.isEmpty) return [];
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
  }

  Widget buildQuestionCard(CardQview question) => Card(
        child: ListTile(
          leading: CircleAvatar(
            // ignore: unnecessary_null_comparison
            backgroundImage: question.userPhotoUrl != null
                ? NetworkImage(question.userPhotoUrl!)
                : null,
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
                  PostDeleteButton(docId: question.docId),
                ],
              ),
            ],
          ),
        ),
      );

//team collab
  Stream<List<CardFTview>> readTeam() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('dropdownValue', isEqualTo: 'Team Collaberation')
        .where('userId', isEqualTo: email)
        .snapshots()
        .asyncMap((snapshot) async {
      final questions = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['docId'] = doc.id;
        return CardFTview.fromJson(data);
      }).toList();
      if (questions.isEmpty) return [];
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
  }

  Stream<List<CardFTview>> readProject() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('dropdownValue', isEqualTo: 'Project')
        .where('userId', isEqualTo: email)
        .snapshots()
        .asyncMap((snapshot) async {
      final questions = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['docId'] = doc.id;
        return CardFTview.fromJson(data);
      }).toList();
      if (questions.isEmpty) return [];
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
  }

  Stream<List<CardAview>> readAnswer() => FirebaseFirestore.instance
          .collection('answers')
          .where('userId', isEqualTo: email)
          .snapshots()
          .asyncMap((snapshot) async {
        final answers = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['docId'] = doc.id;
          return CardAview.fromJson(data);
        }).toList();
        if (answers.isEmpty) return [];
        final userIds = answers.map((answer) => answer.userId).toList();
        final userDocs = await FirebaseFirestore.instance
            .collection('users')
            .where('email', whereIn: userIds)
            .get();

        final userMap = Map<String, Map<String, dynamic>>.fromEntries(
            userDocs.docs.map((doc) => MapEntry(doc.data()['email'] as String,
                doc.data() as Map<String, dynamic>)));

        answers.forEach((answer) {
          final userDoc = userMap[answer.userId];
          final username = userDoc?['userName'] as String? ?? '';
          final userPhotoUrl = userDoc?['imageUrl'] as String? ?? '';
          answer.username = username;
          answer.userPhotoUrl = userPhotoUrl;
        });

        return answers;
      });

  Widget buildTeamCard(CardFTview fandT) {
    final formattedDate =
        DateFormat.yMMMMd().format(fandT.date); // Format the date

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          // ignore: unnecessary_null_comparison
          backgroundImage: fandT.userPhotoUrl != null
              ? NetworkImage(fandT.userPhotoUrl!)
              : null,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              fandT.username ?? '', // Display the username
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            SizedBox(height: 5),
            Text(
              fandT.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(fandT.description),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  icon: Icon(Icons.chat_bubble),
                  onPressed: () {
                    // Add your functionality for the button here
                  },
                ),
                PostDeleteButton(docId: fandT.docId),
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
          ],
        ),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () async {
            _toggleFormVisibility();
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
            if (email == null || email == '')
              SizedBox()
            else
              // Display Question Cards
              StreamBuilder<List<CardQview>>(
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
                stream: readAnswer(),
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
              StreamBuilder<List<CardFTview>>(
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
              StreamBuilder<List<CardFTview>>(
                stream: readProject(),
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
    String currentEmail = '';

    Future<String> getCurrentUserEmail() async {
      return await fetchuseremail();
    }

    int upvoteCount = answer.upvoteCount ?? 0;
    List<String> upvotedUserIds = answer.upvotedUserIds ?? [];

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: answer.userPhotoUrl != null
              ? NetworkImage(answer.userPhotoUrl!)
              : null, // Handle null value
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              answer.username ?? '', // Display the username
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            SizedBox(height: 5),
            ListTile(
              title: Text(answer.answerText),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FutureBuilder<String>(
                  future: getCurrentUserEmail(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show a loading indicator while retrieving the email
                    } else if (snapshot.hasError) {
                      return Text(
                          'Error: ${snapshot.error}'); // Show an error message if email retrieval fails
                    } else {
                      currentEmail = snapshot.data!;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(upvotedUserIds.contains(currentEmail)
                                ? Icons.arrow_circle_down
                                : Icons.arrow_circle_up),
                            onPressed: () {
                              setState(() {
                                if (upvotedUserIds.contains(currentEmail)) {
                                  // Undo the upvote
                                  upvotedUserIds.remove(currentEmail);
                                  upvoteCount--;
                                } else {
                                  // Perform the upvote
                                  upvotedUserIds.add(currentEmail);
                                  upvoteCount++;
                                }

                                // Update the upvote count and upvoted user IDs in Firestore
                                FirebaseFirestore.instance
                                    .collection('answers')
                                    .doc(answer.answerId)
                                    .update({
                                  'upvoteCount': upvoteCount,
                                  'upvotedUserIds': upvotedUserIds,
                                }).then((_) {
                                  print('Upvote count updated successfully');
                                }).catchError((error) {
                                  print(
                                      'Failed to update upvote count: $error');
                                  // Handle error if the update fails
                                });
                              });
                            },
                          ),
                          Text('Upvotes: $upvoteCount'),
                          SizedBox(
                            width: 20,
                          ),
                          PostDeleteButton(
                            docId: answer.docId,
                            type: 'answer',
                          )
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PostDeleteButton extends StatelessWidget {
  const PostDeleteButton({super.key, required this.docId, this.type = 'post'});

  final String? docId;
  final String type;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: Colors.red,
      icon: Icon(Icons.delete),
      onPressed: () {
        if (docId == null || docId == '') {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unable to delete this $type')));
        } else {
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
        }
      },
    );
  }
}
