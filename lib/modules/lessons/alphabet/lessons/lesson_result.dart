import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/data/lesson_model.dart';


import 'package:flutter/material.dart';
import 'package:sign_buddy/modules/lessons/alphabet/letters.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';

class Result extends StatefulWidget {
  final String lessonName;

  const Result({super.key, required this.lessonName});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  int progress = 0;

  @override
  void initState() {
    super.initState();
  getProgress(widget.lessonName);
  
  }

 Future<void> clearProgress(String lessonName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('$lessonName-completed1', false);
    await prefs.setBool('$lessonName-completed2', false);
    await prefs.setBool('$lessonName-completed3', false);
    await prefs.setBool('$lessonName-completed4', false);
    await prefs.setBool('$lessonName-completed5', false);
    await prefs.setBool('$lessonName-completed6', false);

  }

  LetterLesson? getLetterLessonByName(
      List<LetterLesson> letterLessons, String lessonName) {
    return letterLessons.firstWhere((lesson) => lesson.name == lessonName);
  }

  Future<void> getProgress(String lessonName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/lesson_alphabet.json');

    try {
      final jsonString = await file.readAsString();
      final List<dynamic>jsonData = json.decode(jsonString);


      List<LetterLesson> letterLessons = jsonData.map((lesson){
        return LetterLesson.fromJson(lesson);
      }).toList();


      LetterLesson? lesson = getLetterLessonByName(letterLessons, lessonName);

      if (lesson != null) {
        setState(() {
          progress = lesson.progress;
        });
      } else {
        print('LetterLesson with name $lessonName not found in JSON file');
      }
      
    } catch (e) {
      print('Error reading result lesson_alphabet.json: $e');
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
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Congratulations!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(text: '\n'),
                        TextSpan(
                          text: ' You have completed the lesson!',
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
                                    'Reset Progress?',
                                    style: TextStyle(
                                      fontFamily: 'FiraSans',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              content: Text('Are you sure you want to reset your progress for this lesson?',
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
                          await clearProgress(widget.lessonName);
                          await resetProgress(widget.lessonName);

                          Navigator.push(
                            context,
                            SlidePageRoute(
                              page: Letters(), // Replace with the desired page
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
                            'Reset Progress',
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
                      onPressed: () {
                        if (progress >= 90) {
                          unlockLesson(widget.lessonName);
                        }
                        // Navigate to the Home page (replace it with the desired route)
                        Navigator.pushReplacement(
                          context,
                          SlidePageRoute(
                            page: Letters(), // Replace with the desired page
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
                            'Next Lesson',
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