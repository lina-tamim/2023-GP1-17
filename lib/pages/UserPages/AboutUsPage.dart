import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:techxcel11/Models/ReusedElements.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBarUser(),
      appBar: buildAppBar('About TechXcel'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/Backgrounds/XlogoSmall.png'),
                const SizedBox(height: 5),
                Center(
                  child: Lottie.network(
                    'https://lottie.host/623f88bb-cb70-413c-bb1a-0003d0b7e3d6/RnPQM25m8I.json',
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                const Text(
                  "TechXcel, the all-in-one destination for tech ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  'enthusiasts, professionals, and lifelong learners.',
                  style: GoogleFonts.satisfy(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(221, 62, 17, 17),
                  ),
                ),
                SizedBox(height: 15),
                const SizedBox(height: 25),
                Center(
                  child: const Text(
                    "At TechXcel, we're passionate about technology and its endless possibilities. Our platform serves as a hub where you can ignite your tech journey, connect with like-minded individuals, and unlock new opportunities.",
                    style: TextStyle(
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                const Text( 'Reach out to us!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(37, 6, 81, 0.898),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email),
                      const SizedBox(width: 10),
                      Text(
                        'txsupport@techxcel.com',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.twitter,
                        size: 20,
                        color: Color.fromARGB(255, 0, 136, 255),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '@techxcelapp',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

 