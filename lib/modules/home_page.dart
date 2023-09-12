import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/sign_up.dart';

import 'dart:convert';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LessonsScreen(),
    const AlphabetScreen(),
    const DictionaryScreen(),
    const StudyScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return false to indicate that you don't want to pop the route
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: const Color(0xFF5A96E3),
          title: const Text(
            'Welcome to Sign Buddy!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'FiraSans',
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.feedback),
              onPressed: () {
                // Implement search functionality here
              },
            ),
          ],
        ),
    
        drawer: Drawer(
          child: Column(
            children: [
              SizedBox(
                height: 250,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF5A96E3),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(
                              5.0), // do adjust the margin of avatar and Text "Juan Dela Cruz"
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2.0,
                                  ),
                                ),
                                child: const CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage(
                                      'assets/user_man.png'), // Replace with your avatar image path
                                ),
                              ),
                              const SizedBox(height: 10),
                              buildUserData() // class for fetching user
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            _scaffoldKey.currentState?.openEndDrawer();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  // Handle profile tap
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notification'),
                onTap: () {
                  // Handle notification tap
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('FAQ'),
                onTap: () {
                  // Handle FAQ tap
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                onTap: () {
                  // Handle about tap
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Logout'),
                onTap: () async {
                  bool confirmLogout = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: const Text('Are you sure you want to logout?',
                          style: TextStyle(
                            fontFamily: 'FiraSans',
                            fontWeight: FontWeight.w300,
                          )),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('CANCEL',
                              style: TextStyle(
                                color: Colors.black,
                              )),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('LOGOUT',
                              style: TextStyle(
                                color: Colors.red,
                              )),
                        ),
                      ],
                    ),
                  );
    
                  if (confirmLogout == true) {
                    await FirebaseAuth.instance.signOut();
                    // ignore: use_build_context_synchronously
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  }
                },
              ),
            ],
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
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
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
              icon: Icon(Icons.school),
              label: 'Study',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        // floatingActionButton: _currentIndex == 0
        //     ? FloatingActionButton.extended(
        //         onPressed: () {
    
        //         },
        //         icon: const Icon(Icons.play_arrow),
        //         label: const Text('Start'),
        //         backgroundColor: Colors.deepPurpleAccent[700],
        //       )
        //     : null,
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
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
            const Text(
              'Save progress, make a profile!',
              style: TextStyle(
                  color: Colors.white, fontSize: 11, fontFamily: 'FiraSans'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              // Wrap the buttons in a Row
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                    width: 20), // Add some spacing between the buttons
                ElevatedButton(
                  onPressed: () {
                    // Navigate to sign up page
                    Navigator.push(
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

      return Text(
        '${capitalizeFirstLetter(firstName)} ${capitalizeFirstLetter(lastName)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontFamily: 'FiraSans',
        ),
      );
    },
  );
}

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({Key? key}) : super(key: key);

  @override
  _LessonsScreenState createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  int? selectedLessonIndex;

  final List<Map<String, dynamic>> lessons = [
    {'lessonName': 'Alphabet', 'icon': 'lesson-icon/img1.png'},
    {'lessonName': 'Numbers', 'icon': 'lesson-icon/img2.png'},
    {'lessonName': 'Family', 'icon': 'lesson-icon/img3.png'},
    {'lessonName': 'Greetings', 'icon': 'lesson-icon/img10.png'},
    // {'lessonName': 'Colors', 'icon': 'lesson-icon/img4.png'},
    // {'lessonName': 'Shapes', 'icon': 'lesson-icon/img5.png'},
    {'lessonName': 'Animals', 'icon': 'lesson-icon/img6.png'},
    // {'lessonName': 'Nature', 'icon': 'lesson-icon/img7.png'},
    // {'lessonName': 'Foods and Drinks', 'icon': 'lesson-icon/img8.png'},
    {'lessonName': 'Time and Days', 'icon': 'lesson-icon/img9.png'},
  ];

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
            Container(
              padding: const EdgeInsets.fromLTRB(41, 20, 20, 20),
              child: const Text(
                'Lessons',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                        _navigateToStartLesson(context, lesson['lessonName']);
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
                            lesson['lessonName'],
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
  switch (lesson) {
    case 'Alphabet':
      Navigator.pushNamed(context, '/basic');
      break;
    case 'Numbers':
      Navigator.pushNamed(context, '/numbers');
      break;
    case 'Family':
      Navigator.pushNamed(context, '/family');
      break;
    case 'Colors':
      Navigator.pushNamed(context, '/colors');
      break;
    case 'Shapes':
      Navigator.pushNamed(context, '/shapes');
      break;
    case 'Animals':
      Navigator.pushNamed(context, '/animals');
      break;
    case 'Nature':
      Navigator.pushNamed(context, '/nature');
      break;
    case 'Foods and Drinks':
      Navigator.pushNamed(context, '/food');
      break;
    case 'Time and Days':
      Navigator.pushNamed(context, '/timeAndDays');
      break;
    case 'Greetings':
      Navigator.pushNamed(context, '/greeting');
      break;
    // Add more cases for other lessons...

    default:
      // Handle the case when the lesson is not found
      break;
  }
}

class AlphabetScreen extends StatefulWidget {
  const AlphabetScreen({super.key});

  @override
  _AlphabetScreenState createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen> {
  final letterImages = {
    'A': 'alphabet/a',
    'B': 'alphabet/b',
    'C': 'alphabet/c',
    'D': 'alphabet/d',
    'E': 'alphabet/e',
    'F': 'alphabet/f',
    'G': 'alphabet/g',
    'H': 'alphabet/h',
    'I': 'alphabet/i',
    'J': 'alphabet/j',
    'K': 'alphabet/k',
    'L': 'alphabet/l',
    'M': 'alphabet/m',
    'N': 'alphabet/n',
    'O': 'alphabet/o',
    'P': 'alphabet/p',
    'Q': 'alphabet/q',
    'R': 'alphabet/r',
    'S': 'alphabet/s',
    'T': 'alphabet/t',
    'U': 'alphabet/u',
    'V': 'alphabet/v',
    'W': 'alphabet/w',
    'X': 'alphabet/x',
    'Y': 'alphabet/y',
    'Z': 'alphabet/z',
  };

  String selectedLetter = '';

  @override
  Widget build(BuildContext context) {
    final letters = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z'
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(25, 50, 20, 20),
            child: const Text(
              'Sign Language Alphabet',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Set the text color of the title
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: selectedLetter.isNotEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(
                        'assets/${letterImages[selectedLetter]}.png',
                        width: 200,
                        height: 200,
                      ),
                    )
                  : const Text(
                      'Tap a letter to see the sign language image',
                      style: TextStyle(fontSize: 15.0),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              padding: const EdgeInsets.all(10),
              children: List.generate(26, (index) {
                final letter = letters[index];
                final isSelected = selectedLetter == letter;
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[300] : Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (isSelected) {
                          selectedLetter = '';
                        } else {
                          selectedLetter = letter;
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 20,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({Key? key}) : super(key: key);

  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  List<Map<String, dynamic>> dictionary = [];
  List<String> suggestedResults = [];
  List<Map<String, dynamic>> searchResults = [];
  bool termNotFound = false;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  bool isSuggestionTapped = false;
  String query = '';

  @override
  void initState() {
    super.initState();
    loadDictionaryData();
  }

  Future<void> loadDictionaryData() async {
    final loadedDictionary = await loadDictionary();
    setState(() {
      dictionary = loadedDictionary;
    });
  }

  Future<List<Map<String, dynamic>>> loadDictionary() async {
    final dictionaryJson =
        await rootBundle.loadString('assets/dictionary.json');
    return List<Map<String, dynamic>>.from(json.decode(dictionaryJson));
  }

  void search(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        suggestedResults.clear();
        termNotFound = false;
        isSearching = false;
      });
    } else {
      final results = dictionary.where((entry) {
        final content = entry['content'] ?? '';
        return content.toLowerCase().contains(query.toLowerCase());
      }).toList();

      final suggested = dictionary
          .where((entry) {
            final content = entry['content'] ?? '';
            return content.toLowerCase().startsWith(query.toLowerCase()) ||
                (query.length >= 2 &&
                    content.toLowerCase().contains(query.toLowerCase()));
          })
          .map((entry) => entry['content'] as String)
          .toList();

      setState(() {
        this.query = query;
        searchResults = results;
        termNotFound = results.isEmpty && suggested.isEmpty;
        isSearching = true;
        suggestedResults = suggested;
        isSuggestionTapped = false;
      });
    }
  }

  void selectSuggestedResult(String result) {
    setState(() {
      isSuggestionTapped = true;
      query = result;
      searchController.text = result;
      searchResults =
          dictionary.where((entry) => entry['content'] == result).toList();
      suggestedResults.clear(); // Clear suggested results here
    });
  }

  void selectSuggestion(String suggestion) {
    setState(() {
      query = suggestion;
      searchController.text = suggestion;
      isSuggestionTapped = true;
    });
    search(suggestion);
  }

  void clearSearch() {
    setState(() {
      searchController.clear();
      suggestedResults.clear();
      termNotFound = false;
      isSearching = false;
      isSuggestionTapped = false; // Reset suggestion tapped status
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                TextField(
                  controller: searchController,
                  onChanged: search,
                  decoration: InputDecoration(
                    hintText: 'Search something....',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.deepPurpleAccent,
                    ),
                    suffixIcon: isSearching
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.redAccent,
                            ),
                            onPressed: clearSearch,
                          )
                        : null,
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (suggestedResults.isNotEmpty)
                  Expanded(
                    child: ListView(
                      children: suggestedResults.map((result) {
                        return GestureDetector(
                          onTap: () => selectSuggestedResult(result),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 60), // Adjust the value as needed
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              child: Text(
                                result,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                if (isSuggestionTapped && searchResults.isNotEmpty)
                  Column(
                    children: [
                      searchResults[0]['type'] == 'letter'
                          ? Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                child: Image.asset(
                                  searchResults[0]['image'],
                                  height: 200,
                                  width: 200,
                                ),
                              ),
                            )
                          : searchResults[0]['type'] == 'word' ||
                                  searchResults[0]['type'] == 'phrases'
                              ? Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: ClipRRect(
                                    child: Image.asset(
                                      searchResults[0]['gif'],
                                      height: 190,
                                      width: 300,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                      const SizedBox(height: 10),
                      Text(
                        searchResults[0]['content'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                Visibility(
                  visible: !isSearching,
                  child: Image.asset(
                    'assets/dictionary/search.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                if (termNotFound && !isSuggestionTapped)
                  Column(
                    children: [
                      Text(
                        '"$query"',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'was not found',
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StudyScreen extends StatelessWidget {
  const StudyScreen({Key? key}) : super(key: key);

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
        child: const Center(
          child: Text(
            'Study Screen',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
        child: const Center(
          child: Text(
            'Settings Screen',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
