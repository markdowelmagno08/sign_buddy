import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/lessons/numbers/number_lessons/quiz_one.dart';
import 'package:sign_buddy/modules/lessons/numbers/numbers.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/modules/firestore_data/lesson_numbers.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
class NumberLessonOne extends StatefulWidget {
  final String lessonName;

  const NumberLessonOne({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<NumberLessonOne> createState() => _NumberLessonOneState();
}

class _NumberLessonOneState extends State<NumberLessonOne> {
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
      await NumberLessonFireStore(userId: userId!)
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


  void getContent1DataByName(String lessonName) async {
    
    try {
      final userId = Auth().getCurrentUserId();
      Map<String, dynamic>? lessonData = 
      await NumberLessonFireStore(userId: userId!)
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

  

  void _nextPage() async {
    Navigator.pushReplacement(
      context,
      SlidePageRoute(page: NumberQuizOne(lessonName: widget.lessonName)),
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
          title: Text('Number Lesson', style: TextStyle(color: Colors.black, fontSize: 16)),
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
              Navigator.pushReplacement(context, SlidePageRoute(page: Number()));// This will pop the current screen
            },
          ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            const SizedBox(height: 100),
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
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),// adjust the size of the image 
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
                    // width: 180, 
                    // height: 150,
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
                          if (progress >= 24) {
                            _nextPage();
                          } else {
                            NumberLessonFireStore(userId: uid)
                                .incrementProgressValue(widget.lessonName, isEnglish ? "en" : "ph", 25);
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