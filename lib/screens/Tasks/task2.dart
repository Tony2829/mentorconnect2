import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Task2Page extends StatefulWidget {
  @override
  _Task2PageState createState() => _Task2PageState();
}

class _Task2PageState extends State<Task2Page> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, double> _courseRatings = {}; // For course ratings
  double _canteenRating = 0;
  double _transportRating = 0;
  double _libraryRating = 0;

  List<dynamic>? _courses; // Store courses fetched from Task 1
  String? _menteeName;
  String? _mentorName;
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
          _courses = menteeData['task1']['courses'];
          _menteeName = menteeData['username']; // Assuming 'username' is the mentee's name
          // _mentorName = menteeData['mentor'] ?? 'Mentor not assigned yet'; // Mentor name
          _loading = false;

          // Initialize ratings for courses
          for (var course in _courses!) {
            _courseRatings[course] = 0;
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

  Future<void> _submitFeedback() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    String userId = currentUser.uid;

    // Create a map with task 2 feedback details
    Map<String, dynamic> task2Details = {
      'courseFeedback': _courseRatings,
      'canteenRating': _canteenRating,
      'transportRating': _transportRating,
      'libraryRating': _libraryRating,
    };

    // Update the task 2 details in the mentee document
    await _firestore.collection('mentees').doc(userId).update({
      'task2': task2Details,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Feedback submitted successfully!")),
    );

    // Optionally clear the fields after submission
    _clearFields();
  }

  void _clearFields() {
    setState(() {
      _courseRatings.clear();
      _canteenRating = 0;
      _transportRating = 0;
      _libraryRating = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task 2: Course Feedback'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display mentee and mentor name at the top
                    Text(
                      "Mentee: $_menteeName",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // SizedBox(height: 10),
                    // Text(
                    //   "Mentor: $_mentorName",
                    //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    // ),
                    SizedBox(height: 20),

                    // Display course feedback if courses are available
                    if (_courses != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Course Feedback:",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          for (var course in _courses!)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(course, style: TextStyle(fontSize: 16)),
                                RatingBar.builder(
                                  initialRating: _courseRatings[course] ?? 0,
                                  minRating: 0,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemPadding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    setState(() {
                                      _courseRatings[course] = rating;
                                    });
                                  },
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                        ],
                      ),

                    SizedBox(height: 20),

                    // Other feedback section
                    Text(
                      "Other Feedback:",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),

                    Text("Canteen Rating"),
                    RatingBar.builder(
                      initialRating: _canteenRating,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _canteenRating = rating;
                        });
                      },
                    ),
                    SizedBox(height: 10),

                    Text("Transport Rating"),
                    RatingBar.builder(
                      initialRating: _transportRating,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _transportRating = rating;
                        });
                      },
                    ),
                    SizedBox(height: 10),

                    Text("Library Rating"),
                    RatingBar.builder(
                      initialRating: _libraryRating,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _libraryRating = rating;
                        });
                      },
                    ),
                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _submitFeedback,
                      child: Text('Submit Feedback'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
