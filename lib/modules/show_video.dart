import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:video_player/video_player.dart'; // Import video_player package

class ShowVideo extends StatefulWidget {
  const ShowVideo({Key? key}) : super(key: key);

  @override
  ShowVideoState createState() => ShowVideoState();
}

class ShowVideoState extends State<ShowVideo> {
  final AssetFirebaseStorage assetFirebaseStorage = AssetFirebaseStorage();
  List<Map<String, dynamic>> dictionary = [];
  TextEditingController searchController = TextEditingController();
  String? mp4Url;
  bool isEnglish = true;
  bool loading = false; // Add a loading indicator
  VideoPlayerController? _videoController; // Video controller

  final CollectionReference wordsCollection =
      FirebaseFirestore.instance.collection('dictionary/en/random');

  @override
  void initState() {
    super.initState();
    loadDictionaryData();
    getLanguage();
  }

  Future<void> loadDictionaryData() async {
    final wordData = await wordsCollection.get();

    final loadedDictionary = combineData(wordData);

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

  List<Map<String, dynamic>> combineData(QuerySnapshot wordData) {
    final List<Map<String, dynamic>> combinedData = [];

    for (var doc in wordData.docs) {
      combinedData.add({
        "content": doc['content'],
        "type": "word",
        "category": doc['category'],
        "mp4": doc['mp4'],
      });
    }

    return combinedData;
  }

  Future<void> fetchAssetUrls(String? mp4Path) async {
    mp4Url = await assetFirebaseStorage.getAsset(mp4Path);
    if (mp4Url != null) {
      final Uri videoUri = Uri.parse(mp4Url!);
      _videoController = VideoPlayerController.networkUrl(videoUri);
      await _videoController!.initialize();
      await _videoController!.play(); // Play the video automatically
      if (mounted) {
        setState(() {
          // Once the URLs are fetched and the video is set to play, trigger a rebuild of the widget.
        });
      }
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
          isEnglish ? 'Hello!' : "Kamusta!",
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
                  hintText: isEnglish ? 'Search Something....' : 'Maghanap ng kahit ano.....',
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
                // Get the word entered in the search bar
                final searchWord = searchController.text;

                // Find the corresponding video URL in the dictionary
                for (var entry in dictionary) {
                  if (entry['content'] == searchWord) {
                    fetchAssetUrls(entry['mp4']);
                    break;
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5BD8FF),
              ),
              child: Text("Show Video", style: TextStyle(color: Color(0xFF5A5A5A), fontFamily: 'FiraSans')),
            ),
            if (_videoController != null)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
          ],
        ),
      ),
    );
  }
}
