import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mentee_details_page.dart'; // Ensure this import is correct

class MentorHomePage extends StatefulWidget {
  @override
  _MentorHomePageState createState() => _MentorHomePageState();
}

class _MentorHomePageState extends State<MentorHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String mentorName = '';
  List<Map<String, dynamic>> mentees = [];
  final TextEditingController _rollNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMentorDetails();
    _fetchMentees();
  }

  // Fetch the mentor details from Firestore
  Future<void> _fetchMentorDetails() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot mentorDoc = await _firestore.collection('mentors').doc(user.uid).get();

      if (mentorDoc.exists) {
        setState(() {
          mentorName = (mentorDoc.data() as Map<String, dynamic>)['username'] ?? 'Mentor';
        });
      }
    }
  }

  // Fetch mentees assigned to this mentor
  Future<void> _fetchMentees() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Fetch mentees from the 'mentoring' collection under the current mentor's document
      DocumentSnapshot mentoringDoc = await _firestore.collection('mentoring').doc(user.uid).get();

      if (mentoringDoc.exists) {
        setState(() {
          mentees = List<Map<String, dynamic>>.from((mentoringDoc.data() as Map<String, dynamic>)['mentees'] ?? []);
        });
      }
    }
  }

  // Function to add a mentee via roll number
  Future<void> _addMentee() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String rollNumber = _rollNumberController.text.trim();

      // Check if mentee exists in the mentees collection
      QuerySnapshot menteeQuery = await _firestore.collection('mentees').where('rollNumber', isEqualTo: rollNumber).get();

      if (menteeQuery.docs.isNotEmpty) {
        DocumentSnapshot menteeDoc = menteeQuery.docs.first;
        var menteeData = menteeDoc.data() as Map<String, dynamic>;
        String menteeId = menteeDoc.id;

        // Check if this mentee is already assigned to a mentor
        if (menteeData.containsKey('mentorId') && menteeData['mentorId'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("This mentee is already assigned to a mentor.")),
          );
        } else {
          // Assign the mentee to the current mentor
          User? currentMentor = _auth.currentUser;
          if (currentMentor != null) {
            // Update mentee's mentorId in the mentees collection
            await _firestore.collection('mentees').doc(menteeId).update({
              'mentorId': currentMentor.uid,
            });

            // Add mentee details under the mentor's document in the mentoring collection
            DocumentReference mentoringDoc = _firestore.collection('mentoring').doc(currentMentor.uid);

            DocumentSnapshot docSnapshot = await mentoringDoc.get();

            if (docSnapshot.exists) {
              // Update the existing mentees array
              await mentoringDoc.update({
                'mentees': FieldValue.arrayUnion([
                  {
                    'username': menteeData['username'],
                    'rollNumber': menteeData['rollNumber'],
                    'email': menteeData['email'],
                    'uid': menteeId,  // Store the UID of the mentee
                  }
                ])
              });
            } else {
              // Create a new mentoring document if it doesn't exist
              await mentoringDoc.set({
                'mentees': [
                  {
                    'username': menteeData['username'],
                    'rollNumber': menteeData['rollNumber'],
                    'email': menteeData['email'],
                    'uid': menteeId,  // Store the UID of the mentee
                  }
                ]
              });
            }

            // Fetch the updated list of mentees
            _fetchMentees();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Mentee added successfully!")),
            );
          }
        }
      } else {
        // Mentee doesn't exist
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mentee not signed up yet.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _rollNumberController.clear();
      });
    }
  }

  // Function to navigate to mentee details
 Future<void> _viewMenteeDetails(String rollNumber) async {
  User? user = _auth.currentUser;

  if (user != null) {
    // Fetch the mentoring document for the current mentor
    DocumentSnapshot mentoringDoc = await _firestore.collection('mentoring').doc(user.uid).get();

    if (mentoringDoc.exists) {
      List<dynamic> menteesList = (mentoringDoc.data() as Map<String, dynamic>)['mentees'] ?? [];
      // Find the mentee by roll number and get their UID
      String? menteeUid;

      for (var mentee in menteesList) {
        if (mentee['rollNumber'] == rollNumber) {
          menteeUid = mentee['uid'];
          break;
        }
      }

      if (menteeUid != null) {
        // Navigate to the MenteeDetailsPage with the mentee's UID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenteeDetailsPage(menteeId: menteeUid!), // Use menteeUid! to convert to non-nullable
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mentee not found.")),
        );
      }
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentor Home'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mentor's Name
            Text(
              'Welcome, $mentorName',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // List of Mentees under this mentor
            Text(
              'Mentees:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: mentees.isNotEmpty
                  ? ListView.builder(
                      itemCount: mentees.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(mentees[index]['username']),
                          subtitle: Text(mentees[index]['rollNumber']),
                          trailing: ElevatedButton(
                            onPressed: () => _viewMenteeDetails(mentees[index]['rollNumber']),
                            child: Text('View'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              backgroundColor: Colors.deepPurple,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text("No mentees assigned yet."),
                    ),
            ),
            SizedBox(height: 20),

            // Add Mentee Section
            TextField(
              controller: _rollNumberController,
              decoration: InputDecoration(
                labelText: 'Enter Mentee Roll Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),

            // Add Mentee Button
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _addMentee,
                    child: Text('Add Mentee'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
