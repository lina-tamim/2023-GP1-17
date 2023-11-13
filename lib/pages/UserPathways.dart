//Full code, m s
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path/path.dart' as path;
import 'package:google_fonts/google_fonts.dart';
import 'package:techxcel11/models/pathwayscards.dart';
import 'package:url_launcher/url_launcher.dart';
import '../user_image.dart';
import 'package:lottie/lottie.dart';
import 'package:techxcel11/pages/reuse.dart';

enum ExerciseFilter { walking, running, cycling, hiking }

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
        await firestore.collection('pathway').doc('title').get();
    return snapshot.data() as Map<String, dynamic>;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      //_addField();
      fetchContainerData().then((data) {
        setState(() {
          // Update the container data once retrieved from the database
        });
      });
    });
  }

  bool showSearchtBarPath = false;

  // TextEditingController searchpathController = TextEditingController();

  Stream<List<PathwayContainer>> readPathway() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('pathway');

    // search

    if (widget.searchQuery.isNotEmpty) {
      query = query
          .where('title', isGreaterThanOrEqualTo: widget.searchQuery)
          .where('title', isLessThanOrEqualTo: widget.searchQuery + '\uf8ff');
    }

    return query.snapshots().asyncMap((snapshot) async {
      final pathway = snapshot.docs
          .map((doc) =>
              PathwayContainer.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      if (pathway.isEmpty) return [];

      return pathway;
    });
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
            //width: 200, // Adjust the width of the card as per your requirement
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
                height: 100,
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
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                            // Delete button logic
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
                      icon:
                          SizedBox(), // Empty SizedBox to maintain proper alignment
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'I want to learn...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // FilterChipExample(key: UniqueKey()),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PathwayContainer>>(
              stream: readPathway(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final q = snapshot.data!;
                  final filterText = widget.searchQuery.toLowerCase();

                  if (q.isEmpty) {
                    return Center(
                      child: Text('No Pathways Yet'),
                    );
                  }

                  final filteredQ = filterText.isEmpty
                      ? q
                      : q.where((pathway) =>
                          pathway.title.toLowerCase().contains(filterText));

                  return ListView(
                    children: [
                      ...filteredQ.map(buildpathwayCard).toList(),
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
                                    launch(
                                        'http://example.com'); // Replace with the actual URL
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.link),
                                      SizedBox(width: 4.0),
                                      Text(
                                        'here resource',
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
}

/*
class FilterChipExample extends StatefulWidget {
  const FilterChipExample({required Key key}) : super(key: key);

  @override
  State<FilterChipExample> createState() => _FilterChipExampleState();
}

class _FilterChipExampleState extends State<FilterChipExample> {
  Set<ExerciseFilter> filters = <ExerciseFilter>{};

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Choose an exercise', style: textTheme.headline6),
          const SizedBox(height: 5.0),
          Wrap(
            spacing: 5.0,
            children: ExerciseFilter.values.map((ExerciseFilter exercise) {
              return FilterChip(
                label: Text(exercise.name),
                selected: filters.contains(exercise),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      filters.add(exercise);
                    } else {
                      filters.remove(exercise);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10.0),
          Text(
            'Looking for: ${filters.map((ExerciseFilter e) => e.name).join(', ')}',
            style: textTheme.headline6,
          ),
        ],
      ),
    );
  }
}*/



