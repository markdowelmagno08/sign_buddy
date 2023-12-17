// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_buddy/actors.dart';
import 'package:sign_buddy/forgot_pass.dart';
import 'package:sign_buddy/modules/assessments/assess_one.dart';
import 'package:sign_buddy/choose_language.dart';
import 'package:sign_buddy/classify_as.dart';
import 'package:sign_buddy/get_started.dart';
import 'package:sign_buddy/modules/create_sign.dart';
import 'package:sign_buddy/modules/find_sign.dart';
import 'package:sign_buddy/modules/finger_spelling.dart';
import 'package:sign_buddy/modules/home_page.dart';
import 'package:sign_buddy/modules/lessons/color/color.dart';
import 'package:sign_buddy/modules/lessons/family/family.dart';
import 'package:sign_buddy/modules/lessons/numbers/number_lessons/lesson_one.dart';
import 'package:sign_buddy/modules/lessons/numbers/numbers.dart';
import 'package:sign_buddy/modules/lessons/shape.dart';
import 'package:sign_buddy/modules/lessons/animals/animals.dart';
import 'package:sign_buddy/modules/lessons/nature.dart';
import 'package:sign_buddy/modules/lessons/food.dart';
import 'package:sign_buddy/modules/lessons/time_and_days/time-and-days.dart';
import 'package:sign_buddy/modules/lessons/greetings/greetings.dart';

import 'package:sign_buddy/login_screen.dart';

import 'package:sign_buddy/modules/sign_alphabet.dart';
import 'package:sign_buddy/sign_up.dart';
import 'package:sign_buddy/modules/lessons/alphabet/letters.dart';
import 'package:sign_buddy/user_account.dart';

import 'firebase_options.dart';
import 'front_page.dart';
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
      home: AuthenticationWrapper(),
      routes: {
        '/actors': (context) => Actors(),
        '/One': (context) => AssessmentOne(),
        '/get_started': (context) => GetStartedPage(),
        '/signup': (context) => SignupPage(),
        '/chooseLanguage': (context) => ChooseLanguages(),
        '/classify': (context) => Classify(),
        '/homePage': (context) => AuthenticationWrapper(),
        '/login': (context) => LoginPage(),
        '/forgotPass': (context) => ForgotPassword(),
        '/basic': (context) => Letters(),
        '/numbers': (context) => Number(),
        '/family': (context) => Family(),
        '/color': (context) => ColorLesson(),
        '/shapes': (context) => Shapes(),
        '/animals': (context) => Animals(),
        '/nature': (context) => Nature(),
        '/food': (context) => Food(),
        '/timeAndDays': (context) => TimeAndDays(),
        '/greeting': (context) => Greetings(),
        '/alphabet': (context) => AlphabetScreen(),
        '/findSign': (context) => FindSign(),
        '/fingerSpell': (context) => FingerSpelling(),
        '/createSign': (context) => CreateSignPage(),

      },
    );
  }
}


class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  late Future<bool> _authenticationCheck;

  @override
  void initState() {
    super.initState();
    _authenticationCheck = _checkAuthentication();
  }

  Future<bool> _checkAuthentication() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('userData').doc(user.uid).get();

      if (docSnapshot.exists) {
        if (docSnapshot.data()!.containsKey('knowLevel') &&
            docSnapshot['knowLevel'] != null) {
          setState(() {
          });
          return true;
        } else {
          // "knowLevel" not found or is null, navigate to FrontPage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => FrontPage()),
          );
          return false;
        }
      } else {
        // Document does not exist, navigate to FrontPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => FrontPage()),
        );
        return false;
      }
    } else {
      return false;
    }
  }

  @override
    Widget build(BuildContext context) {
      return FutureBuilder<bool>(
        future: _authenticationCheck,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              // Customized loading indicator with image and text
              return Container(
                color: Colors.white, 
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/app_icon.png', 
                        width: 120, 
                        height: 120, 
                      ),
                      SizedBox(height: 16),
                      
                      Padding(
                        padding: const EdgeInsets.only(left: 60, right: 60),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey[300], 
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent), 
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case ConnectionState.done:
              if (snapshot.data == true) {
                // User is authenticated and has "knowLevel", navigate to HomePage
                return HomePage();
              } else {
                // User is not authenticated or does not have "knowLevel", navigate to FrontPage
                return FrontPage();
              }
            default:
              // Handle other cases
              return FrontPage();
          }
        },
      );
    }

}