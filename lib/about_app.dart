import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutApp extends StatefulWidget {
  const AboutApp({super.key});

  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                AppBar(
                  backgroundColor: const Color(0xFF5A96E3),
                  title: Text(
                    'About',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'FiraSans',
                    ),
                  ),
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/app_icon.png', 
                        height: 70, 
                      ),
                      SizedBox(width: 10),
                      Text(
                        'SignBuddy for Everyone',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'FiraSans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Welcome to SignBuddy! Our app is designed to make learning and using sign language an enjoyable and accessible experience for everyone.',
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'FiraSans',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                
                buildModuleCard(
                  'English and Filipino\nSign Language Lessons',
                  'Unlock the world of sign language with our comprehensive lessons. SignBuddy supports both English and Filipino sign languages, providing a learning experience for users seeking to enhance their communication skills.',
                  FontAwesomeIcons.book, // Icon for Module 1
                ),

                // Module 2
                buildModuleCard(
                  'Sign Alphabet',
                  'Explore the Sign Alphabet module, you can interactively discover sign language gestures by tapping on letters displayed on the screen. Learn the basics of finger movements and gestures that form the foundation of sign language.'
                  ,Icons.sign_language,
                ),
                

                // Module 3
                buildModuleCard(
                  'Find Sign',
                  'Searching for a specific sign? Our "Find Sign" feature lets you easily locate and view video demonstrations of sign language for both Filipino and English. With suggested search functionality, you can quickly find the signs you need, making communication effortless.',
                  FontAwesomeIcons.magnifyingGlass,
                ),

                // Module 4
                buildModuleCard(
                  'Finger Spelling ',
                  'Type out words or phrases, and let SignBuddy transform them into Sign Exact English (SEE). Our Finger Spelling module dynamically displays the corresponding alphabet signs, helping you understand and express a wide range of words and phrases in sign language.',
                  FontAwesomeIcons.handFist
                ),

                // Module 5
                buildModuleCard(
                  'Word Fusion',
                  'Unleash your creativity with Word Fusion! This unique module allows you to combine phrases and words, generating a carousel of search results presented in video format. Swipe through the results to discover new and expressive ways to communicate using sign language.',
                  Icons.video_library
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create a Card for each module
// Helper method to create a Card for each module with icons
Widget buildModuleCard(String title, String description, IconData iconData) {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: Colors.grey),
    ),
    margin: EdgeInsets.only(left: 20, right: 20, bottom: 30),
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                iconData,
                size: 30,
                color: Colors.deepPurpleAccent, // Adjust the color as needed
              ),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'FiraSans',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'FiraSans',
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ),
  );
}


}
