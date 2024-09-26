
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentor_connect/screens/authenticaton/signup.dart';
import 'package:mentor_connect/screens/homepages/mentee_homepage.dart';

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
      routes: {
        '/': (context) => LoginPage(),
        // '/mentee_home': (context) => MenteeHomePageWidget(),
        '/signup' :(context) => SignUpPage(),
         // '/mentor_home': (context) => MentorHomePage(),
      },
    );
  }
}
