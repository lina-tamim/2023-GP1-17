import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/Models/QuestionCard.dart';
import 'package:techxcel11/Models/AnswerCard.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/pages/CommonPages/misc_widgets.dart';
import 'package:techxcel11/pages/UserPages/UserProfileView.dart';
import 'package:techxcel11/widgets/misc_widgets.dart';

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
    return questions;
  }

  Widget buildQuestionCard(CardQuestion question) => Card(
        child: UserInfoWidget(
          title: question.title,
          description: question.description,
          postedDate: question.postedDate,
          userId: question.userId,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          padding: const EdgeInsets.only(left: 0),
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
                    icon: Icon(
                      Icons.bookmark,
                      color: email == 'texelad1@gmail.com'
                          ? Color.fromARGB(
                              24, 63, 63, 63) // Color for texelad1@gmail.com
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
                                builder: (context) => AnswerPage(
                                    questionDocId: question.questionDocId),
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

  Future<void> addQuestionToBookmarks(
      String email, CardQuestion question) async {
    try {

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
    return Card(
      child: UserInfoWidget(
        // title: answer.answerText,
        description: answer.answerText,
        postedDate: answer.postedDate,
        userId: answer.userId,
        child: Column(
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

                      if (answer.docId == null) {
                        return Text('No document ID');
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          IconButton(
                            icon: Icon(Icons.report,
                                color: Color.fromARGB(255, 63, 63, 63)),
                             iconSize: 20,
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
                                                  handleReportAnswer(
                                                      email, answer, reason);
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
                          if (email != 'texelad1@gmail.com')
                            IconButton(
                              icon: Icon(
                                upvotedUserIds.contains(currentEmail)
                                    ? Icons.arrow_circle_down
                                    : Icons.arrow_circle_up,
                                color: upvotedUserIds.contains(currentEmail)
                                    ? const Color.fromARGB(255, 49, 3,
                                        0) // Color for arrow_circle_down
                                    : const Color.fromARGB(255, 26, 33,
                                        38), // Color for arrow_circle_up
                              ),
                              iconSize: 20,
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
                                  }).catchError((error) {
                                    // Handle error if the update fails
                                  });
                                });
                              },
                            ),
                        Text(
                          'Upvotes: $upvoteCount',
                          style: TextStyle(
                            fontSize: 10, // Adjust the size as desired
                          ),
                        ),
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
        'questionId': widget.questionDocId,
        'userId': email,
        'answerText': answerText,
        'upvoteCount': 0,
        'postedDate': DateTime.now(),
      });

      final questionDocId = widget.questionDocId;
      final questionDoc = await FirebaseFirestore.instance
          .collection('Question')
          .doc(questionDocId)
          .get();
      final currentNoOfAnswers = questionDoc.data()!['noOfAnswers'] ?? 0;
      await FirebaseFirestore.instance
          .collection('Question')
          .doc(questionDocId)
          .update({
        'noOfAnswers': currentNoOfAnswers + 1,
      });

      _answerController.clear();
    }
  }

  Stream<List<CardAnswer>> readAnswer() => FirebaseFirestore.instance
          .collection('Answer')
          .where('questionId', isEqualTo: widget.questionDocId)
          .orderBy('upvoteCount', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        final answers = snapshot.docs.map((doc) {
          final data = doc.data();
          data['docId'] = doc.id;
          return CardAnswer.fromJson(data);
        }).toList();

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
        List<CardAnswer> filteredQuestions = answers
            .where((answer) => !acceptedQuestionIds.contains(answer.docId))
            .toList();

        return filteredQuestions;
      });

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: buildAppBar('Answers'),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: StreamBuilder<List<CardQuestion>>(
                stream: questionStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No questions available.'));
                  }

                  final questions = snapshot.data!;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: buildQuestionCard(questions[0]),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: StreamBuilder<List<CardAnswer>>(
                stream: readAnswer(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading answers: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No answers yet'));
                  }

                  final answers = snapshot.data!;
                  return ListView(
                    children: answers.map((answer) => buildAnswerCard(answer)).toList(),
                  );
                },
              ),
            ),
          ),
          if (email != 'texelad1@gmail.com')
            Padding(
              padding: const EdgeInsets.all(2.0),
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
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        final email = prefs.getString('loggedInEmail') ?? '';
                        if (email != null) {
                          _submitAnswer(email);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromRGBO(37, 6, 81, 0.898)),
                        minimumSize: MaterialStateProperty.all(Size(100, 57)),
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
                          fontSize: 14,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
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
      'reportedUserId': question.userId,
      'seen': false,
    });

    // Clear the selected option after reporting
    selectedOption = null;
  }

  void handleReportAnswer(
    String email,
    CardAnswer answer,
    String reason,
  ) async {
    String? postId = answer.docId;

    await _firestore.collection('Report').add({
      'reportedItemId': postId,
      'reason': reason,
      'reportDate': DateTime.now(),
      'reportType': "Answer",
      'status': 'Pending',
      'reportedUserId': answer.userId,
      'seen': false,
    });
    selectedOption = null;
  }
}
