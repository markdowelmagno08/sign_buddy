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
    LessonContent content1;
    LessonContent content2;
    LessonContent content3;
    LessonContent content4;
    LessonContent content5;
    LessonContent content6;

    LetterLesson({
      required this.name,
      required this.progress,
      required this.isUnlocked,
      required this.content1,
      required this.content2,
      required this.content3,
      required this.content4,
      required this.content5,
      required this.content6,
    });

    factory LetterLesson.fromJson(Map<String, dynamic> json) =>
        _$LetterLessonFromJson(json);

    Map<String, dynamic> toJson() => _$LetterLessonToJson(this);
  }

  @JsonSerializable()
  class LessonContent {
    String description;
    List<dynamic>? contentImage;
    List<dynamic>? contentOption;
    List<dynamic>? correctAnswerIndex;

    LessonContent({
      required this.description,
      this.contentImage,
      this.contentOption,
      this.correctAnswerIndex,
    });

    factory LessonContent.fromJson(Map<String, dynamic> json) =>
        _$LessonContentFromJson(json);

    Map<String, dynamic> toJson() => _$LessonContentToJson(this);
  }



  Future<void> initLetterLessonData() async {
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
      name: "A",
      progress: 0,
      isUnlocked: true,
      content1: LessonContent(
        description: "This is the sign for letter 'A'.",
        contentImage: ["assets/alphabet/a.png",]
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
        contentImage: ["assets/alphabet/c.png",],
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



  Future<void> incrementProgressValue(String lessonName, int value) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/lesson_alphabet.json');

    try {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = json.decode(jsonString);

      List<LetterLesson> letterLessons = jsonData.map((lesson) {
        return LetterLesson.fromJson(lesson);
      }).toList();

      LetterLesson? lessonToUpdate = 
        letterLessons.firstWhere((element) => element.name == lessonName);
        
      // ignore: unnecessary_null_comparison
      if(lessonToUpdate != null) {

        lessonToUpdate.progress += value;

        final updatedJsonData =
            letterLessons.map((lesson) => lesson.toJson()).toList();
        await file.writeAsString(json.encode(updatedJsonData));
        print('Score updated successfully!');
      } else {
        print('LetterLesson with name $lessonName not found in JSON file');
      }

    } catch(e) {

      print('Error reading/writing lesson_alphabet.json: $e');

    }
  }

  Future<void> unlockLesson(String lessonName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/letter_lessons.json');

    try {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = json.decode(jsonString);

      List<LetterLesson> letterLessons = jsonData.map((lesson) {
        return LetterLesson.fromJson(lesson);
      }).toList();

      int currentIndex =
          letterLessons.indexWhere((element) => element.name == lessonName);

      if (currentIndex >= 0 && currentIndex < letterLessons.length - 1) {
        // Change the value of isUnlocked to true for the next lesson
        letterLessons[currentIndex + 1].isUnlocked = true;

        final updatedJsonData =
            letterLessons.map((lesson) => lesson.toJson()).toList();
        await file.writeAsString(json.encode(updatedJsonData));
        print('Lesson has unlocked successfully!');
      } else {
        print(
            'LetterLesson with name $lessonName not found or is the last lesson');
      }
    } catch (e) {
      print('Error reading/writing letter_lessons.json: $e');
    }
  }


