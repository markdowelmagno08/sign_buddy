import 'dart:math';
import 'package:sign_buddy/modules/data/lesson_model.dart';

void shuffleLessonContentOptions(LessonContent content) {
  if (content.contentOption != null && content.correctAnswerIndex != null) {
    final random = Random();
    for (var i = content.contentOption!.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final tempOption = content.contentOption![i];
      content.contentOption![i] = content.contentOption![j];
      content.contentOption![j] = tempOption;

      // Update the correct answer indices if they are affected by the shuffle.
      for (var k = 0; k < content.correctAnswerIndex!.length; k++) {
        if (content.correctAnswerIndex![k] == i) {
          content.correctAnswerIndex![k] = j;
        } else if (content.correctAnswerIndex![k] == j) {
          content.correctAnswerIndex![k] = i;
        }
      }
    }
  }
}
