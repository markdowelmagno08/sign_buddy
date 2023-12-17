import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/modules/firestore_data/lesson_alphabet.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/lessons/alphabet/lessons/quiz_one.dart';
import 'package:sign_buddy/modules/lessons/alphabet/letters.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:cached_video_player/cached_video_player.dart';

class LessonTwo extends StatefulWidget {
  final String lessonName;

  const LessonTwo({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<LessonTwo> createState() => _LessonTwoState();
}

class _LessonTwoState extends State<LessonTwo> {
  String contentDescription = "";
  String uid = "";
  List<dynamic> contentVideo = [];
  bool isEnglish = true;
  bool isLoading = true;
  bool showOverlay = true;
  int progress = 0;
  bool progressAdded = false; // Track whether progress has been added
  CachedVideoPlayerController? _videoController;
  bool isSlowMotion = false;

  @override
  void initState() {
    super.initState();
    getLanguage().then((value) {
      getContent2DataByName(widget.lessonName);
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

  void getContent2DataByName(String lessonName) async {
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData =
          await LetterLessonFireStore(userId: userId!)
              .getLessonData(lessonName, isEnglish ? "en" : "ph");

      if (lessonData != null && lessonData.containsKey('content2')) {
        Map<String, dynamic> content2Data =
            lessonData['content2'] as Map<String, dynamic>;
        String description = content2Data['description'] as String;
        Iterable<dynamic> _contentVideo = content2Data['contentImage'];

        _contentVideo = await Future.wait(
            _contentVideo.map((e) => AssetFirebaseStorage().getAsset(e)));

        if (mounted) {
          setState(() {
            contentDescription = description;
            contentVideo = _contentVideo.toList();
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

  void _nextPage() async {
    Navigator.pushReplacement(
      context,
      SlidePageRoute(page: QuizOne(lessonName: widget.lessonName)),
    );

    if(mounted) {
      setState(() {
        progressAdded = false; // Reset progressAdded
        if (_videoController != null) {
          _videoController!.pause();
          _videoController!.dispose();
          _videoController = null;
        }
        
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
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
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    if (isSlowMotion) {
                      _videoController!.setPlaybackSpeed(1.0);
                      _videoController!.play();
                    } else {
                      _videoController!.setPlaybackSpeed(0.5);
                      _videoController!.play();
                    }
                    if(mounted) {
                      setState(() {
                        isSlowMotion = !isSlowMotion;
                      });
                    }
                  },
                  child: ImageIcon(
                    AssetImage(
                      isSlowMotion
                          ? 'assets/rabbit.png'
                          : 'assets/turtle.png',
                    ),
                    size: 40, // Adjust the size as needed
                    color: Colors.deepPurpleAccent,
                  ),
                ),
              ],
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
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 209, 209, 209),
          title: Text('Alphabet Lesson', style: TextStyle(color: Colors.black, fontSize: 16)),
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
              Navigator.pushReplacement(context, SlidePageRoute(page: Letters()));
            },
          ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 70),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                contentDescription,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(height: 30),
            if (contentVideo.isNotEmpty) buildVideoDisplay(),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                  onPressed: isLoading || contentVideo.isEmpty
                      ? null  // Disable the button if assets are still loading
                      : () async {
                          if (progress >= 31) {
                            _nextPage();
                          } else {
                            LetterLessonFireStore(userId: uid)
                                .incrementProgressValue(widget.lessonName, isEnglish ? "en" : "ph", 16);
                            print("Progress 2 updated successfully!");
                            _nextPage();
                          }
                        },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.grey.shade400; // Color when disabled
                        }
                        return Color(0xFF5BD8FF); // Color when enabled
                      },
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.arrowRight,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(width: 8),
                        Text(
                          isEnglish ? 'Next' : 'Susunod',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}