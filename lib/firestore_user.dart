import 'package:cloud_firestore/cloud_firestore.dart';


class UserFirestore {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String userId;

  UserFirestore({required this.userId});

  Future<Map<String, dynamic>> getDocumentData() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('userData').doc(userId).get();
    return snapshot.data() ?? {};
  }

  // Function to save user data to Firestore
  Future<void> saveUserDataToFirestore(
      String userId, Map<String, dynamic> userData) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('userData');

    final DocumentReference userDocRef = usersCollection.doc(userId);

    // Save user data to the main document
    await userDocRef.set(userData);
  }

  Future<void> initializeLessons(String lessonCategory, String locale) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Reference to the source collection "letters > en > lessons"
      CollectionReference sourceCollection = firestore
          .collection(lessonCategory)
          .doc(locale)
          .collection('lessons');

      // Reference to the destination collection "users > <userId> > letters > en > lessons"
      CollectionReference destinationCollection = firestore
          .collection('userData')
          .doc(userId)
          .collection(lessonCategory)
          .doc(locale)
          .collection('lessons');

      // Query the source collection
      QuerySnapshot sourceQuery = await sourceCollection.get();

      // Loop through the documents in the source collection
      for (QueryDocumentSnapshot sourceDoc in sourceQuery.docs) {
        // Get the data from the source document
        Map<String, dynamic> data = sourceDoc.data() as Map<String, dynamic>;

        // Extract only the necessary keys
        Map<String, dynamic> newData = {
          'isUnlocked': data['isUnlocked'],
          'name': data['name'],
          'progress': data['progress'],
        };

        // Get the document ID from the source document
        String documentId = sourceDoc.id;

        // Add the data to the destination collection with the same document ID
        await destinationCollection.doc(documentId).set(newData);
      }

      print('Documents copied successfully');
    } catch (e) {
      print('Error copying documents: $e');
    }
  }

  Future<bool> getIsNewAccount() async {
    var data = await getDocumentData();

    return data['isNewAccount'];
  }

  



}