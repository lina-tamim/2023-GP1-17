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

const Color mainColor = Color.fromRGBO(37, 6, 81, 0.898);
const Color secondaryColor = Color(0xffffffff);
const Color redColor = Color(0xffbd2727);

class AdminCoursesAndEventsPage extends StatefulWidget {
  const AdminCoursesAndEventsPage({Key? key}) : super(key: key);

  @override
  State<AdminCoursesAndEventsPage> createState() =>
      _AdminCoursesAndEventsPageState();
}

class _AdminCoursesAndEventsPageState extends State<AdminCoursesAndEventsPage> {
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
  List<String> courseType = ["Course", "Event"];
  String selectedCourseType = "Course";
  List<String> AttendanceType = ["Onsite", "Online"];
  String selectedAttendanceType = "Onsite";
  bool showSearchBar = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        backgroundColor: const Color.fromRGBO(37, 6, 81, 0.898),
        toolbarHeight: showSearchBar ? 120 : 100,
        automaticallyImplyLeading: false,
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
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back)),
                const Text(
                  'Courses and Events',
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
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                  ),
                  isDense: true,
                ),
                onChanged: (text) {
                  setState(() {});
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
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 25,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Courses",
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Poppins",
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
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
                      width: 500,
                      height: 350,
                      child: ListView.builder(
                          itemCount: list.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              child: CoursesWidget(
                                item: list[index],
                                onEdit: () {
                                  setData(list[index]);
                                  showInputDialog();
                                },
                                onDelete: () {
                                  deleteEvent(list[index], 'Course');
                                },
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
                          fontSize: 20,
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
                      width: 500,
                      height: 350,
                      child: ListView.builder(
                          itemCount: list.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              child: CoursesWidget(
                                item: list[index],
                                onEdit: () {
                                  setData(list[index]);
                                  showInputDialog();
                                },
                                onDelete: () {
                                  deleteEvent(list[index], 'Event');
                                },
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
              SizedBox(
                height: 60,
              )
            ],
          ),
        ),
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
    selectedCourseType = item.type ?? '';
    selectedAttendanceType = item.attendanceType ?? '';
    courseStartDate = item.startDate;
    courseEndDate = item.endDate;
    this.item = item;
  }

  deleteEvent(Course item, type) {
    if (item.docId == null || item.docId == '') {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to delete this $type')));
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete this $type?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('Program')
                      .doc(item.docId)
                      .delete();
                  Navigator.of(context).pop(); 
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _submitForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';
    final formCollection = FirebaseFirestore.instance.collection('Program');

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('coursesAndEvents_images')
        .child('${DateTime.now().toIso8601String()}png');

    String? imageURL = item?.imageURL;

    if (_selectedImage == null && (imageURL == null || imageURL == '')) {
      // Load the default image from assets
      final byteData = await rootBundle.load(defaultImagePath);
      final bytes = byteData.buffer.asUint8List();

      // Save the default image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(tempDir.path, 'default_image.png');
      await File(tempPath).writeAsBytes(bytes);

      // Upload the default image to storage
      await storageRef.putFile(File(tempPath));
      imageURL = await storageRef.getDownloadURL();
    } else if (_selectedImage != null) {
      // Upload the selected image to storage
      await storageRef.putFile(_selectedImage!);
      imageURL = await storageRef.getDownloadURL();
    }
    // Create a new document with auto-generated ID
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
        'approval': 'Yes',
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
        'approval': 'Yes',
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')));

    clearAllFields();

    Navigator.pop(context);
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

    if (searchController.text.isNotEmpty) {
      query = query
          .where('title',
              isGreaterThanOrEqualTo: searchController.text.toLowerCase())
          .where('title',
              isLessThanOrEqualTo:
                  searchController.text.toLowerCase() + '\uf8ff');
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
                    title: "Link",
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
      ],
    );
  }
}

class CoursesWidget extends StatelessWidget {
  final Course item;

  const CoursesWidget({
    Key? key,
    required this.item,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  final onDelete;
  final onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(95, 92, 92, 92).withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 2),
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
                      height: 200,
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
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  item.title ?? '--',
                  style: const TextStyle(
                    fontSize: 17,
                    fontFamily: "Poppins",
                    color: mainColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  width: double.infinity,
                  child: Text(
                    'Description: ${item.description}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: "Poppins",
                      color: mainColor,
                    ),
                    softWrap: true,
                    maxLines: null,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Visibility(
                visible: item.attendanceType == 'Onsite',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
              ),
              Visibility(
                visible: item.attendanceType == 'Online',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                        padding: const EdgeInsets.only(right: 20, left: 20),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item.link != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextButton(
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
                            color: Color.fromARGB(255, 150, 202, 245),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(
                    width: 100,
                  ),
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(
                      Icons.edit,
                      color: mainColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.delete,
                      color: redColor,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
