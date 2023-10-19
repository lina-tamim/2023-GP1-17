import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techxcel11/pages/reuse.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: buildAppBar ('Calendar'),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display application name in big font
              Text(
                'TechXcel',
                style: GoogleFonts.orbitron(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              // Display application logo
              Image.asset('assets/Backgrounds/XlogoSmall.png'),
              const SizedBox(height: 30),

              // Brief description of the platform
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