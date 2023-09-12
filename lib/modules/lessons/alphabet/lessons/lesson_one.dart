import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sign_buddy/modules/english_level.dart';
import 'package:sign_buddy/modules/lessons/alphabet/shuffle_lesson_options.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:sign_buddy/modules/data/lesson_model.dart';  // Import the lesson model classes
import 'package:sign_buddy/modules/lessons/alphabet/letters.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';


 class LessonOne extends StatefulWidget {
  final String lessonName;

  const LessonOne ({Key? key, required this.lessonName}) : super(key: key);

  @override
  State<LessonOne> createState() => _LessonOneState();
}

class _LessonOneState extends State<LessonOne> {

  bool isLoading = true;
  bool showOverlay = true;



  @override
  void initState() {
    super.initState();
    getLessonOneData(widget.lessonName);
    Future.delayed (const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showOverlay = false;
        });
      }
    });
    
  }


  LetterLesson? geLetterLessonByName(List<LetterLesson> letterLessons, String lessonName){
    return letterLessons.firstWhere((lesson) => lesson.name == lessonName);

  }

  void getLessonOneData(String lessonName) async {
    final directory = await getApplicationCacheDirectory();
    final file = File('${directory.path}/lesson_alphabet.json');


    try {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = json.decode(jsonString);


      List<LetterLesson> letterLessons = jsonData.map((lesson) {
        return LetterLesson.fromJson(lesson);
      }).toList();

      LetterLesson? lesson = geLetterLessonByName(letterLessons, lessonName);


      if (lesson != null) {
        // LessonContent contentData = lesson.quiz1;
      }
    } catch (e) {
      print ('Error reading lesson_alphabet.json: $e');

    }
  }







  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}