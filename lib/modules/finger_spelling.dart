import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:sign_buddy/analytics.dart';

class FingerSpelling extends StatefulWidget {
  const FingerSpelling({Key? key}) : super(key: key);

  @override
  _FingerSpellingState createState() => _FingerSpellingState();
}

class _FingerSpellingState extends State<FingerSpelling> {
  final Map<String, String> aslSigns = {
    'a': 'assets/alphabet/a.png',
    'b': 'assets/alphabet/b.png',
    'c': 'assets/alphabet/c.png',
    'd': 'assets/alphabet/d.png',
    'e': 'assets/alphabet/e.png',
    'f': 'assets/alphabet/f.png',
    'g': 'assets/alphabet/g.png',
    'h': 'assets/alphabet/h.png',
    'i': 'assets/alphabet/i.png',
    'j': 'assets/alphabet/j.png',
    'k': 'assets/alphabet/k.png',
    'l': 'assets/alphabet/l.png',
    'm': 'assets/alphabet/m.png',
    'n': 'assets/alphabet/n.png',
    'o': 'assets/alphabet/o.png',
    'p': 'assets/alphabet/p.png',
    'q': 'assets/alphabet/q.png',
    'r': 'assets/alphabet/r.png',
    's': 'assets/alphabet/s.png',
    't': 'assets/alphabet/t.png',
    'u': 'assets/alphabet/u.png',
    'v': 'assets/alphabet/v.png',
    'w': 'assets/alphabet/w.png',
    'x': 'assets/alphabet/x.png',
    'y': 'assets/alphabet/y.png',
    'z': 'assets/alphabet/z.png',
  };

  String inputText = '';
  List<Widget> groupASL = [];
  bool showLetters = false;
  bool hasSignImages = false; // Track if there are sign images
  bool isEnglish = true;
  final AnalyticsService analyticsService = AnalyticsService();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    
    getLanguage();
    super.initState();
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    setState(() {
      this.isEnglish = isEnglish;
    });
  }

  void translateTextToASL() {
    FocusScope.of(context).unfocus(); 
    groupASL.clear();
    hasSignImages = false; // Reset the flag
    final words = inputText.split(RegExp(r'\s+'));
    for (var word in words) {
      List<Widget> wordSign = [];
      for (int i = 0; i < word.length; i++) {
        String letter = word[i].toLowerCase();
        if (aslSigns.containsKey(letter)) {
          hasSignImages = true; 
          if (wordSign.isNotEmpty) {
            wordSign.add(SizedBox(width: 10)); 
          }
          wordSign.add(
            GestureDetector(
              onTap: ()  {
                analyticsService.incrementInteractions( isEnglish ? "en" : "ph", "spellInteract");
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      contentPadding: EdgeInsets.all(
                          5), 
                      content: ClipRRect(
                      child: Image.asset(
                        aslSigns[letter]!,
                        height: 250,
                        width: 250,
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      child: Image.asset(
                        aslSigns[letter]!,
                        height: 110,
                        width: 110,
                      ),
                    ),
                    if (showLetters)
                      Text(
                        letter,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }
      }
      groupASL.add(
        Column(
          children: [
            Text(
              word,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      );
      groupASL.add(Row(
        children: wordSign,
      ));
      groupASL.add(SizedBox(height: 30));
    }
    setState(() {});
  }

  void toggleLetterVisibility() {
    
    setState(() {
      showLetters = !showLetters;
    });
    translateTextToASL();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollNotification) {
        // Check if the user is scrolling
        if (scrollNotification is ScrollUpdateNotification) {
          // Increment interactions when scrolling occurs
          analyticsService.incrementInteractions(isEnglish ? "en" : "ph", "spellInteract");
        }
        return false; 
      },
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg-signbuddy2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: const Color(0xFF5A96E3),
                title: Text(
                  'Finger Spell',
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      TextField(
                        onChanged: (text) {
                          setState(() {
                            analyticsService.incrementInteractions( isEnglish ? "en" : "ph", "spellInteract");
                            inputText = text;
                            if (text.isNotEmpty) {
                              hasSignImages = false;
                              groupASL.clear();
                            }
                          });
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                        ],
                        decoration: InputDecoration(
                          labelText: isEnglish ? 'Enter text to translate' : 'Maglagay ng text na isasalin',
                          labelStyle: TextStyle(
                            color: Color(0xFF5A5A5A),
                          ),
                          prefixIcon: const Icon(
                            Icons.translate,
                            color: Colors.deepPurpleAccent,
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                        ),
                        maxLength: 50,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          translateTextToASL();
                          analyticsService.incrementInteractions( isEnglish ? "en" : "ph", "spellInteract");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF5BD8FF),
                        ),
                        child: Text(
                          isEnglish ? 'Translate to Sign' : 'Isalin sa Wikang Pasensyas',
                          style: TextStyle(color: Color(0xFF5A5A5A), fontFamily: 'FiraSans'),
                        ),
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: hasSignImages ? () {
                            // Toggle letter visibility
                            toggleLetterVisibility();

                            // Increment interactions based on language and field
                            analyticsService.incrementInteractions(isEnglish ? "en" : "ph", "spellInteract");
                          } : null,
                          child: Text(
                            hasSignImages ? (showLetters ? 'Hide letters' : 'Show letters') : '',
                            style: TextStyle(color: Color(0xFF5A5A5A), fontFamily: 'FiraSans', fontSize: 12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: groupASL,
                              ),
                            ),
                            Visibility(
                              visible: !hasSignImages,
                              child: Container(
                                width: 330, // Set width to full width
                                child: Center(
                                  child: Image.asset(
                                    'assets/dictionary/sign_s.png',
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

}