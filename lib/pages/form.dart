import 'dart:async';

import 'package:techxcel11/pages/homePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
//import 'package:database1/freelancerhomepage.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FormWidget extends StatefulWidget {
  const FormWidget({Key? key}) : super(key: key);

  @override
  _FormWidgetState createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  int count = 0;
  int id = 0;
   String? dropdownValue ;
  String textFieldValue = '';
  String largeTextFieldValue = '';
  DateTime? selectedDate ;

  String? _selectedPostType;
String _postTypeDescription = 'Question';
String _postTypeTopic = 'Question';
 Map<String, String> postTypeData = {
  
    'Question': 'Question',
    'Team Collab': 'Team Collaboration',
    'Freelancer': 'Freelancer',
  };

   Map<String, String> postTypeDescription = {
    'Question': 'Enter your question here',
    'Team Collab': 'Enter team needs here',
    'Freelancer': 'Enter project details here',
  };

    Map<String, String> postTypeTopics = {
      
    'Question': 'Post Topic',
    'Team Collab': 'Skills Needed',
    'Freelancer': 'Skills Needed',
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

Completer<List<String>> _selectedInterestsCompleter = Completer<List<String>>();
  List<String> _selectedInterests = [];
//topics method
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

  final List<String> selectedInterests = List<String>.from(_selectedInterests); // Store the selected interests outside of the dialog

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
                  if (validateInterests(chosenInterests) == null) {
    _selectedInterestsCompleter.complete(chosenInterests);
  } else {
    _selectedInterestsCompleter.complete(null);
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
      _selectedInterests = result;
});
}
}

String? validateInterests(List<String> selectedInterests) {
  if (selectedInterests.isEmpty) {
    return 'Please select at least one interest';
  }
  return null;
}

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Form'),
      ),
      body: KeyboardDismisser(
      child:Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
        child: Column(
           children: [
          const SizedBox(height: 16),

                      const Text(
                        'Post Type',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                     
                    DropdownButtonFormField<String>(
  value: _selectedPostType,
 onChanged: (String? newValue) {
  setState(() {
    _selectedPostType = newValue!;
  });
},
 validator: (value) {
    if (value == null) {
      return 'Please select an option.';
    }
    return null;
  },
  items: postTypeData.keys.map((String postType) {
    return DropdownMenuItem<String>(
      value: postType,
      child: Text(postType),
    );
  }).toList(),
),
            SizedBox(height: 16.0),
            Text( 
                        'Title',
                        style: TextStyle(
                          fontSize: 16,
                        ),),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  textFieldValue = value;
                });
    
              },
          validator: (value) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    return null;
  },
              decoration: InputDecoration(
       prefixIcon: const Icon(Icons.title, color: Color.fromARGB(255, 212, 178, 248)),

      labelText: postTypeData[_selectedPostType],
      labelStyle: TextStyle(
        color: const Color.fromARGB(255, 60, 6, 99).withOpacity(0.9),
      ),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: const Color.fromARGB(255, 200, 176, 185).withOpacity(0.3) ,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
      hintText:"Title",
      
      
    ),
            ),
            const SizedBox(height: 16),
                      Text( //NEEDS TO BE VALIDATED + MAKE IT LARGER
                        '${postTypeData[_selectedPostType]}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
            TextFormField(

              onChanged: (value) {
                setState(() {
                  largeTextFieldValue = value;
                });
              },
              validator: (value) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    if (value.length > 1024) {
      return 'Maximum character limit exceeded (1024 characters).';
    }
    return null;
  },
              maxLines: 5,
                              decoration: InputDecoration(
       prefixIcon: const Icon(Icons.title, color: Color.fromARGB(255, 212, 178, 248)),

      labelText: postTypeDescription[_selectedPostType],
      labelStyle: TextStyle(
        color: const Color.fromARGB(255, 60, 6, 99).withOpacity(0.9),
      ),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: const Color.fromARGB(255, 200, 176, 185).withOpacity(0.3) ,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
      hintText:"Description",
      
      
    ),
            ),
const SizedBox(height: 16),
             Text(
                          '${postTypeTopics[_selectedPostType]}:',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
 ElevatedButton(
  onPressed: () async {
    _showMultiSelectInterests();
    final List<String>? selected = await _selectedInterestsCompleter.future;
    if (selected != null) {
      setState(() {
        _selectedInterests = selected;
      });
    }
  },
  child: Text('${postTypeTopics[_selectedPostType]}'),
),
                
               

           

                 if (_selectedPostType == 'Team Collab' || _selectedPostType == 'Freelancer') ...[
  const SizedBox(height: 16),
  const Text(
    'Deadline Date',
   style: TextStyle(
    fontSize: 16,
    ),
  ),
  const SizedBox(height: 8),
  
  TextFormField(
  
    readOnly: true,
    controller: _dateController,

    onTap: () async {
    await _selectDate(context);
  },
  validator: (value) {
    if (_dateController.text.isEmpty) {
      return 'Please select a date';
    }
    return null;
  },
    decoration: InputDecoration(
       prefixIcon: const Icon(Icons.calendar_month, color: Color.fromARGB(255, 212, 178, 248)),

      labelText: "Select Date",
      labelStyle: TextStyle(
        color: const Color.fromARGB(255, 60, 6, 99).withOpacity(0.9),
      ),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: const Color.fromARGB(255, 200, 176, 185).withOpacity(0.3) ,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
      hintText: selectedDate != null
          ? selectedDate.toString().split(' ')[0]
          : 'Select a date',
      
    ),
   
    
  ),

                      ],

              

            
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                final email = prefs.getString('loggedInEmail') ??'';
                _submitForm(email);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),),),
    );
  }


  void _submitForm(String userId) async {
    final String? interestsValidation = validateInterests(_selectedInterests);
    if (_selectedInterests.isEmpty) {
      // ... Perform your form submission logic here
    
    // Selected interests are valid, continue with form submission

    // ... Perform your form submission logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(interestsValidation!),
        duration: Duration(seconds: 2),
      ),
    );

  }
    else if (_formKey.currentState!.validate()) {
      
    // Create a Firestore document reference
    final formCollection = FirebaseFirestore.instance.collection('posts');

    // Create a new document with auto-generated ID
    final newFormDoc = formCollection.doc();
    if(_selectedPostType == 'Question'){
    // Set the form data
    await newFormDoc.set({
      'userId': userId,
      'dropdownValue': _selectedPostType,
      'textFieldValue': textFieldValue,
      'largeTextFieldValue': largeTextFieldValue,
      'selectedInterests': _selectedInterests,
      'upvotecount': count,
      //number of answers
      'NoOfAnwers':count,
      'id':id,
      
    });}

    else{
      await newFormDoc.set({
      'userId': userId,
      'dropdownValue': _selectedPostType,
      'textFieldValue': textFieldValue,
      'largeTextFieldValue': largeTextFieldValue,
      'selectedDate': selectedDate,
      'selectedInterests': _selectedInterests,
      
      
    });
    }

   
      
    

    // Clear the form fields and selected date.
    setState(() {
      dropdownValue = null;
      textFieldValue = '';
      largeTextFieldValue = '';
      selectedDate = null;
      _selectedInterests.clear();
      id = id+1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form submitted successfully!')));

        Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => FHomePage()),
  );
  }}
}
