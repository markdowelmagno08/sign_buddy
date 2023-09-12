import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_buddy/modules/classify_as.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:sign_buddy/modules/sharedwidget/loading.dart';

class Level extends StatefulWidget {
  const Level({Key? key}) : super(key: key);

  @override
  _LevelState createState() => _LevelState();
}

class _LevelState extends State<Level> {
  String? selectedLevelIndex;
  bool loading = false;

  final List<Map<String, dynamic>> levels = [
    {
      'level': 'I’m new to English Sign Language',
      'iconlevel': 'level1.png',
    },
    {
      'level': 'I know some sign language words and phrases',
      'iconlevel': 'level2.png',
    },
    {
      'level': 'I can have simple conversation using English Sign Language',
      'iconlevel': 'level3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading(
            text: 'Setting up your preferences . . . ',
          )
        : Scaffold(
            body: Container(
              decoration: const BoxDecoration(
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
                                page: const Classify())); // Handle routing here
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: const Text(
                      'How much English Sign Language do you know?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: levels.length,
                      itemBuilder: (context, index) {
                        final level = levels[index];
                        final isSelected = selectedLevelIndex == level['level'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 30.0),
                          child: Card(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.deepPurpleAccent
                                      : Colors.black,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListTile(
                                onTap: () {
                                  setState(() {
                                    selectedLevelIndex = level['level'];
                                  });
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 15.0),
                                leading: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Image.asset(
                                    'assets/${level['iconlevel']}',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  level['level'],
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
                      padding: const EdgeInsets.only(right: 33, bottom: 120),
                      child: SizedBox(
                        width: 120, // Set the desired width for the button
                        height: 40,
                        child: ElevatedButton(
                          onPressed: selectedLevelIndex != null
                              ? () => _navigateToHomePage(
                                  context, selectedLevelIndex!)
                              : null,
                          style: ButtonStyle(
                            backgroundColor: selectedLevelIndex != null
                                ? MaterialStateProperty.all<Color>(
                                    const Color(0xFF5BD8FF))
                                : MaterialStateProperty.all<Color>(const Color(
                                    0xFFD3D3D3)), // Set a different color when no choice is selected
                          ),
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors
                                  .grey[700], // Set the desired font color
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

  Future<void> _navigateToHomePage(
      BuildContext context, String selectedLevel) async {
    //show the loading screen
    setState(() => loading = true);

    try {
      // loading screen time
      await Future.delayed(const Duration(seconds: 5));

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Store the selected level data in Firestore under the user's UID
        await FirebaseFirestore.instance
            .collection('userData')
            .doc(currentUser.uid)
            .set({'selectedLevel': selectedLevel}, SetOptions(merge: true));

        switch (selectedLevelIndex) {
          case 'I’m new to English Sign Language':
            selectedLevel = 'I’m new to English Sign Language';
            Navigator.pushNamed(context, '/homePage');
            break;
          case 'I know some sign language words and phrases':
            selectedLevel = 'I know some sign language words and phrases';
            Navigator.pushNamed(context, '/s');
            break;
          case 'I can have simple conversation using English Sign Language':
            selectedLevel =
                'I can have simple conversation using English Sign Language';
            Navigator.pushNamed(context, '/s');
            break;
          default:
            selectedLevel = '';
            break;
        }
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print(e.toString());
    }
  }
}
