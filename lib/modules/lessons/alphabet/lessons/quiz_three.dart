import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:sign_buddy/modules/firestore_data/lesson_alphabet.dart';
import 'package:sign_buddy/modules/lessons/alphabet/lessons/lesson_one.dart';
import 'package:sign_buddy/modules/lessons/alphabet/lessons/quiz_four.dart';
import 'package:sign_buddy/modules/lessons/alphabet/letters.dart';
import 'package:sign_buddy/modules/lessons/alphabet/letters_confirm_dialog.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_buddy/modules/sharedwidget/shuffle_options.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QuizThree extends StatefulWidget {
  final String lessonName;

  const QuizThree({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<QuizThree> createState() => _QuizThreeState();
}

class _QuizThreeState extends State<QuizThree> {
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
      setState(() {
        isLoading = false;
      });
    }
  }

  void getContent5DataByName(String lessonName) async {
    
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData = 
      await LetterLessonFireStore(userId: userId!)
          .getLessonData(lessonName, isEnglish ? "en" : "ph");


      if(lessonData != null && lessonData.containsKey('content5')) {
        Map<String,dynamic> content5data = 
        lessonData['content5'] as Map<String, dynamic>; 
        Iterable<dynamic> _contentImage = content5data['contentImage'];
        String description = content5data['description'] as String;
        
        Iterable<dynamic> _contentOption = content5data['contentOption'];
        Iterable<dynamic> _correctAnswer = content5data['correctAnswer'];

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
      if (progress < 79) {
        // Increment the progress value only if it's less than 47
        LetterLessonFireStore(userId: uid).incrementProgressValue(widget.lessonName, isEnglish ? "en" : "ph", 16);
        print("Progress 5 updated successfully!");
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
        selectedOption = ''; // Reset selectedOption
      });
    });
  }

  void _nextPage() {
    

    Navigator.pushReplacement(
      context, SlidePageRoute(page: QuizFour(lessonName: widget.lessonName))
    );
    if(mounted) {
      setState(() {
        selectedOption = '';
        answerChecked = false;
      });
    }
  }
      Future<bool> _onWillPop() async {
      _showExitConfirmationDialog();
        return false;
      }

      // function that calls the confirmation dialog
      void _showExitConfirmationDialog() {
        ExitConfirmationDialog.show(context, isEnglish);
      }


  @override
  Widget build(BuildContext context) {
     return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 209, 209, 209),
            title: Text(isEnglish ? 'Lesson Quiz' : 'Pagsusulit sa Aralin', style: TextStyle(color: Colors.black, fontSize: 16)),
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
            iconTheme: IconThemeData(color: Colors.black), 
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _onWillPop,
            ),
          ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Text(
                contentDescription,
                style: TextStyle(fontSize: 18),
              ),
              if (contentImage.isNotEmpty)
              GestureDetector(
                onTap: ()  {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          contentPadding: EdgeInsets.all(
                              10), 
                          content: Container(
                            color: Colors.white,
                            child: ClipRRect(
                            child: CachedNetworkImage(
                            imageUrl: contentImage[0],
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                                                  ),
                                                  ),
                          ),
                      ),
                    );
                  },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 20),
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
              ),
              SizedBox(height: 20),
              isLoading
                ? CircularProgressIndicator() // Display loading indicator
                : _buildYesNoOption(),
              SizedBox(height: 20), // Add spacing for the "Check" button
              Expanded(
                child: Builder(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYesNoOption() {
  List<String> options = contentOption.cast<String>(); // Ensure that options are of type String

  bool isAnswerChecked = answerChecked;
  String selectedOption = this.selectedOption;

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: options.map((option) {
      bool isOptionSelected = selectedOption == option;
      bool isCorrectAnswer = correctAnswer.contains(option);

      Color tileColor = isOptionSelected
          ? (isAnswerChecked
              ? (isCorrectAnswer
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3))
              : Colors.grey.withOpacity(0.2))
          : Colors.transparent;

      IconData icon = isCorrectAnswer
          ? FontAwesomeIcons.thumbsUp
          : FontAwesomeIcons.thumbsDown;

      return GestureDetector(
        onTap: () {
          if (!isAnswerChecked) {
            setState(() {
              this.selectedOption = option;
            });
          }
        },
        child: Container(
          width: 70,
          height: 70,
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: tileColor,
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Color(0xFF5BD8FF),
                size: 25,
              ),
              SizedBox(height: 5),
              Text(
                option,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}

}
