import 'package:flutter/material.dart';
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

  final List<Map<String, dynamic>> assessmentQuestions = [
    {
      'question': 'What is being signed here? ',
      'matches': [
        {
          'video': 'assets/assess-img/question-eight/boyfriend.gif',
          'word': 'Boyfriend',
        },
        {
          'video': 'assets/assess-img/question-eight/nephew.gif',
          'word': 'Nephew',
        },
      ],
    },
    // Add more questions here if needed
  ];

  @override
  void initState() {
    super.initState();
    shuffleOptions(assessmentQuestions);
  }

  void shuffleOptions(List<Map<String, dynamic>> questions) {
    for (var question in questions) {
      List<Map<String, dynamic>> matches =
          List<Map<String, dynamic>>.from(question['matches']);

      // Shuffle the 'matches' list for each question
      matches.shuffle();

      // Shuffle the order of videos and words separately
      List<dynamic> shuffledVideos =
          List<dynamic>.from(matches.map((match) => match['video']));
      List<dynamic> shuffledWords =
          List<dynamic>.from(matches.map((match) => match['word']));
      shuffledVideos.shuffle();
      shuffledWords.shuffle();

      // Pair the shuffled videos and words back together
      List<Map<String, dynamic>> shuffledMatches = [];
      for (int i = 0; i < shuffledVideos.length; i++) {
        shuffledMatches.add({
          'video': shuffledVideos[i],
          'word': shuffledWords[i],
        });
      }

      question['matches'] = shuffledMatches;
    }
  }

  void checkAnswer() {
    setState(() {
      answerChecked = true;
      if (selectedVideoIndex != -1 && selectedWordIndex != -1) {
        String selectedVideo = assessmentQuestions[currentIndex]['matches']
            [selectedVideoIndex]['video'];
        String selectedWord = assessmentQuestions[currentIndex]['matches']
            [selectedWordIndex]['word'];

        if ((selectedVideo ==
                    'assets/assess-img/question-eight/boyfriend.gif' &&
                selectedWord == 'Boyfriend') ||
            (selectedVideo == 'assets/assess-img/question-eight/nephew.gif' &&
                selectedWord == 'Nephew')) {
          score++;
        }
      }
    });
  }

  void nextQuestion() {
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
              label: 'Next',
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
    List<dynamic> videoUrls = matches.map((match) => match['video']).toList();
    List<dynamic> options = matches.map((match) => match['word']).toList();

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
                "Match the sign language video with the correct word.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              Text(
                "Assessment 8: ${question}",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              Text(
                "*Double tap the video for a closer look",
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Color.fromARGB(255, 121, 121, 121) // Add this line to make the text italic
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
                                        match['video']!,
                                        fit: BoxFit.contain, // Adjust the fit as needed.
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
    
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ?Colors.deepPurpleAccent : Colors.grey,
                                  width: 1,
                                ),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                match['video']!,
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
                                  match['word']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color:
                                        isSelected ? Colors.deepPurpleAccent : Colors.black,
                                  ),
                                ),
                              ),
                              
                            )
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
                            String selectedVideo = videoUrls[selectedVideoIndex];
                            String selectedWord = options[selectedWordIndex];
    
                            if ((selectedVideo ==
                                        'assets/assess-img/question-eight/boyfriend.gif' &&
                                    selectedWord == 'Boyfriend') ||
                                (selectedVideo ==
                                        'assets/assess-img/question-eight/nephew.gif' &&
                                    selectedWord == 'Nephew')) {
                              showResultSnackbar(
                                context,
                                'Correct',
                                FontAwesomeIcons.solidCircleCheck,
                              );
                              score++;
                            } else {
                              showResultSnackbar(
                                context,
                                'Incorrect',
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
                  child: const Text('Check'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}