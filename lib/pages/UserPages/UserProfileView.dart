

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
import 'package:techxcel11/Models/ViewAnswerCard.dart';
import 'package:techxcel11/pages/UserPages/AnswerPage.dart';
import 'package:techxcel11/providers/profile_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Models/QuestionCard.dart';

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

  Future<String> fetchuseremail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';
    return email;
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
    tabController = TabController(length: 5, vsync: this);
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
                    icon: Icon(Icons.bookmark, color: Color.fromARGB(255, 63, 63, 63)),
                    onPressed: () {
                      addQuestionToBookmarks(email, question);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.comment , color: Color.fromARGB(255, 63, 63, 63)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AnswerPage(questionId: question.id)),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.report, color: Color.fromARGB(255, 63, 63, 63)),
                    onPressed: () {
                      // Add functionality in upcoming sprints
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
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Project')
        .where('userId', isEqualTo: email)
        .orderBy('postedDate', descending: true);

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
                Text(
                  team.username ?? '', // Display the username
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
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
                },
              ),
              IconButton(
                icon: Icon(Icons.report),
                onPressed: () {
                  // Add your functionality next sprints
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

  Stream<List<CardAnswer>> readAnswers() {
    String x = '';
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Answer')
        .where('userId', isEqualTo: email);
    //.orderBy('postedDate', descending: true);

    return query.snapshots().asyncMap((snapshot) async {
      final questions = snapshot.docs.map((doc) {
        final cardAnswer =
            CardAnswer.fromJson(doc.data() as Map<String, dynamic>);
        x = doc.id; // Assign the document ID to the docId field
        return cardAnswer;
      }).toList();
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
      return questions;
    });
  }

  Widget buildAnswerCard(CardAnswer answer) {
    String currentEmail = '';

    Future<String> getCurrentUserEmail() async {
      return await fetchuseremail();
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
            Text(
              answer.username ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
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

                      if (answer.docId == null) {
                        return Text('No document ID');
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(upvotedUserIds.contains(currentEmail)
                                ? Icons.arrow_circle_down
                                : Icons.arrow_circle_up),
                            onPressed: () {
                              setState(() {
                                print("______ IM INT $upvotedUserIds");
                                print("______ IM INT ${answer.docId}");

                                if (upvotedUserIds.contains(currentEmail)) {
                                  upvotedUserIds.remove(currentEmail);
                                  upvoteCount--;
                                } else {
                                  upvotedUserIds.add(currentEmail);
                                  upvoteCount++;
                                }

                                answer.upvoteCount = upvoteCount;
                                answer.upvotedUserIds = upvotedUserIds;

                                FirebaseFirestore.instance
                                    .collection('Answer')
                                    .doc(answer.docId)
                                    .update({
                                  'upvoteCount': upvoteCount,
                                  'upvotedUserIds': upvotedUserIds,
                                }).then((_) {
                                  // Update successful
                                }).catchError((error) {
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
          ],
        ),
      ),
    );
  }

  Stream<List<CardAnswer>> readupvoted() {
    String x = '';
    return FirebaseFirestore.instance
        .collection('Answer')
        .where('upvotedUserIds',
            arrayContains: email) // Replace 'email' with the desired user ID
        .snapshots()
        .asyncMap((snapshot) async {
      final questions = snapshot.docs.map((doc) {
        final cardAnswer =
            CardAnswer.fromJson(doc.data() as Map<String, dynamic>);
        x = doc.id; // Assign the document ID to the docId field
        return cardAnswer;
      }).toList();

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

      return questions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TabController tabController = TabController(length: 5, vsync: this);
    int randomIndex = Random().nextInt(imageList.length);
    String randomImage = imageList[randomIndex];
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
                        bottom: 0,
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
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.all(20),
                        child: OutlinedButton(
                          child: Text(
                            "Chat with $username",
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            context
                                .read<ProfileProvider>()
                                .gotoChat(context, email);
                            // log('MK: clicked on Message: ${email}');
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
                              username,
                              style: const TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
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
                                  size: 19,
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
                                  TextSpan(
                                    text: '     GitHub',
                                    style: TextStyle(
                                      fontSize: 17.5,
                                      color: Colors.black,
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
                                fontSize: 17,
                                color: Color.fromARGB(255, 128, 128, 128)),
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
                                  fontSize: 16.0,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (skills != null && skills.isNotEmpty)
                              SizedBox(height: 16.0),
                            if (skills.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Skills:',
                                  style: TextStyle(
                                    fontSize: 16.0,
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
                      padding: const EdgeInsets.only(top: 8),
                      alignment: Alignment.center,
                      child: TabBar(
                        controller: tabController,
                        indicatorColor: const Color.fromARGB(
                            255, 27, 5, 230), // Change the underline color here
                        labelColor: const Color.fromARGB(
                            255, 27, 5, 230), // Change the text color here
                        tabs: [
                          Tab(text: 'Question'),
                          Tab(text: 'Build\nTeam'),
                          Tab(text: 'Project'),
                          Tab(text: 'Answer'),
                          Tab(text: 'Upvoted'),
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

                      StreamBuilder<List<CardAnswer>>(
                        stream: readupvoted(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final p = snapshot.data!;
                            if (p.isEmpty) {
                              return Center(
                                child: Text('No Upvotes yet'),
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
}
