//Full code, m s
//GP discussion
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/models/cardQuestion.dart';
import 'package:techxcel11/models/cardanswer.dart';
import 'package:techxcel11/pages/reuse.dart';

class AnswerPage extends StatefulWidget {
  final int questionId;

  const AnswerPage({Key? key, required this.questionId}) : super(key: key);

  @override
  _AnswerPageState createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
   Future <String> fetchuseremail() async{
SharedPreferences prefs= await SharedPreferences.getInstance();
  final email = prefs.getString('loggedInEmail') ??'';
  return email;
  }

  late List<CardQuestion> questions = [];
final _questionStreamController = StreamController<List<CardQuestion>>.broadcast();

Stream<List<CardQuestion>> get questionStream => _questionStreamController.stream;
  @override
  void initState() {
    super.initState();
    fetchQuestionData();
 
  }
  void fetchQuestionData() async {
  final List<CardQuestion> questionList = await readQuestion();
  _questionStreamController.add(questionList);
}

Future<List<CardQuestion>> readQuestion() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('posts')
      .where('dropdownValue', isEqualTo: 'Question')
      .where('id', isEqualTo: widget.questionId)
      .limit(1)
      .get();

  final questions = snapshot.docs.map((doc) => CardQuestion.fromJson(doc.data())).toList();
  final userIds = questions.map((question) => question.userId).toList();
  final userDocs = await FirebaseFirestore.instance.collection('users').where('email', whereIn: userIds).get();

  final userMap = Map<String, Map<String, dynamic>>.fromEntries(userDocs.docs.map(
      (doc) => MapEntry(doc.data()['email'] as String, doc.data() as Map<String, dynamic>)));

  questions.forEach((question) {
    final userDoc = userMap[question.userId];
    final username = userDoc?['userName'] as String? ?? '';
    final userPhotoUrl = userDoc?['imageUrl'] as String? ?? '';
    question.username = username;
    question.userPhotoUrl = userPhotoUrl;
  });

  return questions;
}

  Widget buildQuestionCard(CardQuestion question) => Card(
  child: ListTile(
    leading: CircleAvatar(
          backgroundImage: question.userPhotoUrl != null
              ? NetworkImage(question.userPhotoUrl!)
              : null, // Handle null value
        ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        Text(
          question.username ?? '', // Display the username
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0)
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
              icon: Icon(Icons.bookmark),
              onPressed: () {
                // Add your functionality for the button here
              },
            ),
            IconButton(
              icon: Icon(Icons.comment),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnswerPage(questionId: question.id)),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.report),
              onPressed: () {
                // Add your functionality for the button here
              },
            ),
          ],
        ),
      ],
    ),
  ),
);

Widget buildAnswerCard(CardAnswer answer) {
  String currentEmail = '';

  Future<String> getCurrentUserEmail() async {
    return await fetchuseremail();
  }
  int upvoteCount = answer.upvoteCount ?? 0;
  List<String> upvotedUserIds = answer.upvotedUserIds ?? [];

  return Card(
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
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple
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
                return CircularProgressIndicator(); // Show a loading indicator while retrieving the email
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}'); // Show an error message if email retrieval fails
              } else {
                currentEmail = snapshot.data!;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(upvotedUserIds.contains(currentEmail) ? Icons.arrow_circle_down : Icons.arrow_circle_up),
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

                          // Update the upvote count and upvoted user IDs in Firestore
                          FirebaseFirestore.instance
                            .collection('answers')
                            .doc(answer.answerId)
                            .update({
                              'upvoteCount': upvoteCount,
                              'upvotedUserIds': upvotedUserIds,
                            })
                            .then((_) {
                              print('Upvote count updated successfully');
                            })
                            .catchError((error) {
                              print('Failed to update upvote count: $error');
                              // Handle error if the update fails
                            });
                        });
                      },
                    ),
                    Text('Upvotes: $upvoteCount'),
                  ],
                );
              }
            },
          ),
        ],
      ),
   ], ),
  ),);
}
 
 
  final TextEditingController _answerController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

 Future<void> _submitAnswer(String email) async {
  if (_formKey.currentState!.validate()) {
    final String answerText = _answerController.text;

    final formCollection = FirebaseFirestore.instance.collection('answers');

    final newFormDoc = formCollection.doc();
    await newFormDoc.set({
      'answerId': newFormDoc.id,
      'questionId': widget.questionId,
      'userId': email,
      'answerText': answerText,
      'upvoteCount': 0, 
    });

    _answerController.clear();
  }
}
Stream<List<CardAnswer>> readAnswer() => FirebaseFirestore.instance
    .collection('answers')
    .where('questionId', isEqualTo: widget.questionId)
    .snapshots()
    .asyncMap((snapshot) async {
      final answers = snapshot.docs.map((doc) => CardAnswer.fromJson(doc.data())).toList();
      final userIds = answers.map((answer) => answer.userId).toList();
      final userDocs = await FirebaseFirestore.instance.collection('users').where('email', whereIn: userIds).get();

      final userMap = Map<String, Map<String, dynamic>>.fromEntries(userDocs.docs.map(
          (doc) => MapEntry(doc.data()['email'] as String, doc.data() as Map<String, dynamic>)));

      answers.forEach((answer) {
        final userDoc = userMap[answer.userId];
        final username = userDoc?['userName'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageUrl'] as String? ?? '';
        answer.username = username;
        answer.userPhotoUrl = userPhotoUrl;
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
        children:[
          Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<List<CardQuestion>>(
            stream: questionStream, // Use the questionStream from _questionStreamController
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Display a loading indicator while waiting for data
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No questions available.'); // Display a message if there are no questions
              }

              final questions = snapshot.data!;
              return buildQuestionCard(questions[0]); // Display the first question
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
                  children: answers.map((answer) => buildAnswerCard(answer)).toList(),
                );
              },
            ),
          ),
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
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      final email = prefs.getString('loggedInEmail') ??'';
                      if (email != null) {
                        _submitAnswer(email);
                      }
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}