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

  void _nextPage() {
    setState(() {
      lessonPage++; // Move to the next page
    });
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
      name: "Letter A",
      progress: 10,
      isUnlocked: true,
      content: [
        LessonContent(
          description: "This is the sign for letter 'A'.",
          lessonImage: "assets/alphabet/a.png",
        ),
        LessonContent(
          description: "This is how you sign Aunt.",
          lessonImage: "assets/alphabet-lesson/a-d-img/aunt.gif",
        ),
      ],
      quiz1: LessonQuiz(
        question: "Which one here is the sign for letter 'A'?",
        options: [
          "assets/alphabet/a.png",
          "assets/alphabet/s.png",
          "assets/alphabet/w.png",
          "assets/alphabet/x.png",
        ],
        correctAnswerIndex: [0],
      ),
      quiz2: LessonQuiz(
        question: "What sign is this?",
        quizImage: "assets/alphabet/c.png",
        options: [
          "Q",
          "C",
          "D",
          "X",
          "O",
          "F",
        ],
        correctAnswerIndex: [1],
      ),
      quiz3: LessonQuiz(
        question: "Is this letter A?",
        quizImage: "assets/alphabet/a.png",
        options: [
          "Yes",
          "No",
        ],
        correctAnswerIndex: [0],
      ),
      quiz4: LessonQuiz(
        question: "What is being signed here?",
       quizImage: "assets/alphabet-lesson/a-d-img/aunt.gif",
        options: [
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
      name: "Letter B",
      progress: 0,
      isUnlocked: false,
      content: [
        LessonContent(
          description: "This is the sign for letter 'B'.",
          lessonImage: "assets/alphabet/b.png",
        ),
        LessonContent(
          description: "This is how you sign Baby.",
          lessonImage: "assets/alphabet-lesson/a-d-img/baby.gif",
        ),
      ],
      quiz1: LessonQuiz(
        question: "Which one here is the sign for letter 'B'?",
        options: [
          "assets/alphabet/b.png",
          "assets/alphabet/f.png",
          "assets/alphabet/l.png",
          "assets/alphabet/k.png",
        ],
        correctAnswerIndex: [0],
      ),
      quiz2: LessonQuiz(
        question: "What sign is this?",
        quizImage: "assets/alphabet/k.png",
        options: [
          "B",
          "K",
          "W",
          "P",
          "M",
          "L",
        ],
        correctAnswerIndex: [1],
      ),
      quiz3: LessonQuiz(
        question: "Is this letter B?",
        quizImage: "assets/alphabet/b.png",
        options: [
          "Yes",
          "No",
        ],
        correctAnswerIndex: [0],
      ),
      quiz4: LessonQuiz(
        question: "What is being signed here?",
        quizImage: "assets/alphabet-lesson/a-d-img/baby.gif",
        options: [
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
      name: "Letter C",
      progress: 0,
      isUnlocked: false,
      content: [
        LessonContent(
          description: "This is the sign for letter 'C'.",
          lessonImage: "assets/alphabet/c.png",
        ),
        LessonContent(
          description: "This is how you sign Camel.",
          lessonImage: "assets/alphabet-lesson/a-d-img/camel.gif",
        ),
      ],
      quiz1: LessonQuiz(
        question: "Which one here is the sign for letter 'C'?",
        options: [
          "assets/alphabet/c.png",
          "assets/alphabet/g.png",
          "assets/alphabet/k.png",
          "assets/alphabet/u.png",
        ],
        correctAnswerIndex: [0],
      ),
      quiz2: LessonQuiz(
        question: "What sign is this?",
        quizImage: "assets/alphabet/c.png",
        options: [
          "S",
          "C",
          "Z",
          "C",
          "Q",
          "R",
        ],
        correctAnswerIndex: [1],
      ),
      quiz3: LessonQuiz(
        question: "Is this letter C?",
        quizImage: "assets/alphabet/c.png",
        options: [
          "Yes",
          "No",
        ],
        correctAnswerIndex: [0],
      ),
      quiz4: LessonQuiz(
        question: "What is being signed here?",
       quizImage: "assets/alphabet-lesson/a-d-img/camel.gif",
        options: [
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
      name: "Letter D",
      progress: 0,
      isUnlocked: false,
      content: [
        LessonContent(
          description: "This is the sign for letter 'D'.",
          lessonImage: "assets/alphabet/d.png",
        ),
        LessonContent(
          description: "This is how you sign Dolphin.",
          lessonImage: "assets/alphabet-lesson/a-d-img/dolphin.gif",
        ),
      ],
      quiz1: LessonQuiz(
        question: "Which one here is the sign for letter 'D'?",
        options: [
          "assets/alphabet/d.png",
          "assets/alphabet/z.png",
          "assets/alphabet/h.png",
          "assets/alphabet/y.png",
        ],
        correctAnswerIndex: [0],
      ),
      quiz2: LessonQuiz(
        question: "What sign is this?",
        quizImage: "assets/alphabet/d.png",
        options: [
          "T",
          "D",
          "G",
          "L",
          "H",
          "P",
        ],
        correctAnswerIndex: [1],
      ),
      quiz3: LessonQuiz(
        question: "Is this letter D?",
        quizImage: "assets/alphabet/d.png",
        options: [
          "Yes",
          "No",
        ],
        correctAnswerIndex: [0],
      ),
      quiz4: LessonQuiz(
        question: "What is being signed here?",
        quizImage: "assets/alphabet-lesson/a-d-img/dolphin.gif",
        options: [
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
      name: "Letter E",
      progress: 0,
      isUnlocked: false,
      content: [
        LessonContent(
          description: "This is the sign for letter 'E'.",
          lessonImage: "assets/alphabet/e.png",
        ),
        LessonContent(
          description: "This is how you sign Excuse Me.",
          lessonImage: "assets/alphabet-lesson/a-d-img/excuse.gif",
        ),
      ],
      quiz1: LessonQuiz(
        question: "Which one here is the sign for letter 'E'?",
        options: [
          "assets/alphabet/e.png",
          "assets/alphabet/f.png",
          "assets/alphabet/l.png",
          "assets/alphabet/h.png",
        ],
        correctAnswerIndex: [0],
      ),
      quiz2: LessonQuiz(
        question: "What sign is this?",
        quizImage: "assets/alphabet/e.png",
        options: [
          "F",
          "E",
          "Y",
          "B",
          "U",
          "I",
        ],
        correctAnswerIndex: [1],
      ),
      quiz3: LessonQuiz(
        question: "Is this letter E?",
        quizImage: "assets/assess-img/question-five/e.png",
        options: [
          "Yes",
          "No",
        ],
        correctAnswerIndex: [0],
      ),
      quiz4: LessonQuiz(
        question: "What is being signed here?",
        quizImage: "assets/alphabet-lesson/a-d-img/excuse.gif",
        options: [
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

      return true; // Writing successful
    } catch (e) {
      print('Error writing lessons: $e');
      return false; // Writing failed
    }
  }

  Widget _buildWordStartsWithA() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              lessons[lessonStep].content[0].description,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              lessons[lessonStep].content[0].lessonImage,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignLanguageVideo() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              lessons[lessonStep].content[1].description,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              lessons[lessonStep].content[1].lessonImage,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuiz() {
    LessonQuiz currentQuiz = lessonStep == 1
        ? lessons[lessonStep].quiz1
        : lessonStep == 3
            ? lessons[lessonStep].quiz2
            : lessons[lessonStep].quiz3;

    return Column(
      children: [
        Text(currentQuiz.question),
        // Render quiz options/buttons
        // Implement logic to check user's answer and update lessonPage
      ],
    );
  }

  Widget _buildPageContent() {
    switch (lessonPage) {
      case 1:
        return _buildWordStartsWithA();
      case 2:
        return _buildSignLanguageVideo();
      case 3:
        return _buildQuiz();
      default:
        return Container(); // Replace this with an appropriate default content widget
    }
  }

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentLesson = lessons[3]; // Display the first lesson for now

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              currentLesson.content[0].description,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Image.asset(currentLesson.content[0].lessonImage),
            SizedBox(height: 16),
            Text(
              currentLesson.content[1].description,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Image.asset(currentLesson.content[1].lessonImage),
          ],
        ),
      ),
    );
  }
}
