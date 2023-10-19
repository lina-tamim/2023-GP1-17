/*import 'dart:developer';
//
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/pages/cardFandT.dart';
import 'package:techxcel11/pages/cardQuestion.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techxcel11/pages/cardanswer.dart';
import 'package:techxcel11/pages/answer.dart';
import 'package:techxcel11/pages/reuse.dart';
import 'form.dart';
import 'package:intl/intl.dart';

class UserPostsPage extends StatefulWidget {
  final String userId;
  const UserPostsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserPostsPageState createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
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

  // bool showSearchBar = false;
  //
  // TextEditingController searchController = TextEditingController();

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
          .where('dropdownValue', isEqualTo: 'Question')
          // .orderBy('postedDate', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        final questions = snapshot.docs
            .map((doc) => CardQuestion.fromJson(doc.data()))
            .toList();
        final userIds = questions.map((question) => question.userId).toList();
        final userDocs = await FirebaseFirestore.instance
            .collection('users')
            .where('email', whereIn: userIds)
            .get();

        final userMap = Map<String, String>.fromEntries(userDocs.docs.map(
            (doc) => MapEntry(doc.data()['email'] as String,
                doc.data()['userName'] as String)));

        questions.forEach((question) {
          final username = userMap[question.userId] ?? '';
          question.username = username;
        });

        return questions;
      });

  Widget buildQuestionCard(CardQuestion question) => Card(
        child: ListTile(
          leading: CircleAvatar(
              //backgroundImage: NetworkImage(question.userPhotoUrl),
              ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Text(
                question.username, // Display the username
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
                  PostDeleteButton(docId: question.docId)
                ],
              ),
            ],
          ),
        ),
      );

//team collab

  Stream<List<CardFT>> readTeam() => FirebaseFirestore.instance
          .collection('posts')
          .where('dropdownValue', isEqualTo: 'Team Collaberation')
          .snapshots()
          .asyncMap((snapshot) async {
        final team =
            snapshot.docs.map((doc) => CardFT.fromJson(doc.data())).toList();
        final userIds = team.map((team) => team.userId).toList();
        final userDocs = await FirebaseFirestore.instance
            .collection('users')
            .where('email', whereIn: userIds)
            .get();

        final userMap = Map<String, String>.fromEntries(userDocs.docs.map(
            (doc) => MapEntry(doc.data()['email'] as String,
                doc.data()['userName'] as String)));

        team.forEach((team) {
          final username = userMap[team.userId] ?? '';
          team.username = username;
        });

        return team;
      });

  Stream<List<CardFT>> readProjects() => FirebaseFirestore.instance
          .collection('posts')
          .where('dropdownValue', isEqualTo: 'Project')
          .snapshots()
          .asyncMap((snapshot) async {
        final project =
            snapshot.docs.map((doc) => CardFT.fromJson(doc.data())).toList();
        final userIds = project.map((project) => project.userId).toList();
        final userDocs = await FirebaseFirestore.instance
            .collection('users')
            .where('email', whereIn: userIds)
            .get();

        final userMap = Map<String, String>.fromEntries(userDocs.docs.map(
            (doc) => MapEntry(doc.data()['email'] as String,
                doc.data()['userName'] as String)));

        project.forEach((project) {
          final username = userMap[project.userId] ?? '';
          project.username = username;
        });

        return project;
      });
  Stream<List<CardAnswer>> readAnswer() => FirebaseFirestore.instance
          .collection('answers')
          .where('userId', isEqualTo: widget.userId)
          .snapshots()
          .asyncMap((snapshot) async {
        final project = snapshot.docs
            .map((doc) => CardAnswer.fromJson(doc.data()))
            .toList();
        final userIds = project.map((project) => project.userId).toList();
        final userDocs = await FirebaseFirestore.instance
            .collection('users')
            .where('email', whereIn: userIds)
            .get();

        final userMap = Map<String, String>.fromEntries(userDocs.docs.map(
            (doc) => MapEntry(doc.data()['email'] as String,
                doc.data()['userName'] as String)));

        project.forEach((project) {
          final username = userMap[project.userId] ?? '';
          project.username = username;
        });

        return project;
      });

  Widget buildTeamCard(CardFT team) {
    final formattedDate =
        DateFormat.yMMMMd().format(team.date); // Format the date

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
                //backgroundImage: NetworkImage(question.userPhotoUrl),
                ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.username, // Display the username
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
          PostDeleteButton(docId: team.docId),
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
        backgroundColor: Color.fromARGB(255, 251, 246, 247),
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
                    'My Interactions',
                    style: TextStyle(
                      fontSize: 18, // Adjust the font size
                      fontFamily: "Poppins",
                      color: Colors.white,
                    ),
                  ),
                  // Spacer(),
                  // IconButton(
                  //     onPressed: () {
                  //       setState(() {
                  //         showSearchBar = !showSearchBar;
                  //       });
                  //     },
                  //     icon:
                  //         Icon(showSearchBar ? Icons.search_off : Icons.search))
                ],
              ),
              // SizedBox(
              //   height: 0,
              // ),
              // if (showSearchBar)
              //   TextField(
              //     controller: searchController,
              //     decoration: InputDecoration(
              //       hintText: 'Search...',
              //       prefixIcon: Icon(Icons.search),
              //       contentPadding: EdgeInsets.symmetric(
              //         vertical: 0,
              //       ),
              //       isDense: true,
              //     ),
              //     onChanged: (text) {
              //       setState(() {});
              //       // Handle search input changes
              //     },
              //   ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Question'),
              Tab(text: 'Answers'),
              Tab(text: 'Collaberation Request'),
              Tab(text: 'Projects'),
            ],
          ),
        ),

        drawer: NavBarUser(),

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _toggleFormVisibility();
          },
          backgroundColor: Color.fromARGB(255, 0, 5, 109),
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
              StreamBuilder<List<CardAnswer>>(
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

  Widget buildAnswerCard(CardAnswer answer) {
    int upvoteCount = answer.upvoteCount ?? 0;
    bool isUpvoted = false;

//answer.upvotedUserIds.contains(currentUserId);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
            //backgroundImage: NetworkImage(question.userPhotoUrl),
            ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              answer.username, // Display the username
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
                IconButton(
                  //icon: Icon(isUpvoted ? Icons.arrow_downward : Icons.arrow_circle_up),
                  icon: Icon(Icons.arrow_circle_up),
                  onPressed: () {
                    setState(() {
                      if (isUpvoted == true) {
                        // Undo the upvote
                        upvoteCount--;
                        print("**IM INSIDE ISUPVOTED**");
                        isUpvoted = false;
                        print("**I changed flag to ** $isUpvoted");
                        //answer.upvotedUserIds.remove(currentUserId);
                      } else if (isUpvoted == false) {
                        // Perform the upvote
                        upvoteCount++;
                        print("**IM OUTSIDE ISUPVOTED**");
                        isUpvoted = true;
                        print("**I changed flag to ** $isUpvoted");
                        //answer.upvotedUserIds.add(currentUserId);
                      }

                      // Update the upvote count and upvoted user IDs in Firestore
                      FirebaseFirestore.instance
                          .collection('answers')
                          .doc(answer.answerId)
                          .update({'upvoteCount': upvoteCount})
                          //'upvotedUserIds': answer.upvotedUserIds
                          .then((_) {
                        print('Upvote count updated successfully');
                      }).catchError((error) {
                        print('Failed to update upvote count: $error');
                        // Handle error if the update fails
                      });
                    });
                  },
                ),
                Text('Upvotes: $upvoteCount'),
                PostDeleteButton(
                  docId: answer.docId,
                  type: 'answer',
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
}*/