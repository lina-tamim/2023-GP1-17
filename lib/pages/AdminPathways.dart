import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techxcel11/models/pathwayscards.dart';
//import 'package:techxcel11/pages/EditPathwayPage.dart';
//import 'package:techxcel11/pages/pathwaycards.dart';
import 'package:techxcel11/pages/reuse.dart';
//firebase++
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path/path.dart' as path;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/resource.dart';
import '../user_image.dart';
import 'package:lottie/lottie.dart';

class AdminPathways extends StatefulWidget {
  const AdminPathways({Key? key});

  @override
  State<AdminPathways> createState() => _AdminPathwaysState();
}

class _AdminPathwaysState extends State<AdminPathways> {
  int id = 0;

  //firebase++
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool showWhiteBox = false; // Track whether to show the white box
  bool _isHidden = true;

  final TextEditingController _pathTitle = TextEditingController();
  final List<TextEditingController> _topics = [];
  final List<TextEditingController> _descriptions = [];
  final List<List<TextEditingController>> _resourceControllersList = [];
  File? _selectedImage;
  final TextEditingController _path_descriptions = TextEditingController();

  List<String> _SelectTopic = [];

  void _showMultiSelectTopic() async {
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
        _SelectTopic); // Store the selected topics outside of the dialog

    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        final List<String> chosenTopics = List<String>.from(selectedTopics);

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
        _SelectTopic = result;
      });
    }
  }

  Future<Map<String, dynamic>> fetchContainerData() async {
    final DocumentSnapshot snapshot =
        await firestore.collection('pathway').doc('title').get();
    return snapshot.data() as Map<String, dynamic>;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _addField();
      fetchContainerData().then((data) {
        setState(() {
          // Update the container data once retrieved from the database
        });
      });
    });
  }

  _addField() {
    setState(() {
      _topics.add(TextEditingController());
      _descriptions.add(TextEditingController());

      // Initialize the resource controllers for the new field
      List<TextEditingController> resourceControllers = [];
      resourceControllers.add(TextEditingController());
      _resourceControllersList.add(resourceControllers);
    });
  }

  _remove(int index) {
    setState(() {
      if (index >= 1) {
        _topics.removeAt(index);
        _descriptions.removeAt(index);

        // Remove the resource controllers
        _resourceControllersList.removeAt(index);
      }
    });
  }

  // new
  bool showSearchtBarPath = false;

  TextEditingController searchpathController = TextEditingController();

  //

  Stream<List<PathwayContainer>> readPathway() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('pathway');

    // search

    if (searchpathController.text.isNotEmpty) {
      query = query
          .where('title', isGreaterThanOrEqualTo: searchpathController.text)
          .where('title',
              isLessThanOrEqualTo: searchpathController.text + '\uf8ff');
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
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
                              deletePathway(context, pathway.title)
                                  .then((deletionConfirmed) {
                                if (deletionConfirmed) {
                                  _showSnackBar('Pathway deleted successfully');
                                  print('Delete button pressed');
                                }
                              });
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              print('Edit button pressed');
                            },
                            icon: Icon(Icons.edit),
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
                                  fontWeight: FontWeight.bold),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: const NavBarAdmin(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme:
            IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
        backgroundColor: Color.fromRGBO(37, 6, 81, 0.898),
        toolbarHeight: 120, // Adjust the height of the AppBar
        elevation: 0, // Adjust the position of the AppBar
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(130),
            bottomRight: Radius.circular(130),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Builder(builder: (context) {
                  return IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: Icon(Icons.menu));
                }),
                const Text(
                  'Pathway Management ',
                  style: TextStyle(
                    fontSize: 18, // Adjust the font size
                    fontFamily: "Poppins",
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      setState(() {
                        showSearchtBarPath = !showSearchtBarPath;
                      });
                    },
                    icon: Icon(
                        showSearchtBarPath ? Icons.search_off : Icons.search))
              ],
            ),
            const SizedBox(
              height: 0,
            ),
            if (showSearchtBarPath)
              TextField(
                controller: searchpathController,
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
      body: Stack(
        children: [
          Positioned(
            bottom: 60,
            right: 50,
            child: Column(
              children: [],
            ),
          ),

          if (!showWhiteBox)
            Stack(
              children: [
                StreamBuilder<List<PathwayContainer>>(
                  stream: readPathway(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final q = snapshot.data!;

                      if (q.isEmpty) {
                        return Center(
                          child: Text('No Pathways Yet'),
                        );
                      }
                      return ListView(
                        children: q.map(buildpathwayCard).toList(),
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
                Positioned(
                  bottom: 60,
                  right: 50,
                  child: FloatingActionButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      setState(() {
                        showWhiteBox =
                            !showWhiteBox; // Show or hide the white box
                      });
                    },
                    backgroundColor: Color.fromARGB(255, 156, 147, 176),
                    child: const Icon(
                      Icons.add,
                      color: Color.fromARGB(255, 255, 255, 255),
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),

          // SHOW FROM

          if (showWhiteBox)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          if (showWhiteBox)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
              top: MediaQuery.of(context).size.height * 0.07,
              bottom: MediaQuery.of(context).size.height * 0.06,
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 20, right: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showWhiteBox = false;
                                  _isHidden = true; // Hide the white box
                                });
                                cleareFields();
                              },
                              child: Icon(
                                Icons.arrow_back,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 40),
                            Text(
                              'Add a Pathway ',
                              style: TextStyle(
                                  fontSize: 24, fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 7),
                        child: Text(
                          'Add pathways and unlock a world of knowledge!',
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
                      SizedBox(
                        height: 10,
                      ),
                      //image++
                      UserImagePicker(
                        onPickImage: (pickedImage) {
                          _selectedImage = pickedImage;
                        },
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text(
                          'Please make sure to include at least one component (topic, description and resource)',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Pathway\'s Title',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            reusableTextField("Please enter pathway's title",
                                Icons.title, false, _pathTitle, true),
                            const SizedBox(
                              height: 20,
                            ),
                            const Row(
                              children: [
                                Text(
                                  'Pathway\'s Description',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              enabled: true,
                              controller: _path_descriptions,
                              maxLines: 4,
                              cursorColor:
                                  const Color.fromARGB(255, 43, 3, 101),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.description,
                                    color:
                                        const Color.fromARGB(255, 63, 12, 118)),
                                labelText:
                                    "Please enter pathway's\n\ndescription",
                                labelStyle: const TextStyle(
                                  color: Colors.black54,
                                ),
                                filled: true,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                fillColor:
                                    const Color.fromARGB(255, 228, 228, 228)
                                        .withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                const Text(
                                  'Topics',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            ElevatedButton(
                              onPressed: _showMultiSelectTopic,
                              child: const Text('Select Topics'),
                            ),

                            // Display the selected items
                            Wrap(
                              children: _SelectTopic // Updated variable name
                                  .map((e) => Chip(
                                        label: Text(e),
                                      )).toList(),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        width: 200,
                        height: 50,
                        child: Visibility(
                          visible: _isHidden,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isHidden =
                                    false; // Show the hidden part when the button is clicked
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 198, 180, 247),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 10,
                              shadowColor:
                                  Color.fromARGB(255, 0, 0, 0).withOpacity(1),
                            ),
                            child: Text(
                              'Next',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Move the ListView here inside the white box
                      Visibility(
                        visible: !_isHidden,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 300,
                              child: Divider(
                                color: Color.fromARGB(255, 211, 211, 211),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 5),
                              child: Text(
                                'Please note that you can add more than one topic',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _topics.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final isRemovable = index >
                                      0; // Check if the field is removable

                                  return Column(
                                    children: [
                                      Row(
                                        //mainAxisAlignment:
                                        // MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(18.0),
                                            child: Text(
                                              'SubTopic - ${index + 1}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 56, 9, 150)),
                                            ),
                                          ),
                                          Spacer(),
                                          if (isRemovable)
                                            InkWell(
                                              child: const Icon(
                                                  Icons.remove_circle),
                                              onTap: () {
                                                _remove(index);
                                              },
                                            ),
                                          InkWell(
                                            child: const Icon(Icons.add_circle),
                                            onTap: () {
                                              _addField();
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 0),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Text(
                                                  'Sub-Topic Title',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  '*',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            reusableTextField(
                                              "Please enter pathway's subtopic",
                                              Icons.topic,
                                              false,
                                              _topics[index],
                                              true,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      //descriptionlarger

                                      //description
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Text(
                                                  'Description',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  '*',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              enabled: true,
                                              controller: _descriptions[index],
                                              maxLines: 4,
                                              cursorColor: const Color.fromARGB(
                                                  255, 43, 3, 101),
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.description,
                                                  color: const Color.fromARGB(
                                                      255, 63, 12, 118),
                                                ),
                                                labelText:
                                                    "Please enter subtopic's\n\nDescription",
                                                labelStyle: const TextStyle(
                                                  color: Colors.black54,
                                                ),
                                                filled: true,
                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior.never,
                                                fillColor: const Color.fromARGB(
                                                        255, 228, 228, 228)
                                                    .withOpacity(0.3),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(32),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),

                                      //resources
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Text(
                                                  'Resource',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  '*',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Tooltip(
                                                  child: Icon(
                                                    Icons.live_help_rounded,
                                                    size: 18,
                                                    color: Color.fromARGB(
                                                        255, 178, 178, 178),
                                                  ),
                                                  message:
                                                      'Note: The resource for learning can be any of the following types:\n'
                                                      '- Online courses or websites (e.g., Coursera, Udemy)\n'
                                                      '- YouTube content such as playlists or channels\n'
                                                      '- Research papers and articles',
                                                  padding: EdgeInsets.all(20),
                                                  showDuration:
                                                      Duration(seconds: 3),
                                                  textStyle: TextStyle(
                                                      color: Colors.white),
                                                  preferBelow: false,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            for (var i = 0;
                                                i <
                                                    _resourceControllersList[
                                                            index]
                                                        .length;
                                                i++)
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: reusableTextField(
                                                      "Please enter subtopic's resource",
                                                      Icons.link_sharp,
                                                      false,
                                                      _resourceControllersList[
                                                          index][i],
                                                      true,
                                                    ),
                                                  ),
                                                  if (i ==
                                                      _resourceControllersList[
                                                                  index]
                                                              .length -
                                                          1)
                                                    InkWell(
                                                      child: const Icon(
                                                          Icons.add_circle),
                                                      onTap: () {
                                                        setState(() {
                                                          _resourceControllersList[
                                                                  index]
                                                              .add(
                                                                  TextEditingController());
                                                        });
                                                      },
                                                    ),
                                                  if (i != 0)
                                                    InkWell(
                                                      child: const Icon(
                                                          Icons.remove_circle),
                                                      onTap: () {
                                                        setState(() {
                                                          _resourceControllersList[
                                                                  index]
                                                              .removeAt(i);
                                                        });
                                                      },
                                                    ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: Visibility(
                          visible: !_isHidden,
                          child: ElevatedButton(
                            onPressed: () async {
                              //firebase++
                              if (await _validateFields()) {
                                if (await saveDataToFirestore()) {
                                  _showSnackBar('Pathway added successfully!');
                                  setState(() {
                                    showWhiteBox = false;
                                    _isHidden = true;
                                  });
                                  cleareFields();
                                } else {
                                  _showSnackBar(
                                      'Failed to save data to Firestore!');
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 198, 180, 247),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 10,
                              shadowColor:
                                  Color.fromARGB(255, 0, 0, 0).withOpacity(1),
                            ),
                            child: Text(
                              'Add Pathway',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          //////////////////// END FORM
        ],
      ),
    );
  }

  // DB

  Future<bool> saveDataToFirestore() async {
    try {
      // Create a new document reference
      DocumentReference documentReference =
          firestore.collection('pathway').doc();
      //validation++
      String newTitle = _pathTitle.text.trim();
      bool isUnique = await isTitleUnique(newTitle);
      if (!isUnique) {
        // Title already exists, display message
        _showSnackBar('Please enter a new title');
        return false; // Data save failed
      }
      //image++
      String imagePath = "";
      if (_selectedImage != null) {
        // If user selected an image
        imagePath =
            'pathways_images/${documentReference.id}${path.extension(_selectedImage!.path)}'; // Generate a unique image path
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference storageRef = storage.ref().child(imagePath);
        UploadTask uploadTask = storageRef.putFile(_selectedImage!);
        await uploadTask.whenComplete(() => null);
      } else {
        // If no image is selected, use the default image from assets
        ByteData defaultImageData =
            await rootBundle.load('assets/Backgrounds/navbarbg2.png');
        List<int> defaultImageBytes = defaultImageData.buffer.asUint8List();
        Directory tempDir = await getTemporaryDirectory();
        String tempPath =
            '${tempDir.path}/${path.basename('assets/Backgrounds/navbarbg2.png')}';
        File tempFile = File(tempPath);
        await tempFile.writeAsBytes(defaultImageBytes);
        imagePath =
            'pathways_images/${documentReference.id}.png'; // Generate a unique image path
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference storageRef = storage.ref().child(imagePath);
        UploadTask uploadTask = storageRef.putFile(tempFile);
        await uploadTask.whenComplete(() => null);
        await tempFile.delete(); // Delete the temporary file
      }

      String imageUrl =
          await FirebaseStorage.instance.ref(imagePath).getDownloadURL();

      List<List<String>> flattenedResources = _resourceControllersList
          .map((controllers) =>
              controllers.map((controller) => controller.text).toList())
          .toList();

      // Flatten the nested array
      List<String> flattenedResourcesList = [];
      for (List<String> resourceList in flattenedResources) {
        flattenedResourcesList.addAll(resourceList);
      }

  //RESOURCES PART

      for (int i = 0; i < _resourceControllersList.length; i++) {
      List<String> subtopicResources = _resourceControllersList[i]
          .map((controller) => controller.text)
          .toList();

      // Create a new document reference in the "resources" collection
      DocumentReference resourceDocumentRef =
          firestore.collection('resources').doc();

      // Save resource data to Firestore
      await resourceDocumentRef.set({
        'pathway_id': documentReference.id,
        'subtopic_id': i,
        'link': subtopicResources,
      });
    }
      // Save the flattened resources list to Firestore
      await documentReference.set({
        'title': _pathTitle.text,
        'path_description': _path_descriptions.text,
        'Key_topic': _SelectTopic,
        'topics': _topics.map((controller) => controller.text).toList(),
        'descriptions':
            _descriptions.map((controller) => controller.text).toList(),
        'resources': flattenedResourcesList,
        'image_url': imageUrl,
        'id': id,
        'docId':documentReference.id,
      });

      // Display a success message or perform any other actions
      print('***Data saved to Firestore');
      id = id + 1;
      return true; // Data saved successfully
    } catch (error) {
      // Error occurred while saving data
      print('Error saving data to Firestore: $error');
      return false; // Data save failed
    }
  }

  /////// VALIDATION
  /////validation++
  Future<bool> isTitleUnique(String title) async {
    // Check if the title exists in the pathways collection
    QuerySnapshot querySnapshot = await firestore
        .collection('pathway')
        .where('title', isEqualTo: title.toLowerCase())
        .get();

    return querySnapshot
        .docs.isEmpty; // Return true if no matching title exists
  }

  Future<bool> _validateFields() async {
    // Validate the title field
    if (_pathTitle.text.isEmpty) {
      _showSnackBar('Please enter the title');
      return false; // Return early if the title field is empty
    }

    if (_path_descriptions.text.isEmpty) {
      _showSnackBar('Please enter the pathway\'s description');
      return false; // Return early if the title field is empty
    }

    if (_SelectTopic.isEmpty) {
      _showSnackBar('Please enter the pathway\'s KeyWords');
      return false; // Return early if the title field is empty
    }

    // Validate the topics, descriptions, and resources
    for (int i = 0; i < _topics.length; i++) {
      if (_topics[i].text.isEmpty || _descriptions[i].text.isEmpty) {
        _showSnackBar('Please fill all fields for topic ${i + 1}');
        return false; // Return early if any topic or description field is empty
      }

      for (int j = 0; j < _resourceControllersList[i].length; j++) {
        if (_resourceControllersList[i][j].text.isEmpty) {
          _showSnackBar('Please fill all fields for topic ${i + 1}');
          return false; // Return early if any resource field is empty
        }
      }
    }

    return true;
  }

  void cleareFields() {
    // Clear the title field
    _pathTitle.clear();
    _path_descriptions.clear();
    _SelectTopic.clear();
// remove the opened fields >1 "the muust field "
    if (_topics.length > 1) {
      _topics.removeRange(1, _topics.length);
      _descriptions.removeRange(1, _descriptions.length);
    }
    if (_resourceControllersList.length > 0 &&
        _resourceControllersList[0].length > 1) {
      _resourceControllersList[0]
          .removeRange(1, _resourceControllersList[0].length);
    }

    // Clear the topics, descriptions, and resources
    for (int i = 0; i < _topics.length; i++) {
      _topics[i].clear();
      _descriptions[i].clear();
      for (int j = 0; j < _resourceControllersList[i].length; j++) {
        _resourceControllersList[i][j].clear();
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 80,
          right: 20,
          left: 20,
        ),
        backgroundColor:
            Color.fromARGB(255, 63, 12, 118), // Customize the background color
      ),
    );
  }

  // delete
  Future<bool> deletePathway(BuildContext context, String Ptitle) async {
    // Show a confirmation dialog
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this pathway?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Not confirmed
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmed
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('pathway')
              .where('title', isEqualTo: Ptitle)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> pathwayDoc =
            snapshot.docs.first;
        final String pathId = pathwayDoc.id;

        // Delete pathway document from Firestore
        await FirebaseFirestore.instance
            .collection('pathway')
            .doc(pathId)
            .delete();

        return true;
      }
    }

    return false;
  }


Future<List<String>> getResourcesFromFirestore(PathwayContainer path) async {
  try {

    DocumentReference documentReference =
          firestore.collection('pathway').doc();
          String? idPath = path.docId;
   
print("@@@@@@  INSIDE RESOURCE DB");
print("@@@@@@  id is $idPath");

    // Query Firestore to retrieve resources with matching pathway_id
    QuerySnapshot snapshot = await firestore
        .collection('resources')
        .where('pathway_id', isEqualTo: idPath)
        .orderBy('subtopic_id')
        .get();

    // Extract the links from the snapshot
List<String> resources = snapshot.docs
    .map((doc) => (doc['link']  ).toString())
    .toList();
    resources.sort();

    print("@@@  RESPURCE ARE: $resources");

    return resources;
  } catch (error) {
    // Handle the error appropriately
    throw error;
  }
}



  void moreInfo(PathwayContainer pathway) {
    int i = 0;
 showDialog(
    context: context,
    builder: (BuildContext context) {
      Map<String, bool> expandedStates = {};
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 16),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            content: FutureBuilder<List<String>>(
              future: getResourcesFromFirestore(pathway),
              builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error retrieving resources: ${snapshot.error}');
                } else {
                  List<String> resources = snapshot.data ?? [];
                  print("######## RES: $resources");

                  return SingleChildScrollView(
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

                            int x = index;
                            if (expandedStates[subtopic] == null) {
                              expandedStates[subtopic] = false;
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.amber,
                                      ),
                                      child: Icon(
                                        Icons.star,
                                        color: Colors.white,
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
                                        color: const Color.fromARGB(255, 81, 81, 81),
                                      ),
                                    ),
                                  ),

                                //resources
                                if (expandedStates[subtopic] ?? false)
                                  Padding(
                                    padding: EdgeInsets.only(left: 22.0, top: 8.0),
                                    child: Column(
                                      children: resources.map((resource) {
                                        return GestureDetector(
                                          onTap: () {
                                            launch(resource);
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.link),
                                              SizedBox(width: 4.0),
                                              Text(
                                                resources[x++],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blue,
                                                  decoration: TextDecoration.underline,
                                       
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }
              },
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

  /*Color _getCircleColor(int index) {
    List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }*/
}
