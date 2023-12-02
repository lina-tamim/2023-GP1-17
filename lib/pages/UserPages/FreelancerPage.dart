import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techxcel11/Models/ReusedElements.dart';

class FreelancerPage extends StatefulWidget {
  const FreelancerPage({super.key});

  @override
  State<FreelancerPage> createState() => _FreelancerPageState();
}

int _currentIndex = 0;

class _FreelancerPageState extends State<FreelancerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBarUser(),
      appBar: buildAppBar('Freelancers'),
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
              Text(
                'Coming soon !',
                style: TextStyle(
                    fontFamily: AutofillHints.familyName,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              )
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

 