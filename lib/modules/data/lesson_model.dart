import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';

part 'lesson_model.g.dart';

@JsonSerializable()
class LetterLesson {
  String name;
  int progress;
  bool isUnlocked;
  List<LessonContent> content;
  LessonQuiz quiz1;
  LessonQuiz quiz2;
  LessonQuiz quiz3;
  LessonQuiz quiz4;

  LetterLesson({
    required this.name,
    required this.progress,
    required this.isUnlocked,
    required this.content,
    required this.quiz1,
    required this.quiz2,
    required this.quiz3,
    required this.quiz4,
  });

  factory LetterLesson.fromJson(Map<String, dynamic> json) =>
      _$LetterLessonFromJson(json);

  Map<String, dynamic> toJson() => _$LetterLessonToJson(this);
}

@JsonSerializable()
class LessonContent {
  String description;
  String lessonImage;

  LessonContent({
    required this.description,
    required this.lessonImage,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) =>
      _$LessonContentFromJson(json);

  Map<String, dynamic> toJson() => _$LessonContentToJson(this);
}

@JsonSerializable()
class LessonQuiz {
  String question;
  String? quizImage;
  List<String> options; // Add options field
  List<int> correctAnswerIndex;

  LessonQuiz({
    required this.question,
    this.quizImage,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory LessonQuiz.fromJson(Map<String, dynamic> json) =>
      _$LessonQuizFromJson(json);

  Map<String, dynamic> toJson() => _$LessonQuizToJson(this);
}

Future<void> initLetterLessonData() async {
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
      question: "What is being signed here",
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
      question: "What is being signed here",
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
      question: "What is being signed here",
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
      question: "What is being signed here",
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
      question: "What is being signed here",
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

  final jsonString = json.encode([
    letterA.toJson(),
    letterB.toJson(),
    letterC.toJson(),
    letterD.toJson(),
    letterE.toJson()
  ]);

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/lesson_alphabet.json');
  await file.writeAsString(jsonString);
}

Future<void> addNewLetterLesson(LetterLesson newLesson) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/lesson_alphabet.json');

  try {
    final jsonString = await file.readAsString();
    final List<dynamic> jsonData = json.decode(jsonString);

    List<LetterLesson> letterLessons = jsonData.map((lesson) {
      return LetterLesson.fromJson(lesson);
    }).toList();

    // Check if the lesson with the given name already exists
    if (letterLessons.any((lesson) => lesson.name == newLesson.name)) {
      print(
          'LetterLesson with name ${newLesson.name} already exists in JSON file');
      return;
    }

    LetterLesson newLetterLesson = LetterLesson(
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
        question: "What is being signed here",
        quizImage: "assets/alphabet-lesson/a-d-img/excuse.gif",
        options: [
          "Excuse Me",
          "A",
          "P",
          "Q",
          "G",
          "L",
          "Crocodile",
          "Fox",
          "Uncle",
        ],
        correctAnswerIndex: [1],
      ),
    );

    // Add the new LetterLesson to the list
    letterLessons.add(newLetterLesson);

    // Write the updated JSON data back to the file
    final updatedJsonData =
        letterLessons.map((lesson) => lesson.toJson()).toList();
    await file.writeAsString(json.encode(updatedJsonData));

    print('LetterLesson with name ${newLesson.name} added successfully!');

    // Print the updated lessons for verification
    print(json.encode(updatedJsonData));
  } catch (e) {
    print('Error reading/writing lesson_alphabet.json: $e');
  }
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
      question: "What is being signed here",
      quizImage: "assets/alphabet-lesson/a-d-img/aunt.gif",
      options: [
        "Aunt",
        "Cat",
        "Dog",
        "X",
        "U",
        "Orange",
        "Frame",
        "X",
        "B",
      ],
      correctAnswerIndex: [1],
    ),
  );

  final initialLessons = [letterA]; // Add more lessons as needed

  return initialLessons;
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
