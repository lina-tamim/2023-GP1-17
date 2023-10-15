//import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:techxcel11/pages/NavBar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import the FontAwesome Flutter package
import 'package:google_fonts/google_fonts.dart';



class AboutUsPage extends StatefulWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
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
    fontSize: 60,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
              ),

              // Display application logo
              Image.asset('assets/logo.png'),
              SizedBox(height: 60),

              // Brief description of the platform
              Text(
                'TechXcel is a platform that combines features from multiple platforms like StackOverflow, Upwork, and Coursera. It is a one-stop shop for all things tech, where you can ask questions, find freelancers, and learn new skills.',
                style: TextStyle(
                  fontSize: 16,
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
                    size: 18,
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















/*



class AboutusPage extends StatefulWidget{
  const AboutusPage({Key? key}) : super(key: key);

  @override
  State<AboutusPage> createState() => _AboutusPageState();
}
  
class _AboutusPageState extends State<AboutusPage>{
  @override
  Widget build (BuildContext context){
     return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 241, 243, 1),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color.fromRGBO(248, 241, 243, 1),
        color: const Color.fromARGB(255, 237, 212, 242),
        animationDuration: const Duration (milliseconds: 300),
        onTap: (index){
          //use it to navigate to different pages

        },
        items: const [
        Icon(Icons.home),
        Icon(Icons.work),
        Icon(Icons.book),
        Icon(Icons.chat_bubble),

      ],
      ) ,
    );
  }
}*/