import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:sign_buddy/modules/firestore_data/lesson_color.dart';
import 'package:sign_buddy/modules/lessons/color/color.dart';
import 'package:sign_buddy/modules/lessons/color/color_confirm_dialog.dart';
import 'package:sign_buddy/modules/lessons/color/color_lessons/lesson_one.dart';
import 'package:sign_buddy/modules/lessons/color/color_lessons/quiz_four.dart';
import 'package:sign_buddy/modules/lessons/alphabet/letters_confirm_dialog.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_buddy/modules/sharedwidget/shuffle_options.dart';


class ColorQuizThree extends StatefulWidget {
  final String lessonName;

  const ColorQuizThree({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<ColorQuizThree> createState() => _ColorQuizThreeState();
}

class _ColorQuizThreeState extends State<ColorQuizThree> {
  String contentDescription = "";
  String uid = "";
  List<dynamic> contentOption = [];
  List<dynamic> correctAnswer = [];
// Declare a list of CachedVideoPlayerController
  List<CachedVideoPlayerController?> _videoControllers = [];
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
      await ColorLessonFireStore(userId: userId!)
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
            'By Progress: Colors lesson "$lessonName" was not found within the Firestore.');
        isLoading = true;
      }
    } catch (e) {
      print('Error reading colors_lessons.json: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void getContent4DataByName(String lessonName) async {
  try {
    final userId = Auth().getCurrentUserId();
    Map<String, dynamic>? lessonData =
        await ColorLessonFireStore(userId: userId!)
            .getLessonData(lessonName, isEnglish ? "en" : "ph");

    if (lessonData != null && lessonData.containsKey('content4')) {
      Map<String, dynamic> content4data =
          lessonData['content4'] as Map<String, dynamic>;
      String description = content4data['description'] as String;

      Iterable<dynamic> _contentOption = content4data['contentOption'];
      Iterable<dynamic> _correctAnswer = content4data['correctAnswer'];

      // Shuffle the contentOption list using the imported function
      _contentOption = shuffleIterable(_contentOption); 
      _correctAnswer =  await Future.wait(_correctAnswer.map((e) => AssetFirebaseStorage().getAsset(e)));
      _contentOption =
          await Future.wait(_contentOption.map((e) => AssetFirebaseStorage().getAsset(e)));

      if (mounted) {
        setState(() {
          contentDescription = description;
          contentOption = _contentOption.toList();
          correctAnswer = _correctAnswer.toList();
          uid = userId;
          isLoading = false;

          if (contentOption.isNotEmpty) {
             // Initialize _videoControllers list for each video in contentOption
            _videoControllers = List.generate(
              contentOption.length,
              (index) => setupVideoController(Uri.parse(contentOption[index])),
            );
          }
        });
      } else {
        print(
            'By Content: Colors lesson "$lessonName" was not found within the Firestore.');
        isLoading = true;
      }
    }
  } catch (e) {
    print('Error reading colors_lessons.json: $e');
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
  }
}


  CachedVideoPlayerController setupVideoController(Uri videoUri) {
    final controller = CachedVideoPlayerController.network(
      videoUri.toString(),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
    return controller;
  }

 

Widget _buildVideoOption(CachedVideoPlayerController controller, String option) {
  bool isSelected = selectedOption == option;
  Color borderColor = isSelected ? Colors.deepPurpleAccent : Colors.grey;

  if (answerChecked && isSelected) {
    bool isCorrectAnswer = correctAnswer.contains(option);
    borderColor = isCorrectAnswer ? Colors.green : Colors.red;
  }

  return GestureDetector(
    onTap: () {
      if (!answerChecked) {
        setState(() {
          selectedOption = option;
        });
        controller.seekTo(Duration.zero);
        controller.play();
      }
    },
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: 2.0,
        ),
        color: isSelected ? Colors.grey.withOpacity(0.5) : Colors.transparent,
      ),
      height: 190, // Adjust the height as needed
      width: 300, // Adjust the width as needed
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CachedVideoPlayer(controller),
      ),
    ),
  );
}



  
  Widget buildVideoDisplay() {
    if (_videoControllers.every(
        (controller) => controller != null && controller.value.isInitialized)) {
      return Column(
        children: List.generate(_videoControllers.length, (index) {
          return Column(
            children: [
              _buildVideoOption(_videoControllers[index]!, contentOption[index]),
              SizedBox(height: 20), // Add spacing between videos
            ],
          );
        }),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

 @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller?.pause();
      controller?.dispose();
    }
    super.dispose();
  }
     Future<bool> _onWillPop() async {
     _showExitConfirmationDialog();
     return false;
   }

   // function that calls the confirmation dialog
     void _showExitConfirmationDialog() {
     ColorExitConfirmationDialog.show(context, isEnglish);
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
              const SizedBox(height: 50),
              Text(
                contentDescription,
                style: TextStyle(fontSize: 18,),
              ),
              const SizedBox(height: 20),
              isLoading
                ? CircularProgressIndicator() // Display loading indicator
                : buildVideoDisplay(), // Add spacing for the "Check" button
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
        ColorLessonFireStore(userId: uid).incrementProgressValue(widget.lessonName, isEnglish ? "en" : "ph", 20);
        print("Progress 5 updated successfully!");
      }
    }

    showResultSnackbar(context, resultMessage, icon, () {
      if (isAnswerCorrect) {
        _nextPage();
      } else {
        Navigator.pushReplacement(
          context,
          SlidePageRoute(page: ColorLessonOne(lessonName: widget.lessonName)),
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
    context, SlidePageRoute(page: ColorQuizFour(lessonName: widget.lessonName))
  );

    if (mounted) {
      setState(() {
        progressAdded = false; 
        selectedOption = '';
        answerChecked = false;
        // Dispose all video controllers
        for (var controller in _videoControllers) {
          controller?.pause();          
        }
        
      });
    }
  }



}
