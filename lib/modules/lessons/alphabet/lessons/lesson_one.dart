import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:sign_buddy/modules/data/lesson_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/lessons/alphabet/lessons/lesson_two.dart';
import 'package:sign_buddy/modules/lessons/alphabet/letters.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/modules/firestore_data/lesson_alphabet.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
class LessonOne extends StatefulWidget {
  final String lessonName;

  const LessonOne({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<LessonOne> createState() => _LessonOneState();
}

class _LessonOneState extends State<LessonOne> {
  String contentDescription = "";
  String uid = "";
  List<dynamic> contentImage = [];
  bool isEnglish = true;
  bool isLoading = true;
  int progress = 0;


  bool progressAdded = false; // Track whether progress has been added

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
      await LetterLessonFireStore(userId: userId!)
            .getUserLessonData(lessonName, isEnglish ? "en" : "ph");

      
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


  void getContent1DataByName(String lessonName) async {
    
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData = 
      await LetterLessonFireStore(userId: userId!)
          .getLessonData(lessonName, isEnglish ? "en" : "ph");


      if(lessonData != null && lessonData.containsKey('content1')) {
        Map<String,dynamic> content1Data = 
        lessonData['content1'] as Map<String, dynamic>; 
        String description = content1Data['description'] as String;
        Iterable<dynamic> _contentImage = content1Data['contentImage'];


        _contentImage = await Future.wait(_contentImage.map((e) => AssetFirebaseStorage().getAsset(e)));


        if(mounted) {
          setState(() {
            contentDescription = description;
            contentImage = _contentImage.toList();
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

  

  void _nextPage() async {
    Navigator.pushReplacement(
      context,
      SlidePageRoute(page: LessonTwo(lessonName: widget.lessonName)),
    );
    
    setState(() {
      progressAdded = false; // Reset progressAdded
    });
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
          iconTheme: IconThemeData(color: Colors.black), // Set the icon color
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.pushReplacement(context, SlidePageRoute(page: Letters()));// This will pop the current screen
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
            if (isLoading) // Show loading indicator while fetching data
              CircularProgressIndicator()
            else if (contentImage.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),//adjust the size of the image
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
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                  onPressed: isLoading || contentImage.isEmpty
                      ? null  // Disable the button if assets are still loading
                      : () async {
                          if (progress >= 15) {
                            _nextPage();
                          } else {
                            LetterLessonFireStore(userId: uid)
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