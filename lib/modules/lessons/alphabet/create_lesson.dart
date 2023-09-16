// runthis code if you want to create or add a lesson

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:sign_buddy/modules/data/lesson_model.dart';
// Import the lesson model classes

class CreateLessonScreen extends StatefulWidget {
  @override
  _CreateLessonScreenState createState() => _CreateLessonScreenState();
}

class _CreateLessonScreenState extends State<CreateLessonScreen> {
  List<LetterLesson> lessons = [];
  int lessonStep = 0;
  int lessonPage = 1;

  @override
  void initState() {
    super.initState();
    initLessonData();
  }



  Future<void> initLessonData() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/lesson_alphabet.json');

    if (!await file.exists()) {
      // If the file doesn't exist, create it with initial data
      await writeLessonData(createInitialLessons());
    }

    final jsonString = await file.readAsString();
    final jsonData = json.decode(jsonString);

    lessons = List<LetterLesson>.from(
        jsonData.map((lessonJson) => LetterLesson.fromJson(lessonJson)));

    setState(() {}); // Update the UI with the loaded data
  }

  List<LetterLesson> createInitialLessons() {
    final letterA = LetterLesson(
      name: "A",
      progress: 0,
      isUnlocked: true,
      content1: LessonContent(
        description: "This is the sign for letter 'A'.",
        contentImage: ["assets/alphabet/a.png"]
      ),
      content2: LessonContent(
        description: "This is how you sign Aunt.",
        contentImage: ["assets/alphabet-lesson/a-d-img/aunt.gif"],
      ),
      content3: LessonContent(
        description: "Which one here is the sign for letter 'A'?",
        contentOption: [
          "assets/alphabet/a.png",
          "assets/alphabet/s.png",
          "assets/alphabet/w.png",
          "assets/alphabet/x.png",
        ],
        correctAnswerIndex: [0],
      ),
    content4: LessonContent(
        description: "What sign is this?",
        contentImage: ["assets/alphabet/c.png"],
        contentOption: [
          "Q",
          "C",
          "D",
          "X",
          "O",
          "F",
        ],
        correctAnswerIndex: [1],
      ),
      content5: LessonContent(
        description: "Is this letter A?",
        contentImage: ["assets/alphabet/a.png"],
        contentOption: [
          "Yes",
          "No",
        ],
        correctAnswerIndex: [0],
      ),
    content6: LessonContent(
        description: "What is being signed here",
        contentImage: ["assets/alphabet-lesson/a-d-img/aunt.gif"],
        contentOption: [
          "Aunt",
          "Cat",
          "Dog",
          "X",
          "U",
          "Orange",
          "Frame",
          "T",
          "B",
        ],
        correctAnswerIndex: [0],
      ),
    );


    final letterB = LetterLesson(
    name: "B",
    progress: 0,
    isUnlocked: false,
    content1: LessonContent(
      description: "This is the sign for letter 'B'.",
      contentImage: ["assets/alphabet/b.png"],
    ),
    content2: LessonContent(
      description: "This is how you sign Baby.",
      contentImage: ["assets/alphabet-lesson/a-d-img/baby.gif"],
    ),
    content3: LessonContent(
      description: "Which one here is the sign for letter 'B'?",
      contentOption: [
        "assets/alphabet/b.png",
        "assets/alphabet/f.png",
        "assets/alphabet/l.png",
        "assets/alphabet/k.png",
      ],
      correctAnswerIndex: [0],
    ),
    content4: LessonContent(
      description: "What sign is this?",
      contentImage: ["assets/alphabet/k.png"],
      contentOption: [
        "B",
        "K",
        "W",
        "P",
        "M",
        "L",
      ],
      correctAnswerIndex: [1],
    ),
    content5: LessonContent(
      description: "Is this letter B?",
      contentImage: ["assets/alphabet/b.png"],
      contentOption: [
        "Yes",
        "No",
      ],
      correctAnswerIndex: [0],
    ),
    content6: LessonContent(
      description: "What is being signed here",
      contentImage: ["assets/alphabet-lesson/a-d-img/baby.gif"],
      contentOption: [
        "Baby",
        "W",
        "S",
        "P",
        "K",
        "Play",
        "Man",
        "Letter",
        "I(letter)",
      ],
      correctAnswerIndex: [0],
    ),
  );

  final letterC = LetterLesson(
    name: "C",
    progress: 0,
    isUnlocked: false,
    content1: LessonContent(
      description: "This is the sign for letter 'C'.",
      contentImage: ["assets/alphabet/c.png"],
    ),
    content2: LessonContent(
      description: "This is how you sign Camel.",
      contentImage: ["assets/alphabet-lesson/a-d-img/camel.gif"],
    ),
    content3: LessonContent(
      description: "Which one here is the sign for letter 'C'?",
      contentOption: [
        "assets/alphabet/c.png",
        "assets/alphabet/g.png",
        "assets/alphabet/k.png",
        "assets/alphabet/u.png",
      ],
      correctAnswerIndex: [0],
    ),
    content4: LessonContent(
      description: "What sign is this?",
      contentImage: ["assets/alphabet/c.png"],
      contentOption: [
        "S",
        "C",
        "Z",
        "F",
        "Q",
        "R",
      ],
      correctAnswerIndex: [1],
    ),
    content5: LessonContent(
      description: "Is this letter C?",
      contentImage: ["assets/alphabet/c.png"],
      contentOption: [
        "Yes",
        "No",
      ],
      correctAnswerIndex: [0],
    ),
    content6: LessonContent(
      description: "What is being signed here",
      contentImage: ["assets/alphabet-lesson/a-d-img/camel.gif"],
      contentOption: [
        "Camel",
        "P",
        "N",
        "V",
        "T",
        "X",
        "Dolphin",
        "North",
        "Goat",
      ],
      correctAnswerIndex: [0],
    ),
  );

  final letterD = LetterLesson(
    name: "D",
    progress: 0,
    isUnlocked: false,
    content1: LessonContent(
      description: "This is the sign for letter 'D'.",
      contentImage: ["assets/alphabet/d.png"],
    ),
    content2: LessonContent(
      description: "This is how you sign Dolphin.",
      contentImage: ["assets/alphabet-lesson/a-d-img/dolphin.gif"],
    ),
    content3: LessonContent(
      description: "Which one here is the sign for letter 'D'?",
      contentOption: [
        "assets/alphabet/d.png",
        "assets/alphabet/z.png",
        "assets/alphabet/h.png",
        "assets/alphabet/y.png",
      ],
      correctAnswerIndex: [0],
    ),
    content4: LessonContent(
      description: "What sign is this?",
      contentImage: ["assets/alphabet/d.png"],
      contentOption: [
        "T",
        "D",
        "G",
        "L",
        "H",
        "P",
      ],
      correctAnswerIndex: [1],
    ),
    content5: LessonContent(
      description: "Is this letter D?",
      contentImage: ["assets/alphabet/d.png"],
      contentOption: [
        "Yes",
        "No",
      ],
      correctAnswerIndex: [0],
    ),
    content6: LessonContent(
      description: "What is being signed here",
      contentImage: ["assets/alphabet-lesson/a-d-img/dolphin.gif"],
      contentOption: [
        "Dolphin",
        "A",
        "T",
        "Y",
        "G",
        "H",
        "Crocodile",
        "Fox",
        "Uncle",
      ],
      correctAnswerIndex: [0],
    ),
  );

  final letterE = LetterLesson(
    name: "E",
    progress: 0,
    isUnlocked: false,
    content1: LessonContent(
      description: "This is the sign for letter 'E'.",
      contentImage: ["assets/alphabet/e.png"],
    ),
    content2: LessonContent(
      description: "This is how you sign Excuse Me.",
      contentImage: ["assets/alphabet-lesson/a-d-img/excuse.gif"],
    ),
    content3: LessonContent(
      description: "Which one here is the sign for letter 'E'?",
      contentOption: [
        "assets/alphabet/e.png",
        "assets/alphabet/f.png",
        "assets/alphabet/l.png",
        "assets/alphabet/h.png",
      ],
      correctAnswerIndex: [0],
    ),
    content4: LessonContent(
      description: "What sign is this?",
      contentImage: ["assets/alphabet/e.png"],
      contentOption: [
        "F",
        "E",
        "Y",
        "B",
        "U",
        "I",
      ],
      correctAnswerIndex: [1],
    ),
    content5: LessonContent(
      description: "Is this letter E?",
      contentImage: ["assets/assess-img/question-five/e.png"],
      contentOption: [
        "Yes",
        "No",
      ],
      correctAnswerIndex: [0],
    ),
    content6: LessonContent(
      description: "What is being signed here",
      contentImage: ["assets/alphabet-lesson/a-d-img/excuse.gif"],
      contentOption: [
        "Excuse Me",
        "O",
        "P",
        "Q",
        "G",
        "L",
        "Crocodile",
        "Good Morning",
        "Friday",
      ],
      correctAnswerIndex: [0],
    ),
  );
    return [letterA, letterB, letterC, letterD, letterE];
  }

  Future<bool> writeLessonData(List<LetterLesson> lessons) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/lesson_alphabet.json');

      final jsonString =
          json.encode(lessons.map((lesson) => lesson.toJson()).toList());
      await file.writeAsString(jsonString);
       print('Successfull created lesson data');

      return true; // Writing successful
    } catch (e) {
      print('Error writing lessons: $e');
      return false; // Writing failed
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
      return Scaffold();
  }

}
