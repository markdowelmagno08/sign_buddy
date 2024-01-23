import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/sign_up.dart';
import 'package:intl/intl.dart';



class AssessmentResult extends StatefulWidget {
  final int score;
  final int totalQuestions;

  AssessmentResult({
    Key? key,
    required this.score,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  _AssessmentResultState createState() => _AssessmentResultState();
}

class _AssessmentResultState extends State<AssessmentResult> {

  bool isEnglish = true;

  
  
  @override
  void initState() {
    super.initState();
    getLanguage();
    
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;
    
    setState(() {
      this.isEnglish = isEnglish;
    });
  }
  String getLanguageKnowledge() {
    int score = widget.score;
    if (score >= 0 && score <= 3) {
      return isEnglish ? "I’m new to English Sign Language" : "Bagohan sa Filipino Sign Language";
    } else if (score >= 4 && score <= 5) {
      return isEnglish ? "I know some sign language words and phrases": "May kaalaman sa pagsenyas ng salita at parirala";
    } else if (score >= 6 && score <= 8) {
      return isEnglish ? "I can have a simple conversation using English Sign Language": "Simpleng pag-uusap gamit ang Filipino Sign Language";
    } else {
      return "Assessment not completed";
    }
  }

  String getLanguageLevel() {
    String languageKnowledge = getLanguageKnowledge();
    if (languageKnowledge == "I’m new to English Sign Language" || languageKnowledge == "Bagohan sa Filipino Sign Language") {
      return "Basic Level";
    } else if (languageKnowledge == "I know some sign language words and phrases" || languageKnowledge == "May kaalaman sa pagsenyas ng salita at parirala") {
      return "Intermediate Level";
    } else if (languageKnowledge == "I can have a simple conversation using English Sign Language" || languageKnowledge == "Simpleng pag-uusap gamit ang Filipino Sign Language") {
      return "Advanced Level";
    } else {
      return "Assessment not completed";
    }
  }

  String getCongratulatoryMessage() {
    if (widget.score == widget.totalQuestions) {
      return isEnglish ?  "Congratulations! You got a perfect score!" : "Pagbati! Nakakuha ka ng perpektong puntos";
    } else {
      return "";
    }
  }
    Future<void> _storeAssessmentResult() async {
      try {
        // Get the current user
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          String languageLevel = getLanguageLevel(); // Get the modified level string

          // Get the current date as a string (e.g., January 11, 2024)
          String formattedDate =
              "${DateFormat.MMMM().format(DateTime.now().toLocal())} ${DateTime.now().toLocal().day}, ${DateTime.now().toLocal().year}";
          
          DateTime timestamp = DateTime.now();
 

          // Get the user count for the current date from Firestore
          DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
              .collection('userCount')
              .doc(formattedDate) 
              .get();

          int userCount = (documentSnapshot.exists) ? documentSnapshot['count'] + 1 : 1;

          // Update the user count for the current date in Firestore
          await FirebaseFirestore.instance.collection('userCount').doc(formattedDate).set({
            'count': userCount,
          });

          // Store the assessment result in Firestore under the user's UID
          await FirebaseFirestore.instance.collection('userData').doc(currentUser.uid).set({
            'assessmentResult': widget.score,
            'knowLevel': languageLevel, // Store the modified level string separately
            'accountCreated': timestamp, // Add timestamp field with the current date
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
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 100),
                    Image.asset(
                      'assets/congrats-img.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                    const SizedBox(height: 20),
                     Text(
                      isEnglish ? 'Assessment Completed!' : "Natapos na ang Pagsusuri!",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isEnglish ? 'Your score: ${widget.score}/${widget.totalQuestions}' : 'Puntos: ${widget.score}/${widget.totalQuestions}',
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
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      getCongratulatoryMessage(),
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: SizedBox(
                      width: 140,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _storeAssessmentResult();
                          Navigator.pushReplacement(
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
                          isEnglish ? 'Continue' : "Magpatuloy",
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height:10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
