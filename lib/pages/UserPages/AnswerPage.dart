import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/Models/QuestionCard.dart';
import 'package:techxcel11/Models/AnswerCard.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/pages/UserPages/UserProfileView.dart';

class AnswerPage extends StatefulWidget {
  final String questionDocId;

  const AnswerPage({Key? key, required this.questionDocId}) : super(key: key);

  @override
  _AnswerPageState createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  String email = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> fetchuseremail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final loggedinEmail = prefs.getString('loggedInEmail') ?? '';

    setState(() {
      email = loggedinEmail;
    });
  }

  late List<CardQuestion> questions = [];
  final _questionStreamController =
      StreamController<List<CardQuestion>>.broadcast();

  Stream<List<CardQuestion>> get questionStream =>
      _questionStreamController.stream;
  @override
  void initState() {
    super.initState();
    fetchQuestionData();
    fetchuseremail();
  }

  void fetchQuestionData() async {
    final List<CardQuestion> questionList = await readQuestion();
    _questionStreamController.add(questionList);
  }

  Future<List<CardQuestion>> readQuestion() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Question')
        .where('questionDocId', isEqualTo: widget.questionDocId)
        .limit(1)
        .get();

    final questions =
        snapshot.docs.map((doc) => CardQuestion.fromJson(doc.data())).toList();
    final userIds = questions.map((question) => question.userId).toList();
    final userDocs = await FirebaseFirestore.instance
        .collection('RegularUser')
        .where('email', whereIn: userIds)
        .get();

    final userMap = Map<String, Map<String, dynamic>>.fromEntries(userDocs.docs
        .map((doc) => MapEntry(doc.data()['email'] as String,
            doc.data() as Map<String, dynamic>)));

    questions.forEach((question) {
      final userDoc = userMap[question.userId];
      final username = userDoc?['username'] as String? ?? '';
      final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';

      question.username = username;
      question.userPhotoUrl = userPhotoUrl;
    });

    // Check if any userIds were not found in the 'User' collection
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
  }

  Widget buildQuestionCard(CardQuestion question) => Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: question.userPhotoUrl != ''
                ? NetworkImage(question.userPhotoUrl!)
                : AssetImage('assets/Backgrounds/defaultUserPic.png')
                    as ImageProvider<Object>,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Text(
                question.username ?? '',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0)),
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
  icon: Icon(
    Icons.bookmark,
    color: email == 'texelad1@gmail.com'
        ?Color.fromARGB(24, 63, 63, 63) // Color for texelad1@gmail.com
        : Color.fromARGB(255, 63, 63, 63), // Default color
  ),
  onPressed: email == 'texelad1@gmail.com'
      ? null
      : () {
          addQuestionToBookmarks(email, question);
        },
),
IconButton(
  icon: Icon(
    Icons.comment,
    color: email == 'texelad1@gmail.com'
        ? Color.fromARGB(24, 63, 63, 63)
        : Color.fromARGB(255, 63, 63, 63), // Default color
  ),
  onPressed: email == 'texelad1@gmail.com'
      ? null
      : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnswerPage(questionDocId: question.questionDocId),
            ),
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

  Widget buildAnswerCard(CardAnswer answer) {
    String currentEmail = '';

    Future<String> getCurrentUserEmail() async {
      return email;
    }

    int upvoteCount = answer.upvoteCount ?? 0;
    List<String> upvotedUserIds = answer.upvotedUserIds ?? [];
    String doc = answer.docId;
    print("7777777777777 $doc");
    return Card(
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
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      currentEmail = snapshot.data!;
                      print("11111111111 $currentEmail");
                      print('@@@@@@@@@@@@@@@@@@@@))-----))  ');

                      if (answer.docId == null) {
                        return Text('No document ID');
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 80,
                          ),
                          IconButton(
                            icon: Icon(Icons.report,
                                color: Color.fromARGB(255, 63, 63, 63)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      // Set the initial selectedOption to null
                                      String? initialOption = null;
                                      TextEditingController
                                          customReasonController =
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
                                              items: dropDownOptions
                                                  .map((String option) {
                                                return DropdownMenuItem<String>(
                                                  value: option,
                                                  child: Text(option),
                                                );
                                              }).toList(),
                                            ),
                                            Visibility(
                                              visible:
                                                  selectedOption == 'Others',
                                              child: TextFormField(
                                                controller:
                                                    customReasonController,
                                                decoration: InputDecoration(
                                                    labelText:
                                                        'Enter your reason'),
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
                                                if (selectedOption ==
                                                    'Others') {
                                                  reason =
                                                      customReasonController
                                                          .text;
                                                } else {
                                                  reason = selectedOption!;
                                                }
                                                if (reason.isNotEmpty) {
                                                  // Check if a reason is provided
                                                  handleReportAnswer(
                                                      email, answer, reason);
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
                        if (email != 'texelad1@gmail.com')
                          IconButton(
                            icon: Icon(
                              upvotedUserIds.contains(currentEmail)
                                  ? Icons.arrow_circle_down
                                  : Icons.arrow_circle_up,
                              size: 28, // Adjust the size as needed
                              color: upvotedUserIds.contains(currentEmail)
                                  ? const Color.fromARGB(255, 49, 3,
                                      0) // Color for arrow_circle_down
                                  : const Color.fromARGB(255, 26, 33,
                                      38), // Color for arrow_circle_up
                            ),
                            onPressed: () {
                              setState(() {
                                if (upvotedUserIds.contains(currentEmail)) {
                                  upvotedUserIds.remove(currentEmail);
                                  upvoteCount--;

                                  // Decrease userScore in RegularUser collection
                                  FirebaseFirestore.instance
                                      .collection('RegularUser')
                                      .where('email', isEqualTo: answer.userId)
                                      .get()
                                      .then((QuerySnapshot<Map<String, dynamic>>
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
                                } else {
                                  upvotedUserIds.add(currentEmail);
                                  upvoteCount++;
                                  FirebaseFirestore.instance
                                      .collection('RegularUser')
                                      .where('email', isEqualTo: answer.userId)
                                      .get()
                                      .then((QuerySnapshot<Map<String, dynamic>>
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
                                }

                                answer.upvoteCount = upvoteCount;
                                answer.upvotedUserIds = upvotedUserIds;
                                FirebaseFirestore.instance
                                    .collection('Answer')
                                    .doc(answer.docId)
                                    .update({
                                  'upvoteCount': upvoteCount,
                                  'upvotedUserIds': upvotedUserIds,
                                }).catchError((error) {
                                  // Handle error if the update fails
                                });
                              });
                            },
                          ),
                          SizedBox(
                            width: 2,
                          ), // Adjust the width to move the icons further to the right
                          Text('Upvotes: $upvoteCount'),
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

  final TextEditingController _answerController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _submitAnswer(String email) async {
    if (_formKey.currentState!.validate()) {
      final String answerText = _answerController.text;

      final formCollection = FirebaseFirestore.instance.collection('Answer');

      final newFormDoc = formCollection.doc();
      await newFormDoc.set({
        //'answerId': newFormDoc.id,
        'questionDocId': widget.questionDocId,
        'userId': email,
        'answerText': answerText,
        'upvoteCount': 0,
      });

      _answerController.clear();
    }
  }

  Stream<List<CardAnswer>> readAnswer() => FirebaseFirestore.instance
          .collection('Answer')
          .where('questionDocId', isEqualTo: widget.questionDocId)
          .snapshots()
          .asyncMap((snapshot) async {
        final answers = snapshot.docs.map((doc) {
          final data = doc.data();
          data['docId'] = doc.id; // Set the 'docId' field to the document ID
          return CardAnswer.fromJson(data);
        }).toList();
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
          final userIdsNotFound =
              userIds.where((userId) => !userMap.containsKey(userId)).toList();
          userIdsNotFound.forEach((userId) {
            answers.forEach((answer) {
              if (answer.userId == userId) {
                answer.username = 'DeactivatedUser';
                answer.userPhotoUrl = '';
              }
            });
          });
        });
        return answers;
      });

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar('Answers'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<List<CardQuestion>>(
              stream: questionStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No questions available.');
                }

                final questions = snapshot.data!;
                return buildQuestionCard(questions[0]);
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CardAnswer>>(
              stream: readAnswer(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('No answers yet');
                }

                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                final answers = snapshot.data!;
                return ListView(
                  children:
                      answers.map((answer) => buildAnswerCard(answer)).toList(),
                );
              },
            ),
          ),
          if (email != 'texelad1@gmail.com')
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _answerController,
                      decoration: InputDecoration(
                        labelText: 'Enter your answer',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an answer';
                        }
                        if (value.length > 1024) {
                          return 'Maximum character limit exceeded (1024 characters).';
                        }
                        return null;
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      final email = prefs.getString('loggedInEmail') ?? '';
                      if (email != null) {
                        _submitAnswer(email);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromRGBO(37, 6, 81, 0.898)),
                      minimumSize: MaterialStateProperty.all(Size(100, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  void handleReportAnswer(
    String email,
    CardAnswer answer,
    String reason,
  ) async {
    String? postId = answer.docId; // Get the post ID

    await _firestore.collection('Report').add({
      'reportedItemId': postId,
      'reason': reason, // Use the provided reason parameter
      'reportDate': DateTime.now(),
      'reportType': "Answer",
      'status': 'Pending',
    });

    // Clear the selected option after reporting
    selectedOption = null;
  }
}
