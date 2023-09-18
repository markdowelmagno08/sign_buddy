import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sign_buddy/modules/data/lesson_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/lessons/alphabet/lessons/lesson_two.dart';
import 'package:sign_buddy/modules/lessons/alphabet/letters.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LessonOne extends StatefulWidget {
  final String lessonName;

  const LessonOne({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<LessonOne> createState() => _LessonOneState();
}

class _LessonOneState extends State<LessonOne> {
  String? contentDescription;
  List<dynamic> contentImage = [];

  bool progressAdded = false; // Track whether progress has been added

  @override
  void initState() {
    super.initState();
    getContent1DataByName(widget.lessonName);
  }

  LetterLesson? getLetterLessonByName(
      List<LetterLesson> letterLessons, String lessonName) {
    return letterLessons.firstWhere((lesson) => lesson.name == lessonName);
  }

  void getContent1DataByName(String lessonName) async {
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
        LessonContent contentData = lesson.content1;
        print('Content 1 data for $lessonName: $contentData');

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
    bool isCompleted = prefs.getBool('$lessonName-completed1') ?? false;

    if (!isCompleted) {
      // Check if progress is not already added
      await incrementProgressValue(lessonName, 16);
      print("Progress 1 updated successfully!");
      await prefs.setBool('$lessonName-completed1', true); // Mark as completed
    }
  }

  void _nextPage() async {
    Navigator.pushReplacement(
      context,
      SlidePageRoute(page: LessonTwo(lessonName: widget.lessonName)),
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
