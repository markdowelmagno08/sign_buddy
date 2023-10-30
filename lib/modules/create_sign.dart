import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/firebase_storage.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:card_swiper/card_swiper.dart';

class CreateSignPage extends StatefulWidget {
  const CreateSignPage({Key? key}) : super(key: key);

  @override
  _CreateSignPageState createState() => _CreateSignPageState();
}

class _CreateSignPageState extends State<CreateSignPage> {
  final AssetFirebaseStorage assetFirebaseStorage = AssetFirebaseStorage();
  List<Map<String, dynamic>> dictionary = [];
  TextEditingController searchController = TextEditingController();
  String? mp4Url;
  CachedVideoPlayerController? _videoController;
  bool isEnglish = true;
  String? content;
  int searchIndex = 0;
  String? errorMessage;
  bool loading = false;
  bool isSlowMotion = false;
  final FocusNode _textFieldFocusNode = FocusNode();

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
    searchController.addListener(() {
      if (_videoController != null && searchController.text.isNotEmpty) {
        setState(() {
          mp4Url = null;
          content = null;
        });
      }
    });
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
        setState(() {
          _videoController!.play();
        });
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
      print(e);
    }

    if (searchResult != null) {
      final mp4Path = searchResult['mp4'];
      await fetchAssetUrls(mp4Path);

      setState(() {
        content = searchResult?['content'];
        loading = false;
      });
    } else {
      setState(() {
        errorMessage = '"${searchController.text}" sign not found';
        loading = false;
      });
    }
  }

  Future<void> playVideosInSequence(List<String> words) async {
    for (var word in words) {
      await loadAndDisplayVideo(word);
      // Wait for the video to finish playing
      while (_videoController != null && _videoController!.value.isPlaying) {
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
  }
  

  Future<void> translateToSign() async {
    FocusScope.of(context).unfocus();
    if (searchController.text.isNotEmpty) {
      List<String> words = searchController.text
          .split(" ")
          .map((word) => word.trim())
          .toList();
      await playVideosInSequence(words);
    }
  }

  void clearSearch() {
    setState(() {
      searchController.clear();
      errorMessage = null;
      if (_videoController != null) {
          _videoController!.pause();
          _videoController!.dispose();
          _videoController = null;
        }
    });
  }

  


  @override
  void dispose() {
    searchController.dispose();
    _videoController?.dispose();
    _textFieldFocusNode.dispose();
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
                  focusNode: _textFieldFocusNode, // Attach the focus node
                  onTap: clearSearch,
                  onChanged: (text) {
                    if (text.isEmpty) {
                      setState(() {
                        mp4Url = null;
                        content = null;     
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: isEnglish
                        ? 'Translate something....'
                        : 'Maghanap ng kahit ano.....',
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
                  onPressed: translateToSign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5BD8FF),
                  ),
                  child: Text("Translate to Sign",
                      style: TextStyle(color: Color(0xFF5A5A5A), fontFamily: 'FiraSans')),
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
                  height: 190,
                  width: 300,
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: CachedVideoPlayer(_videoController!),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        );
      } else {
        return Container();
      }
    }
  }
}
