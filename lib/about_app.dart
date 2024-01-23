import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutApp extends StatefulWidget {
  const AboutApp({super.key});

  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {

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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg-signbuddy2.png'),
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
                        'assets/app_icon1.png', 
                        height: 70, 
                      ),
                      SizedBox(width: 10),
                      Text(
                        isEnglish ? 'SignBuddy for Everyone' : 'SignBuddy para sa Lahat',
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
                    isEnglish ? 'Welcome to SignBuddy! Our app is designed to make learning and using sign language an enjoyable and accessible experience for everyone.'
                    : 'Maligayang pagdating sa SignBuddy! Ang aming aplikasyon ay idinisenyo upang gawing bukas at madaling gamitin ang Wikang Pansenyas para sa lahat',
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'FiraSans',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                
                buildModuleCard(
                  isEnglish ? 'English and Filipino\nSign Language Lessons' : 'Ingles at Filipino\nAralin sa Wikang Pangsenyas',
                  isEnglish ? 'Unlock the world of sign language with our comprehensive lessons. SignBuddy supports both English and Filipino sign languages, providing a learning experience for users seeking to enhance their communication skills.'
                  : 'Buksan ang mundo ng Wikang Pangsenyas sa pamamagitan ng aming kumprehensibong mga aralin. Sinusuportahan ng SignBuddy ang parehong wika sa pangsenyas sa Ingles at sa Filipino at nagbibigay ng karanasan sa pag-aaral ng Wikang Pangsenyas para sa mga gumagamit na nagnanais palakasin ang kanilang kakayahan at kaalaman sa komunikasyon.',
                  
                  FontAwesomeIcons.book, // Icon for Module 1
                ),

                // Module 2
                buildModuleCard(
                  isEnglish ? 'Sign Alphabet' : 'Alpabeto ng Pangsenyas',
                  isEnglish ? 'Explore the Sign Alphabet module, you can interactively discover sign language gestures by tapping on letters displayed on the screen. Learn the basics of finger movements and gestures that form the foundation of sign language.' 
                  : 'Tuklason ang module ng Alpabeto ng Pangsenyas, maaari kang mag-interaktibo sa pagtuklas ng mga galaw ng wika sa pangsenyas sa pamamagitan ng pag-tap sa mga titik na ipinapakita sa screen. Matuto ng mga batayang galaw ng daliri at mga senyas na bumubuo sa pundasyon ng wika sa pangsenyas.'
                  ,Icons.sign_language,
                ),
                

                // Module 3
                buildModuleCard(
                  isEnglish ? 'Find Sign' : 'Hanapin ang Senyas',
                  isEnglish ? 'Searching for a specific sign? Our "Find Sign" feature lets you easily locate and view video demonstrations of sign language for both Filipino and English. With suggested search functionality, you can quickly find the signs you need, making communication effortless.'
                  : 'Naghahanap ka ba ng tiyak na senyas? Ang aming "Hanapin ang Senyas" feature ay nagbibigay-daan sa iyo na madaling makahanap at mapanood ang video na nagpapakita ng wika sa pangsenyas para sa Filipino at Ingles. Sa tulong ng "suggested search functionality", madaling makahanap ng mga senyas na nais at kailangan mo.',
                  FontAwesomeIcons.magnifyingGlass,
                ),

                // Module 4
                buildModuleCard(
                  isEnglish ? 'Finger Spelling' : 'Pagbaybay sa Daliri',
                  isEnglish ? 'Type out words or phrases, and let SignBuddy transform them into Sign Exact English (SEE). Our Finger Spelling module dynamically displays the corresponding alphabet signs, helping you understand and express a wide range of words and phrases in sign language.'
                  : 'I-type ang mga salita o parirala, at hayaan mong ang SignBuddy i-translate ito sa "Sign Exact English (SEE)". Ang aming module na "Pagbaybay sa Daliri" ay  magpapakita ng mga tugma na senyas ng alpabeto, tumutulong sa iyo na maunawaan at maipahayag ang iba\'t ibang mga salita at parirala sa Wikang Pangsenyas.',
                  FontAwesomeIcons.handFist
                ),

                // Module 5
                buildModuleCard(
                  'Word Fusion',
                  isEnglish ? 'Unleash your creativity with Word Fusion! This unique module allows you to combine phrases and words, generating a carousel of search results presented in video format. Swipe through the results to discover new and expressive ways to communicate using sign language.'
                  : 'Ang module na ito ay nagbibigay-daan sa iyo na pagsamahin ang mga parirala at salita, na lumilikha ng "carousel" ng mga bidyo sa Wikang Pangsenyas. Mag-swipe sa mga resulta upang makadiskubre ng bagong paraan at ekspresyon sa paggamit ng wika sa palakasan para sa komunikasyon',
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
                  fontSize: 17,
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
