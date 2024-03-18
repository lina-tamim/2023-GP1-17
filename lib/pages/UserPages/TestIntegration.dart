import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/Models/QuestionCard.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/pages/UserPages/AnswerPage.dart';
import 'package:techxcel11/pages/UserPages/BookmarkPage.dart';
import 'package:techxcel11/pages/UserPages/UserProfileView.dart';

class TestIntegration extends StatefulWidget {
  @override
  _TestIntegrationState createState() => _TestIntegrationState();
}

class _TestIntegrationState extends State<TestIntegration> {
  String loggedInEmail = '';
  List<String> userSkills = [];
  List<String> userInterests = [];
  List<String> recommendedQuestionIds = [];
  List<Map<String, dynamic>> allTheQuestions = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchUserDetails() async {
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
          print('2222222222');
          Map<String, dynamic> jsonQuestion = {
            'selectedInterests': question['selectedInterests'],
            'noOfAnswers': question['noOfAnswers'],
            'questionDocId': question['questionDocId'],
            'totalUpvotes': question['totalUpvotes'] ?? 0,
            //'postTitle': question['postTitle'],
            //'userId': question['userId'],
            //'postDescription': question['postDescription'],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send User Preferences'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Recommended Question IDs: $recommendedQuestionIds'),
            ElevatedButton(
              onPressed: () {
                fetchUserDetails();
              },
              child: Text('Fetch Recommendations'),
            ),
          ],
        ),
      ),
    );
  }
}

/*class TestIntegration extends StatefulWidget {
  const TestIntegration({Key? key}) : super(key: key);

  @override
  State<TestIntegration> createState() => _TestIntegrationState();
}

class _TestIntegrationState extends State<TestIntegration> {
  String greetings = 'bbbbbbbbb';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              greetings,
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20,),
            Center(
              child: Container(
                width: 150,
                height: 60,
                child: IconButton(
                  icon: Icon(Icons.abc),
                  onPressed: () async {
                     print(';;;;;;;;');

                    final Uri uri = Uri.parse('http://10.0.2.2:5000/');


final response = await http.get(uri);
 
                                                print('[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]');

                    final decoded = json.decode(response.body) as Map<String, dynamic>;
                    print('ooooooooooooooooo');
                    setState(() {
                      greetings = decoded['greetings'];
                                            print(greetings);

                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/







/*
class TestIntegration extends StatefulWidget {
  const TestIntegration({Key? key}) : super(key: key);

  @override
  State<TestIntegration> createState() => _TestIntegrationState();
}

class _TestIntegrationState extends State<TestIntegration> {
  int _currentIndex = 0;
  String _loggedInImage = '';
  List <String> userSkills = [];
    List <String> userInterests = [];


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  TabController? tabController;
  
  bool isLoading = false;

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

      final imageURL = userData['imageURL'] ?? '';
      userSkills = List<String>.from(userData['skills'] ?? []);
      userInterests = List<String>.from(userData['interests'] ?? []);


      setState(() {
        _loggedInImage = imageURL;
      });

      // Call recommendQs method here after fetching user data
    //  recommendQs(
      //  userData['user_skills'],
        //userData['user_interests'],
      //);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Divider(color: const Color.fromARGB(255, 140, 140, 140)),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.only(top: 8),
                    alignment: Alignment.center,
                    child: TabBar(
                      controller: tabController,
                      indicatorColor: Color.fromARGB(255, 0, 0, 0),
                      labelColor: Color.fromARGB(255, 0, 0, 0),
                      tabs: [
                        Tab(text: 'Question'),
                      ],
                    ),
                  ),
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
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  

  Stream<List<CardQuestion>> readQuestion() {
    return Stream.fromFuture(fetchUserData()).asyncMap((_) async {
      final recommendedQuestionIds = await recommendQs(userSkills, userInterests);

      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('Question');
      
      // Filter questions based on recommended question IDs
      query = query.where(FieldPath.documentId, whereIn: recommendedQuestionIds);

      final snapshot = await query.get();
      final List<CardQuestion> questions = snapshot.docs.map((doc) {
        final questionData = doc.data() as Map<String, dynamic>;
        final question = CardQuestion.fromJson(questionData);
        question.docId = doc.id; // Set the docId to the actual document ID
        return question;
      }).toList();


      return questions;
    });
  }



  Future<List<String>> recommendQs(List<String> userSkills, List <String> userInterests) async {
    final Uri uri = Uri.parse('http://10.0.2.2:5000/');
    final Map<String, dynamic> params = {
      'user_skills': userSkills,
      'user_interests': userInterests,
    };

    final Uri uriWithParams = uri.replace(queryParameters: params);

    final response = await http.get(uriWithParams);

    if (response.statusCode == 200) {
      // Parse response and return question IDs
      List<String> recommendedQuestionIds = json.decode(response.body).cast<String>();
      return recommendedQuestionIds;
    } else {
      // Handle error
            print('Failed to recommend questions--------------------------------------------------');

      throw Exception('Failed to recommend questions');
    }
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
                    icon: Icon(Icons.monitor_heart,
                        color: Color.fromARGB(255, 81, 0, 78)),
                    onPressed: () {
                      Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TestIntegration()),
              );

                    }

                  ),
                  IconButton(
                    icon: Icon(Icons.bookmark,
                        color: Color.fromARGB(255, 63, 63, 63)),
                    onPressed: () {
                    },
                  ),
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
                                         // handleReportQuestion(
                                           //   loggedInEmail, question, reason);
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
}
*/