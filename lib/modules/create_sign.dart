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
    disposeVideoControllers();
    getLanguage();
  }

  Future<void> loadDictionaryData() async {
    final wordData = await wordsCollection.get();
    final phraseData = await phrasesCollection.get();
    final loadedDictionary = combineData(wordData, phraseData);

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
    if(mounted) {
      setState(() {
        disposeVideoControllers();
        searchResults.clear();
        loading = true;
        errorMessage = null; // Clear the error message
      });
    }
    
    
    final wordsToSearch = searchText.split(" ");
    
    for (var word in wordsToSearch) {
      for (var item in dictionary) {
        if (item['content'].toLowerCase() == word.toLowerCase()) {
          searchResults.add({
            'mp4': item['mp4'],
            'word': item['content'],
          });
          break;
        }
      }
    }

    for (var result in searchResults) {
      await fetchAssetUrls(result['mp4']);
    }

     if (videoControllers.isNotEmpty) {
      setState(() {
        selectedVideoWord = searchResults[0]['word']; // Set the word of the first video
        loading = false; 
      });
      }else {
      setState(() {
        errorMessage = '"$searchText" sign not found';
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
              if (searchResults.isNotEmpty) {
                setState(() {
                  selectedVideoWord = searchResults[index]['word'];
                });
              }
            },
            itemBuilder: (BuildContext context, int index) {
              if (videoControllers[index].value.isInitialized) {
                videoControllers[index].seekTo(Duration.zero);
                videoControllers[index].play();
                return ClipRRect(
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
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(), // Display a loading indicator
                );
              }
            },
            itemCount: videoControllers.length,
            viewportFraction: 0.8,
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
      appBar: AppBar(
        title: Text(
          'Word Fusion',
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
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                 onTap: clearSearch,
                decoration: InputDecoration(
                  hintText: 'Search for words or phrases',
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
                child: Text("Search Sign",
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
  );
}
}