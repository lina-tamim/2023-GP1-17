import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import 'package:techxcel11/pages/UserPages/HomePage.dart';

class FormWidget extends StatefulWidget {
  const FormWidget({Key? key}) : super(key: key);

  @override
  _FormWidgetState createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  int count = 0;
  int iid = 0;
  String? dropdownValue;

  String textFieldValue = '';
  String largeTextFieldValue = '';
  DateTime? selectedDate;

  String? _selectedPostType = 'Question';
  Map<String, String> postTypeData = {
    'Question': 'Enter Question Title',
    'Team Collaberation': 'Enter Team Collaboration Title',
    'Project': 'Enter Project Title',
  };

  Map<String, String> postTypeDescription = {
    'Question': 'Enter your question here',
    'Team Collaberation': 'Enter team needs here',
    'Project': 'Enter project details here',
  };

  Map<String, String> postTypeTopics = {
    'Question': 'Post Topic',
    'Team Collaberation': 'Skills Needed',
    'Project': 'Skills Needed',
  };

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Please select a date.';
    }
    return null;
  }

  String? validateTopics(List<String> selectedTopics) {
    if (selectedTopics.isEmpty) {
      return 'Please select at least one topic';
    }
    return null;
  }

  Completer<List<String>> _selectedTopicCompleter = Completer<List<String>>();
  List<String> _selectedTopics = [];

  void _showMultiSelectTopics() async {
    final Map<String, List<String>> topicGroups = {
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

    final List<String> items = topicGroups.keys.toList();
    final List<String> selectedTopics = List<String>.from(
        _selectedTopics); 

    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        final List<String> chosenTopics = List<String>.from(selectedTopics);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select From Categories'),
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
                          ...topicGroups[group]!.map((String topic) {
                            return CheckboxListTile(
                              title: Text(topic),
                              value: chosenTopics.contains(topic),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    chosenTopics.add(topic);
                                  } else {
                                    chosenTopics.remove(topic);
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
                    Navigator.of(context).pop(chosenTopics);
                    if (validateTopics(chosenTopics) == null) {
                      _selectedTopicCompleter.complete(chosenTopics);
                    } else {
                      _selectedTopicCompleter.complete(null);
                    }
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
        _selectedTopics = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_outlined,
                        color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 85),
                      child: Text(
                        "Add post",
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Poppins",
                            color:
                                Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 7),
                  child: Text(
                    'Ask, Connect, Achieve: Empowering Starts Here! ',
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Post Type',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
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
                          '\nQuestions: Ask TechXcel community.\n\nTeam collaberation: Find and build your team.\n\nProjects: Post your projects to get help from TechXcel community.',
                      padding: EdgeInsets.all(20),
                      showDuration: Duration(seconds: 3),
                      textStyle: TextStyle(color: Colors.white),
                      preferBelow: false,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedPostType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPostType = newValue;
                    });
                  },
                  validator: (value) {
                    // if (value == null) {
                    //   return 'Please select an option.';
                    // }
                    return null;
                  },
                  items: postTypeData.keys.map((String postType) {
                    return DropdownMenuItem<String>(
                      value: postType,
                      child: Text(postType),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.arrow_downward,
                        color: const Color.fromARGB(255, 63, 12, 118)),
                    labelText: 'Post Type',
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
                    hintText: "Post",
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Text(
                      'Title',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
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
                const SizedBox(height: 8),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      textFieldValue = value;
                    });
                  },
                  validator: (value) {
                    return null;
                  },
                  cursorColor: const Color.fromARGB(255, 43, 3, 101),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.title,
                        color: const Color.fromARGB(255, 63, 12, 118)),
                    labelText: postTypeData[_selectedPostType],
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
                    hintText: "Title",
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
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
                const SizedBox(height: 8),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      largeTextFieldValue = value;
                    });
                  },
                  validator: (value) {
                    return null;
                  },
                  maxLines: 5,
                  cursorColor: const Color.fromARGB(255, 43, 3, 101),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.book,
                        color: const Color.fromARGB(255, 63, 12, 118)),
                    labelText: postTypeDescription[_selectedPostType],
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
                    hintText: "Description",
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Text(
                      'Skill/s',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
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
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    _showMultiSelectTopics();
                    final List<String>? selected =
                        await _selectedTopicCompleter.future;
                    if (selected != null) {
                      setState(() {
                        _selectedTopics = selected;
                      });
                    }
                  },
                  child: Text('${postTypeTopics[_selectedPostType]}'),
                ),
                const Divider(
                  height: 10,
                ),
                Wrap(
                  children: _selectedTopics
                      .map((e) => Chip(
                            label: Text(e),
                          ))
                      .toList(),
                ),
                if (_selectedPostType == 'Team Collaberation' ||
                    _selectedPostType == 'Project') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Deadline Date',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
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
                  const SizedBox(height: 8),
                  TextFormField(
                    readOnly: true,
                    controller: _dateController,
                    onTap: () async {
                      await _selectDate(context);
                    },
                    validator: (value) {
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.calendar_month,
                          color: const Color.fromARGB(255, 63, 12, 118)),
                      labelText: "Select Date",
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
                      hintText: selectedDate != null
                          ? selectedDate.toString().split(' ')[0]
                          : 'Select a date',
                    ),
                  ),
                ],
                SizedBox(height: 16.0),
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        final email = prefs.getString('loggedInEmail') ?? '';
                        _submitForm(email);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(37, 6, 81, 0.898),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 10,
                        shadowColor:
                            Color.fromARGB(255, 0, 0, 0).withOpacity(1),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm(String userId) async {
    final String? interestsValidation = validateTopics(_selectedTopics);

    bool isDateRequired = _selectedPostType == 'Team Collaberation' ||
        _selectedPostType == 'Project';

    // Get the current date
    DateTime currentDate = DateTime.now();

    if (_selectedPostType == null) {
      toastMessage('Please select an option.');
    } else if (textFieldValue.isEmpty) {
      toastMessage('Please enter a title');
    } else if (largeTextFieldValue.isEmpty) {
      toastMessage('Description is required');
    } else if (largeTextFieldValue.length > 1024) {
      toastMessage(
          'Maximum character limit exceeded (1024 characters) in description.');
    } else if (isDateRequired && _dateController.text.isEmpty) {
      toastMessage('Please select a date');
    } else if (isDateRequired &&
        (selectedDate == null || selectedDate!.isBefore(currentDate))) {
      toastMessage("Please enter a valid date");
    } else if (_selectedTopics.isEmpty) {
      toastMessage(interestsValidation ?? 'Invalid data');
    } else {


      DateTime postDate = DateTime.now();
      if (_selectedPostType == 'Question') {
        final questionCollection =
            FirebaseFirestore.instance.collection('Question');
        final newFormDoc = questionCollection.doc();

        await questionCollection.doc(newFormDoc.id).set({
          'userId': userId,
          'postTitle': textFieldValue,
          'postDescription': largeTextFieldValue[0].toUpperCase() +
              largeTextFieldValue.substring(1),
          'selectedInterests': _selectedTopics,
          'noOfAnwers': count,
          'postedDate': postDate,
          'questionDocId': newFormDoc.id,
        });
      } else if (_selectedPostType == 'Team Collaberation') {
        final teamCollabCollection =
            FirebaseFirestore.instance.collection('Team');
        final newFormDoc = teamCollabCollection.doc();
        await teamCollabCollection.doc(newFormDoc.id).set({
          'userId': userId,
          'postTitle': textFieldValue,
          'postDescription': largeTextFieldValue,
          'deadlineDate': selectedDate,
          'selectedInterests': _selectedTopics,
          'postedDate': postDate,
          'teamDocId': newFormDoc.id,
        });
      } else if (_selectedPostType == 'Project') {
        final formCollection = FirebaseFirestore.instance.collection('Project');
        final newFormDoc = formCollection.doc();
        final projectCollection =
            FirebaseFirestore.instance.collection('Project');
        await projectCollection.doc(newFormDoc.id).set({
          'userId': userId,
          'postTitle': textFieldValue,
          'postDescription': largeTextFieldValue,
          'deadlineDate': selectedDate,
          'selectedInterests': _selectedTopics,
          'postedDate': postDate,
          'teamDocId': newFormDoc.id,
        });
      }

      setState(() {
        dropdownValue = null;
        textFieldValue = '';
        largeTextFieldValue = '';
        selectedDate = null;
        _selectedTopics.clear();
      });
      toastMessage(interestsValidation ?? 'Form submitted successfully!');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FHomePage()),
      );
    }
  }
}
