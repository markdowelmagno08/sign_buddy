import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import services.dart


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
    // Add ASL signs for other letters here
  };

  String inputText = '';
  List<Widget> groupASL = [];
  bool showLetters = false;
  bool hasSignImages = false; // Track if there are sign images
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

  void translateTextToASL() {
    groupASL.clear();
    hasSignImages = false; // Reset the flag
    final words = inputText.split(RegExp(r'\s+'));
    for (var word in words) {
      List<Widget> wordSign = [];
      for (int i = 0; i < word.length; i++) {
        String letter = word[i].toLowerCase();
        if (aslSigns.containsKey(letter)) {
          hasSignImages = true; // Set the flag if there are sign images
          if (wordSign.isNotEmpty) {
            wordSign.add(SizedBox(width: 10)); // Add space between sign images
          }
          wordSign.add(
            Container(
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
                      height: 100,
                      width: 100,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Finger Spell',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontFamily: 'FiraSans',
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg-signbuddy.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              TextField(
                onChanged: (text) {
                  inputText = text;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')), // Allow only letters and spaces
                ],
                decoration: InputDecoration(
                  labelText: isEnglish ? 'Enter text to translate' : 'Maglagay ng text na isasalin',
                  labelStyle: TextStyle(
                    color: Color(0xFF5A5A5A), // Change the label (hint) text color
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: translateTextToASL,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5BD8FF),
                ),
                child: Text(isEnglish ? 'Translate to Sign Language' : 'Isalin sa Wikang Pasensyas',
                    style: TextStyle(color: Color(0xFF5A5A5A), fontFamily: 'FiraSans')),
              ),
              SizedBox(height: 50),
              // Check if there are sign images before showing the button
              Align(
                alignment: Alignment.centerRight, // Align the button to the right
                child: TextButton(
                  onPressed: hasSignImages ? toggleLetterVisibility : null,
                  child: Text(
                    hasSignImages ? (showLetters ? 'Hide letters' : 'Show letters') : '',
                    style: TextStyle(color: Color(0xFF5A5A5A), fontFamily: 'FiraSans', fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: groupASL,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
