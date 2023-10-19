import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techxcel11/pages/reuse.dart';


class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: buildAppBar ('Bookmark'),
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