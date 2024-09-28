import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentor_connect/screens/Tasks/task1.dart';
import 'package:mentor_connect/screens/Tasks/task2.dart';
import 'package:mentor_connect/screens/Tasks/task3.dart';
import 'package:mentor_connect/screens/authenticaton/signup.dart';
import 'package:mentor_connect/screens/homepages/mentee_details_page.dart';
import 'package:mentor_connect/screens/homepages/mentee_homepage.dart';
import 'package:mentor_connect/screens/homepages/mentor_homepage.dart';
import 'screens/authenticaton/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        // Handle dynamic routing
        if (settings.name == '/menteeDetails') {
          final String menteeId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => MenteeDetailsPage(menteeId: menteeId),
          );
        }
        // Default routing
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => LoginPage());
          case '/mentee_home':
            return MaterialPageRoute(builder: (context) => MenteeHomePage());
          case '/signup':
            return MaterialPageRoute(builder: (context) => SignUpPage());
          case '/mentor_home':
            return MaterialPageRoute(builder: (context) => MentorHomePage());
          case '/task1':
            return MaterialPageRoute(builder: (context) => Task1Page());
          case '/task2':
            return MaterialPageRoute(builder: (context) => Task2Page());
          case '/task3':
            return MaterialPageRoute(builder: (context) => Task3Page());
          default:
            return null; // Handle unknown routes
        }
      },
    );
  }
}
