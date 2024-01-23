import 'package:flutter/material.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/modules/firestore_data/lesson_alphabet.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/firestore_data/lesson_animals.dart';

import 'package:sign_buddy/modules/lessons/animals/animals.dart';
import 'package:sign_buddy/modules/lessons/animals/animals/lessons_one.dart';
import 'package:sign_buddy/modules/lessons/animals/animals/quiz_four.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_buddy/modules/sharedwidget/shuffle_options.dart';
import 'package:cached_video_player/cached_video_player.dart';


class AnimalsQuizThree extends StatefulWidget {
  final String lessonName;

  const AnimalsQuizThree({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<AnimalsQuizThree> createState() => _AnimalsQuizFourState();
}

class _AnimalsQuizFourState extends State<AnimalsQuizThree> {
  String contentDescription = "";
  String uid = "";
  List<dynamic> contentOption = [];
  List<dynamic> correctAnswer = [];
  List<dynamic> contentVideo = [];
  CachedVideoPlayerController? _videoController;
  bool isSlowMotion = false;

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
  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
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
      await AnimalsLessonFireStore(userId: userId!)
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
            'By Progress: Animals lesson "$lessonName" was not found within the Firestore.');
        isLoading = true;
      }
    } catch (e) {
      print('Error reading animals_lessons.json: $e');
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
      await AnimalsLessonFireStore(userId: userId!)
          .getLessonData(lessonName, isEnglish ? "en" : "ph");


      if(lessonData != null && lessonData.containsKey('content5')) {
        Map<String,dynamic> content5data = 
        lessonData['content5'] as Map<String, dynamic>; 
        Iterable<dynamic> _contentVideo = content5data['contentImage'];
        String description = content5data['description'] as String;
        
        Iterable<dynamic> _contentOption = content5data['contentOption'];
        Iterable<dynamic> _correctAnswer = content5data['correctAnswer'];

        // Shuffle the contentOption list using the imported function
        _contentOption = shuffleIterable(_contentOption);

        _contentVideo = await Future.wait(_contentVideo.map((e) => AssetFirebaseStorage().getAsset(e)));


        if(mounted) {
          setState(() {
            contentDescription = description;
            contentVideo = _contentVideo.toList();
            correctAnswer.addAll(_correctAnswer);
            contentOption.addAll(_contentOption);
            uid = userId;
            isLoading = false;

            // Initialize the video player with the first video URL
            if (contentVideo.isNotEmpty) {
              _videoController =
              setupVideoController(Uri.parse(contentVideo[0]));
              _videoController!.play();
            }
          });
        } else {
          print(
            'By Content: Animals lesson "$lessonName" was not found within the Firestore.');
          isLoading = true;
        }

      }
    } catch (e) {
        print('Error reading animals_lessons.json: $e');
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
        AnimalsLessonFireStore(userId: uid).incrementProgressValue(widget.lessonName, isEnglish ? "en" : "ph", 20);
        print("Progress 6 updated successfully!");
      }
    }

    showResultSnackbar(context, resultMessage, icon, () {
      if (isAnswerCorrect) {
        _nextPage();
      } else {
        Navigator.pushReplacement(
          context,
          SlidePageRoute(page: AnimalsLessonOne(lessonName: widget.lessonName)),
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
    context, SlidePageRoute(page: AnimalsQuizFour(lessonName: widget.lessonName))
    );
    if(mounted) {
      setState(() {
        selectedOption = '';
        answerChecked = false;
        if (_videoController != null) {
          _videoController!.pause();
          _videoController!.dispose();
          _videoController = null;
        }
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          return true;
        },
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
              onPressed: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                Navigator.pushReplacement(context, SlidePageRoute(page: Animals()));
              },
            ),
          ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 70),
              Text(
                contentDescription,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              if (contentVideo.isNotEmpty)
                buildVideoDisplay(),
                SizedBox(height: 20),
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
                          mainAxisExtent: 50
                        ),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: contentOption.length,
                        itemBuilder: (context, index) {
                          return _buildWordOption(
                            contentOption[index],
                          );
                        },
                      ),
              ),
              SizedBox(height: 20), // Add spacing for the "Check" button
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
      ),
    );
  }

  Widget buildVideoDisplay() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      return Column(
        children: [
          GestureDetector(
            onTap: () {
              if (_videoController != null) {
                _videoController!.seekTo(Duration.zero);
                _videoController!.play();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0,
                ),
                color: Colors.white,
              ),
              height: 190, // Adjust the height as needed
              width: 300, // Adjust the width as needed
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: CachedVideoPlayer(_videoController!),
              ),
            ),
          ),    
        ],
      );
      
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget _buildWordOption(String option) {
      
    bool isSelected = selectedOption == option;
    Color tileColor =
        isSelected ? Colors.grey.withOpacity(0.5) : Colors.transparent;

    if (answerChecked && isSelected) {
      bool isCorrectAnswer = correctAnswer.contains(option);
      tileColor = isCorrectAnswer ? Colors.green.withOpacity(0.3): Colors.red.withOpacity(0.3);
    }

    return GestureDetector(
      onTap: () {
        if (!answerChecked) {
          setState(() {
            selectedOption = option;
          });
        }
      },
      child: SizedBox(
        child: Container(
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
