import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/assessments/assess_eight.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AssessmentSeven extends StatefulWidget {
  final int score;

  const AssessmentSeven({Key? key, required this.score}) : super(key: key);

  @override
  _AssessmentSevenState createState() => _AssessmentSevenState();
}

class _AssessmentSevenState extends State<AssessmentSeven> {
  int currentIndex = 0;
  int score = 0;
  bool answerChecked = false;
  List<String> selectedWords = [];
  bool isEnglish = true;

  final List<String> enOptions = [
    'My',
    'moon',
    'nice',
    'man',
    'day',
    'Have',
    'a',
    'yes',
    '?',
  ];

  final List<String> phOptions = [
    'Magandang',
    'buwan',
    'umaga',
    'lalaki',
    'tita',
    'Mayroon',
    'ang',
    'oo',
    '!',
  ];

  final List<Map<String, dynamic>> assessmentQuestions = [
    {
      'question': 'What sentence does this sign language represent?',
      'imageUrl': {
        'en': 'assets/dictionary/phrases/have_a_nice_day.gif',
        'ph': 'assets/dictionary/phrases/magandang_umaga.gif',
      },
      'options': [],
      'correctAnswer': {
        'en': ['Have', 'a', 'nice', 'day'],
        'ph': ['Magandang', 'umaga'],
      },
    },
  ];

  void shuffleOptions() {
    setState(() {
      enOptions.shuffle(Random());
      phOptions.shuffle(Random());
    });
  }

  @override
  void initState() {
    super.initState();
    getLanguage();
    shuffleOptions(); // Add this line to shuffle options when the screen initializes.
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    setState(() {
      this.isEnglish = isEnglish;
      assessmentQuestions[0]['options'] = isEnglish ? enOptions : phOptions;
    });
  }

  void checkAnswer() {
    setState(() {
      answerChecked = true;
      Map<String, dynamic> correctAnswer =
          assessmentQuestions[currentIndex]['correctAnswer'];
      if (selectedWords.join(' ') == correctAnswer[isEnglish ? 'en' : 'ph'].join(' ')) {
        score++;
      }
    });
  }

  void nextQuestion() {
    setState(() {
      currentIndex++;
      answerChecked = false;
      selectedWords.clear();
    });
  }

  void navigateToNextAssessment(BuildContext context) {
    if (currentIndex < assessmentQuestions.length - 1) {
      Navigator.push(
        context,
        SlidePageRoute(
          page: AssessmentSeven(score: widget.score + score),
        ),
      );
    } else {
      Navigator.push(
        context,
        SlidePageRoute(
          page: AssessmentEight(score: widget.score + score),
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
    String imageUrlKey = isEnglish ? 'en' : 'ph';
    String imageUrl = currentQuestion['imageUrl'][imageUrlKey];
    List<String> options = (currentQuestion['options'] as List).cast<String>();
    Map<String, dynamic> correctAnswer = currentQuestion['correctAnswer'];

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
                ? "Create a sentence by selecting the word options below"
                : "Lumikha ng pangungusap sa pamamagitan ng pagpili ng mga opsyon",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                isEnglish
                ? "Assessment 7: ${question}"
                : "Pagsusuri 7: Anong pangungusap ang binubuo ng senyas na ito?",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
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
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: Text(
                  isEnglish
                  ? "Your Answer:"
                  : 'Sagot mo',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Wrap(
                      spacing: 2,
                      children: List.generate(selectedWords.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(
                            selectedWords[index],
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  if (answerChecked)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                         Center(
                          child: Text(
                            isEnglish
                            ? 'Correct Answer:'
                            : 'Tamang sagot:',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                isEnglish
                                ? correctAnswer['en'].join(' ')
                                : correctAnswer['ph'].join(' '),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (!answerChecked)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Wrap(
                      spacing: 8,
                      children: List.generate(
                        options.length,
                        (index) => GestureDetector(
                          onTap: () {
                            if (!answerChecked) {
                              setState(() {
                                if (selectedWords.contains(options[index])) {
                                  selectedWords.remove(options[index]);
                                } else {
                                  selectedWords.add(options[index]);
                                }
                              });
                            }
                          },
                          child: Chip(
                            label: Text(
                              options[index],
                              style: TextStyle(
                                color: answerChecked &&
                                        correctAnswer[isEnglish ? 'en' : 'ph'].contains(options[index])
                                    ? Colors.green
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            backgroundColor:
                                selectedWords.contains(options[index])
                                    ? Colors.grey.withOpacity(0.3)
                                    : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: answerChecked &&
                                        correctAnswer[isEnglish ? 'en' : 'ph'].contains(options[index])
                                    ? Colors.green
                                    : Colors.grey,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              if (!answerChecked)
                ElevatedButton(
                  onPressed: selectedWords.isNotEmpty
                      ? () {
                          checkAnswer();
                          if (selectedWords.join(' ') ==
                              correctAnswer[isEnglish ? 'en' : 'ph'].join(' ')) {
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
