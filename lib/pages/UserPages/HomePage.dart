import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
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
import 'package:techxcel11/pages/UserPages/TestIntegration.dart';
import 'package:techxcel11/pages/UserPages/UserProfileView.dart';
import 'dart:developer';
import 'package:techxcel11/providers/profile_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class FHomePage extends StatefulWidget {
  const FHomePage({Key? key}) : super(key: key);

  @override
  __FHomePageState createState() => __FHomePageState();
}

int _currentIndex = 0;

class __FHomePageState extends State<FHomePage> {
  String loggedInEmail = '';
  String loggedImage = '';

  List<String> userSkills = [];
  List<String> userInterests = [];
  List<String> recommendedQuestionIds = [];
  List<Map<String, dynamic>> allTheQuestions = [];

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

  String greetings = '';

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
    fetchUserDetailsREC();
  }

////RECOMMENDER
  ///
  Future<void> fetchUserDetailsREC() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('RegularUser')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs[0].data();
      setState(() {
        userSkills = List<String>.from(userData['skills'] ?? []);
        userInterests = List<String>.from(userData['interests'] ?? []);
      });
    }

    final QuerySnapshot<Map<String, dynamic>> snapshotQ =
        await _firestore.collection('Question').get();
//
    if (snapshotQ.docs.isNotEmpty) {
      setState(() {
        allTheQuestions = snapshotQ.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        // Convert each question to JSON object

        List<Map<String, dynamic>> questionsJson = [];
        allTheQuestions.forEach((question) {
          Timestamp timestamp =
              question['postedDate']; // Get the Timestamp object
          print('11111111111');
          DateTime dateTime =
              timestamp.toDate(); // Convert Timestamp to DateTime
          Map<String, dynamic> jsonQuestion = {
            'selectedInterests': question['selectedInterests'],
            'noOfAnswers': question['noOfAnswers'],
            'questionDocId': question['questionDocId'],
            'totalUpvotes': question['totalUpvotes'] ?? 0,
            'postedDate': DateFormat.yMMMMd()
                .add_jms()
                .format(dateTime), // Format DateTime to string
          };
          print('^^^^^^^^^^^^^^^^^^^^^^^^^^');
          print(DateFormat.yMMMMd()
              .add_jms()
              .format(dateTime)); // Print formatted date string
          questionsJson.add(jsonQuestion);
          print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
          print(jsonQuestion);
          print('777777777777777777');
        });

        // Send the JSON object to the server
        recommendQuestions(questionsJson);
      });
    }

//
  }

  Future<void> recommendQuestions(
      List<Map<String, dynamic>> questionsJson) async {
    // Send user preferences and all questions to the server
    final Map<String, dynamic> requestBody = {
      'user_skills': userSkills,
      'user_interests': userInterests,
      'all_questions': questionsJson,
    };

    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      // Parse response body as JSON
      final List<dynamic> responseBody = json.decode(response.body);

      // Extract question IDs from response
      final List<String> ids = responseBody.cast<String>().toList();

      // Update recommendedQuestionIds state
      setState(() {
        recommendedQuestionIds = ids;
      });
    } else {
      print('77577777777777777777777777777777777777777777777777777777777');
      throw Exception('Failed to fetch recommended questions');
    }
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
      final questions = snapshot.docs.map((doc) {
        final questionData = doc.data() as Map<String, dynamic>;
        final question = CardQuestion.fromJson(questionData);
        question.docId = doc.id; // Set the docId to the actual document ID
        return question;
      }).toList();
      if (questions.isEmpty) return [];

      final userIds = questions.map((question) => question.userId).toList();

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
      print("@@@@@@@@@$acceptedQuestionIds");

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

      // Filter out questions with docId present in the Report collection with reportType = "Question" and status = "Accepted"
      List<CardQuestion> filteredQuestions = questions
          .where((question) => !acceptedQuestionIds.contains(question.docId))
          .toList();
      // Filter questions based on recommendedQuestionIds
      filteredQuestions = filteredQuestions
          .where((question) =>
              !recommendedQuestionIds.contains(question.questionDocId))
          .toList();
      print("77566574746378");
      //print(filteredQuestions);
      print(recommendedQuestionIds);
      return filteredQuestions;
    });
  }

  Stream<List<CardQuestion>> readQuestionRecommended() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('Question');
    
    

    return query.snapshots().asyncMap((snapshot) async {
      final questions = snapshot.docs.map((doc) {
        final questionData = doc.data() as Map<String, dynamic>;
        final question = CardQuestion.fromJson(questionData);
        question.docId = doc.id; // Set the docId to the actual document ID
        return question;
      }).toList();
      if (questions.isEmpty) return [];

      final userIds = questions.map((question) => question.userId).toList();

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
      print("@@@@@@@@@$acceptedQuestionIds");

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

      // Filter out questions with docId present in the Report collection with reportType = "Question" and status = "Accepted"
      List<CardQuestion> filteredQuestions = questions
          .where((question) => !acceptedQuestionIds.contains(question.docId))
          .toList();
      // Filter questions based on recommendedQuestionIds
      filteredQuestions = recommendedQuestionIds
          .map((id) => filteredQuestions
              .firstWhere((question) => question.questionDocId == id))
          .toList();

      print("RECOMMENDEDDEED HEEEEEEEEEEEEEEEREEEEEEEEEEE");
      //print(filteredQuestions);
      print(recommendedQuestionIds);
      
      return filteredQuestions;
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
      final questions = snapshot.docs.map((doc) {
        final questionData = doc.data() as Map<String, dynamic>;
        final question = CardFT.fromJson(questionData);
        question.docId = doc.id; // Set the docId to the actual document ID
        return question;
      }).toList();

      if (questions.isEmpty) return [];
      final userIds = questions.map((question) => question.userId).toList();

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

      // Filter out questions with docId present in the Report collection with reportType = "Question" and status = "Accepted"
      List<CardFT> filteredQuestions = questions
          .where((question) => !acceptedQuestionIds.contains(question.docId))
          .toList();

      return filteredQuestions;
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
      final questions = snapshot.docs.map((doc) {
        final questionData = doc.data() as Map<String, dynamic>;
        final question = CardFT.fromJson(questionData);
        question.docId = doc.id; // Set the docId to the actual document ID
        return question;
      }).toList();
      if (questions.isEmpty) return [];
      final userIds = questions.map((question) => question.userId).toList();

      // Query the Report collection to get accepted questionIds
      QuerySnapshot<Map<String, dynamic>> reportSnapshot =
          await FirebaseFirestore.instance
              .collection('Report')
              .where('reportType', isEqualTo: 'Project')
              .where('status', isEqualTo: 'Accepted')
              .get();
      final userDocs = await FirebaseFirestore.instance
          .collection('RegularUser')
          .where('email', whereIn: userIds)
          .get();
      Set<String> acceptedQuestionIds = reportSnapshot.docs
          .map((doc) => doc['reportedItemId'] as String)
          .toSet();

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
      // Filter out questions with docId present in the Report collection with reportType = "Question" and status = "Accepted"
      List<CardFT> filteredQuestions = questions
          .where((question) => !acceptedQuestionIds.contains(question.docId))
          .toList();

      return filteredQuestions;
    });
  }

  Widget buildQuestionCard(CardQuestion question) => Card(
        elevation: 0.4, // Set elevation to 0 to remove the shadow
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
                          color: Color.fromARGB(255, 24, 8, 53),
                          fontSize: 16),
                    ),
                    if (question.userType == "Freelancer")
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: Colors.deepPurple,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                        ],
                      ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(question.postedDate),
                          style: TextStyle(fontSize: 12),
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
                  fontSize: 15.4,
                ),
              ),
              SizedBox(height: 5),
              Text(question.description,
                  style: TextStyle(
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
                  SizedBox(height: 60,)
                ],
              ),
            ],
          ),
        ),
      );

  Widget buildRecommendedQuestionCard(CardQuestion question) => Card(
       color: Color.fromARGB(255, 253, 251, 255),
        elevation: 0.4, // Set elevation to 0 to remove the shadow
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
                          color: Color.fromARGB(255, 24, 8, 53),
                          fontSize: 16),
                    ),
                    if (question.userType == "Freelancer")
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: Colors.deepPurple,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                        ],
                      ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(question.postedDate),
                          style: TextStyle(fontSize: 12),
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
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 5),
              Text(question.description,
                  style: TextStyle(
                    fontSize: 13,
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
              SizedBox(height: 6,),
             Align(
  alignment: Alignment.bottomLeft,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Image.asset(
      'assets/icons/sparkle.png', 
      width: 17, 
      height: 17,
    ),
        SizedBox(width:5),
      Text(
        "Is this content relevant to you?",
        style: TextStyle(fontSize: 12),
      ),
      SizedBox(width:15),
      GestureDetector(
      onTap: () {
        recordFeedback(loggedInEmail, question, true);
      },
      child: Image.asset(
        'assets/icons/thumbUp.png', 
        width: 15, 
        height: 15,
        color: Color.fromARGB(255, 116, 116, 116), 
      ),
      ),
      SizedBox(width:20),
     GestureDetector(
      onTap: () {
        recordFeedback(loggedInEmail, question, false);
      },
      child: Image.asset(
        'assets/icons/thumbDown.png', 
        width: 15, 
        height: 15,
        color: Color.fromARGB(255, 116, 116, 116), 
      ),
      ),
    ],
  ),
),
              SizedBox(height: 6,),

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
                        team.username ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 34, 3, 87),
                          fontSize: 16,
                        ),
                      ),
                      if (team.userType == "Freelancer")
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
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
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
                  ? Color.fromARGB(255, 166, 11, 0)
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
            backgroundColor: Color.fromARGB(255, 242, 241, 243),
            iconTheme: IconThemeData(
              color: Color.fromRGBO(37, 6, 81, 0.898),
            ),
            toolbarHeight: 80,
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
                    /*  IconButton(
                        onPressed: () {
                          setState(() {
                            showSearchBar = !showSearchBar;
                          });
                        },
                        icon: Icon(
                            showSearchBar ? Icons.search_off : Icons.search),
                      ),*/
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
                      255, 0, 0, 0), // Set the color of the underline
                ),
                // Adjust the insets if needed
              ),
              labelColor: Color.fromARGB(255, 0, 0, 0),
              // Set the color of the selected tab's text
              tabs: [
                Tab(
                  child: Text('Questions',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                ),
                Tab(
                  child: Text('Teams',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                ),
                Tab(
                  child: Text('Projects',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            )),

        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () async {
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
        //CARDS DISPLAY

        body: TabBarView(
          children: [
            // Display Question Cards
            StreamBuilder<List<CardQuestion>>(
              stream: readQuestionRecommended(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final q = snapshot.data!;
                  if (q.isEmpty) {
                    return Center(
                      child: Text('No Posts Yet'),
                    );
                  }
                  return ListView(
                    children: [
                      // First stream's content
                      ...q.map(buildRecommendedQuestionCard).toList(),
                      // Second stream
                      StreamBuilder<List<CardQuestion>>(
                        stream: readQuestion(),
                        builder: (context, secondSnapshot) {
                          if (secondSnapshot.hasData) {
                            final secondQ = secondSnapshot.data!;

                            if (secondQ.isEmpty) {
                              return Center(
                                child: Text('No Second Stream Data'),
                              );
                            }

                            return ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: secondQ.map(buildQuestionCard).toList(),
                            );
                          } else if (secondSnapshot.hasError) {
                            return Center(
                              child: Text('Error: ${secondSnapshot.error}'),
                            );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                    ],
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

  Future<void> recordFeedback(
      String email, CardQuestion question, bool isThumbUp) async {
    try {
      print(question.questionDocId);
      String relevant = isThumbUp ? 'Yes' : 'No';

      await FirebaseFirestore.instance.collection('RecommenderMeasure').add({
        'questionId': question.questionDocId,
        'relevant': relevant,
        'userId': email,
      });
      toastMessage('Feedback Send');
    } catch (error) {
      print('Error adding question to bookmarks: $error');
    }
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
      'reportedUserId': question.userId,
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
      'reportedUserId': team.userId,
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
      'reportedUserId': team.userId,
    });

    // Clear the selected option after reporting
    selectedOption = null;
  }
}
