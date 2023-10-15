import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/cardQuestion.dart';
import 'package:techxcel11/cardanswer.dart';

class AnswerPage extends StatefulWidget {
  final int questionId;
  const AnswerPage({Key? key, required this.questionId}) : super(key: key);

  @override
  __AnswerPageState createState() => __AnswerPageState();
}

class __AnswerPageState extends State<AnswerPage> {

  

 

Stream<List<CardQuestion>> readQuestion() =>FirebaseFirestore.instance
                .collection('posts')
                .where('id',isEqualTo: widget.questionId)
                .snapshots()
                .map((snapshot) => 
                snapshot.docs.map((doc)=> CardQuestion.fromJson(doc.data())).toList());


 Widget buildQuestionCard(CardQuestion question) => Card(
  child: Column(
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
                  question.userId,
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
        children: question.topics.map((topic) => Chip(label: Text(topic, style: TextStyle(fontSize: 12.0),))).toList(),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.bookmark), // Replace `icon1` with the desired icon
            onPressed: () {
              // Add your functionality for the button here
            },
          ),
          IconButton(
            icon: Icon(Icons.comment), // Replace `icon2` with the desired icon
            onPressed: () {
              
                  },
          ),
          
          IconButton(
            icon: Icon(Icons.report), // Replace `icon4` with the desired icon
            onPressed: () {
              // Add your functionality for the button here
            },
          ),
        ],
      ),
    ],
  ),
);

Future<void> _incrementUpvoteCount(CardAnswer answer) async {
  final answerRef =
      FirebaseFirestore.instance.collection('answers').doc(answer.answerId as String?);

  try {
    await answerRef.update({'upvoteCount': FieldValue.increment(1)});
  } catch (e) {
    // Handle error
    print('Error updating upvote count: $e');
  }
}
/////////////////////////////////////
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
 //late Stream<QuerySnapshot> _answersStream;
 Stream<List<CardAnswer>> readAnswer() =>FirebaseFirestore.instance
                .collection('answers')
                .where('questionId',isEqualTo: widget.questionId)
                .snapshots()
                .map((snapshot) => snapshot.docs
        .map((doc) => CardAnswer.fromJson({
              ...doc.data(),
              'upvoteCount': doc['upvoteCount'] ?? 0,
            }))
        .toList());

 Widget buildAnswerCard(CardAnswer answer) => Card(
      child: Column(
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
                      answer.userId,
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
              IconButton(
                icon: Icon(Icons.arrow_upward),
                onPressed: () {
                  // Call the method to increment the upvote count here
                 // _incrementUpvoteCount(answer);
                },
              ),
              Text(answer.upvoteCount.toString()),
              IconButton(
                icon: Icon(Icons.report),
                onPressed: () {
                  // Add your functionality for the report button here
                },
              ),
            ],
          ),
        ],
      ),
    );
  final TextEditingController _answerController = TextEditingController();

  /*@override
  void initState() {
    super.initState();
    _answersStream = FirebaseFirestore.instance
        .collection('answers')
        .where('questionId', isEqualTo: widget.questionId)
        .snapshots();
  }*/
 @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

 /* void _submitAnswer() {
    final String answerText = _answerController.text;
    // TODO: Implement answer submission logic
    if(answerText.isEmpty){
       ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('please write an answer'),
        duration: Duration(seconds: 2),
      ),
    );
    }
    _answerController.clear();
  }*/
int id = 0;
int upvoteCount = 0;
  Future<void> _submitAnswer(String email) async {
    if (_formKey.currentState!.validate()) {
      final String answerText = _answerController.text;
      // Create a Firestore document reference
    final formCollection = FirebaseFirestore.instance.collection('answers');

    // Create a new document with auto-generated ID
    final newFormDoc = formCollection.doc();
    await newFormDoc.set({
      'answerId':id,
      'questionId':widget.questionId,
      'userId':email,
      'answerText':answerText,
      'upvoteCount':upvoteCount,
      
    });
      _answerController.clear();
      id=id+1;
    }
  }

   @override
  Widget build(BuildContext context)  {
    return Scaffold(
      appBar: AppBar(
        title: Text('Answers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                title: Text('Question'), // Replace with your question text
              ),
            ),
          ),
          Expanded(
           child:StreamBuilder<List<CardQuestion>>(
                              stream: readQuestion(),
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  final q= snapshot.data!;
                                  return ListView(
                                    children: q.map(buildQuestionCard).toList(),
                                  );
                                }
                                else if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                }
                
                                else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                               
                               
                
                                
                              },
                            ),),
          Expanded(
            child: StreamBuilder<List<CardAnswer>>(
              stream: readAnswer(),
               builder: (context, snapshot){
                                if(snapshot.hasData){
                                  final a= snapshot.data!;
                                  return ListView(
                                    children: a.map(buildAnswerCard).toList(),
                                  );
                                }
                                else if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                }
                
                                else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                };},
                               
                      
                /*return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final answer =
                        CardAnswer.fromJson(document.data() as Map<String, dynamic>);
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Icon(Icons.reply),
                        title: Text(answer.answerText),
                        subtitle: Text('Upvotes: ${answer.upvoteCount}'),
                      ),
                    );
                  },
                );*/
             
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
                        hintText: 'Write your answer',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your answer';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    
                    onPressed:() async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                final email = prefs.getString('loggedInEmail') ??'';
                _submitAnswer(email);
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