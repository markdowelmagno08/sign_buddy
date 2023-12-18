import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/firestore_data/lesson_animals.dart';
import 'package:sign_buddy/modules/lessons/animals/animals.dart';
import 'package:sign_buddy/modules/lessons/animals/animals/lessons_one.dart';
import 'package:sign_buddy/modules/lessons/animals/animals/quiz_two.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_buddy/modules/sharedwidget/shuffle_options.dart';
import 'package:cached_network_image/cached_network_image.dart';


class AnimalsQuizOne extends StatefulWidget {
  final String lessonName;

  const AnimalsQuizOne({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<AnimalsQuizOne> createState() => _AnimalsQuizOneState();
}

class _AnimalsQuizOneState extends State<AnimalsQuizOne> {
  String contentDescription = "";
  String uid = "";
  List<dynamic> contentOption = [];
  List<dynamic> correctAnswer = [];
  List<dynamic> contentVideo = [];
  CachedVideoPlayerController? _videoController;

  String selectedOption = '';
  bool answerChecked = false;
  bool progressAdded = false; 
  bool isLoading = true;
  bool isEnglish = true;
  int progress = 0;
  bool isSlowMotion = false;

  @override
  void initState() {
    super.initState();
    getLanguage().then((value) {
      getContent3DataByName(widget.lessonName);
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
      await AnimalsLessonFireStore(userId: userId!)
            .getUserLessonData(lessonName, isEnglish ? 'en' : 'ph');

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
            'By Progress: animals lesson "$lessonName" was not found within the Firestore.');
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

 void getContent3DataByName(String lessonName) async {
    
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData = 
      await AnimalsLessonFireStore(userId: userId!)
          .getLessonData(lessonName, isEnglish ? "en" : "ph");


      if(lessonData != null && lessonData.containsKey('content3')) {
        Map<String,dynamic> content3data = 
        lessonData['content3'] as Map<String, dynamic>; 
        String description = content3data['description'] as String;
        Iterable<dynamic> _contentVideo = content3data['contentImage'];
        Iterable<dynamic> _contentOption = content3data['contentOption'];
        Iterable<dynamic> _correctAnswer = content3data['correctAnswer'];

        // Shuffle the contentOption list using the imported function
        _contentOption = shuffleIterable(_contentOption);

        _contentOption = await Future.wait(_contentOption.map((e) => AssetFirebaseStorage().getAsset(e)));
        _correctAnswer =  await Future.wait(_correctAnswer.map((e) => AssetFirebaseStorage().getAsset(e)));
        _contentVideo = await Future.wait(
            _contentVideo.map((e) => AssetFirebaseStorage().getAsset(e)));

        if(mounted) {
          setState(() {
            contentDescription = description;
            contentVideo = _contentVideo.toList();
            contentOption = _contentOption.toList();
            correctAnswer = _correctAnswer.toList();
            uid = userId;
            isLoading = false;

            // Initialize the video player with the first video URL
            if (contentVideo.isNotEmpty) {
              _videoController =
                  setupVideoController(Uri.parse(contentVideo[0]));
            }
          });
        } else {
          print(
            'By Content: animals lesson "$lessonName" was not found within the Firestore.');
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

 

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

    
   

  void _checkAnswer() async {
  // Check if the selected option is in the list of correct answers
  bool isAnswerCorrect = correctAnswer.contains(selectedOption);

  setState(() {
    answerChecked = true;
  });

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
    if (progress < 39) {
      // Increment the progress value only if it's less than 47
      AnimalsLessonFireStore(userId: uid).incrementProgressValue(widget.lessonName, isEnglish ? "en" : "ph", 20);
      print("Progress 3 updated successfully!");
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

  void _nextPage() async {
    Navigator.pushReplacement(
      context,
      SlidePageRoute(page: AnimalsQuizTwo(lessonName: widget.lessonName)),
    );

      if(mounted) {
        setState(() {
          progressAdded = false; // Reset progressAdded
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

 

  @override
    Widget build(BuildContext context) {
      return isLoading
          ? Center(
            child: CircularProgressIndicator(),
          )
          :Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 209, 209, 209),
          title: Text(isEnglish ? 'Lesson Quiz' : 'Pagsusulit sa Aralin', style: TextStyle(color: Colors.black, fontSize: 16)),
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(60),
              bottomRight: Radius.circular(60),
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black), // Set the icon color
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.pushReplacement(context, SlidePageRoute(page: Animals()));// This will pop the current screen
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Text(
                contentDescription,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              if (contentVideo.isNotEmpty) buildVideoDisplay(),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(contentOption.length, (index) {
                    return _buildImageOption(contentOption[index]);
                  }),
                ),
              ),
              Builder(
                builder: (context) {
                  return Align(
                    alignment: Alignment.bottomRight,
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
                  );
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    }


  Widget _buildImageOption(String option) {
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
      child: Container(
        padding: EdgeInsets.all(20),// Adjust the height as needed
        decoration: BoxDecoration(
          color: tileColor,
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: option,
            fit: BoxFit.cover,
            placeholder: (context, url) => CircularProgressIndicator(), // You can customize the placeholder
            errorWidget: (context, url, error) => Icon(Icons.error), // You can customize the error widget
          ),
        ),
      ),
    );
  }

}
