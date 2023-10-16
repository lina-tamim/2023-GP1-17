//import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import the FontAwesome Flutter package
import 'package:google_fonts/google_fonts.dart';
import 'package:techxcel11/pages/reuse.dart';



class AboutUsPage extends StatefulWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBarUser(),
      appBar: AppBar(
        title: Text('About TechXcel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display application name in big font
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




  Text(
  "TechXcel, the all-in-one destination for tech ",
                style: TextStyle(
                  fontSize: 13,
                ),
              ),


Text(
'enthusiasts, professionals, and lifelong learners.',
  style: GoogleFonts.satisfy ( // chakraPetch blackOpsOne orbitron
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: const Color.fromARGB(221, 62, 17, 17),
  ),),
SizedBox(height:20),
              Text(
                "At TechXcel, we're passionate about technology and its endless possibilities. Our platform serves as a hub where you can ignite your tech journey, connect with like-minded individuals, and unlock new opportunities.",
                style: TextStyle(
                  fontSize: 13,
                ),
              ),

              SizedBox(height: 80),

              // Ways to communicate with us
              Text(
                'Reach out to us!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Email address
              Row(
                children: [
                  Icon(Icons.email),
                  SizedBox(width: 10),
                  Text(
                    'txsupport@techxcel.com',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              // Twitter account
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.twitter,
                    size: 20,
                    color: Colors.grey[700],
                  ),
                  SizedBox(width: 10),
                  Text(
                    '@techxcelapp',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}











