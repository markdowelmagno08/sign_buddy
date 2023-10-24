import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/firebase_storage.dart';

class CreateSignPage extends StatefulWidget {
  const CreateSignPage({Key? key}) : super(key: key);

  @override
  _CreateSignPageState createState() => _CreateSignPageState();
}

class _CreateSignPageState extends State<CreateSignPage> {
  final AssetFirebaseStorage assetFirebaseStorage = AssetFirebaseStorage();
  List<Map<String, dynamic>> dictionary = [];
  TextEditingController searchController = TextEditingController();
  String? imageUrl;
  String? gifUrl;
  bool isEnglish = true;
  String? content;
  int searchIndex = 0;
  String? errorMessage;
  bool loading = false; // Add a loading indicator

  final CollectionReference lettersCollection =
      FirebaseFirestore.instance.collection('dictionary/en/letters');
  final CollectionReference wordsCollection =
      FirebaseFirestore.instance.collection('dictionary/en/words');
  final CollectionReference phrasesCollection =
      FirebaseFirestore.instance.collection('dictionary/en/phrases');

  @override
  void initState() {
    super.initState();
    loadDictionaryData();
    getLanguage();
  }

  Future<void> loadDictionaryData() async {
    final letterData = await lettersCollection.get();
    final wordData = await wordsCollection.get();
    final phraseData = await phrasesCollection.get();

    final loadedDictionary = combineData(letterData, wordData, phraseData);

    if (mounted) {
      setState(() {
        dictionary = loadedDictionary;
      });
    }
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    if (mounted) {
      setState(() {
        this.isEnglish = isEnglish;
      });
    }
  }

  List<Map<String, dynamic>> combineData(
      QuerySnapshot letterData, QuerySnapshot wordData, QuerySnapshot phraseData) {
    final List<Map<String, dynamic>> combinedData = [];

    for (var doc in letterData.docs) {
      combinedData.add({
        "content": doc['content'],
        "type": "letter",
        "image": doc['image'],
      });
    }

    for (var doc in wordData.docs) {
      combinedData.add({
        "content": doc['content'],
        "type": "word",
        "category": doc['category'],
        "gif": doc['gif'],
      });
    }

    for (var doc in phraseData.docs) {
      combinedData.add({
        "content": doc['content'],
        "type": "phrases",
        "category": doc['category'],
        "gif": doc['gif'],
      });
    }

    return combinedData;
  }

  Future<void> fetchAssetUrls(String? imagePath, String? gifPath) async {
    imageUrl = await assetFirebaseStorage.getAsset(imagePath);
    gifUrl = await assetFirebaseStorage.getAsset(gifPath);
    setState(() {
      // Once the URLs are fetched, trigger a rebuild of the widget.
    });
  }

  Future<void> searchDictionary(String query) async {
    String? errorMessage;
    final searchTerms = query.toLowerCase().split(" ");
    List<String?> imageUrls = [];
    List<String?> gifUrls = [];
    String currentSearchTerm = "";

    for (final term in searchTerms) {
      if (currentSearchTerm.isNotEmpty) {
        currentSearchTerm += " ";
      }
      currentSearchTerm += term;

      final results = dictionary.where((entry) {
        return entry['content'].toLowerCase() == currentSearchTerm;
      }).toList();

      if (results.isNotEmpty) {
        final firstResult = results.first;
        final imagePath = firstResult['image'];
        final gifPath = firstResult['gif'];

        if (mounted) {
          setState(() {
            loading = true; // Show loading indicator when fetching image/gif
          });
        }

        await fetchAssetUrls(imagePath, gifPath);

        if (content == null) {
          content = firstResult['content'];
        }
        errorMessage = null;

        if (mounted) {
          setState(() {
            content = firstResult['content'];
            errorMessage = null;
            loading = false; // Hide loading indicator when fetch is complete
          });
        }

        await Future.delayed(Duration(seconds: 3));
        currentSearchTerm = "";
      } else {
        imageUrl = null;
        gifUrl = null;
        content = null;
        errorMessage = 'Could not find "$currentSearchTerm" ';
        if (mounted) {
          setState(() {
            loading = false; // Hide loading indicator when fetch is complete
          });
        }
      }

      imageUrls.add(imageUrl);
      gifUrls.add(gifUrl);
    }

    
    if (mounted) {
      setState(() {
        this.errorMessage = errorMessage;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Sign',
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: isEnglish ? 'Translate something....' : 'Maghanap ng kahit ano.....',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.deepPurpleAccent,
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                searchIndex = 0;
                errorMessage = null;

                final searchText = searchController.text.trim();
                if (searchText.isNotEmpty) searchDictionary(searchText);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5BD8FF),
              ),
              child: Text("Translate to Sign", style: TextStyle(color: Color(0xFF5A5A5A), fontFamily: 'FiraSans')),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  _imageDisplay(), // Call the _imageDisplay method
                  if (content != null)
                    Text(
                      content!,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to display the image
  Widget _imageDisplay() {
    return loading
        ? CircularProgressIndicator() // Show loading indicator
        : imageUrl != null || gifUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
                      if (imageUrl != null)
                        Image.network(
                          imageUrl!,
                          width: 300,
                          height: 190,
                        ),
                      if (gifUrl != null)
                        Image.network(
                          gifUrl!,
                          width: 300,
                          height: 190,
                        ),
                    ],
                  ),
                ),
              )
            : SizedBox(); // Placeholder when no image or gif to display
          }
}
