/*import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:techxcel11/pages/LoginPage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final String txlLogo = 'assets/Backgrounds/Xlogo.png';
  final String txlLogo2 = 'assets/Backgrounds/TXlogo2.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 100,
            child: Image.asset('assets/Backgrounds/Spline.png'),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 10),
            ),
          ),
          const RiveAnimation.asset('assets/RiveAssets/shapes.riv'),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: const SizedBox(),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 300,
                  left: 50,
                  child: Image.asset(
                    txlLogo,
                    width: 250,
                    height: 250,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Solve, \nLearn, \nCommunicate",
                            style: TextStyle(
                              fontSize: 40,
                              fontFamily: "Poppins",
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 40),
                        /*  Text(
                            'Welcome to TeXel,\nYour centralized hub for technology.\n\n'
                            'Join our vibrant community to engage in community-wide discussions,find solutions to all your problem and '
                            'stay up to date with the newest technology events and courses, empowering your professional growth.',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Color.fromARGB(255, 27, 27, 26)),
                          ),*/
                        ],
                      ),
                    ],
                  ),
                ),
                /*Positioned(
                  top: 450,
                  left: 53,
                  child: Image.asset(
                    txlLogo2,
                    width: 160, 
                    height: 180, 
                  ),
                ),*/
                SizedBox(width:70),
                Positioned(
                  bottom: 70,
                  left: 100,
                  right: 100,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 4,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: Colors.black,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "START",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:techxcel11/pages/LoginPage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final String txlLogo = 'assets/Backgrounds/Xlogo.png';
  final String txlLogo2 = 'assets/Backgrounds/TXlogo2.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 100,
            child: Image.asset('assets/Backgrounds/Spline.png'),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 10),
            ),
          ),
          const RiveAnimation.asset('assets/RiveAssets/shapes.riv'),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: const SizedBox(),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  left: 300,
                  child: Image.asset(
                    txlLogo,
                    width: 250,
                    height: 250,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Solve, \nLearn, \nCommunicate",
                            style: TextStyle(
                              fontSize: 45,
                              fontFamily: "Poppins",
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 40),
                          Text(
                            'Welcome to TeXel,\nYour centralized hub for technology.\n\n'
                            '                                                                                                          '
                             '                                                                                                          ',

                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Color.fromARGB(255, 27, 27, 26)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 550,
                  left: 70,
                  child: Image.asset(
                    txlLogo2,
                    width: 160, 
                    height: 180, 
                  ),
                ),
                Positioned(
                  bottom: 70,
                  left: 40,
                  right: 150,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 4,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: Colors.black,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "START",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}