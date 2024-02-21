import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techxcel11/Models/AnswerCard.dart';
import 'package:techxcel11/Models/PostCard.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/Models/ViewQCard.dart';
import 'package:techxcel11/pages/UserPages/AnswerPage.dart';
import 'package:techxcel11/pages/UserPages/UserPathwaysPage.dart';
import 'package:techxcel11/pages/UserPages/UserProfileView.dart';

class ReportedPost extends StatefulWidget {
  const ReportedPost({Key? key}) : super(key: key);

  @override
  State<ReportedPost> createState() => _ReportedPostState();
}

class _ReportedPostState extends State<ReportedPost> {
  final searchController = TextEditingController();

  bool showSearchBar = false;
  bool isLoading = true; // Added loading state

/*
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
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
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 0),
                    const Text(
                      'Reported Posts',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Poppins",
                        color: Color.fromRGBO(37, 6, 81, 0.898),
                      ),
                    ),
                    const SizedBox(width: 140),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showSearchBar = !showSearchBar;
                        });
                      },
                      icon:
                          Icon(showSearchBar ? Icons.search_off : Icons.search),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
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
          ),
          bottom: const TabBar(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 5.0,
                color: Color.fromARGB(
                    255, 27, 5, 230), // Set the color of the underline
              ),
              // Adjust the insets if needed
            ),
            labelColor: Color.fromARGB(255, 27, 5, 230),
            tabs: [
              Tab(
                child: Text(
                  'Questions',
                  style: TextStyle(),
                ),
              ),
              Tab(
                child: Text(
                  'Build Team',
                  style: TextStyle(),
                ),
              ),
              Tab(
                child: Text(
                  'Project',
                  style: TextStyle(),
                ),
              ),
              Tab(
                child: Text(
                  'Answers',
                  style: TextStyle(),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle button press
              },
              child: Text('ollld'),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                StreamBuilder<List<CardQview>>(
                  stream: readReportedQuestion(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final q = snapshot.data!;
                      if (q.isEmpty) {
                        return Center(
                          child: Text('No Reported Question'),
                        );
                      }
                      return ListView(
                        children: q
                            .map((question) => buildQuestionCard(
                                question, question.reportedItemId))
                            .toList(),
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
                  stream: readReportedTeam(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final t = snapshot.data!;
                      if (t.isEmpty) {
                        return Center(
                          child: Text('No Reported Build Team Post'),
                        );
                      }
                      return ListView(
                        children: t
                            .map((team) => buildTeamCard(context, team))
                            .toList(),
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
                  stream: readReportedProject(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final q = snapshot.data!;
                      if (q.isEmpty) {
                        return Center(
                          child: Text('No Reported Question'),
                        );
                      }
                      return ListView(
                        children: q
                            .map((team) => buildTeamCard(context, team))
                            .toList(),
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
                StreamBuilder<List<CardAnswer>>(
                  stream: readReportedAnswer(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final a = snapshot.data!;
                      if (a.isEmpty) {
                        return Center(
                          child: Text('No Answers yet'),
                        );
                      }
                      return ListView(
                        children: a
                            .map((answer) => buildAnswerCard(context, answer))
                            .toList(),
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
        ]),
      ),
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 0),
                    const Text(
                      'Reported Posts',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Poppins",
                        color: Color.fromRGBO(37, 6, 81, 0.898),
                      ),
                    ),
                    const SizedBox(width: 140),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showSearchBar = !showSearchBar;
                        });
                      },
                      icon:
                          Icon(showSearchBar ? Icons.search_off : Icons.search),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
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
          ),
          bottom: TabBar(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 5.0,
                color: Color.fromARGB(
                    255, 27, 5, 230), // Set the color of the underline
              ),
              // Adjust the insets if needed
            ),
            labelColor: Color.fromARGB(255, 27, 5, 230),
            tabs: [
              Tab(
                text: 'Active Request',
              ),
              Tab(
                text: 'Old Request',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Scaffold(
              body: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    TabBar(
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          width: 5.0,
                          color: Color.fromARGB(255, 27, 5,
                              230), // Set the color of the underline
                        ),
                        // Adjust the insets if needed
                      ),
                      labelColor: Color.fromARGB(255, 27, 5, 230),
                      tabs: [
                        Tab(
                          text: 'Question',
                        ),
                        Tab(
                          text: 'Team',
                        ),
                        Tab(
                          text: 'Project',
                        ),
                        Tab(
                          text: 'Answer',
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Active Request - Question Tab
                          StreamBuilder<List<CardQview>>(
                            stream: readReportedQuestion(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final q = snapshot.data!;
                                if (q.isEmpty) {
                                  return Center(
                                    child: Text('No Reported Question'),
                                  );
                                }
                                return ListView(
                                  children: q
                                      .map((question) => buildQuestionCard(
                                          question, question.reportedItemId))
                                      .toList(),
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
                          // Active Request - Team Tab
                          StreamBuilder<List<CardFT>>(
                            stream: readReportedTeam(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final t = snapshot.data!;
                                if (t.isEmpty) {
                                  return Center(
                                    child: Text('No Reported Build Team Post'),
                                  );
                                }
                                return ListView(
                                  children: t
                                      .map((team) =>
                                          buildTeamCard(context, team))
                                      .toList(),
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

                          // Active Request - Project Tab
                          StreamBuilder<List<CardFT>>(
                            stream: readReportedProject(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final q = snapshot.data!;
                                if (q.isEmpty) {
                                  return Center(
                                    child: Text('No Reported Question'),
                                  );
                                }
                                return ListView(
                                  children: q
                                      .map((team) =>
                                          buildTeamCard(context, team))
                                      .toList(),
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
                          // Active Request - Answer Tab

                          StreamBuilder<List<CardAnswer>>(
                            stream: readReportedAnswer(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final a = snapshot.data!;
                                if (a.isEmpty) {
                                  return Center(
                                    child: Text('No Answers yet'),
                                  );
                                }
                                return ListView(
                                  children: a
                                      .map((answer) =>
                                          buildAnswerCard(context, answer))
                                      .toList(),
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
                  ],
                ),
              ),
            ),
            Scaffold(
              body: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    TabBar(
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          width: 5.0,
                          color: Color.fromARGB(255, 27, 5,
                              230), // Set the color of the underline
                        ),
                        // Adjust the insets if needed
                      ),
                      labelColor: Color.fromARGB(255, 27, 5, 230),
                      tabs: [
                        Tab(
                          text: 'Question',
                        ),
                        Tab(
                          text: 'Team',
                        ),
                        Tab(
                          text: 'Project',
                        ),
                        Tab(
                          text: 'Answer',
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Old Request - Question Tab
                          StreamBuilder<List<CardQview>>(
                            stream: readOldReportedQuestion(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final q = snapshot.data!;
                                if (q.isEmpty) {
                                  return Center(
                                    child: Text('No Reported Question'),
                                  );
                                }
                                return ListView(
                                  children: q
                                      .map((question) => buildOldQuestionCard(
                                          question, question.reportedItemId))
                                      .toList(),
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
                          // Old Request - Team Tab
                          StreamBuilder<List<CardFT>>(
                            stream: readOldReportedTeam(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final t = snapshot.data!;
                                if (t.isEmpty) {
                                  return Center(
                                    child: Text('No Reported Build Team Post'),
                                  );
                                }
                                return ListView(
                                  children: t
                                      .map((team) =>
                                          buildOldTeamCard(context, team))
                                      .toList(),
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

                          // Old Request - Project Tab
                          StreamBuilder<List<CardFT>>(
                            stream: readOldReportedProject(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final q = snapshot.data!;
                                if (q.isEmpty) {
                                  return Center(
                                    child: Text('No Reported Question'),
                                  );
                                }
                                return ListView(
                                  children: q
                                      .map((team) =>
                                          buildOldTeamCard(context, team))
                                      .toList(),
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
                          // Old Request - Answer Tab
                          StreamBuilder<List<CardAnswer>>(
                            stream: readOldReportedAnswer(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final a = snapshot.data!;
                                if (a.isEmpty) {
                                  return Center(
                                    child: Text('No Answers yet'),
                                  );
                                }
                                return ListView(
                                  children: a
                                      .map((answer) =>
                                          buildOldAnswerCard(context, answer))
                                      .toList(),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///Questionn +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  Stream<List<CardQview>> readReportedQuestion() {
    return FirebaseFirestore.instance
        .collection('Report')
        .where('status', isEqualTo: 'Pending') // Filter by status

        .orderBy('reportType', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return [];
      }

      final reportedPosts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['reportedPostId'] = doc.id;
        return data;
      }).toList();

      final questionIds = reportedPosts
          .map((post) => post['reportedItemId'] as String)
          .toList();

      final questionDocs = await FirebaseFirestore.instance
          .collection('Question')
          .where(FieldPath.documentId, whereIn: questionIds)
          .get();

      final questions = questionDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['docId'] = doc.id;
        return CardQview.fromJson(data);
      }).toList();

      final userIds = questions.map((question) => question.userId).toSet();
      final userDocs = await FirebaseFirestore.instance
          .collection('RegularUser')
          .where('email', whereIn: userIds.toList())
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(
        userDocs.docs.map((doc) => MapEntry(
              doc.data()!['email'] as String,
              doc.data()! as Map<String, dynamic>,
            )),
      );

      questions.forEach((question) {
        final userDoc = userMap[question.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';

        final reportedPost = reportedPosts.firstWhere(
          (post) => post['reportedItemId'] == question.questionDocId,
          orElse: () => <String, dynamic>{},
        );
        final reason = reportedPost['reason'] as String? ?? '';
        final reportedItemId = reportedPost['reportedItemId'] as String? ?? '';
        final reportDocid = reportedPost['reportedPostId'] as String? ??
            ''; // Add this line to retrieve the report document ID

        question.userType = userDoc?['userType'] as String? ?? '';
        question.reportedItemId = reportedItemId;
        question.username = username;
        question.userPhotoUrl = userPhotoUrl;
        question.reason = reason;
        question.reportDocid =
            reportDocid; // Assign the report document ID to the reportDocid variable
      });

      return questions;
    });
  }

  Widget buildQuestionCard(CardQview question, String postId) => Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: question.userPhotoUrl != null
                ? NetworkImage(question.userPhotoUrl!)
                : null,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  if (question.userId != null &&
                      question.userId.isNotEmpty &&
                      question.userId != "DeactivatedUser") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfileView(userId: question.userId),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    Text(
                      question.username ?? '', // Display the username
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 34, 3, 87),
                          fontSize: 16),
                    ),
                    if (question.userType == "Freelancer")
                      Icon(
                        Icons.verified,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                  ],
                ),
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
              SizedBox(height: 5),
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
                    icon: Icon(Icons.comment,
                        color: Color.fromARGB(255, 63, 63, 63)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AnswerPage(
                                questionDocId: question.questionDocId)),
                      );
                    },
                  ),
                ],
              ),
              Container(
                width: 550.0,
                height: 1.0,
                color: Colors.grey, // Customize the color if needed
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Reason: ${question.reason ?? ''}", // Display the reason here
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 92, 0, 0),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _updateReportStatus('Accepted', question.reportDocid);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromARGB(255, 22, 146, 0),
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Accept',
                        style: TextStyle(
                            color: Color.fromARGB(255, 254, 254, 254))),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updateReportStatus('Rejected', question.reportDocid);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 122, 1, 1),
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Reject',
                      style:
                          TextStyle(color: Color.fromARGB(255, 254, 254, 254)),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      );

  Stream<List<CardQview>> readOldReportedQuestion() {
    return FirebaseFirestore.instance
        .collection('Report')
        .where('status', isEqualTo: 'Accepted') // Filter by status

        .orderBy('reportType', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return [];
      }

      final reportedPosts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['reportedPostId'] = doc.id;
        return data;
      }).toList();

      final questionIds = reportedPosts
          .map((post) => post['reportedItemId'] as String)
          .toList();

      final questionDocs = await FirebaseFirestore.instance
          .collection('Question')
          .where(FieldPath.documentId, whereIn: questionIds)
          .get();

      final questions = questionDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['docId'] = doc.id;
        return CardQview.fromJson(data);
      }).toList();

      final userIds = questions.map((question) => question.userId).toSet();
      final userDocs = await FirebaseFirestore.instance
          .collection('RegularUser')
          .where('email', whereIn: userIds.toList())
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(
        userDocs.docs.map((doc) => MapEntry(
              doc.data()!['email'] as String,
              doc.data()! as Map<String, dynamic>,
            )),
      );

      questions.forEach((question) {
        final userDoc = userMap[question.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';

        final reportedPost = reportedPosts.firstWhere(
          (post) => post['reportedItemId'] == question.questionDocId,
          orElse: () => <String, dynamic>{},
        );
        final reason = reportedPost['reason'] as String? ?? '';
        final status = reportedPost['status'] as String? ?? '';

        final reportedItemId = reportedPost['reportedItemId'] as String? ?? '';
        final reportDocid = reportedPost['reportedPostId'] as String? ??
            ''; // Add this line to retrieve the report document ID

        question.userType = userDoc?['userType'] as String? ?? '';
        question.reportedItemId = reportedItemId;
        question.username = username;
        question.userPhotoUrl = userPhotoUrl;
        question.reason = reason;
        question.reportDocid = reportDocid;
        question.status = status;
        // Assign the report document ID to the reportDocid variable
      });

      return questions;
    });
  }

  Widget buildOldQuestionCard(CardQview question, String postId) => Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: question.userPhotoUrl != null
                ? NetworkImage(question.userPhotoUrl!)
                : null,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  if (question.userId != null &&
                      question.userId.isNotEmpty &&
                      question.userId != "DeactivatedUser") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfileView(userId: question.userId),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    Text(
                      question.username ?? '', // Display the username
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 34, 3, 87),
                          fontSize: 16),
                    ),
                    if (question.userType == "Freelancer")
                      Icon(
                        Icons.verified,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                  ],
                ),
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
              SizedBox(height: 5),
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
                    icon: Icon(Icons.comment,
                        color: Color.fromARGB(255, 63, 63, 63)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AnswerPage(
                                questionDocId: question.questionDocId)),
                      );
                    },
                  ),
                ],
              ),
              Container(
                width: 550.0,
                height: 1.0,
                color: Colors.grey, // Customize the color if needed
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Reason: ${question.reason ?? ''}", // Display the reason here
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 92, 0, 0),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Report Accepted",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 2, 106, 8),
                ),
              )
            ],
          ),
        ),
      );

  ////END QUESTION
  //////TEAM
  ///
  ///
  
  Stream<List<CardFT>> readReportedTeam() {
    return FirebaseFirestore.instance
        .collection('Report')
        .where('status', isEqualTo: 'Pending') // Filter by status

        .orderBy('reportType', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return []; // Return an empty list if there are no reported posts.
      }

      final reportedPosts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['reportedPostId'] = doc.id;
        return data;
      }).toList();

      final teamIds = reportedPosts
          .map((post) => post['reportedItemId'] as String)
          .toList();

      final teamDocs = await FirebaseFirestore.instance
          .collection('Team')
          .where(FieldPath.documentId, whereIn: teamIds)
          .get();

      final teams = teamDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['docId'] = doc.id;
        return CardFT.fromJson(data);
      }).toList();

      // Get user-related information for each question
      final userIds = teams.map((team) => team.userId).toSet();
      final userDocs = await FirebaseFirestore.instance
          .collection('RegularUser')
          .where('email', whereIn: userIds.toList())
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(
        userDocs.docs.map((doc) => MapEntry(
              doc.data()!['email'] as String,
              doc.data()! as Map<String, dynamic>,
            )),
      );

      teams.forEach((team) {
        final userDoc = userMap[team.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';

        final reportedPost = reportedPosts.firstWhere(
          (post) => post['reportedItemId'] == team.docId, //
          orElse: () => <String, dynamic>{},
        );
        final reason = reportedPost['reason'] as String? ?? '';
        final reportDocid = reportedPost['reportedPostId'] as String? ?? '';
        team.userType = userDoc?['userType'] as String? ?? "";
        team.username = username;
        team.userPhotoUrl = userPhotoUrl;
        team.reason = reason;
        team.reportDocid = reportDocid;
      });

      return teams;
    });
  }

  Stream<List<CardFT>> readOldReportedTeam() {
    return FirebaseFirestore.instance
        .collection('Report')
        .where('status', isEqualTo: 'Accepted') // Filter by status

        .orderBy('reportType', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return []; // Return an empty list if there are no reported posts.
      }

      final reportedPosts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['reportedPostId'] = doc.id;
        return data;
      }).toList();

      final teamIds = reportedPosts
          .map((post) => post['reportedItemId'] as String)
          .toList();

      final teamDocs = await FirebaseFirestore.instance
          .collection('Team')
          .where(FieldPath.documentId, whereIn: teamIds)
          .get();

      final teams = teamDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['docId'] = doc.id;
        return CardFT.fromJson(data);
      }).toList();

      // Get user-related information for each question
      final userIds = teams.map((team) => team.userId).toSet();
      final userDocs = await FirebaseFirestore.instance
          .collection('RegularUser')
          .where('email', whereIn: userIds.toList())
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(
        userDocs.docs.map((doc) => MapEntry(
              doc.data()!['email'] as String,
              doc.data()! as Map<String, dynamic>,
            )),
      );

      teams.forEach((team) {
        final userDoc = userMap[team.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';

        final reportedPost = reportedPosts.firstWhere(
          (post) => post['reportedItemId'] == team.docId, //
          orElse: () => <String, dynamic>{},
        );
        final reason = reportedPost['reason'] as String? ?? '';
        final reportDocid = reportedPost['reportedPostId'] as String? ?? '';
        team.userType = userDoc?['userType'] as String? ?? "";
        team.username = username;
        team.userPhotoUrl = userPhotoUrl;
        team.reason = reason;
        team.reportDocid = reportDocid;
      });

      return teams;
    });
  }

  Widget buildTeamCard(BuildContext context, CardFT team) => Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: team.userPhotoUrl != null
                ? NetworkImage(team.userPhotoUrl!)
                : null,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  if (team.userId != null &&
                      team.userId.isNotEmpty &&
                      team.userId != "DeactivatedUser") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfileView(userId: team.userId),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    Text(
                      team.username ?? '', // Display the username
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 34, 3, 87),
                          fontSize: 16),
                    ),
                    if (team.userType == "Freelancer")
                      Icon(
                        Icons.verified,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                  ],
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
              SizedBox(height: 5),
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
              Container(
                width: 550.0,
                height: 1.0,
                color: Colors.grey, // Customize the color if needed
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Reason: ${team.reason ?? ''}", // Display the reason here
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 92, 0, 0),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _updateReportStatus('Accepted', team.reportDocid);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromARGB(255, 22, 146, 0),
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Accept',
                        style: TextStyle(
                            color: Color.fromARGB(255, 254, 254, 254))),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updateReportStatus('Rejected', team.reportDocid);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 122, 1, 1),
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Reject',
                      style:
                          TextStyle(color: Color.fromARGB(255, 254, 254, 254)),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      );

  Widget buildOldTeamCard(BuildContext context, CardFT team) => Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: team.userPhotoUrl != null
                ? NetworkImage(team.userPhotoUrl!)
                : null,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  if (team.userId != null &&
                      team.userId.isNotEmpty &&
                      team.userId != "DeactivatedUser") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfileView(userId: team.userId),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    Text(
                      team.username ?? '', // Display the username
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 34, 3, 87),
                          fontSize: 16),
                    ),
                    if (team.userType == "Freelancer")
                      Icon(
                        Icons.verified,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                  ],
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
              SizedBox(height: 5),
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
              Container(
                width: 550.0,
                height: 1.0,
                color: Colors.grey, // Customize the color if needed
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Reason: ${team.reason ?? ''}", // Display the reason here
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 92, 0, 0),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Report Accepted",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 2, 106, 8),
                ),
              )
            ],
          ),
        ),
      );

  /// end TEAM
  /// Start project
  ///
  Stream<List<CardFT>> readReportedProject() {
    return FirebaseFirestore.instance
        .collection('Report')
        .where('status', isEqualTo: 'Pending') // Filter by status

        .orderBy('reportType', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return []; // Return an empty list if there are no reported posts.
      }

      final reportedPosts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['reportedPostId'] = doc.id;
        return data;
      }).toList();

      final projectIds = reportedPosts
          .map((post) => post['reportedItemId'] as String)
          .toList();

      final projectDocs = await FirebaseFirestore.instance
          .collection('Project')
          .where(FieldPath.documentId, whereIn: projectIds)
          .get();

      final projects = projectDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['docId'] = doc.id;
        return CardFT.fromJson(data);
      }).toList();

      // Get user-related information for each question
      final userIds = projects.map((project) => project.userId).toSet();
      final userDocs = await FirebaseFirestore.instance
          .collection('RegularUser')
          .where('email', whereIn: userIds.toList())
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(
        userDocs.docs.map((doc) => MapEntry(
              doc.data()!['email'] as String,
              doc.data()! as Map<String, dynamic>,
            )),
      );

      projects.forEach((project) {
        final userDoc = userMap[project.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';

        final reportedPost = reportedPosts.firstWhere(
          (post) => post['reportedItemId'] == project.docId, //
          orElse: () => <String, dynamic>{},
        );
        final reason = reportedPost['reason'] as String? ?? '';
        final reportDocid = reportedPost['reportedPostId'] as String? ?? '';
        project.userType = userDoc?['userType'] as String? ?? "";
        project.reportDocid = reportDocid;
        project.username = username;
        project.userPhotoUrl = userPhotoUrl;
        project.reason = reason;
      });

      return projects;
    });
  }

  Stream<List<CardFT>> readOldReportedProject() {
    return FirebaseFirestore.instance
        .collection('Report')
        .where('status', isEqualTo: 'Accepted') // Filter by status

        .orderBy('reportType', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return []; // Return an empty list if there are no reported posts.
      }

      final reportedPosts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['reportedPostId'] = doc.id;
        return data;
      }).toList();

      final projectIds = reportedPosts
          .map((post) => post['reportedItemId'] as String)
          .toList();

      final projectDocs = await FirebaseFirestore.instance
          .collection('Project')
          .where(FieldPath.documentId, whereIn: projectIds)
          .get();

      final projects = projectDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['docId'] = doc.id;
        return CardFT.fromJson(data);
      }).toList();

      // Get user-related information for each question
      final userIds = projects.map((project) => project.userId).toSet();
      final userDocs = await FirebaseFirestore.instance
          .collection('RegularUser')
          .where('email', whereIn: userIds.toList())
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(
        userDocs.docs.map((doc) => MapEntry(
              doc.data()!['email'] as String,
              doc.data()! as Map<String, dynamic>,
            )),
      );

      projects.forEach((project) {
        final userDoc = userMap[project.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';

        final reportedPost = reportedPosts.firstWhere(
          (post) => post['reportedItemId'] == project.docId, //
          orElse: () => <String, dynamic>{},
        );
        final reason = reportedPost['reason'] as String? ?? '';
        final reportDocid = reportedPost['reportedPostId'] as String? ?? '';
        project.userType = userDoc?['userType'] as String? ?? "";
        project.reportDocid = reportDocid;
        project.username = username;
        project.userPhotoUrl = userPhotoUrl;
        project.reason = reason;
      });

      return projects;
    });
  }

  // answer

  Stream<List<CardAnswer>> readReportedAnswer() {
    return FirebaseFirestore.instance
        .collection('Report')
        .where('status', isEqualTo: 'Pending') // Filter by status

        .orderBy('reportType', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return []; // Return an empty list if there are no reported posts.
      }

      final reportedPosts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['reportedPostId'] = doc.id;
        return data;
      }).toList();

      final AnswerIds = reportedPosts
          .map((post) => post['reportedItemId'] as String)
          .toList();

      final AnswerDocs = await FirebaseFirestore.instance
          .collection('Answer')
          .where(FieldPath.documentId, whereIn: AnswerIds)
          .get();

      final Answers = AnswerDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['docId'] = doc.id;
        return CardAnswer.fromJson(data);
      }).toList();

      // Get user-related information for each question
      final userIds = Answers.map((Answer) => Answer.userId).toSet();
      final userDocs = await FirebaseFirestore.instance
          .collection('RegularUser')
          .where('email', whereIn: userIds.toList())
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(
        userDocs.docs.map((doc) => MapEntry(
              doc.data()!['email'] as String,
              doc.data()! as Map<String, dynamic>,
            )),
      );

      Answers.forEach((Answer) {
        final userDoc = userMap[Answer.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';

        final reportedPost = reportedPosts.firstWhere(
          (post) => post['reportedItemId'] == Answer.docId, //
          orElse: () => <String, dynamic>{},
        );
        final reason = reportedPost['reason'] as String? ?? '';
        final reportDocid = reportedPost['reportedPostId'] as String? ?? '';

        Answer.userType = userDoc?['userType'] as String? ?? "";
        Answer.username = username;
        Answer.userPhotoUrl = userPhotoUrl;
        Answer.reason = reason;
        Answer.reportDocid = reportDocid;
      });

      return Answers;
    });
  }

  Stream<List<CardAnswer>> readOldReportedAnswer() {
    return FirebaseFirestore.instance
        .collection('Report')
        .where('status', isEqualTo: 'Accepted') // Filter by status

        .orderBy('reportType', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return []; // Return an empty list if there are no reported posts.
      }

      final reportedPosts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['reportedPostId'] = doc.id;
        return data;
      }).toList();

      final AnswerIds = reportedPosts
          .map((post) => post['reportedItemId'] as String)
          .toList();

      final AnswerDocs = await FirebaseFirestore.instance
          .collection('Answer')
          .where(FieldPath.documentId, whereIn: AnswerIds)
          .get();

      final Answers = AnswerDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['docId'] = doc.id;
        return CardAnswer.fromJson(data);
      }).toList();

      // Get user-related information for each question
      final userIds = Answers.map((Answer) => Answer.userId).toSet();
      final userDocs = await FirebaseFirestore.instance
          .collection('RegularUser')
          .where('email', whereIn: userIds.toList())
          .get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(
        userDocs.docs.map((doc) => MapEntry(
              doc.data()!['email'] as String,
              doc.data()! as Map<String, dynamic>,
            )),
      );

      Answers.forEach((Answer) {
        final userDoc = userMap[Answer.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';

        final reportedPost = reportedPosts.firstWhere(
          (post) => post['reportedItemId'] == Answer.docId, //
          orElse: () => <String, dynamic>{},
        );
        final reason = reportedPost['reason'] as String? ?? '';
        final reportDocid = reportedPost['reportedPostId'] as String? ?? '';

        Answer.userType = userDoc?['userType'] as String? ?? "";
        Answer.username = username;
        Answer.userPhotoUrl = userPhotoUrl;
        Answer.reason = reason;
        Answer.reportDocid = reportDocid;
      });

      return Answers;
    });
  }

  Widget buildAnswerCard(BuildContext context, CardAnswer answer) {
    String currentEmail = '';
    int upvoteCount = answer.upvoteCount ?? 0;
    List<String> upvotedUserIds = answer.upvotedUserIds ?? [];
    String doc = answer.docId;
    print("7777777777777 $doc");

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AnswerPage(questionDocId: answer.questionDocId),
          ),
        );
      },
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: answer.userPhotoUrl != ''
                ? NetworkImage(answer.userPhotoUrl!)
                : AssetImage('assets/Backgrounds/defaultUserPic.png')
                    as ImageProvider<Object>,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (answer.userId != null &&
                          answer.userId.isNotEmpty &&
                          answer.userId != "DeactivatedUser") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProfileView(userId: answer.userId),
                          ),
                        );
                      }
                    },
                    child: Text(
                      answer.username ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  if (answer.userType == "Freelancer")
                    Icon(
                      Icons.verified,
                      color: Colors.deepPurple,
                      size: 20,
                    ),
                ],
              ),
              SizedBox(height: 10),
              Text(answer.answerText),
              SizedBox(height: 10),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Upvotes: $upvoteCount'),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 550.0,
                height: 1.0,
                color: Colors.grey, // Customize the color if needed
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Reason: ${answer.reason ?? ''}", // Display the reason here
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 92, 0, 0),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _updateReportStatus('Accepted', answer.reportDocid);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromARGB(255, 22, 146, 0),
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Accept',
                        style: TextStyle(
                            color: Color.fromARGB(255, 254, 254, 254))),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updateReportStatus('Rejected', answer.reportDocid);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 122, 1, 1),
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Reject',
                      style:
                          TextStyle(color: Color.fromARGB(255, 254, 254, 254)),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOldAnswerCard(BuildContext context, CardAnswer answer) {
    String currentEmail = '';
    int upvoteCount = answer.upvoteCount ?? 0;
    List<String> upvotedUserIds = answer.upvotedUserIds ?? [];
    String doc = answer.docId;
    print("7777777777777 $doc");

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AnswerPage(questionDocId: answer.questionDocId),
          ),
        );
      },
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: answer.userPhotoUrl != ''
                ? NetworkImage(answer.userPhotoUrl!)
                : AssetImage('assets/Backgrounds/defaultUserPic.png')
                    as ImageProvider<Object>,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (answer.userId != null &&
                          answer.userId.isNotEmpty &&
                          answer.userId != "DeactivatedUser") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProfileView(userId: answer.userId),
                          ),
                        );
                      }
                    },
                    child: Text(
                      answer.username ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 34, 3, 87),
                      ),
                    ),
                  ),
                  if (answer.userType == "Freelancer")
                    Icon(
                      Icons.verified,
                      color: Colors.deepPurple,
                      size: 20,
                    ),
                ],
              ),
              SizedBox(height: 10),
              Text(answer.answerText),
              SizedBox(height: 10),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Upvotes: $upvoteCount'),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 550.0,
                height: 1.0,
                color: Colors.grey, // Customize the color if needed
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Reason: ${answer.reason ?? ''}", // Display the reason here
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 92, 0, 0),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Report Accepted",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 2, 106, 8),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _updateReportStatus(String status, String reportId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Report')
          .doc(reportId)
          .update({
        'status': status,
      });
    } catch (e) {}
  }
}