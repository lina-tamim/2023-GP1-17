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
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Color.fromRGBO(37, 6, 81, 0.898),
        ),
        toolbarHeight: 100,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Backgrounds/bg11.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
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

Stream<List<Widget>> readReportedAccounts() {
  return FirebaseFirestore.instance
      .collection('Report')
      .where('reportType', isEqualTo: 'Account')
      .where('status', isEqualTo: 'Pending')
      .orderBy('reportDate', descending: true)
      .snapshots()
      .asyncMap((snapshot) async {
        final reportedAccounts = <Widget>[];

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final reportedItemId = data['reportedItemId'];
          final reason = data['reason'];

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
            final reportId = doc.id;
            final count = await getAccountReportCount(reportedItemId);

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
                              Row(
                                children: [
                                  Text(
                                    'Reason: ',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 92, 0, 0),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    reason,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
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
                                reportId, username, reason, email);
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
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            rejectReportedAccount(reportId);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 122, 1, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Reject',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );

            reportedAccounts.add(
              Container(
                margin: EdgeInsets.only(bottom: 16),
                child: card,
              ),
            );
          }
        }

        if (reportedAccounts.isEmpty) {
          reportedAccounts.add(
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 280),
                  Center(
                    child: Text(
                      "Completely Clean!\n\nNo Reported Accounts Found",
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



Stream<List<Widget>> readOldReportedAccounts() {
  return FirebaseFirestore.instance
      .collection('Report')
      .where('reportType', isEqualTo: 'Account')
      .where('status' , isEqualTo: 'Accepted')
      .orderBy('reportDate', descending: true)  
      .snapshots()
      .asyncMap((snapshot) async {
    final reportedAccounts = <Widget>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final reportedItemId = data['reportedItemId'];
      final reason = data['reason'];

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
                        builder: (context) => UserProfileView(userId: email),
                      ),
                    );
                  }, child: 
                  CircleAvatar(
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
                        builder: (context) => UserProfileView(userId: email),
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
                        builder: (context) => UserProfileView(userId: email),
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
                  Row(
                    children: [
                      Text(
                        'Reason: ',
                        style: TextStyle(
                          color: Color.fromARGB(255, 92, 0, 0),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        reason,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Report Accepted',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

        reportedAccounts.add(Container(
          margin: EdgeInsets.only(bottom: 16),
          child: card,
        ));
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
                "No Previous Accepted Reports Found",
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
        .where('reportedItemId', isEqualTo: reportedItemID)
        .get();

    return querySnapshot.docs.length;
  } catch (error) {
    print('Error getting report count: $error');
    return 0;
  }
}

void rejectReportedAccount(String reportId) async {
  try {
    await FirebaseFirestore.instance
        .collection('Report')
        .doc(reportId)
        .update({'status': 'Rejected'});
    toastMessage('Report Has Been Rejected');
  } catch (error) {
    toastMessage('Error While Rejecting Report');
    print('Error Rejecting Report: $error');
  }
}


void acceptReportedAccount(String reportId, String username, String reason, String email) async {
  print(reportId);
  print(';;;;;;;;;;;;777788888889797');
  try {
    await FirebaseFirestore.instance
        .collection('Report')
        .doc(reportId)
        .update({'status': 'Accepted'});
    toastMessage('Report Has Been Accepted');
  } catch (error) {
    toastMessage('Error While Accepting Report');
    print('Error Accepting Report: $error');
  }

  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    queryParameters: {
      'subject': 'Account Report Alert',
      'body':  '''
Dear TeXel user,

We would like to inform you that your account with the username "$username" has been reported for $reason. We kindly remind you to adhere to our community guidelines and maintain appropriate conduct within our platform.

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


