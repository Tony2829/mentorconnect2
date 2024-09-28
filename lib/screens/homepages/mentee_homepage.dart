import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenteeHomePage extends StatefulWidget {
  @override
  _MenteeHomePageState createState() => _MenteeHomePageState();
}

class _MenteeHomePageState extends State<MenteeHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String menteeName = '';
  String mentorName = 'Mentor not assigned yet';
  bool isMentorAssigned = false;
  bool isTask1Filled = false;
  bool isTask2Filled = false;
  bool isTask3Filled = false;

  @override
  void initState() {
    super.initState();
    _fetchMenteeDetails();
  }

  // Fetch mentee details from Firestore
  Future<void> _fetchMenteeDetails() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot menteeDoc = await _firestore.collection('mentees').doc(user.uid).get();

      if (menteeDoc.exists) {
        var menteeData = menteeDoc.data() as Map<String, dynamic>;
        setState(() {
          menteeName = menteeData['username'] ?? 'Mentee';
          isTask1Filled = menteeData.containsKey('task1'); // Check if Task 1 is filled
          isTask2Filled = menteeData.containsKey('task2'); // Check if Task 2 is filled
          isTask3Filled = menteeData.containsKey('task3'); // Check if Task 3 is filled

          // Check if mentor is assigned
          if (menteeData.containsKey('mentorId') && menteeData['mentorId'] != null) {
            isMentorAssigned = true;
            mentorName = "Fetching mentor name...";

            // Fetch mentor's name
            _fetchMentorName(menteeData['mentorId']);
          }
        });
      }
    }
  }

  Future<void> _fetchMentorName(String mentorId) async {
    DocumentSnapshot mentorDoc = await _firestore.collection('mentors').doc(mentorId).get();
    if (mentorDoc.exists) {
      setState(() {
        mentorName = (mentorDoc.data() as Map<String, dynamic>)['username'] ?? 'Mentor not assigned yet';
      });
    }
  }

  // Function to navigate to a task
  void _navigateToTask(String taskRoute) {
    Navigator.pushNamed(context, taskRoute).then((_) => _fetchMenteeDetails()); // Fetch details after task submission
  }

  // Helper method to build task buttons
  Widget _buildTaskButton(String taskName, bool isTaskFilled, bool isTaskEnabled, String taskRoute) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isTaskEnabled
                  ? () => _navigateToTask(taskRoute)
                  : null, // Pass null if task is not enabled
              child: Text(taskName),
              style: ElevatedButton.styleFrom(
                backgroundColor: isTaskEnabled ? Colors.teal : Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            if (isTaskFilled) // Show tick mark if the task is filled
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 30,
                ),
              ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentee Home'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mentee's Name
            Text(
              'Welcome, $menteeName',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),

            // Mentor's Name
            Text(
              'Assigned Mentor: $mentorName',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // Task Buttons with tick mark and centered design
            Text(
              'Tasks Assigned:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Button for Task 1 (Centered with tick mark if completed)
            _buildTaskButton(
              'Task 1',
              isTask1Filled,
              isMentorAssigned, // Task 1 enabled if mentor is assigned
              '/task1',
            ),

            // Button for Task 2 (Enabled after Task 1 is filled)
            _buildTaskButton(
              'Task 2',
              isTask2Filled,
              isTask1Filled, // Task 2 enabled if Task 1 is filled
              '/task2',
            ),

            // Button for Task 3 (Enabled after Task 2 is filled)
            _buildTaskButton(
              'Task 3',
              isTask3Filled,
              isTask2Filled, // Task 3 enabled if Task 2 is filled
              '/task3',
            ),
          ],
        ),
      ),
    );
  }
}
