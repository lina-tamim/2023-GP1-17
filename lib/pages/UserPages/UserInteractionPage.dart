import 'dart:developer';

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

import '../../Models/ReportedPost.dart';

class UserPostsPage extends StatefulWidget {
  const UserPostsPage({Key? key}) : super(key: key);

  @override
  _UserPostsPageState createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  int _currentIndex = 0;

  String email = '';
  String loggedInImage = '';
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      fetchUserData();
      setState(() {
        email = prefs.getString('loggedInEmail')!;
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

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('RegularUser')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs[0].data();
      final imageURL = userData['imageURL'] ?? '';

      setState(() {
        loggedInImage = imageURL;
        this.userData = userData;
      });
    }
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

  Stream<List<String>> readReportedQuestions(String type) {
    return FirebaseFirestore.instance
        .collection('Report')
        .where('reportedUserId', isEqualTo: email)
        .where('reportType', isEqualTo: type)
        .where('status', isEqualTo: 'Accepted')
        .snapshots()
        .asyncMap((snapshot) async {
      List<String> questionsIds = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        String id = data['reportedItemId'];
        return id;
      }).toList();
      return questionsIds;
    });
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
        question.userType = userDoc?['userType'] as String? ?? '';
      });

      return questions;
    });
  }

  Widget buildQuestionCard(CardQview question,
          {bool isReported = false, String? reason = ''}) =>
      Card(
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
              Row(
                children: [
                  Text(
                    question.username ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 34, 3, 87),
                    ),
                  ),
                  if (question.userType == "Freelancer")
                    Icon(
                      Icons.verified,
                      color: Colors.deepPurple,
                      size: 20,
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 110.0),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(question.postedDate),
                      style: TextStyle(fontSize: 12),
                      // Use the desired date format in the DateFormat constructor
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
               Text(
                question.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                 fontSize: 15.4,
                ),
              ),
              SizedBox(height: 5),
              Text(question.description, style: TextStyle(
                 fontSize: 15,
                )),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 7,),
              Container(
                              width:
                                  400, // Set a fixed width for the skills container
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                    question.topics.length,
                                    (intrestsIndex) {
                                      final intrest =
                                          question.topics[intrestsIndex] as String;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Chip(
                                          label: Text(
                                            intrest,
                                            style: TextStyle(fontSize: 12.0),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
              if (!isReported)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.bookmark,
                          color: Color.fromARGB(255, 63, 63, 63)),
                      onPressed: () {
                        addQuestionToBookmarks(email, question);
                      },
                    ),
                    Row(
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
                        Text(question.noOfAnswers.toString()),
                      ],
                    ),
                    PostDeleteButton(docId: question.docId, type: 'question'),
                  ],
                )
              else
                ReportedPostBottom(type: 'Question', reason: reason),
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
        question.userType = userDoc?['userType'] as String? ?? '';
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
              doc.data()['email'] as String,
              doc.data() as Map<String, dynamic>,
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
          answer.userType = userDoc?['userType'] as String? ?? '';
        });

        return answers;
      });

  Stream<List<ReportedPost>> readReportedPosts() {
    return FirebaseFirestore.instance
        .collection('Report')
        .where('reportedUserId', isEqualTo: email)
        .where('status', isEqualTo: 'Accepted')
        .orderBy("reportDate", descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      log('MK: reportedPosts length ${snapshot.docs.length}');

      List<ReportedPost> reportedPosts = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> item in snapshot.docs) {
        Map<String, dynamic> data = item.data();
        ReportedPost post = ReportedPost.fromJson(data, item.id);
        if (post.reportType == 'Question') {
          final doc = await FirebaseFirestore.instance
              .collection('Question')
              .doc(post.reportedItemId)
              .get();

          final Map<String, dynamic>? data = doc.data();
          if (data != null) {
            data['docId'] = doc.id;

            post.data = processJson(data);
          }
          reportedPosts.add(post);
        } else if (post.reportType == 'Answer') {
          final doc = await FirebaseFirestore.instance
              .collection('Answer')
              .doc(post.reportedItemId)
              .get();

          final Map<String, dynamic>? data = doc.data();
          if (data != null) {
            data['docId'] = doc.id;
            post.data = processJson(data);
          }
          reportedPosts.add(post);
        } else if (post.reportType == 'Team') {
          final doc = await FirebaseFirestore.instance
              .collection('Team')
              .doc(post.reportedItemId)
              .get();

          final Map<String, dynamic>? data = doc.data();
          if (data != null) {
            data['docId'] = doc.id;
            post.data = processJson(data);
          }
          reportedPosts.add(post);
        } else if (post.reportType == 'Project') {
          final doc = await FirebaseFirestore.instance
              .collection('Project')
              .doc(post.reportedItemId)
              .get();

          final Map<String, dynamic>? data = doc.data();
          if (data != null) {
            data['docId'] = doc.id;
            post.data = processJson(data);
          }
          reportedPosts.add(post);
        }
      }

      log('MK: reportedPosts ${reportedPosts}');

      return reportedPosts;
    });
  }

  Map<String, dynamic> processJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    data['username'] = userData['username'];
    data['userPhotoUrl'] = userData['userPhotoUrl'] ?? userData['imageURL'];
    data['userType'] = userData['userType'];
    // log('MK: photo url ${userData['userPhotoUrl']}');
    return data;
  }

  Widget buildReportCard(ReportedPost reportedPost) {
    if (reportedPost.reportType == 'Question' && reportedPost.data != null) {
      return buildQuestionCard(CardQview.fromJson(reportedPost.data!),
          isReported: true, reason: reportedPost.reason);
    } else if (reportedPost.reportType == 'Answer' &&
        reportedPost.data != null) {
      return buildAnswerCard(CardAview.fromJson(reportedPost.data!),
          isReported: true, reason: reportedPost.reason);
    } else if (reportedPost.reportType == 'Team' && reportedPost.data != null) {
      return buildTeamCard(CardFTview.fromJson(reportedPost.data!),
          isReported: true, reason: reportedPost.reason);
    } else if (reportedPost.reportType == 'Project' &&
        reportedPost.data != null) {
      return buildProjectCard(CardFTview.fromJson(reportedPost.data!),
          isReported: true, reason: reportedPost.reason);
    }
    return Container();
  }

  Widget buildTeamCard(CardFTview fandT,
      {bool isReported = false, String? reason = ''}) {
    final formattedDate = DateFormat.yMMMMd().format(fandT.date);
    DateTime deadlineDate = fandT.date as DateTime;
    DateTime currentDate = DateTime.now();
    print('User typeTeam: ${fandT.userType}');

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
            Row(
              children: [
                Text(
                  fandT.username ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 34, 3, 87),
                    fontSize: 16,
                  ),
                ),
                if (fandT.userType == "Freelancer")
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                      SizedBox(
                          width:
                              4), // Adjust the spacing between the icon and the date
                    ],
                  ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(fandT.postedDate),
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
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
              spacing:  -5,
              runSpacing:  -5,
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
            if (!isReported) ...[
              Padding(
                padding: const EdgeInsets.only(left: 105),
                child: Row(
                  children: [
                    PostDeleteButton(docId: fandT.docId, type: 'team'),
                    SizedBox(height: 5),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: deadlineDate.isBefore(currentDate)
                        ? const Color.fromARGB(255, 113, 10, 3)
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
              )
            ] else
              ReportedPostBottom(type: 'Team', reason: reason),
          ],
        ),
      ),
    );
  }

  Future<void> addQuestionToBookmarks(String email, CardQview question) async {
    try {
      print("888888888888888888");
      print(question.questionDocId);
      print("888888888888888888");

      final existingBookmark = await FirebaseFirestore.instance
          .collection('Bookmark')
          .where('bookmarkType', isEqualTo: 'question')
          .where('userId', isEqualTo: email)
          .where('postId', isEqualTo: question.questionDocId)
          .get();

      if (existingBookmark.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('Bookmark').add({
          'bookmarkType': 'question',
          'userId': email,
          'postId': question.questionDocId,
          'bookmarkDate': DateTime.now(),
        });
        toastMessage('Question is Bookmarked');
      } else {
        toastMessage('Question is Already Bookmarked!');
      }
    } catch (error) {
      print('Error adding question to bookmarks: $error');
    }
  }

  Widget buildProjectCard(CardFTview fandT,
      {bool isReported = false, String? reason = ''}) {
    final formattedDate = DateFormat.yMMMMd().format(fandT.date);
    DateTime deadlineDate = fandT.date as DateTime;
    DateTime currentDate = DateTime.now();
    print('User typeP: ${fandT.userType}');
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
            Row(
              children: [
                Text(
                  fandT.username ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 34, 3, 87),
                    fontSize: 16,
                  ),
                ),
                if (fandT.userType == "Freelancer")
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                      SizedBox(
                          width:
                              4), // Adjust the spacing between the icon and the date
                    ],
                  ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(fandT.postedDate),
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              fandT.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              fandT.description,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing:  -5,
              runSpacing:  -5,
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
            if (!isReported) ...[
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PostDeleteButton(docId: fandT.docId, type: 'project'),
                    SizedBox(height: 5),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: deadlineDate.isBefore(currentDate)
                        ? const Color.fromARGB(255, 113, 10, 3)
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
              )
            ] else
              ReportedPostBottom(type: 'Project', reason: reason),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
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
          backgroundColor: Color.fromARGB(255, 242, 241, 243),
          automaticallyImplyLeading: false,
          iconTheme: IconThemeData(
            color: Color.fromRGBO(37, 6, 81, 0.898),
          ),
          toolbarHeight: 100,
          title: Builder(
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (loggedInImage.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(loggedInImage),
                        ),
                      ),
                    const SizedBox(width: 8),
                    const Text(
                      'My Interactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Poppins",
                        color: Color.fromRGBO(37, 6, 81, 0.898),
                      ),
                    ),
                    const SizedBox(width: 120),
                  ],
                ),
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(45),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: TabBar(
                isScrollable: true,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 5.0,
                    color: Colors.black,
                  ),
                ),
                labelColor: Colors.black,
                tabs: [
                  Tab(
                    child: Text(
                      'Questions',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w600), // Adjust font size as needed
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Answers',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Team',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Projects',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Reports',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
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
          backgroundColor: Color.fromARGB(255, 49, 0, 84),
          child: const Icon(
            Icons.add,
            color: Color.fromARGB(255, 255, 255, 255),
            size: 25,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: TabBarView(
          children: [
            if (email == '')
              SizedBox()
            else
              StreamBuilder<List<String>>(
                  stream: readReportedQuestions('Question'),
                  builder: (context, snapshotData) {
                    List<String> list = snapshotData.data ?? [];
                    return StreamBuilder<List<CardQview>>(
                      stream: readQuestion(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<CardQview> q = snapshot.data!;
                          q = q
                              .where((element) =>
                                  !list.contains(element.questionDocId))
                              .toList();
                          if (q.isEmpty) {
                            return Center(
                              child: Text('You didn’t post any questions yet'),
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
                    );
                  }),
            if (email == '')
              SizedBox()
            else
              StreamBuilder<List<String>>(
                  stream: readReportedQuestions('Answer'),
                  builder: (context, snapshotData) {
                    List<String> list = snapshotData.data ?? [];
                    return StreamBuilder<List<CardAview>>(
                      stream: readAnswer(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<CardAview> p = snapshot.data!;

                          p = p
                              .where((element) => !list.contains(element.docId))
                              .toList();

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
                    );
                  }),
            if (email == '')
              SizedBox()
            else
              StreamBuilder<List<String>>(
                  stream: readReportedQuestions('Team'),
                  builder: (context, snapshotData) {
                    List<String> list = snapshotData.data ?? [];
                    return StreamBuilder<List<CardFTview>>(
                      stream: readTeam(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<CardFTview> t = snapshot.data!;

                          t = t
                              .where((element) =>
                                  !list.contains(element.teamDocId))
                              .toList();

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
                    );
                  }),
            if (email == '')
              SizedBox()
            else
              StreamBuilder<List<String>>(
                  stream: readReportedQuestions('Project'),
                  builder: (context, snapshotData) {
                    List<String> list = snapshotData.data ?? [];
                    return StreamBuilder<List<CardFTview>>(
                      stream: readProject(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<CardFTview> p = snapshot.data!;

                          p = p
                              .where((element) => !list.contains(element.docId))
                              .toList();

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
                    );
                  }),
            if (email == '')
              SizedBox()
            else
              StreamBuilder<List<ReportedPost>>(
                stream: readReportedPosts(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final q = snapshot.data!;
                    if (q.isEmpty) {
                      return Center(
                        child: Text('No reported posts yet'),
                      );
                    }
                    return ListView(
                      children: q.map(buildReportCard).toList(),
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

  Widget buildAnswerCard(CardAview answer,
      {bool isReported = false, String? reason = ''}) {
    String currentEmail = '';

    Future<String> getCurrentUserEmail() async {
      return email;
    }

    int upvoteCount = answer.upvoteCount;
    List<String> upvotedUserIds = answer.upvotedUserIds;

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
            backgroundImage: answer.userPhotoUrl != null
                ? NetworkImage(answer.userPhotoUrl!)
                : null,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    answer.username ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 34, 3, 87),
                      fontSize: 16,
                    ),
                  ),
                  if (answer.userType == "Freelancer")
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.deepPurple,
                          size: 20,
                        ),
                        SizedBox(
                            width:
                                4), // Adjust the spacing between the icon and the date
                      ],
                    ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(answer.postedDate),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
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
              if (!isReported)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FutureBuilder<String>(
                      future: getCurrentUserEmail(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                                icon: Icon(
                                  upvotedUserIds.contains(currentEmail)
                                      ? Icons.arrow_circle_down
                                      : Icons.arrow_circle_up,
                                  size: 28,
                                  color: upvotedUserIds.contains(currentEmail)
                                      ? const Color.fromARGB(255, 49, 3, 0)
                                      : const Color.fromARGB(255, 26, 33, 38),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (upvotedUserIds.contains(currentEmail)) {
                                      upvotedUserIds.remove(currentEmail);
                                      upvoteCount--;
                                      FirebaseFirestore.instance
                                          .collection('RegularUser')
                                          .where('email',
                                              isEqualTo: answer.userId)
                                          .get()
                                          .then((QuerySnapshot<
                                                  Map<String, dynamic>>
                                              snapshot) {
                                        if (snapshot.docs.isNotEmpty) {
                                          final documentId =
                                              snapshot.docs[0].id;

                                          FirebaseFirestore.instance
                                              .collection('RegularUser')
                                              .doc(documentId)
                                              .update({
                                            'userScore':
                                                FieldValue.increment(-1),
                                          }).catchError((error) {
                                            // Handle error if the update fails
                                          });
                                        }
                                      }).catchError((error) {});
                                      FirebaseFirestore.instance
                                          .collection('Question')
                                          .doc(answer.questionDocId)
                                          .update({
                                        'totalUpvotes':
                                            FieldValue.increment(-1),
                                      }).catchError((error) {
                                        // Handle error if the update fails
                                      });
                                    } else {
                                      upvotedUserIds.add(currentEmail);
                                      upvoteCount++;
                                      FirebaseFirestore.instance
                                          .collection('RegularUser')
                                          .where('email',
                                              isEqualTo: answer.userId)
                                          .get()
                                          .then((QuerySnapshot<
                                                  Map<String, dynamic>>
                                              snapshot) {
                                        if (snapshot.docs.isNotEmpty) {
                                          final documentId =
                                              snapshot.docs[0].id;

                                          FirebaseFirestore.instance
                                              .collection('RegularUser')
                                              .doc(documentId)
                                              .update({
                                            'userScore':
                                                FieldValue.increment(1),
                                          }).catchError((error) {});
                                        }
                                      }).catchError((error) {});
                                      FirebaseFirestore.instance
                                          .collection('Question')
                                          .doc(answer.questionDocId)
                                          .update({
                                        'totalUpvotes': FieldValue.increment(1),
                                      }).catchError((error) {
                                        // Handle error if the update fails
                                      });
                                    }

                                    answer.upvoteCount = upvoteCount;
                                    answer.upvotedUserIds = upvotedUserIds;
                                    FirebaseFirestore.instance
                                        .collection('Answer')
                                        .doc(answer.docId)
                                        .update({
                                      'upvoteCount': upvoteCount,
                                      'upvotedUserIds': upvotedUserIds,
                                    }).catchError((error) {});
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
                )
              else
                ReportedPostBottom(type: 'Answer', reason: reason),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportedPostBottom extends StatelessWidget {
  const ReportedPostBottom({
    super.key,
    required this.type,
    this.reason,
  });

  final String type;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text('Reason: ${reason ?? 'Unknown Reason'}')),
      SizedBox(
        width: 20,
      ),
      Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
          // margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: Text(
            type,
          )),
    ]);
  }
}

class PostDeleteButton extends StatelessWidget {
  const PostDeleteButton({super.key, required this.docId, this.type = ''});

  final String? docId;
  final String type;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: const Color.fromARGB(255, 122, 1, 1),
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
                      if (collectionName == 'Answer') {
                        // Get the questionDocId associated with the answer
                        var answerSnapshot = await FirebaseFirestore.instance
                            .collection(collectionName)
                            .doc(docId)
                            .get();
                        var questionDocId = answerSnapshot['questionId'];

                        // Delete the answer
                        await FirebaseFirestore.instance
                            .collection(collectionName)
                            .doc(docId)
                            .delete();

                        // Decrement the noOfAnswers attribute in the Question table
                        await FirebaseFirestore.instance
                            .collection('Question')
                            .doc(questionDocId)
                            .update({'noOfAnswers': FieldValue.increment(-1)});

                        Navigator.of(context).pop();
                      }
                      if (collectionName.isNotEmpty &&
                          collectionName != 'Answer') {
                        await FirebaseFirestore.instance
                            .collection(collectionName)
                            .doc(docId)
                            .delete();

                        QuerySnapshot<Map<String, dynamic>> querySnapshot =
                            await FirebaseFirestore.instance
                                .collection('Bookmark')
                                .where('bookmarkType', isEqualTo: 'question')
                                .where('postId', isEqualTo: docId)
                                .get();

                        for (QueryDocumentSnapshot<
                                Map<String, dynamic>> docSnapshot
                            in querySnapshot.docs) {
                          await docSnapshot.reference.delete();
                        }

                        Navigator.of(context).pop();
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
