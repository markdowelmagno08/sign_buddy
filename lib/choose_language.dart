import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_buddy/classify_as.dart';
import 'package:sign_buddy/firestore_user.dart';
import 'package:sign_buddy/get_started.dart';
import 'package:sign_buddy/locale.dart';
import 'package:sign_buddy/modules/sharedwidget/loading.dart';
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
    {'name': 'English', 'flag': 'america.png'},
    {'name': 'Filipino', 'flag': 'ph.png'},
  ];

  bool loading = false;
  String? selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg-signbuddy.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(
                    top: orientation == Orientation.portrait ? 50 : 20,
                    left: orientation == Orientation.portrait ? 16 : 8,
                  ),
                  child: CustomBackButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        SlidePageRoute(page: GetStartedPage()),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(
                    orientation == Orientation.portrait ? 20 : 10,
                    orientation == Orientation.portrait ? 100 : 50,
                    orientation == Orientation.portrait ? 20 : 10,
                    2,
                  ),
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
                  height: orientation == Orientation.portrait ? 50 : 20,
                ),
                SizedBox(
                  height: orientation == Orientation.portrait ? 300 : 150,
                  child: ListView.builder(
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final language = languages[index];
                      final isSelected = selectedLanguage == language['name'];

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: orientation == Orientation.portrait ? 2.0 : 1.0,
                          horizontal: orientation == Orientation.portrait ? 30.0 : 15.0,
                        ),
                        child: Card(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.deepPurpleAccent : Colors.black,
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
                                vertical: orientation == Orientation.portrait ? 5.0 : 2.5,
                                horizontal: orientation == Orientation.portrait ? 15.0 : 7.5,
                              ),
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
                                  backgroundImage: AssetImage(
                                    'assets/${language['flag']}',
                                  ),
                                ),
                              ),
                              title: Text(
                                language['name'],
                                style: Theme.of(context).textTheme.bodyMedium,
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
                    padding: EdgeInsets.only(
                      right: orientation == Orientation.portrait ? 30 : 15,
                    ),
                    child: SizedBox(
                      width: 120,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: selectedLanguage != null
                            ? () => _navigateToClassify(context, selectedLanguage!)
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
      },
    );
  }

  void _navigateToClassify(BuildContext context, String language) async {
    try {
      await InternetConnectivityService.checkInternetOrShowDialog(
        context: context,
        onLogin: () async {
          User? currentUser = FirebaseAuth.instance.currentUser;

          if (currentUser != null) {
            setState(() => loading = true);

            await FirebaseFirestore.instance
                .collection('userData')
                .doc(currentUser.uid)
                .set({'language': language}, SetOptions(merge: true));

            switch (language) {
              case 'English':
                setLanguage(true);
                print("language set successfully for en");
                Navigator.push(context, SlidePageRoute(page: Classify()));
                break;
              case 'Filipino':
                setLanguage(false);
                print("language set successfully for ph");
                Navigator.push(context, SlidePageRoute(page: Classify()));
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
