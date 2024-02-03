import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techxcel11/Models/ViewQCard.dart';
import 'package:techxcel11/pages/UserPages/AnswerPage.dart';

class ReposrtedPost extends StatefulWidget {
  const ReposrtedPost({super.key});

  @override
  State<ReposrtedPost> createState() => _ReposrtedPostState();
}

int _currentIndex = 0;

class _ReposrtedPostState extends State<ReposrtedPost> {
  final searchController = TextEditingController();

  bool showSearchBar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  const SizedBox(width: 140),
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
                    // Handle search input changes
                  },
                ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<CardQview>>(
                  stream: readReportedQuestion(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final q = snapshot.data!;
                      if (q.isEmpty) {
                        return Center(
                          child: Text('No Reported Post'),
                        );
                      }
                      return ListView(
                        children: q.map(buildQuestionCard).toList(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<List<CardQview>> readReportedQuestion() {
    return FirebaseFirestore.instance
        .collection('Report')
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

      final questionIds =
          reportedPosts.map((post) => post['postId'] as String).toList();

      // Retrieve details of the reported posts from the 'Question' table
      final questionDocs = await FirebaseFirestore.instance
          .collection('Question')
          .where(FieldPath.documentId, whereIn: questionIds)
          .get();

      final questions = questionDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        data['docId'] = doc.id;
        return CardQview.fromJson(data);
      }).toList();

      // Get user-related information for each question
      final userIds = questions.map((question) => question.userId).toSet();
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

      questions.forEach((question) {
        final userDoc = userMap[question.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';
        final reportedPost = reportedPosts.firstWhere(
          (post) => post['postId'] == question.questionDocId,
          orElse: () => <String, dynamic>{},
        );
        final reason = reportedPost['reason'] as String? ??
            ''; // Get the reason from the ReportedPost table
        question.username = username;
        question.userPhotoUrl = userPhotoUrl;
        question.reason = reason; // Assign the reason to the reason property
      });

      return questions;
    });
  }

  Widget buildQuestionCard(CardQview question) => Card(
        child: ListTile(
          leading: CircleAvatar(
            // ignore: unnecessary_null_comparison
            backgroundImage: question.userPhotoUrl != null
                ? NetworkImage(question.userPhotoUrl!)
                : null,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Text(
                question.username ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 34, 3, 87),
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
              SizedBox(height: 5),
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
                    icon: Icon(Icons.comment,
                        color: Color.fromARGB(255, 63, 63, 63)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AnswerPage(questionId: question.id)),
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
                "Reason: ${question.reason ?? ''}", // Display the reason here
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red, // Customize the color if needed
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 22, 146, 0),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Accept',
                      style:
                          TextStyle(color: Color.fromARGB(255, 254, 254, 254))),
                ),
                  ElevatedButton(
                    onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 122, 1, 1),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Reject',
                    style: TextStyle(color: Color.fromARGB(255, 254, 254, 254)),
                  ),
                  )
                ],
              )
            ],
          ),
        ),
      );
}
