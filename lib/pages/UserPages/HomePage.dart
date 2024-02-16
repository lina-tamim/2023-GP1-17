import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/Models/FormCard.dart';
import 'package:techxcel11/Models/PostCard.dart';
import 'package:techxcel11/Models/QuestionCard.dart';
import 'package:techxcel11/pages/UserPages/AnswerPage.dart';
import 'package:techxcel11/pages/UserPages/UserProfileView.dart';
import 'dart:developer';
import 'package:techxcel11/providers/profile_provider.dart';

class FHomePage extends StatefulWidget {
  const FHomePage({Key? key}) : super(key: key);

  @override
  __FHomePageState createState() => __FHomePageState();
}

int _currentIndex = 0;

class __FHomePageState extends State<FHomePage> {
  String loggedInEmail = '';
  String loggedImage = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// lina add
  String? selectedOption;
  List<String> dropDownOptions = [
    'Inappropriate content',
    'Spam',
    'Harassment',
    'False information',
    'Violence',
    'Hate speech',
    'Bullying',
    'Others'
    // Add more options as needed
  ];

  // Clear the selected option after reporting

  Future<bool> checkIfPostExists(String collectionName, String postId) async {
    bool exists = false;

    // Query Firestore to check if the document exists
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(postId)
        .get();

    exists = snapshot.exists;

    return exists;
  }

  @override
  void initState() {
    super.initState();

    fetchUserData();
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('RegularUser')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs[0].data();

      final username = userData['username'] ?? '';
      final imageURL = userData['imageURL'] ?? '';

      setState(() {
        loggedInEmail = email;
        loggedImage = imageURL;
      });
    }
    context.read<ProfileProvider>();
  }

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
      query = query
          .where('postDescription', isGreaterThanOrEqualTo: searchText)
          .where('postDescription', isLessThan: searchText + 'z');
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
        question.userType = userDoc?['userType'] as String? ?? "";
        // question.userId = userDoc ?['userId'] as String;
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
      String searchText = searchController.text;
      //String newVal = searchText[0].toUpperCase() + searchText.substring(1);
      //.toLowerCase(); // Convert search text to lowercase
      query = query
          .where('postTitle', isGreaterThanOrEqualTo: searchText)
          .where('postTitle', isLessThan: searchText + 'z');
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
        question.userType = userDoc?['userType'] as String? ?? '';
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
      String searchText = searchController.text;
      //.toLowerCase(); // Convert search text to lowercase
      query = query
          .where('postTitle', isGreaterThanOrEqualTo: searchText)
          .where('postTitle', isLessThan: searchText + 'z');
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
        question.userType = userDoc?['userType'] as String? ?? '';
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
                    icon: Icon(Icons.bookmark,
                        color: Color.fromARGB(255, 63, 63, 63)),
                    onPressed: () {
                      addQuestionToBookmarks(loggedInEmail, question);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.comment,
                        color: Color.fromARGB(255, 63, 63, 63)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AnswerPage(questionDocId: question.questionDocId)),
                      );
                    },
                  ),
                  
                  IconButton(
                    icon: Icon(Icons.report,
                        color: Color.fromARGB(255, 63, 63, 63)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              String? initialOption = null;
                              TextEditingController customReasonController =
                                  TextEditingController();

                              return AlertDialog(
                                title: Text('Report Post'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    DropdownButton<String>(
                                      value: selectedOption,
                                      hint: Text('Select a reason'),
                                      onTap: () {
                                        // Set the initialOption to the selectedOption
                                        initialOption = selectedOption;
                                      },
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedOption = newValue!;
                                        });
                                      },
                                      items:
                                          dropDownOptions.map((String option) {
                                        return DropdownMenuItem<String>(
                                          value: option,
                                          child: Text(option),
                                        );
                                      }).toList(),
                                    ),
                                    Visibility(
                                      visible: selectedOption == 'Others',
                                      child: TextFormField(
                                        controller: customReasonController,
                                        decoration: InputDecoration(
                                            labelText: 'Enter your reason'),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      // Reset the selectedOption to the initialOption when canceling
                                      setState(() {
                                        selectedOption = initialOption;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Report'),
                                    onPressed: () {
                                      if (selectedOption != null) {
                                        String reason;
                                        if (selectedOption == 'Others') {
                                          reason = customReasonController.text;
                                        } else {
                                          reason = selectedOption!;
                                        }
                                        if (reason.isNotEmpty) {
                                          // Check if a reason is provided
                                          handleReportQuestion(
                                              loggedInEmail, question, reason);
                                          toastMessage(
                                              'Your report has been sent successfully');
                                          Navigator.of(context).pop();
                                        } else {
                                          // Show an error message or handle the case where no reason is provided
                                          print(
                                              'Please provide a reason for reporting.');
                                        }
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
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

    final formattedDate = DateFormat.yMMMMd().format(team.date);

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
                        ),
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
                  context
                      .read<ProfileProvider>()
                      .gotoChat(context, team.userId);
                  log('MK: clicked on Message: ${team.userId}');
                },
              ),
              IconButton(
                icon:
                    Icon(Icons.report, color: Color.fromARGB(255, 63, 63, 63)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          // Set the initial selectedOption to null
                          String? initialOption = null;
                          TextEditingController customReasonController =
                              TextEditingController();

                          return AlertDialog(
                            title: Text('Report Post'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                DropdownButton<String>(
                                  value: selectedOption,
                                  hint: Text('Select a reason'),
                                  onTap: () {
                                    // Set the initialOption to the selectedOption
                                    initialOption = selectedOption;
                                  },
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedOption = newValue!;
                                    });
                                  },
                                  items: dropDownOptions.map((String option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(option),
                                    );
                                  }).toList(),
                                ),
                                Visibility(
                                  visible: selectedOption == 'Others',
                                  child: TextFormField(
                                    controller: customReasonController,
                                    decoration: InputDecoration(
                                        labelText: 'Enter your reason'),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  // Reset the selectedOption to the initialOption when canceling
                                  setState(() {
                                    selectedOption = initialOption;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Report'),
                                onPressed: () async {
                                  if (selectedOption != null) {
                                    String reason;
                                    if (selectedOption == 'Others') {
                                      reason = customReasonController.text;
                                    } else {
                                      reason = selectedOption!;
                                    }

                                    if (team is CardFT &&
                                        team.teamDocId != null) {
                                      String postId = team.teamDocId!;
                                      bool isTeamPost = await checkIfPostExists(
                                          'Team', postId);
                                      bool isProjectPost =
                                          await checkIfPostExists(
                                              'Project', postId);

                                      if (isTeamPost) {
                                        handleReportTeam(
                                            loggedInEmail, team, reason);
                                      } else if (isProjectPost) {
                                        handleReportProject(
                                            loggedInEmail, team, reason);
                                      } else {
                                        toastMessage('Invalid team');
                                      }

                                      toastMessage(
                                          'Your report has been sent successfully');
                                      Navigator.of(context).pop();
                                    } else {
                                      // Handle the cases when team is not an instance of CardFT or postId is null
                                      toastMessage('Invalid team');
                                    }
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
          Container(
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
                      if (loggedImage.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(loggedImage),
                          ),
                        ),
                      const SizedBox(width: 8),
                      const Text(
                        'Home           ',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Poppins",
                          color: Color.fromRGBO(37, 6, 81, 0.898),
                        ),
                      ),
                      const SizedBox(width: 120),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showSearchBar = !showSearchBar;
                          });
                        },
                        icon: Icon(
                            showSearchBar ? Icons.search_off : Icons.search),
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
              // Set the color of the selected tab's text
              tabs: [
                Tab(
                  child: Text('Questions'),
                ),
                Tab(
                  child: Text('Build Team'),
                ),
                Tab(
                  child: Text('Projects'),
                ),
              ],
            )),

        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () async {
            showInputDialog();
          },
          backgroundColor: Color.fromARGB(255, 13, 13, 15),
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

  Future<void> addQuestionToBookmarks(
      String email, CardQuestion question) async {
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

  void handleReportQuestion(
    String email,
    CardQuestion question,
    String reason,
  ) async {
    String? postId = question.questionDocId; // Get the post ID

    await _firestore.collection('Report').add({
      'reportedItemId': postId,
      'reason': reason, // Use the provided reason parameter
      'reportDate': DateTime.now(),
      'reportType': "Question",
      'status': 'Pending',
    });

    // Clear the selected option after reporting
    selectedOption = null;
  }

  void handleReportTeam(
    String email,
    CardFT team,
    String reason, // Accept reason as a parameter
  ) async {
    String? postId = team.teamDocId; // Get the post ID

    // Create a new document in the "Report" collection in Firestore
    await FirebaseFirestore.instance.collection('Report').add({
      'reportedItemId': postId,
      'reason': reason, // Use the provided reason parameter
      'reportDate': DateTime.now(),
      'reportType': "Team",
      'status': 'Pending', 
    });

    // Clear the selected option after reporting
    selectedOption = null;
  }

  void handleReportProject(
    String email,
    CardFT team,
    String reason, // Accept reason as a parameter
  ) async {
    String? postId = team.teamDocId; // Get the post ID

    // Create a new document in the "Report" collection in Firestore
    await FirebaseFirestore.instance.collection('Report').add({
      'reportedItemId': postId,
      'reason': reason, // Use the provided reason parameter
      'reportDate': DateTime.now(),
      'reportType': "Project",
      'status': 'Pending', 
    });

    // Clear the selected option after reporting
    selectedOption = null;
  }
}
