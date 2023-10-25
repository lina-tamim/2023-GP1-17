//Full code, m s
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techxcel11/pages/reuse.dart';

class CoursesAndEventsPage extends StatefulWidget {
  const CoursesAndEventsPage({super.key});

  @override
  State<CoursesAndEventsPage> createState() => _CoursesAndEventsPageState();

}
int _currentIndex = 0;
class _CoursesAndEventsPageState extends State<CoursesAndEventsPage> {
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBarUser(),
      appBar: buildAppBar ('Courses and Events'),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TechXcel',
                style: GoogleFonts.orbitron(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Image.asset('assets/Backgrounds/XlogoSmall.png'),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

//TECHXCEL-LINA
