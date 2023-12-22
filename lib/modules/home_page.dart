import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_buddy/about_app.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/feedback.dart';
import 'package:sign_buddy/locale.dart';
import 'package:sign_buddy/modules/finger_spelling.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/sign_alphabet.dart';
import 'package:sign_buddy/settings.dart';
import 'package:sign_buddy/sign_up.dart';
import 'package:sign_buddy/user_account.dart';


class LessonsScreen extends StatefulWidget {
  const LessonsScreen({Key? key}) : super(key: key);

  @override
  _LessonsScreenState createState() => _LessonsScreenState();
}



class _LessonsScreenState extends State<LessonsScreen> {
  int? selectedLessonIndex;

  final List<Map<String, dynamic>> lessons = [
    {
      'en': 'Alphabet',
      'ph': 'Alpabeto',
      'icon': 'lesson-icon/img1.png',
    },
    {
      'en': 'Numbers',
      'ph': 'Mga Numero',
      'icon': 'lesson-icon/img2.png',
    },
    {
      'en': 'Animals',
      'ph': 'Mga Hayop',
      'icon': 'lesson-icon/img6.png',
    },
    {
      'en': 'Colors',
      'ph': 'Mga Kulay',
      'icon': 'lesson-icon/img4.png',
    },
    {
      'en': 'Family',
      'ph': 'Pamilya',
      'icon': 'lesson-icon/img3.png',
    },
    {
      'en': 'Greetings',
      'ph': 'Pagbati',
      'icon': 'lesson-icon/img10.png',
    },
    
    
  ];

  bool isEnglish = true;
  bool isLoading = true;

  Future<void> getLanguageFromFirestore() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('userData')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (snapshot.exists) {
        String languageFromFirestore = snapshot.get('language');

        // Check if the language is English
        if (languageFromFirestore == 'English') {
          setLanguage(true);
          setState(() {
          // Update the state variable isEnglish based on the fetched language
          isEnglish = languageFromFirestore == 'English';
          });
        } else {
            setLanguage(false);
            setState(() {
            // Update the state variable isEnglish based on the fetched language
            isEnglish = false;
          });
        }        
      }
    } catch (e) {
      print('Error fetching language from Firestore: $e');
    }
  }

  

  @override
  void initState() {
    getLanguageFromFirestore().then((_) {
      setState(() {
        
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/bg-signbuddy.png'), // Replace with your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 45),
              child: Text(
                isEnglish ? 'Lessons' : 'Mga Aralin',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  final lessonName = isEnglish ? lesson['en'] : lesson['ph'];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: const BorderSide(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        _navigateToStartLesson(context, lessonName);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/${lesson['icon']}',
                            width: 48,
                            height: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lessonName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _navigateToStartLesson(BuildContext context, String lesson) {
  final lessonMap = {
    'Alphabet': '/basic',
    'Alpabeto': '/basic',
    'Numbers': '/numbers',
    'Mga Numero': '/numbers',
    'Family': '/family',
    'Pamilya': '/family',
    'Animals': '/animals',
    'Mga Hayop': '/animals',
    'Time and Days': '/timeAndDays',
    'Oras at Araw': '/timeAndDays',
    'Colors' : '/color',
    'Mga Kulay': '/color',
    'Greetings': '/greeting',
    'Pagbati': '/greeting',
  };

  final route = lessonMap[lesson];

  if (route != null) {
    Navigator.pushNamed(context, route);
  } else {
    // Handle the case when the lesson is not found
  }
}







class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  bool isEnglish = true;
  bool isLoading = true;

  final List<Widget> _screens = [
    LessonsScreen(),
    AlphabetScreen(),
    // FindSign(),
    FingerSpelling(),
    // CreateSignPage(),
  ];



   

  

  Future<void> getLanguageFromFirestore() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('userData')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (snapshot.exists) {
        String languageFromFirestore = snapshot.get('language');

        // Check if the language is English
        if (languageFromFirestore == 'English') {
          setLanguage(true);
          setState(() {
            
            // Update the state variable isEnglish based on the fetched language
            isEnglish = languageFromFirestore == 'English';
          });
        } else {
            setLanguage(false);
            setState(() {
            // Update the state variable isEnglish based on the fetched language
            isEnglish = false;
          });
        }        
      }
    } catch (e) {
      print('Error fetching language from Firestore: $e');
    }
  }

  

  @override
  void initState() {
    getLanguageFromFirestore().then((_) {
      setState(() {
        
      });
    });
    super.initState();
  }



    @override
  Widget build(BuildContext context) {

    // Get the user ID
    String? userId = Auth().getCurrentUserId();

    // Use the user ID to get a randomly selected profile image
    String? selectedProfileImage = getProfileImageForUser(userId);


    return WillPopScope(
      onWillPop: () async {
        // Return false to indicate that you don't want to pop the route
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: const Color(0xFF5A96E3),
          title: Row(
            children: [
              Image.asset(
                'assets/app_icon.png',
                width: 30, 
                height: 30, 
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(
                  'SignBuddy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontFamily: 'FiraSans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Image.asset(
                isEnglish ? 'assets/america.png' : 'assets/ph.png',
                width: 25, 
                height: 25, 
              ),
            ),
          ],
        ),
        drawer:Drawer(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg-signbuddy.png'),
                fit: BoxFit.cover, // You can adjust the fit as needed
              ),
            ),
            child: Column(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF5A96E3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // CircleAvatar with the user image
                       Padding(
                        padding: const EdgeInsets.only(left: 9),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.grey,
                            // Use the randomly selected profile image
                            backgroundImage: selectedProfileImage != null
                                ? AssetImage(selectedProfileImage)
                                : AssetImage('assets/user_man.png'), // Provide a default image if needed
                          ),
                        )
                      ),

                      // User data in the center
                      buildUserData(),

                      // IconButton on the top right
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              _scaffoldKey.currentState?.openEndDrawer();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // ListTile with border and ">" icon
                buildListTileWithBorderAndIcon(
                  icon: Icons.person,
                  title: 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        page: UserAccountPage()
                      ),
                    );
                    
                  },
                ),
               
                buildListTileWithBorderAndIcon(
                  icon: Icons.info,
                  title: 'About',
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        page: AboutApp()
                      ),
                    );
                    
                  },
                ),
                buildListTileWithBorderAndIcon(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        page: MySettings()
                      ),
                    );
                  },
                ),
                buildListTileWithBorderAndIcon(
                  icon: Icons.feedback,
                  title: 'Feedback',
                  onTap: () {
                   Navigator.push(
                      context,
                      SlidePageRoute(
                        page: FeedbackApp(),
                      ),
                    );
                  },
                ),

                //hide the logout button for authenticated users
                if (Auth().isUserAnonymous()) 
                buildListTileWithBorderAndIcon(
                  icon: Icons.exit_to_app,
                  title: 'Sign out',
                  onTap: () async {
                      bool confirmLogout = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Text(isEnglish ? 'Are you sure you want to sign out?' : 'Sigurado ka bang nais mong mag-sign out?',
                            style: TextStyle(
                              fontFamily: 'FiraSans',
                              fontWeight: FontWeight.w300,
                            )),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(isEnglish ? 'CANCEL' : 'KANSEL',
                                style: TextStyle(
                                  color: Colors.black,
                                )),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('SIGN OUT',
                                style: TextStyle(
                                  color: Colors.red,
                                )),
                            ),
                          ],
                        ),
                      );

                      if (confirmLogout == true) {
                        
                         await Auth().signOut();
                         
                        
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false);
                      }
                    }
                  
                ),
                // Footer with version number
                Spacer(), // Ensures the footer is centered vertically
                Padding(
                  padding: const EdgeInsets.only(bottom: 10), // Adjust the bottom padding
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF5BD8FF),
        unselectedItemColor: Colors.grey[800],
        selectedItemColor: Colors.black,
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            // Check if the selected item is not the current screen
            if (index == 1) {
              // Navigate to AlphabetScreen
              Navigator.pushNamed(context, '/alphabet');
            } else if (index == 2) {
              // Navigate to FindSign
              Navigator.pushNamed(context, '/findSign');
            }
            else if (index == 3) {
              // Navigate to FindSign
              Navigator.pushNamed(context, '/fingerSpell');
            }
            else if (index == 4) {
              // Navigate to FindSign
              Navigator.pushNamed(context, '/createSign');
            }
              else {
              // Change the current screen if it's not Alphabet or Find Sign
              setState(() {
                _currentIndex = index;
              });
            }
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Lessons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields),
            label: 'Alphabet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Find Sign',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.spellcheck),
            label: 'Finger Spell',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Word Fusion',
          ),
          
          
        ],
        selectedLabelStyle: TextStyle(fontSize: 11), // Adjust the fontSize as needed
        unselectedLabelStyle: TextStyle(fontSize: 11), // Adjust the fontSize as needed
      ),
      ),
    );
  }
  Widget buildUserData() {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('userData')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }

      if (snapshot.hasError) {
        return const Text('Error fetching data');
      }

      var userData = snapshot.data!.data() as Map<String, dynamic>;
      var firstName = userData['firstName'];
      var lastName = userData['lastName'];

      // Check if firstName or lastName is empty
      if (firstName == null ||
          firstName.isEmpty ||
          lastName == null ||
          lastName.isEmpty) {
        return Column(
          children: [
            SizedBox(height: 30),
             Text(
              isEnglish ? 'Make a profile!' : 'Simulan ang\nprofile!',
              style: TextStyle(
                  color: Colors.white, fontSize: 15, fontFamily: 'FiraSans', fontWeight: FontWeight.bold ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [// Add some spacing between the buttons
                ElevatedButton(
                  onPressed: () {
                    // Navigate to sign up page
                    Navigator.pushReplacement(
                        context, SlidePageRoute(page: const SignupPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        );
      }

      // Capitalize the first letter
      String capitalizeFirstLetter(String name) {
        return name[0].toUpperCase() + name.substring(1);
      }

      String formattedName(String firstName, String lastName) {
      List<String> firstNameWords = firstName.split(' ');

      if (firstNameWords.length > 1) {
        // If the first name has more than one word, put the second word on a new line
        return '${capitalizeFirstLetter(firstNameWords[0])}\n${capitalizeFirstLetter(firstNameWords[1])}\n$lastName';
      } else if (firstName.length > 5 || lastName.length > 5) {
        // If the first name has one word and is longer than 5 characters or the last name is longer than 5 characters, put them on a new line
        return '$firstName\n$lastName';
      } else {
        // Otherwise, concatenate the first and last names with a space
        return '$firstName $lastName';
      }
    }

      return Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          formattedName(
            capitalizeFirstLetter(firstName),
            capitalizeFirstLetter(lastName),
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'FiraSans',
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    },
  );
}

}

//randomly gives the user an profile image
  String? getProfileImageForUser(String? userId) {
      if (userId == null) {
        // Handle the case where userId is null (if needed)
        return null;
      }

      // List of user profile images
      final List<String> userImages = [
        'assets/user_img/user_1.png',
        'assets/user_img/user_2.png',
        'assets/user_img/user_3.png',
        'assets/user_img/user_4.png',
        'assets/user_img/user_5.png',
        'assets/user_img/user_6.png',
        'assets/user_img/user_7.png',
        'assets/user_img/user_8.png',
        'assets/user_img/user_9.png',
        'assets/user_img/user_10.png',
        'assets/user_img/user_11.png',
        'assets/user_img/user_12.png',
      ];

      // Use the user ID to generate a random index for selecting a profile image
      int randomIndex = userId.hashCode % userImages.length;

      // Ensure the index is non-negative
      randomIndex = randomIndex < 0 ? -randomIndex : randomIndex;

      // Return the selected profile image
      return userImages[randomIndex];
    }

Widget buildListTileWithBorderAndIcon({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return Container(
    child: Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(
            color: Color(0xFF5A96E3),
            width: 1.0,
          ),
        ),
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: Icon(Icons.chevron_right), // ">" icon
          onTap: onTap,
        ),
      ),
    ),
  );
}

