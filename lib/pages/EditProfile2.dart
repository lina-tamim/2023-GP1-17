import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techxcel11/pages/UserProfilePage.dart';
import "package:csc_picker/csc_picker.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:techxcel11/pages/reuse.dart';
import 'package:techxcel11/pages/start.dart'; // Import the FontAwesome Flutter package
import 'package:crypto/crypto.dart';
import 'dart:convert';


class EditProfile2 extends StatefulWidget {
  const EditProfile2({super.key});

  @override
  _EditProfile2State createState() => _EditProfile2State();
}

class _EditProfile2State extends State<EditProfile2> {

/////////// RETRIVED FROM DATABASE:
  String loggedInUsername = '';
  String loggedInPassword = '';
  String loggedInEmail = '';
  String loggedInCountry = '';
  String loggedInState='';
  String loggedInCity = '';
  String loggedInUserType = '';
  String LoggedInPreference='';
  String loggedInGithub = '';
  List<String> loggedInInterests= [];
  List<String> loggedInSkills= [];
  bool showSkills = false;
  bool showInterests = false;
  bool isModified = false;
  bool isPasswordchange = false;

/////////// MODIFIED BY USER:
String newUsername=''; //used later when comparison if values have
String newPassword =''; // changed or not(changed means user want to edit)
bool showPassword = false; // Variable to track the password visibility
String newCountry='';
String newState='';
String newCity='';
String newUserType='';
String newUserPreference='';
List<String> typeOfUser = ['Regular User', 'Freelancer'];
String selectedUserType ='';
List<String> typeOfPreference = ['Online', 'In Place'];
String selectedPreference = '';
List<String> newUserInterests =[];
List<String> newUserSkills =[];
String newGithubLink='';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs[0].data();
      final username = userData['userName'] ?? '';
      final country = userData['country'] ?? '';
      final state = userData['state'] ?? '';
      final city = userData['city'] ?? '';
      final userType = userData['userType'] ?? '';
      final userPreference = userData['attendancePreference'] ?? ''; //CORRECT SPELLING
      final github = userData['GithubLink'] ?? '';
      final skills = List<String>.from(userData['skills'] ?? []);
      final interests = List<String>.from(userData['interests'] ?? []); 
      final password = userData['password'] ?? ''; 
      newUsername = username;
      newPassword = password;
      isPasswordchange = false;

      newCountry=country;
      newState=state;
      newCity=city;
      newUserType = userType;
      selectedUserType = userType; // two variables used for comparison,  
      newUserPreference= userPreference; // one for what is retrieved from DB and other from what user modified
      selectedPreference = userPreference;
      newUserInterests = interests;
      newUserSkills = skills;
      newGithubLink = github;

      setState(() {
        loggedInUsername = username;
        loggedInCountry = country;
        loggedInState = state;
        loggedInCity = city;
        loggedInUserType= userType;
        LoggedInPreference = userPreference;
        loggedInGithub = github;
        loggedInSkills = skills;
        loggedInInterests = interests;
        loggedInEmail = email;
        loggedInPassword = password;
        loggedInGithub = github;
      });
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Edit Profile'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Username
          const Row(
            children: [
              SizedBox(width: 30),
              Text(
                'Username',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 5),
              Tooltip(
                message: 'Username must meet the following criteria:\n'
                    '- At least 6 characters long\n'
                    '- No whitespace allowed',
                padding: EdgeInsets.all(20),
                showDuration: Duration(seconds: 3),
                textStyle: TextStyle(color: Colors.white),
                preferBelow: false,
                child: Icon(
                  Icons.live_help_rounded,
                  size: 18,
                  color: Color.fromARGB(255, 178, 178, 178),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextField(
  decoration: InputDecoration(
    prefixIcon: const Icon(Icons.person, color: Color.fromARGB(255, 0, 0, 0)),
    labelStyle: const TextStyle(
      color: Colors.black54,
    ),
    filled: true,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    fillColor: const Color.fromARGB(255, 228, 228, 228).withOpacity(0.3),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
    ),
  ),
  enabled: true,
  readOnly: false,
  controller: TextEditingController(text: newUsername), // Use newUsername variable as the initial value
  onChanged: (value) {
    newUsername = value; // Update newUsername when the value changes
  },
),
              ),
              const SizedBox(width: 5),
            ],
          ),
          const SizedBox(height: 20),
          // Email
          const Row(
            children: [
              SizedBox(width: 30),
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 5),
              Tooltip(
                message: 'Email address as it cannot be changed after account creation',
                padding: EdgeInsets.all(20),
                showDuration: Duration(seconds: 4),
                textStyle: TextStyle(color: Colors.white),
                preferBelow: false,
                child: Icon(
                  Icons.warning_rounded,
                  size: 18,
                  color: Color.fromARGB(255, 195, 0, 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email, color: Color.fromARGB(255, 0, 0, 0)),
                    labelStyle: const TextStyle(
                      color: Colors.black54,
                    ),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: const Color.fromARGB(255, 119, 119, 119).withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  enabled: false,
                  readOnly: true,
                  controller: TextEditingController(text: loggedInEmail),
                ),
              ),
              const SizedBox(width: 5),
            ],
          ),
          const SizedBox(height: 20),
          // Password
          const Row(
            children: [
              SizedBox(width: 30),
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 5),
              Tooltip(
                message: 'Password must meet the following criteria:\n'
                    '- At least 8 characters long\n'
                    '- At least 1 capital letter\n'
                    '- No whitespace allowed',
                padding: EdgeInsets.all(20),
                showDuration: Duration(seconds: 3),
                textStyle: TextStyle(color: Colors.white),
                preferBelow: false,
                child: Icon(
                  Icons.live_help_rounded,
                  size: 18,
                  color: Color.fromARGB(255, 178, 178, 178),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextField(
  decoration: InputDecoration(
    prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 0, 0, 0)),
    labelStyle: const TextStyle(
      color: Colors.black54,
    ),
    filled: true,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    fillColor: const Color.fromARGB(255, 228, 228, 228).withOpacity(0.3),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
    ),
    suffixIcon: IconButton(
      icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
      onPressed: () {
        setState(() {
          showPassword = !showPassword;
        });
      },
    ),
  ),
  enabled: true,
  readOnly: false,
  obscureText: !showPassword, // Set obscureText based on the toggle state
  onChanged: (value) {
    newPassword = value;
   // isPasswordchange = true; // Update newPassword when the value changes
  },
),
              ),
              const SizedBox(width: 5),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
// COUNTRY CITY AND STATE
const Row(
        children: [
                 Text(
                                'Country',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'State and City',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
      CSCPicker(
        onCountryChanged: (value) {
          setState(() {
            newCountry = value.toString();
          });
        },
        onStateChanged: (value) {
          setState(() {
            newState = value.toString();
          });
        },
        onCityChanged: (value) {
          setState(() {
            newCity = value.toString();
          });
        },
      ),
 const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),

//USER TYPE

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
                          Tooltip(
                            message:
                                'Note:\nSelecting the freelancer option unlocks additional features such as:\nJoin the dedicated freelancer page.\nTake on diverse projects, including paid opportunities.',
                            padding: EdgeInsets.all(20),
                            showDuration: Duration(seconds: 4),
                            textStyle: TextStyle(color: Colors.white),
                            preferBelow: false,
                            child: Icon(
                              Icons.live_help_rounded,
                              size: 18,
                              color: Color.fromARGB(255, 178, 178, 178),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Column(
                        children: typeOfUser.map((String user) {
                          return RadioListTile<String>(
                            title: Text(user),
                            value: user, 
                            groupValue: selectedUserType,
                            onChanged: (String? value) {
                              setState(() {
                                selectedUserType = value!;
                                newUserType = selectedUserType;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          );
                        }).toList(),
                      ),
// User ATTENDANCE PREFERENCE

        const SizedBox(height: 5),
      const Row(
                        children: [
                          Text(
                            'Attendance Preference',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                              Tooltip(
                                message:
                                    'Find the best option for courses and events that suits your preference:\n'
                                    '- In Place for physical attendance\n'
                                    '- Online for remote participation\n',
                                padding: EdgeInsets.all(20),
                                showDuration: Duration(seconds: 3),
                                textStyle: TextStyle(color: Colors.white),
                                preferBelow: false,
                                child: Icon(
                                  Icons.live_help_rounded,
                                  size: 18,
                                  color: Color.fromARGB(255, 178, 178, 178),
                                ),
                              )
                      
                        ],
                      ),
                      const SizedBox(height: 2),
                      Column(
                        children: typeOfPreference.map((String user) {
                          return RadioListTile<String>(
                            title: Text(user),
                            value: user, 
                            groupValue: selectedPreference,
                            onChanged: (String? value) {
                              setState(() {
                                selectedPreference = value!;
                                newUserPreference = selectedPreference;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          );
                        }).toList(),
                      ),

 const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
//Interests
const Row(
                      children: [
                         Text(
                          'Interests',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                         SizedBox(
                            width: 5,
                          ),
                         Tooltip(
                message: 'We are asking for your interests to get to know you\nbetter and recommend relevant content to you',
                padding: EdgeInsets.all(20),
                showDuration: Duration(seconds: 3),
                textStyle: TextStyle(color: Colors.white),
                preferBelow: false,
                child: Icon(
                  Icons.live_help_rounded,
                  size: 18,
                  color: Color.fromARGB(255, 178, 178, 178),
                ),
              ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed:
                          _showMultiSelectInterests, // Corrected method name
                      child: const Text('Select Interests'),
                    ),
                 
                    // Display the selected items
                    Wrap(
                      children: newUserInterests // Updated variable name
                          .map((e) => Chip(
                                label: Text(e),
                              ))
                          .toList(),
                    ),
 const SizedBox(height: 5),
          const Divider(),
          const SizedBox(height: 5),

//skills

                    Row(
                      children: [
                        const Text(
                          'Skills',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        if (newUserType == 'Freelancer')
                          const Text(
                            '  *',
                            style: TextStyle(color: Colors.red),
                          ),
                                        const SizedBox(
                            width: 5,
                          ),
                         const Tooltip(
                message: 'Entering your skills will help you to build a strong profile\nand make you more visible to potential clients.',
                padding: EdgeInsets.all(20),
                showDuration: Duration(seconds: 3),
                textStyle: TextStyle(color: Colors.white),
                preferBelow: false,
                child: Icon(
                  Icons.live_help_rounded,
                  size: 18,
                  color: Color.fromARGB(255, 178, 178, 178),
                ),
              ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed:
                          _showMultiSelectSkills, // Corrected method name
                      child: const Text('Select Skills'),
                    ),
                  
                    // Display the selected items
                    Wrap(
                      children: newUserSkills // Updated variable name
                          .map((e) => Chip(
                                label: Text(e),
                              ))
                          .toList(),
                    ),
                     const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),

//Github
              const Text(
                'Github',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
          const SizedBox(height: 5),
         Row(
  children: [
    Expanded(
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(
            FontAwesomeIcons.github,
            size: 18,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          labelStyle: const TextStyle(
            color: Colors.black54,
          ),
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          fillColor: const Color.fromARGB(255, 228, 228, 228).withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          hintText: newGithubLink.isEmpty ? 'Add your GitHub account now!' : null,
        ),
        enabled: true,
        readOnly: false,
        controller: TextEditingController(text: newGithubLink), // Use newGithubLink variable as the initial value
        onChanged: (value) {
          newGithubLink = value; // Update newGithubLink when the value changes
        },
      ),
    ),
    const SizedBox(width: 5),
  ],
),
const SizedBox(height: 20),

// Save button
Row(
      children: [
        ElevatedButton(
           onPressed: () async {
    if (await validateUsername() && await validatePassword() && await validateCSC()
     && await validateUserType() && await validateUserPreference() && 
     await validateInterests() && await validateSkills() && await validateGithubLink())
    {
      if ( isModified == true ) {
        _showSnackBar("Your information has been changed successfully");
      }

                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserProfilePage()),
                    );
  }
  },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 6, 107, 10), // Set the button's background color to green
            padding: const EdgeInsets.symmetric(horizontal: 35), // Add padding for visual spacing
            alignment: Alignment.centerLeft, // Align the button's contents to the left
          ),
          child: const Text('Save'),
        ),
        const SizedBox(width: 13), // Add some spacing between the buttons
        ElevatedButton(
          onPressed: () {
            // Handle Cancel button press
            Navigator.pop(context); // Redirect back to UserProfilePage.dart
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey, // Set the button's background color to grey
            padding: const EdgeInsets.symmetric(horizontal: 35), // Add padding for visual spacing
            alignment: Alignment.centerLeft, // Align the button's contents to the left
          ),
          child: const Text('Cancel'),
        ),
      ],
    ),
const SizedBox(height: 2), // Add spacing between the button sets
    ElevatedButton(
  onPressed: () {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "There's no Ctrl+Z to bring it back!",
            style: TextStyle(
              color: Color.fromARGB(255, 70, 0, 83),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to delete your account?',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Handle delete account confirmation
                      if ( await isDeleted() )
                      {
                      Navigator.pop(context); // Close the dialog

         showDialog(
  context: context,
  builder: (BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 240, 240, 240),
              Color.fromARGB(255, 223, 223, 223),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bye!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We hope to see you again soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  },
);

navigateToStartPage();

                    }
      },
                    icon: const Icon(Icons.delete, size: 24),
                    label: const Text(
                      'Delete',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 184, 13, 1),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
         backgroundColor: const Color.fromARGB(255, 244, 242, 242),
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 193, 34, 23), // Set the button's background color to red
        padding: const EdgeInsets.symmetric(horizontal: 120),
      ),
      child: const Text('Delete My Account'),
    ),
        ],
   
      ),
      
    ),
  );
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

  final List<String> selectedInterests = List<String>.from(loggedInInterests); // Store the selected interests outside of the dialog

  final List<String>? result = await showDialog<List<String>>(
    context: context,
    builder: (BuildContext context) {
      final List<String> chosenInterests = List<String>.from(selectedInterests);

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
      newUserInterests = result;
    });
  }
}


void _showMultiSelectSkills() async {
  final Map<String, List<String>> skillGroups ={
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

  final List<String> selectedSkills = List<String>.from(loggedInSkills); // Store the selected skills outside of the dialog

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
      newUserSkills = result;
    });
  }
}



// Function to validate and save the username
Future<bool> validateUsername() async {
  if (  newUsername == loggedInUsername) {
    return true;
  } else if (newUsername.length < 6 ) {
    _showSnackBar('Username should be at least 6 characters long.');
  } else if (newUsername.contains(' ')) {
    _showSnackBar('Username should not contain spaces.');
  } else if (newUsername != loggedInUsername) {
    bool usernameExists = await checkUsernameExists(newUsername);

    if (usernameExists) {
      _showSnackBar('Username is already taken. Please choose a different one.');
    } else {
      // Username is valid and not already taken, perform the save operation
      if ( await updateUsernameByEmail()) {
        return true;
      }
      
    }
  } else {
  }
  return false;
}

Future<bool> checkUsernameExists(String username) async {
  final querySnapshot = await FirebaseFirestore.instance
    .collection('users')
    .where('userName', isEqualTo: username.toLowerCase())
    .limit(1)
    .get();

  return querySnapshot.docs.isNotEmpty;
}

Future<bool> updateUsernameByEmail() async {
  final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: loggedInEmail)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    final DocumentSnapshot<Map<String, dynamic>> userDoc = snapshot.docs.first;
    final String userId = userDoc.id;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'userName': newUsername,
    });
  }
      isModified = true;
    //   _showSnackBar('Your information has been changed successfullyUSERNAME');
       return true;

}
Future<bool> validatePassword() async {
  // Check if the new password is equal to the existing password
  if (newPassword =='' || hashPassword(newPassword) == loggedInPassword ) {
    return true; // Nothing changed (user doesn't want to modify)
  }

  // Check password length
  if (newPassword.length < 6) {
    _showSnackBar('Password should not be less than 6 characters.');
    return false;
  }

  // Check for white spaces in the password
  if (newPassword.contains(' ')) {
    _showSnackBar('Password should not contain spaces.');
    return false;
  }

  // Update the password in the database and Firebase Authentication
  if (await updatePasswordByEmail()) {
    return true;
  }

  return false;
}

Future<bool> updatePasswordByEmail() async {
  final QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: loggedInEmail)
          .limit(1)
          .get();

  if (snapshot.docs.isNotEmpty) {
    final DocumentSnapshot<Map<String, dynamic>> userDoc = snapshot.docs.first;
    final String userId = userDoc.id;
    final String hashedPassword = hashPassword(newPassword); // Hash the new password

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'password': hashedPassword});

    // Update password in Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
         isModified = true;
        return true;
      } catch (e) {
        print('Failed to update password in Firebase Authentication: $e');
      }
    }
  }

  return false;
}

String hashPassword(String password) {
  var bytes = utf8.encode(password); // Encode the password as bytes
  var digest = sha256.convert(bytes); // Hash the bytes using SHA-256
  return digest.toString(); // Convert the hash to a string
}

Future<bool> validateCSC() async {
  // Check if the new password is equal to the existing password
  if (newCountry == loggedInCountry && newState == loggedInState && newCity == loggedInCity ) {
    return true;
  }else
  // Check country is entered length
  if (newCountry.isEmpty) {
  _showSnackBar( 'Choose your country please');
    return false;
  }else
if ( await updateCSC() )
return true;
return false;
}

Future<bool> updateCSC() async {
  final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: loggedInEmail)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    final DocumentSnapshot<Map<String, dynamic>> userDoc = snapshot.docs.first;
    final String userId = userDoc.id;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'country': newCountry, 'city': newCity,'state': newState,
    });
  }
       isModified = true;
       return true;
}

Future<bool> validateUserType() async {
  if (newUserType == loggedInUserType ) {
    return true;
  }else
  if ( newUserSkills.isEmpty && newUserType == 'Freelancer' )
  {
    _showSnackBar('Please enter your skills');
    return false;
  }else
if ( await updateUserType() )
return true;
return false;
}

Future<bool> updateUserType() async {
  final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: loggedInEmail)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    final DocumentSnapshot<Map<String, dynamic>> userDoc = snapshot.docs.first;
    final String userId = userDoc.id;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'userType': newUserType, 
    });
  }
      isModified = true;
       return true;
}


Future<bool> validateUserPreference() async {
  if (newUserPreference == LoggedInPreference ) {
    return true;
  }else
if ( await updateUserPreference() )
return true;
return false;
}

Future<bool> updateUserPreference()  async {
  final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: loggedInEmail)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    final DocumentSnapshot<Map<String, dynamic>> userDoc = snapshot.docs.first;
    final String userId = userDoc.id;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'attendancePreference': newUserPreference, 
    });
  }
      isModified = true;
       return true;
}



Future<bool> validateInterests() async {
  if (newUserInterests == loggedInInterests ) {
    return true;
  }else
  if ( newUserInterests.isEmpty)
  {
    _showSnackBar('Please enter your interests');
    return false;
  }
if ( await updateInterests() ) {
  return true;
}
return false;
}


Future<bool> updateInterests()  async {
  final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: loggedInEmail)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    final DocumentSnapshot<Map<String, dynamic>> userDoc = snapshot.docs.first;
    final String userId = userDoc.id;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'interests': newUserInterests, 
    });
  }
        isModified = true;
       return true;
}

Future<bool> validateSkills() async {
  if (newUserSkills == loggedInSkills ) {
    return true;
  }else
  if ( newUserSkills.isEmpty && newUserType == 'Freelancer' )
  {
    _showSnackBar('Please enter your skills');
    return false;
  }else
if ( await updateSkills() )
return true;
else
return false;
}

Future<bool> updateSkills()  async {
  final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: loggedInEmail)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    final DocumentSnapshot<Map<String, dynamic>> userDoc = snapshot.docs.first;
    final String userId = userDoc.id;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'skills': newUserSkills, 
    });
  }
      isModified = true;
     // _showSnackBar('Your information has been changed successfullySKILLS');
       return true;
}



Future<bool> validateGithubLink() async {
  if (  newGithubLink == loggedInGithub) {
    return true;
  } else if (newGithubLink.isNotEmpty && !newGithubLink.startsWith("https://github.com/")) {
      _showSnackBar('Invalid GitHub link');
      return false;
    }
     else {
      if ( await updateGithubLink()) {
        return true;
      }
      return false;
      
    }
}

Future<bool> updateGithubLink() async {
  final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: loggedInEmail)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    final DocumentSnapshot<Map<String, dynamic>> userDoc = snapshot.docs.first;
    final String userId = userDoc.id;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'GithubLink': newGithubLink,
    });
  }
     isModified = true;
       return true;

}

Future<bool> isDeleted() async {
  final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: loggedInEmail)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    final DocumentSnapshot<Map<String, dynamic>> userDoc = snapshot.docs.first;
    final String userId = userDoc.id;

    // Delete user document from Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();

    // Delete user from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete();
    }
    return true;
  }

  _showSnackBar('An error occurred while trying to delete your account');
  return false;
}

void navigateToStartPage() async {
  await Future.delayed(const Duration(seconds: 4));
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const OnboardingScreen(),
    ),
  );
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




}// end page




  
