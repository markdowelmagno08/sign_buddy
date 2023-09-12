import 'dart:math';

void shuffleOptions(List<Map<String, dynamic>> assessmentQuestions) {
  bool optionsShuffled = false; // Declare the flag as a local variable

  if (!optionsShuffled) {
    final random = Random();
    for (var question in assessmentQuestions) {
      var options = List<String>.from(
          question['options']); // Make a copy of the original options
      var correctAnswerIndex = question[
          'correctAnswerIndex']; // Get the original correct answer index

      for (int i = options.length - 1; i > 0; i--) {
        int j = random.nextInt(i + 1);

        // Swap options
        var temp = options[i];
        options[i] = options[j];
        options[j] = temp;

        // Update the correctAnswerIndex if it was swapped
        if (i == correctAnswerIndex) {
          correctAnswerIndex = j;
        } else if (j == correctAnswerIndex) {
          correctAnswerIndex = i;
        }
      }

      // Update the 'options' and 'correctAnswerIndex' in the 'assessmentQuestions' with the shuffled options and correct answer index
      question['options'] = options;
      question['correctAnswerIndex'] = correctAnswerIndex;
    }

    optionsShuffled = true; // Set the flag to true after shuffling options
  }
}
