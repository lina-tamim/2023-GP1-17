import 'dart:convert';

import 'package:algolia/algolia.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:techxcel11/Models/CourseEventImage.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/Models/CourseModel.dart';
import "package:csc_picker/csc_picker.dart";

class UserCoursesAndEventsPage extends StatefulWidget {
  const UserCoursesAndEventsPage({super.key, required this.searchQuery});

  final String searchQuery;

  @override
  State<UserCoursesAndEventsPage> createState() =>
      _UserCoursesAndEventsPageState();
}

const Color mainColor = Color.fromRGBO(37, 6, 81, 0.898);
const Color secondaryColor = Color(0xffffffff);

class _UserCoursesAndEventsPageState extends State<UserCoursesAndEventsPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final locationController = TextEditingController();
  final linkController = TextEditingController();
  DateTime? courseStartDate;
  DateTime? courseEndDate;
  Course? item;
  File? _selectedImage;
  String defaultImagePath = 'assets/Backgrounds/defaultCoursePic.png';
  int _currentIndex = 0;
  List<String> courseType = ["Course", "Event"];
  String selectedCourseType = "Course";
  List<String> AttendanceType = ["Onsite", "Online"];
  String selectedAttendanceType = "Onsite";
  bool showSearchBar = false;
  bool _loading = false;
  String selectedCountry = '';
  String selectedCity = '';
  String selectedState = '';
  static String loggedinEmaill = '';
  static List<String> recommendedCEIds = [];
  static List<Map<String, dynamic>> alltheCE = [];
  static List<Map<String, dynamic>> allUsers = [];

  final Algolia algolia = Algolia.init(
    applicationId: 'PTLT3VDSB8',
    apiKey: '6236d82b883664fa54ad458c616d39ca',
  );
  bool coursesLoading = true;
  List<String> recommendedObjects = [];

  static Future<List<String>> fetchUserDetails() async {
    List<Map<String, dynamic>> UsersJson = [];
    List<Map<String, dynamic>> CEJson = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedinEmaill = prefs.getString('loggedInEmail') ?? '';
/////////////

    final QuerySnapshot<Map<String, dynamic>> snapshotUsers =
        await FirebaseFirestore.instance.collection('RegularUser').get();

    if (snapshotUsers.docs.isNotEmpty) {
      // setState(() {
      allUsers = snapshotUsers.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Convert each question to JSON object

      allUsers.forEach((User) {
        Map<String, dynamic> jsonUsers = {
          'attendancePreference': User['attendancePreference'],
          'email': User['email'], // Accessing document ID directly from doc
          'interests': User['interests'],
          'skills': User['skills'],
          'country': User['country'],
          'state': User['state'],
          'city': User['city'],
        };
        UsersJson.add(jsonUsers);
      });
      // });
    }

//////////
    DateTime current_date = DateTime.now();
    final QuerySnapshot<Map<String, dynamic>> snapshotCE =
        await FirebaseFirestore.instance
            .collection('Program')
            .where('approval', isEqualTo: 'Yes')
            .where('endDate', isGreaterThanOrEqualTo: current_date)
            .get();

    if (snapshotCE.docs.isNotEmpty) {
      // setState(() {
      alltheCE = snapshotCE.docs.map((doc) {
        // Access the document ID using 'doc.id'
        Map<String, dynamic> CE = doc.data() as Map<String, dynamic>;
        CE['CE_Id'] = doc.id; // Assign document ID to 'CE_Id'
        return CE;
      }).toList();

      // Convert each question to JSON object
      alltheCE.forEach((CE) {
        CEJson.add({
          'attendanceType': CE['attendanceType'],
          'CE_Id': CE['CE_Id'], // Use 'CE_Id' assigned above
          'clickedBy': CE['clickedBy'],
          'country': CE['country'],
          'state': CE['state'],
          'city': CE['city'],
        });
      });

      // Send the JSON object to the server
      return await recommendCE(CEJson, UsersJson);
      // });
    }
    return [];
  }

  bool isMenuOpen = false;

  static Future<List<String>> recommendCE(List<Map<String, dynamic>> CEJson,
      List<Map<String, dynamic>> UsersJson) async {
    // Send user preferences and all questions to the server

    final Map<String, dynamic> requestBody = {
      'user_Email': loggedinEmaill,
      'all_users': UsersJson,
      'all_CE': CEJson,
    };
    final response = await http.post(
      Uri.parse(
          'https://flask-deploy-gp2-717dffd55916.herokuapp.com/recommendCE'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      final List<dynamic> responseBody = json.decode(response.body);
      final List<String> ids = responseBody.cast<String>().toList();
      recommendedCEIds = ids;
      log('888888');
      log('$recommendedCEIds');
      return recommendedCEIds;
    } else {
      return [];
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        recommendedObjects = await fetchUserDetails();
      } catch (e) {}
      setState(() {
        coursesLoading = false;
        recommendedObjects = recommendedObjects;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBarUser(),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          clearAllFields();
          showInputDialog();
        },
        backgroundColor: Color.fromARGB(255, 49, 0, 84),
        child: const Tooltip(
          decoration: BoxDecoration(
            color: Color.fromARGB(177, 40, 0, 75),
          ),
          message: '  Add a course or event now!   ',
          child: Icon(
            Icons.add,
            color: Color.fromARGB(255, 255, 255, 255),
            size: 25,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Courses",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: "Poppins",
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    PopupMenuTheme(
                      data: PopupMenuThemeData(
                        elevation: 10,
                        // Change the elevation of the drop-down menu
                        color: Color.fromARGB(255, 255, 255, 255),
                        // Change the background color
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10)), // Change the shape of the menu
                      ),
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'my_requests') {
                                checkRequests();
                              } else if (value == 'submit_request') {
                                showInputDialog();
                              }
                            },
                            onOpened: () {
                              setState(() {
                                isMenuOpen = true;
                              });
                            },
                            onCanceled: () {
                              setState(() {
                                isMenuOpen = false;
                              });
                            },
                            offset: Offset(-6, 22),
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'my_requests',
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'My Requests',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(255, 0, 0, 2),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(height: 10),
                              const PopupMenuItem<String>(
                                value: 'submit_request',
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add Request',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(255, 0, 0, 2),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            child: SizedBox(
                              width: 125,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'My Requests  ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                      color: Color.fromARGB(255, 7, 0, 101),
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                                  Icon(isMenuOpen
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down),
                                  // Change the icon based on the menu's state
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          
              if (widget.searchQuery.isNotEmpty)
                StreamBuilder<List<Course>>(
                  stream: readCourseSearch(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final list = snapshot.data!;
                      return Column(
                        children: [
                          CoursesAndEventsBuilder(
                            list: list
                                .where((element) => element.type == 'Course')
                                .toList(),
                            type:
                                'Searched Courses ${list.where((element) => element.type == 'Course').length}',
                          ),
                          EventsHeading(),
                          CoursesAndEventsBuilder(
                            list: list
                                .where((element) => element.type == 'Event')
                                .toList(),
                            type: 'Searched Events',
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error:${snapshot.error}'),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                )
              else ...[
                StreamBuilder<List<Course>>(
                  stream: readCoursesNew(type: 'Course'),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final list = snapshot.data!;

                      if (list.isEmpty) {
                        return const SizedBox(
                          height: 200,
                          child: Center(
                            child: Text('No Courses'),
                          ),
                        );
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        height: 480,
                        child: ListView.builder(
                            itemCount: list.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                child: CoursesWidget(
                                  item: list[index],
                                ),
                              );
                            }),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error:${snapshot.error}'),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Events",
                        style: TextStyle(
                            fontSize: 22,
                            fontFamily: "Poppins",
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<List<Course>>(
                  stream: readCoursesNew(type: 'Event'),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final list = snapshot.data!;

                      if (list.isEmpty) {
                        return const SizedBox(
                          height: 200,
                          child: Center(
                            child: Text('No Events'),
                          ),
                        );
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        height: 480,
                        child: ListView.builder(
                            itemCount: list.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                child: CoursesWidget(
                                  item: list[index],
                                ),
                              );
                            }),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error:${snapshot.error}'),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                )
              ],
            ],
          ),
        ),
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

  Future<void> saveToCalendar(Course courseAndEvent) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('loggedInEmail') ?? '';
      final calendarCollection =
          FirebaseFirestore.instance.collection('Calendar');
      final existingDocsQuery = calendarCollection
          .where('my_id', isEqualTo: email)
          .where('docId', isEqualTo: courseAndEvent.docId)
          .limit(1);

      final existingDocsSnapshot = await existingDocsQuery.get();

      if (existingDocsSnapshot.docs.isNotEmpty) {
        toastMessage("Already exists in Calendar");
        return;
      }
      final courseAndeventMap = courseAndEvent.toJson2(email);
      await calendarCollection.add(courseAndeventMap);
      toastMessage("Saved to Calender");
    } catch (e) {
      toastMessage("Failed to save to Calendar: $e");
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

  Future<bool> isValidUrl(String url) async {
    return await canLaunchUrl(Uri.parse(url));
  }

  bool isDateValid(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return false;
    }
    if (start.isAfter(end)) {
      return false;
    }
    return end.isAfter(DateTime.now());
  }

  setData(Course item) {
    titleController.text = item.title ?? '';
    descController.text = item.description ?? '';
    locationController.text = item.location ?? '';
    linkController.text = item.link ?? '';
    selectedCourseType = item.type ?? '';
    selectedAttendanceType = item.attendanceType ?? '';
    courseStartDate = item.startDate;
    courseEndDate = item.endDate;
    this.item = item;
    selectedCountry = item.country ?? '';
    selectedCity = item.city ?? '';
    selectedState = item.state ?? '';
  }

  Future<void> _submitForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';
    final formCollection = FirebaseFirestore.instance.collection('Program');
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('coursesAndEvents_images')
        .child('${item?.docId}png');

    if (_selectedImage == null) {
      // Load the default image from assets
      final byteData = await rootBundle.load(defaultImagePath);
      final bytes = byteData.buffer.asUint8List();

      // Save the default image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(tempDir.path, 'default_image.png');
      await File(tempPath).writeAsBytes(bytes);

      // Upload the default image to storage
      await storageRef.putFile(File(tempPath));
    } else {
      // Upload the selected image to storage
      await storageRef.putFile(_selectedImage!);
    }
    final imageURL = await storageRef.getDownloadURL();

    final newFormDoc = formCollection.doc();
    DateTime postDate = DateTime.now();

    if (item?.docId != null) {
      await formCollection.doc(item!.docId).update({
        'userEmail': email,
        'type': selectedCourseType,
        'attendanceType': selectedAttendanceType,
        'title': titleController.text,
        'description': descController.text,
        'startDate': courseStartDate,
        'endDate': courseEndDate,
        'link': linkController.text,
        'location': locationController.text,
        'imageURL': imageURL,
        'approval': 'Pending',
        'clickedBy': [],
        'city': selectedCity,
        'country': selectedCountry,
        'state': selectedState,
      });
    } else {
      await newFormDoc.set({
        'userEmail': email,
        'type': selectedCourseType,
        'attendanceType': selectedAttendanceType,
        'title': titleController.text,
        'description': descController.text,
        'startDate': courseStartDate,
        'endDate': courseEndDate,
        'link': linkController.text,
        'location': locationController.text,
        'createdAt': postDate,
        'imageURL': imageURL,
        'approval': 'Pending',
        'clickedBy': [],
        'city': selectedCity,
        'country': selectedCountry,
        'state': selectedState,
      });
    }
    clearAllFields();
    Navigator.pop(context);
    showCourseOrEventSubmissionDialog(context);
  }

  void showCourseOrEventSubmissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Request Submitted',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text('Your request is pending approval. Stay tuned!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  clearAllFields() {
    titleController.clear();
    descController.clear();
    courseStartDate = null;
    courseEndDate = null;
    selectedCourseType = 'Course';
    selectedAttendanceType = 'Onsite';
    locationController.clear();
    linkController.clear();
    item = null;
    _selectedImage = null;
  }

  Stream<List<Course>> readCourses({String type = 'Course'}) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Program')
        .where('type', isEqualTo: type)
        .where('approval', isEqualTo: 'Yes');

    if (widget.searchQuery.isNotEmpty) {
      query = query
          .where('title',
              isGreaterThanOrEqualTo: widget.searchQuery.toLowerCase())
          .where('title',
              isLessThanOrEqualTo: widget.searchQuery.toLowerCase() + '\uf8ff');
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    return query.snapshots().asyncMap((snapshot) async {
      final courses = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['docId'] = doc.id;
        return Course.fromJson(data);
      }).toList();

      return courses;
    });
  }

  Stream<List<Course>> readCoursesNew({String type = 'Course'}) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Program')
        .where('type', isEqualTo: type)
        .where('approval', isEqualTo: 'Yes');

    if (widget.searchQuery.isNotEmpty) {
      query = query
          .where('title',
              isGreaterThanOrEqualTo: widget.searchQuery.toLowerCase())
          .where('title',
              isLessThanOrEqualTo: widget.searchQuery.toLowerCase() + '\uf8ff');
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    return query.snapshots().map((snapshot) {
      final courses = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['docId'] = doc.id;
        return Course.fromJson(data);
      }).toList();

      List<Course> recommendedCourses = [];
      List<Course> otherCourses = [];
      List<Course> activeCourrses = [];
      for (Course course in courses) {
        if (recommendedObjects.contains(course.docId)) {
          course.isRecommended = true;
          recommendedCourses.add(course);
        } else {
          if (course.endDate != null) {
            if (course.endDate!.isBefore(DateTime.now())) {
              otherCourses.add(course);
            } else {
              activeCourrses.add(course);
            }
          }
        }
      }
      if (recommendedCourses.length > 11)
        recommendedCourses = recommendedCourses.sublist(0, 4);
      List<Course> sortedCourses = [
        ...recommendedCourses,
        ...activeCourrses,
        ...otherCourses
      ];
      return sortedCourses;
    });
  }

  Stream<List<Course>> readCourseSearch() async* {
    if (widget.searchQuery.isNotEmpty) {
      final AlgoliaQuerySnapshot response = await algolia.instance
          .index('Program_index')
          .query(widget.searchQuery)
          .getObjects();
      print(response);
      final List<AlgoliaObjectSnapshot> hits = response.hits;
      final projects = hits.map((AlgoliaObjectSnapshot snapshot) {
        final projectData = snapshot.data as Map<String, dynamic>;
        final project = Course.fromJson(projectData);
        project.docId = snapshot.objectID;
        return project;
      }).toList();
      yield* Stream.value(projects);
    } else {
      yield* Stream.value([]);
    }
  }

  void showInputDialog() {
    showAlertDialog(
      context,
      StatefulBuilder(builder: (context, setstate) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_outlined,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "Add Course or Event",
                      style: TextStyle(
                          fontSize: 17,
                          fontFamily: "Poppins",
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    const Spacer(),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const FormTitleWidget(
                        title: "",
                        isRequired: false,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: CourseAndEventImagePicker(
                          onPickImage: (pickedImage) {
                            _selectedImage = pickedImage;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FormTitleWidget(
                      title: "Type",
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 228, 228, 228)
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color.fromARGB(255, 228, 228, 228)
                                  .withOpacity(0.5),
                            )),
                        child: DropDownWidget(
                          selectedItem: selectedCourseType,
                          list: courseType,
                          onItemSelected: (value) {
                            setstate(() {
                              selectedCourseType = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const FormTitleWidget(
                  title: "Title",
                ),
                const SizedBox(height: 8),
                reusableTextField(
                    selectedCourseType == 'Course'
                        ? "Please enter the course's title"
                        : "Please enter the event's title",
                    Icons.title,
                    false,
                    titleController,
                    true,
                    maxLines: 1),
                const SizedBox(height: 14),
                const FormTitleWidget(
                  title: "Description",
                ),
                const SizedBox(height: 8),
                reusableTextField(
                    selectedCourseType == 'Course'
                        ? "Please enter the course's description"
                        : "Please enter the event's description",
                    Icons.description,
                    false,
                    descController,
                    true,
                    maxLines: 5),
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            FormTitleWidget(
                              title: "Start Date",
                              isRequired: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            FormTitleWidget(
                              title: "End Date",
                              isRequired: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await selectDate(context, "start");
                            setstate(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 13),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color.fromARGB(255, 228, 228, 228)
                                  .withOpacity(0.3),
                            ),
                            child: Text(
                              courseStartDate == null
                                  ? "Select start date"
                                  : DateFormat('MMM dd, yyyy')
                                      .format(courseStartDate!),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: mainColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await selectDate(context, "end");
                            setstate(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 13),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color.fromARGB(255, 228, 228, 228)
                                  .withOpacity(0.3),
                            ),
                            child: Text(
                              courseEndDate == null
                                  ? "Select end Date"
                                  : DateFormat('MMM dd, yyyy')
                                      .format(courseEndDate!),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: mainColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FormTitleWidget(
                      title: "Onsite or Online?",
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 228, 228, 228)
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color.fromARGB(255, 228, 228, 228)
                                  .withOpacity(0.5),
                            )),
                        child: DropDownWidget(
                          selectedItem: selectedAttendanceType,
                          list: AttendanceType,
                          onItemSelected: (value) {
                            setstate(() {
                              selectedAttendanceType = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const SizedBox(height: 14),
                Visibility(
                  visible: selectedAttendanceType == 'Onsite',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'Select Your Country',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '*',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'State and City',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '*',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CSCPicker(
                          onCountryChanged: (value) {
                            setState(() {
                              selectedCountry = value.toString();
                            });
                          },
                          onStateChanged: (value) {
                            setState(() {
                              selectedState = value.toString();
                            });
                          },
                          onCityChanged: (value) {
                            setState(() {
                              selectedCity = value.toString();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: selectedAttendanceType == 'Onsite',
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            FormTitleWidget(
                              title: "Location",
                              isRequired: true,
                            ),
                            Tooltip(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(177, 40, 0, 75),
                              ),
                              message:
                                  'To accept your request,Add location of the course or event as country and city',
                              child: Icon(
                                Icons.live_help_rounded,
                                size: 18,
                                color: Color.fromARGB(255, 178, 178, 178),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: selectedAttendanceType == 'Onsite',
                  child: reusableTextField(
                    selectedCourseType == 'Course'
                        ? "Please write the place of the course"
                        : "Please write the place of the event",
                    Icons.location_on_rounded,
                    false,
                    locationController,
                    true,
                    maxLines: 1,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: FormTitleWidget(
                    title: "Platform Link",
                  ),
                ),
                reusableTextField(
                    selectedCourseType == 'Course'
                        ? "Please enter the course's link"
                        : "Please enter the event's link",
                    Icons.link,
                    false,
                    linkController,
                    true,
                    maxLines: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_loading)
                        IgnorePointer(
                          child: Opacity(
                            opacity: 1,
                            child: Container(
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () async {
                            bool validLink =
                                await isValidUrl(linkController.text);
                            if (titleController.text.isEmpty) {
                              toastMessage("Please enter a title");
                            } else if (titleController.text.length > 40) {
                              toastMessage("Please enter a shorter title");
                            } else if (descController.text.isEmpty) {
                              toastMessage("Please enter a description");
                            } else if (descController.text.length > 255) {
                              toastMessage(
                                  "Please enter a shorter description");
                            } else if (isDateValid(
                                    courseStartDate, courseEndDate) ==
                                false) {
                              toastMessage("Please enter a valid date");
                            } else if (selectedCourseType == '') {
                              toastMessage("Please select a type");
                            } else if (selectedCountry.isEmpty &&
                                selectedAttendanceType == 'Onsite') {
                              toastMessage("Please enter  a Country");
                            } else if (selectedCity.isEmpty &&
                                selectedAttendanceType == 'Onsite') {
                              toastMessage("Please enter  a City");
                            } else if (locationController.text.isEmpty &&
                                selectedAttendanceType == 'Onsite') {
                              toastMessage("Please enter  a location");
                            } else if (linkController.text.isEmpty) {
                              toastMessage("Please enter a link");
                            } else if (!validLink) {
                              toastMessage("Please enter a valid link");
                            } else {
                              setstate(() {
                                _loading = true;
                              });
                              await _submitForm();
                              setstate(() {
                                _loading = false;
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: mainColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(32)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 40),
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                //fontFamily: "Poppins",
                                color: secondaryColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<List<Map<String, dynamic>>> fetchCourseEventTitles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Program')
        .where('userEmail', isEqualTo: email)
        .get();

    // Extract titles, approval values, and reason from the query snapshot
    List<Map<String, dynamic>> courses = snapshot.docs.map((doc) {
      String approval = doc.data()['approval'] as String;
      String reason = '';
      if (approval.contains(',')) {
        List<String> approvalSplit = approval.split(',');
        approval = approvalSplit[0].trim();
        reason = approvalSplit[1].trim();
      }
      return {
        'title': doc.data()['title'] as String,
        'approval': approval,
        'reason': reason,
      };
    }).toList();

    return courses;
  }

  void checkRequests() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchCourseEventTitles(),
          builder: (BuildContext context,
              AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('My submitted requests'),
                content: Text('Error: ${snapshot.error}'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            } else {
              return AlertDialog(
                title: const Text('My submitted requests'),
                content: snapshot.data != null && snapshot.data!.isNotEmpty
                    ? Container(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            final course = snapshot.data![index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  course['title'],
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Color.fromARGB(171, 0, 0, 0),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildApprovalMessage(course['approval']),
                                    if (course['approval'].substring(0, 2) ==
                                        'No')
                                      Text(
                                        'Rejection reason: ${course['reason']}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Color.fromARGB(171, 66, 0, 0),
                                        ),
                                      ),
                                  ],
                                ),
                                leading: _buildApprovalDot(course['approval']),
                              ),
                            );
                          },
                        ),
                      )
                    : const Text("You have not added any requests yet!"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Widget _buildApprovalMessage(String approvalStatus) {
    String message;

    if (approvalStatus == 'Yes') {
      message = 'Approved';
    } else if (approvalStatus == 'Pending') {
      message = 'Pending';
    } else {
      message = 'Rejected';
      int commaIndex = approvalStatus.indexOf(',');
      if (commaIndex != -1 && commaIndex < approvalStatus.length - 1) {}
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalDot(String approvalStatus) {
    Color dotColor;
    IconData icon;

    if (approvalStatus == 'Yes') {
      dotColor = const Color.fromARGB(255, 0, 148, 5);
      icon = Icons.check_circle;
    } else if (approvalStatus == 'No') {
      dotColor = Color.fromARGB(255, 213, 14, 0);
      icon = Icons.cancel;
    } else if (approvalStatus == 'Pending') {
      dotColor = Color.fromARGB(255, 229, 218, 0);
      icon = Icons.access_time;
    } else {
      dotColor = Colors.grey;
      icon = Icons.help;
    }

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dotColor,
      ),
      child: Icon(
        icon,
        size: 25,
        color: Colors.white,
      ),
    );
  }

  Future<void> selectDate(BuildContext context, String dateType,
      {type = "normal", initialDate = null}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2090),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: mainColor,
            hintColor: mainColor,
            colorScheme: const ColorScheme.light(primary: mainColor),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      dateType == "start" ? courseStartDate = pickedDate : null;
      dateType == "end" ? courseEndDate = pickedDate : null;
    }
  }
}

class EventsHeading extends StatelessWidget {
  const EventsHeading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Events",
            style: TextStyle(
                fontSize: 22,
                fontFamily: "Poppins",
                color: Colors.black,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

class CoursesAndEventsBuilder extends StatelessWidget {
  const CoursesAndEventsBuilder({
    super.key,
    required this.list,
    required this.type,
  });

  final List<Course> list;
  final String type;

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text('No $type'),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      height: 480,
      child: ListView.builder(
          itemCount: list.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: CoursesWidget(
                item: list[index],
              ),
            );
          }),
    );
  }
}

class FormTitleWidget extends StatelessWidget {
  const FormTitleWidget({
    super.key,
    required this.title,
    this.tooltip,
    this.isRequired = true,
  });

  final String title;
  final String? tooltip;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$title',
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        if (isRequired)
          const Text(
            '*',
            style: TextStyle(color: Colors.red),
          ),
        if (tooltip != null) ...[]
      ],
    );
  }
}

class CoursesWidget extends StatelessWidget {
  final Course item;

  const CoursesWidget({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isExpired =
        item.endDate != null && item.endDate!.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 5),
      child: Opacity(
        opacity: isExpired ? 0.3 : 1.0, // Reduce opacity if item is expired
        child: Container(
          padding: const EdgeInsets.only(top: 0, bottom: 0),
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: item.isRecommended
                ? Border.all(
                    color: Color.fromARGB(255, 10, 0, 195).withOpacity(0.5),
                  )
                : Border.all(
                    color: Color.fromARGB(255, 95, 1, 162).withOpacity(0.5),
                  ),
            boxShadow: [
              item.isRecommended
                  ? BoxShadow(
                      color: Color.fromARGB(255, 25, 65, 243).withOpacity(0.7),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(2, 2), // Set shadow offset
                    )
                  : BoxShadow(
                      color: Color.fromARGB(95, 92, 92, 92).withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 2), // Set shadow offset
                    ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 200,
                        ),
                      ),
                      Container(
                        height: 260,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(item.imageURL),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    item.title ?? '--',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      '${item.description}',
                      style: const TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 81, 81, 81)),
                      softWrap: true,
                      maxLines: null,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Visibility(
                  visible: item.attendanceType == 'Onsite',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            '${item.country ?? ''}, ${item.city ?? ''}',
                            // Concatenate country and city with comma
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Poppins",
                              color: mainColor.withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Visibility(
                  visible: item.attendanceType == 'Onsite',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: mainColor.withOpacity(0.6),
                          size: 25,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            item.location,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Poppins",
                              color: mainColor.withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: item.attendanceType == 'Online',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.computer,
                          color: mainColor.withOpacity(0.6),
                          size: 25,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            'Online',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Poppins",
                              color: mainColor.withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (item.startDate != null || item.endDate != null)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20, left: 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: mainColor.withOpacity(0.5),
                                size: 25,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.startDate != null)
                                    Text(
                                      DateFormat('MMM dd, yy')
                                          .format(item.startDate!),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontFamily: "Poppins",
                                        color: mainColor,
                                      ),
                                    ),
                                  if (item.endDate != null)
                                    Text(
                                      DateFormat('MMM dd, yy')
                                          .format(item.endDate!),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontFamily: "Poppins",
                                        color: mainColor,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        _UserCoursesAndEventsPageState().saveToCalendar(item);
                      },
                      icon: Icon(
                        Icons.edit_calendar,
                        size: 28,
                        color: Color.fromARGB(255, 63, 63, 63),
                      ),
                      tooltip: 'Save to Calendar',
                    ),
                    if (item.link != null)
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextButton(
                            onPressed: () async {
                              if (await canLaunch(item.link!)) {
                                await launch(item.link!);
                                await addUserEmailToClickedBy(); // Call function to add email to Firestore
                              } else {
                                toastMessage('Unable to show details');
                              }
                            },
                            child: Text(
                              'More Details ->',
                              style: TextStyle(
                                color: Color.fromARGB(255, 63, 63, 63),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )),
                  ],
                ),
                if (item.isRecommended)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/sparkle.png',
                          width: 17,
                          height: 17,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Is this content relevant to you?",
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            recordFeedback(item, true); // Pass item directly
                          },
                          child: Image.asset(
                            'assets/icons/thumbUp.png',
                            width: 15,
                            height: 15,
                            color: Color.fromARGB(255, 116, 116, 116),
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            recordFeedback(item, false); // Pass item directly
                          },
                          child: Image.asset(
                            'assets/icons/thumbDown.png',
                            width: 15,
                            height: 15,
                            color: Color.fromARGB(255, 116, 116, 116),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addUserEmailToClickedBy() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';
    try {
      await FirebaseFirestore.instance
          .collection('Program')
          .doc(item.docId)
          .update({
        'clickedBy': FieldValue.arrayUnion([email])
      });
      print('User email added to clickedBy array.');
    } catch (e) {
      print('Error adding user email to clickedBy array: $e');
    }
  }

  Future<void> recordFeedback(Course item, bool isThumbUp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';
    try {
      String relevant = isThumbUp ? 'Yes' : 'No';
      String itemType =
          item.type == 'Event' ? 'Event' : 'Course'; // Check item type

      await FirebaseFirestore.instance.collection('RecommenderMeasure').add({
        'recommendedItemId': item.docId,
        'relevant': relevant,
        'userId': email,
        'type': itemType,
      });
      toastMessage('Feedback Send');
    } catch (error) {
      print('Error adding question to bookmarks: $error');
    }
  }
}
