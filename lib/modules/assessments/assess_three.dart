import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool isEnglish = true;
  

   final List<String> enOptions = [
    'assets/dictionary/family/grandmother.gif',
    'assets/dictionary/family/friend.gif',
  ];

    final List<String> phOptions = [
      'assets/dictionary/family/lola.gif',
      'assets/dictionary/family/ate.gif',
    ];

    final List<Map<String, dynamic>> assessmentQuestions = [
      {
        'question': 'Which is the correct sign for "Friend"?',
        'options': [], // To be populated based on the language
        'correctAnswerIndex': 1,
      },
    ];

  @override
  void initState() {
    super.initState();
    getLanguage();
    shuffleOptions(assessmentQuestions); // Shuffle options when the widget is first initialized
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

      if(mounted) {
        setState(() {
        this.isEnglish = isEnglish;
        // Populate options based on the selected language
        assessmentQuestions[0]['options'] = isEnglish ? enOptions : phOptions;
      });
      }
  }

  void checkAnswer() {
    if(mounted) {
      setState(() {
        answerChecked = true;
        correctAnswerIndex =
            assessmentQuestions[currentIndex]['correctAnswerIndex'];
        if (selectedAnswerIndex == correctAnswerIndex) {
          score++;
        }
      });
    }
  }

  void nextQuestion() {
    if(mounted) {
      setState(() {
        currentIndex++;
        answerChecked = false;
        selectedAnswerIndex = -1;
        correctAnswerIndex = -1;
      });
    }
  }

  void navigateToNextAssessment(BuildContext context) {
    if (currentIndex < assessmentQuestions.length - 1) {
      Navigator.pushReplacement(
        context,
        SlidePageRoute(
          page: AssessmentThree(score: widget.score + score),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        SlidePageRoute(
          page: AssessmentFour(score: widget.score + score),
        ),
      );
    }
  }

  

  void showResultSnackbar(BuildContext context, String message, IconData icon) {
    Color backgroundColor;
    Color fontColor;
    TextStyle textStyle;

    if (message == 'Correct' || message == 'Tama') {
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
              label: isEnglish ? 'Next' : 'Susunod',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 70),
              Text(
                isEnglish
                    ? "Tap the video to select the answer."
                    : "Pindutin ang bidyo para pumili ng sagot",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              Text(
                isEnglish
                    ? "Assessment 3: ${question}"
                    : "Pagsusuri 3: Ano ang tamang senyas para sa 'Ate'?",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              // Display Video
              Column(
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: answerChecked
            ? null
            :Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: selectedAnswerIndex != -1
              ? () {
                  checkAnswer();
                  if (selectedAnswerIndex == correctAnswerIndex) {
                    showResultSnackbar(
                      context,
                      isEnglish ? 'Correct' : "Tama",
                      FontAwesomeIcons.solidCircleCheck,
                    );
                  } else {
                    showResultSnackbar(
                      context,
                      isEnglish ? 'Incorrect' : "Mali",
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
          child: Text(isEnglish ? 'Check' : "Tignan"),
        ),
      ),
    ),
  );
}
}
