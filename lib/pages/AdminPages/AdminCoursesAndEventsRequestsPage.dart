import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/Models/CourseModel.dart';

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

  List<String> courseType = ["Course", "Event"];
  String selectedCourseType = "Course";
  bool showSearchBar = false;

  final Algolia algolia = Algolia.init(
  applicationId: 'PTLT3VDSB8',
  apiKey: '6236d82b883664fa54ad458c616d39ca',
);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor:  Color.fromARGB(255, 242, 241, 243),
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Color.fromRGBO(37, 6, 81, 0.898),
        ),
        toolbarHeight: 100,
        title: Builder(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 0),
                  const Text(
                    'Courses & Events\nRequests',
                    style: TextStyle(
                      fontSize: 17.5,
                      fontFamily: "Poppins",
                      color: Color.fromRGBO(37, 6, 81, 0.898),
                    ),
                  ),
                  const SizedBox(width: 75),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        showSearchBar = !showSearchBar;
                      });
                    },
                    icon: Icon(showSearchBar ? Icons.search_off : Icons.search),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
                  if (showSearchBar)
                    Container(
                      height: 40.0, // Adjust the height as needed
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Color.fromARGB(255, 242, 241, 243),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10.0),
                          isDense: false,
                        ),
                        style: TextStyle(color: Colors.black, fontSize: 14.0),
                        onChanged: (text) {
                          setState(() {
                         
                          });
                        },
                      ),
                    ),
            ],
          ),
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
                        "Welcome to the uploaded requests section by TeXel users!\nHere, you have the power "
                        "to review and make decisions on these requests.\nYou can either accept them, "
                        "allowing them to be published to the public,or reject them if they don't meet the criteria.\n",
                        style: TextStyle(
                          fontSize: 12,
                          color: mainColor,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      "Your actions will directly impact the visibility of these requests and shape the content available to our users.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
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
List<String> searchRequestsIds =[];
Future<Stream<List<Course>>> readRequestSearch() async {
  if (searchController.text.isNotEmpty) {

    final AlgoliaQuerySnapshot response = await algolia
        .instance
        .index('Program_index')
        .query(searchController.text)
        .facetFilter('approval:Pending')
        .getObjects();

searchRequestsIds.clear();
    final List<AlgoliaObjectSnapshot> hits = response.hits;
    final List<String> projectIds =
        hits.map((snapshot) => snapshot.objectID).toList();

searchRequestsIds.addAll(projectIds); // Add the IDs to the list
    final snapshot = await FirebaseFirestore.instance
        .collection('Program')
        .where(FieldPath.documentId, whereIn: projectIds)
        .get();

    final projects = snapshot.docs.map((doc) {
      final projectData = doc.data() as Map<String, dynamic>;
      final project =  Course.fromJson(projectData);
      project.docId = doc.id; // Set the docId to the actual document ID
      return project;
    }).toList();

    return Stream.value(projects);
  } else {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('Program');

    query = query.orderBy('postedDate', descending: true);

    return query.snapshots().map((snapshot) {
      final projects = snapshot.docs.map((doc) {
        final projectData = doc.data() as Map<String, dynamic>;
        final project = Course.fromJson(projectData);
        project.docId = doc.id; // Set the docId to the actual document ID
        return project;
      }).toList();

      return projects;
    });
  }
}

  Stream<List<Course>> readCourses({String type = 'Course'}) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Program')
        .where('type', isEqualTo: type)
        .where('approval', isEqualTo: 'Pending')
           .orderBy('createdAt', descending: true);


    
List<Course> courses =[];
    return query.snapshots().asyncMap((snapshot) async {
       courses = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['docId'] = doc.id;
        return Course.fromJson(data);
      }).toList();
if (searchController.text.isNotEmpty) {
       courses = courses
          .where((question) => searchRequestsIds.contains(question.docId))
          .toList();
    } 
      return courses;
    });
  }
}

class CoursesWidget extends StatelessWidget {
  final Course item;

  CoursesWidget({
    Key? key,
    required this.item,
  }) : super(key: key);

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
        child: ListView(
          children: [
            Stack(
              children: [
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '${item.title}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: MediaQuery.of(context).size.width,
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
            const SizedBox(height: 5),
            Visibility(
              visible: item.attendanceType == 'Onsite',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.startDate != null)
                                Text(
                                  '   Start date:  ${DateFormat('MMM dd, yy').format(item.startDate!)}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: "Poppins",
                                    color: mainColor,
                                  ),
                                ),
                              if (item.endDate != null)
                                Text(
                                  '   End date:     ${DateFormat('MMM dd, yy').format(item.endDate!)}',
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
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (item.link != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextButton(
                      onPressed: () async {
                        if (await canLaunchUrl(Uri.parse(item.link!))) {
                          await launchUrl(Uri.parse(item.link!));
                        } else {
                          toastMessage('Unable to show details');
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          'Link for more details: ${item.link}',
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Poppins",
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                          maxLines: null,
                        ),
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
                    updateApprovalStatus('Yes');
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
                        String reason = '';

                        return AlertDialog(
                          title: const Text('Enter Rejection Reason'),
                          content: TextField(
                            onChanged: (value) {
                              reason = value;
                            },
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                updateApprovalStatus('No,$reason');
                                Navigator.of(context).pop();
                              },
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
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
            ),
          ],
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
