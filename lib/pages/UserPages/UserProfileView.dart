import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/Models/AnswerCard.dart';
import 'package:techxcel11/Models/PostCard.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/pages/UserPages/AnswerPage.dart';
import 'package:techxcel11/pages/UserPages/EditUserProfilePage.dart';
import 'package:techxcel11/providers/profile_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Models/QuestionCard.dart';
import 'package:techxcel11/pages/UserPages/HomePage.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key, required this.userId});

  final String userId;

  @override
  _UserProfileView createState() => _UserProfileView();
}

int _currentIndex = 0;

class _UserProfileView extends State<UserProfileView>
    with TickerProviderStateMixin {
  TabController? tabController;
  List<String> imageList = [
    'assets/UserBackground/background1.jpeg',
    'assets/UserBackground/background2.jpeg',
    'assets/UserBackground/background3.jpeg',
    // add more image paths or URLs here
  ];

  String currentEmail = '';
  Future<String> fetchuseremail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';
    currentEmail = email;
    return email;
  }

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
//retrive info from DB

  String _loggedInImage = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String city = '';
  String country = '';
  String email = '';
  String? imageURL;
  String? githubURL;
  List<String> interests = [];
  List<String> skills = [];
  String username = '';
  String usertype = '';
  int userScore = 0;
  bool isLoading = true; // Added loading state

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchuseremail();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('RegularUser')
        .where('email', isEqualTo: widget.userId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs[0].data();

      final usernamedb = userData['username'] ?? '';
      final imageURLdb = userData['imageURL'] ?? '';
      final citydb = userData['city'] ?? '';
      final countrydb = userData['country'] ?? '';
      final emaildb = userData['email'] ?? '';
      final githubURLdb = userData['githubLink'];
      final usertypedb = userData['userType'];
      userScore = userData['userScore'];

      final interestsdb = List<String>.from(userData['interests'] ?? []);
      final skillsdb = List<String>.from(userData['skills'] ?? []);

      setState(() {
        city = citydb;
        country = countrydb;
        email = emaildb;
        imageURL = imageURLdb;
        username = usernamedb;
        githubURL = githubURLdb;
        interests = interestsdb;
        skills = skillsdb;
        usertype = usertypedb;
        isLoading = false; // Set loading state to false when data is fetched
      });
    }
  }

  Stream<List<CardQuestion>> readQuestion() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Question')
        .where('userId', isEqualTo: email)
        .orderBy('postedDate', descending: true);

    return query.snapshots().asyncMap((snapshot) async {
      final questions = snapshot.docs.map((doc) {
        final questionData = doc.data() as Map<String, dynamic>;
        final question = CardQuestion.fromJson(questionData);
        question.docId = doc.id; // Set the docId to the actual document ID
        return question;
      }).toList();
      if (questions.isEmpty) return [];
      // Query the Report collection to get accepted questionIds
      QuerySnapshot<Map<String, dynamic>> reportSnapshot =
          await FirebaseFirestore.instance
              .collection('Report')
              .where('reportType', isEqualTo: 'Question')
              .where('status', isEqualTo: 'Accepted')
              .get();

      Set<String> acceptedQuestionIds = reportSnapshot.docs
          .map((doc) => doc['reportedItemId'] as String)
          .toSet();

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

      List<CardQuestion> filteredQuestions = questions
          .where((question) => !acceptedQuestionIds.contains(question.docId))
          .toList();

      return filteredQuestions;
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
              GestureDetector(
                onTap: () {
                  if (question.userId != null && question.userId.isNotEmpty) {
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
                          color: Color.fromARGB(255, 24, 8, 53),
                          fontSize: 14),
                    ),
                    if (question.userType == "Freelancer")
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: Colors.deepPurple,
                            size: 20,
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(question.postedDate),
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Text(
                question.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.4,
                ),
              ),
              SizedBox(height: 5),
              Text(question.description,
                  style: TextStyle(
                    fontSize: 12,
                  )),
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
                              style: TextStyle(fontSize: 10.0),
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
                    icon: Icon(
                      Icons.bookmark,
                      color: currentEmail == 'texelad1@gmail.com'
                          ? const Color.fromARGB(24, 63, 63, 63)
                          : Color.fromARGB(255, 63, 63, 63),
                    ),
                    onPressed: currentEmail == 'texelad1@gmail.com'
                        ? null
                        : () {
                            addQuestionToBookmarks(email, question);
                          },
                          iconSize: 18,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.comment,
                          color: currentEmail == 'texelad1@gmail.com'
                              ? const Color.fromARGB(24, 63, 63, 63)
                              : Color.fromARGB(255, 63, 63, 63),
                        ),
                        iconSize: 18,
                        onPressed: currentEmail == 'texelad1@gmail.com'
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnswerPage(
                                        questionDocId: question.questionDocId),
                                  ),
                                );
                              },
                      ),
                      Text(
            question.noOfAnswers.toString(),
            style: TextStyle(fontSize: 14),
          ),
                    ],
                  ),
                  IconButton(
                    icon: currentEmail != email
                        ? Icon(Icons.report,
                            color: Color.fromARGB(255, 63, 63, 63))
                        : SizedBox.shrink(),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
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
                                              email, question, reason);
                                          toastMessage(
                                              'Your report has been sent successfully');
                                          Navigator.of(context).pop();
                                        } else {
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

  Stream<List<CardFT>> readTeam() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Team')
        .where('userId', isEqualTo: email)
        .orderBy('postedDate', descending: true);

    return query.snapshots().asyncMap((snapshot) async {
      final questions = snapshot.docs.map((doc) {
        final questionData = doc.data() as Map<String, dynamic>;
        final question = CardFT.fromJson(questionData);
        question.docId = doc.id; // Set the docId to the actual document ID
        return question;
      }).toList();

      if (questions.isEmpty) return [];
      // Query the Report collection to get accepted questionIds
      QuerySnapshot<Map<String, dynamic>> reportSnapshot =
          await FirebaseFirestore.instance
              .collection('Report')
              .where('reportType', isEqualTo: 'Team')
              .where('status', isEqualTo: 'Accepted')
              .get();

      Set<String> acceptedQuestionIds = reportSnapshot.docs
          .map((doc) => doc['reportedItemId'] as String)
          .toSet();
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
      // Filter out questions with docId present in the Report collection with reportType = "Question" and status = "Accepted"
      List<CardFT> filteredQuestions = questions
          .where((question) => !acceptedQuestionIds.contains(question.docId))
          .toList();

      return filteredQuestions;
    });
  }

  Stream<List<CardFT>> readProjects() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Project')
        .where('userId', isEqualTo: email)
        .orderBy('postedDate', descending: true);

    return query.snapshots().asyncMap((snapshot) async {
      final questions = snapshot.docs.map((doc) {
        final questionData = doc.data() as Map<String, dynamic>;
        final question = CardFT.fromJson(questionData);
        question.docId = doc.id; // Set the docId to the actual document ID
        return question;
      }).toList();
      if (questions.isEmpty) return [];
      // Query the Report collection to get accepted questionIds
      QuerySnapshot<Map<String, dynamic>> reportSnapshot =
          await FirebaseFirestore.instance
              .collection('Report')
              .where('reportType', isEqualTo: 'Project')
              .where('status', isEqualTo: 'Accepted')
              .get();

      Set<String> acceptedQuestionIds = reportSnapshot.docs
          .map((doc) => doc['reportedItemId'] as String)
          .toSet();

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
      // Filter out questions with docId present in the Report collection with reportType = "Question" and status = "Accepted"
      List<CardFT> filteredQuestions = questions
          .where((question) => !acceptedQuestionIds.contains(question.docId))
          .toList();

      return filteredQuestions;
    });
  }

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
                Row(
                  children: [
                    Text(
                      team.username ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 34, 3, 87),
                        fontSize: 16,
                      ),
                    ),
                    if (usertype == "Freelancer")
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
                          DateFormat('dd/MM/yyyy').format(team.postedDate),
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  team.title,
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.4,
                ),
                ),
                SizedBox(height: 5),
                Text(team.description,  style: TextStyle(
                    fontSize: 12,
                  )),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                width: 400, // Set a fixed width for the skills container
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      team.topics.length,
                      (intrestsIndex) {
                        final intrest =
                            team.topics[intrestsIndex] as String;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Chip(
                            label: Text(
                              intrest,
                              style: TextStyle(fontSize: 10.0),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Visibility(
                visible: currentEmail != email,
                child: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.solidMessage,
                    color: currentEmail == 'texelad1@gmail.com'
                        ? const Color.fromARGB(24, 63, 63, 63)
                        : Color.fromARGB(255, 63, 63, 63),
                    size: 18.5,
                  ),
                  onPressed: currentEmail == 'texelad1@gmail.com'
                      ? null
                      : () {
                          context
                              .read<ProfileProvider>()
                              .gotoChat(context, team.userId);
                        },
                ),
              ),
              Visibility(
                visible: currentEmail != email,
                child: IconButton(
                  icon: Icon(Icons.report,
                      color: Color.fromARGB(255, 63, 63, 63)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
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
                                        bool isTeamPost =
                                            await checkIfPostExists(
                                                'Team', postId);
                                        bool isProjectPost =
                                            await checkIfPostExists(
                                                'Project', postId);

                                        if (isTeamPost) {
                                          handleReportTeam(email, team, reason);
                                        } else if (isProjectPost) {
                                          handleReportProject(
                                              email, team, reason);
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

  Stream<List<CardAnswer>> readAnswers() {
    String x = '';
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Answer')
        .where('userId', isEqualTo: email)
        .orderBy('postedDate', descending: true);

    return query.snapshots().asyncMap((snapshot) async {
      final questions = snapshot.docs.map((doc) {
        final cardAnswer =
            CardAnswer.fromJson(doc.data() as Map<String, dynamic>);
        x = doc.id; // Assign the document ID to the docId field
        return cardAnswer;
      }).toList();
      if (questions.isEmpty) return [];

      // Query the Report collection to get accepted questionIds
      QuerySnapshot<Map<String, dynamic>> reportSnapshot =
          await FirebaseFirestore.instance
              .collection('Report')
              .where('reportType', isEqualTo: 'Answer')
              .where('status', isEqualTo: 'Accepted')
              .get();

      Set<String> acceptedQuestionIds = reportSnapshot.docs
          .map((doc) => doc['reportedItemId'] as String)
          .toSet();

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
        question.docId = x;
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
      List<CardAnswer> filteredQuestions = questions
          .where((question) => !acceptedQuestionIds.contains(question.docId))
          .toList();

      return filteredQuestions;
    });
  }

  Widget buildAnswerCard(CardAnswer answer) {
    int upvoteCount = answer.upvoteCount ?? 0;
    List<String> upvotedUserIds = answer.upvotedUserIds ?? [];
    String doc = answer.docId;


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
                  Text(
                    answer.username ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 34, 3, 87),
                      fontSize: 16,
                    ),
                  ),
                  if (usertype == "Freelancer")
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
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              ListTile(
                title: 
                Text(
            answer.answerText,
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  isLoading
                      ? CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(
                                currentEmail == 'texelad1@gmail.com'
                                    ? null
                                    : upvotedUserIds.contains(currentEmail)
                                        ? Icons.arrow_circle_down
                                        : Icons.arrow_circle_up,
                                size: 20, // Adjust the size as needed
                                color: upvotedUserIds.contains(currentEmail)
                                    ? const Color.fromARGB(255, 49, 3,
                                        0) // Color for arrow_circle_down
                                    : const Color.fromARGB(255, 26, 33,
                                        20), // Color for arrow_circle_up
                              ),
                              onPressed: () {
                                setState(() {
                                  if (upvotedUserIds.contains(currentEmail)) {
                                    upvotedUserIds.remove(currentEmail);
                                    upvoteCount--;

                                    // Decrease userScore in RegularUser collection
                                    FirebaseFirestore.instance
                                        .collection('RegularUser')
                                        .where('email',
                                            isEqualTo: answer.userId)
                                        .get()
                                        .then(
                                            (QuerySnapshot<Map<String, dynamic>>
                                                snapshot) {
                                      if (snapshot.docs.isNotEmpty) {
                                        final documentId = snapshot.docs[0].id;

                                        FirebaseFirestore.instance
                                            .collection('RegularUser')
                                            .doc(documentId)
                                            .update({
                                          'userScore': FieldValue.increment(-1),
                                        }).catchError((error) {
                                          // Handle error if the update fails
                                        });
                                      }
                                    }).catchError((error) {});
                                    FirebaseFirestore.instance
                                        .collection('Question')
                                        .doc(answer.questionDocId)
                                        .update({
                                      'totalUpvotes': FieldValue.increment(-1),
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
                                        .then(
                                            (QuerySnapshot<Map<String, dynamic>>
                                                snapshot) {
                                      if (snapshot.docs.isNotEmpty) {
                                        final documentId = snapshot.docs[0].id;

                                        FirebaseFirestore.instance
                                            .collection('RegularUser')
                                            .doc(documentId)
                                            .update({
                                          'userScore': FieldValue.increment(1),
                                        }).catchError((error) {});
                                      }
                                    }).catchError((error) {});
                                    FirebaseFirestore.instance
                                        .collection('Question')
                                        .doc(answer.questionDocId)
                                        .update({
                                      'totalUpvotes': FieldValue.increment(1),
                                    }).catchError((error) {});
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
                            Text(
           'Upvotes: $upvoteCount',
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
                          ],
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Account'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                buildReasonItem(context, 'Inappropriate Content'),
                buildReasonItem(context, 'Spam'),
                buildReasonItem(context, 'Abuse & Harassment'),
                buildReasonItem(context, 'Impersonation'),
                buildOtherReasonItem(context),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget buildReasonItem(BuildContext context, String reason) {
    return ListTile(
      title: Text(reason),
      onTap: () {
        showConfirmationDialog(context, reason);
      },
    );
  }

  void showConfirmationDialog(BuildContext context, String selectedReason) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Report'),
          content: const Text('Are you sure you want to report this account?'),
          actions: [
            TextButton(
              onPressed: () {
                handleReportAccount(context, email, selectedReason);
                Navigator.pop(context);
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        'Report Submitted',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      content: const Text(
                          'We will check your request and take appropriate action. Thank you for keeping it cool!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Ok'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  Widget buildOtherReasonItem(BuildContext context) {
    return ListTile(
      title: const Text('Others'),
      onTap: () {
        Navigator.pop(context); // Close the current dialog
        showOtherReasonDialog(
            context); // Show a dialog for typing custom reason
      },
    );
  }

  void showOtherReasonDialog(BuildContext context) {
    String customReason = ''; // Variable to hold the custom reason value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Custom Reason'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'Type your reason here',
            ),
            onChanged: (value) {
              customReason =
                  value; // Update the customReason variable as the user types
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        'Report Submitted',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      content: const Text(
                          'We will check your request and take appropriate action. Thank you for keeping it cool!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Ok'),
                        ),
                      ],
                    );
                  },
                );
                handleReportAccount(context, email,
                    customReason); // Pass the customReason to the handleReportAccount method
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void handleReportAccount(BuildContext context, String email, String reason) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Retrieve postId based on email from RegularUser collection
    firestore
        .collection('RegularUser')
        .where('email', isEqualTo: email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document that matches the query
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        String postId = documentSnapshot.id;

        // Add report to Firestore
        firestore.collection('Report').add({
          'reportedItemId': postId,
          'reason': reason,
          'reportDate': DateTime.now(),
          'reportType': 'Account',
          'reportedUserId': email,
          'status': 'Pending',
          'seen': false,
        }).catchError((error) {
          print('Error submitting report: $error');
          // Handle error, show an error dialog, or take appropriate action
        });
      } else {
        print('User not found');
      }
    }).catchError((error) {
      print('Error retrieving user: $error');
    });
  }

  String _extractUsername(String githubURL) {
    List<String> parts = githubURL.split('/');
    if (parts.length >= 4) {
      return parts[3];
    } else {
      return 'GitHub';
    }
  }

  @override
  Widget build(BuildContext context) {
    final TabController tabController = TabController(length: 4, vsync: this);
    int randomIndex = Random().nextInt(imageList.length);
    String randomImage = imageList[randomIndex];
    String Githubusername =
        githubURL != null ? _extractUsername(githubURL!) : 'GitHub';

    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 150.0,
                  floating: true,
                  snap: true,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          randomImage,
                          fit: BoxFit.cover,
                        ), //Container(color: Color.fromRGBO(100, 100, 100, 250)),
                      ),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: CircleAvatar(
                          backgroundImage: imageURL != null &&
                                  imageURL!.isNotEmpty
                              ? NetworkImage(imageURL!)
                              : AssetImage(
                                      'assets/Backgrounds/defaultUserPic.png')
                                  as ImageProvider<Object>,
                          radius: 40,
                        ),
                      ),
                      if (currentEmail != email)
                        Container(
                          alignment: Alignment.topRight,
                          margin: const EdgeInsets.all(20),
                          child: IconButton(
                            onPressed: () {
                              showReportDialog(context);
                            },
                            icon: const Icon(Icons.report,
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                        ),
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.all(20),
                        child: OutlinedButton(
                          child: Text(
                            currentEmail == email
                                ? "My profile"
                                : currentEmail == 'texelad1@gmail.com'
                                    ? ""
                                    : "Chat with $username",
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            if (currentEmail == email) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfile2(),
                                ),
                              );
                              // Add the behavior for chatting with oneself
                              // For example, display a message or show an alert
                            } else {
                              context
                                  .read<ProfileProvider>()
                                  .gotoChat(context, email);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(left: 8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Text(
                              '$username  ',
                              style: const TextStyle(
                                  fontSize: 23, fontWeight: FontWeight.bold),
                            ),
                            if (usertype == 'Freelancer')
                              Icon(
                                Icons.verified,
                                size: 25,
                                color: Colors.deepPurple,
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: [
                              Tooltip(
                                child: const Icon(
                                  Icons.star_rounded,
                                  color: Color.fromARGB(255, 209, 196, 25),
                                  size: 18,
                                ),
                               decoration: BoxDecoration(
                      color: Color.fromARGB(177, 40, 0, 75), 
                      borderRadius: BorderRadius.circular(8.0), 
                    ),
                                message:
                                    'This is the total number of Upvote received \nfor positive interactions!',
                                padding: EdgeInsets.all(10),
                                showDuration: Duration(seconds: 3),
                                textStyle: TextStyle(color: Colors.white),
                                preferBelow: false,
                              ),
                              Tooltip(
                                child: Text(userScore.toString()),
                               decoration: BoxDecoration(
                      color: Color.fromARGB(177, 40, 0, 75), 
                      borderRadius: BorderRadius.circular(8.0), 
                    ),
                                message:
                                    'This is the total number of Upvote received \nfor positive interactions!',
                                padding: EdgeInsets.all(10),
                                showDuration: Duration(seconds: 3),
                                textStyle: TextStyle(color: Colors.white),
                                preferBelow: false,
                              ),
                            ],
                          ),
                        ),
                        if (githubURL != null && githubURL!.isNotEmpty)
                          SizedBox(height: 16.0),
                        if (githubURL!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(
                                      FontAwesomeIcons.github,
                                      size: 20,
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                  TextSpan(text: '      '),
                                  TextSpan(
                                    text: githubURL != null
                                        ? '$Githubusername'
                                        : 'GitHub',
                                    style: githubURL != null
                                        ? TextStyle(
                                            fontSize: 13,
                                            color:
                                                Color.fromARGB(255, 0, 49, 146),
                                            decoration:
                                                TextDecoration.underline,
                                          )
                                        : TextStyle(
                                            fontSize: 17.5,
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                          ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // Handle the tap on the GitHub link
                                        launchGitHubURL(githubURL!);
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        if (country == "null")
                          Text(
                            '  $city',
                            style: const TextStyle(fontSize: 17),
                          ),
                        if (city == "null")
                          Text(
                            '  $country',
                            style: const TextStyle(fontSize: 17),
                          ),
                        if (city == "null" && country == "null")
                          Text(
                            '  $country, $city',
                            style: const TextStyle(fontSize: 17),
                          ),
                        if (city != "null" && country != "null")
                          Text(
                            '  $country, $city',
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        const SizedBox(height: 2),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Intrested In:',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            Container(
                              width:
                                  400, // Set a fixed width for the skills container
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                    interests.length,
                                    (intrestsIndex) {
                                      final intrest =
                                          interests[intrestsIndex] as String;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Chip(
                                          label: Text(
                                            intrest,
                                            style: TextStyle(fontSize: 10.0),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (skills != null && skills.isNotEmpty)
                              SizedBox(height: 14.0),
                            if (skills.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Skills:',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            Container(
                              width:
                                  400, // Set a fixed width for the skills container
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                    skills.length,
                                    (skillIndex) {
                                      final skill =
                                          skills[skillIndex] as String;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Chip(
                                          label: Text(
                                            skill,
                                            style: TextStyle(fontSize: 12.0),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child:
                      Divider(color: const Color.fromARGB(255, 140, 140, 140)),
                ),
                SliverToBoxAdapter(
                  child: Container(
                      padding: const EdgeInsets.only(top: 1),
                      alignment: Alignment.center,
                      child: TabBar(
                        controller: tabController,
                        indicatorColor:Color.fromRGBO(37, 6, 81, 0.898), 
                         tabs: [
                Tab(
                  child: Text(
                    'Questions',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Teams',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Projects',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Answers',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
                      )),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      // Content for Tab 1
                      StreamBuilder<List<CardQuestion>>(
                        stream: readQuestion(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final q = snapshot.data!;

                            if (q.isEmpty) {
                              return Center(
                                child: Text('No Questions Yet'),
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
                      // Content for Tab 2
                      StreamBuilder<List<CardFT>>(
                        stream: readTeam(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final t = snapshot.data!;
                            if (t.isEmpty) {
                              return Center(
                                child: Text('No Team requests yet'),
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
                                child: Text('No Project request yet'),
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

                      StreamBuilder<List<CardAnswer>>(
                        stream: readAnswers(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final p = snapshot.data!;
                            if (p.isEmpty) {
                              return Center(
                                child: Text('No Answers yet'),
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
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  void launchGitHubURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> addQuestionToBookmarks(
      String email, CardQuestion question) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final currentUser = prefs.getString('loggedInEmail') ?? '';
      final existingBookmark = await FirebaseFirestore.instance
          .collection('Bookmark')
          .where('bookmarkType', isEqualTo: 'question')
          .where('userId', isEqualTo: currentUser)
          .where('postId', isEqualTo: question.questionDocId)
          .get();

      if (existingBookmark.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('Bookmark').add({
          'bookmarkType': 'question',
          'userId': currentUser,
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

    // Create a new document in the "reported_posts" collection in Firestore
    await _firestore.collection('Report').add({
      'reportedItemId': postId,
      'reason': reason, // Use the provided reason parameter
      'reportDate': DateTime.now(),
      'reportType': "Question",
      'status': 'Pending',
      'reportedUserId': question.userId,
      'seen': false,
    });

    // Clear the selected option after reporting
    selectedOption = null;
  }

  void handleReportTeam(
    String email,
    CardFT team,
    String reason,
  ) async {
    String? postId = team.teamDocId;

    await FirebaseFirestore.instance.collection('Report').add({
      'reportedItemId': postId,
      'reason': reason,
      'reportDate': DateTime.now(),
      'reportType': "Team",
      'status': 'Pending',
      'reportedUserId': team.userId,
      'seen': false,
    });
    selectedOption = null;
  }

  void handleReportProject(
    String email,
    CardFT team,
    String reason,
  ) async {
    String? postId = team.teamDocId;

    await FirebaseFirestore.instance.collection('Report').add({
      'reportedItemId': postId,
      'reason': reason,
      'reportDate': DateTime.now(),
      'reportType': "Project",
      'status': 'Pending',
      'reportedUserId': team.userId,
      'seen': false,
    });
    selectedOption = null;
  }
}
