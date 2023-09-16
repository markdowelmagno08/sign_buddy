// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:sign_buddy/actors.dart';
import 'package:sign_buddy/forgot_pass.dart';
import 'package:sign_buddy/modules/assessments/assess_one.dart';
import 'package:sign_buddy/modules/choose_language.dart';
import 'package:sign_buddy/modules/classify_as.dart';
import 'package:sign_buddy/modules/english_level.dart';
import 'package:sign_buddy/modules/get_started.dart';
import 'package:sign_buddy/modules/home_page.dart';
import 'package:sign_buddy/modules/lessons/alphabet/lessons/lesson_one.dart';
import 'package:sign_buddy/modules/lessons/alphabet/lessons/quiz_one.dart';
import 'package:sign_buddy/modules/lessons/color.dart';
import 'package:sign_buddy/modules/lessons/family.dart';
import 'package:sign_buddy/modules/lessons/numbers.dart';
import 'package:sign_buddy/modules/lessons/shape.dart';
import 'package:sign_buddy/modules/lessons/animals.dart';
import 'package:sign_buddy/modules/lessons/nature.dart';
import 'package:sign_buddy/modules/lessons/food.dart';
import 'package:sign_buddy/modules/lessons/time-and-days.dart';
import 'package:sign_buddy/modules/lessons/greeting.dart';

import 'package:sign_buddy/login_screen.dart';
import 'package:sign_buddy/sign_up.dart';
import 'package:sign_buddy/modules/lessons/alphabet/letters.dart';

import 'firebase_options.dart';
import 'modules/front_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sign Buddy',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: TextTheme(
            bodyLarge: TextStyle(
              fontFamily: 'FiraSans',
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            bodyMedium: TextStyle(
              fontFamily: 'FiraSans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            displayLarge: TextStyle(
              fontFamily: 'FiraSans',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            labelLarge: TextStyle(
              fontFamily: 'FiraSans',
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            // Add more text styles here as needed.
          ),
        ),
        initialRoute: '/',
        routes: {
          '/f': (context) => FrontPage(),
          '/actors': (context) => Actors(),
          '/One': (context) => AssessmentOne(),
          '/get_started': (context) => GetStartedPage(),
          '/signup': (context) => SignupPage(),
          '/chooseLanguage': (context) => ChooseLanguages(),
          '/classify': (context) => Classify(),
          '/langLevel': (context) => Level(),
          '/homePage': (context) => HomePage(),
          '/login': (context) => LoginPage(),
          '/forgotPass': (context) => ForgotPass(),
          '/basic': (context) => Letters(),
          '/numbers': (context) => Numbers(),
          '/family': (context) => Family(),
          '/colors': (context) => ColorLesson(),
          '/shapes': (context) => Shapes(),
          '/animals': (context) => Animals(),
          '/nature': (context) => Nature(),
          '/food': (context) => Food(),
          '/timeAndDays': (context) => TimeAndDays(),
          '/greeting': (context) => Greetings(),
        },
        home: HomePage(),
    );
  }
}
