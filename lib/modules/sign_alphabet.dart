import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

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
  String selectedLetter = '';
  bool isEnglish = true;

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
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/bg-signbuddy.png',
                ), // Replace with your background image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppBar(
                backgroundColor: const Color(0xFF5A96E3),
                title: Text(
                  isEnglish ? 'Sign Alphabet' : "Wikang Pasenyas",
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
              Container(
                padding: const EdgeInsets.fromLTRB(25, 50, 20, 20),
                child: Text(
                  isEnglish ? 'Sign Alphabet' : 'Alpabeto sa Senyas',
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
                            color: Colors.white,
                          ),
                          child: Image.asset(
                            'assets/${letterImages[selectedLetter]}.png',
                            width: 200,
                            height: 200,
                          ),
                        )
                      : Text(
                          isEnglish
                              ? 'Tap a letter to see the sign language image'
                              : 'I-tap ang titik para makita ang senyas',
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
        ],
      ),
    );
  }

}