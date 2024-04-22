import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/Models/FormCard.dart';
import 'package:techxcel11/Models/PathwaysCard.dart';
import 'package:techxcel11/Models/PostCard.dart';
import 'package:techxcel11/Models/QuestionCard.dart';
import 'package:techxcel11/Models/ViewAnswerCard.dart';
import 'package:techxcel11/Models/ViewQCard.dart';
import 'package:techxcel11/pages/UserPages/AnswerPage.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/pages/UserPages/UserInteractionPage.dart';
import 'package:techxcel11/pages/UserPages/UserProfileView.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';

class BookmarkPage extends StatefulWidget {
  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _loggedInImage = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _tabController = TabController(length: 2, vsync: this);
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

      setState(() {
        _loggedInImage = imageURL;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  AppBar buildAppBarWithTabs(
      String titleText, TabController tabController, _loggedInImage) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Color.fromARGB(255, 242, 241, 243),
      iconTheme: IconThemeData(
        color: Color.fromRGBO(37, 6, 81, 0.898),
      ),
      toolbarHeight: 70,
      title: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_loggedInImage.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(_loggedInImage),
                    ),
                  ),
                const SizedBox(width: 8),
                const Text(
                  'Bookmark',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Poppins",
                    color: Color.fromRGBO(37, 6, 81, 0.898),
                  ),
                ),
                const SizedBox(width: 120),
              ],
            ),
          ],
        ),
      ),
      bottom: TabBar(
        controller: tabController,
        //indicator: UnderlineTabIndicator(
        //borderSide: BorderSide(
        //width: 5.0,
        //color: Color.fromARGB(
        //  255, 27, 5, 230), // Set the color of the underline
        //),
        // Adjust the insets if needed
        //),
        //labelColor: Color.fromARGB(255, 27, 5, 230),
        tabs: [
          Tab(
            child: Text(
              'Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
            ),
          ),
          Tab(
            child: Text(
              'Pathways',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWithTabs('Explore', _tabController, _loggedInImage),
      drawer: NavBarUser(),
      body: TabBarView(
        controller: _tabController,
        children: [
          UserBookmarkedQuestions(),
          UserBookmarkedPathways(),
        ],
      ),
    );
  }
}

class UserBookmarkedPathways extends StatefulWidget {
  @override
  State<UserBookmarkedPathways> createState() => _UserBookmarkedPathwaysState();
}

int _currentIndex = 0;

class _UserBookmarkedPathwaysState extends State<UserBookmarkedPathways> {
  int id = 0;
  late FirebaseFirestore firestore;
  late SharedPreferences prefs;
  late String email = '';

  @override
  void initState() {
    super.initState();
    initializeVariables();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchContainerData().then((data) {
        setState(() {});
      });
    });
  }

  Future<void> initializeVariables() async {
    firestore = FirebaseFirestore.instance;
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('loggedInEmail') ?? '';
    print(email);
    print("**********");
  }

  List<String> filteredTopics = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Material(
                    // Wrap PopupMenuButton with Material
                    elevation: 0, // Set elevation to 0 to remove shadow
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(60), // Set the border radius
                    ),
                    child: PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: Container(
                            padding:
                                EdgeInsets.all(8.0), // Add padding as needed
                            child: Text(
                              'Clear All Bookmarked Pathways',
                              style:
                                  TextStyle(fontSize: 15), // Set the font size
                            ),
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 1) {
                          removeAllBookmarkedPathways();
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<PathwayContainer>>(
                    stream: readPathway(),
                    builder: (context, pathwaySnapshot) {
                      if (pathwaySnapshot.hasData) {
                        final pathways = pathwaySnapshot.data!;

                        if (pathways.isEmpty) {
                          return Center(
                            child: Text('No Saved Pathways'),
                          );
                        }

                        return ListView.builder(
                          itemCount: pathways.length,
                          itemBuilder: (context, index) {
                            return buildpathwayCard(pathways[index]);
                          },
                        );
                      } else if (pathwaySnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${pathwaySnapshot.error}'),
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

  Stream<List<PathwayContainer>> readPathway() {
    return FirebaseFirestore.instance
        .collection('Bookmark')
        .where('bookmarkType', isEqualTo: 'pathway')
        .where('userId', isEqualTo: email)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<PathwayContainer> pathways = [];

      print('Bookmark Snapshot Size: ${snapshot.size}');

      for (final doc in snapshot.docs) {
        final postId = doc['postId'];
        print('Post ID: $postId');

        final pathwaySnapshot = await FirebaseFirestore.instance
            .collection('Pathway')
            .doc(postId)
            .get();

        if (pathwaySnapshot.exists) {
          pathways.add(PathwayContainer.fromJson(
            pathwaySnapshot.data() as Map<String, dynamic>,
          ));
        }
      }
      return pathways;
    });
  }

  Future<Map<String, dynamic>?> fetchContainerData() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection('Bookmark')
        .where('bookmarkType', isEqualTo: 'pathway')
        .where('userId', isEqualTo: email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final pathwayId = snapshot.docs[0].id;
      final pathwaySnapshot = await FirebaseFirestore.instance
          .collection('Pathway')
          .doc(pathwayId)
          .get();

      if (pathwaySnapshot.exists) {
        return pathwaySnapshot.data() as Map<String, dynamic>;
      }
    }
    return null;
  }

  Widget buildpathwayCard(PathwayContainer pathway) {
    if (pathway.imagePath == 'assets/Backgrounds/navbarbg2.png') {}
    return Padding(
      padding: EdgeInsets.all(8.0), // Add space between each card
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(95, 92, 92, 92).withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(0, 2), // Set shadow offset
                ),
              ],
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(pathway.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pathway.title,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15.0),
                    Text(
                      pathway.path_description,
                      style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 81, 81, 81)),
                    ),
                    SizedBox(height: 8.0),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Wrap(
                            spacing:  -5,
                            runSpacing: -5,
                            children: pathway.Key_topic.map(
                              (topic) => Chip(
                                label: Text(
                                  topic,
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              ),
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: 6,
                  left: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            removePathwayFromBookmark(pathway);
                          },
                          icon: Icon(
                            Icons.bookmark_remove,
                            color: Color.fromARGB(255, 138, 0, 0),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        moreInfo(pathway);
                      },
                      label: const Row(
                        children: [
                          Text(
                            'Explore',
                            style: TextStyle(
                              color: Color.fromARGB(255, 150, 202, 245),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Color.fromARGB(255, 150, 202, 245),
                          ),
                        ],
                      ),
                      icon: SizedBox(),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> removeAllBookmarkedPathways() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Bookmark')
          .where('userId', isEqualTo: email)
          .where('bookmarkType', isEqualTo: 'pathway')
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('All bookmarked pathways removed successfully!');
    } catch (error) {
      print('Error removing bookmarked pathways: $error');
    }
  }

  Future<void> removePathwayFromBookmark(PathwayContainer pathway) async {
    try {
      // Query to find the bookmarked pathway
      final QuerySnapshot<Map<String, dynamic>> existingBookmark =
          await firestore
              .collection('Bookmark')
              .where('bookmarkType', isEqualTo: 'pathway')
              .where('userId', isEqualTo: email)
              .where('postId', isEqualTo: pathway.pathwayDocId)
              .get();

      if (existingBookmark.docs.isNotEmpty) {
        // If the bookmarked pathway is found, delete it
        await Future.forEach(existingBookmark.docs,
            (DocumentSnapshot<Map<String, dynamic>> doc) async {
          await doc.reference.delete();
        });

        print('Pathway removed from bookmarks successfully!');
      } else {
        // If the bookmarked pathway is not found, you can handle it accordingly
        print('Pathway is not bookmarked!');
      }
    } catch (error) {
      // Handle errors, e.g., display an error message or log the error
      print('Error removing pathway from bookmarks: $error');
    }
  }

  void moreInfo(PathwayContainer pathway) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Map<String, bool> expandedStates =
            {}; // Store the expanded state for each subtopic
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 16),
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        pathway.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Center(
                      child: Lottie.network(
                          'https://lottie.host/623f88bb-cb70-413c-bb1a-0003d0b7e3d6/RnPQM25m8I.json'),
                    ),
                    Center(
                      child: Text(
                        pathway.path_description,
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 81, 81, 81),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      width: 300,
                      child: Divider(
                        color: Color.fromARGB(255, 211, 211, 211),
                        thickness: 1,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Center(
                      child: Text(
                        'Get ready to embark on an exciting journey of learning and growth!',
                        style:
                            TextStyle(color: Color.fromARGB(255, 169, 0, 157)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'SubTopics:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: pathway.subtopics.asMap().entries.map((entry) {
                        final index = entry.key;
                        final subtopic = entry.value;
                        if (expandedStates[subtopic] == null) {
                          expandedStates[subtopic] = false;
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                height: 8.0), // Add space between each subtopic
                            Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors
                                        .amber, // Custom function to get circle color based on the index
                                  ),
                                  child: Icon(
                                    Icons.star,
                                    color: Colors
                                        .white, // Set the desired color for the star icon
                                    size: 16,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      expandedStates[subtopic] =
                                          !(expandedStates[subtopic] ?? false);
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Icon(expandedStates[subtopic] ?? false
                                          ? Icons.keyboard_arrow_down
                                          : Icons.keyboard_arrow_right),
                                      SizedBox(width: 8.0),
                                      Text(
                                        subtopic,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color.fromARGB(
                                              255, 81, 81, 81),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (expandedStates[subtopic] ?? false)
                              Padding(
                                padding: EdgeInsets.only(left: 22.0, top: 4.0),
                                child: Text(
                                  pathway.descriptions[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        const Color.fromARGB(255, 81, 81, 81),
                                  ),
                                ),
                              ),
                            if (expandedStates[subtopic] ?? false)
                              Padding(
                                padding: EdgeInsets.only(left: 22.0, top: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    launch(pathway.resources[
                                        index]); // Replace with the actual URL
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.link),
                                      SizedBox(width: 4.0),
                                      Text(
                                        'Click here for resource',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<String> _SelectTopicFilter = [];

  void _showMultiSelectTopic(BuildContext context) async {
    // Rest of the code remains the same
    final Map<String, List<String>> topicGroups = {
      'Data Science': [
        'Python',
        'R',
        'Tableau',
        'Machine learning and artificial intelligence',
        'Big data technologies (Hadoop, Apache Spark)',
        'Data science',
        'Statistical analysis',
        'Natural language processing (NLP)',
        'Robotic process automation (RPA)',
      ],
      'Database Management': [
        'Database management SQL',
        'Database management NoSQL',
        'Database management NewSQL',
      ],
      'Programming Languages': [
        'Java',
        'Node.js',
        'React',
        'C#',
        'C++',
      ],
      'Web Development': [
        'Web development (HTML)',
        'Web development (CSS)',
        'Web development (JavaScript)',
        'Web development (PHP)',
      ],
      'Mobile App Development': [
        'Mobile app development (iOS, Android)',
        'UI/UX design',
        'Swift',
        'Ruby',
        'Flutter and Dart',
      ],
      'Other Topics': [
        'Agile and Scrum methodologies',
        'Virtual reality (VR)',
        'Augmented reality (AR)',
        'Cloud computing',
        'Cybersecurity',
        'Network',
        'Blockchain',
        'Internet of Things (IoT)',
      ],
      'Soft Skills': [
        'Critical thinking',
        'Problem-solving',
        'Communication skills',
        'Collaboration',
        'Attention to detail',
        'Logical reasoning',
        'Creativity',
        'Time management',
        'Adaptability',
        'Leadership',
        'Teamwork',
        'Presentation skills',
      ],
    };

    final List<String> items = topicGroups.keys.toList();

// Store the selected topics outside of the dialog

    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        final List<String> chosenTopics = List<String>.from(_SelectTopicFilter);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select Topics'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    for (String group in items)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...topicGroups[group]!.map((String topic) {
                            return CheckboxListTile(
                              title: Text(topic),
                              value: chosenTopics.contains(topic),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    chosenTopics.add(topic);
                                  } else {
                                    chosenTopics.remove(topic);
                                  }
                                });
                              },
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(chosenTopics);
                    setState(() {
                      filteredTopics = chosenTopics;
                    });
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _SelectTopicFilter = result;
      });
    }
  }
}

class UserBookmarkedQuestions extends StatefulWidget {
  @override
  State<UserBookmarkedQuestions> createState() =>
      _UserBookmarkedQuestionsState();
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
];
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class _UserBookmarkedQuestionsState extends State<UserBookmarkedQuestions> {
  int _currentIndex = 0;
  String loggedInEmail = '';
  String loggedImage = '';

  Future<String> fetchuseremail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final emaill = prefs.getString('loggedInEmail') ?? '';
    return emaill;
  }

  String? email;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('loggedInEmail');
      setState(() {
        this.email = email;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Material(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: Container(
                            padding:
                                EdgeInsets.all(8.0), // Add padding as needed
                            child: Text(
                              'Clear All Bookmarked Questions',
                              style:
                                  TextStyle(fontSize: 15), // Set the font size
                            ),
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 1) {
                          removeAllBookmarkedQuestion();
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<CardQview>>(
                    stream: readBookmarkedQuestion(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final q = snapshot.data!;
                        if (q.isEmpty) {
                          return Center(
                            child: Text('No Saved Questions'),
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

  void showInputDialog() {
    showAlertDialog(
      context,
      FormWidget(),
    );
  }

  Stream<List<CardQview>> readBookmarkedQuestion() {
    return FirebaseFirestore.instance
        .collection('Bookmark')
        .where('bookmarkType', isEqualTo: 'question')
        .where('userId', isEqualTo: email)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return []; // Return an empty list if there are no saved questions.
      }

      final questionIds =
          snapshot.docs.map((doc) => doc['postId'] as String).toList();

      // Retrieve details of saved questions from the 'Question' table
      final questionDocs = await FirebaseFirestore.instance
          .collection('Question')
          .where(FieldPath.documentId, whereIn: questionIds)
          .get();

      final questions = questionDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
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
              doc.data()['email'] as String,
              doc.data() as Map<String, dynamic>,
            )),
      );

      questions.forEach((question) {
        final userDoc = userMap[question.userId];
        final username = userDoc?['username'] as String? ?? '';
        final userPhotoUrl = userDoc?['imageURL'] as String? ?? '';
        //   final userType = userDoc?['userType'] as String? ?? '';
        question.username = username;
        question.userPhotoUrl = userPhotoUrl;
        question.userType = userDoc?['userType'] as String? ?? "";
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
                 fontSize: 15.4,
                ),
              ),
              SizedBox(height: 5),
              Text(question.description, style: TextStyle(
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
                    icon: Icon(
                      Icons.bookmark_remove_sharp,
                      color: Color.fromARGB(255, 138, 0, 0),
                    ),
                    onPressed: () {
                      removeQuestionFromBookmark(question);
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
            ],
          ),
        ),
      );

  Future<void> removeAllBookmarkedQuestion() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Bookmark')
          .where('userId', isEqualTo: email)
          .where('bookmarkType', isEqualTo: 'question')
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('All bookmarked questions removed successfully!');
    } catch (error) {
      print('Error removing questions pathways: $error');
    }
  }

  Future<void> removeQuestionFromBookmark(CardQview question) async {
    try {
      // Query to find the bookmarked pathway
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final QuerySnapshot<Map<String, dynamic>> existingBookmark =
          await firestore
              .collection('Bookmark')
              .where('bookmarkType', isEqualTo: 'question')
              .where('userId', isEqualTo: email)
              .where('postId', isEqualTo: question.docId)
              .get();

      if (existingBookmark.docs.isNotEmpty) {
        // If the bookmarked pathway is found, delete it
        await Future.forEach(existingBookmark.docs,
            (DocumentSnapshot<Map<String, dynamic>> doc) async {
          await doc.reference.delete();
        });

        print('Question removed from bookmarks successfully!');
      } else {
        // If the bookmarked pathway is not found, you can handle it accordingly
        print('Question is not bookmarked!');
      }
    } catch (error) {
      // Handle errors, e.g., display an error message or log the error
      print('Error removing Question from bookmarks: $error');
    }
  }

  void handleReportQuestion(
    String email,
    CardQview question,
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
    selectedOption = null;
  }
}
