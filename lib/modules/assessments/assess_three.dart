import 'package:flutter/material.dart';
import 'package:sign_buddy/modules/assessments/assess_four.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';

import 'package:sign_buddy/modules/assessments/shuffle_options.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AssessmentThree extends StatefulWidget {
  final int score;

  const AssessmentThree({Key? key, required this.score}) : super(key: key);

  @override
  _AssessmentThreeState createState() => _AssessmentThreeState();
}

class _AssessmentThreeState extends State<AssessmentThree> {
  int currentIndex = 0;
  int score = 0;
  bool answerChecked = false;
  int selectedAnswerIndex = -1;
  int correctAnswerIndex = -1;

  final List<Map<String, dynamic>> assessmentQuestions = [
    {
      'question': 'Which is the correct sign for "Friend"?',
      'options': [
        'assets/dictionary/family/grandmother.gif',
        'assets/dictionary/family/friend.gif',
      ],
      'correctAnswerIndex': 1,
    },
  ];

  void checkAnswer() {
    setState(() {
      answerChecked = true;
      correctAnswerIndex =
          assessmentQuestions[currentIndex]['correctAnswerIndex'];
      if (selectedAnswerIndex == correctAnswerIndex) {
        score++;
      }
    });
  }

  void nextQuestion() {
    setState(() {
      currentIndex++;
      answerChecked = false;
      selectedAnswerIndex = -1;
      correctAnswerIndex = -1;
    });
  }

  void navigateToNextAssessment(BuildContext context) {
    if (currentIndex < assessmentQuestions.length - 1) {
      Navigator.push(
        context,
        SlidePageRoute(
          page: AssessmentThree(score: widget.score + score),
        ),
      );
    } else {
      Navigator.push(
        context,
        SlidePageRoute(
          page: AssessmentFour(score: widget.score + score),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    shuffleOptions(
        assessmentQuestions); // Shuffle options when the widget is first initialized
  }

  void showResultSnackbar(BuildContext context, String message, IconData icon) {
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
            duration: const Duration(days: 365),
            dismissDirection: DismissDirection.none,
            action: SnackBarAction(
              label: 'Next',
              textColor: Colors.grey.shade700,
              backgroundColor: Colors.blue.shade200,
              onPressed: () {
                if (currentIndex < assessmentQuestions.length - 1) {
                  nextQuestion();
                } else {
                  navigateToNextAssessment(context);
                }
              },
            ),
          ),
        )
        .closed
        .then((reason) {
      setState(() {
        answerChecked = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> currentQuestion = assessmentQuestions[currentIndex];
    String question = currentQuestion['question'];
    List<String> options = currentQuestion['options'];

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 70),
              Text(
                "Tap the video to select the answer.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              Text(
                "Assessment 3: ${question}",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              // Display Video
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(options.length, (index) {
                    bool isCorrectAnswer =
                        (answerChecked && correctAnswerIndex == index);
                    bool isSelectedAnswer = (selectedAnswerIndex == index);
    
                    return GestureDetector(
                      onTap: () {
                        if (!answerChecked) {
                          setState(() {
                            selectedAnswerIndex = index;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isCorrectAnswer
                              ? Colors.green.withOpacity(0.3)
                              : isSelectedAnswer
                                  ? Colors.grey.withOpacity(0.3)
                                  : Colors
                                      .white, // Set the default color here (e.g., Colors.white)
                        ),
                        child: ClipRRect(
                          // ClipRRect to ensure the GIF stays within the container
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(options[index]),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              if (!answerChecked)
                ElevatedButton(
                  onPressed: selectedAnswerIndex != -1
                      ? () {
                          checkAnswer();
                          if (selectedAnswerIndex == correctAnswerIndex) {
                            showResultSnackbar(
                              context,
                              'Correct',
                              FontAwesomeIcons.solidCircleCheck,
                            );
                          } else {
                            showResultSnackbar(
                              context,
                              'Incorrect',
                              FontAwesomeIcons.solidCircleXmark,
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: const Color(0xFF5BD8FF),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'FiraSans',
                      fontWeight: FontWeight.bold,
                    ),
                    foregroundColor: const Color(0xFF5A5A5A),
                  ),
                  child: const Text('Check'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
