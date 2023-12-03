
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/modules/firestore_data/lesson_numbers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/lessons/numbers/numbers.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';

class Result extends StatefulWidget {
  final String lessonName;

  const Result({super.key, required this.lessonName});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  String uid = "";
  int progress = 0;
  bool isLoading = true;
  bool isEnglish = true;


  @override
  void initState() {
    super.initState();
    getPrefValues().then((_) => getProgress(widget.lessonName)).then((_) {
    if (progress >= 90) {
      NumberLessonFireStore(userId: uid)
          .unlockLesson(widget.lessonName, isEnglish ? "en" : "ph");
    }
    });
  }






  Future<void> getPrefValues() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true; // Default to English.

    if (mounted) {
      setState(() {
        this.isEnglish = isEnglish;
      });
    }
  }
    

  Future<void> getProgress(String lessonName) async {
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData =
      await NumberLessonFireStore(userId: userId!)
            .getUserLessonData(lessonName, isEnglish ? "en" : "ph");

      // ignore: unnecessary_null_comparison
      if (lessonData != null) {
        if (mounted) {
          setState(() {
            progress = lessonData['progress'];
            uid = userId;
            isLoading = false;
          });
        }

      } else {
        print(
            'Number lesson "$lessonName" was not found within the Firestore.');
        isLoading = true;
      }
    } catch (e) {
      print('Error reading number_lessons.json: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
    
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/congrats-img.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                   Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: isEnglish ? 'Congratulations!' : 'Pagbati',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(text: '\n'),
                        TextSpan(
                          text: isEnglish ? 'You have completed the lesson' : 'Natapos mo na ang aralin!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        // Show a confirmation dialog before resetting progress
                        bool confirmReset = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    color:  const Color(0xFF5A96E3),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    isEnglish ? 'Reset Progress?' : 'I-reset ang Progres?',
                                    style: TextStyle(
                                      fontFamily: 'FiraSans',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(isEnglish ? 'Are you sure you want to reset your progress for this lesson?' : 'Sigurado ka bang gusto mong i-reset ang iyong progress para sa araling ito?',
                              style: TextStyle(fontFamily: 'FiraSans')),
                              actions: <Widget>[
                                ElevatedButton(
                                  style: ButtonStyle(
                                     backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                  ),
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false); // Return false to indicate cancellation
                                  },
                                ),
                                SizedBox(width: 5)
,                               ElevatedButton(
                                  style: ButtonStyle(
                                     backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                  ),
                                  child: Text('Reset'),
                                  onPressed: () {
                                    Navigator.of(context).pop(true); // Return true to confirm the reset
                                  },
                                ),
                              ],
                            );
                          },
                        );

                        // Check if the user confirmed the reset and then call the clearProgress function
                        if (confirmReset == true) {
                          // print('Clearing progress for lesson: ${widget.lessonName}');
                          await NumberLessonFireStore(
                            userId: Auth().getCurrentUserId()!,
                          ).resetProgress(widget.lessonName, isEnglish ? "en" : "ph");

                          Navigator.push(
                            context,
                            SlidePageRoute(
                              page: Number(), // Replace with the desired page
                            ),
                          );
                          
                        }
                      },
                      child: Column(
                        children: [
                          const Icon(
                            Icons.refresh,
                            color: Color(0xFF5BD8FF),
                          ),
                          Text(
                            isEnglish ? 'Reset Progress' : 'I-reset ang Progres',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                      
                        Navigator.pushReplacement(
                          context,
                          SlidePageRoute(
                            page: Number(), 
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF5BD8FF),
                          ),
                          Text(
                            isEnglish ? 'Next Lesson' : 'Susunod na Aralin',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}