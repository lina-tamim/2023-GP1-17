import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techxcel11/pages/BlankPage.dart';
import 'package:techxcel11/pages/reuse.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHome();
}

class _AdminHome extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBarAdmin(),
      appBar: buildAppBar('Welcome Admin'),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              decoration: BoxDecoration(
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
                        MaterialPageRoute(builder: (context) => BlankPage()),
                      );
                    },
                    child: itemDashborde(
                      "Reported Posts",
                      CupertinoIcons.flag_fill,
                      Color.fromARGB(255, 194, 0, 0),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to another page when the box is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BlankPage()),
                      );
                    },
                    child: itemDashborde(
                      "Reported Accounts",
                      CupertinoIcons.flag_fill,
                      Color.fromARGB(255, 34, 115, 255),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to another page when the box is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BlankPage()),
                      );
                    },
                    child: itemDashborde(
                      "Admin Course and Event Management",
                      CupertinoIcons.square_stack_3d_up_fill,
                      Color.fromARGB(255, 0, 194, 49),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to another page when the box is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BlankPage()),
                      );
                    },
                    child: itemDashborde(
                      "Admin Pathways Management",
                      CupertinoIcons.arrow_down_doc_fill,
                      Color.fromARGB(255, 228, 211, 25),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to another page when the box is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BlankPage()),
                      );
                    },
                    child: itemDashborde(
                      "User Course or Event Addition Request",
                      CupertinoIcons.add_circled,
                      Color.fromARGB(255, 228, 27, 168),
                    ),
                  ),
                ],
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
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 5),
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
}
