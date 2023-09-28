import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_buddy/firestore_user.dart';
import 'package:sign_buddy/modules/choose_language.dart';
import 'package:sign_buddy/modules/get_started.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:sign_buddy/modules/sharedwidget/loading.dart';
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

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading(text: 'Loading . . . ')
        : Scaffold(
            body: Column(
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
                              page:
                                  const GetStartedPage())); // Handle routing here
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                  child: const Text(
                    'You are?',
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
                          'Continue',
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
          );
  }

    void _navigateToStart(BuildContext context, String userAs) async {
  try {
    // Check for internet connectivity before proceeding
    await InternetConnectivityService.checkInternetOrShowDialog(
      context: context,
      onLogin: () async {
        // Sign in the user anonymously
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInAnonymously();
        final User? currentUser = userCredential.user;

        if (currentUser != null) {
          // Retrieve the user ID
          final String userId = currentUser.uid;
          
          UserFirestore(userId: userId).initializeLessons("letters", "en");
          setState(() => loading = true); // Show the loading screen

          // Store the data in Firestore with the document named after the user UID
          await FirebaseFirestore.instance
              .collection('userData')
              .doc(userId)
              .set({
            // Specify the data you want to store
            'selectedUser': userAs,
          });

          // Navigate to the appropriate page based on the selected user
          switch (userAs) {
            case 'User Client':
              Navigator.push(
                  context, SlidePageRoute(page: const ChooseLanguages()));
              break;
            case 'PDAO Employee':
              Navigator.push(
                  context, SlidePageRoute(page: const ChooseLanguages()));
              break;
            default:
              // Handle the case when the actor is not found
              break;
          }

          // Dismiss the loading screen
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