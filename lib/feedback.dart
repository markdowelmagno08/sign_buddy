import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/modules/home_page.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:sign_buddy/sign_up.dart';

class FeedbackApp extends StatefulWidget {
  const FeedbackApp({Key? key}) : super(key: key);

  @override
  State<FeedbackApp> createState() => _FeedbackAppState();
}






class _FeedbackAppState extends State<FeedbackApp> {
  final _feedbackFormKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  bool isLoading = true;
  bool isEnglish = true;


  @override
    void initState() {
      getLanguage();
      super.initState();
    }

  Future<void> getLanguage() async {
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getBool('isEnglish');

      if (mounted) {
        setState(() {
          isEnglish = locale!;
        });
      }
    }

  @override
  Widget build(BuildContext context) {
    if (Auth().isUserAnonymous()) {
        // If the user is anonymous, display this ui
        return Scaffold(
        body:  Stack(
            children: [
              // Background Image
              Image.asset(
                'assets/bg-signbuddy.png',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),
              // Back Button aligned to top-left
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: CustomBackButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              // Image at the top
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/feedback.png',
                      height: 120,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Simulan ang Iyong Profile\nIbahagi ang Iyong Feedback",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the sign-up page
                        Navigator.pushReplacement(context, SlidePageRoute(page: const SignupPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color.fromARGB(255, 71, 63, 63),
                        backgroundColor: Color(0xFF5BD8FF),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
         Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg-signbuddy.png'),
                fit: BoxFit.cover,
              ),
            ),
          ), 
          SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: Form(
                    key:_feedbackFormKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              AppBar(
                                title: Text(
                                  'Feedback',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'FiraSans',
                                  ),
                                ),
                                backgroundColor: const Color(0xFF5A96E3).withOpacity(0.8),
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(50),
                                    bottomRight: Radius.circular(50),
                                  ),
                                ),
                              ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/feedback1.png', // Replace with the path to your image
                                        height: 120, // Adjust the height as needed
                                      ),
                                      SizedBox(height: 20),
                                      Center(
                                        child: Text(
                                          isEnglish ? 
                                          "Share your thoughts with us! \nWhether it's a suggestion, a problem report, or any other feedback \nWe want to hear from you!" 
                                          : 'Ibahagi ang iyong mga iniisip o pansin sa amin! Maging ito\'y rekomendasyon, ulat ng problema, o anumang iba pang feedback. Nais naming marinig mula sa iyo',
                                          
                                          style: TextStyle(fontSize: 16, height: 1.5),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      TextFormField(
                                        style: TextStyle(fontSize: 17.0,  color: Colors.black),
                                        controller: _feedbackController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 30.0),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.deepPurpleAccent,
                                            ),
                                          ),
                                        ),
                                        inputFormatters: [
                                          CustomInputFormatter(maxLength: 100),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your feedback';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          child: ElevatedButton(
                            onPressed: () {
                            if (_feedbackFormKey.currentState!.validate()) {
                                // Form is valid, send feedback to Firestore
                                sendFeedbackToFirestore();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF5BD8FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.all(16.0),
                            ),
                            child: Text('Send', style: TextStyle(fontSize: 18, color: Colors.grey.shade700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      

      @override
      void dispose() {
        _feedbackController.dispose();
        super.dispose();
      }



      Future<void> sendFeedbackToFirestore() async {

        // Retrieve the current user from FirebaseAuth
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          String feedbackText = _feedbackController.text.trim();
          String userId = user.uid;
          String email = user.email!;
          Timestamp timestamp = Timestamp.now();

          // Create a feedback document in Firestore
          await FirebaseFirestore.instance.collection('feedback').add({
            'feedback': feedbackText,
            'timestamp': timestamp,
            'userId': userId,
            'email': email,
          });

           // Reset the TextEditingController
          _feedbackController.clear();

          Navigator.pushReplacement(
            context, SlidePageRoute(page: const ThankYouScreen()));
        } else {
          // Handle the case where the user is not signed in
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User not signed in. Please sign in and try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      
}


class ThankYouScreen extends StatefulWidget {
  const ThankYouScreen({Key? key}) : super(key: key);

  @override
  _ThankYouScreenState createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen> {
  bool isEnglish = true;

  @override
  void initState() {
    super.initState();
    getLanguage();
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getBool('isEnglish');

    if (mounted) {
      setState(() {
        isEnglish = locale!; 
      });
    }
  }
    
    
  
  @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                  'assets/sent-img.png', // Replace with the path to your image
                height: 120, // Adjust the height as needed
              ),
              SizedBox(height: 20),
              Text(
                isEnglish ? 'Thank You!' : 'Maraming Salamat!',
                style: TextStyle(fontFamily: 'FiraSans', fontWeight: FontWeight.bold, fontSize: 24),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'Lubos kaming nagpapasalamat sa iyong feedback',
                  style: TextStyle(fontFamily: 'FiraSans',fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the sign-up page
                  Navigator.pushReplacement(
                      context, SlidePageRoute(page: const HomePage()));
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  backgroundColor: Color(0xFF5BD8FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                ),
                child: Text(
                  'Okay',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )   
            ],
          ),
        ),
      );
    }
  }

class CustomInputFormatter extends TextInputFormatter {
  final int maxLength;

  CustomInputFormatter({required this.maxLength});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isNotEmpty) {
      // Capitalize the first letter
      String formattedText =
          newValue.text[0].toUpperCase() + newValue.text.substring(1);

      // Check if the length exceeds maxLength
      if (formattedText.length > maxLength) {
        // Truncate the text if it exceeds maxLength
        formattedText = formattedText.substring(0, maxLength);
      }

      return TextEditingValue(
        text: formattedText,
        selection: newValue.selection,
      );
    }
    return newValue;
  }
}

