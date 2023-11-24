import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techxcel11/pages/reuse.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/course.dart';
//EDIT +CALNDER COMMIT

const Color mainColor = Color.fromRGBO(37, 6, 81, 0.898);
const Color secondaryColor = Color(0xffffffff);
const Color redColor = Color(0xffbd2727);

class AdminCoursesAndEventsRequestsPage extends StatefulWidget {
  const AdminCoursesAndEventsRequestsPage({super.key});

  @override
  State<AdminCoursesAndEventsRequestsPage> createState() =>
      _AdminCoursesAndEventsRequestsPageState();
}

class _AdminCoursesAndEventsRequestsPageState
    extends State<AdminCoursesAndEventsRequestsPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final locationController = TextEditingController();
  final linkController = TextEditingController();
  final searchController = TextEditingController();
  DateTime? courseStartDate;
  DateTime? courseEndDate;
  Course? item;
  String defaultImagePath = 'assets/Backgrounds/defaultCoursePic.png';

  List<String> incidentDistrict = ["Course", "Event"];
  String selectedIncidentDistrict = "Course";
  bool showSearchBar = false;

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
                  'Courses and Events Requests',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Welcome to the uploaded requests section by Techxcel users!\nHere, you have the power "
                        "to review and make decisions on these requests.\nYou can either accept them, "
                        "allowing them to be published to the public,or reject them if they don't meet the criteria.\n",
                        style: TextStyle(
                          fontSize: 15,
                          color: mainColor,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      "Your actions will directly impact the visibility of these requests and shape the content available to our users.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.red,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Text(
                      "Courses Requests",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Poppins",
                        color: Colors.black,
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
                          child: Text('No Requests'),
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
                      "Events Requests",
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
                          child: Text('No Requests'),
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
    );
  }

  Stream<List<Course>> readCourses({String type = 'Course'}) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Program')
        .where('type', isEqualTo: type)
        .where('approval', isEqualTo: 'Pending');

    if (searchController.text.isNotEmpty) {
      query = query
          .where('title',
              isGreaterThanOrEqualTo: searchController.text.toLowerCase())
          .where('title',
              isLessThanOrEqualTo:
                  searchController.text.toLowerCase() + '\uf8ff');
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
}

class CoursesWidget extends StatelessWidget {
  final Course item;

  CoursesWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.only(right: 12, left: 12),
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
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                //used when uploadd image failed to download due to unexcpected network issues
                // ignore: unnecessary_null_comparison
                child: item.imageURL != null
                    ? Image.network(
                        item.imageURL,
                        width: 250,
                        height: 105,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/Backgrounds/defaultCoursePic.png',
                        width: 250,
                        height: 105,
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            Text(
              'Title: ${item.title}',
              style: const TextStyle(
                  fontSize: 17, fontFamily: "Poppins", color: mainColor),
            ),
            Container(
              width: MediaQuery.of(context).size.width, // Adjust the width as needed
              child: Text(
                'Description: ${item.description}',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: "Poppins",
                  color: mainColor,
                ),
                softWrap: true,
                maxLines: null, // Allow multiple lines
              ),
            ),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.startDate != null)
                              Text(
                                'Start date:  ${DateFormat('MMM dd, yy').format(item.startDate!)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: "Poppins",
                                  color: mainColor,
                                ),
                              ),
                            if (item.endDate != null)
                              Text(
                                'End date:     ${DateFormat('MMM dd, yy').format(item.endDate!)}',
                                style: const TextStyle(
                                  fontSize: 15,
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
                  if (item.link != null)
                    TextButton(
                      onPressed: () async {
                        if (await canLaunchUrl(Uri.parse(item.link!))) {
                          await launchUrl(Uri.parse(item.link!));
                        } else {
                          toastMessage('Unable to show details');
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7, // Adjust the width as needed
                        child: Text(
                          'Link for more details: ${item.link}',
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Poppins",
                            decoration: TextDecoration.underline,
                            color: mainColor,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: null, // Allow multiple lines
                        ),
                      ),
                    )
                  else
                    const SizedBox(),
                ],
              ),
            Row(
              children: [
                SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () {
                    updateApprovalStatus(
                        'Yes'); // Update the approval status to 'Yes'
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 22, 146, 0),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Accept',
                      style:
                          TextStyle(color: Color.fromARGB(255, 254, 254, 254))),
                ),
                SizedBox(width: 120),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String reason =
                            ''; // Variable to store the rejection reason

                        return AlertDialog(
                          title: const Text('Enter Rejection Reason'),
                          content: TextField(
                            onChanged: (value) {
                              reason =
                                  value; // Update the rejection reason as the user types
                            },
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                updateApprovalStatus(
                                    'No,$reason'); // Update the approval status to 'No'
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(Colors
                                        .red), // Set the background color to red
                              ),
                              child: const Text('Reject'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 122, 1, 1),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Reject',
                    style: TextStyle(color: Color.fromARGB(255, 254, 254, 254)),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 3,
            ), //just to add space
          ],
        ),
      ),
    ),
    );
  }

  Future<void> updateApprovalStatus(String newStatus) async {
    final formCollection = FirebaseFirestore.instance.collection('Program');
    if (newStatus.contains('Yes')) {
      await formCollection.doc(item.docId).update({
        'approval': 'Yes',
      });
      toastMessage('Request has been sent to the public!');
    } else {
      await formCollection.doc(item.docId).update({
        'approval': newStatus,
      });
      toastMessage('Request has been Rejected');
    }
  }
}
