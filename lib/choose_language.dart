// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_buddy/actors.dart';
import 'package:sign_buddy/firestore_user.dart';

import 'package:sign_buddy/get_started.dart';
import 'package:sign_buddy/locale.dart';
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
  ];


   bool loading = false;
   String? selectedLanguage;

   


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
                  Navigator.push(context, SlidePageRoute(page: GetStartedPage()));
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 2),
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
              height: 50,
            ),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final isSelected = selectedLanguage == language['name']; // Check if this language is selected
            
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 30.0),
                    child: Card(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.deepPurpleAccent : Colors.black, // Set border color based on isSelected
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              selectedLanguage = language['name'];
                            });
                          },
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 15.0),
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
                                .bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 30),
                child: SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: selectedLanguage != null
                        ? () => _navigateToActors(context, selectedLanguage!)
                        : null,
                    style: ButtonStyle(
                      backgroundColor: selectedLanguage != null
                          ? MaterialStateProperty.all<Color>(const Color(0xFF5BD8FF))
                          : MaterialStateProperty.all<Color>(const Color(0xFFD3D3D3)),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToActors(BuildContext context, String language) async {
    try {
      await InternetConnectivityService.checkInternetOrShowDialog(
        context: context,
        onLogin: () async {
          final UserCredential userCredential =
              await FirebaseAuth.instance.signInAnonymously();
          final User? currentUser = userCredential.user;

          if (currentUser != null) {
            final String userId = currentUser.uid;
            setState(() => loading = true);

            await FirebaseFirestore.instance
                .collection('userData')
                .doc(userId)
                .set({'language': language}, SetOptions(merge: true));

            switch (language) {
              case 'American - English':
               UserFirestore(userId: userId).initializeLessons("letters", "en");
                setLanguage(true);
                print("language set successfully for en");
                Navigator.push(context, SlidePageRoute(page: Actors()));
                break;
              case 'Filipino':
              setLanguage(false);
               UserFirestore(userId: userId).initializeLessons("letters", "ph");

              print("language set successfully for ph");
                Navigator.push(context, SlidePageRoute(page: Actors()));
                break;
              default:
                // Handle the case when the language is not found
                break;
            }

            setState(() {
              loading = false;
            });
          }
        },
      );
    } catch (e) {
      print('Failed to store data for anonymous user: $e');
    }
  }
}