// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_buddy/actors.dart';
import 'package:sign_buddy/modules/classify_as.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:sign_buddy/modules/widgets/internet_connectivity.dart'; 

class ChooseLanguages extends StatefulWidget {
  const ChooseLanguages({Key? key}) : super(key: key);

  @override
  _ChooseLanguagesState createState() => _ChooseLanguagesState();
}

class _ChooseLanguagesState extends State<ChooseLanguages> {
  final List<Map<String, dynamic>> languages = [
    {'name': 'American - English', 'flag': 'america.png'},
    {'name': 'Filipino', 'flag': 'ph.png'},
    // {'name': 'Spanish', 'flag': 'spain.png'},
    // {'name': 'Arabic', 'flag': 'arab.png'},
    // {'name': 'British - English', 'flag': 'uk.png'},
    // {'name': 'Chinese', 'flag': 'china.png'},
    // {'name': 'French', 'flag': 'france.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/bg-signbuddy.png'), // Replace with your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(top: 50, left: 16),
              child: CustomBackButton(
                onPressed: () {
                  Navigator.push(context,
                      SlidePageRoute(page: Actors())); // Handle routing here
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Text(
                'What language would you like to learn?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 30.0),
                    // Increase the vertical padding of the box height and margin here

                    child: Card(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4)),
                        child: ListTile(
                          onTap: () {
                            _navigateToLanguageLesson(
                                context, language['name']);
                          },

                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 15.0),
                          // Increase the vertical padding of the box her
                          leading: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  AssetImage('assets/${language['flag']}'),
                            ),
                          ),
                          title: Text(
                            language['name'],
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium, // call from main text style
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to navigate to the corresponding language lesson page
  void _navigateToLanguageLesson(BuildContext context, String language) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Check for internet connectivity before proceeding
        await InternetConnectivityService.checkInternetOrShowDialog(
          context: context,
          onLogin: () async {
            // Retrieve the existing user data (gathered before signing up)
            DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                .collection('userData')
                .doc(currentUser.uid)
                .get();
            Map<String, dynamic> existingData =
                userSnapshot.data() as Map<String, dynamic>? ?? {};

            // Merge the existing data with the new data
            Map<String, dynamic> newData = {
              'language': language,
            };
            newData.addAll(existingData);

            // Store the merged data in Firestore with the document named after the user UID
            await FirebaseFirestore.instance
                .collection('userData')
                .doc(currentUser.uid)
                .set(newData, SetOptions(merge: true));

            // Navigate to the language lesson page or perform any other desired actions
            switch (language) {
              case 'American - English':
                Navigator.push(context, SlidePageRoute(page: Classify()));
                break;
              default:
                // Handle the case when the language is not found
                break;
            }
          },
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }
}