import 'package:firebase_storage/firebase_storage.dart';


// class that gets thee assets path in firebase and download the URL 
class AssetFirebaseStorage {
  final storage = FirebaseStorage.instance;

  Future<String?> getAsset(String? path) async {
    try {
      if (path != null) {
        return storage.ref(path).getDownloadURL();
      } else {
        return null;
      }
    } catch (e) {
      print('Failed to retrieve the asset on Firebase Storage: $e');
      return null;
    }
  }
}