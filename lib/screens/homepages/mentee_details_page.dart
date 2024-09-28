import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenteeDetailsPage extends StatefulWidget {
  final String menteeId;

  MenteeDetailsPage({required this.menteeId});

  @override
  _MenteeDetailsPageState createState() => _MenteeDetailsPageState();
}

class _MenteeDetailsPageState extends State<MenteeDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? menteeDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenteeDetails();
  }

  // Fetch mentee details from Firestore
  Future<void> _fetchMenteeDetails() async {
    try {
      DocumentSnapshot menteeDoc = await _firestore.collection('mentees').doc(widget.menteeId).get();

      if (menteeDoc.exists) {
        setState(() {
          menteeDetails = menteeDoc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mentee not found.")),
        );
        Navigator.pop(context); // Go back if mentee not found
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching mentee details: ${e.toString()}")),
      );
    }
  }

  // Function to show task details in a dialog
  void _showTaskDetails(Map<String, dynamic> taskDetails, String taskTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$taskTitle Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: taskDetails.entries
                  .map((entry) => Text('${entry.key}: ${entry.value}'))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Helper function to check if a task is completed
  bool _isTaskCompleted(Map<String, dynamic>? task) {
    return task != null && (task['completed'] == true || task['status'] == 'completed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentee Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mentee Details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text('Username: ${menteeDetails?['username'] ?? 'N/A'}'),
                  Text('Roll Number: ${menteeDetails?['rollNumber'] ?? 'N/A'}'),
                  Text('Email: ${menteeDetails?['email'] ?? 'N/A'}'),
                  Text('Mentor ID: ${menteeDetails?['mentorId'] ?? 'N/A'}'),
                  SizedBox(height: 20),

                  // Task 1
                  _buildTaskRow('Task 1', menteeDetails?['task1'], 'task1'),

                  // Task 2
                  _buildTaskRow('Task 2', menteeDetails?['task2'], 'task2'),

                  // Task 3
                  _buildTaskRow('Task 3', menteeDetails?['task3'], 'task3'),
                ],
              ),
            ),
    );
  }

  // Function to build a task row
  Widget _buildTaskRow(String taskTitle, Map<String, dynamic>? taskDetails, String taskKey) {
    bool isTaskCompleted = _isTaskCompleted(taskDetails);

    return ListTile(
      title: Text(taskTitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTaskCompleted ? Icons.check : Icons.close,
            color: isTaskCompleted ? Colors.green : Colors.red,
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: taskDetails != null
                ? () => _showTaskDetails(taskDetails, taskTitle)
                : null, // Disable the button if taskDetails is null
            child: Text('View Details'),
          ),
        ],
      ),
      subtitle: taskDetails == null
          ? Text('$taskTitle not filled yet')
          : null, // If the task is null, show this message
    );
  }
}
