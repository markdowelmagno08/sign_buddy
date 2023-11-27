import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/modules/lessons/alphabet/lessons/lesson_one.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';




class Letters extends StatefulWidget {
  const Letters({Key? key}) : super(key: key);

  @override
  State<Letters> createState() => _LettersState();
  
}



class _LettersState extends State<Letters> {
  List letterLessonNames = [];
  List letterLessonProgress = [];
  List unlockedLetterLessons = [];
  bool isEnglish = true;
  bool isLoading = true;

 

  

 

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getBool('isEnglish');

    if (mounted) {
      setState(() {
       if (locale != null) {
        isEnglish = locale;
      }
      });
    }
  }

  Future<void> letterLessons() async {
    
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final String? userId = Auth().getCurrentUserId();


      List<String> letterNames = [];
      List<bool> unlockedLessons = [];
      List<int> letterProgress = [];

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection('userData')
          .doc(userId)
          .collection('letters')
          .doc(isEnglish ? 'en' : 'ph')
          .collection('lessons')
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshot.docs) {
        Map<String, dynamic> lessonData = doc.data();
        letterNames.add(lessonData['name'] as String);
        unlockedLessons.add(lessonData['isUnlocked'] as bool);
        letterProgress.add(lessonData['progress'] as int);
      }
      if (mounted) {
        setState(() {
          letterLessonNames = letterNames;
          unlockedLetterLessons = unlockedLessons;
          letterLessonProgress = letterProgress;
        });
      }



    } catch (e) {
        print('Error updating local letter lessons: $e');
    }
  }

  @override
  void initState() {
    getLanguage().then((_) {
      letterLessons();

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
    super.initState();
    
  }
  
   @override
  void dispose() {
    super.dispose();
  }
  


  void showLockedLessonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock, color: Colors.blueAccent),
              SizedBox(width: 10),
              Text('Lock Lesson',
                  style: TextStyle(
                    fontFamily: 'FiraSans',
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          content: Text(isEnglish ? 'You need to unlock the other lessons first' : 'Kailangan mo munang i-unlock ang iba pang mga aralin',
              style: TextStyle(
                fontFamily: 'FiraSans',
                fontWeight: FontWeight.normal,
              )),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 100,
              maxHeight: 150,
              bottomPadding: 20.0, // Adjust the top padding here
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF5A96E3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 50, 36, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: CustomBackButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/homePage');
                          },
                        ),
                      ),
                       Visibility(
                        child: Text(
                          isEnglish ? 'Learn Alphabets' : 'Matuto ng Alpabeto',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/lesson-icon/img1.png',
                        width: 50,
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (isLoading) {
                  // Show a loading indicator for lesson names
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  final lessonName = letterLessonNames[index];
                  final isUnlocked = unlockedLetterLessons[index];
                  final progress = letterLessonProgress[index] / 100; // Normalize progress to a value between 0 and 1
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                      child: Stack(
                        children: [
                          ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            leading: Icon(Icons.menu_book_outlined, size: 30),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lessonName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isUnlocked ? Colors.black : Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        isEnglish ? 'Learn the sign for $lessonName' : 'Senyas para sa $lessonName',
                                        style: TextStyle(
                                          color: isUnlocked ? const Color(0xFF5A96E3) : Colors.grey,
                                          fontFamily: 'FiraSans',
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isUnlocked) CircularProgressBar(progress: progress),
                                if (!isUnlocked) Icon(Icons.lock, size: 35, color: const Color(0xFF5A96E3))
                              ],
                            ),
                            onTap: () async {
                              if (isUnlocked) {
                                Navigator.push(
                                  context,
                                  SlidePageRoute(
                                    page: LessonOne(
                                      lessonName: lessonName,
                                    ),
                                  ),
                                );
                              } else {
                                showLockedLessonDialog(); // Show the locked lesson dialog
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
              childCount: isLoading ? 1 : letterLessonNames.length, // Show 1 item if loading, otherwise show the lesson names
            ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressBar extends StatelessWidget {
  final double progress;

  CircularProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF5A96E3)),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
    this.bottomPadding = 0.0, // Add a topPadding property
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;
  final double bottomPadding; // Add topPadding property

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding), // Apply top padding
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
