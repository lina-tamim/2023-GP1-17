import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/pages/UserPages/UserProfileView.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportedAccountsPage extends StatefulWidget {
  const ReportedAccountsPage({super.key});

  @override
  State<ReportedAccountsPage> createState() => _ReportedAccountsPageState();
}

int _currentIndex = 0;

class _ReportedAccountsPageState extends State<ReportedAccountsPage> {
  final searchController = TextEditingController();
  bool showSearchBar = false;

@override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 2, 
    child: Scaffold(
      appBar: AppBar(
              backgroundColor:  Color.fromARGB(255, 242, 241, 243),

        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Color.fromRGBO(37, 6, 81, 0.898),
        ),
        toolbarHeight: 100,
        /*flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Backgrounds/bg11.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),*/
        title: Builder(
          builder: (context) {
            return Column(
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
                      'Reported Accounts',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Poppins",
                        color: Color.fromRGBO(37, 6, 81, 0.898),
                      ),
                    ),
                    const SizedBox(width: 100),
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
            );
          },
        ),
        bottom: TabBar(
              tabs: [
                Tab(
                  child: Text(
                    'Active Reports',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Old Reports',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            )
      ),
      body: TabBarView(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Center(
              child: StreamBuilder<List<Widget>>(
                stream: readReportedAccounts(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final reportedAccounts = snapshot.data!;
                    return ListView(
                      children: reportedAccounts,
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Center(
              child: StreamBuilder<List<Widget>>(
                stream: readOldReportedAccounts(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final oldReportedAccounts = snapshot.data!;
                    return ListView(
                      children: oldReportedAccounts,
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

//
Stream<List<Widget>> readReportedAccounts() {
  return FirebaseFirestore.instance
      .collection('Report')
      .where('reportType', isEqualTo: 'Account')
      .where('status', isEqualTo: 'Pending')
      .orderBy('reportDate', descending: false)
      .snapshots()
      .asyncMap((snapshot) async {
    final reportedAccounts = <Widget>[];
    final reportedItemsMap = <String, List<String>>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final reportedItemId = data['reportedItemId'];
      final reason = data['reason'];

      if (reportedItemsMap.containsKey(reportedItemId)) {
        reportedItemsMap[reportedItemId]!.add(reason);
      } else {
        reportedItemsMap[reportedItemId] = [reason];
      }
    }

    for (final reportedItemId in reportedItemsMap.keys) {
      final reasons = reportedItemsMap[reportedItemId]!;
      final userSnapshot = await FirebaseFirestore.instance
          .collection('RegularUser')
          .doc(reportedItemId)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        final username = userData!['username'];
        final email = userData!['email'];
        final imageURL = userData!['imageURL'];
        final profileImage = NetworkImage(imageURL);
        final reportIds = snapshot.docs
            .where((doc) => doc['reportedItemId'] == reportedItemId)
            .map((doc) => doc.id)
            .toList();
        final count = await getAccountReportCount(reportedItemId);

        final reasonsWidgets = reasons.map((reason) {
          return Row(
            children: [
              Text(
                reason,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
            ],
          );
        }).toList();

        final card = Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProfileView(userId: email),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundImage: profileImage,
                        radius: 35,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserProfileView(userId: email),
                                ),
                              );
                            },
                            child: Text(
                              '@$username',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserProfileView(userId: email),
                                ),
                              );
                            },
                            child: Text(
                              '$email',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                             Text(
                            'Reasons: ',
                            style: TextStyle(
                              color: Color.fromARGB(255, 92, 0, 0),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: reasonsWidgets,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Tooltip(
                      child: Container(
                        padding: EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(217, 122, 1, 1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      message: 'Total number of reports on this account',
                      padding: EdgeInsets.all(10),
                      showDuration: Duration(seconds: 3),
                      textStyle: TextStyle(color: Colors.white),
                      preferBelow: false,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        acceptReportedAccount(
                            reportIds, username, reasons, email);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 22, 146, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Accept',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        rejectReportedAccount(reportIds);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 201, 0, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Reject',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

        reportedAccounts.add(card);
      }
    }

    if (reportedAccounts.isEmpty) {
      reportedAccounts.add(
         Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                  SizedBox(height: 280,),
            Center(
              child: Text(
                "No Reports Found",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      );
    }

    return reportedAccounts;
  });
}


//

//
String status = 'Accepted';
String status2 = '';
Stream<List<Widget>> readOldReportedAccounts() {

 return FirebaseFirestore.instance
      .collection('Report')
      .where('reportType', isEqualTo: 'Account')
      .where('status', whereIn: ['Accepted', 'Rejected'])
      .orderBy('reportDate', descending: true)
      .snapshots()
      .asyncMap((snapshot) async {
    final reportedAccounts = <Widget>[];
    final reportedItemsMap = <String, List<String>>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final reportedItemId = data['reportedItemId'];
      final reason = data['reason'];

      if (reportedItemsMap.containsKey(reportedItemId)) {
        reportedItemsMap[reportedItemId]!.add(reason);
      } else {
        reportedItemsMap[reportedItemId] = [reason];
      }
    }

    for (final reportedItemId in reportedItemsMap.keys) {
      final reasons = reportedItemsMap[reportedItemId]!;
      final userSnapshot = await FirebaseFirestore.instance
          .collection('RegularUser')
          .doc(reportedItemId)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        final username = userData!['username'];
        final email = userData!['email'];
        final imageURL = userData!['imageURL'];
        final profileImage = NetworkImage(imageURL);
        final reportIds = snapshot.docs
            .where((doc) => doc['reportedItemId'] == reportedItemId)
            .map((doc) => doc.id)
            .toList();
        final count = await getAccountReportCount(reportedItemId);


final statusSnapshot = await FirebaseFirestore.instance
        .collection('Report')
        .where('reportedItemId', isEqualTo: reportedItemId)
        .get();

    String status10 = 'lolo';
    if (statusSnapshot.docs.isNotEmpty) {
      status10 = statusSnapshot.docs.first['status'];
    }

        final reasonsWidgets = reasons.map((reason) {
          return Row(
            children: [
              Text(
                reason,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
            ],
          );
        }).toList();

        final card = Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProfileView(userId: email),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundImage: profileImage,
                        radius: 35,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserProfileView(userId: email),
                                ),
                              );
                            },
                            child: Text(
                              '@$username',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserProfileView(userId: email),
                                ),
                              );
                            },
                            child: Text(
                              '$email',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                             Text(
                            'Reasons: ',
                            style: TextStyle(
                              color: Color.fromARGB(255, 92, 0, 0),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: reasonsWidgets,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Tooltip(
                      child: Container(
                        padding: EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(217, 122, 1, 1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      message: 'Total number of reports on this account',
                      padding: EdgeInsets.all(10),
                      showDuration: Duration(seconds: 3),
                      textStyle: TextStyle(color: Colors.white),
                      preferBelow: false,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Center(
                  child:  Text(
                        '$status10',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
  ],
            ),
          ),
        );

        reportedAccounts.add(card);
      }
    }

    if (reportedAccounts.isEmpty) {
      reportedAccounts.add(
         Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                  SizedBox(height: 280,),
            Center(
              child: Text(
                "No Reports Found",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      );
    }

    return reportedAccounts;
  });
}


Future<int> getAccountReportCount(String reportedItemID) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Report')
        .where('status', isEqualTo: 'Pending')
        .where('reportedItemId', isEqualTo: reportedItemID)
        .get();

    return querySnapshot.docs.length;
  } catch (error) {
    print('Error getting report count: $error');
    return 0;
  }
}

Future<void> rejectReportedAccount(List<String> reportIds) async {
  try {
    for (final reportId in reportIds) {
      final currentReportSnapshot = await FirebaseFirestore.instance
          .collection('Report')
          .doc(reportId)
          .get();
      final reportedItemId = currentReportSnapshot.get('reportedItemId');

      await FirebaseFirestore.instance
          .collection('Report')
          .where('reportedItemId', isEqualTo: reportedItemId)
          .get()
          .then((querySnapshot) {
        final batch = FirebaseFirestore.instance.batch();
        querySnapshot.docs.forEach((doc) {
          batch.update(doc.reference, {'status': 'Rejected'});
        });
        return batch.commit();
      });

      await FirebaseFirestore.instance
          .collection('Report')
          .doc(reportId)
          .update({'status': 'Rejected'});
    }

    toastMessage('Reports Have Been Rejected');
  } catch (error) {
    toastMessage('Error While Rejecting Reports');
    print('Error Rejecting Reports: $error');
  }
}




Future<void> acceptReportedAccount(List<String> reportIds, String username, List<String> reasons, String email) async {
  try {
    print('ARRRAAAAYYYYY $reportIds');

    final reportId = reportIds[0];
    // Get the reportedItemId of the current report
    final currentReportSnapshot = await FirebaseFirestore.instance
        .collection('Report')
        .doc(reportId)
        .get();
    final reportedItemId = currentReportSnapshot.get('reportedItemId');

    // Update the status of all reports with the same reportedItemId to 'Accepted'
    await FirebaseFirestore.instance
        .collection('Report')
        .where('reportedItemId', isEqualTo: reportedItemId)
        .get()
        .then((querySnapshot) {
      final batch = FirebaseFirestore.instance.batch();
      querySnapshot.docs.forEach((doc) {
        batch.update(doc.reference, {'status': 'Accepted'});
      });
      return batch.commit();
    });

    // Update the status of the current report to 'Accepted'
    await FirebaseFirestore.instance
        .collection('Report')
        .doc(reportId)
        .update({'status': 'Accepted'});

    toastMessage('Report Has Been Accepted');
  } catch (error) {
    toastMessage('Error While Accepting Report');
    print('Error Accepting Reports: $error');
  }

  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    queryParameters: {
      'subject': 'Account Report Alert',
      'body':  '''
Dear TeXel user,

We would like to inform you that your account with the username "$username" has been reported for $reasons. We kindly remind you to adhere to our community guidelines and maintain appropriate conduct within our platform.

We value the cooperation of all our users in creating a safe and respectful environment for everyone. If you have any questions or concerns, please don't hesitate to reach out to our support team.

Best regards,

The TeXel Team
''',
    },
  );


  if (await canLaunch(emailUri.toString())) {
    await launch(emailUri.toString());
  } else {
    throw 'Could not launch email';
  }

}
}