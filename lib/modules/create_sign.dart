import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:cached_video_player/cached_video_player.dart';

class CreateSignPage extends StatefulWidget {
  const CreateSignPage({Key? key}) : super(key: key);

  @override
  _CreateSignPageState createState() => _CreateSignPageState();
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

class _CreateSignPageState extends State<CreateSignPage> {
  final AssetFirebaseStorage assetFirebaseStorage = AssetFirebaseStorage();
  List<Map<String, dynamic>> dictionary = [];
  List<CachedVideoPlayerController> videoControllers = [];
  bool isEnglish = true;
  TextEditingController searchController = TextEditingController();
  bool loading = false;
  List<Map<String, dynamic>> searchResults = [];
  String selectedVideoWord = ''; // Store the selected word
  String? errorMessage;

  late FirestoreCollections firestoreCollections;
  



  @override
  void initState() {
    super.initState();
    disposeVideoControllers();
    getLanguage();
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

  Future<void> fetchAssetUrls(String? mp4Path) async {
    final mp4Url = await assetFirebaseStorage.getAsset(mp4Path);

    if (mp4Url != null) {
      final videoController = setupVideoController(Uri.parse(mp4Url));
      if (mounted) {
        setState(() {
          videoControllers.add(videoController);
        });
      }
    }
  }

  CachedVideoPlayerController setupVideoController(Uri videoUri) {
    final controller = CachedVideoPlayerController.network(
      videoUri.toString(),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    controller.initialize().then((_) {
      if (mounted) {
        setState(() {

        });
      }
    });
    return controller;
  }

  Future<void> searchAndDisplayVideo(String searchText) async {
    if (mounted) {
      setState(() {
        disposeVideoControllers();
        searchResults.clear();
        loading = true;
        errorMessage = null; // Clear the error message
      });
    }

    final wordsToSearch = searchText.toLowerCase().split(" ");

    for (var phrase in dictionary) {
      final phraseWords = phrase['content'].toLowerCase().split(" ");
      if (phraseWords.every((word) => wordsToSearch.contains(word))) {
        searchResults.add({
          'mp4': phrase['mp4'],
          'word': phrase['content'],
          'sequence': wordsToSearch.indexOf(phraseWords[0]),
        });
      }
    }

    searchResults.sort((a, b) => a['sequence'].compareTo(b['sequence']));

    for (var result in searchResults) {
      await fetchAssetUrls(result['mp4']);
    }

    if (videoControllers.isNotEmpty) {
      setState(() {
        selectedVideoWord = searchResults[0]['word']; // Set the word of the first video
        loading = false;
      });
    } else {
      setState(() {
        errorMessage = isEnglish
            ? '"$searchText" sign not found'
            : '"$searchText" ay hindi natagpuan';
        loading = false;
      });
    }
  }







Widget _buildVideoCarousel() {
  if (videoControllers.isNotEmpty) {
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Swiper(
            onIndexChanged: (int index) {
              if (searchResults.isNotEmpty && videoControllers[index].value.isInitialized) {
                setState(() {
                  selectedVideoWord = searchResults[index]['word'];
                  videoControllers[index].seekTo(Duration.zero);
                  videoControllers[index].play();
                });
              }
            },
            itemBuilder: (BuildContext context, int index) {
              if (videoControllers[index].value.isInitialized) {
                return GestureDetector(
                  onTap: () {
                    videoControllers[index].seekTo(Duration.zero);
                    videoControllers[index].play();
                  },
                  child: ClipRRect(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                        color: Colors.white,
                      ),
                      height: 190,
                      width: 300,
                      child: CachedVideoPlayer(videoControllers[index]),
                    ),
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(), // Display a loading indicator
                );
              }
            },
            itemCount: videoControllers.length,
            viewportFraction: 0.9,//adjust the width of the video
            scale: 0.9,
            pagination: SwiperPagination(), // Add pagination dots
            loop: false,
          ),
        ),
        SizedBox(height: 5),
        if (searchResults.isNotEmpty)
          Text(
            selectedVideoWord,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
      ],
    );
  } else if (loading) {
    return Center(
      child: CircularProgressIndicator(), // Display a loading indicator
    );
  } else {
    return Container();
  }
}

  void disposeVideoControllers() {
    for (var controller in videoControllers) {
      controller.dispose();
    }
    videoControllers.clear();
  }
  
  void clearSearch() {
    if(mounted) {
      setState(() {
      searchController.clear();
      disposeVideoControllers();
      selectedVideoWord = '';
      errorMessage = null;
      });
    }
  }



  @override
  void dispose() {
    searchController.dispose();
    disposeVideoControllers();
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
              image: AssetImage('assets/bg-signbuddy.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          children: [
            AppBar(
              backgroundColor: const Color(0xFF5A96E3),
              title: Text(
                'Word Fusion',
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
                  children: [
                    TextField(
                      controller: searchController,
                      onTap: clearSearch,
                      decoration: InputDecoration(
                        hintText: isEnglish ? 'Search for words or phrases' : 'Hanapin ang mga salita o parirala.',
                        prefixIcon: const Icon(
                          Icons.create,
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
                    Visibility(
                      visible: videoControllers.isEmpty, // Show the button when there are no videos
                      child: ElevatedButton(
                        onPressed: () {
                          searchAndDisplayVideo(searchController.text);
                          FocusScope.of(context).unfocus();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF5BD8FF),
                        ),
                        child: Text(isEnglish ? "Search Sign" : "Hanapin ang Sign",
                            style: TextStyle(color: Color(0xFF5A5A5A), fontFamily: 'FiraSans')),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Visibility(
                            visible: videoControllers.isEmpty && errorMessage == null,
                            child: Image.asset(
                              'assets/dictionary/sign_hello.png',
                              width: 100,
                              height: 100,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildVideoCarousel(),
                              if (errorMessage != null)
                                Text(
                                  errorMessage!,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                            ],
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
  );
}

}