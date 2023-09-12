import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sign_buddy/modules/lessons/alphabet/shuffle_lesson_options.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:sign_buddy/modules/data/lesson_model.dart';  // Import the lesson model classes
import 'package:sign_buddy/modules/lessons/alphabet/letters.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';

class LessonScreen extends StatefulWidget {
  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {

  
  List<LetterLesson> lessons = [];
  int lessonStep = 0;
  int lessonPage = 1;
  String? selectedOption; // Track the selected option for Quiz 1
  bool answerChecked = false;

  @override
  void initState() {
    super.initState();
    initLessonData();
  }

  void _nextPage() {
    setState(() {
      answerChecked = false;
      lessonPage++; // Move to the next page
    });
  }

  void resetLesson() {
    setState(() {
      lessonPage = 1; // Reset to the first page
      selectedOption = null; // Clear selected option
      answerChecked = false; // Reset answer checked flag
    });
  }

  Future<void> initLessonData() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/lesson_alphabet.json');

    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);

      lessons = List<LetterLesson>.from(
          jsonData.map((lessonJson) => LetterLesson.fromJson(lessonJson)));
      shuffleOptions(lessons); // Shuffle options here

      setState(() {}); // Update the UI with the loaded data
    }
  }

  Widget _buildLessonImage() {
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

  Widget _buildLessonVideo() {
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

  Widget _buildPageContent() {
    if (lessons.isEmpty) {
      return Container(); // Handle the case where lessons list is empty
    }

    if (lessonStep < 0 || lessonStep >= lessons.length) {
      return Container(); // Handle the case where lessonStep is out of bounds
    }

    switch (lessonPage) {
      case 1:
        return _buildLessonImage();
      case 2:
        return _buildLessonVideo();
      case 3:
        return _buildQuiz1(); // Display Quiz 1
      case 4:
        return _buildQuiz2();
      case 5:
        return _buildQuiz3();
      case 6:
        return _buildQuiz4();
      default:
        return Container(); // Replace this with an appropriate default content widget
    }
  }

  Widget _buildQuiz1() {
    LessonQuiz currentQuestion = lessons[lessonStep].quiz1;
    List<String> options = currentQuestion.options;
    List<int> correctAnswerIndices = currentQuestion.correctAnswerIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          currentQuestion.question,
          style: TextStyle(fontSize: 18),
        ),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: options.length,
          itemBuilder: (context, index) {
            return _buildImageOption1(
                index, options[index], correctAnswerIndices);
          },
        ),
      ],
    );
  }

  Widget _buildImageOption1(
      int index, String option, List<int> correctAnswerIndices) {
    int optionIndex = lessons[lessonStep].quiz1.options.indexOf(option);
    bool isCorrectAnswer = correctAnswerIndices.contains(optionIndex);
    bool isSelected = selectedOption == option;
    Color tileColor =
        isSelected ? Colors.grey.withOpacity(0.5) : Colors.transparent;
    if (answerChecked) {
      if (isCorrectAnswer) {
        tileColor = Colors.green.withOpacity(0.3); // Correct answer color
      } else if (isSelected) {
        tileColor =
            Colors.red.withOpacity(0.3); // Incorrect selected answer color
      }
    }

    return GestureDetector(
      onTap: () {
        if (!answerChecked) {
          setState(() {
            selectedOption = option;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: tileColor,
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image.asset(
              option,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuiz2() {
    LessonQuiz currentQuestion = lessons[lessonStep].quiz2;
    List<String> options = currentQuestion.options;
    List<int> correctAnswerIndices = currentQuestion.correctAnswerIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          currentQuestion.question,
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 10),
        if (currentQuestion.quizImage != null)
          Container(
            padding: const EdgeInsets.all(0.0),
            margin: const EdgeInsets.symmetric(horizontal: 90, vertical: 20),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey, // Border color
                width: 2, // Border width
              ),
              color: Colors.white, // Color inside the border// Border radius
            ),
            child: Image.asset(
              currentQuestion.quizImage!,
            ),
          ),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 60,
          ),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: options.length,
          itemBuilder: (context, index) {
            return _buildLetterOption(
              index,
              options[index],
              correctAnswerIndices,
            );
          },
        ),
      ],
    );
  }

  Widget _buildLetterOption(
      int index, String option, List<int> correctAnswerIndices) {
    int optionIndex = lessons[lessonStep].quiz2.options.indexOf(option);
    bool isCorrectAnswer = correctAnswerIndices.contains(optionIndex);
    bool isSelected = selectedOption == option;
    Color tileColor =
        isSelected ? Colors.grey.withOpacity(0.5) : Colors.transparent;
    if (answerChecked) {
      if (isCorrectAnswer) {
        tileColor = Colors.green.withOpacity(0.3); // Correct answer color
      } else if (isSelected) {
        tileColor =
            Colors.red.withOpacity(0.3); // Incorrect selected answer color
      }
    }

    return GestureDetector(
      onTap: () {
        if (!answerChecked) {
          setState(() {
            selectedOption = option;
          });
        }
      },
      child: SizedBox(
        height: 10, // Adjust the height as needed
        width: 10,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: tileColor,
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              option,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuiz3() {
    LessonQuiz currentQuestion = lessons[lessonStep].quiz3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          currentQuestion.question,
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey, // Border color
              width: 2, // Border width
            ),
            color: Colors.white, // Color inside the border// Border radius
          ),
          child: Image.asset(
            currentQuestion.quizImage!,
          ),
        ),
        SizedBox(height: 20),
        _buildYesNoOption(),
      ],
    );
  }

  Widget _buildYesNoOption() {
    LessonQuiz currentQuestion = lessons[lessonStep].quiz3;
    List<String> options = currentQuestion.options;

    bool isAnswerChecked = answerChecked;
    String selectedOption = this.selectedOption ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: options.map((option) {
        int optionIndex = options.indexOf(option);
        bool isOptionSelected = selectedOption == option;
        bool isCorrectAnswer =
            currentQuestion.correctAnswerIndex.contains(optionIndex);

        Color tileColor = isOptionSelected
            ? (isAnswerChecked
                ? (isCorrectAnswer
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3))
                : Colors.grey.withOpacity(0.2))
            : Colors.transparent;

        IconData icon = isCorrectAnswer
            ? FontAwesomeIcons.thumbsUp
            : FontAwesomeIcons.thumbsDown;

        return GestureDetector(
          onTap: () {
            if (!isAnswerChecked) {
              setState(() {
                this.selectedOption = option;
              });
            }
          },
          child: Container(
            width: 70,
            height: 70,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tileColor,
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Color(0xFF5BD8FF),
                  size: 25,
                ),
                SizedBox(height: 5),
                Text(
                  option,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuiz4() {
    LessonQuiz currentQuestion = lessons[lessonStep].quiz4;
    List<String> options = currentQuestion.options;
    List<int> correctAnswerIndices = currentQuestion.correctAnswerIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          currentQuestion.question,
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 10),
        if (currentQuestion.quizImage != null)
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(currentQuestion.quizImage!),
            ),
          ),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 50,
          ),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: options.length,
          itemBuilder: (context, index) {
            return _buildWordOption(
              index,
              options[index],
              correctAnswerIndices,
            );
          },
        ),
      ],
    );
  }

  Widget _buildWordOption(
      int index, String option, List<int> correctAnswerIndices) {
    int optionIndex = lessons[lessonStep].quiz4.options.indexOf(option);
    bool isCorrectAnswer = correctAnswerIndices.contains(optionIndex);
    bool isSelected = selectedOption == option;
    Color tileColor =
        isSelected ? Colors.grey.withOpacity(0.5) : Colors.transparent;
    if (answerChecked) {
      if (isCorrectAnswer) {
        tileColor = Colors.green.withOpacity(0.3); // Correct answer color
      } else if (isSelected) {
        tileColor =
            Colors.red.withOpacity(0.3); // Incorrect selected answer color
      }
    }

    return GestureDetector(
      onTap: () {
        if (!answerChecked) {
          setState(() {
            selectedOption = option;
          });
        }
      },
      child: SizedBox(
        child: Container(
          decoration: BoxDecoration(
            color: tileColor,
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              option,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _checkAnswer() {
    LessonQuiz currentQuestion;
    switch (lessonPage) {
      case 3:
        currentQuestion = lessons[lessonStep].quiz1;
        break;
      case 4:
        currentQuestion = lessons[lessonStep].quiz2;
        break;
      case 5:
        currentQuestion = lessons[lessonStep].quiz3;
        break;
      case 6:
        currentQuestion = lessons[lessonStep].quiz4;
        break;
      default:
        return; // Return if it's not quiz 1 to 4
    }

    List<int> correctAnswerIndices = currentQuestion.correctAnswerIndex;

    int selectedIndex = currentQuestion.options.indexOf(selectedOption!);
    bool isAnswerCorrect = correctAnswerIndices.contains(selectedIndex);

    setState(() {
      answerChecked = true;
    });

    IconData icon = isAnswerCorrect
        ? FontAwesomeIcons.solidCheckCircle
        : FontAwesomeIcons.solidTimesCircle;
    String resultMessage = isAnswerCorrect ? 'Correct' : 'Incorrect';

    if (isAnswerCorrect) {
      showResultSnackbar(context, resultMessage, icon);
    } else {
      // Reset lesson if answer is incorrect
      showResultSnackbar(context, resultMessage, icon, resetLesson);
    }
  }

  void showResultSnackbar(BuildContext context, String message, IconData icon,
      [VoidCallback? callback]) {
    int totalLessons = lessons.length;
    Color backgroundColor;
    Color fontColor;
    TextStyle textStyle;

    if (message == 'Correct') {
      backgroundColor = Colors.green.shade100;
      fontColor = Colors.green;
      textStyle = TextStyle(
        color: fontColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'FiraSans',
      );
    } else {
      backgroundColor = Colors.red.shade100;
      fontColor = Colors.red;
      textStyle = TextStyle(
        color: fontColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'FiraSans',
      );
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: SizedBox(
              height: 60,
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: fontColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    message,
                    style: textStyle,
                  ),
                ],
              ),
            ),
            backgroundColor: backgroundColor,
            duration: const Duration(days: 365), // Change duration as needed
            dismissDirection: DismissDirection.none,
            action: SnackBarAction(
              label: 'Next',
              textColor: Colors.grey.shade700,
              backgroundColor: Colors.blue.shade200,
              onPressed: () {
                if (callback != null) {
                  callback(); // Call the provided callback if it's not null // reset the lesson if the user got wrong answer
                } else if (lessonPage <= totalLessons) {
                  _nextPage();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
        )
        .closed
        .then((reason) {
      setState(() {
        selectedOption = null; // Reset selectedOption
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget nextButton = Container();
    int totalLessons = lessons.length;

    if (lessonPage <= totalLessons) {
      // Compare with the total number of lessons
      nextButton = TextButton(
        onPressed: () {
          if ((lessonPage == 3 || lessonPage == 4 || lessonPage == 5) &&
              !answerChecked) {
            // Check for both lesson 3 and lesson 4
            if (selectedOption != null) {
              _checkAnswer();
            }
          } else {
            _nextPage();
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              (lessonPage == 3 ||
                      lessonPage == 4 ||
                      lessonPage == 5 && !answerChecked)
                  ? FontAwesomeIcons.check // Change the icon to check
                  : FontAwesomeIcons.arrowRight, // Keep the original icon
              color: Color(0xFF5BD8FF),
            ),
            Text(
              (lessonPage == 3 ||
                      lessonPage == 4 ||
                      lessonPage == 5 && !answerChecked)
                  ? 'Check'
                  : 'Next',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      );

      // Disable the "Check" button if no option is selected
      if (selectedOption == null &&
          !answerChecked &&
          (lessonPage == 3 || lessonPage == 4 || lessonPage == 5)) {
        nextButton = TextButton(
          onPressed: null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.check,
                color: Color(0xFF5BD8FF),
              ),
              Text(
                'Check',
                style: TextStyle(
                  color:
                      Colors.black.withOpacity(0.6), // Adjust text opacity here
                ),
              ),
            ],
          ),
        );
      }
    }
    // Adjust the conditions for showing the "Check" and "Next" buttons
    if (lessonPage == 6 && !answerChecked) {
      nextButton = TextButton(
        onPressed: selectedOption != null ? _checkAnswer : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.check,
              color: Color(0xFF5BD8FF),
            ),
            Text(
              'Check',
              style: TextStyle(
                color: selectedOption != null
                    ? Colors.black
                    : Colors.black.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.topLeft,
              child: CustomBackButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    SlidePageRoute(page: const Letters()),
                  );
                },
              ),
            ),
            const SizedBox(height: 70),
            _buildPageContent(),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Material(
                    borderRadius: BorderRadius.zero,
                    child: SizedBox(
                      width: 100,
                      height: 60,
                      child: nextButton,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
