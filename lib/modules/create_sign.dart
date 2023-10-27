import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:cached_video_player/cached_video_player.dart'; // Import CachedVideoPlayer

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
  String? mp4Url;
  CachedVideoPlayerController? _videoController; // Use CachedVideoPlayerController
  bool isEnglish = true;
  String? content;
  int searchIndex = 0;
  String? errorMessage;
  bool loading = false; // Add a loading indicator
    bool isSlowMotion = false;

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
        "mp4": doc['mp4'], // Updated to use "mp4"
      });
    }

    for (var doc in phraseData.docs) {
      combinedData.add({
        "content": doc['content'],
        "type": "phrases",
        "category": doc['category'],
        "mp4": doc['mp4'], // Updated to use "mp4"
      });
    }

    return combinedData;
  }

  Future<void> fetchAssetUrls(String? imagePath, String? mp4Path) async {
    imageUrl = await assetFirebaseStorage.getAsset(imagePath);
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

  Future<void> loadAndDisplayVideo(String searchText) async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    Map<String, dynamic>? searchResult;
    try {
      searchResult = dictionary.firstWhere(
        (element) =>
            element['content'].toString().toLowerCase() ==
            searchText.toLowerCase(),
      );
    } catch (e) {
      // Handle the case where the element is not found
      print(e);
    }

    if (searchResult != null) {
      final imagePath = searchResult['image'];
      final mp4Path = searchResult['mp4'];
      await fetchAssetUrls(imagePath, mp4Path);

      setState(() {
        content = searchResult?['content'];
        loading = false;
      });
    } else {
      setState(() {
        errorMessage = 'Sign not found';
        loading = false;
      });
    }
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
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
                  onChanged: (text) {
                    // Set mp4Url to null when the text field is cleared
                    if (text.isEmpty) {
                      setState(() {
                        mp4Url = null;
                        content = null;
                      });
                    }
                  },
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
              Visibility(
                visible: mp4Url == null,
                child: ElevatedButton(
                  onPressed: () async {
                    if (searchController.text.isNotEmpty) {
                      await loadAndDisplayVideo(searchController.text);
                      FocusScope.of(context).unfocus();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5BD8FF),
                  ),
                  child: Text("Translate to Sign", style: TextStyle(color: Color(0xFF5A5A5A), fontFamily: 'FiraSans')),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    _videoDisplay(),
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
      ),
    );
  }

  // Method to display the video
  Widget _videoDisplay() {
  if (loading) {
    return CircularProgressIndicator();
  } else {
    if (mp4Url != null) {
      return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_videoController != null) {
                      _videoController!.seekTo(Duration.zero);
                      _videoController!.play();
                    }
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
                      height: 190, // Adjust the height as needed
                      width: 300, // Adjust the width as needed
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: CachedVideoPlayer(_videoController!),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (isSlowMotion) {
                            _videoController!.setPlaybackSpeed(1.0);
                            _videoController!.play();
                          } else {
                            _videoController!.setPlaybackSpeed(0.5);
                            _videoController!.play();
                          }
                          setState(() {
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
            );
    } else {
      return Container(  
      );
    }
  }
}

}
