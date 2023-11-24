import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/assessments/result.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AssessmentEight extends StatefulWidget {
  final int score;

  const AssessmentEight({Key? key, required this.score}) : super(key: key);

  @override
  _AssessmentEightState createState() => _AssessmentEightState();
}

class _AssessmentEightState extends State<AssessmentEight> {
  int currentIndex = 0;
  int score = 0;
  bool answerChecked = false;
  int selectedVideoIndex = -1;
  int selectedWordIndex = -1;
  bool isEnglish = true;

  final List<Map<String, dynamic>> assessmentQuestions = [
    {
      'question': 'What is being signed here?',
      'matches': [
        {
          'videos': {
            'en': 'assets/dictionary/family/cat.gif',
            'ph': 'assets/dictionary/family/pusa.gif',
          },
          'words': {
            'en': 'Cat',
            'ph': 'Pusa',
          },
        },
        {
          'videos': {
            'en': 'assets/dictionary/family/nephew.gif',
            'ph': 'assets/dictionary/family/pamangkin_na_lalake.gif',
          },
          'words': {
            'en': 'Nephew',
            'ph': 'Pamangkin na Lalaki',
          },
        },
      ],
    },
    // Add more questions here if needed
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

  void shuffleOptions(List<Map<String, dynamic>> questions) {
    for (var question in questions) {
      List<Map<String, dynamic>> matches =
          List<Map<String, dynamic>>.from(question['matches']);

      // Shuffle the 'matches' list for each question
      matches.shuffle();

      question['matches'] = matches;
    }
  }

  void checkAnswer() {
    if(mounted) {
      setState(() {
        answerChecked = true;
        if (selectedVideoIndex != -1 && selectedWordIndex != -1) {
          String languageKey = isEnglish ? 'en' : 'ph';
          String selectedVideo =
              assessmentQuestions[currentIndex]['matches'][selectedVideoIndex]
                  ['videos'][languageKey];
          String selectedWord =
              assessmentQuestions[currentIndex]['matches'][selectedWordIndex]
                  ['words'][languageKey];

          if ( 
            ((selectedVideo ==
                      'assets/dictionary/family/cat.gif' &&
                  selectedWord == 'Cat') || (selectedVideo ==
                      'assets/dictionary/family/pusa.gif' &&
                  selectedWord == 'Pusa')) ||
              ((selectedVideo ==
                      'assets/dictionary/family/nephew.gif' &&
                  selectedWord == 'Nephew') || (selectedVideo ==
                      'assets/dictionary/family/pamangkin_na_lalake.gif' &&
                  selectedWord == 'Pamangkin')  )) {
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
        selectedVideoIndex = -1;
        selectedWordIndex = -1;
        if (currentIndex == assessmentQuestions.length) {
          navigateToResult(context);
        }
      });
    }
  }

  void navigateToResult(BuildContext context) {
    Navigator.push(
      context,
      SlidePageRoute(
        page: AssessmentResult(
          score: widget.score + score,
          totalQuestions: 8,
        ),
      ),
    );
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
            content: Container(
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
                  navigateToResult(context);
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
    List<Map<String, dynamic>> matches =
        List<Map<String, dynamic>>.from(currentQuestion['matches']);
    String languageKey = isEnglish ? 'en' : 'ph';

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
                    ? "Match the sign language video with the correct word"
                    : "Ipareha ang video ng senyas sa tamang salita",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              Text(
                isEnglish ? "Assessment 8: ${question}" : "Pagsusuri 8: Anong senyas ang ginagamit dito?",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              Text(
                isEnglish ? "*Double tap the video for a closer look" : "*I-double tap ang video para mas malapit na tingnan",
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Color.fromARGB(255, 121, 121, 121),
                ),
              ),
              // Display the sign language videos and word choices side by side
              Expanded(
                child: Row(
                  children: [
                    // Display the sign language videos on the left side
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: matches.map((match) {
                          int matchIndex = matches.indexOf(match);
                          bool isSelected = selectedVideoIndex == matchIndex;

                          return GestureDetector(
                            onTap: () {
                              if (!answerChecked) {
                                setState(() {
                                  selectedVideoIndex = matchIndex;
                                });
                              }
                            },
                             onDoubleTap: () {
                              if (!answerChecked) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    contentPadding: EdgeInsets.all(5), // Remove padding around the content
                                    content: Container(
                                      child: Image.asset(
                                         match['videos'][languageKey],
                                        fit: BoxFit.contain, // Adjust the fit as needed.
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },

                            // Display the video based on the language setting
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? Colors.deepPurpleAccent : Colors.grey,
                                  width: 1,
                                ),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                match['videos'][languageKey],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Display the word choices on the right side
                    Expanded(
                      child: Column(
                        children: matches.map((match) {
                          int matchIndex = matches.indexOf(match);
                          bool isSelected = selectedWordIndex == matchIndex;

                          return GestureDetector(
                            onTap: () {
                              if (!answerChecked) {
                                setState(() {
                                  selectedWordIndex = matchIndex;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 36),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? Colors.deepPurpleAccent : Colors.grey,
                                  width: 1,
                                ),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  match['words'][languageKey],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isSelected ? Colors.deepPurpleAccent : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (!answerChecked)
                ElevatedButton(
                  onPressed: selectedVideoIndex != -1 && selectedWordIndex != -1
                      ? () {
                          setState(() {
                            String selectedVideo = assessmentQuestions[currentIndex]['matches'][selectedVideoIndex]['videos'][languageKey];
                            String selectedWord = assessmentQuestions[currentIndex]['matches'][selectedWordIndex]['words'][languageKey];

                          //checks if the selected video or word is match correspondly, it also gets the language using the isEnglish variable
                            if ( 
                              ((selectedVideo ==
                                        'assets/dictionary/family/cat.gif' &&
                                    selectedWord == 'Cat') || (selectedVideo ==
                                        'assets/dictionary/family/pusa.gif' &&
                                    selectedWord == 'Pusa')) ||
                                
                                ((selectedVideo ==
                                        'assets/dictionary/family/nephew.gif' &&
                                    selectedWord == 'Nephew') || (selectedVideo ==
                                        'assets/dictionary/family/pamangkin_na_lalake.gif' &&
                                    selectedWord == 'Pamangkin')  )) {
                              showResultSnackbar(
                                context,
                                isEnglish ? 'Correct' : "Tama",
                                FontAwesomeIcons.solidCircleCheck,
                              );
                              score++;
                            } else {
                              showResultSnackbar(
                                context,
                                isEnglish ? 'Incorrect' : "Mali",
                                FontAwesomeIcons.solidCircleXmark,
                              );
                            }
                          });
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
