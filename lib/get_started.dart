

import 'package:flutter/material.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/choose_language.dart';
import 'package:sign_buddy/firestore_user.dart';
import 'package:sign_buddy/front_page.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';

void main() {
  runApp(const GetStartedPage());
}

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({Key? key}) : super(key: key);

  @override
  _GetStartedPageState createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  bool showModal = false;
  final PageController _pageController = PageController(initialPage: 0);

  int _currentPage = 0;
  bool loading = false;

  List<String> assessments = [
    'Share any specific requirements or preferences you have, so we can personalize your app experience',
    'Select your preferred language for learning sign language.',
    'Indicate your sign language proficiency level for personalized lessons.',
  ];

  List<String> images = [
    'assets/image1.png',
    'assets/image2.png',
    'assets/image3.png',
  ];

  void showReminderModal() {
    if (_currentPage == assessments.length - 1) {
      setState(() {
        showModal = true;
      });
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void hideReminderModal() {
    setState(() {
      showModal = false;
    });
  }

  void goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      setState(() {
        _currentPage--;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FrontPage()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg-signbuddy.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: assessments.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50),
                        if (_currentPage < 3)
                          CustomBackButton(
                            onPressed: () {
                              Navigator.push(
                                  context, SlidePageRoute(page: FrontPage()));
                            },
                          ),
                        const SizedBox(height: 100),
                        const Center(
                          child: Text(
                            'Sign language is beautiful and expressive.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Center(
                          child: Image.asset(
                            images[index],
                            height: 120,
                            width: 120,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: Text(
                            assessments[index],
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (_currentPage == 0) const Spacer(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: ElevatedButton(
                                onPressed: showReminderModal,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF5BD8FF),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 16.0),
                                  textStyle: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                child: Text(
                                  _currentPage == assessments.length - 1
                                      ? 'Get Started'
                                      : 'Next',
                                  style: const TextStyle(
                                    fontFamily: 'FiraSans',
                                    color: Color(0xFF5A5A5A),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (showModal)
              GestureDetector(
                onTap: hideReminderModal,
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Reminder',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Please ensure that you have someone accompanying you before using this app.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF5BD8FF),
                            ),
                            onPressed: () {
                              signInAnonymously();
                              Navigator.push(
                                  context, SlidePageRoute(page: ChooseLanguages()));
                            },
                            child: const Text(
                              'Got It!',
                              style: TextStyle(
                                color: Color(0xFF5A5A5A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (loading) LoadingDialog(),
          ],
        ),
      ),
    );
  }

  Widget LoadingDialog() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signInAnonymously() async {
    try {
      setState(() {
        loading = true;
      });

      await Auth().signInAnonymously();
      String? userId = Auth().getCurrentUserId();

      if (userId != null) {
        UserFirestore(userId: userId).createNewAnonymousAccount();
        UserFirestore(userId: userId).initializeLessons("letters", "en");
        UserFirestore(userId: userId).initializeLessons("numbers", "en");
        UserFirestore(userId: userId).initializeLessons("family", "en");
        UserFirestore(userId: userId).initializeLessons("greetings", "en");
        UserFirestore(userId: userId).initializeLessons("animals", "en");
        UserFirestore(userId: userId).initializeLessons("color", "en");
        UserFirestore(userId: userId).initializeLessons("letters", "ph");
        UserFirestore(userId: userId).initializeLessons("numbers", "ph");
        UserFirestore(userId: userId).initializeLessons("family", "ph");
        UserFirestore(userId: userId).initializeLessons("greetings", "ph");
        UserFirestore(userId: userId).initializeLessons("animals", "ph");
        UserFirestore(userId: userId).initializeLessons("color", "ph");
      } else {
        print("User ID is null");
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print("Error during authentication: $e");
      setState(() {
        loading = false;
      });
    }
  }
}
