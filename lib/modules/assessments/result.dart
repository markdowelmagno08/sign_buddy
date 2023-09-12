import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/sign_up.dart';

class AssessmentResult extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const AssessmentResult({
    Key? key,
    required this.score,
    required this.totalQuestions,
  }) : super(key: key);

  String getLanguageKnowledge() {
    if (score >= 1 && score <= 3) {
      return "I’m new to English Sign Language";
    } else if (score >= 4 && score <= 5) {
      return "I know some sign language words and phrases";
    } else if (score >= 6 && score <= 8) {
      return "I can have a simple conversation using English Sign Language";
    } else {
      return "Assessment not completed";
    }
  }

  String getLanguageLevel() {
    String languageKnowledge = getLanguageKnowledge();
    if (languageKnowledge == "I’m new to English Sign Language") {
      return "Basic Level";
    } else if (languageKnowledge ==
        "I know some sign language words and phrases") {
      return "Intermediate Level";
    } else if (languageKnowledge ==
        "I can have a simple conversation using English Sign Language") {
      return "Advanced Level";
    } else {
      return "Assessment not completed";
    }
  }

  String getCongratulatoryMessage() {
    if (score == totalQuestions) {
      return "Congratulations! You got a perfect score!";
    } else {
      return "";
    }
  }

  Future<void> _storeAssessmentResult() async {
    try {
      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String languageLevel =
            getLanguageLevel(); // Get the modified level string

        // Store the assessment result in Firestore under the user's UID
        await FirebaseFirestore.instance
            .collection('userData')
            .doc(currentUser.uid)
            .set({
          'assessmentResult': score,
          'knowLevel':
              languageLevel, // Store the modified level string separately
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const SizedBox(height: 70),
                  Image.asset(
                  'assets/congrats-img.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
                const SizedBox(height: 20),
                  const Text(
                    'Assessment Completed!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your score: $score/$totalQuestions',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      getLanguageKnowledge(), // Display the original string
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                getCongratulatoryMessage(),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              const SizedBox(height: 60),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: SizedBox(
                    width: 120,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _storeAssessmentResult();
                        Navigator.push(
                          context,
                          SlidePageRoute(page: const SignupPage()),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF5BD8FF),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
