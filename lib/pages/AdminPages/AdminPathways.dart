import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'package:techxcel11/Models/PathwaysCard.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/Models/UserImage.dart';

class AdminPathways extends StatefulWidget {
  const AdminPathways({Key? key});

  @override
  State<AdminPathways> createState() => _AdminPathwaysState();
}

class _AdminPathwaysState extends State<AdminPathways> {
  //EDIT
int x = 0;
  //to hold values of key topics selected
  List<String> _editSelectTopic = [];
  //hold values retrived from DB
  List<String> subtopicControllers = [];
  List<String> subtopicDescriptionControllers = [];
  List<String> subtopicresourseControllers = [];

  

  // hold new values from user
  List<TextEditingController> topics2 = [];
  List<TextEditingController> descriptions2 = [];
  List<TextEditingController> resourse2 = [];

  List<List<String>> resourcesnew = [];

  //Retrived Values From DB
  String dbimage_url = '';
  String dbtitle = '';
  String dbpath_description = '';
  List<String> dbKey_topic = [];
  List<String> dbsubtopics = [];
  List<String> dbdescriptions = [];
  List<String> dbresourses = [];
  int lenghtOftopics = 0;
  int pathID = 0;
  String? dbdocId = '';

//Modified by user
  String newimage_url = '';
  String newtitle = '';
  String newpath_description = '';
  List<String> newKey_topic = [];
  List<String> newsubtopics = [];
  List<String> newdescriptions = [];
  List<String> newResources = [];

  File? newProfilePicture;

  Future<void> fetchData(PathwayContainer pathway) async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    final pathwayId = pre.getInt('pathwayId_${pathway.id}') ?? '';
    final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection('Pathway')
        .where('pathwayNo', isEqualTo: pathwayId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final pathwayData = snapshot.docs[0].data();
      final image_url = pathwayData['imageURL'] ?? '';
      final title = pathwayData['title'] ?? '';
      final path_description = pathwayData['pathwayDescription'] ?? '';
      final Key_topic = List<String>.from(pathwayData['keyTopic'] ?? []);
      final subtopics = List<String>.from(pathwayData['subtopics'] ?? []);
      final descriptions = List<String>.from(pathwayData['descriptions'] ?? []);
      final resourses = List<String>.from(pathwayData['resources'] ?? []);
       

      newimage_url = image_url;
      newtitle = title;
      newpath_description = path_description;
      newKey_topic = Key_topic;
      newsubtopics = subtopics;
      newdescriptions = descriptions;
      lenghtOftopics = subtopics.length;
      newResources = resourses;

      setState(() {
        _editSelectTopic = pathway.Key_topic;
        dbimage_url = image_url;
        dbtitle = pathway.title;
        dbpath_description = pathway.path_description;
        dbKey_topic = Key_topic;
        dbsubtopics = subtopics;
        dbdescriptions = descriptions;
        pathID = pathway.id;
        //dbdocId = pathway.docId;
        subtopicControllers = pathway.subtopics;
        subtopicDescriptionControllers = pathway.descriptions;
        subtopicresourseControllers = pathway.resources;
      });
    }
  }

  void _showMultiSelectTopicedit() async {
    final Map<String, List<String>> edittopicGroups = {
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

    final List<String> items = edittopicGroups.keys.toList();

    final List<String> selectededitTopics = List<String>.from(
        _editSelectTopic); 

    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        final List<String> chosenTopics = List<String>.from(selectededitTopics);

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
                          ...edittopicGroups[group]!.map((String topic) {
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
        newKey_topic = result;
        _editSelectTopic = result;
      });
    }
  }

  bool showEditBox = false;
//EDIT PART END
  int id = 0;

  //firebase++
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool showWhiteBox = false; // Track whether to show the white box
  bool _isHidden = true;

  final TextEditingController _pathTitle = TextEditingController();
  final List<TextEditingController> _topics = [];
  final List<TextEditingController> _descriptions = [];
  final List<TextEditingController> _resources = [];
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

//EDIT
  void clear() {
    ///SOMETHING IS BEING WROTE AGAIN
    if (topics2.length > 1) {
      topics2.removeRange(1, topics2.length);
      descriptions2.removeRange(1, descriptions2.length);
      resourse2.removeRange(1, resourse2.length);
    }

    for (int i = 0; i < topics2.length; i++) {
      topics2[i].clear();
      descriptions2[i].clear();
      resourse2[i].clear();
    }
   
    _editSelectTopic = [];
  
   subtopicControllers = [];
  subtopicDescriptionControllers = [];
  subtopicresourseControllers = [];
  x=0;
      
   
  }

  //EDIT
  Future<Map<String, dynamic>> fetchContainerData() async {
    final DocumentSnapshot snapshot =
        await firestore.collection('Pathway').doc('title').get();
    return snapshot.data() as Map<String, dynamic>;
  }

  @override
  void initState() {
    super.initState();
    _addfieldsub();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _addField();
      fetchContainerData().then((data) {
        setState(() {
          // Update the container data once retrieved from the database
        });
      });
    });
  }

  //edit
  _addfieldsub() {
    setState(() {
      topics2.add(TextEditingController());
      descriptions2.add(TextEditingController());
      resourse2.add(TextEditingController());
      x++;
    
      
    });
  }

  //edit

  _addField() {
    setState(() {
      _topics.add(TextEditingController());
      _descriptions.add(TextEditingController());
      _resources.add(TextEditingController());

   
    });
  }

  _remove(int index) {
    setState(() {
      if (index >= 1) {
        _topics.removeAt(index);
        _descriptions.removeAt(index);
        _resources.removeAt(index);

      }
    });
  }

  // new
  bool showSearchtBarPath = false;

  TextEditingController searchpathController = TextEditingController();

  //

  Stream<List<PathwayContainer>> readPathway() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('Pathway');

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
                                }
                              });
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              SharedPreferences pre =
                                  await SharedPreferences.getInstance();
                              pre.setInt('pathwayId_${pathway.id}', pathway.id);
                              pre.setString('pathwayIdx', pathway.docId ?? '');
                              fetchData(pathway);
                              setState(() {
                                showEditBox = !showEditBox;
                              });
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
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back));
                }),
                const Text(
                  'Pathway Management ',
                  style: TextStyle(
                    fontSize: 18, 
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

          if (!showWhiteBox && !showEditBox)
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
                                      const SizedBox(height: 0),
                                      ////
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
                                            reusableTextField(
                                              "Please enter pathway's resource",
                                              Icons.link_sharp,
                                              false,
                                              _resources[index],
                                              true,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      
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
          ///
          ///
          ///
          ///
          ///
          if (showEditBox)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),

          if (showEditBox)
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
                                showEditBox = false;
                              });

                              clear();
                           
                            },
                            child: Icon(
                              Icons.arrow_back,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 40),
                          Text(
                            'Edit Pathway ',
                            style:
                                TextStyle(fontSize: 24, fontFamily: 'Poppins'),
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
                        'Edit pathways and unlock a world of knowledge!',
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
                        newProfilePicture = pickedImage;
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
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.title,
                                        color: Color.fromARGB(255, 0, 0, 0)),
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
                                  enabled: true,
                                  readOnly: false,
                                  controller: TextEditingController(
                                      text:
                                          newtitle), // Use newUsername variable as the initial value
                                  onChanged: (value) {
                                    newtitle =
                                        value; // Update newUsername when the value changes
                                  },
                                ),
                              ),
                              const SizedBox(width: 5),
                            ],
                          ),
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
                            controller: TextEditingController(
                                text:
                                    newpath_description), // Use newUsername variable as the initial value
                            onChanged: (value) {
                              newpath_description =
                                  value; // Update newUsername when the value changes
                            },
                            maxLines: 4,
                            cursorColor: const Color.fromARGB(255, 43, 3, 101),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.description,
                                  color:
                                      const Color.fromARGB(255, 63, 12, 118)),
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
                            onPressed: _showMultiSelectTopicedit,
                            child: const Text('Select Topics'),
                          ),

                          // Display the selected items
                          Wrap(
                            children: _editSelectTopic // Updated variable name
                                .map((e) => Chip(
                                      label: Text(e),
                                    ))
                                .toList(),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ///////////
                    ///
                    ///
                    Column(
                      children: [
                        SizedBox(
                          width: 300,
                          child: Divider(
                            color: Color.fromARGB(255, 211, 211, 211),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: Text(
                            'Please note that you can add more than one topic',
                            style: TextStyle(color: Colors.red, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: topics2.length,
                            itemBuilder: (BuildContext context, int indexx) {
                              final isRemovable =
                                  indexx > 0; // Check if the field is removable
                              int x = 0;
                              // Check if index is within the range of subtopicControllers length
                              if (indexx < subtopicControllers.length) {
                                return Column(
                                  children: [
                                   
                                    const SizedBox(height: 0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: buildNewfield(indexx),
                                    ),
                                    
                                  ],
                                );
                              } else {
                                // Return a different ListView.builder when index exceeds subtopicControllers length
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: 1, // Only one item in the builder
                                  itemBuilder:
                                      (BuildContext context, int subIndex) {
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(18.0),
                                              child: Text(
                                                'SubTopic - ${indexx + 1}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 56, 9, 150),
                                                ),
                                              ),
                                            ),
                                            Spacer(),
                                            if (indexx >
                                                0) // Conditionally render the remove button for indices greater than 0
                                              IconButton(
                                                icon: Icon(Icons.remove_circle),
                                                onPressed: () {
                                                setState(() {
                                                                // Remove the text field and corresponding data from the lists
                                                                topics2
                                                                    .removeAt(
                                                                        indexx);
                                                                descriptions2
                                                                    .removeAt(
                                                                        indexx);
                                                                        resourse2
                                                                    .removeAt(
                                                                        indexx);
                                                              });
                                                },
                                              ),
                                            InkWell(
                                              child:
                                                  const Icon(Icons.add_circle),
                                              onTap: () {
                                                _addfieldsub();
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
                                                  SizedBox(width: 5),
                                                  Text(
                                                    '*',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                  SizedBox(width: 5),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              TextField(
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(
                                                      Icons.title,
                                                      color: Color.fromARGB(
                                                          255, 0, 0, 0)),
                                                  labelStyle: const TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                  filled: true,
                                                  labelText: "please enter",
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .never,
                                                  fillColor:
                                                      const Color.fromARGB(255,
                                                              228, 228, 228)
                                                          .withOpacity(0.3),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32),
                                                  ),
                                                ),
                                                controller: topics2[indexx],
                                                enabled: true,
                                                readOnly: false,
                                                onChanged: (value) {
                                                  setState(() {
                                                    topics2[indexx].text = value;
                                                  });
                                                },
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    TextField(
                                                      enabled: true,
                                                      controller:
                                                          descriptions2[indexx],
                                                      maxLines: 4,
                                                      cursorColor:
                                                          const Color.fromARGB(
                                                              255, 43, 3, 101),
                                                      decoration:
                                                          InputDecoration(
                                                        prefixIcon: Icon(
                                                          Icons.description,
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 63, 12, 118),
                                                        ),
                                                        labelText:
                                                            "Please enter subtopic's\n\nDescription",
                                                        labelStyle:
                                                            const TextStyle(
                                                          color: Colors.black54,
                                                        ),
                                                        filled: true,
                                                        floatingLabelBehavior:
                                                            FloatingLabelBehavior
                                                                .never,
                                                        fillColor: const Color
                                                                .fromARGB(255,
                                                                228, 228, 228)
                                                            .withOpacity(0.3),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(32),
                                                        ),
                                                      ),
                                                       onChanged: (value) {
                                                  setState(() {
                                                    descriptions2[indexx].text = value;
                                                  });
                                                },
                                                    ),
                                                          const SizedBox(height: 0),
                                      ////
                                      
                                                    Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: Colors.red,
                      ),
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
                TextField(
                  enabled: true,
                  controller: TextEditingController(
                      text: resourse2[indexx].text),
                  
                  cursorColor: const Color.fromARGB(255, 43, 3, 101),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.link_sharp,
                      color: const Color.fromARGB(255, 63, 12, 118),
                    ),
                    labelText: "Please enter subtopic's Resource",
                    labelStyle: const TextStyle(
                      color: Colors.black54,
                    ),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: const Color.fromARGB(255, 228, 228, 228)
                        .withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // Handle any changes in the text field
                      resourse2[indexx].text = value;
                    });
                  },
                ),
           
              ],
            ),
          ),
                                                    
                                            
                                                    
                                                  ],
                                                 
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        SharedPreferences pre =
                            await SharedPreferences.getInstance();
                        final id = pre.getString('pathwayIdx') ?? '';
                        if ( await validateTitle() &&
                            await validatedescription() &&
                            await validateTopics() &&
                            await validatesubtopics(subtopicControllers, topics2) &&
                            await validatesubdescription(subtopicDescriptionControllers, descriptions2) &&
                            await validateResource(subtopicresourseControllers,resourse2)) {
                          updateTitle();
                          updateProfilePicture();
                          _showSnackBar(
                              "Your information has been changed successfully");
                            clear();
                          setState(() {
                            showEditBox = false;
                          });
                          
                        }
                        
                      },
                      child: const Text('Save'),
                    )
                  ],
                ),
              )),
            ),
        ],
      ),
    );
  }



  
//edit db
  Future<bool> validateTopics() async {
    if (newKey_topic == dbKey_topic) {
      return true;
    } else if (newKey_topic.isEmpty) {
      _showSnackBar('Please enter at least one topic');
      return false;
    }
    if (await updateTopics()) {
      return true;
    }
    return false;
  }

  Future<bool> updateTopics() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Pathway')
        .where('pathwayNo', isEqualTo: pathID)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String userId = userDoc.id;

      await FirebaseFirestore.instance
          .collection('Pathway')
          .doc(userId)
          .update({
        'KeyTopic': _editSelectTopic,
      });
    }

    return true;
  }

  Widget buildNewfield(int index) {
    if (index <= lenghtOftopics) {
      return Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  'SubTopic - ${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 56, 9, 150),
                  ),
                ),
              ),
              Spacer(),
              if (index >
                  0) // Conditionally render the remove button for indices greater than 0
                IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                                  // Remove the text field and corresponding data from the lists
                                  // Remove the text field and corresponding data from the lists
                                  subtopicControllers.removeAt(index);
                                  //topics2.removeAt(index);
                                  subtopicDescriptionControllers
                                      .removeAt(index);
                                      subtopicresourseControllers.removeAt(index);
                                });
                  },
                ),
              InkWell(
                child: const Icon(Icons.add_circle),
                onTap: () {
                  _addfieldsub();
                 
                },
              ),
            ],
          ),
          const SizedBox(height: 0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Sub-Topic Title',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '*',
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(width: 5),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.title,
                        color: Color.fromARGB(255, 0, 0, 0)),
                    labelStyle: const TextStyle(
                      color: Colors.black54,
                    ),
                    filled: true,
                    //labelText: "please enter",
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: const Color.fromARGB(255, 228, 228, 228)
                        .withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  controller:
                      TextEditingController(text: subtopicControllers[index]),
                  enabled: true,
                  readOnly: false,
                  onChanged: (value) {
                    setState(() {
                      // Handle any changes in the text field
                      subtopicControllers[index] = value;
                    });
                  },
                ),
                SizedBox(
                  height: 5,
                ),
              Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  enabled: true,
                  controller: TextEditingController(
                      text: subtopicDescriptionControllers[index]),
                  maxLines: 4,
                  cursorColor: const Color.fromARGB(255, 43, 3, 101),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.description,
                      color: const Color.fromARGB(255, 63, 12, 118),
                    ),
                    labelText: "Please enter subtopic's\n\nDescription",
                    labelStyle: const TextStyle(
                      color: Colors.black54,
                    ),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: const Color.fromARGB(255, 228, 228, 228)
                        .withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // Handle any changes in the text field
                      subtopicDescriptionControllers[index] = value;
                    });
                  },
                ),
              ],
            ),
          ),



          //new resourse
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: Colors.red,
                      ),
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
                TextField(
                  enabled: true,
                  controller: TextEditingController(
                      text: subtopicresourseControllers[index]),
                  cursorColor: const Color.fromARGB(255, 43, 3, 101),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.link_sharp,
                      color: const Color.fromARGB(255, 63, 12, 118),
                    ),
                    labelText: "Please enter subtopic's Resource",
                    labelStyle: const TextStyle(
                      color: Colors.black54,
                    ),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: const Color.fromARGB(255, 228, 228, 228)
                        .withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // Handle any changes in the text field
                      subtopicresourseControllers[index] = value;
                    });
                  },
                ),
              ],
            ),
          ),
              ],
            ),
          ),
        ],
      );
    } else {
      return SizedBox(); // Empty container if the text field should be hidden
    }
  }

  

  addvalue(String s, int i) {
    newsubtopics[++i] = s;
  }
Future<bool> updateresoursesssub (List<String> list1, List<TextEditingController> list2) async {

        List<String> mergedList = [];

    for (int i = 0; i < list1.length; i++) {
      String value = list1[i];
      if (value.isNotEmpty) {
        mergedList.add(value);
      }
    }

    for (int i = 0; i < list2.length; i++) {
      String value = list2[i].text;
      if (value.isNotEmpty) {
        mergedList.add(value);
      }
    }
    if (mergedList.isEmpty) {
      _showSnackBar("Enter Resources");
      return false; // Return false if the mergedList is empty
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Pathway')
        .where('pathwayNo', isEqualTo: pathID)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String id = userDoc.id;

      await FirebaseFirestore.instance.collection('Pathway').doc(id).update({
        'resources': mergedList,
      });
    }

    return true;

      }
  Future<bool> updatetitlessub(
      List<String> list1, List<TextEditingController> list2) async {
    List<String> mergedList = [];

    for (int i = 0; i < list1.length; i++) {
      String value = list1[i];
      if (value.isNotEmpty) {
        mergedList.add(value);
      }
    }



    for (int i = 0; i < list2.length; i++) {
      String value = list2[i].text;
      if (value.isNotEmpty) {
        mergedList.add(value);
      }
    }
    if (mergedList.isEmpty) {
      _showSnackBar("Enter at least one subtopic");
      return false; // Return false if the mergedList is empty
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Pathway')
        .where('pathwayNo', isEqualTo: pathID)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String id = userDoc.id;

      await FirebaseFirestore.instance.collection('Pathway').doc(id).update({
        'subtopics': mergedList,
      });
    }

    return true;
  }

  Future<bool> updatedescriptionssub(
      List<String> list1, List<TextEditingController> list2) async {
    List<String> mergedList = [];

    for (int i = 0; i < list1.length; i++) {
      String value = list1[i];
      if (value.isNotEmpty) {
        mergedList.add(value);
      }
    }

    for (int i = 0; i < list2.length; i++) {
      String value = list2[i].text;
      if (value.isNotEmpty) {
        mergedList.add(value);
      }
    }
    if (mergedList.isEmpty) {
      _showSnackBar("Enter a description for subtopics");
      return false; // Return false if the mergedList is empty
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Pathway')
        .where('pathwayNo', isEqualTo: pathID)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String id = userDoc.id;

      await FirebaseFirestore.instance.collection('Pathway').doc(id).update({
        'descriptions': mergedList,
      });
    }

    return true;
  }

  Future<bool> updateProfilePicture() async {
    try {
      // Upload the new profile picture to Firebase Storage
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('pathway_images/$pathID.jpg');
      final UploadTask uploadTask = storageRef.putFile(newProfilePicture!);
      final TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('Pathway')
              .where('pathwayNo', isEqualTo: pathID)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> userDoc =
            snapshot.docs.first;
        final String id = userDoc.id;
        await FirebaseFirestore.instance.collection('Pathway').doc(id).update({
          'imageURL': downloadURL,
        });
      }
      dbimage_url = downloadURL;

      return true;
    } catch (e) {
      //_showSnackBar('An error occurred while trying to change  picture');
      return false;
    }
  }

  Future<bool> validateTitle() async {
    if (newtitle == dbtitle) {
      return true;
    } else if (newtitle != dbtitle) {
      bool titleExists = await isTitleUnique(newtitle);
      if (titleExists == false) {
        _showSnackBar('Title is already taken. Please choose a different one.');
        return false;
      }
      if (newtitle == '') {
        _showSnackBar('Please enter a pathway title.');
        return false;
      } 
      if (newtitle.length > 40) {
       _showSnackBar('Title should not exceed 40 characters');

        return false;
      }
      else {
        // Username is valid and not already taken, perform the save operation

        return true;
      }
    }
    return false;
  }

  Future<bool> updateTitle() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Pathway')
        .where('pathwayNo', isEqualTo: pathID)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String id = userDoc.id;

      await FirebaseFirestore.instance.collection('Pathway').doc(id).update({
        'title': newtitle,
      });
    }

    return true;
  }

  Future<bool> updateDescription() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Pathway')
        .where('pathwayNo', isEqualTo: pathID)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String id = userDoc.id;

      await FirebaseFirestore.instance.collection('Pathway').doc(id).update({
        'pathwayDescription': newpath_description,
      });
    }

    return true;
  }

  Future<bool> validatedescription() async {
    if (newpath_description == dbpath_description) {
      return true;
    } else if (newpath_description != dbpath_description) {
      if (newpath_description.isEmpty) {
        _showSnackBar('Please add pathway description');
        return false;
      } 
       if (newpath_description.length > 250) {
        _showSnackBar('Description should not exceed 250 characters');

        return false;
      }
      else {
        if (await updateDescription()) {
          return true;
        }
      }
    }
    return false;
  }



  Future<bool> updatetopics() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Pathway')
        .where('pathwayNo', isEqualTo: pathID)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String id = userDoc.id;

      await FirebaseFirestore.instance.collection('Pathway').doc(id).update({
        'keyTopic': newKey_topic,
      });
    }

    return true;
  }


Future<bool> validateResource (List<String> list1, List<TextEditingController> list2) async {
   List<String> mergedList = [];
int len = list1.length;

    for (int i = 0; i < list1.length; i++) {
      String value = list1[i];
      if (value.isEmpty) {
        _showSnackBar('Please fill all resource');
        return false;
      }
      if (value.isNotEmpty) {
        mergedList.add(value);
      }
    }
 


    for (int i = len; i < list2.length; i++) {
      String value = list2[i].text;
       if (value.isEmpty) {
        _showSnackBar('Please fill all resource');
        return false;
      }
      if (value.isNotEmpty) {
        mergedList.add(value);
      }
    }

     for (int i = 0; i < mergedList.length; i++) {
      //String value = list2[i].text;
      if (mergedList[i].isEmpty) {
         _showSnackBar('Please fill all resource');
         return false;
      }
    }
 if (await updateresoursesssub(subtopicresourseControllers, resourse2)) {
      return true;
    }
    return false;
}


  Future<bool> validatesubtopics(List<String> list1, List<TextEditingController> list2) async {

     List<String> mergedList = [];
int len = list1.length;
    for (int i = 0; i < list1.length; i++) {
      String value = list1[i];
      if (value.isEmpty) {
        _showSnackBar('Please fill all subtopic title');
        return false;
      }
      if (value.isNotEmpty) {
        mergedList.add(value);
      }
    }

    for (int i = len; i < list2.length; i++) {
      String value = list2[i].text;
       if (value.isEmpty) {
        _showSnackBar('Please fill all subtopic title');
        return false;
      }
      if (value.isNotEmpty) {
        mergedList.add(value);

      }
    }

     for (int i = 0; i < mergedList.length; i++) {
      //String value = list2[i].text;
      if (mergedList[i].isEmpty) {
         _showSnackBar('Please fill all subtopic title');
         return false;
      }
    }
    if (await updatetitlessub(subtopicControllers, topics2)) {
      return true;
    }
    return false;
  }

  Future<bool> validatesubdescription(List<String> list1, List<TextEditingController> list2) async {
int len = list1.length;

       List<String> mergedList = [];

    for (int i = 0; i < list1.length; i++) {
      String value = list1[i];
      if (value.isEmpty) {
        _showSnackBar('Please fill all description');
         return false;
      }
      if (value.isNotEmpty) {
        mergedList.add(value);
      }
    }

    for (int i = len; i < list2.length; i++) {
      String value = list2[i].text;
      if (value.isEmpty) {
        _showSnackBar('Please fill all description');
         return false;
      }
      if (value.isNotEmpty) {
        mergedList.add(value);
      }
    }

     for (int i = 0; i < mergedList.length; i++) {
      //String value = list2[i].text;
      if (mergedList[i].isEmpty) {
         _showSnackBar('Please fill all description');
         return false;
      }
    }
    
    if (await updatedescriptionssub(
        subtopicDescriptionControllers, descriptions2)) {
      return true;
    }
    return false;
  }
//DONE EDIT DATABASE
  // DB

  Future<bool> saveDataToFirestore() async {
    try {
      // Create a new document reference
      DocumentReference documentReference =
          firestore.collection('Pathway').doc();
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

      // Save the flattened resources list to Firestore
      await documentReference.set({
        'title': _pathTitle.text,
        'pathwayDescription': _path_descriptions.text,
        'keyTopic': _SelectTopic,
        'subtopics': _topics.map((controller) => controller.text).toList(),
        'descriptions':
            _descriptions.map((controller) => controller.text).toList(),
        'resources':  _resources.map((controller) => controller.text).toList(),
        'imageURL': imageUrl,
        'pathwayNo': id,
        //'docId': documentReference.id,
      });
      id = id + 1;
      return true; 
    } catch (error) {
      return false; 
    }
  }

  /////// VALIDATION
  Future<bool> isTitleUnique(String title) async {
    QuerySnapshot querySnapshot = await firestore
        .collection('Pathway')
        .where('title', isEqualTo: title)
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
    if (_pathTitle.text.length > 40) {
      _showSnackBar('Title should not exceed 40 characters');
      return false;
    }

    if (_path_descriptions.text.isEmpty) {
      _showSnackBar('Please enter the pathway\'s description');
      return false; // Return early if the title field is empty
    }
 if (_path_descriptions.text.length > 250) {
      _showSnackBar('Description should not exceed 250 characters');
      return false;
    }

    if (_SelectTopic.isEmpty) {
      _showSnackBar('Please enter the pathway\'s KeyWords');
      return false; // Return early if the title field is empty
    }

    // Validate the topics, descriptions, and resources
    for (int i = 0; i < _topics.length; i++) {
      if (_topics[i].text.isEmpty || _descriptions[i].text.isEmpty || _resources[i].text.isEmpty) {
        _showSnackBar('Please fill all fields for topic ${i + 1}');
        return false; // Return early if any topic or description field is empty
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
      _resources.removeRange(1, _resources.length);
    }
  

    // Clear the topics, descriptions, and resources
    for (int i = 0; i < _topics.length; i++) {
      _topics[i].clear();
      _descriptions[i].clear();
      _resources[i].clear();
     
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
              .collection('Pathway')
              .where('title', isEqualTo: Ptitle)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> pathwayDoc =
            snapshot.docs.first;
        final String pathId = pathwayDoc.id;

        // Delete pathway document from Firestore
        await FirebaseFirestore.instance
            .collection('Pathway')
            .doc(pathId)
            .delete();

        return true;
      }
    }

    return false;
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
              content:  SingleChildScrollView(
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
                              style: TextStyle(
                                  color: Color.fromARGB(255, 169, 0, 157)),
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
                            children:
                                pathway.subtopics.asMap().entries.map((entry) {
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
                                                !(expandedStates[subtopic] ??
                                                    false);
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Icon(expandedStates[subtopic] ??
                                                    false
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
                                      padding:
                                          EdgeInsets.only(left: 22.0, top: 4.0),
                                      child: Text(
                                        pathway.descriptions[index],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: const Color.fromARGB(
                                              255, 81, 81, 81),
                                        ),
                                      ),
                                    ),

                                  //resources
                                 

                               if (expandedStates[subtopic] ?? false)
                              Padding(
                                padding: EdgeInsets.only(left: 22.0, top: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    launch(
                                        pathway.resources[index]); // Replace with the actual URL
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
                    Navigator.pop(context); 
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

 