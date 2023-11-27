import 'package:flutter/material.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/modules/firestore_data/lesson_alphabet.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:sign_buddy/modules/lessons/alphabet/lessons/lesson_one.dart';
import 'package:sign_buddy/modules/lessons/alphabet/lessons/quiz_three.dart';
import 'package:sign_buddy/modules/lessons/alphabet/letters.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/lessons/alphabet/shuffle_options.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QuizTwo extends StatefulWidget {
  final String lessonName;

  const QuizTwo({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<QuizTwo> createState() => _QuizTwoState();
}

class _QuizTwoState extends State<QuizTwo> {
  String contentDescription = "";
  String uid = "";
  List<dynamic> contentOption = [];
  List<dynamic> correctAnswer = [];
  List<dynamic> contentImage = [];

  String selectedOption = '';
  bool answerChecked = false;
  bool progressAdded = false; // Track whether progress has been added
  bool isLoading = true;
  bool isEnglish = true;
  int progress = 0;
  

  @override
  void initState() {
    super.initState();
    getLanguage().then((value) {
      getContent4DataByName(widget.lessonName);
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
      await LetterLessonFireStore(userId: userId!)
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
            'By Progress: Letter lesson "$lessonName" was not found within the Firestore.');
        isLoading = true;
      }
    } catch (e) {
      print('Error reading letter_lessons.json: $e');
      if(mounted) {
      setState(() {
        isLoading = false;
      });
    }
    }
  }

  void getContent4DataByName(String lessonName) async {
    
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData = 
      await LetterLessonFireStore(userId: userId!)
          .getLessonData(lessonName, isEnglish ? "en" : "ph");


      if(lessonData != null && lessonData.containsKey('content4')) {
        Map<String,dynamic> content4data = 
        lessonData['content4'] as Map<String, dynamic>; 
        Iterable<dynamic> _contentImage = content4data['contentImage'];
        String description = content4data['description'] as String;
        
        Iterable<dynamic> _contentOption = content4data['contentOption'];
        Iterable<dynamic> _correctAnswer = content4data['correctAnswer'];

        // Shuffle the contentOption list using the imported function
        _contentOption = shuffleIterable(_contentOption);

        _contentImage = await Future.wait(_contentImage.map((e) => AssetFirebaseStorage().getAsset(e)));


        if(mounted) {
          setState(() {
            contentDescription = description;
            contentImage = _contentImage.toList();
            correctAnswer.addAll(_correctAnswer);
            contentOption.addAll(_contentOption);
            uid = userId;
            isLoading = false;
          });
        } else {
          print(
            'By Content: Letter lesson "$lessonName" was not found within the Firestore.');
          isLoading = true;
        }

      }
    } catch (e) {
        print('Error reading letter_lessons.json: $e');
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
      }
    }

  



  
  void _checkAnswer() async {
    // Check if the selected option is in the list of correct answers
    bool isAnswerCorrect = correctAnswer.contains(selectedOption);

    if(mounted) {
      setState(() {
        answerChecked = true;
      });
    }

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
      resultMessage = isAnswerCorrect ? 'Tama' : 'Mali'; // Adjust these translations as needed
    }

    if (isAnswerCorrect) {
      if (progress < 63) {
        // Increment the progress value only if it's less than 47
        LetterLessonFireStore(userId: uid).incrementProgressValue(widget.lessonName, isEnglish ? "en" : "ph", 16);
        print("Progress 4 updated successfully!");
      }
    }

    showResultSnackbar(context, resultMessage, icon, () {
      if (isAnswerCorrect) {
        _nextPage();
      } else {
        Navigator.pushReplacement(
          context,
          SlidePageRoute(page: LessonOne(lessonName: widget.lessonName)),
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
        selectedOption = ''; // Reset selectedOption
      });
    });
  }

  void _nextPage() async {
    Navigator.pushReplacement(
      context,
      SlidePageRoute(page: QuizThree(lessonName: widget.lessonName)),
    );

    if(mounted) {
      setState(() {
        selectedOption = '';
        answerChecked = false;
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
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
                    SlidePageRoute(page: Letters()),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Lesson quiz for: "${widget.lessonName}"', 
                style: TextStyle(
                  fontSize: 20, // Adjust the font size as needed
                  fontWeight: FontWeight.bold, // Optionally make it bold
                ),
              ),
            ),
            const SizedBox(height: 50),

            Text(
              contentDescription,
              style: TextStyle(fontSize: 18),
            ),
            if (contentImage.isNotEmpty) // Check if there's an image to display
              Container(
                padding: const EdgeInsets.all(0.0),
                margin: const EdgeInsets.symmetric(horizontal: 90, vertical: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey, // Border color
                    width: 2, // Border width
                  ),
                  color: Colors.white, // Color inside the border
                  // Border radius
                ),
                child: CachedNetworkImage(
                    imageUrl: contentImage[0],
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
              ),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(), // Display option loading indicator
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: 60
                      ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: contentOption.length,
                      itemBuilder: (context, index) {
                        return _buildLetterOption(
                          contentOption[index]
                        );
                      },
                    ),
            ),
            Builder(
              builder: (context) {
                return Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Visibility(
                      visible: !answerChecked,
                      child: ElevatedButton(
                        onPressed: selectedOption.isNotEmpty ? _checkAnswer : null,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            selectedOption.isNotEmpty
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
                                color: selectedOption.isNotEmpty
                                    ? Colors.grey.shade700
                                    : Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                isEnglish ? 'Check' : 'Tsek',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: selectedOption.isNotEmpty
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
      ),
    );
  }

  Widget _buildLetterOption(String option) {

    bool isSelected = selectedOption == option;
    Color tileColor =
        isSelected ? Colors.grey.withOpacity(0.5) : Colors.transparent;

    if (answerChecked) {
       bool isCorrectAnswer = correctAnswer.contains(option);
      if (isCorrectAnswer) {
        tileColor = Colors.green.withOpacity(0.3); // Correct answer color
      } else if (isSelected) {
        tileColor =
            Colors.red.withOpacity(0.3); // Incorrect selected answer color
      }
    }

    return GestureDetector(
      onTap: () {
        if (!answerChecked) {
          if(mounted) {
            setState(() {
              selectedOption = option;
            });
          }
        }
      },
      child: SizedBox(
        height: 10, // Adjust the height as needed
        width: 10,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: tileColor,
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              option,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
