import 'package:flutter/material.dart';
import 'package:sign_buddy/modules/assessments/assess_five.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';

import 'package:sign_buddy/modules/assessments/shuffle_options.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';

class AssessmentFour extends StatefulWidget {
  final int score;

  const AssessmentFour({Key? key, required this.score}) : super(key: key);

  @override
  _AssessmentFourState createState() => _AssessmentFourState();
}

class _AssessmentFourState extends State<AssessmentFour> {
  int currentIndex = 0;
  int score = 0;
  bool answerChecked = false;
  String typedAnswer = '';
  String correctAnswer = '';

  final List<Map<String, dynamic>> assessmentQuestions = [
    {
      'question': 'What sign is this?',
      'options': [
        'assets/assess-img/question-four/grandmother.gif',
      ],
      'correctAnswer': 'grandmother',
    },
    // Add more assessment questions here if needed
  ];

  void checkAnswer() {
    setState(() {
      answerChecked = true;
      correctAnswer = assessmentQuestions[currentIndex]['correctAnswer'];
      if (typedAnswer.toLowerCase() == correctAnswer) {
        score++;
      }
    });
  }

  void nextQuestion() {
    setState(() {
      currentIndex++;
      answerChecked = false;
      typedAnswer = '';
      correctAnswer = '';
    });
  }

  void navigateToNextAssessment(BuildContext context) {
    if (currentIndex < assessmentQuestions.length - 1) {
      Navigator.push(
        context,
        SlidePageRoute(
          page: AssessmentFour(score: widget.score + score),
        ),
      );
    } else {
      Navigator.push(
        context,
        SlidePageRoute(
          page: AssessmentFive(score: widget.score + score),
        ),
      );
    }
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
              height: 80, // Increase the height to accommodate both messages
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Align the text in the center vertically
                children: [
                  Row(
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
                  if (message != 'Correct')
                    Container(
                      padding: const EdgeInsets.only(top: 3, right: 65),
                      child: Text(
                        'Correct answer: $correctAnswer',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'FiraSans',
                        ),
                      ),
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
  void initState() {
    super.initState();
    shuffleOptions(
        assessmentQuestions); // Shuffle options when the widget is first initialized
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
        body: SingleChildScrollView( // Wrap your Scaffold with SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 70),
                Text(
                  "Type your answer in the text field",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                Text(
                  "Assessment 4: ${question}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                // Display Gif with a border
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey, // Add a border color
                      width: 2, // Add border width
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(options[0]),
                ),
                const SizedBox(height: 20),
                if (!answerChecked)
                TextField(
                  onChanged: (value) {
                    setState(() {
                      typedAnswer = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    CustomInputFormatter(),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        bottomNavigationBar: answerChecked
            ? null
            : Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: typedAnswer.isNotEmpty
                      ? () {
                          checkAnswer();
                          if (typedAnswer.toLowerCase() == correctAnswer) {
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
              ),
      ),
    );
  }
}


class CustomInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only alphabetic characters and disallow spaces
    final RegExp regExp = RegExp(r'^[a-zA-Z]*$');
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
