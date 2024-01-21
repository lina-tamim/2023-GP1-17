import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techxcel11/Models/ViewAnswerCard.dart';
import 'package:techxcel11/pages/UserPages/AnswerPage.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/Models/FormCard.dart';
import 'package:techxcel11/Models/PostCardView.dart';
import 'package:techxcel11/Models/ViewQCard.dart';
import 'package:techxcel11/pages/UserPages/AnswerPage.dart';

class UserPostsPage extends StatefulWidget {
  const UserPostsPage({Key? key}) : super(key: key);

  @override
  _UserPostsPageState createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  int _currentIndex = 0;
  String loggedInEmail = '';
  String loggedImage = '';

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
      });
    });
    super.initState();
  }

  void showInputDialog() {
    showAlertDialog(
      context,
      FormWidget(),
    );
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
        .collection('Question')
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
                question.username ?? '',
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
                      // Add functionality next sprints
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
                  PostDeleteButton(docId: question.docId, type: 'question'),
                ],
              ),
            ],
          ),
        ),
      );
  Stream<List<CardFTview>> readTeam() {
    return FirebaseFirestore.instance
        .collection('Team')
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
          .collection('RegularUser')
          .where('email', whereIn: userIds)
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(
        userDocs.docs.map((doc) => MapEntry(
              doc.data()['email'] as String,
              doc.data() as Map<String, dynamic>,
            )),
      );

      questions.forEach((question) {
        final userDoc = userMap[question.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';
        question.username = username;
        question.userPhotoUrl = userPhotoUrl;
      });

      return questions;
    });
  }

  Stream<List<CardFTview>> readProject() {
    return FirebaseFirestore.instance
        .collection('Project')
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
          .collection('RegularUser')
          .where('email', whereIn: userIds)
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(
        userDocs.docs.map((doc) => MapEntry(
              doc.data()!['email'] as String,
              doc.data()! as Map<String, dynamic>,
            )),
      );

      questions.forEach((question) {
        final userDoc = userMap[question.userId];
        final username = userDoc?['username'] as String?;
        final userPhotoUrl = userDoc?['imageURL'] as String?;
        question.username = username ?? '';
        question.userPhotoUrl = userPhotoUrl ?? '';
      });

      return questions;
    });
  }

  Stream<List<CardAview>> readAnswer() => FirebaseFirestore.instance
          .collection('Answer')
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
            .collection('RegularUser')
            .where('email', whereIn: userIds)
            .get();

        final userMap = Map<String, Map<String, dynamic>>.fromEntries(
            userDocs.docs.map((doc) => MapEntry(doc.data()['email'] as String,
                doc.data() as Map<String, dynamic>)));

        answers.forEach((answer) {
          final userDoc = userMap[answer.userId];
          final username = userDoc?['username'] as String? ?? '';
          final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';
          answer.username = username;
          answer.userPhotoUrl = userPhotoUrl;
        });

        return answers;
      });

  Widget buildTeamCard(CardFTview fandT) {
    final formattedDate = DateFormat.yMMMMd().format(fandT.date);
    DateTime deadlineDate = fandT.date as DateTime;
    DateTime currentDate = DateTime.now();

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: fandT.userPhotoUrl != null
              ? NetworkImage(fandT.userPhotoUrl!)
              : null,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              fandT.username ?? '',
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
                  icon: Icon(Icons.chat_bubble),
                  onPressed: () {
                    // Add functionality next sprints
                  },
                ),
                PostDeleteButton(docId: fandT.docId, type: 'team'),
                SizedBox(height: 5),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: deadlineDate.isBefore(currentDate)
                      ? Colors.red
                      : Color.fromARGB(255, 11, 0, 135),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProjectCard(CardFTview fandT) {
    final formattedDate = DateFormat.yMMMMd().format(fandT.date);
    DateTime deadlineDate = fandT.date as DateTime;
    DateTime currentDate = DateTime.now();

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: fandT.userPhotoUrl != null
              ? NetworkImage(fandT.userPhotoUrl!)
              : null,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              fandT.username ?? '',
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
                  icon: Icon(Icons.chat_bubble),
                  onPressed: () {
                    // Add functionality next sprints
                  },
                ),
                PostDeleteButton(docId: fandT.docId, type: 'project'),
                SizedBox(height: 5),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: deadlineDate.isBefore(currentDate)
                      ? Colors.red
                      : Color.fromARGB(255, 11, 0, 135),
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
          iconTheme: IconThemeData(
            color: Color.fromRGBO(37, 6, 81, 0.898),
          ),
          toolbarHeight: 100,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Backgrounds/bg11.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Builder(
              builder: (context) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          // if (_loggedInImage.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: CircleAvatar(
                              radius: 25,
                              //backgroundImage: NetworkImage(_loggedInImage),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'My Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Poppins",
                              color: Color.fromRGBO(37, 6, 81, 0.898),
                            ),
                          ),
                          const SizedBox(width: 120),
                        ])
                      ])),
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
            // _toggleFormVisibility();
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
        body: TabBarView(
          children: [
            if (email == null || email == '')
              SizedBox()
            else
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
                      children: p.map(buildProjectCard).toList(),
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

    return GestureDetector(
      onTap: () {
        // Navigate to the Answer page when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnswerPage(questionId: answer.questionId),
          ),
        );
      },
      child: Card(
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
                                  answer.upvoteCount = upvoteCount;
                                  answer.upvotedUserIds = upvotedUserIds;
                                  // Update the upvote count and upvoted user IDs in Firestore
                                  FirebaseFirestore.instance
                                      .collection('Answer')
                                      .doc(answer.docId)
                                      .update({
                                        'upvoteCount': upvoteCount,
                                        'upvotedUserIds': upvotedUserIds,
                                      })
                                      .then((_) {})
                                      .catchError((error) {
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
      ),
    );
  }
}

class PostDeleteButton extends StatelessWidget {
  const PostDeleteButton({super.key, required this.docId, this.type = ''});

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
                      String collectionName;
                      switch (type) {
                        case 'answer':
                          collectionName = 'Answer';
                          break;
                        case 'question':
                          collectionName = 'Question';
                          break;
                        case 'team':
                          collectionName = 'Team';
                          break;
                        case 'project':
                          collectionName = 'Project';
                          break;
                        default:
                          collectionName = '';
                          break;
                      }
                      if (collectionName.isNotEmpty) {
                        await FirebaseFirestore.instance
                            .collection(collectionName)
                            .doc(docId)
                            .delete();
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Invalid type')));
                      }
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
