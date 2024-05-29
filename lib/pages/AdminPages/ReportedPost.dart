import 'package:algolia/algolia.dart';
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
import 'package:intl/intl.dart';

class ReportedPost extends StatefulWidget {
  const ReportedPost({Key? key}) : super(key: key);

  @override
  State<ReportedPost> createState() => _ReportedPostState();
}

class _ReportedPostState extends State<ReportedPost>
    with TickerProviderStateMixin {
  final searchController = TextEditingController();

  late TabController _tabController;
  late TabController _tabItemsController;
  late TabController _tabItemsController2;

  tabStaterefresher() {
    setState(() {});
  }

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this)
      ..addListener(tabStaterefresher);
    _tabItemsController = new TabController(length: 4, vsync: this)
      ..addListener(tabStaterefresher);
    _tabItemsController2 = new TabController(length: 4, vsync: this)
      ..addListener(tabStaterefresher);
    super.initState();
  }

  final Algolia algolia = Algolia.init(
    applicationId: 'PTLT3VDSB8',
    apiKey: '6236d82b883664fa54ad458c616d39ca',
  );

  bool showSearchBar = false;
  bool isLoading = true; // Added loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 242, 241, 243),
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Color.fromRGBO(37, 6, 81, 0.898),
        ),
        toolbarHeight: 100,
        /* flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Backgrounds/bg11.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),*/
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
                  Spacer(),
                  // const SizedBox(width: 140),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        showSearchBar = !showSearchBar;
                      });
                    },
                    icon: Icon(showSearchBar ? Icons.search_off : Icons.search),
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
                    // searchReportsByQuestionContent(searchController.text);
                    // Handle search input changes
                  },
                ),
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 3.0,
              color: Color.fromRGBO(37, 6, 81, 0.898),
              // Set the color of the underline
            ),
            // Adjust the insets if needed
          ),
          labelColor: Color.fromARGB(255, 31, 5, 67),
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
        controller: _tabController,
        children: [
          Scaffold(
            body: Column(
              children: [
                TabBar(
                  controller: _tabItemsController,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      width: 3.0,
                      color: Color.fromRGBO(37, 6, 81, 0.898),
                      // Set the color of the underline
                    ),
                    // Adjust the insets if needed
                  ),
                  labelColor: Color.fromARGB(255, 31, 5, 67),
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
                    controller: _tabItemsController,
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
                                child: Text('No Reported Teams Post'),
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

                      // Active Request - Project Tab
                      StreamBuilder<List<CardFT>>(
                        stream: readReportedProject(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final q = snapshot.data!;
                            if (q.isEmpty) {
                              return Center(
                                child: Text('No Reported Projects'),
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
          Scaffold(
            body: Column(
              children: [
                TabBar(
                  controller: _tabItemsController2,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                        width: 3.0,
                        color: Color.fromRGBO(
                            37, 6, 81, 0.898) // Set the color of the underline
                        ),
                    // Adjust the insets if needed
                  ),
                  labelColor: Color.fromARGB(255, 31, 5, 67),
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
                    controller: _tabItemsController2,
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
                                child: Text('No Reported Teams Post'),
                              );
                            }
                            return ListView(
                              children: t
                                  .map(
                                      (team) => buildOldTeamCard(context, team))
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
                                child: Text('No Reported Projects Post'),
                              );
                            }
                            return ListView(
                              children: q
                                  .map(
                                      (team) => buildOldTeamCard(context, team))
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
                                child: Text('No Reported Answers Post'),
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
        ],
      ),
    );
  }

  ///Questionn +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ///

  Future<List<Map<String, dynamic>>> searchReportsByQuestionContent(
      String status, String indexName) async {
    AlgoliaQuery query =
        algolia.instance.index(indexName).query(searchController.text);
    AlgoliaQuerySnapshot querySnapshot = await query.getObjects();
    List<String> itemIds =
        querySnapshot.hits.map((hit) => hit.objectID).toList();

    if (itemIds.isEmpty) {
      return [];
    }
    AlgoliaQuery reportsQuery = algolia.instance.index('Report_index');
    List<String> filters = itemIds.map((id) => 'reportedItemId:$id').toList();
    // print('MK: filters: ${filters.length} $filters');
    AlgoliaQuerySnapshot reportsSnapshot = await reportsQuery
        .facetFilter(filters)
        .facetFilter('status:$status')
        .getObjects();
    List<Map<String, dynamic>> reports = reportsSnapshot.hits
        .map((hit) => {'reportedPostId': hit.objectID, ...hit.data})
        .toList();

    // for (Map<String, dynamic> report in reports) {
    //   report['item'] = querySnapshot.hits
    //       .firstWhere((hit) => report['reportedItemId'] == hit.objectID);
    // }

    print('MK: reports: ${reports.length} $reports');

    return reports;
  }

  Stream<List<CardQview>> readReportedQuestion() async* {
    if (searchController.text.isNotEmpty) {
      List<Map<String, dynamic>> reportedPosts =
          await searchReportsByQuestionContent('Pending', 'Question_index');

      yield* Stream.value(await getQuestions(reportedPosts));
    } else {
      yield* FirebaseFirestore.instance
          .collection('Report')
          .where('status', isEqualTo: 'Pending') // Filter by status

          .orderBy('reportType', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        if (snapshot.docs.isEmpty) {
          return [];
        }

        final reportedPosts = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['reportedPostId'] = doc.id;
          return data;
        }).toList();

        return getQuestions(reportedPosts);
      });
    }
  }

  Future<List<CardQview>> getQuestions(
      List<Map<String, dynamic>> reportedPosts) async {
    final questionIds =
        reportedPosts.map((post) => post['reportedItemId'] as String).toList();

    List<CardQview> questions = [];

    // Paginate the query to avoid `whereIn` limitations
    for (int i = 0; i < questionIds.length; i += 10) {
      List<String> batchIds = questionIds.sublist(
          i, (i + 10 < questionIds.length) ? i + 10 : questionIds.length);

      final questionDocs = await FirebaseFirestore.instance
          .collection('Question')
          .where(FieldPath.documentId, whereIn: batchIds)
          .get();

      final batchQuestions = questionDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['docId'] = doc.id;
        return CardQview.fromJson(data);
      }).toList();

      final userIds = batchQuestions.map((question) => question.userId).toSet();
      print('userIds: ${userIds} $batchQuestions');
      if (batchQuestions.isEmpty || userIds.isEmpty) continue;
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

      batchQuestions.forEach((question) {
        final userDoc = userMap[question.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';

        final reportedPostsForQuestion = reportedPosts
            .where((post) => post['reportedItemId'] == question.questionDocId)
            .toList();
        final reasons = reportedPostsForQuestion
            .map((post) => post['reason'] as String)
            .toList();
        final reportIds = reportedPostsForQuestion
            .map((post) => post['reportedPostId'] as String)
            .toList();

        final reportDate = reportedPostsForQuestion
            .map((report) => report['reportDate'] is int
                ? Timestamp.fromMicrosecondsSinceEpoch(
                    report['reportDate'] as int)
                : report['reportDate'] as Timestamp?)
            .where((date) => date != null)
            .toList();

        question.reportDate =
            reportDate.isNotEmpty ? reportDate.first!.toDate() : DateTime.now();

        question.userType = userDoc?['userType'] as String? ?? '';
        question.username = username;
        question.userPhotoUrl = userPhotoUrl;
        question.reasons =
            reasons; // Add a list property to CardQview to hold reasons
        question.reportIds =
            reportIds; // Add a list property to CardQview to hold reportIds
      });

      questions.addAll(batchQuestions);
    }

    return questions;
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
              Stack(
                children: [
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
                        SizedBox(
                          width: 140,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: -8,
                    // Adjust this value to give the tooltip some extra space from the top
                    child: Tooltip(
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(217, 122, 1, 1),
                        ),
                        child: Text(
                          '${question.reportIds!.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      message: 'Total number of reports on this post',
                      padding: EdgeInsets.all(10),
                      showDuration: Duration(seconds: 3),
                      textStyle: TextStyle(color: Colors.white),
                      preferBelow: true,
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
              Text(question.description,
                  style: TextStyle(
                    fontSize: 15,
                  )),
              SizedBox(height: 5),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 7,
              ),
              Container(
                width: 400, // Set a fixed width for the skills container
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      question.topics.length,
                      (intrestsIndex) {
                        final intrest =
                            question.topics[intrestsIndex] as String;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
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
                "Reasons: ${question.reasons?.join(', ')}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 92, 0, 0),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Report Date: ${DateFormat('dd/MM/yyyy').format(question.reportDate)}",
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
                      for (String reportId in question.reportIds ?? []) {
                        _updateReportStatus('Accepted', reportId);
                      }
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
                      for (String reportId in question.reportIds ?? []) {
                        _updateReportStatus('Rejected', reportId);
                      }
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

  Stream<List<CardQview>> readOldReportedQuestion() async* {
    if (searchController.text.isNotEmpty) {
      List<Map<String, dynamic>> reportedPosts =
          await searchReportsByQuestionContent('Accepted', 'Question_index');

      yield* Stream.value(await getQuestions(reportedPosts));
    } else {
      yield* FirebaseFirestore.instance
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

        // final questionIds = reportedPosts
        //     .map((post) => post['reportedItemId'] as String)
        //     .toList();

        return getQuestions(reportedPosts);

        /*
        List<CardQview> questions = [];

      // Paginate the query to avoid `whereIn` limitations
      for (int i = 0; i < questionIds.length; i += 10) {
        List<String> batchIds = questionIds.sublist(
            i, (i + 10 < questionIds.length) ? i + 10 : questionIds.length);

        final questionDocs = await FirebaseFirestore.instance
            .collection('Question')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();

        final batchQuestions = questionDocs.docs.map((doc) {
          Map<String, dynamic> data = doc.data()!;
          data['docId'] = doc.id;
          return CardQview.fromJson(data);
        }).toList();

        final userIds =
            batchQuestions.map((question) => question.userId).toSet();
        if (batchQuestions.isEmpty || userIds.isEmpty) continue;
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

        batchQuestions.forEach((question) {
          final userDoc = userMap[question.userId];
          final username = userDoc?['username'] as String? ?? '';
          final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';

          final reportedPostsForQuestion = reportedPosts
              .where((post) => post['reportedItemId'] == question.questionDocId)
              .toList();
          final reasons = reportedPostsForQuestion
              .map((post) => post['reason'] as String)
              .toList();
          final reportIds = reportedPostsForQuestion
              .map((post) => post['reportedPostId'] as String)
              .toList();

          final reportDate = reportedPostsForQuestion
              .map((report) => report['reportDate'] as Timestamp?)
              .where((date) => date != null)
              .toList();

          question.reportDate = reportDate.isNotEmpty
              ? reportDate.first!.toDate()
              : DateTime.now();

          question.userType = userDoc?['userType'] as String? ?? '';
          question.username = username;
          question.userPhotoUrl = userPhotoUrl;
          question.reasons =
              reasons; // Add a list property to CardQview to hold reasons
          question.reportIds =
              reportIds; // Add a list property to CardQview to hold reportIds
        });

        questions.addAll(batchQuestions);
      }

      return questions;
        * */
      });
    }
  }

  Widget buildOldQuestionCard(CardQview question, String postId) {
    return Card(
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
            Stack(
              children: [
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
                      SizedBox(
                        width: 140,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  top: -8,
                  // Adjust this value to give the tooltip some extra space from the top
                  child: Tooltip(
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(217, 122, 1, 1),
                      ),
                      child: Text(
                        '${question.reportIds!.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    message: 'Total number of reports on this post',
                    padding: EdgeInsets.all(10),
                    showDuration: Duration(seconds: 3),
                    textStyle: TextStyle(color: Colors.white),
                    preferBelow: true,
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
            Text(
              question.description ?? '', // Ensure description is not null
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 7),
            Container(
              width: 400,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    question.topics.length,
                    (index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Chip(
                          label: Text(
                            question.topics[index],
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Reasons: ${question.reasons?.isNotEmpty == true ? question.reasons!.join(', ') : 'Reasons not provided'}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 92, 0, 0),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Report Date: ${DateFormat('dd/MM/yyyy').format(question.reportDate)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 92, 0, 0),
              ),
            ),
            SizedBox(height: 20),
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
  }

  ////END QUESTION
  //////TEAM
  ///
  Stream<List<CardFT>> readReportedTeam() async* {
    if (searchController.text.isNotEmpty) {
      List<Map<String, dynamic>> reportedPosts =
          await searchReportsByQuestionContent('Pending', 'Team_index');

      yield* Stream.value(await getReportedTeam(reportedPosts));
    } else {
      yield* FirebaseFirestore.instance
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

        return getReportedTeam(reportedPosts);
      });
    }
  }

  Future<List<CardFT>> getReportedTeam(List reportedPosts) async {
    final teamIds =
        reportedPosts.map((post) => post['reportedItemId'] as String).toList();

    List<CardFT> teams = [];

    // Paginate the query to avoid `whereIn` limitations
    for (int i = 0; i < teamIds.length; i += 10) {
      List<String> batchIds = teamIds.sublist(
          i, (i + 10 < teamIds.length) ? i + 10 : teamIds.length);

      if (batchIds.isEmpty) continue;
      final questionDocs = await FirebaseFirestore.instance
          .collection('Team')
          .where(FieldPath.documentId, whereIn: batchIds)
          .get();

      final batchQuestions = questionDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['docId'] = doc.id;
        return CardFT.fromJson(data);
      }).toList();
      // Get user-related information for each question
      final userIds = batchQuestions.map((team) => team.userId).toSet();

      dynamic userMap = {};
      if (userIds.isNotEmpty) {
        final userDocs = await FirebaseFirestore.instance
            .collection('RegularUser')
            .where('email', whereIn: userIds.toList())
            .get();

        userMap = Map<String, Map<String, dynamic>>.fromEntries(
          userDocs.docs.map((doc) => MapEntry(
                doc.data()!['email'] as String,
                doc.data()! as Map<String, dynamic>,
              )),
        );
      }

      batchQuestions.forEach((team) {
        final userDoc = userMap[team.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';

        final teamReports = reportedPosts
            .where((post) => post['reportedItemId'] == team.docId)
            .toList();

        final reasons =
            teamReports.map((report) => report['reason'] as String).toList();
        final reportIds = teamReports
            .map((report) => report['reportedPostId'] as String)
            .toList();

        final reportDate = teamReports
            .map((report) => report['reportDate'] is int
                ? Timestamp.fromMicrosecondsSinceEpoch(
                    report['reportDate'] as int)
                : report['reportDate'] as Timestamp?)
            .where((date) => date != null)
            .toList();

        team.reportDate =
            reportDate.isNotEmpty ? reportDate.first!.toDate() : DateTime.now();

        team.userType = userDoc?['userType'] as String? ?? '';
        team.username = username;
        team.userPhotoUrl = userPhotoUrl;
        team.reasons = reasons;
        team.reportDocids = reportIds;
      });

      teams.addAll(batchQuestions);
    }

    return teams;
  }

  Stream<List<CardFT>> readOldReportedTeam() async* {
    if (searchController.text.isNotEmpty) {
      List<Map<String, dynamic>> reportedPosts =
          await searchReportsByQuestionContent('Accepted', 'Team_index');

      yield* Stream.value(await getReportedTeam(reportedPosts));
    } else {
      yield* FirebaseFirestore.instance
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

        return getReportedTeam(reportedPosts);

        // final teamIds = reportedPosts
        //     .map((post) => post['reportedItemId'] as String)
        //     .toList();
        //
        // List<CardFT> teams = [];
        //
        // // Paginate the query to avoid `whereIn` limitations
        // for (int i = 0; i < teamIds.length; i += 10) {
        //   List<String> batchIds = teamIds.sublist(
        //       i, (i + 10 < teamIds.length) ? i + 10 : teamIds.length);
        //
        //   if (batchIds.isEmpty) continue;
        //   final questionDocs = await FirebaseFirestore.instance
        //       .collection('Team')
        //       .where(FieldPath.documentId, whereIn: batchIds)
        //       .get();
        //
        //   final batchQuestions = questionDocs.docs.map((doc) {
        //     Map<String, dynamic> data = doc.data()!;
        //     data['docId'] = doc.id;
        //     return CardFT.fromJson(data);
        //   }).toList();
        //   // Get user-related information for each question
        //   final userIds = batchQuestions.map((team) => team.userId).toSet();
        //
        //   dynamic userMap = {};
        //   if (userIds.isNotEmpty) {
        //     final userDocs = await FirebaseFirestore.instance
        //         .collection('RegularUser')
        //         .where('email', whereIn: userIds.toList())
        //         .get();
        //
        //     userMap = Map<String, Map<String, dynamic>>.fromEntries(
        //       userDocs.docs.map((doc) => MapEntry(
        //             doc.data()!['email'] as String,
        //             doc.data()! as Map<String, dynamic>,
        //           )),
        //     );
        //   }
        //
        //   batchQuestions.forEach((team) {
        //     final userDoc = userMap[team.userId];
        //     final username = userDoc?['username'] as String? ?? '';
        //     final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';
        //
        //     final teamReports = reportedPosts
        //         .where((post) => post['reportedItemId'] == team.docId)
        //         .toList();
        //
        //     final reasons =
        //         teamReports.map((report) => report['reason'] as String).toList();
        //     final reportIds = teamReports
        //         .map((report) => report['reportedPostId'] as String)
        //         .toList();
        //
        //     final reportDate = teamReports
        //         .map((report) => report['reportDate'] as Timestamp?)
        //         .where((date) => date != null)
        //         .toList();
        //
        //     team.reportDate = reportDate.isNotEmpty
        //         ? reportDate.first!.toDate()
        //         : DateTime.now();
        //
        //     team.userType = userDoc?['userType'] as String? ?? '';
        //     team.username = username;
        //     team.userPhotoUrl = userPhotoUrl;
        //     team.reasons = reasons;
        //     team.reportDocids = reportIds;
        //   });
        //
        //   teams.addAll(batchQuestions);
        // }
        //
        // return teams;
      });
    }
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
              Stack(
                children: [
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
                        SizedBox(
                          width: 160,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 3,
                    top: -6,
                    child: Tooltip(
                      child: Container(
                        padding: EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(217, 122, 1, 1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${team.reportDocids!.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      message: 'Total number of reports on this post',
                      padding: EdgeInsets.all(10),
                      showDuration: Duration(seconds: 3),
                      textStyle: TextStyle(color: Colors.white),
                      preferBelow:
                          true, // Ensure the tooltip appears below the widget
                    ),
                  ),
                ],
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
                spacing: -5,
                runSpacing: -5,
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
                "Reasons: ${team.reasons?.join(', ')}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 92, 0, 0),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Report Date: ${DateFormat('dd/MM/yyyy').format(team.reportDate)}",
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
                      for (String reportId in team.reportDocids ?? []) {
                        _updateReportStatus('Accepted', reportId);
                      }
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
                      for (String reportId in team.reportDocids ?? []) {
                        _updateReportStatus('Rejected', reportId);
                      }
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
              Stack(
                children: [
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
                        SizedBox(
                          width: 160,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 3,
                    top: -6,
                    child: Tooltip(
                      child: Container(
                        padding: EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(217, 122, 1, 1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${team.reportDocids!.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      message: 'Total number of reports on this post',
                      padding: EdgeInsets.all(10),
                      showDuration: Duration(seconds: 3),
                      textStyle: TextStyle(color: Colors.white),
                      preferBelow:
                          true, // Ensure the tooltip appears below the widget
                    ),
                  ),
                ],
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
                spacing: -5,
                runSpacing: -5,
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
                "Reasons: ${team.reasons?.join(', ')}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 92, 0, 0),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Report Date: ${DateFormat('dd/MM/yyyy').format(team.reportDate)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 92, 0, 0),
                ),
              ),
              SizedBox(
                height: 20,
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
  Stream<List<CardFT>> readReportedProject() async* {
    if (searchController.text.isNotEmpty) {
      List<Map<String, dynamic>> reportedPosts =
          await searchReportsByQuestionContent('Pending', 'Project_index');

      yield* Stream.value(await getReportedProject(reportedPosts));
    } else {
      yield* FirebaseFirestore.instance
          .collection('Report')
          .where('status', isEqualTo: 'Pending') // Filter by status
          .orderBy('reportType', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        if (snapshot.docs.isEmpty) {
          return []; // Return an empty list if there are no reported posts.
        }

        final reportedPosts = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['reportedPostId'] = doc.id;
          return data;
        }).toList();

        return getReportedProject(reportedPosts);
      });
    }
  }

  Future<List<CardFT>> getReportedProject(
      List<Map<String, dynamic>> reportedPosts) async {
    final projectIds =
        reportedPosts.map((post) => post['reportedItemId'] as String).toList();

    List<CardFT> projects = [];

    // Paginate the query to avoid `whereIn` limitations
    for (int i = 0; i < projectIds.length; i += 10) {
      List<String> batchIds = projectIds.sublist(
          i, (i + 10 < projectIds.length) ? i + 10 : projectIds.length);

      if (batchIds.isEmpty) continue;
      final questionDocs = await FirebaseFirestore.instance
          .collection('Project')
          .where(FieldPath.documentId, whereIn: batchIds)
          .get();

      final batchQuestions = questionDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['docId'] = doc.id;
        return CardFT.fromJson(data);
      }).toList();
      // Get user-related information for each question
      final userIds = batchQuestions.map((project) => project.userId).toSet();

      dynamic userMap = {};
      if (userIds.isNotEmpty) {
        final userDocs = await FirebaseFirestore.instance
            .collection('RegularUser')
            .where('email', whereIn: userIds.toList())
            .get();

        userMap = Map<String, Map<String, dynamic>>.fromEntries(
          userDocs.docs.map((doc) => MapEntry(
                doc.data()!['email'] as String,
                doc.data()! as Map<String, dynamic>,
              )),
        );
      }

      batchQuestions.forEach((project) {
        final userDoc = userMap[project.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';

        final projectReports = reportedPosts
            .where((post) => post['reportedItemId'] == project.docId)
            .toList();

        final reasons =
            projectReports.map((report) => report['reason'] as String).toList();
        final reportIds = projectReports
            .map((report) => report['reportedPostId'] as String)
            .toList();

        final reportDate = projectReports
            .map((report) => report['reportDate'] is int
                ? Timestamp.fromMicrosecondsSinceEpoch(
                    report['reportDate'] as int)
                : report['reportDate'] as Timestamp?)
            .where((date) => date != null)
            .toList();

        project.reportDate =
            reportDate.isNotEmpty ? reportDate.first!.toDate() : DateTime.now();

        project.userType = userDoc?['userType'] as String? ?? '';
        project.username = username;
        project.userPhotoUrl = userPhotoUrl;
        project.reasons = reasons;
        project.reportDocids = reportIds;
      });

      projects.addAll(batchQuestions);
    }

    return projects;
  }

  Stream<List<CardFT>> readOldReportedProject() async* {
    if (searchController.text.isNotEmpty) {
      List<Map<String, dynamic>> reportedPosts =
          await searchReportsByQuestionContent('Accepted', 'Project_index');

      yield* Stream.value(await getReportedProject(reportedPosts));
    } else {
      yield* FirebaseFirestore.instance
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

        return getReportedProject(reportedPosts);

        // final projectIds = reportedPosts
        //     .map((post) => post['reportedItemId'] as String)
        //     .toList();
        //
        // List<CardFT> projects = [];
        //
        // // Paginate the query to avoid `whereIn` limitations
        // for (int i = 0; i < projectIds.length; i += 10) {
        //   List<String> batchIds = projectIds.sublist(
        //       i, (i + 10 < projectIds.length) ? i + 10 : projectIds.length);
        //
        //   if (batchIds.isEmpty) continue;
        //   final questionDocs = await FirebaseFirestore.instance
        //       .collection('Project')
        //       .where(FieldPath.documentId, whereIn: batchIds)
        //       .get();
        //
        //   final batchQuestions = questionDocs.docs.map((doc) {
        //     Map<String, dynamic> data = doc.data()!;
        //     data['docId'] = doc.id;
        //     return CardFT.fromJson(data);
        //   }).toList();
        //   // Get user-related information for each question
        //   final userIds = batchQuestions.map((project) => project.userId).toSet();
        //
        //   dynamic userMap = {};
        //   if (userIds.isNotEmpty) {
        //     final userDocs = await FirebaseFirestore.instance
        //         .collection('RegularUser')
        //         .where('email', whereIn: userIds.toList())
        //         .get();
        //
        //     userMap = Map<String, Map<String, dynamic>>.fromEntries(
        //       userDocs.docs.map((doc) => MapEntry(
        //             doc.data()!['email'] as String,
        //             doc.data()! as Map<String, dynamic>,
        //           )),
        //     );
        //   }
        //
        //   batchQuestions.forEach((project) {
        //     final userDoc = userMap[project.userId];
        //     final username = userDoc?['username'] as String? ?? '';
        //     final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';
        //
        //     final projectReports = reportedPosts
        //         .where((post) => post['reportedItemId'] == project.docId)
        //         .toList();
        //
        //     final reasons = projectReports
        //         .map((report) => report['reason'] as String)
        //         .toList();
        //     final reportIds = projectReports
        //         .map((report) => report['reportedPostId'] as String)
        //         .toList();
        //
        //     final reportDate = projectReports
        //         .map((report) => report['reportDate'] as Timestamp?)
        //         .where((date) => date != null)
        //         .toList();
        //
        //     project.reportDate = reportDate.isNotEmpty
        //         ? reportDate.first!.toDate()
        //         : DateTime.now();
        //
        //     project.userType = userDoc?['userType'] as String? ?? '';
        //     project.username = username;
        //     project.userPhotoUrl = userPhotoUrl;
        //     project.reasons = reasons;
        //     project.reportDocids = reportIds;
        //   });
        //
        //   projects.addAll(batchQuestions);
        // }
        //
        // return projects;
      });
    }
  }

  // answer

  Stream<List<CardAnswer>> readReportedAnswer() async* {
    if (searchController.text.isNotEmpty) {
      List<Map<String, dynamic>> reportedPosts =
          await searchReportsByQuestionContent('Pending', 'Answer_index');

      yield* Stream.value(await getReportedAnswers(reportedPosts));
    } else {
      yield* FirebaseFirestore.instance
          .collection('Report')
          .where('status', isEqualTo: 'Pending') // Filter by status
          .orderBy('reportType', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        if (snapshot.docs.isEmpty) {
          return []; // Return an empty list if there are no reported posts.
        }

        final reportedPosts = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['reportedPostId'] = doc.id;
          return data;
        }).toList();

        return getReportedAnswers(reportedPosts);
      });
    }
  }

  Future<List<CardAnswer>> getReportedAnswers(
      List<Map<String, dynamic>> reportedPosts) async {
    final answerIds =
        reportedPosts.map((post) => post['reportedItemId'] as String).toList();

    List<CardAnswer> answers = [];

    // Paginate the query to avoid `whereIn` limitations
    for (int i = 0; i < answerIds.length; i += 10) {
      List<String> batchIds = answerIds.sublist(
          i, (i + 10 < answerIds.length) ? i + 10 : answerIds.length);

      if (batchIds.isEmpty) continue;
      final answerDocs = await FirebaseFirestore.instance
          .collection('Answer')
          .where(FieldPath.documentId, whereIn: batchIds)
          .get();

      final batchAnswers = answerDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['docId'] = doc.id;
        return CardAnswer.fromJson(data);
      }).toList();

      final userIds = batchAnswers.map((answer) => answer.userId).toSet();
      if (batchAnswers.isEmpty || userIds.isEmpty) continue;
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

      batchAnswers.forEach((answer) {
        final userDoc = userMap[answer.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';

        final reportedPost = reportedPosts.firstWhere(
          (post) => post['reportedItemId'] == answer.docId,
          orElse: () => <String, dynamic>{},
        );
        final answerReports = reportedPosts
            .where((post) => post['reportedItemId'] == answer.docId)
            .toList();
        final reportIds =
            answerReports.map((e) => e['reportedPostId'] as String).toList();
        final reason = reportedPost['reason'] as String? ?? '';
        final reportDocid = reportedPost['reportedPostId'] as String? ?? '';

        final reasons =
            answerReports.map((report) => report['reason'] as String).toList();
        answer.reasons = reasons;

        answer.userType = userDoc?['userType'] as String? ?? "";
        answer.username = username;
        answer.userPhotoUrl = userPhotoUrl;
        answer.reason = reason;
        answer.reportDocid = reportDocid;
        answer.reportDocids = reportIds;
      });

      answers.addAll(batchAnswers);
    }

    return answers;
  }

  Stream<List<CardAnswer>> readOldReportedAnswer() async* {
    if (searchController.text.isNotEmpty) {
      List<Map<String, dynamic>> reportedPosts =
          await searchReportsByQuestionContent('Accepted', 'Answer_index');

      yield* Stream.value(await getReportedAnswers(reportedPosts));
    } else {
      yield* FirebaseFirestore.instance
          .collection('Report')
          .where('status', isEqualTo: 'Accepted') // Filter by status

          .orderBy('reportType', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        if (snapshot.docs.isEmpty) {
          return []; // Return an empty list if there are no reported posts.
        }

        final reportedPosts = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['reportedPostId'] = doc.id;
          return data;
        }).toList();

        return getReportedAnswers(reportedPosts);
      });
    }
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
            backgroundImage:
                answer.userPhotoUrl != '' && answer.userPhotoUrl != null
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
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (answer.userId.isNotEmpty &&
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
                        child: Row(
                          children: [
                            Text(
                              answer.username ?? '', // Display the username
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 34, 3, 87),
                                  fontSize: 16),
                            ),
                            if (answer.userType == "Freelancer")
                              Icon(
                                Icons.verified,
                                color: Colors.deepPurple,
                                size: 20,
                              ),
                            SizedBox(
                              width: 160,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 3,
                        top: -6,
                        child: Tooltip(
                          child: Container(
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(217, 122, 1, 1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${answer.reportDocids?.length ?? 0}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          message: 'Total number of reports on this post',
                          padding: EdgeInsets.all(10),
                          showDuration: Duration(seconds: 3),
                          textStyle: TextStyle(color: Colors.white),
                          preferBelow:
                              true, // Ensure the tooltip appears below the widget
                        ),
                      ),
                    ],
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
                "Reasons: ${answer.reasons?.join(', ')}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 92, 0, 0),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Report Date: ${DateFormat('dd/MM/yyyy').format(answer.reportDate)}",
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
                      for (String reportId in answer.reportDocids ?? []) {
                        _updateReportStatus('Accepted', reportId);
                      }
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
                      for (String reportId in answer.reportDocids ?? []) {
                        _updateReportStatus('Rejected', reportId);
                      }
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
                  SizedBox(
                    width: 170,
                  ),
                  if (answer.reportDocids != null &&
                      answer.reportDocids!
                          .isNotEmpty) // Condition to check if reports exist
                    Container(
                        padding: EdgeInsets.all(6),
                        margin:
                            EdgeInsets.only(left: 5), // Adjust margin as needed
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(217, 122, 1, 1),
                        ),
                        child: Text(
                          '${answer.reportDocids!.length}',
                          // Show the number of reports
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
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
                "Reasons: ${answer.reasons?.join(', ')}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 92, 0, 0),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Report Date: ${DateFormat('dd/MM/yyyy').format(answer.reportDate)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 92, 0, 0),
                ),
              ),
              SizedBox(
                height: 20,
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
