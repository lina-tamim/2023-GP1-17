import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techxcel11/pages/reuse.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBarUser(),
      appBar: AppBar(
        title: Text('Bookmark'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                   Text(
                'TechXcel',
                style: GoogleFonts.orbitron ( // chakraPetch blackOpsOne orbitron
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
              ),

              // Display application logo
              Image.asset('assets/Backgrounds/XlogoSmall.png'),
              SizedBox(height: 30),

              // Brief description of the platform
            ],
          ),
        ),
      ),
    );
  }
}
