import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReposrtedPost extends StatefulWidget {
const ReposrtedPost({super.key});

  @override
  State<ReposrtedPost> createState() => _ReposrtedPostState();
}

int _currentIndex = 0;

class _ReposrtedPostState extends State<ReposrtedPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme:
            IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
        backgroundColor: Color.fromRGBO(37, 6, 81, 0.898),
        toolbarHeight: 100, 
        elevation: 0, 
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(130),
            bottomRight: Radius.circular(130),
          ),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Builder(builder: (context) {
                return IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),
                );
              }),
              const Text(
                'Reported Accounts',
                style: TextStyle(
                  fontSize: 18, // Adjust the font size
                  fontFamily: "Poppins",
                  color: Colors.white,
                ),
              ),
              const Spacer(),
            ],
          ),
        ]),
      ),
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
                  fontFamily: 'AutofillHints.familyName',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 
