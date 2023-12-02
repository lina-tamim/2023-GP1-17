import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:csc_picker/csc_picker.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:techxcel11/Models/UserEditProfileImage.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/pages/UserPages/UserProfilePage.dart';
import 'package:techxcel11/pages/StartPage.dart';

//EDIT +CALNDER COMMIT

class EditProfile2 extends StatefulWidget {
  const EditProfile2({super.key});

  @override
  _EditProfile2State createState() => _EditProfile2State();
}

class _EditProfile2State extends State<EditProfile2> {
/////////// RETRIVED FROM DATABASE:
  String _loggedInUID = '';
  String _loggedInUsername = '';
  String _loggedInPassword = '';
  String _loggedInEmail = '';
  String _loggedInCountry = '';
  String _loggedInState = '';
  String _loggedInCity = '';
  String _loggedInUserType = '';
  String _LoggedInPreference = '';
  String _loggedInGithub = '';
  List<String> _loggedInInterests = [];
  List<String> _loggedInSkills = [];
  String _loggedInimageURL = '';
  bool _showSkills = false;
  bool _showInterests = false;
  bool isModified = false;
  bool isPasswordchange = false;
  bool _isLoading = false;

/////////// MODIFIED BY USER:
  String newUsername = ''; //used later when comparison if values have
  String newPassword = ''; // changed or not(changed means user want to edit)
  bool showPassword = false; // Variable to track the password visibility
  String newCountry = '';
  String newState = '';
  String newCity = '';
  String newUserType = '';
  String newUserPreference = '';
  List<String> typeOfUser = ['Regular User', 'Freelancer'];
  String selectedUserType = '';
  List<String> typeOfPreference = ['Online', 'Onsite'];
  String selectedPreference = '';
  List<String> newUserInterests = [];
  List<String> newUserSkills = [];
  String newGithubLink = '';
  File? newProfilePicture;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('RegularUser')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs[0].data();
      final username = userData['username'] ?? '';
      final country = userData['country'] ?? '';
      final state = userData['state'] ?? '';
      final city = userData['city'] ?? '';
      final userType = userData['userType'] ?? '';
      final userPreference =
          userData['attendancePreference'] ?? ''; //CORRECT SPELLING
      final github = userData['githubLink'] ?? '';
      final skills = List<String>.from(userData['skills'] ?? []);
      final interests = List<String>.from(userData['interests'] ?? []);
      final password = userData['password'] ?? '';
      final imageURL = userData['imageURL'] ?? '';
      newUsername = username;
      newPassword = '';
      isPasswordchange = false;
      newCountry = country;
      newState = state;
      newCity = city;
      newUserType = userType;
      selectedUserType = userType; // two variables used for comparison,
      newUserPreference =
          userPreference; // one for what is retrieved from DB and other from what user modified
      selectedPreference = userPreference;
      newUserInterests = interests;
      newUserSkills = skills;
      newGithubLink = github;

      setState(() {
        _loggedInUID = snapshot.docs[0].id;
        _loggedInUsername = username;
        _loggedInCountry = country;
        _loggedInState = state;
        _loggedInCity = city;
        _loggedInUserType = userType;
        _LoggedInPreference = userPreference;
        _loggedInGithub = github;
        _loggedInSkills = skills;
        _loggedInInterests = interests;
        _loggedInEmail = email;
        _loggedInPassword = password;
        _loggedInGithub = github;
        _loggedInimageURL = imageURL;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar('Edit Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Transform.scale(
                  scale:
                      1.6, // Increase the scale value to make the image bigger
                  child: UserEditImagePicker(
                    onPickImage: (pickedImage) {
                      newProfilePicture = pickedImage;
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Text(
                  'Username',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  '*',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(
                  width: 5,
                ),
                Tooltip(
                  message:
                      'Username should be at least 6 characters long\nand No white spaces are allawed',
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
                      prefixIcon: const Icon(Icons.person,
                          color: Color.fromARGB(255, 0, 0, 0)),
                      labelStyle: const TextStyle(
                        color: Colors.black54,
                      ),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: const Color.fromARGB(255, 228, 228, 228)
                          .withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    enabled: true,
                    readOnly: false,
                    controller: TextEditingController(
                        text:
                            newUsername), // Use newUsername variable as the initial value
                    onChanged: (value) {
                      newUsername =
                          value; // Update newUsername when the value changes
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
                SizedBox(width: 10),
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  '*',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(width: 5),
                Tooltip(
                  message:
                      'Email address cannot be changed after account creation',
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
                      prefixIcon: const Icon(Icons.email,
                          color: Color.fromARGB(255, 0, 0, 0)),
                      labelStyle: const TextStyle(
                        color: Colors.black54,
                      ),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: const Color.fromARGB(255, 119, 119, 119)
                          .withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    enabled: false,
                    readOnly: true,
                    controller: TextEditingController(text: _loggedInEmail),
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
            const SizedBox(height: 20),
            // Password
            const Row(
              children: [
                SizedBox(width: 10),
                Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  '*',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(width: 5),
                Tooltip(
                  message:
                      'Password must meet be at least 6 characters long\nand No white spaces are allowed',
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
                      prefixIcon: const Icon(Icons.lock,
                          color: Color.fromARGB(255, 0, 0, 0)),
                      labelStyle: const TextStyle(
                        color: Colors.black54,
                      ),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      fillColor: const Color.fromARGB(255, 228, 228, 228)
                          .withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(showPassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                    enabled: true,
                    readOnly: false,
                    obscureText:
                        !showPassword, 
                    onChanged: (value) {
                      newPassword = value;
                    },
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
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
                SizedBox(width: 5),
                Text(
                  '*',
                  style: TextStyle(color: Colors.red),
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
                SizedBox(width: 5),
                Text(
                  '*',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(
                  width: 5,
                ),
                Tooltip(
                  message:
                      'Find the best option for courses and events that suits your preference:\n'
                      '- Physical attendance available for on-site experiences\n'
                      '- Remote participation offered through online platforms\n',
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
                SizedBox(width: 5),
                Text(
                  '*',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(
                  width: 5,
                ),
                Tooltip(
                  message:
                      'Share your passions with us, and we will ensure you receive the finest content recommendations!', // 'Choose What are you passionate about so we can recommend you the best content!'
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
              onPressed: _showMultiSelectInterests, // Corrected method name
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
                  message:
                      'Showcase what you can do based on your acquired abilities and experience.',
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
              onPressed: _showMultiSelectSkills, // Corrected method name
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
              'Github link',
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
                      fillColor: const Color.fromARGB(255, 228, 228, 228)
                          .withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      hintText: newGithubLink.isEmpty
                          ? 'Add your GitHub account now!'
                          : null,
                    ),
                    enabled: true,
                    readOnly: false,
                    controller: TextEditingController(
                        text:
                            newGithubLink), // Use newGithubLink variable as the initial value
                    onChanged: (value) {
                      newGithubLink =
                          value; // Update newGithubLink when the value changes
                    },
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
            if (_isLoading)
              IgnorePointer(
                child: Opacity(
                  opacity: 1,
                  child: Container(
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
// Save button
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (await validateUsername() &&
                          await validatePassword() &&
                          await validateCSC() &&
                          await validateUserType() &&
                          await validateUserPreference() &&
                          await validateInterests() &&
                          await validateSkills() &&
                          await validateGithubLink() &&
                          await validateUserPic()) {
                        if (isModified == true) {
                          _showSnackBar2(
                              "Your information has been changed successfully");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UserProfilePage()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UserProfilePage()),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 6, 107, 10),
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      alignment: Alignment.centerLeft,
                    ),
                    child: const Text('Save',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 13),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      alignment: Alignment.centerLeft,
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
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
                                  if (await isDeleted()) {
                                    Navigator.pop(context); // Close the dialog

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color.fromARGB(
                                                      255, 240, 240, 240),
                                                  Color.fromARGB(
                                                      255, 223, 223, 223),
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
                                  backgroundColor:
                                      const Color.fromARGB(255, 184, 13, 1),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
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
                backgroundColor: const Color.fromARGB(255, 193, 34,
                    23), // Set the button's background color to red
                padding: const EdgeInsets.symmetric(horizontal: 120),
              ),
              child: const Text('Delete My Account',
                  style: TextStyle(fontWeight: FontWeight.w800)),
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

    final List<String> selectedInterests = List<String>.from(
        _loggedInInterests); // Store the selected interests outside of the dialog

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
        newUserInterests = result;
      });
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
        _loggedInSkills); // Store the selected skills outside of the dialog

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
    if (newUsername == _loggedInUsername) {
      return true;
    } else if (newUsername.length < 6) {
      toastMessage('Username should be at least 6 characters long.');
      return false;
    } else if (newUsername.contains(' ')) {
      toastMessage('Username should not contain spaces.');
      return false;
    } else if (newUsername.contains(RegExp(r'^\d+$'))) {
      toastMessage('Username should not contain only digits');
      return false;
    } else if (newUsername != _loggedInUsername) {
      bool usernameExists = await checkUsernameExists(newUsername);
      if (usernameExists) {
        toastMessage(
            'Username is already taken. Please choose a different one.');
        return false;
      } else {
        // Username is valid and not already taken, perform the save operation
        if (await updateUsernameByEmail()) {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> checkUsernameExists(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('RegularUser')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> updateUsernameByEmail() async {
    setState(() {
      _isLoading = true;
    });
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('RegularUser')
        .where('email', isEqualTo: _loggedInEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String userId = userDoc.id;

      await FirebaseFirestore.instance
          .collection('RegularUser')
          .doc(userId)
          .update({
        'username': newUsername,
      });
    }
    setState(() {
      _isLoading = false;
    });
    isModified = true;
    return true;
  }

  Future<bool> validatePassword() async {
    // Check if the new password is equal to the existing password
    if (newPassword == '' || hashPassword(newPassword) == _loggedInPassword) {
      return true; // Nothing changed (user doesn't want to modify)
    } else
    // Check password length
    if (newPassword.length < 6) {
      toastMessage('Password should not be less than 6 characters.');
      return false;
    } else
    // Check for white spaces in the password
    if (newPassword.contains(' ')) {
      toastMessage('Password should not contain spaces.');
      return false;
    } else
    // Update the password in the database and Firebase Authentication
    if (await updatePasswordByEmail()) {
      return true;
    }

    return false;
  }

  Future<bool> updatePasswordByEmail() async {
    setState(() {
      _isLoading = true;
    });
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('RegularUser')
        .where('email', isEqualTo: _loggedInEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String userId = userDoc.id;
      final String hashedPassword =
          hashPassword(newPassword); // Hash the new password

      await FirebaseFirestore.instance
          .collection('RegularUser')
          .doc(userId)
          .update({'password': hashedPassword});

      // Update password in Firebase Authentication
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await user.updatePassword(newPassword);
          setState(() {
            _isLoading = false;
          });
          isModified = true;
          return true;
        } catch (e) {}
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
    if (newCountry == _loggedInCountry &&
        newState == _loggedInState &&
        newCity == _loggedInCity) {
      return true;
    } else
    // Check country is entered length
    if (newCountry.isEmpty) {
      toastMessage('Choose your country please');
      return false;
    } else if (await updateCSC()) return true;
    return false;
  }

  Future<bool> updateCSC() async {
    setState(() {
      _isLoading = true;
    });
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('RegularUser')
        .where('email', isEqualTo: _loggedInEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String userId = userDoc.id;

      await FirebaseFirestore.instance
          .collection('RegularUser')
          .doc(userId)
          .update({
        'country': newCountry,
        'city': newCity,
        'state': newState,
      });
    }
    setState(() {
      _isLoading = false;
    });
    isModified = true;
    return true;
  }

  Future<bool> validateUserType() async {
    if (newUserType == _loggedInUserType) {
      return true;
    } else if (newUserSkills.isEmpty && newUserType == 'Freelancer') {
      toastMessage('Please enter your skills');
      return false;
    } else if (await updateUserType()) return true;
    return false;
  }

  Future<bool> updateUserType() async {
    setState(() {
      _isLoading = true;
    });
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('RegularUser')
        .where('email', isEqualTo: _loggedInEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String userId = userDoc.id;

      await FirebaseFirestore.instance
          .collection('RegularUser')
          .doc(userId)
          .update({
        'userType': newUserType,
      });
    }
    setState(() {
      _isLoading = false;
    });
    isModified = true;
    return true;
  }

  Future<bool> validateUserPreference() async {
    if (newUserPreference == _LoggedInPreference) {
      return true;
    } else if (await updateUserPreference()) return true;
    return false;
  }

  Future<bool> updateUserPreference() async {
    setState(() {
      _isLoading = true;
    });
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('RegularUser')
        .where('email', isEqualTo: _loggedInEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String userId = userDoc.id;

      await FirebaseFirestore.instance
          .collection('RegularUser')
          .doc(userId)
          .update({
        'attendancePreference': newUserPreference,
      });
    }
    setState(() {
      _isLoading = false;
    });
    isModified = true;
    return true;
  }

  Future<bool> validateInterests() async {
    if (newUserInterests == _loggedInInterests) {
      return true;
    } else if (newUserInterests.isEmpty) {
      toastMessage('Please enter your interests');
      return false;
    }
    if (await updateInterests()) {
      return true;
    }
    return false;
  }

  Future<bool> updateInterests() async {
    setState(() {
      _isLoading = true;
    });
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('RegularUser')
        .where('email', isEqualTo: _loggedInEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String userId = userDoc.id;

      await FirebaseFirestore.instance
          .collection('RegularUser')
          .doc(userId)
          .update({
        'interests': newUserInterests,
      });
    }
    setState(() {
      _isLoading = false;
    });
    isModified = true;
    return true;
  }

  Future<bool> validateSkills() async {
    if (newUserSkills == _loggedInSkills) {
      return true;
    } else if (newUserSkills.isEmpty && newUserType == 'Freelancer') {
      toastMessage('Please enter your skills');
      return false;
    } else if (await updateSkills())
      return true;
    else
      return false;
  }

  Future<bool> updateSkills() async {
    setState(() {
      _isLoading = true;
    });
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('RegularUser')
        .where('email', isEqualTo: _loggedInEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String userId = userDoc.id;

      await FirebaseFirestore.instance
          .collection('RegularUser')
          .doc(userId)
          .update({
        'skills': newUserSkills,
      });
    }
    setState(() {
      _isLoading = false;
    });
    isModified = true;
    return true;
  }

  Future<bool> validateGithubLink() async {
    if (newGithubLink == _loggedInGithub) {
      return true;
    } else if (newGithubLink.isNotEmpty &&
        !newGithubLink.startsWith("https://github.com/")) {
      toastMessage('Invalid GitHub link');
      return false;
    } else {
      if (await updateGithubLink()) {
        return true;
      }
      return false;
    }
  }

  Future<bool> updateGithubLink() async {
    setState(() {
      _isLoading = true;
    });
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('RegularUser')
        .where('email', isEqualTo: _loggedInEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String userId = userDoc.id;

      await FirebaseFirestore.instance
          .collection('RegularUser')
          .doc(userId)
          .update({
        'githubLink': newGithubLink,
      });
    }
    setState(() {
      _isLoading = false;
    });
    isModified = true;
    return true;
  }

  Future<bool> validateUserPic() async {
    if (newProfilePicture == null) {
      return true;
    } else {
      return await updateProfilePicture(_loggedInUID);
    }
  }

  Future<bool> updateProfilePicture(String userId) async {
    try {
      setState(() {
        _isLoading = true;
      });
      // Upload the new profile picture to Firebase Storage
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('user_images/$userId.jpg');
      final UploadTask uploadTask = storageRef.putFile(newProfilePicture!);
      final TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // Update the imageURL field in Firebase Firestore
      await FirebaseFirestore.instance
          .collection('RegularUser')
          .doc(userId)
          .update({
        'imageURL': downloadURL,
      });

      // Update the local user object
      setState(() {
        _isLoading = false;
      });
      _loggedInimageURL = downloadURL;
      isModified = true;

      return true;
    } catch (e) {
      toastMessage('An error occurred while trying to change your picture');
      return false;
    }
  }

  Future<bool> isDeleted() async {
    setState(() {
      _isLoading = true;
    });

    // Delete user from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete();
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('RegularUser')
        .where('email', isEqualTo: _loggedInEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          snapshot.docs.first;
      final String userId = userDoc.id;

      // Delete user document from Firestore
      await FirebaseFirestore.instance
          .collection('RegularUser')
          .doc(userId)
          .delete();

      // Delete user's name questions, team requests, and projects
      await FirebaseFirestore.instance
          .collection('Project')
          .where('userId', isEqualTo: _loggedInEmail)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({'userId': 'DeactivatedUser'});
        });
      });
            // Delete user's name questions, team requests, and projects
      await FirebaseFirestore.instance
          .collection('Question')
          .where('userId', isEqualTo: _loggedInEmail)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({'userId': 'DeactivatedUser'});
        });
      });

      // Delete user's name questions, team requests, and projects
      await FirebaseFirestore.instance
          .collection('Team')
          .where('userId', isEqualTo: _loggedInEmail)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({'userId': 'DeactivatedUser'});
        });
      });

      // Delete user's name questions, team requests, and projects
      await FirebaseFirestore.instance
          .collection('Answer')
          .where('userId', isEqualTo: _loggedInEmail)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({'userId': 'DeactivatedUser'});
        });
      });

      setState(() {
        _isLoading = false;
      });
      return true;
    }
    setState(() {
      _isLoading = false;
    });
    toastMessage('An error occurred while trying to delete your account');
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

  void _showSnackBar2(String message) {
    double snackBarHeight = 510; // Customize the height of the snackbar

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.only(
          bottom: snackBarHeight +
              180, // Add the snackbar height and some additional margin
          right: 20,
          left: 20,
        ),
        backgroundColor:
            Color.fromARGB(255, 12, 118, 51), // Customize the background color
      ),
    );
  }
}

 