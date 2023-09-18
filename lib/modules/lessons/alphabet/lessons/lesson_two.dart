import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sign_buddy/modules/data/lesson_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/lessons/alphabet/lessons/quiz_one.dart';
import 'package:sign_buddy/modules/lessons/alphabet/letters.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LessonTwo extends StatefulWidget {
  final String lessonName;

  const LessonTwo({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<LessonTwo> createState() => _LessonTwoState();
}

class _LessonTwoState extends State<LessonTwo> {
  String? contentDescription;
  List<dynamic> contentImage = [];

  bool progressAdded = false; // Track whether progress has been added

  @override
  void initState() {
    super.initState();
    getContent2DataByName(widget.lessonName);
  }

  LetterLesson? getLetterLessonByName(
      List<LetterLesson> letterLessons, String lessonName) {
    return letterLessons.firstWhere((lesson) => lesson.name == lessonName);
  }

  void getContent2DataByName(String lessonName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/lesson_alphabet.json');

    try {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = json.decode(jsonString);

      List<LetterLesson> letterLessons = jsonData.map((lesson) {
        return LetterLesson.fromJson(lesson);
      }).toList();

      LetterLesson? lesson = getLetterLessonByName(letterLessons, lessonName);

      if (lesson != null) {
        LessonContent contentData = lesson.content2;
        print('Content 2 data for $lessonName: $contentData');

        if (mounted) {
          setState(() {
            contentDescription = contentData.description;
            contentImage.addAll(contentData.contentImage!);
          });
        }
      } else {
        print('LetterLesson with name $lessonName not found in JSON file');
      }
    } catch (e) {
      print('Error reading lesson_alphabet.json: $e');
    }
  }

  Future<void> addProgressIfNotCompleted(String lessonName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isCompleted = prefs.getBool('$lessonName-completed2') ?? false;

    if (!isCompleted) {
      // Check if progress is not already added
      await incrementProgressValue(lessonName, 1);
      print("Progress 2 updated successfully!");
      await prefs.setBool('$lessonName-completed2', true); // Mark as completed
    }
  }

  void _nextPage() async {
    Navigator.pushReplacement(
      context,
      SlidePageRoute(page: QuizOne(lessonName: widget.lessonName)),
    );

    setState(() {
      progressAdded = false; // Reset progressAdded
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.topLeft,
              child: CustomBackButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    SlidePageRoute(page: Letters()),
                  );
                },
              ),
            ),
            const SizedBox(height: 100),
            if (contentDescription != null)
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  contentDescription!,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            if (contentImage.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    contentImage.isNotEmpty ? contentImage[0] : "",
                  ),
                ),
              ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Only add progress on the first navigation
                      if (!progressAdded) {
                        await addProgressIfNotCompleted(widget.lessonName);
                        setState(() {
                          progressAdded = true; // Set progressAdded to true
                        });
                      }
                      _nextPage();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Color(0xFF5BD8FF),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.arrowRight,
                            size: 18,
                            color: Colors.grey.shade700,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
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
}
