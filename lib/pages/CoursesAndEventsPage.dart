import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techxcel11/pages/reuse.dart';


class CoursesAndEventsPage extends StatelessWidget {
  const CoursesAndEventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBarUser(),
      appBar: AppBar(
        title: Text('Courses and Events'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TechXcel',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              Image.asset('assets/Backgrounds/XlogoSmall.png'),
              SizedBox(height: 30),

            ],
          ),
        ),
      ),
   //   bottomNavigationBar:NavBarBottom2(),
    );
  }
}
