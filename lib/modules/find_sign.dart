import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/firebase_storage.dart';


class FindSign extends StatefulWidget {
  const FindSign({Key? key}) : super(key: key);

  @override
  _FindSignState createState() => _FindSignState();
}

class _FindSignState extends State<FindSign> {
  final AssetFirebaseStorage assetFirebaseStorage = AssetFirebaseStorage();
  List<Map<String, dynamic>> dictionary = [];
  List<String> suggestedResults = [];
  List<Map<String, dynamic>> searchResults = [];
  bool termNotFound = false;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  bool isSuggestionTapped = false;
  String query = '';
  String? imageUrl;
  String? gifUrl;
  bool isEnglish = true;

  

  // Firestore Collections
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

 // Load dictionary data from Firestore
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

    setState(() {
      this.isEnglish = isEnglish;
    });
  }


  // Combine data from different Firestore collections into a single dictionary
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

  void search(String query) {
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          searchResults = [];
          suggestedResults.clear();
          termNotFound = false;
          isSearching = false;
        });
    }} else {
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

       if (mounted) {
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
  }

  void clearSearch() {
    if (mounted) {
      setState(() {
        searchController.clear();
        suggestedResults.clear();
        termNotFound = false;
        isSearching = false;
        isSuggestionTapped = false;
      });
    }
  }

  Future<void> selectSuggestedResult(String result) async {
  if (mounted) {  
    setState(() {
      isSuggestionTapped = true;
      query = result;
      searchController.text = result;
      searchResults =
          dictionary.where((entry) => entry['content'] == result).toList();
      suggestedResults.clear();
      // Fetch image and gif URLs using AssetFirebaseStorage
      fetchAssetUrls(searchResults[0]['image'], searchResults[0]['gif']);
    });
    }
  }

  Future<void> fetchAssetUrls(String? imagePath, String? gifPath) async {
    imageUrl = await assetFirebaseStorage.getAsset(imagePath);
    gifUrl = await assetFirebaseStorage.getAsset(gifPath);
    setState(() {
      // Once the URLs are fetched, trigger a rebuild of the widget.
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
      backgroundColor: const Color(0xFF5A96E3),
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Hello!' :"Kamusta!",
            style: TextStyle(
              color:  Colors.white,
              fontSize: 15,
              fontFamily: 'FiraSans',
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/bg-signbuddy.png'), // Replace with your background image path
            fit: BoxFit.cover,
          ),
        ),
      child: Column(
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
                    hintText: isEnglish? 'Search something....': 'Maghanap ng kahit ano.....',
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
                                left: 60),
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
                    if (searchResults[0]['type'] == 'letter')
                      _buildImageContainer(imageUrl),
                    if (searchResults[0]['type'] == 'word' || searchResults[0]['type'] == 'phrases')
                      _buildImageContainer(gifUrl),
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
                       Text(
                        isEnglish ? 'was not found': 'ay hindi matagpuan',
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
    ),
    );
  }
}

Widget _buildImageContainer(String? url) {
  return url != null
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
            child: Image.network(
              url,
              height: 190,
              width: 300,
            ),
          ),
        )
      : Container(
          // Loading indicator
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        );
}
