import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/firestore_data/lesson_numbers.dart';
import 'package:sign_buddy/modules/lessons/numbers/number_lessons/lesson_one.dart';
import 'package:sign_buddy/modules/lessons/numbers/number_lessons/lesson_result.dart';
import 'package:sign_buddy/modules/lessons/numbers/numbers.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';

class NumberQuizThree extends StatefulWidget {
  final String lessonName;

  const NumberQuizThree({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<NumberQuizThree> createState() => _NumberQuizThreeState();
}

class _NumberQuizThreeState extends State<NumberQuizThree> {
  String contentDescription = "";
  String uid = "";
  List<dynamic> correctAnswer = [];
  List<dynamic> contentImage = [];
  TextEditingController _textController = TextEditingController();


  bool answerChecked = false;
  bool progressAdded = false; // Track whether progress has been added
  bool isLoading = true;
  bool isEnglish = true;
  int progress = 0;
  bool isAnswerCorrect = false;
  
  

  @override
  void initState() {
    super.initState();
    getLanguage().then((value) {
      if (progress >= 90) {
      NumberLessonFireStore(userId: uid)
          .unlockLesson(widget.lessonName, isEnglish ? "en" : "ph");
    }
      
      getContent5DataByName(widget.lessonName);
      getProgress(widget.lessonName);
    });
  }

  
  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true; // Default to English.

    if (mounted) {
      setState(() {
        this.isEnglish = isEnglish;
      });
    }
  }
  Future<void> getProgress(String lessonName) async {
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData =
      await NumberLessonFireStore(userId: userId!)
            .getUserLessonData(lessonName, isEnglish ? "en" : "ph");

      // ignore: unnecessary_null_comparison
      if (lessonData != null) {
        if (mounted) {
          setState(() {
            progress = lessonData['progress'];
            uid = userId;
            isLoading = false;
          });
        }

      } else {
        print(
            'By Progress: Number lesson "$lessonName" was not found within the Firestore.');
        isLoading = true;
      }
    } catch (e) {
      print('Error reading number_lessons.json: $e');
      if(mounted) {
      setState(() {
        isLoading = false;
      });
    }
    }
  }

  void getContent5DataByName(String lessonName) async {
    
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData = 
      await NumberLessonFireStore(userId: userId!)
          .getLessonData(lessonName, isEnglish ? "en" : "ph");


      if(lessonData != null && lessonData.containsKey('content5')) {
        Map<String,dynamic> content5data = 
        lessonData['content5'] as Map<String, dynamic>; 
        Iterable<dynamic> _contentImage = content5data['contentImage'];
        String description = content5data['description'] as String;
        
        Iterable<dynamic> _correctAnswer = content5data['correctAnswer'];



        _contentImage = await Future.wait(_contentImage.map((e) => AssetFirebaseStorage().getAsset(e)));


        if(mounted) {
          setState(() {
            contentDescription = description;
            contentImage = _contentImage.toList();
            correctAnswer.addAll(_correctAnswer);
            uid = userId;
            isLoading = false;
          });
        } else {
          print(
            'By Content: Number lesson "$lessonName" was not found within the Firestore.');
          isLoading = true;
        }

      }
    } catch (e) {
        print('Error reading number_lessons.json: $e');
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
      }
    }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  



  
  void _checkAnswer() async {

    // Update the state to show the result
    if (mounted) {
      setState(() {
        answerChecked = true;
      });
    }

    // Get the entered answer as a string
    String enteredAnswer = _textController.text.trim();

    // Check if the entered answer is correct
    isAnswerCorrect = correctAnswer.contains(enteredAnswer);

    
    IconData icon;
    String resultMessage;

    if (isEnglish) {
      icon = isAnswerCorrect
          ? FontAwesomeIcons.solidCircleCheck
          : FontAwesomeIcons.solidCircleXmark;
      resultMessage = isAnswerCorrect ? 'Correct' : 'Incorrect';
    } else {
      // Use Filipino language icons and messages
      icon = isAnswerCorrect
          ? FontAwesomeIcons.solidCircleCheck
          : FontAwesomeIcons.solidCircleXmark;
      resultMessage = isAnswerCorrect ? 'Tama' : 'Mali'; 
    }

    if (isAnswerCorrect) {
      if (progress < 95) {
        // Increment the progress value only if it's less than 63
        NumberLessonFireStore(userId: uid)
            .incrementProgressValue(widget.lessonName, isEnglish ? "en" : "ph", 25);
        print("Progress updated successfully!");
      }
    }

    showResultSnackbar(context, resultMessage, icon, () {
      if (isAnswerCorrect) {
        _nextPage();
      } else {
        Navigator.pushReplacement(
          context,
          SlidePageRoute(page: NumberLessonOne(lessonName: widget.lessonName)),
        );
      }
    });
  }

  void showResultSnackbar(BuildContext context, String message, IconData icon,
      [VoidCallback? callback]) {
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
            // behavior: SnackBarBehavior.floating, 
            backgroundColor: backgroundColor,
            duration: const Duration(days: 365), // Change duration as needed
            dismissDirection: DismissDirection.none,
            action: SnackBarAction(
              label: isEnglish ? 'Next' : 'Susunod',
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
        answerChecked = false;
      });
    });
        
  }

  void _nextPage() async {
    Navigator.pushReplacement(
      context,
      SlidePageRoute(page: Result(lessonName: widget.lessonName)),
    );

    if(mounted) {
      setState(() {
        answerChecked = false;
      });
    }
  }

  

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Padding(
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
                    SlidePageRoute(page: Number()),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Lesson Quiz for: "${widget.lessonName.startsWith('0') ? widget.lessonName.substring(1) : widget.lessonName}"',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 50),

            Text(
              contentDescription,
              style: TextStyle(fontSize: 18),
            ),
            if (contentImage.isNotEmpty)
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: contentImage[0],
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: answerChecked
                      ? [
                          Center(
                            child: Text(
                              'Your answer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Text(
                              _textController.text,
                              style: TextStyle(
                                color: answerChecked
                                    ? (isAnswerCorrect ? Colors.green : Colors.red)
                                    : Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ]
                      : [
                          Container(
                          margin: const EdgeInsets.symmetric(horizontal: 30),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _textController.text = value;
                              });
                            },
                            controller: _textController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 3, 
                            decoration: InputDecoration(
                              labelText: 'Enter a number',
                              labelStyle: TextStyle(
                                color: _textController.text.isNotEmpty
                                    ? Colors.deepPurpleAccent // Set color when the TextField has text
                                    : Colors.grey, // Set color when the TextField is empty
                              ),
                              border: OutlineInputBorder(),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ],
                  ),
                  Builder(
                    builder: (context) {
                      return Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 150),
                          child: Visibility(
                            visible: !answerChecked,
                            child: ElevatedButton(
                              onPressed: _textController.text.isNotEmpty ? _checkAnswer : null,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  _textController.text.isNotEmpty
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
                                      color: _textController.text.isNotEmpty
                                          ? Colors.grey.shade700
                                          : Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      isEnglish ? 'Check' : 'Tsek',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: _textController.text.isNotEmpty
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
          ],
        ),
      ),
    ),
  );
}
}
