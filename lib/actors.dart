import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/choose_language.dart';
import 'package:sign_buddy/classify_as.dart';
import 'package:sign_buddy/modules/sharedwidget/loading.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:sign_buddy/modules/widgets/internet_connectivity.dart'; 


class Actors extends StatefulWidget {
  const Actors({Key? key}) : super(key: key);

  @override
  State<Actors> createState() => _ActorsState();
}

class _ActorsState extends State<Actors> {
  final List<Map<String, dynamic>> user = [
    {'user_actor': 'User Client'},
    {'user_actor': 'PDAO Employee'},
  ];

  String? selectedUser;
  bool loading = false;
  bool isEnglish = true;

  @override
  void initState() {
    super.initState();
    getLanguage();

  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    setState(() {
      this.isEnglish = isEnglish;
    });
  }

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
                    padding: const EdgeInsets.only(top: 50, left: 16),
                    child: CustomBackButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            SlidePageRoute(
                                page: const ChooseLanguages())); // Handle routing here
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                    child: Text(
                      isEnglish ? 'You are?' : "Ikaw ay?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: user.length,
                      itemBuilder: (context, index) {
                        final userAs = user[index];
                        final isSelected = selectedUser == userAs['user_actor'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 30.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedUser = userAs['user_actor'];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.deepPurpleAccent
                                      : Colors.black,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 15.0),
                                title: Text(
                                  userAs['user_actor'],
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 50),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: SizedBox(
                        width: 120, // Set the desired width for the button
                        height: 40, // Set the desired height for the button
                        child: ElevatedButton(
                          onPressed: selectedUser != null
                              ? () => _navigateToStart(context, selectedUser!)
                              : null,
                          style: ButtonStyle(
                            backgroundColor: selectedUser != null
                                ? MaterialStateProperty.all<Color>(
                                    const Color(0xFF5BD8FF))
                                : MaterialStateProperty.all<Color>(const Color(
                                    0xFFD3D3D3)), // Set a different color when no choice is selected
                          ),
                          child: Text(
                             isEnglish ? 'Continue': 'Magpatuloy',
                            style: TextStyle(
                              color:
                                  Colors.grey[700], // Set the desired font color
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

    // Function to navigate to the corresponding language lesson page
   void _navigateToStart(BuildContext context, String userAs) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        
        // Check for internet connectivity before proceeding
        await InternetConnectivityService.checkInternetOrShowDialog(
          context: context,
          onLogin: () async {
              // Store the data in Firestore with the document named after the user UID
              await FirebaseFirestore.instance
                  .collection('userData')
                  .doc(currentUser.uid)
                  .set({'selectedUser': userAs}, SetOptions(merge: true));
              

             // Navigate to the appropriate page based on the selected user
              switch (userAs) {
                case 'User Client':
                  Navigator.push(
                      context, SlidePageRoute(page: const Classify()));
                  break;
                case 'PDAO Employee':
                  Navigator.push(
                      context, SlidePageRoute(page: const Classify()));
                  break;
                default:
                  // Handle the case when the actor is not found
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