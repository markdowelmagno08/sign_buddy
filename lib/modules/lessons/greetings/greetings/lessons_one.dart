import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/firestore_data/lesson_greetings.dart';
import 'package:sign_buddy/modules/lessons/greetings/greetings.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:cached_video_player/cached_video_player.dart';

class GreetingsLessonOne extends StatefulWidget {
  final String lessonName;

  const GreetingsLessonOne({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<GreetingsLessonOne> createState() => _GreetingsLessonTwoState();
}

class _GreetingsLessonTwoState extends State<GreetingsLessonOne> {
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
      getContent1DataByName(widget.lessonName);
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
      print('Error reading greetings_lessons.json: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void getContent1DataByName(String lessonName) async {
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData =
          await GreetingsLessonFireStore(userId: userId!)
              .getLessonData(lessonName, isEnglish ? "en" : "ph");

      if (lessonData != null && lessonData.containsKey('content1')) {
        Map<String, dynamic> content1Data =
            lessonData['content1'] as Map<String, dynamic>;
        String description = content1Data['description'] as String;
        Iterable<dynamic> _contentVideo = content1Data['contentImage'];

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
              'By Content: Greetings lesson "$lessonName" was not found within the Firestore.');
          isLoading = true;
        }
      }
    } catch (e) {
      print('Error reading greetings_lessons.json: $e');
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
    // Navigator.pushReplacement(
    //   context,
    //   SlidePageRoute(page: QuizOne(lessonName: widget.lessonName)),
    // );

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
                  Navigator.pushReplacement(
                    context,
                    SlidePageRoute(page: Greetings()),
                  );
                },
              ),
            ),
            const SizedBox(height: 70),
              Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Greetings lesson for: "${widget.lessonName}"', 
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold, 
                ),
              ),
            ),
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
            SizedBox(height: 10),
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
                            GreetingsLessonFireStore(userId: uid)
                                .incrementProgressValue(widget.lessonName, isEnglish ? "en" : "ph", 16);
                            print("Progress 1 updated successfully!");
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