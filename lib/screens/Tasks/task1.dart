import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Task1Page extends StatefulWidget {
  @override
  _Task1PageState createState() => _Task1PageState();
}

class _Task1PageState extends State<Task1Page> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers for input fields
  final TextEditingController _rollNumberController = TextEditingController(); // Controller for roll number input
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _coursesController = TextEditingController();
  String? _selectedDepartment;

  Future<void> _submitDetails() async {
    String rollNumber = _rollNumberController.text.trim(); // Get the roll number entered by the user

    if (rollNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter the roll number")),
      );
      return;
    }

    User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    // Fetch mentee document using roll number
    QuerySnapshot menteeSnapshot = await _firestore
        .collection('mentees')
        .where('rollNumber', isEqualTo: rollNumber)
        .get();

    if (menteeSnapshot.docs.isNotEmpty) {
      // Get the first matching mentee
      DocumentSnapshot menteeDoc = menteeSnapshot.docs.first;

      // Create a map with task 1 details
      Map<String, dynamic> task1Details = {
        'fullName': _fullNameController.text.trim(),
        'motherName': _motherNameController.text.trim(),
        'fatherName': _fatherNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'department': _selectedDepartment,
        'courses': _coursesController.text.trim().split(',').map((course) => course.trim()).toList(),
      };

      // Update the task 1 details in the mentee document
      await _firestore.collection('mentees').doc(menteeDoc.id).update({
        'task1': task1Details,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Details submitted successfully!")),
      );

      // Optionally, clear the fields
      _clearFields();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mentee not found with this roll number.")),
      );
    }
  }

  void _clearFields() {
    _rollNumberController.clear();
    _fullNameController.clear();
    _motherNameController.clear();
    _fatherNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _coursesController.clear();
    setState(() {
      _selectedDepartment = null; // Reset the selected department
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task 1'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Roll Number Input
              TextField(
                controller: _rollNumberController,
                decoration: InputDecoration(labelText: "Enter Roll Number"),
              ),
              SizedBox(height: 20),

              // Full Name Input
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: "Student's Full Name"),
              ),
              TextField(
                controller: _motherNameController,
                decoration: InputDecoration(labelText: "Mother's Name"),
              ),
              TextField(
                controller: _fatherNameController,
                decoration: InputDecoration(labelText: "Father's Name"),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Student's Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Student's Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: "Student's Address"),
              ),
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                hint: Text('Select Department'),
                items: ['CSE', 'AIML', 'CS', 'DS', 'IoT', 'ECE', 'EEE', 'CIVIL', 'ME'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDepartment = newValue;
                  });
                },
              ),
              TextField(
                controller: _coursesController,
                decoration: InputDecoration(labelText: "Courses (comma-separated)"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitDetails,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
