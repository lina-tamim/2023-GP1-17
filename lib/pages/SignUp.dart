
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:techxcel11/pages/reuse.dart';
import 'package:lottie/lottie.dart';
import 'package:techxcel11/pages/start.dart';
import 'package:techxcel11/pages/Login.dart';
import "package:csc_picker/csc_picker.dart"; // city
import 'package:email_validator/email_validator.dart'; // email
import 'dart:async';
//+
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// lotti class
class ValidationAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(0, 255, 255, 255),
      child: Center(
        child: Lottie.network(
          'https://lottie.host/372c319f-2c25-4ea3-887a-04025f2c3c34/8YBJTLVI68.json', // Replace with your Lottie animation file path
          width: 300,
          height: 300,
          //assets
        ),
      ),
    );
  }
}

// the class for skills

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _Signup();
}

class _Signup extends State<Signup> {
  TextEditingController _password = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _userName = TextEditingController();
  TextEditingController _GitHublink = TextEditingController();

  List<String> typeOfUser = ['Regular User', 'Freelancer'];
  String _selectedUser = 'Regular User';

  List<String> typeOfPreference = ['Online', 'In Place'];
  String _selectedPreference = 'Online';

  String _selectedCountry = '';
  String _selectedCity = '';
  String _selectedState = '';

  List<String> _selectedSkills = [];
  List<String> _selectedInterests = [];

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> signUserUp() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'userName': _userName.text.trim().toLowerCase(),
        'userType': _selectedUser,
        'attendancePreference': _selectedPreference,
        'country': _selectedCountry,
        'state': _selectedState,
        'city': _selectedCity,
        'email': _email.text.trim().toLowerCase(),
        'password': hashPassword(_password.text.trim()),
        'GithubLink': _GitHublink.text.trim(),
        'interests': _selectedInterests,
        'skills': _selectedSkills,
      });


 // Send email verification to the user
    await userCredential.user?.sendEmailVerification();

    // Display a success message to the user
    _showSnackBar("Please check your email for verification.");

    // Redirect the user to a new screen, such as a login screen

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: ValidationAnimation(),
          );
        },
      );

      // Delay the navigation to the login page using a Timer
      Timer(const Duration(seconds: 6), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Login(),
          ),
        );
      });
    } catch (e) {
      // Handle sign-up errors here
      print('Sign-up error: $e');
    }
  }

  void _showMultiSelectSkills() async {
    final Map<String, List<String>> skillGroups = {
      'Data Science': [
        'Python',
        'R',
        'Tableau',
        'Machine learning and artificial intelligence',
        'Big data technologies (Hadoop, Apache Spark)',
        'Data science',
        'Statistical analysis',
        'Natural language processing (NLP)',
        'Robotic process automation (RPA)',
      ],
      'Database Management': [
        'Database management SQL',
        'Database management NoSQL',
        'Database management NewSQL',
      ],
      'Programming Languages': [
        'Java',
        'Node.js',
        'React',
        'C#',
        'C++',
      ],
      'Web Development': [
        'Web development (HTML)',
        'Web development (CSS)',
        'Web development (JavaScript)',
        'Web development (PHP)',
      ],
      'Mobile App Development': [
        'Mobile app development (iOS, Android)',
        'UI/UX design',
        'Swift',
        'Ruby',
        'Flutter and Dart',
      ],
      'Other Skills': [
        'Agile and Scrum methodologies',
        'Virtual reality (VR)',
        'Augmented reality (AR)',
        'Cloud computing',
        'Cybersecurity',
        'Network',
        'Blockchain',
        'Internet of Things (IoT)',
      ],
      'Soft Skills': [
        'Critical thinking',
        'Problem-solving',
        'Communication skills',
        'Collaboration',
        'Attention to detail',
        'Logical reasoning',
        'Creativity',
        'Time management',
        'Adaptability',
        'Leadership',
        'Teamwork',
        'Presentation skills',
      ],
    };

    final List<String> items = skillGroups.keys.toList();

    final List<String> selectedSkills = List<String>.from(
        _selectedSkills); // Store the selected skills outside of the dialog

    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        final List<String> chosenSkills = List<String>.from(selectedSkills);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select Skills'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    for (String group in items)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...skillGroups[group]!.map((String skill) {
                            return CheckboxListTile(
                              title: Text(skill),
                              value: chosenSkills.contains(skill),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    chosenSkills.add(skill);
                                  } else {
                                    chosenSkills.remove(skill);
                                  }
                                });
                              },
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(chosenSkills);
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedSkills = result;
      });
    }
  }

  void _showMultiSelectInterests() async {
    final Map<String, List<String>> interestGroups = {
      'Data Science': [
        'Python',
        'R',
        'Tableau',
        'Machine learning and artificial intelligence',
        'Big data technologies (Hadoop, Apache Spark)',
        'Data science',
        'Statistical analysis',
        'Natural language processing (NLP)',
        'Robotic process automation (RPA)',
      ],
      'Database Management': [
        'Database management SQL',
        'Database management NoSQL',
        'Database management NewSQL',
      ],
      'Programming Languages': [
        'Java',
        'Node.js',
        'React',
        'C#',
        'C++',
      ],
      'Web Development': [
        'Web development (HTML)',
        'Web development (CSS)',
        'Web development (JavaScript)',
        'Web development (PHP)',
      ],
      'Mobile App Development': [
        'Mobile app development (iOS, Android)',
        'UI/UX design',
        'Swift',
        'Ruby',
        'Flutter and Dart',
      ],
      'Other Interests': [
        'Agile and Scrum methodologies',
        'Virtual reality (VR)',
        'Augmented reality (AR)',
        'Cloud computing',
        'Cybersecurity',
        'Network',
        'Blockchain',
        'Internet of Things (IoT)',
      ],
      'Soft Skills': [
        'Critical thinking',
        'Problem-solving',
        'Communication skills',
        'Collaboration',
        'Attention to detail',
        'Logical reasoning',
        'Creativity',
        'Time management',
        'Adaptability',
        'Leadership',
        'Teamwork',
        'Presentation skills',
      ],
    };

    final List<String> items = interestGroups.keys.toList();

    final List<String> selectedInterests = List<String>.from(
        _selectedInterests); // Store the selected interests outside of the dialog

    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        final List<String> chosenInterests =
            List<String>.from(selectedInterests);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select Interests'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    for (String group in items)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...interestGroups[group]!.map((String interest) {
                            return CheckboxListTile(
                              title: Text(interest),
                              value: chosenInterests.contains(interest),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    chosenInterests.add(interest);
                                  } else {
                                    chosenInterests.remove(interest);
                                  }
                                });
                              },
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(chosenInterests);
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedInterests = result;
      });
    }
  }

  Future signUp() async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(), password: _password.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            left: 100,
            child: Image.asset('assets/Backgrounds/Spline.png'),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          const RiveAnimation.asset('assets/RiveAssets/shapes.riv'),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            top: MediaQuery.of(context).size.height * 0.1,
            bottom: MediaQuery.of(context).size.height * 0.1,
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                //height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OnboardingScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.arrow_back),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 75, top: 10),
                          child: Text(
                            "SignUp",
                            style:
                                TextStyle(fontSize: 34, fontFamily: "Poppins"),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 7),
                      child: Text(
                        'Unlock your potential with TechXcel!\n'
                        'Join now and embark on an exciting journey!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style:
                              TextStyle(color: Color.fromARGB(255, 60, 6, 99)),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 300,
                      child: const Divider(
                        color: const Color.fromARGB(255, 211, 211, 211),
                        thickness: 1,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // User Name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'User Name',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Tooltip(
                                child: Icon(
                                  Icons.live_help_rounded,
                                  size: 18,
                                  color: Color.fromARGB(255, 178, 178, 178),
                                ),
                                message:
                                    'Username should be at least 6 characters long\nand No white spaces are allawed',
                                   // '- At least 6 characters long\n'
                                  //  '- No whitespace allowed',
                                padding: EdgeInsets.all(20),
                                showDuration: Duration(seconds: 3),
                                textStyle: TextStyle(color: Colors.white),
                                preferBelow: false,
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          reusableTextField("Please Enter Your UserName",
                              Icons.person, false, _userName, true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    //Email
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'Email Address',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          Text(
                            'Ensure that you provide a valid email address as it cannot be changed after account creation',
                            style: TextStyle(
                                fontSize: 10,
                                color: Color.fromARGB(255, 205, 34, 21)),
                          ),
                          const SizedBox(height: 8),
                          reusableTextField(
                            "Please Enter Your Email",
                            Icons.email,
                            false,
                            _email,
                            true,
                          ),
                        ],
                      ),
                    ),

                    // pass
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Tooltip(
                                child: Icon(
                                  Icons.live_help_rounded,
                                  size: 18,
                                  color: Color.fromARGB(255, 178, 178, 178),
                                ),
                                message:
                                    'Password must meet be at least 6 characters long\nand No white spaces are allowed', 
                              //      '- At least 8 characters long\n'
                                //    '- At least 1 capital letter\n'
                                  //  '- No whitespace allowed',
                                padding: EdgeInsets.all(20),
                                showDuration: Duration(seconds: 3),
                                textStyle: TextStyle(color: Colors.white),
                                preferBelow: false,
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          reusableTextField(
                            "Please Enter Your Password",
                            Icons.lock,
                            true,
                            _password,
                            true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20), // space
                    // Country and city
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'Select Your Country',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          Text(
                            'State and City',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CSCPicker(
                            onCountryChanged: (value) {
                              setState(() {
                                _selectedCountry = value.toString();
                              });
                            },
                            onStateChanged: (value) {
                              setState(() {
                                _selectedState = value.toString();
                              });
                            },
                            onCityChanged: (value) {
                              setState(() {
                                _selectedCity = value.toString();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    // Type of User
                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'Type of User',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                          Tooltip(
                            child: Icon(
                              Icons.warning_rounded,
                              size: 18,
                              color: Color.fromARGB(255, 195, 0, 0),
                            ),
                            message:
                                'Note:\nSelecting the freelancer option unlocks additional features such as:\nJoin the dedicated freelancer page.\nTake on diverse projects, including paid opportunities.',
                            padding: EdgeInsets.all(20),
                            showDuration: Duration(seconds: 4),
                            textStyle: TextStyle(color: Colors.white),
                            preferBelow: false,
                          ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Column(
                            children: typeOfUser.map((String user) {
                              return RadioListTile<String>(
                                title: Text(user),
                                value: user,
                                groupValue: _selectedUser,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedUser = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              );
                            }).toList(),
                          ),

                          // Preference in Attendance

                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Text(
                                'Preference in Attendance',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Tooltip(
                                child: Icon(
                                  Icons.live_help_rounded,
                                  size: 18,
                                  color: Color.fromARGB(255, 178, 178, 178),
                                ),
                                message:
                                    'Find the best option for courses and events that suits your preference:\n'
                                    '- Physical attendance available for on-site experiences\n'
                                    '- Remote participation offered through online platforms\n',
                                  //  '- In Place for physical attendance\n'
                                  //  '- Online for remote participation\n',
                                padding: EdgeInsets.all(20),
                                showDuration: Duration(seconds: 3),
                                textStyle: TextStyle(color: Colors.white),
                                preferBelow: false,
                              )
                            ],
                          ),
                          const SizedBox(height: 2),
                          Column(
                            children: typeOfPreference.map((String preference) {
                              return RadioListTile<String>(
                                title: Text(preference),
                                value: preference,
                                groupValue: _selectedPreference,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedPreference = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Skills',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              if (_selectedUser == 'Freelancer')
                                const Text(
                                  '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              SizedBox(
                                width: 5,
                              ),
                              const Tooltip(
                                child: Icon(
                                  Icons.live_help_rounded,
                                  size: 18,
                                  color: Color.fromARGB(255, 178, 178, 178),
                                ),
                                message:
                                'Showcase what you can do based on your acquired abilities and experience.',
                                  //  'Skills:\nWhat you can do based on your acquired abilities and experience.',
                                padding: EdgeInsets.all(20),
                                showDuration: Duration(seconds: 3),
                                textStyle: TextStyle(color: Colors.white),
                                preferBelow: false,
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed:
                                _showMultiSelectSkills, // Corrected method name
                            child: const Text('Select Skills'),
                          ),
                          const Divider(
                            height: 10,
                          ),
                          // Display the selected items
                          Wrap(
                            children: _selectedSkills // Updated variable name
                                .map((e) => Chip(
                                      label: Text(e),
                                    ))
                                .toList(),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    //intrest
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Interests',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              const Tooltip(
                                child: Icon(
                                  Icons.live_help_rounded,
                                  size: 18,
                                  color: Color.fromARGB(255, 178, 178, 178),
                                ),
                                message:
                               'Share your passions with us, and we will ensure you receive the finest content recommendations!',// 'Choose What are you passionate about so we can recommend you the best content!'
                                   // 'Interests:\nWhat you enjoy or are passionate about.',
                                padding: EdgeInsets.all(20),
                                showDuration: Duration(seconds: 3),
                                textStyle: TextStyle(color: Colors.white),
                                preferBelow: false,
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed:
                                _showMultiSelectInterests, 
                            child: const Text('Select Interests'),
                          ),
                          const Divider(
                            height: 10,
                            //_selectedPreference
                          ),
                          // Display the selected items
                          Wrap(
                            children:
                                _selectedInterests 
                                    .map((e) => Chip(
                                          label: Text(e),
                                        ))
                                    .toList(),
                          )
                        ],
                      ),
                    ),
                    //  GitHub link
                    const SizedBox(height: 40), // space
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'GitHub Profile Link',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          reusableTextField(
                            "Please Enter Your GitHub Link",
                            FontAwesomeIcons.github,
                            false,
                            _GitHublink,
                            true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40), // space

                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Validation Step 1
                          Future<bool> isStep1Valid = _createAccount1();
                          bool isStep2Valid = _createAccount2();
                          if (await isStep1Valid && isStep2Valid) {
                            signUserUp();
                          }

      
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 198, 180, 247),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 10,
                          shadowColor:
                              Color.fromARGB(255, 0, 0, 0).withOpacity(1),
                        ),
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40), // space
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password); // Encode the password as bytes
    var digest = sha256.convert(bytes); // Hash the bytes using SHA-256
    return digest.toString(); // Convert the hash to a string
  }

  Future<bool> _createAccount1() async {
    if (_userName.text.isEmpty ||
        _email.text.isEmpty ||
        _password.text.isEmpty ||
        _selectedCity == '' ||
        _selectedCountry == '' ||
        _selectedState == '' ||
        _selectedPreference == null ||
        _selectedUser == null) {
      _showSnackBar('Please fill in all the required fields');
      return false;
    }

    //                                   *** username validation ***
    // Check username validity (>6 + no WS)
    if (_userName.text.length < 6) {
      _showSnackBar('Username should be at least 6 characters long');
      return false;
    } else if (_userName.text.contains(RegExp(r'\s'))) {
      _showSnackBar('Username should not contain whitespace');
      return false;
    }
    if (await checkAvailableUsername(_userName.text.trim()) == false) {
      _showSnackBar(
          'This username is already in use. Please try a different username');
      return false;
    }

    //                                   *** email validation ***
    // Check email validity

    bool containsValidCharacters(String email) {
      // Specify the valid characters allowed in the email username
      final validCharacters = RegExp(r'^[a-zA-Z0-9._%+-]+$');
      return validCharacters.hasMatch(email.split('@')[0]);
    }

    bool hasValidTLD(String email) {
      // Specify the minimum length for the top-level domain (TLD)
      final minTLDLength = 2;
      final domainParts = email.split('@')[1].split('.');
      return domainParts.length >= 2 && domainParts.last.length >= minTLDLength;
    }

    final email = _email.text.trim();
    if (!EmailValidator.validate(email) ||
        !containsValidCharacters(email) ||
        !hasValidTLD(email)) {
      _showSnackBar('Invalid Email');
      return false;
    }

    if (await checkAvailableEmail(email) == false) {
      _showSnackBar(
          'This email is already in use. Please try a different email');
      return false;
    }

    //                                   *** password validation ***
    // Check password validity (>8 + no WS)
    if (_password.text.length < 6) {
      _showSnackBar('Password should be at least 8 characters');
      return false;
    } /*else if (!_password.text.contains(RegExp(r'[A-Z]'))) {
      _showSnackBar('Password should contain at least 1 capital letter');
      return false;
    } else if (_password.text.contains(RegExp(r'\s'))) {
      _showSnackBar('Password should not contain whitespace');
      return false;
    }*/
    return true;
  } // end _createAccount1()

  bool _createAccount2() {
    //                                   *** skills validation ***

    if (_selectedUser == "Freelancer" && _selectedSkills.isEmpty) {
      _showSnackBar('Skills field is required for Freelancer user type');
      return false;
    }

    //                                   *** Github link validation ***
    final github = _GitHublink.text;

    if (github.isNotEmpty && !github.startsWith("https://github.com/")) {
      _showSnackBar('Invalid GitHub link');
      return false;
    }

    return true;
  }

  // Check email existence
  Future<bool> checkAvailableEmail(String email) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await usersCollection
        .where('email', isEqualTo: email.toLowerCase())
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      //_showSnackBar('This email is already in use. Please try a different email');
      return false; // Email already exists
    } else {
      return true; // Email is available
    }
  }

  // Check username existence
  Future<bool> checkAvailableUsername(String userName) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await usersCollection
        .where('userName', isEqualTo: userName.toLowerCase())
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      // _showSnackBar('This username is already in use. Please try a different username');
      return false; // Username already exists
    } else {
      return true; // Username is available
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 80,
          right: 20,
          left: 20,
        ),
        backgroundColor:
            Color.fromARGB(255, 63, 12, 118), // Customize the background color
      ),
    );
  }
}
//TECHXCEL
