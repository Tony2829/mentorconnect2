import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Task3Page extends StatefulWidget {
  @override
  _Task3PageState createState() => _Task3PageState();
}

class _Task3PageState extends State<Task3Page> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<dynamic>? _courses; // Courses fetched from Task 1
  Map<String, String> _mid1Marks = {}; // Store Mid 1 marks
  Map<String, String> _mid2Marks = {}; // Store Mid 2 marks
  Map<String, String> _grades = {}; // Store End Semester grades
  String _sgpa = ''; // Store SGPA
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenteeDetails();
  }

  Future<void> _fetchMenteeDetails() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    String userId = currentUser.uid;

    // Fetch the mentee document from the mentees collection
    DocumentSnapshot menteeDoc =
        await _firestore.collection('mentees').doc(userId).get();

    if (menteeDoc.exists) {
      var menteeData = menteeDoc.data() as Map<String, dynamic>?;

      if (menteeData != null && menteeData.containsKey('task1')) {
        setState(() {
          _courses = menteeData['task1']['courses']; // Courses fetched from task1
          _loading = false;

          // Initialize empty values for marks and grades
          for (var course in _courses!) {
            _mid1Marks[course] = '';
            _mid2Marks[course] = '';
            _grades[course] = '';
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No courses found for this mentee.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mentee details not found.")),
      );
    }
  }

  Future<void> _submitTask3Details() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    String userId = currentUser.uid;

    // Create a map with task 3 details
    Map<String, dynamic> task3Details = {
      'mid1Marks': _mid1Marks,
      'mid2Marks': _mid2Marks,
      'endSemesterGrades': _grades,
      'sgpa': _sgpa,
    };

    // Update the task 3 details in the mentee document
    await _firestore.collection('mentees').doc(userId).update({
      'task3': task3Details,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Task 3 details submitted successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task 3: Marks & Grades'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mid 1 Marks Section
                    Text(
                      "Mid 1 Marks:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    for (var course in _courses!)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course),
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Enter Mid 1 marks for $course",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _mid1Marks[course] = value;
                              });
                            },
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 10),
                        ],
                      ),

                    SizedBox(height: 20),

                    // Mid 2 Marks Section
                    Text(
                      "Mid 2 Marks:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    for (var course in _courses!)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course),
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Enter Mid 2 marks for $course",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _mid2Marks[course] = value;
                              });
                            },
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 10),
                        ],
                      ),

                    SizedBox(height: 20),

                    // End Semester Grades Section
                    Text(
                      "End Semester Grades:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    for (var course in _courses!)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course),
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Enter grade for $course",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _grades[course] = value;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                        ],
                      ),

                    SizedBox(height: 20),

                    // SGPA Section
                    Text(
                      "SGPA:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Enter your SGPA",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _sgpa = value;
                        });
                      },
                      keyboardType: TextInputType.number,
                    ),

                    SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitTask3Details,
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
