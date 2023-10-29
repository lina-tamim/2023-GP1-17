import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/pages/reuse.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/course.dart';

const Color mainColor = Color.fromRGBO(37, 6, 81, 0.898);
const Color secondaryColor = Color(0xffffffff);
const Color redColor = Color(0xffbd2727);

class CoursesEventsPage extends StatefulWidget {
  const CoursesEventsPage({Key? key}) : super(key: key);

  @override
  State<CoursesEventsPage> createState() => _CoursesEventsPageState();
}

class _CoursesEventsPageState extends State<CoursesEventsPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final locationController = TextEditingController();
  final linkController = TextEditingController();
  final searchController = TextEditingController();
  DateTime? courseStartDate;
  DateTime? courseEndDate;
  Course? item;
  List<String> incidentDistrict = ["Course", "Event"];
  String selectedIncidentDistrict = "Course";
  bool showSearchBar = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // courseStartDate = "Select Start date";
    // courseEndDate = "Select End date";
  }

  @override
  Widget build(BuildContext context) {
    // log('MK valid url: ${isValidUrl('f')}');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        backgroundColor: const Color.fromRGBO(37, 6, 81, 0.898),
        toolbarHeight: showSearchBar ? 120 : 100,
        automaticallyImplyLeading: false,
        // Adjust the height of the AppBar
        elevation: 0,
        // Adjust the position of the AppBar
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
                          color: mainColor,
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
                      height: 270,
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
                          color: mainColor,
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
                      height: 270,
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
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> isValidUrl(String url) async {
    return await canLaunchUrl(Uri.parse(url));
    // final RegExp urlRegex = RegExp(
    //     r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?");
    // return urlRegex.hasMatch(url);
  }

  setData(Course item) {
    // log('MK docId: ${item.docId}');
    titleController.text = item.title ?? '';
    descController.text = item.description ?? '';
    locationController.text = item.location ?? '';
    linkController.text = item.link ?? '';
    selectedIncidentDistrict = item.type ?? '';
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
                  // Delete the document here
                  await FirebaseFirestore.instance
                      .collection('courses')
                      .doc(item.docId)
                      .delete();
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _submitForm() async {
    // log('MK: ${courseStartDate}');
    // return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';
    // Create a Firestore document reference
    final formCollection = FirebaseFirestore.instance.collection('courses');

    // Create a new document with auto-generated ID
    final newFormDoc = formCollection.doc();
    DateTime postDate = DateTime.now();

    if (item?.docId != null) {
      await formCollection.doc(item!.docId).update({
        'userId': email,
        'type': selectedIncidentDistrict,
        'title': titleController.text,
        'description': descController.text,
        'start_date': courseStartDate,
        'end_date': courseEndDate,
        'link': linkController.text,
        'location': locationController.text,
        // 'created_at': postDate,
      });
    } else {
      await newFormDoc.set({
        'userId': email,
        'type': selectedIncidentDistrict,
        'title': titleController.text,
        'description': descController.text,
        'start_date': courseStartDate,
        'end_date': courseEndDate,
        'link': linkController.text,
        'location': locationController.text,
        'created_at': postDate,
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
    selectedIncidentDistrict = 'Course';
    locationController.clear();
    linkController.clear();
    item = null;
  }

  Stream<List<Course>> readCourses({String type = 'Course'}) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('courses')
        .where('type', isEqualTo: type);

    if (searchController.text.isNotEmpty) {
      query = query
          .where('title', isGreaterThanOrEqualTo: searchController.text)
          .where('title',
              isLessThanOrEqualTo: searchController.text + '\uf8ff');
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
                    const SizedBox(
                      width: 12,
                    ),
                    const Text(
                      "Add Course or Event",
                      style: TextStyle(
                          fontSize: 17,
                          fontFamily: "Poppins",
                          color: mainColor,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Divider(
                    color: mainColor.withOpacity(0.5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const FormTitleWidget(
                        title: "Type",
                        tooltip: 'Please choose type from course or event',
                      ),
                      const SizedBox(height: 8),
                      DropDownWidget(
                          selectedItem: selectedIncidentDistrict,
                          list: incidentDistrict,
                          onItemSelected: (value) {
                            setState(() {
                              selectedIncidentDistrict = value!;
                              print(
                                  "incidentDistrict$selectedIncidentDistrict");
                            });
                          }),
                    ],
                  ),
                ),
                const FormTitleWidget(
                  title: "Title",
                  tooltip: 'Please write here title of course or event',
                ),
                const SizedBox(height: 8),
                reusableTextField("Please enter your title", Icons.person,
                    false, titleController, true,
                    maxLines: 1),
                const SizedBox(height: 14),
                const FormTitleWidget(
                  title: "Description",
                  tooltip: 'Please write here description of course or event',
                ),
                const SizedBox(height: 8),
                reusableTextField("Please enter your description",
                    Icons.description_rounded, false, descController, true,
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
                              isRequired: false,
                              tooltip:
                                  'Please select here start date of course or event',
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
                              isRequired: false,
                              tooltip:
                                  'Please select here end date of course or event',
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
                            // if (appDataProvider.courseStartDate != null)
                            //   courseStartDate =
                            //       appDataProvider.formatDate(
                            //           appDataProvider.courseStartDate
                            //               .toString());
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
                            // if (appDataProvider.courseEndDate != null)
                            //   courseEndDate = appDataProvider.formatDate(
                            //       appDataProvider.courseEndDate
                            //           .toString());
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: FormTitleWidget(
                    title: "Location",
                    tooltip: 'Please write here location of course or event',
                  ),
                ),
                reusableTextField("Please write location",
                    Icons.location_on_rounded, false, locationController, true,
                    maxLines: 1),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: FormTitleWidget(
                    title: "Link",
                    tooltip: 'Please enter link here for course or event',
                  ),
                ),
                reusableTextField("Please enter link", Icons.link, false,
                    linkController, true,
                    maxLines: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //   },
                      //   child: Text(
                      //     "Cancel",
                      //     style: const TextStyle(
                      //       fontSize: 17, // Adjust the font size
                      //       fontFamily: "Poppins",
                      //       color: mainColor,
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(width: 16),
                      GestureDetector(
                        onTap: () async {
                          bool validLink =
                              await isValidUrl(linkController.text);
                          // if (!validLink) {
                          //   validLink = await isValidUrl(
                          //       'https://' + linkController.text);
                          //   if(validLink)
                          //   linkController.text = 'https://' + linkController.text;
                          // }
                          if (titleController.text.isEmpty) {
                            toastMessage("Please enter title");
                          } else if (descController.text.isEmpty) {
                            toastMessage("Please enter description");
                          } else if (selectedIncidentDistrict == '') {
                            toastMessage("Please select type");
                          } else if (locationController.text.isEmpty) {
                            toastMessage("Please enter location");
                          } else if (linkController.text.isEmpty) {
                            toastMessage("Please enter link");
                          } else if (!validLink) {
                            toastMessage("Please enter valid link");
                          } else {
                            ////

                            await _submitForm();
                          }
                          // else if (courseStartDate == "Please select date" &&
                          //     appDataProvider.courseStartDate == null) {
                          //   toastMessage("Please select date");
                          // }
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
      // notifyListeners();
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
          // SizedBox(
          //   width: 5,
          // ),
          // Tooltip(
          //   child: Icon(
          //     Icons.live_help_rounded,
          //     size: 18,
          //     color: Color.fromARGB(255, 178, 178, 178),
          //   ),
          //   message: tooltip,
          //   padding: EdgeInsets.all(20),
          //   showDuration: Duration(seconds: 3),
          //   textStyle: TextStyle(color: Colors.white),
          //   preferBelow: false,
          // )
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
    this.onDelete,
    this.onEdit,
  });

  final onDelete;
  final onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        // height: 150,
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(12),
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
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: mainColor.withOpacity(0.6),
                        size: 18,
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
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.startDate != null || item.endDate != null)
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: mainColor.withOpacity(0.5),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.startDate != null)
                              Text(
                                'From',
                                style: TextStyle(
                                    fontSize: 15,
                                    // fontFamily: "Poppins",
                                    color: mainColor.withOpacity(0.5),
                                    fontWeight: FontWeight.bold),
                              ),
                            if (item.endDate != null)
                              Text(
                                'To',
                                style: TextStyle(
                                    fontSize: 15,
                                    // fontFamily: "Poppins",
                                    color: mainColor.withOpacity(0.5),
                                    fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.startDate != null)
                              Text(
                                DateFormat('MMM dd, yy')
                                    .format(item.startDate!),
                                style: const TextStyle(
                                    fontSize: 15,
                                    // fontFamily: "Poppins",
                                    color: mainColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            if (item.endDate != null)
                              Text(
                                DateFormat('MMM dd, yy').format(item.endDate!),
                                style: const TextStyle(
                                    fontSize: 15,
                                    // fontFamily: "Poppins",
                                    color: mainColor,
                                    fontWeight: FontWeight.bold),
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
                          // fontFamily: "Poppins",
                          color: mainColor,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  const SizedBox(),
                SizedBox(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onEdit,
                        child: const Icon(
                          Icons.edit,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      GestureDetector(
                        onTap: onDelete,
                        child: const Icon(
                          Icons.delete,
                          color: redColor,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PublicTitle extends StatelessWidget {
  final String title;

  const PublicTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18, // Adjust the font size
            fontFamily: "Poppins",
            color: mainColor,
          ),
        ),
        const Text(
          "*",
          style: TextStyle(
            fontSize: 16, // Adjust the font size
            fontFamily: "Poppins",
            color: redColor,
          ),
        ),
      ],
    );
  }
}
