import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/Models/PathwaysCard.dart';

class UserPathwaysPage extends StatefulWidget {
  const UserPathwaysPage({super.key, required this.searchQuery});
  final String searchQuery;

  @override
  State<UserPathwaysPage> createState() => _UserPathwaysPageState();
}

int _currentIndex = 0;

class _UserPathwaysPageState extends State<UserPathwaysPage> {
  int id = 0;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<Map<String, dynamic>> fetchContainerData() async {
    final DocumentSnapshot snapshot =
        await firestore.collection('Pathway').doc('title').get();
    return snapshot.data() as Map<String, dynamic>;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      fetchContainerData().then((data) {
        setState(() {});
      });
    });
  }

  List<String> filteredTopics = [];
  bool showSearchtBarPath = false;
  Stream<List<PathwayContainer>> readPathway() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('Pathway');
    if (widget.searchQuery.isNotEmpty) {
      String searchText = widget.searchQuery;

      query = query
          .where('title',
              isGreaterThanOrEqualTo: widget.searchQuery.toLowerCase())
          .where('title',
              isLessThanOrEqualTo: widget.searchQuery.toLowerCase() + '\uf8ff');
    } else {
      query = query.orderBy('title', descending: true);
    }

    return query.snapshots().asyncMap((snapshot) async {
      final pathway = snapshot.docs
          .map((doc) =>
              PathwayContainer.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      if (pathway.isEmpty) return [];

      // topic filter

      return pathway;
    });
  }

  List<PathwayContainer> filterPathways(List<PathwayContainer> pathways) {
    final filterText = widget.searchQuery.toLowerCase();

    return pathways.where((pathway) {
      final titleMatches = pathway.title.toLowerCase().contains(filterText);

      return titleMatches;
    }).toList();
  }

  Widget buildpathwayCard(PathwayContainer pathway) {
    Widget imageWidget;

    if (pathway.imagePath == 'assets/Backgrounds/navbarbg2.png') {
      // Display the default image
      imageWidget = Image.asset(pathway.imagePath);
    } else {
      // Display the image from URL
      imageWidget = Image.network(pathway.imagePath);
    }

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
                            spacing: 4.0,
                            runSpacing: 2.0,
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
                            // Add functionality next sprints
                          },
                          icon: Icon(
                            Icons.bookmark_add,
                            color: Color.fromARGB(255, 150, 202, 245),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Call the more info method to show a dialog
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(height: 20),
        Expanded(
          child: StreamBuilder<List<PathwayContainer>>(
            stream: readPathway(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final pathways = snapshot.data!;

                if (pathways.isEmpty) {
                  return Center(
                    child: Text('No Pathways Yet'),
                  );
                }

                final filteredPathways = filterPathways(pathways);

                return ListView(
                  children: [
                    ...filteredPathways.map(buildpathwayCard).toList(),
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
        ),
      ]),
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

    final List<String> selectedTopics = List<String>.from(
        _SelectTopicFilter); // Store the selected topics outside of the dialog

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
