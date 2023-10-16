

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/pages/cardQuestion.dart';
import 'package:techxcel11/pages/cardanswer.dart';

class AnswerPage extends StatefulWidget {
  final int questionId;

  const AnswerPage({Key? key, required this.questionId}) : super(key: key);

  @override
  _AnswerPageState createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  Future <String> fetchusername() async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    final username = prefs.getString('username') ??'';
    return username;
  }
  late List<CardQuestion> questions = [];

  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchQuestion();
  }

  Future<void> fetchQuestion() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('id', isEqualTo: widget.questionId)
        .limit(1)
        .get();
    final documents = querySnapshot.docs;

    if (documents.isNotEmpty) {
      setState(() {
        questions = documents
            .map((doc) {
          Map<String, dynamic> data = doc.data();
          data['docId'] = doc.id;
          return CardQuestion.fromJson(data);
            })
            .toList();
      });
    }
  }

  Stream<List<CardAnswer>> readAnswer() => FirebaseFirestore.instance
      .collection('answers')
      .where('questionId', isEqualTo: widget.questionId)
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => CardAnswer.fromJson(doc.data())).toList());

  Widget buildQuestionCard(CardQuestion question) => Card(
    child: FutureBuilder<String>(
      future: fetchusername(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final username = snapshot.data ?? '';
          return Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      //backgroundImage: NetworkImage(question.userPhotoUrl),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ListTile(
                title: Text(question.title),
                subtitle: Text(question.description),
              ),
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
                    icon: Icon(Icons.chat),
                    onPressed: () {
                      focusNode.requestFocus();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.bookmark),
                    onPressed: () {

                    },
                  ),

                  IconButton(
                    icon: Icon(Icons.report),
                    onPressed: () {

                    },
                  ),
                ],
              ),
            ],
          );
        }
      },
    ),
  );


  Widget buildAnswerCard(CardAnswer answer) {
    int upvoteCount = answer.upvoteCount ?? 0;
    bool isUpvoted = false; // Track the upvote state

    return Card(
      child: FutureBuilder<String>(
        future: fetchusername(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final username = snapshot.data ?? '';
            return  Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ListTile(
                  title: Text(answer.answerText),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('$upvoteCount'),

                    IconButton(
                      icon: Icon(isUpvoted ? Icons.arrow_downward : Icons.arrow_upward),
                      onPressed: () {
                        setState(() {
                          if (isUpvoted) {
                            // Decrement the upvote count
                            upvoteCount--;

                            // Update the upvote count in Firestore
                            FirebaseFirestore.instance
                                .collection('answers')
                                .doc(answer.answerId)
                                .update({'upvoteCount': FieldValue.increment(-1)})
                                .then((_) {
                              print('Upvote count decremented successfully');
                            }).catchError((error) {
                              print('Failed to decrement upvote count: $error');
                              // Handle error if the update fails
                            });
                          } else {
                            // Increment the upvote count
                            upvoteCount++;

                            // Update the upvote count in Firestore
                            FirebaseFirestore.instance
                                .collection('answers')
                                .doc(answer.answerId)
                                .update({'upvoteCount': FieldValue.increment(1)})
                                .then((_) {
                              print('Upvote count incremented successfully');
                            }).catchError((error) {
                              print('Failed to increment upvote count: $error');
                              // Handle error if the update fails
                            });
                          }

                          // Toggle the upvote state
                          isUpvoted = !isUpvoted;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.report),
                      onPressed: () {

                      },
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );

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

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Answers'),
      ),
      body: Column(
        children:[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: questions != null && questions.isNotEmpty
                ? buildQuestionCard(questions[0])
                : CircularProgressIndicator(),
          ),
          Expanded(
            child: StreamBuilder<List<CardAnswer>>(
              stream: readAnswer(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                final answers = snapshot.data!;
                return ListView(
                  children: answers.map(buildAnswerCard).toList(),
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
                      focusNode: focusNode,
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
