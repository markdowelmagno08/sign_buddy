import 'package:flutter/material.dart';
import 'package:sign_buddy/modules/assessments/assess_three.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';

import 'package:sign_buddy/modules/assessments/shuffle_options.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class AssessmentTwo extends StatefulWidget {
  final int score;

  const AssessmentTwo({Key? key, required this.score}) : super(key: key);

  @override
  _AssessmentTwoState createState() => _AssessmentTwoState();
}

class _AssessmentTwoState extends State<AssessmentTwo> {
  int currentIndex = 0;
  int score = 0;
  bool answerChecked = false;
  int selectedAnswerIndex = -1;
  int correctAnswerIndex = -1;

  final List<Map<String, dynamic>> assessmentQuestions = [
    {
      'question': 'What is being signed here? ',
      'videoUrl': 'assets/assess-img/question-two/husband.gif',
      'options': ['Husband', 'Niece', 'Hello', 'Mother', 'Sister', 'Tree'],
      'correctAnswerIndex': 0,
    },
    // Add more questions as needed
  ];

  void checkAnswer() {
    setState(() {
      if (selectedAnswerIndex != -1) {
        answerChecked = true;
        correctAnswerIndex =
            assessmentQuestions[currentIndex]['correctAnswerIndex'];
        if (selectedAnswerIndex == correctAnswerIndex) {
          score++;
        }
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
          page: AssessmentTwo(score: widget.score + score),
        ),
      );
    } else {
      Navigator.push(
        context,
        SlidePageRoute(
          page: AssessmentThree(score: widget.score + score),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    shuffleOptions(assessmentQuestions);
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
    String videoUrl = currentQuestion['videoUrl'];
    List<String> options = (currentQuestion['options'] as List).cast<String>();

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
                "Select the word that matches the sign",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              Text(
                "Assessment 2: ${question}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              // Display Video
              GestureDetector(
                onTap: () {
                  if (!answerChecked) {
                    setState(() {
                      selectedAnswerIndex = -1;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    videoUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Display Word Choices in a 2x3 grid
              Expanded(
                flex: 2, // Give the grid 2/3 of the available space
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 60, // Specify the height of each grid item
                  ),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
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
                      child: SizedBox(
                        height: 10, // Adjust the height as needed
                        width: 10,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey, // Add a border color
                              width: 1, // Add border width
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isCorrectAnswer
                                ? Colors.green.withOpacity(
                                    0.3) // Correct answer turns green
                                : isSelectedAnswer
                                    ? Colors.grey.withOpacity(
                                        0.3) // Selected answer has a grey tint
                                    : Colors
                                        .transparent, // Default background color
                          ),
                          child: Center(
                            child: Text(
                              options[index],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
