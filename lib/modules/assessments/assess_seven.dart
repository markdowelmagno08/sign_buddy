import 'package:flutter/material.dart';
import 'package:sign_buddy/modules/assessments/assess_eight.dart';
import 'package:sign_buddy/modules/assessments/shuffle_options.dart';
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
  List<String> selectedWords = []; // List to store the user's selected words

  final List<Map<String, dynamic>> assessmentQuestions = [
    {
      'question': 'What sentence does this sign language represent?',
      'videoUrl':
          'assets/dictionary/phrases/have_a_nice_day.gif', // Replace with the path to your GIF file
      'options': [
        'My',
        'moon',
        'nice',
        'man',
        'day',
        'Have',
        'a',
        'yes',
        '?',
      ], // Add your word options here
      'correctAnswer': [
        'Have',
        'a',
        'nice',
        'day'
      ], // Add the correct sentence here as a list of words
    },
  ];

  void checkAnswer() {
    setState(() {
      answerChecked = true;
      List<String> correctAnswer =
          assessmentQuestions[currentIndex]['correctAnswer'];
      if (selectedWords.join(' ') == correctAnswer.join(' ')) {
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
    String videoUrl = currentQuestion['videoUrl'];
    List<String> options = (currentQuestion['options'] as List).cast<String>();
    List<String> correctAnswer =
        currentQuestion['correctAnswer'].cast<String>();

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
                "Create a sentence by selecting the word options below",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Assessment 7: ${question}",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Display GIF
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
                  videoUrl,
                  fit: BoxFit.cover,
                ),
              ),
    
              const Center(
                child: Text(
                  'Your Answer:',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
    
              // Display selected words or correct answer if checked
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
                  if (answerChecked) // <-- Display "Correct Answer" when answer is checked
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        const Center(
                          child: Text(
                            'Correct Answer:',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            correctAnswer.join(' '),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
    
              const SizedBox(height: 10),
    
              // Display Word Choices if not checked
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
                                        correctAnswer.contains(options[index])
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
                                        correctAnswer.contains(options[index])
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
    
              // ... (other widgets)
    
              if (!answerChecked)
                ElevatedButton(
                  onPressed: selectedWords.isNotEmpty
                      ? () {
                          checkAnswer();
                          if (selectedWords.join(' ') ==
                              correctAnswer.join(' ')) {
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
