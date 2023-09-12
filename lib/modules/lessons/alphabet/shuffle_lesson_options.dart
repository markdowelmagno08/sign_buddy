import 'dart:math';
import 'package:sign_buddy/modules/data/lesson_model.dart';

void shuffleOptions(List<LetterLesson> lessons) {
  final random = Random();

  for (var lesson in lessons) {
    final quizzes = [lesson.quiz1, lesson.quiz2, lesson.quiz3, lesson.quiz4];
    for (var quiz in quizzes) {
      final options = List<String>.from(quiz.options);

      int correctAnswerIndex = quiz.correctAnswerIndex.single;

      for (int i = options.length - 1; i > 0; i--) {
        int j = random.nextInt(i + 1);

        // Swap options
        String temp = options[i];
        options[i] = options[j];
        options[j] = temp;

        // Update correct answer index if swapped
        if (i == correctAnswerIndex) {
          correctAnswerIndex = j;
        } else if (j == correctAnswerIndex) {
          correctAnswerIndex = i;
        }
      }

      quiz.options = options;
      quiz.correctAnswerIndex = [correctAnswerIndex];
    }
  }
}
