import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:cached_video_player/cached_video_player.dart'; // Import CachedVideoPlayer
import 'package:sign_buddy/analytics.dart';

class FindSign extends StatefulWidget {

  
  const FindSign({Key? key}) : super(key: key);

  @override
  _FindSignState createState() => _FindSignState();
}
class FirestoreCollections {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String wordsCollectionPath;
  late String phrasesCollectionPath;

  FirestoreCollections({required bool isEnglish}) {
    if (isEnglish) {
      wordsCollectionPath = 'dictionary/en/words';
      phrasesCollectionPath = 'dictionary/en/phrases';
    } else {
      wordsCollectionPath = 'dictionary/ph/words';
      phrasesCollectionPath = 'dictionary/ph/phrases';
    }
  }

  CollectionReference get wordsCollection =>
      _firestore.collection(wordsCollectionPath);

  CollectionReference get phrasesCollection =>
      _firestore.collection(phrasesCollectionPath);
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
  String? mp4Url;
  bool isEnglish = true;
  bool isSlowMotion = false;


  CachedVideoPlayerController? _videoController;
  late FirestoreCollections firestoreCollections;
  
  final AnalyticsService analyticsService = AnalyticsService();

  @override
  void initState() {
    
    getLanguage();
    super.initState();
  }

  

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    final firestoreCollections = FirestoreCollections(isEnglish: isEnglish);

    setState(() {
      this.firestoreCollections = firestoreCollections;
      this.isEnglish = isEnglish;
    });

    loadDictionaryData();
  }
  
  Future<void> loadDictionaryData() async {
    final wordData = await firestoreCollections.wordsCollection.get();
    final phraseData = await firestoreCollections.phrasesCollection.get();
    final loadedDictionary = combineData(wordData, phraseData);

    if (mounted) {
      setState(() {
        dictionary = loadedDictionary;
      });
    }
  }

  List<Map<String, dynamic>> combineData(
      QuerySnapshot wordData, QuerySnapshot phraseData) {
    final List<Map<String, dynamic>> combinedData = [];

    for (var doc in wordData.docs) {
      combinedData.add({
        "content": doc['content'],
        "type": "word",
        "category": doc['category'],
        "mp4": doc['mp4'],
      });
    }

    for (var doc in phraseData.docs) {
      combinedData.add({
        "content": doc['content'],
        "type": "phrases",
        "category": doc['category'],
        "mp4": doc['mp4'],
      });
    }

    return combinedData;
  }


  // function that hanlde the search functionality of find sign,
  // display the suggested result base on the existing firebase assets
  void search(String query) {
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          searchResults = [];
          suggestedResults.clear();
          termNotFound = false;
          isSearching = false;
        });
      }
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
        if (_videoController != null) {
          _videoController!.pause();
          _videoController!.dispose();
          _videoController = null;
        }
        mp4Url = null;
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
        if (_videoController != null) {
          _videoController!.pause();
          _videoController!.dispose();
          _videoController = null;
        }

        fetchAssetUrls(searchResults[0]['mp4']);
      });
    }
  }


  //function that fetch the URL from firebase storage
  Future<void> fetchAssetUrls(String? mp4Path) async {

    mp4Url = await assetFirebaseStorage.getAsset(mp4Path);

    if (mp4Url != null) {
      _videoController = setupVideoController(Uri.parse(mp4Url!));
      if (mounted) {
        setState(() {});
      }
    }
    _videoController!.play();
  }

  CachedVideoPlayerController setupVideoController(Uri videoUri) {
    final controller = CachedVideoPlayerController.network(
      videoUri.toString(),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
    return controller;
  }

  @override
  void dispose() {
    searchController.dispose();
    _videoController?.dispose();
    super.dispose();
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
        Column(
          children: [
            AppBar(
              backgroundColor: const Color(0xFF5A96E3),
              title: Text(
                'Find Sign',
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: (text) {
                        analyticsService.incrementInteractions(isEnglish ? "en" : "ph", "findInteract");
                        search(text);
                      },
                    decoration: InputDecoration(
                      hintText: isEnglish
                          ? 'Search something....'
                          : 'Maghanap ng kahit ano.....',
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
                              onPressed: () {
                                clearSearch();
                                analyticsService.incrementInteractions(isEnglish ? "en" : "ph", "findInteract");
                                
                              },
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
                            onTap: () {
                              selectSuggestedResult(result);
                              FocusScope.of(context).unfocus();
                              analyticsService.incrementInteractions(isEnglish ? "en" : "ph", "findInteract");
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 60),
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
                        if (searchResults[0]['type'] == 'word' ||
                            searchResults[0]['type'] == 'phrases')
                          _buildVideoPlayer(190, 300),
                        Text(
                          searchResults[0]['content'],
                          style: const TextStyle(
                            fontSize: 18,
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
                          isEnglish
                              ? 'was not found'
                              : 'ay hindi matagpuan',
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget _buildVideoPlayer(double height, double width) {
    return GestureDetector(
      onTap: () {
        if (_videoController != null) {
          analyticsService.incrementInteractions(isEnglish ? "en" : "ph", "findInteract");
          _videoController!.seekTo(Duration.zero);
          _videoController!.play();
          
        }
      },
      child: Column(
        children: [
          _videoController != null
              ? Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 2,
                  ),
                  color: Colors.white,
                ),
                height: height,
                width: width,
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: CachedVideoPlayer(_videoController!),
                ),
              )
              : Container(
                  // Loading indicator
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
          if (_videoController != null)
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (isSlowMotion) {
                        // If slow-motion is enabled, reset to normal speed
                        analyticsService.incrementInteractions(isEnglish ? "en" : "ph", "findInteract");
                        _videoController!.setPlaybackSpeed(1.0);
                        _videoController!.play();
                        
                      } else {
                        // If not in slow-motion, enable slow-motion
                        analyticsService.incrementInteractions(isEnglish ? "en" : "ph", "findInteract");
                        _videoController!.setPlaybackSpeed(0.5);
                        _videoController!.play();
                        
                      }
                      setState(() {
                        // Toggle the slow-motion state
                        isSlowMotion = !isSlowMotion;
                      });
                    },
                    child: ImageIcon(
                      AssetImage(
                        isSlowMotion
                            ? 'assets/rabbit.png'
                            : 'assets/turtle.png',
                      ),
                      size: 40, // Adjust the size as needed
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
