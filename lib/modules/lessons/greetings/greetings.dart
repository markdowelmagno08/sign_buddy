import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/modules/lessons/greetings/greetings/lessons_one.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:sign_buddy/sign_up.dart';
import 'package:sign_buddy/analytics.dart';



class Greetings extends StatefulWidget {
  const Greetings({Key? key}) : super(key: key);

  @override
  State<Greetings> createState() => _GreetingsState();
  
}



class _GreetingsState extends State<Greetings> {
  List greetingsLessonName = [];
  List greetingsLessonProgress = [];
  List unlockedGreetingsLessons = [];
  bool isEnglish = true;
  bool isLoading = true;
  final AnalyticsService analyticsService = AnalyticsService();
 
 @override
  void initState() {
    getLanguage().then((_) {
      greetingsLessons();

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
    super.initState();
  }

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

  Future<void> greetingsLessons() async {
    
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final String? userId = Auth().getCurrentUserId();


      List<String> greetingsNames = [];
      List<bool> unlockedLessons = [];
      List<int> greetingsProgress = [];

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection('userData')
          .doc(userId)
          .collection('greetings')
          .doc(isEnglish ? 'en' : 'ph')
          .collection('lessons')
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshot.docs) {
        Map<String, dynamic> lessonData = doc.data();
        greetingsNames.add(lessonData['name'] as String);
        unlockedLessons.add(lessonData['isUnlocked'] as bool);
        greetingsProgress.add(lessonData['progress'] as int);
      }
      if (mounted) {
        setState(() {
          greetingsLessonName = greetingsNames;
          unlockedGreetingsLessons = unlockedLessons;
          greetingsLessonProgress = greetingsProgress;
        });
      }



    } catch (e) {
        print('Error updating local greetings lessons: $e');
    }
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
                analyticsService.incrementInteractions( isEnglish ? "en" : "ph", "lessonInteract");
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

    if (Auth().isUserAnonymous()) {
        // If the user is anonymous, display this ui
        return Scaffold(
        body: isLoading
          ? Center(
            child: CircularProgressIndicator(),
          )
          : Stack(
            children: [
              // Background Image
              Image.asset(
                'assets/bg-signbuddy.png',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),
              // Back Button aligned to top-left
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: CustomBackButton(
                    onPressed: () {
                      analyticsService.incrementInteractions( isEnglish ? "en" : "ph", "lessonInteract");
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              // Image at the top
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/lesson-img.png',
                      height: 120,
                    ),
                    SizedBox(height: 20),
                    Text(
                      isEnglish ? 'Unlock More Lessons – Sign Up Now!' : "Buksan ang Karagdagang mga Aralin\nMag-sign up Ngayon!",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the sign-up page
                        Navigator.pushReplacement(context, SlidePageRoute(page: const SignupPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color.fromARGB(255, 71, 63, 63),
                        backgroundColor: Color(0xFF5BD8FF),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        isEnglish ? "Sign up" : "Mag-sign up",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      );
    }
    
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
                            analyticsService.incrementInteractions( isEnglish ? "en" : "ph", "lessonInteract");
                            Navigator.pop(context);
                          },
                        ),
                      ),
                       Visibility(
                        child: Text(
                          isEnglish ? 'Learn Greetings' : 'Matuto ng Pagbati',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/lesson-icon/img10.png',
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
                  final lessonName = greetingsLessonName[index];
                  final isUnlocked = unlockedGreetingsLessons[index];
                  final progress = greetingsLessonProgress[index] / 100; // Normalize progress to a value between 0 and 1
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
                            leading: isUnlocked
                              ? FaIcon(FontAwesomeIcons.bookOpen, size: 30, color: Color.fromARGB(255, 98, 189, 101),) // Open book icon
                              : FaIcon(FontAwesomeIcons.book, size: 30,color: Colors.grey),
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
                                      Text.rich(
                                        TextSpan(
                                          text: isEnglish ? 'Learn the sign for\n' : 'Senyas para sa\n',
                                          style: TextStyle(
                                            color: isUnlocked ? const Color(0xFF5A96E3) : Colors.grey,
                                            fontFamily: 'FiraSans',
                                            fontSize: 13,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: '$lessonName',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
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
                                analyticsService.incrementInteractions( isEnglish ? "en" : "ph", "lessonInteract");
                                Navigator.pushReplacement(
                                  context,
                                  SlidePageRoute(
                                    page: GreetingsLessonOne(
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
              childCount: isLoading ? 1 :greetingsLessonName.length, // Show 1 item if loading, otherwise show the lesson names
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
