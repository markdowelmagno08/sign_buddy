import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/assessments/assess_seven.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/assessments/shuffle_options.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AssessmentSix extends StatefulWidget {
  final int score;

  const AssessmentSix({Key? key, required this.score}) : super(key: key);

  @override
  _AssessmentSixState createState() => _AssessmentSixState();
}

class _AssessmentSixState extends State<AssessmentSix> {
  int currentIndex = 0;
  int score = 0;
  bool answerChecked = false;
  int selectedAnswerIndex = -1;
  int correctAnswerIndex = -1;
  bool isEnglish = true;

  

  final List<Map<String, dynamic>> assessmentQuestions = [
    {
      'question': 'What do you think this sign means?',
      'imageUrl': {
        'en': 'assets/dictionary/family/baby.gif',
        'ph': 'assets/dictionary/family/sanggol.gif',
      },
      'options': [
        'assets/dictionary/family/baby.png',
        'assets/dictionary/family/tree.png',
      ],
      'correctAnswerIndex': 0,
    },
    // Add more questions as needed
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
      });
    }
  }

  void checkAnswer() {
    if(mounted) {
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
      Navigator.push(
        context,
        SlidePageRoute(
          page: AssessmentSix(score: widget.score + score),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssessmentSeven(score: widget.score + score),
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
    // Get the current question's image URL based on the language
    String imageUrlKey = isEnglish ? 'en' : 'ph';
    String imageUrl = currentQuestion['imageUrl'][imageUrlKey];
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
                isEnglish
                ? "Tap the image to select the answer."
                : "Pindutin ang larawan para pumili ng sagot",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              Text(
                isEnglish
                ? "Assessment 6: ${question}"
                : "Pagsusuri 6: Ano sa palagay mo ang kahulugan ng senyas na ito?",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
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
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Display Image Choices in a 1x2 grid
              Expanded(
                flex: 2, // Give the grid 2/3 of the available space
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 120, // Specify the height of each grid item
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
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isCorrectAnswer && answerChecked
                                  ? Colors
                                      .green // Show green border when the answer is correct and checked
                                  : Colors.grey, // Default border color
                              width: 2, // Add border width
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelectedAnswer
                                ? Colors.grey.withOpacity(
                                    0.3) // Selected answer has a grey tint
                                : isCorrectAnswer && answerChecked
                                    ? Colors.green // Correct answer turns green
                                    : Colors
                                        .transparent, // Default background color
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: isSelectedAnswer
                                ? ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                        Colors.grey.withOpacity(
                                            0.5), // Change the filter color here (e.g., grey tint)
                                        BlendMode.multiply),
                                    child: Image.asset(
                                      options[index],
                                      fit: BoxFit
                                          .cover, // Image covers the entire container without any scaling
                                    ),
                                  )
                                : Image.asset(
                                    options[index],
                                    fit: BoxFit
                                        .cover, // Image covers the entire container without any scaling
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
                              isEnglish
                              ?'Correct'
                              : "Tama",
                              FontAwesomeIcons.solidCircleCheck,
                            );
                          } else {
                            showResultSnackbar(
                              context,
                              isEnglish
                              ?'Incorrect'
                              : "Mali",
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
            ],
          ),
        ),
      ),
    );
  }
}
