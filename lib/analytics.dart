import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> incrementInteractions(String language, String interactionField) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String userUid = user.uid;

        int currentInteractions = await _getCurrentUserInteractions(
            userUid, language, interactionField);

        int newInteractions = currentInteractions + 1;

        await _updateUserInteractions(userUid, language, interactionField, newInteractions);
      }
    } catch (error) {
      print('Error incrementing interactions: $error');
    }
  }

  Future<int> _getCurrentUserInteractions(
      String userUid, String language, String interactionField) async {
    try {
      DocumentSnapshot userData = await _firestore
          .collection('userData')
          .doc(userUid)
          .collection(language)
          .doc('interact')
          .get();

      if (userData.exists) {
        Map<String, dynamic>? dataMap =
            userData.data() as Map<String, dynamic>?;

        dynamic interactionsData = dataMap?[interactionField];
        if (interactionsData is int) {
          return interactionsData;
        } else {
          return 0;
        }
      } else {
        return 0;
      }
    } catch (error) {
      print('Error getting interactions: $error');
      return 0;
    }
  }

  Future<void> _updateUserInteractions(
      String userUid, String language, String interactionField, int interactions) async {
    await _firestore
        .collection('userData')
        .doc(userUid)
        .collection(language)
        .doc('interact')
        .set({interactionField: interactions}, SetOptions(merge: true));
  }
}
