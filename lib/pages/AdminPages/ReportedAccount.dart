import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_admin/firebase_admin.dart';
import 'package:firebase_admin/src/credential.dart';

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
    return Scaffold(
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
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
    );
  }

  Stream<List<Widget>> readReportedAccounts() {
    return FirebaseFirestore.instance
        .collection('Report')
        .where('reportType', isEqualTo: 'account')
        .snapshots()
        .asyncMap((snapshot) async {
      final reportedAccounts = <Widget>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final reportId = doc.id;
        final email = data['userId'];
        final reason = data['reason'];

        final userSnapshot = await FirebaseFirestore.instance
            .collection('RegularUser')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          final userData = userSnapshot.docs.first.data();
          final username = userData['username'];

          final card = Card(
            child: ListTile(
              title: Text('Username: $username'),
              subtitle: Text('Email: $email\nReason: $reason'),
              contentPadding: EdgeInsets.all(16),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Reject'),
          content: Text('Are you sure you want to reject this account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // Delete the card from the screen
                setState(() {
                  rejectReportedAccount( reportId);
                });

                // Delete the card from the database
                await FirebaseFirestore.instance
                    .collection('Report')
                    .doc(doc.id)
                    .delete();

                Navigator.pop(context);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
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
                  SizedBox(width: 10),
                  ElevatedButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Accept'),
          content: Text('Are you sure you want to Accept this report?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // Delete the card from the screen
                setState(() {
                  acceptReportedAccount( reportId, username, reason, email);
                });
                await FirebaseFirestore.instance
                    .collection('Report')
                    .doc(doc.id)
                    .delete();
                Navigator.pop(context);
              },
              child: Text('Yes'),
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
            ),
          );

          reportedAccounts.add(card);
        }
      }

      return reportedAccounts;
    });
  }
}

void rejectReportedAccount(String reportId) async {
  try {
    await FirebaseFirestore.instance
        .collection('Report')
        .doc(reportId)
        .delete();
    print('Report deleted successfully');
  } catch (error) {
    print('Error deleting report: $error');
  }
}

void acceptReportedAccount(String reportId, String username, String reason, String email) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    queryParameters: {
      'subject': 'Account Deletion Alert',
      'body': 'Dear User,\n\nYour account with username $username has been deactivated for $reason . \n If you have any concerns please reply to this email.\n\nBest regards,\nTeXel Team',
    },
  );

  if (await canLaunch(emailUri.toString())) {
    await launch(emailUri.toString());
  } else {
    throw 'Could not launch email';
  }
 deactivateReportedAccount( email);

}



void deactivateReportedAccount(String email) async {
  /*try {
    final user = await FirebaseAuth.instance.getUserByEmail(email);

    if (user != null) {
      // Deactivate the user account
      await FirebaseAuth.instance.updateUser(user.uid, UserRecordUpdate()..disabled = true);

      print('Account deactivated successfully');
    } else {
      print('User not found');
    }
  } catch (e) {
    print('Error deactivating account: $e');
  }*/
}