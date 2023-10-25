//Full code, m
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techxcel11/pages/reuse.dart';
import 'package:techxcel11/pages/login.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHome();
}
class _AdminHome extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBarAdmin(),
      appBar: buildAppBar('Welcome Admin'),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(0)),
              ), 
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 30,
                mainAxisSpacing: 50,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate to another page when the box is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminHome()), // will be changed in sprint2
                      );
                    },
                    child: itemDashborde(
                      "Reported Posts",
                      CupertinoIcons.flag_fill,
                      const Color.fromARGB(255, 194, 0, 0),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to another page when the box is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminHome()),
                      );
                    },
                    child: itemDashborde(
                      "Reported Accounts",
                      CupertinoIcons.flag_fill,
                      const Color.fromARGB(255, 34, 115, 255),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to another page when the box is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminHome()),
                      );
                    },
                    child: itemDashborde(
                      "Admin Course and Event Management",
                      CupertinoIcons.square_stack_3d_up_fill,
                      const Color.fromARGB(255, 0, 194, 49),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to another page when the box is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminHome()),
                      );
                    },
                    child: itemDashborde(
                      "Admin Pathways Management",
                      CupertinoIcons.arrow_down_doc_fill,
                      const Color.fromARGB(255, 228, 211, 25),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to another page when the box is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminHome()),
                      );
                    },
                    child: itemDashborde(
                      "User Course or Event Addition Request",
                      CupertinoIcons.add_circled,
                      const Color.fromARGB(255, 228, 27, 168),
                    ),
                  ),
                ],
              ),
              
            ),
            
          ),
          InkWell(
  onTap: showLogoutConfirmationDialog,
  child: ListTile(
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.red,
      ),
      child: const Icon(
        Icons.logout,
        color: Colors.white,
      ),
    ),
    title: Text(
      'Logout',
      style: Theme.of(context).textTheme.bodyLarge?.apply(
            color: Colors.black87,
            fontWeightDelta: 2,
          ),
    ),
    trailing: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18.0,
        color: Colors.grey,
      ),
    ),
  ),
            
)
        ],
      ),
    );
  }

  itemDashborde(String title, IconData iconData, Color background) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 5),
              color: Color.fromARGB(255, 169, 157, 156),
              spreadRadius: 2,
              blurRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            )
          ],
        ),
      );

void showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }}
