import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/firestore_data/lesson_greetings.dart';
import 'package:sign_buddy/modules/lessons/greetings/greetings.dart';
import 'package:sign_buddy/modules/lessons/greetings/greetings/lessons_one.dart';
import 'package:sign_buddy/modules/lessons/greetings/greetings/quiz_two.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:sign_buddy/modules/sharedwidget/shuffle_options.dart';



class GreetingsQuizOne extends StatefulWidget {
  
  final String lessonName;

  const GreetingsQuizOne({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<GreetingsQuizOne> createState() => _GreetingsQuizOneState();
}

class _GreetingsQuizOneState extends State<GreetingsQuizOne> {

  String contentDescription = "";
  String uid = "";
  List<dynamic> contentOption = [];
  List<dynamic> correctAnswer = [];
  List<dynamic> contentVideo = [];
  CachedVideoPlayerController? _videoController;
  String selectedOption = '';
  bool answerChecked = false;
  bool progressAdded = false; // Track whether progress has been added
   List<String> userSelectedWords = [];
   bool isAnswerCorrect = false;
  
  bool isLoading = true;
  bool isEnglish = true;
  int progress = 0;

  @override
  void initState() {
    super.initState();
    getLanguage().then((value) {
      getContent2DataByName(widget.lessonName);
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
      await GreetingsLessonFireStore(userId: userId!)
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
            'By Progress: Greetings lesson "$lessonName" was not found within the Firestore.');
        isLoading = true;
      }
    } catch (e) {
      print('Error reading greeting_lessons.json: $e');
      if(mounted) {
      setState(() {
        isLoading = false;
      });
      }
    }
  }

  void getContent2DataByName(String lessonName) async {
    
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData = 
      await GreetingsLessonFireStore(userId: userId!)
          .getLessonData(lessonName, isEnglish ? "en" : "ph");


      if(lessonData != null && lessonData.containsKey('content2')) {
        Map<String,dynamic> content2data = 
        lessonData['content2'] as Map<String, dynamic>; 
        Iterable<dynamic> _contentVideo = content2data['contentImage'];
        String description = content2data['description'] as String;
        
        Iterable<dynamic> _contentOption = content2data['contentOption'];
        Iterable<dynamic> _correctAnswer = content2data['correctAnswer'];

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
            'By Content: Greetings lesson "$lessonName" was not found within the Firestore.');
          isLoading = true;
        }

      }
    } catch (e) {
        print('Error reading greeting_lessons.json: $e');
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

  void _checkAnswer() {
  setState(() {
    answerChecked = true;
  });

  // Convert user's selected words to lowercase for case-insensitive comparison
  List<String> lowercaseUserSelectedWords =
      userSelectedWords.map((word) => word.toLowerCase()).toList();

  // Convert correct answer to lowercase for case-insensitive comparison
  List lowercaseCorrectAnswer =
      correctAnswer.map((word) => word.toLowerCase()).toList();

  // Update the isAnswerCorrect variable based on the result of the answer check
  isAnswerCorrect = (lowercaseUserSelectedWords.join(' ') ==
      lowercaseCorrectAnswer.join(' '));

  IconData icon;
  String resultMessage;

  if (isAnswerCorrect) {
    icon = FontAwesomeIcons.solidCircleCheck;
    resultMessage = isEnglish ? 'Correct' : 'Tama';
    if (progress < 39) {
      GreetingsLessonFireStore(userId: uid).incrementProgressValue(
          widget.lessonName, isEnglish ? 'en' : 'ph', 20);
      print('Progress updated successfully!');
    }
  } else {
    icon = FontAwesomeIcons.solidCircleXmark;
    resultMessage = isEnglish ? 'Incorrect' : 'Mali';
  }

  showResultSnackbar(context, resultMessage, icon, () {
    if (isAnswerCorrect) {
      _nextPage();
    } else {
      Navigator.pushReplacement(
        context,
        SlidePageRoute(page: GreetingsLessonOne(lessonName: widget.lessonName)),
      );
    }
  });
}

 

  void _nextPage() {
    
    Navigator.pushReplacement(
    context, SlidePageRoute(page: GreetingsQuizTwo(lessonName: widget.lessonName))
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
    return Scaffold(
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
              Navigator.pushReplacement(context, SlidePageRoute(page: Greetings()));
            },
          ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              contentDescription,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            if (contentVideo.isNotEmpty)
            buildVideoDisplay(),
            SizedBox(height: 20),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Your Answer:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 7),
                  Text(
                    '${userSelectedWords.join(' ')}',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: answerChecked
                          ? (isAnswerCorrect ? Colors.green : Colors.red)
                          : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            buildWordOption(),
            SizedBox(height: 20),
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
                            onPressed: userSelectedWords.isNotEmpty ? _checkAnswer : null,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              userSelectedWords.isNotEmpty
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
                                  color: userSelectedWords.isNotEmpty
                                      ? Colors.grey.shade700
                                      : Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  isEnglish ? 'Check' : 'Tsek',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: userSelectedWords.isNotEmpty
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
    );
  }
   Widget buildWordOption() {
  return Wrap(
    alignment: WrapAlignment.center,
    spacing: 8.0,
    children: List.generate(contentOption.length, (index) {
      final word = contentOption[index];
      return ChoiceChip(
        label: Text(
          '$word',
          style: TextStyle(color: Colors.black),
        ),
        selectedColor: Colors.grey,
        selected: userSelectedWords.contains(word), // Check if word is selected
        onSelected: answerChecked ? null : (_) { // Disable selection if answer is checked
          setState(() {
            if (!userSelectedWords.contains(word)) {
              userSelectedWords.add(word); // Add word to selected list
            } else {
              userSelectedWords.remove(word); // Remove word from selected list
            }
          });
        },
      );
    }),
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
}