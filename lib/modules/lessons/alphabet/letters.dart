import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:sign_buddy/modules/data/lesson_model.dart';
import 'package:sign_buddy/modules/lessons/alphabet/lessons/lesson_one.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';

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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class Letters extends StatefulWidget {
  const Letters({Key? key}) : super(key: key);

  @override
  State<Letters> createState() => _LettersState();
}

class _LettersState extends State<Letters> {
  List<String> letterLessonNames = [];
  List<bool> unlockedLetterLessons = [];
  List<int> letterLessonProgress = [];

  Future<void> letterLessons() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/lesson_alphabet.json');

      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = json.decode(jsonString);

      List<String> letterNames = [];
      List<bool> unlockedLessons = [];
      List<int> progress = [];

      List<LetterLesson> letterLessons = jsonData.map((lesson) {
        return LetterLesson.fromJson(lesson);
      }).toList();

      for (var lesson in letterLessons) {
        letterNames.add(lesson.name);
        unlockedLessons.add(lesson.isUnlocked);
        progress.add(lesson.progress);
      }

      setState(() {
        letterLessonNames = letterNames;
        unlockedLetterLessons = unlockedLessons;
        letterLessonProgress = progress;
      });
    } catch (e) {
      print('Error reading JSON file: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    letterLessons();
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
          content: Text('You need to unlock the other lessons first',
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
                      const Visibility(
                        child: Text(
                          'Learn Alphabets',
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
                    child: ListTile(
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
                                  'Learn the sign for $lessonName',
                                  style: TextStyle(
                                    color: isUnlocked ? const Color(0xFF5A96E3) : Colors.grey, // Customize the color if needed
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isUnlocked) CircularProgressBar(progress: progress),
                        ],
                      ),
                      onTap: () {
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
                  ),
                );
              },
              childCount: letterLessonNames.length,
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
