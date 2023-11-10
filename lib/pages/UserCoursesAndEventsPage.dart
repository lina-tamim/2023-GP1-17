import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/courseAndEvent_image.dart';
import 'package:techxcel11/pages/reuse.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/course.dart';

class UserCoursesAndEventsPage extends StatefulWidget {
  const UserCoursesAndEventsPage({super.key});

  @override
  State<UserCoursesAndEventsPage> createState() => _UserCoursesAndEventsPageState();

}
const Color mainColor = Color.fromRGBO(37, 6, 81, 0.898);
const Color secondaryColor = Color(0xffffffff);
const Color redColor = Color(0xffbd2727);

int _currentIndex = 0;
class _UserCoursesAndEventsPageState extends State<UserCoursesAndEventsPage> {
 final titleController = TextEditingController();
  final descController = TextEditingController();
  final locationController = TextEditingController();
  final linkController = TextEditingController();
  final searchController = TextEditingController();
  DateTime? courseStartDate;
  DateTime? courseEndDate;
  Course? item;
  File? _selectedImage;
  String defaultImagePath = 'assets/Backgrounds/defaultCoursePic.png';
  int _currentIndex = 0;
  List<String> incidentDistrict = ["Course", "Event"];
  String selectedIncidentDistrict = "Course";
  List<String> AttendanceType = ["Onsite", "Online"];
  String selectedAttendanceType = "Onsite";
  bool showSearchBar = false;
  bool _loading = false;
  
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBarUser(),
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        backgroundColor: const Color.fromRGBO(37, 6, 81, 0.898),
        toolbarHeight: showSearchBar ? 120 : 100,
        automaticallyImplyLeading: true,
        elevation: 0,
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(80),
            bottomRight: Radius.circular(80),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Courses and Events',
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
                        showSearchBar = !showSearchBar;
                      });
                    },
                    icon: Icon(showSearchBar ? Icons.search_off : Icons.search))
              ],
            ),
            if (showSearchBar)
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search for the title of course/event',
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

floatingActionButton: FloatingActionButton(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  onPressed: () {
    clearAllFields();
    showInputDialog();
  },
  child: const Tooltip(
    message: '  Add a course or event now!   ',
    child: Icon(
      Icons.add,
      color: Colors.white,
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
   const SizedBox(width: 122),
PopupMenuButton<String>(
  onSelected: (value) {
    if (value == 'my_requests') {
      showRequestList();
    } else if (value == 'submit_request') {
      showInputDialog();
    }
  },
  offset: const Offset(-0.5, 43), // Adjust the vertical offset as needed
  itemBuilder: (BuildContext context) => [
    const PopupMenuItem<String>(
      value: 'my_requests',
      child: SizedBox(
        width: 100,
        child: Text(
          'My Requests',
          style: TextStyle(
            fontSize: 13,
            color: Color.fromARGB(255, 0, 0, 2),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
    const PopupMenuDivider(),
    const PopupMenuItem<String>(
      value: 'submit_request',
      child: SizedBox(
        width: 130,
        child: Text(
          'Add Course or Event',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  ],
  child: const SizedBox(
    width: 169, 
    child: OutlinedButton(
      onPressed: null,
       child: Align(
        alignment: Alignment.center,
      child: Row(
        children: [
          Text(
            'My Requests',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: Color.fromARGB(255, 7, 0, 101),
              fontWeight: FontWeight.w100,
            ),
          ),
          SizedBox(width: 10),
          Icon(Icons.arrow_drop_down),
        ],
      ),
       ),
    ),
  ),
),
    ],
  ),
),
              StreamBuilder<List<Course>>(
                stream: readCourses(type: 'Course'),
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
                      height: 410,
                      child: ListView.builder(
                          itemCount: list.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
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
                stream: readCourses(type: 'Event'),
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
                      height: 410,
                      child: ListView.builder(
                          itemCount: list.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
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

  Future<bool> isValidUrl(String url) async {
    return await canLaunchUrl(Uri.parse(url));
  }

bool isDateValid(DateTime? start, DateTime? end) {
  if (start == null || end == null) {
    return false;
  }
  return end.isAfter(DateTime.now());
}

  setData(Course item) {
    titleController.text = item.title ?? '';
    descController.text = item.description ?? '';
    locationController.text = item.location ?? '';
    linkController.text = item.link ?? '';
    selectedIncidentDistrict = item.type ?? '';
    selectedAttendanceType = item.attendanceType ?? '';
    courseStartDate = item.startDate;
    courseEndDate = item.endDate;
    this.item = item;
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
        'userId': email,
        'type': selectedIncidentDistrict,
        'attendanceType': selectedAttendanceType,
        'title': titleController.text,
        'description': descController.text,
        'start_date': courseStartDate,
        'end_date': courseEndDate,
        'link': linkController.text,
        'location': locationController.text,
        'imageURL': imageURL,
        'approval': 'Pending',
      });
    } else {
      await newFormDoc.set({
        'userId': email,
        'type': selectedIncidentDistrict,
        'attendanceType': selectedAttendanceType,
        'title': titleController.text,
        'description': descController.text,
        'start_date': courseStartDate,
        'end_date': courseEndDate,
        'link': linkController.text,
        'location': locationController.text,
        'created_at': postDate,
        'imageURL': imageURL,
        'approval': 'Pending',
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
    selectedIncidentDistrict = 'Course';
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

  if (searchController.text.isNotEmpty) {
    query = query
        .where('title', isGreaterThanOrEqualTo: searchController.text.toLowerCase())
        .where('title',
            isLessThanOrEqualTo: searchController.text.toLowerCase() + '\uf8ff');
  } else {
    query = query.orderBy('created_at', descending: true);
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
                        color: mainColor,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "Add Course or Event",
                      style: TextStyle(
                          fontSize: 17,
                          fontFamily: "Poppins",
                          color: mainColor,
                          fontWeight: FontWeight.w400),
                    ),
                    const Spacer(),
                  ],
                ),
                const Divider(),
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
                      child: DropDownWidget(
                        selectedItem: selectedIncidentDistrict,
                        list: incidentDistrict,
                        onItemSelected: (value) {
                          setstate(() {
                            selectedIncidentDistrict = value!;
                            print("incidentDistrict$selectedIncidentDistrict");
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const FormTitleWidget(
                  title: "Title",
                ),
                const SizedBox(height: 8),
                reusableTextField(selectedIncidentDistrict == 'Course' ? "Please enter the course's title" : "Please enter the event's title", Icons.title,
                    false, titleController, true,
                    maxLines: 1),
                const SizedBox(height: 14),
                const FormTitleWidget(
                  title: "Description",
                ),
                const SizedBox(height: 8),
                reusableTextField(selectedIncidentDistrict == 'Course' ? "Please enter the course's description" : "Please enter the event's description",
                    Icons.description, false, descController, true,
                    maxLines: 1),
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
                  ],
                ),
                const SizedBox(height: 14),
  const SizedBox(height: 14),
                Visibility(
                  visible: selectedAttendanceType == 'Onsite',
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: FormTitleWidget(
                      title: "Location",
                      isRequired: true,
                    ),
                  ),
                ),
                Visibility(
                  visible: selectedAttendanceType == 'Onsite',
                  child: reusableTextField(
                    selectedIncidentDistrict == 'Course'
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
                    title: "Link",
                  ),
                ),
                reusableTextField(selectedIncidentDistrict == 'Course' ? "Please enter the course's link" : "Please enter the event's link" , Icons.link, false,
                    linkController, true,
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
                            } else if (descController.text.isEmpty ) {
                              toastMessage("Please enter a description");
                            }else if (isDateValid(courseStartDate , courseEndDate) == false) {
                              toastMessage("Please enter a valid date");
                            }else if (selectedIncidentDistrict == '') {
                              toastMessage("Please select a type");
                            } else if (locationController.text.isEmpty && selectedAttendanceType =='Onsite') {
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
                                fontFamily: "Poppins",
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

  QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
      .collection('Program')
      .where('userId', isEqualTo: email)
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

void showRequestList() {
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCourseEventTitles(),
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
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
                              title:  Text(
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
                                    if (course['approval'].substring(0, 2) == 'No')
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
                  : const Text("You have'not added any requests yet!"),
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
    if (commaIndex != -1 && commaIndex < approvalStatus.length - 1) {
    }
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
    // print("dateType$dateType");
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
        if (tooltip != null) ...[
        ]
      ],
    );
  }
}

class CoursesWidget extends StatelessWidget {
  final Course item;

  const CoursesWidget({
    super.key,
    required this.item,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.only(top: 10,right: 13 , left: 13),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: ([
            BoxShadow(
                color: mainColor.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 3))
          ]),
          
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          Center( child:
Stack(
  children: [
        Center(
child:
    Container(
      width: 325,
      height: 200,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(170, 0, 24, 163).withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
    ),
        ),
        Center(
   child:  ClipRRect(
      borderRadius: BorderRadius.circular(8),
      //used when uploadd image failed to download due to unexcpected network issues
      // ignore: unnecessary_null_comparison
      child: item.imageURL != null
          ? Image.network(
              item.imageURL,
              width: 325,
              height: 200,
              fit: BoxFit.cover,
            )
          : Image.asset(
              'assets/Backgrounds/defaultCoursePic.png',
              width: 325,
              height: 200,
              fit: BoxFit.cover,
            ),
    ),
    ),
  ],
),
          ),
            SizedBox(height:10) ,
           Text(
              item.title ?? '--',
              style: const TextStyle(
                  fontSize: 17,
                  fontFamily: "Poppins",
                  color: mainColor,
                  fontWeight: FontWeight.w400),
            ),
            Text(
              item.description ?? '--',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 15,
                  fontFamily: "Poppins",
                  color: mainColor.withOpacity(0.6),
                  fontWeight: FontWeight.w400),
            ),
           const SizedBox(height: 5),
            Visibility(
              visible: item.attendanceType == 'Onsite',
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
                      item.location ?? '--',
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
            Visibility(
              visible: item.attendanceType == 'Online',
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
            Row(
              children: [
                if (item.startDate != null || item.endDate != null)
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time ,
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
                                DateFormat('MMM dd, yy').format(item.endDate!),
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
              ],
            ),       
                Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        IconButton(
              onPressed: () {
                // Add to calendar functionality!!
              },
              icon: Icon(
                Icons.calendar_today_sharp,
                size: 28, // Adjust the size as needed
                color: Colors.blue,
              ),
              tooltip: 'Save to Calendar',
            ),
            if (item.link != null)
              TextButton(
                onPressed: () async {
                  if (await canLaunchUrl(Uri.parse(item.link!))) {
                    await launchUrl(Uri.parse(item.link!));
                  } else {
                    toastMessage('Unable to show details');
                  }
                },
                child: const Text(
                  'More Details ->',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: "Poppins",
                    color: mainColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
          ],
        ),
      ),
    );
  }
}




