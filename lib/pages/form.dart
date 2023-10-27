import 'dart:async';
import 'package:techxcel11/pages/FHome.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
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
  int iid = 0;
   String? dropdownValue ;
  String textFieldValue = '';
  String largeTextFieldValue = '';
  DateTime? selectedDate ;

String? _selectedPostType = 'Question';
String _postTypeDescription = 'Question';
String _postTypeTopic = 'Question';
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
    return 'Please select at least one Category';
  }
  return null;
}
Completer<List<String>> _selectedTopicCompleter = Completer<List<String>>();
  List<String> _selectedTopics = [];
//topics method
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

  final List<String> selectedTopics = List<String>.from(_selectedTopics); // Store the selected interests outside of the dialog

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
    return Scaffold(
      appBar: AppBar(
        title: Text('My Form'),
      ),
      body: KeyboardDismisser(
        child: SingleChildScrollView(
      child:Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
        child: Column(
          
          crossAxisAlignment: CrossAxisAlignment.start,
           children: [
          const SizedBox(height: 16),
              Row(
  children: [
    Text(
      'Post Type',
      style: TextStyle(
        color: const Color.fromARGB(255, 1, 9, 111).withOpacity(0.9),
        fontSize: 18,
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
    IconButton(
      icon: Icon(
        Icons.live_help_rounded,
        size: 18,
        color: Color.fromARGB(255, 178, 178, 178),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('\nQuestions: Ask TechXcel community.\n\nTeam collaberation: Find and build your team.\n\nProjects: Post your projects to get help from TechXcel community.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
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

  decoration: InputDecoration(
      prefixIcon: Icon(Icons.arrow_downward, color: const Color.fromARGB(255, 63, 12, 118)),
      labelText: 'Post Type',
      labelStyle: const TextStyle(
        color: Colors.black54,
      ),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: const Color.fromARGB(255, 228, 228, 228).withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      hintText:"Post",
    ),
),

   const SizedBox(height: 16),
            Row(
  children: [
    Text(
      'Title',
      style: TextStyle(
        color: const Color.fromARGB(255, 1, 9, 111).withOpacity(0.9),
        fontSize: 18,
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
  cursorColor: const Color.fromARGB(255, 43, 3, 101),
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.title, color: const Color.fromARGB(255, 63, 12, 118)),
      labelText: postTypeData[_selectedPostType],
      labelStyle: const TextStyle(
        color: Colors.black54,
      ),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: const Color.fromARGB(255, 228, 228, 228).withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      hintText:"Title",
    ),
            ),
            
            const SizedBox(height: 16),
               Row(
  children: [
    Text(
      'Description',
      style: TextStyle(
        color: const Color.fromARGB(255, 1, 9, 111).withOpacity(0.9),
        fontSize: 18,
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
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    if (value.length > 1024) {
      return 'Maximum character limit exceeded (1024 characters).';
    }
    return null;
  },
     maxLines: 5,
     cursorColor: const Color.fromARGB(255, 43, 3, 101),
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.book, color: const Color.fromARGB(255, 63, 12, 118)),
      labelText: postTypeDescription[_selectedPostType],
      labelStyle: const TextStyle(
        color: Colors.black54,
      ),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: const Color.fromARGB(255, 228, 228, 228).withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      hintText:"Description",
    ),
     
            ),
const SizedBox(height: 16),
 Row(
  children: [
    Text(
      'Categories',
      style: TextStyle(
        color: const Color.fromARGB(255, 1, 9, 111).withOpacity(0.9),
        fontSize: 18,
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

             
 ElevatedButton(
    onPressed: () async {
      _showMultiSelectTopics();
      final List<String>? selected = await _selectedTopicCompleter.future;
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
                            //_selectedPreference
                          ),
                          // Display the selected items
                          Wrap(
                            children:
                                _selectedTopics 
                                    .map((e) => Chip(
                                          label: Text(e),
                                        ))
                                    .toList(),
                          ),
             
               

           

  if (_selectedPostType == 'Team Collaberation' || _selectedPostType == 'Project') ...[
  const SizedBox(height: 16),
  Row(
  children: [
    Text(
      'Deadline Date',
      style: TextStyle(
        color: const Color.fromARGB(255, 1, 9, 111).withOpacity(0.9),
        fontSize: 18,
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
    if (_dateController.text.isEmpty) {
      return 'Please select a date';
    }
    return null;
  },

  decoration: InputDecoration(
      prefixIcon: Icon(Icons.calendar_month, color: const Color.fromARGB(255, 63, 12, 118)),
      labelText: "Select Date",
      labelStyle: const TextStyle(
        color: Colors.black54,
      ),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: const Color.fromARGB(255, 228, 228, 228).withOpacity(0.3),
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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final email = prefs.getString('loggedInEmail') ?? '';
        _submitForm(email);
      },
      style: ElevatedButton.styleFrom(
        primary: Color.fromARGB(255, 198, 180, 247),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 10,
        shadowColor: Color.fromARGB(255, 0, 0, 0).withOpacity(1),
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
      ),),),),
    );
  }


  void _submitForm(String userId) async {
    final String? interestsValidation = validateTopics(_selectedTopics);
    if (_selectedTopics.isEmpty) {
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
final formCollectionn = FirebaseFirestore.instance.collection('posts');
final snapshot = await formCollectionn.orderBy('id', descending: true).limit(1).get();

int id;
if (snapshot.docs.isEmpty) {
  // No existing documents, it's the first question
  id = 0;
} else {
  final lastDocument = snapshot.docs.first;
  final lastId = lastDocument['id'] as int;
  id = lastId + 1;
}
      
    // Create a Firestore document reference
    final formCollection = FirebaseFirestore.instance.collection('posts');

    // Create a new document with auto-generated ID
    final newFormDoc = formCollection.doc();
    DateTime postDate = DateTime.now();
    if(_selectedPostType == 'Question'){
       id = id+1;
       

    // Set the form data
    await newFormDoc.set({
      'userId': userId,
      'dropdownValue': _selectedPostType,
      'textFieldValue': textFieldValue,
      'largeTextFieldValue': largeTextFieldValue,
      'selectedInterests': _selectedTopics,
      'upvotecount': count,
      //number of answers
      'NoOfAnwers':count,
      'id':id,
      'postedDate': postDate,
      
    });}

    else{
      await newFormDoc.set({
      'userId': userId,
      'dropdownValue': _selectedPostType,
      'textFieldValue': textFieldValue,
      'largeTextFieldValue': largeTextFieldValue,
      'selectedDate': selectedDate,
      'selectedInterests': _selectedTopics,
      'postedDate': postDate,
      
      
    });
    }

  
      
    

    // Clear the form fields and selected date.
    setState(() {
      dropdownValue = null;
      textFieldValue = '';
      largeTextFieldValue = '';
      selectedDate = null;
      _selectedTopics.clear();
      
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form submitted successfully!')));

        Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => FHomePage()),
  );
  }}
}

//TECHXCEL-LINA
