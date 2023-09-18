import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sign_buddy/modules/data/lesson_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/lessons/alphabet/lessons/lesson_one.dart';
import 'package:sign_buddy/modules/lessons/alphabet/lessons/quiz_two.dart';
import 'package:sign_buddy/modules/lessons/alphabet/letters.dart';
import 'package:sign_buddy/modules/lessons/alphabet/shuffle_options.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QuizOne extends StatefulWidget {
  final String lessonName;

  const QuizOne({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<QuizOne> createState() => _QuizOneState();
}

class _QuizOneState extends State<QuizOne> {
  String? contentDescription;
  List<dynamic> contentOption = [];
  List<dynamic> correctAnswerIndex = [];

  String selectedOption = '';
  bool answerChecked = false;
  bool progressAdded = false; // Track whether progress has been added

  @override
  void initState() {
    super.initState();
    getContent3DataByName(widget.lessonName);
  }

  LetterLesson? getLetterLessonByName(
      List<LetterLesson> letterLessons, String lessonName) {
    return letterLessons.firstWhere((lesson) => lesson.name == lessonName);
  }

  void getContent3DataByName(String lessonName) async {
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
        LessonContent contentData = lesson.content3;
        print('Content 3 data for $lessonName: $contentData');
        shuffleLessonContentOptions(contentData);

        if (mounted) {
          setState(() {
            contentDescription = contentData.description;
            contentOption = contentData.contentOption!;
            correctAnswerIndex = contentData.correctAnswerIndex!;
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
    bool isCompleted = prefs.getBool('$lessonName-completed3') ?? false;

    if (!isCompleted) {
      // Check if progress is not already added
      await incrementProgressValue(lessonName, 1);
      print("Progress 3 updated successfully!");
      await prefs.setBool('$lessonName-completed3', true); // Mark as completed
    }
  }

  void _checkAnswer() async {
    int selectedIndex = contentOption.indexOf(selectedOption);
    bool isAnswerCorrect = correctAnswerIndex.contains(selectedIndex);

    setState(() {
      answerChecked = true;
    });

    IconData icon = isAnswerCorrect
        ? FontAwesomeIcons.solidCheckCircle
        : FontAwesomeIcons.solidTimesCircle;
    String resultMessage = isAnswerCorrect ? 'Correct' : 'Incorrect';

    // Only add progress on the first correct attempt
    if (isAnswerCorrect && !progressAdded) {
      await addProgressIfNotCompleted(widget.lessonName);
      setState(() {
        progressAdded = true; // Set progressAdded to true
      });
    }
    

    showResultSnackbar(context, resultMessage, icon, () {
      if (!isAnswerCorrect) {
      // If the answer is incorrect, navigate back to LessonOne
        Navigator.pushReplacement(
          context,
          SlidePageRoute(page: LessonOne(lessonName: widget.lessonName)),
        );
      } else {
        _nextPage();
      }
        
    });
  }

  void showResultSnackbar(BuildContext context, String message, IconData icon,
      [VoidCallback? callback]) {
    Color backgroundColor;
    Color fontColor;
    TextStyle textStyle;

    if (message == 'Correct') {
      backgroundColor = Colors.green.shade100;
      fontColor = Colors.green;
      textStyle = TextStyle(
        color: fontColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'FiraSans',
      );
    } else {
      backgroundColor = Colors.red.shade100;
      fontColor = Colors.red;
      textStyle = TextStyle(
        color: fontColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'FiraSans',
      );
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: SizedBox(
              height: 60,
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: fontColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    message,
                    style: textStyle,
                  ),
                ],
              ),
            ),
            backgroundColor: backgroundColor,
            duration: const Duration(days: 365), // Change duration as needed
            dismissDirection: DismissDirection.none,
            action: SnackBarAction(
              label: 'Next',
              textColor: Colors.grey.shade700,
              backgroundColor: Color(0xFF5BD8FF),
              onPressed: () {
                if (callback != null) {
                  callback(); // Call the provided callback if it's not null
                }
              },
            ),
          ),
        )
        .closed
        .then((reason) {
      setState(() {
        selectedOption = ''; // Reset selectedOption
      });
    });
  }

  void _nextPage() async {
    Navigator.pushReplacement(
      context,
      SlidePageRoute(page: QuizTwo(lessonName: widget.lessonName)),
    );

    setState(() {
      selectedOption = '';
      answerChecked = false;
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
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  Navigator.pushReplacement(
                    context,
                    SlidePageRoute(page: const Letters()),
                  );
                },
              ),
            ),
            const SizedBox(height: 100),
            Text(
              contentDescription ?? '',
              style: TextStyle(fontSize: 18),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: contentOption.length,
                itemBuilder: (context, index) {
                  return _buildImageOption(
                    index,
                    contentOption[index],
                    correctAnswerIndex,
                  );
                },
              ),
            ),
            Builder(
              builder: (context) {
                return Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Visibility(
                      visible: !answerChecked,
                      child: ElevatedButton(
                        onPressed: selectedOption.isNotEmpty ? _checkAnswer : null,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            selectedOption.isNotEmpty
                                ? Color(0xFF5BD8FF)
                                : Colors.grey,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.check,
                                size: 18,
                                color: selectedOption.isNotEmpty
                                    ? Colors.grey.shade700
                                    : Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Check',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: selectedOption.isNotEmpty
                                      ? Colors.grey.shade700
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption(
    int index,
    String option,
    List<dynamic> correctAnswerIndices,
  ) {
    bool isCorrectAnswer = correctAnswerIndices.contains(index);
    bool isSelected = selectedOption == option;
    Color tileColor =
        isSelected ? Colors.grey.withOpacity(0.5) : Colors.transparent;
    if (answerChecked) {
      if (isCorrectAnswer) {
        tileColor = Colors.green.withOpacity(0.3); // Correct answer color
      } else if (isSelected) {
        tileColor =
            Colors.red.withOpacity(0.3); // Incorrect selected answer color
      }
    }

    return GestureDetector(
      onTap: () {
        if (!answerChecked) {
          setState(() {
            selectedOption = option;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: tileColor,
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image.asset(
              option,
            ),
          ),
        ),
      ),
    );
  }
}
