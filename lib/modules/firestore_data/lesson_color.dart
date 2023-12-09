import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/firestore_user.dart';

  class ColorLessonFireStore {

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String userId;


    ColorLessonFireStore ({
      required this.userId,
    });



  Future<Map<String, dynamic>?> getLessonData (

    String lessonName, String locale) async {

      try {
        final DocumentSnapshot doc = await firestore
            .collection('color')
            .doc(locale)
            .collection('lessons')
            .doc(lessonName)
            .get();

        if(doc.exists){
          return doc.data() as Map <String, dynamic>;
        }
        else {
          return null;
        }


      } catch(e) {
        print('Error retrieving lesson data: $e');
        return null;
      }
    }

    Future<Map<String, dynamic>?> getUserLessonData(
      String lessonName, String locale) async {

        try {
          final DocumentSnapshot doc = await firestore
          .collection('userData')
          .doc(userId)
          .collection('color')
          .doc(locale)
          .collection('lessons')
          .doc(lessonName)
          .get();

        if (doc.exists) {
          return doc.data() as Map<String, dynamic>;
        } else {
          return null;
        }
        } catch (e) {
          print('Error retrieving lesson data: $e');
          return null;
        }
      }

      // Function to update lesson data
      Future<void> updateLessonData(
          String lessonName, String locale, Map<String, dynamic> newData) async {
        try {
          await firestore
              .collection('userData')
              .doc(userId)
              .collection('color')
              .doc(locale)
              .collection('lessons') 
              .doc(lessonName)
              .update(newData);
        } catch (e) {
          print('Error updating lesson data: $e');
        }
      }

       // Function that resets progress data to 0
      Future<void> resetProgress(String lessonName, String locale) async {

        try {
          if(lessonName.isEmpty) {

            print('Invalid lessonName: $lessonName');
            return; 
          }

          if(userId.isEmpty) {
            print('Invalid userId: $userId');
            return;
          }

          final DocumentReference lessonRef = firestore 
            .collection('userData')
            .doc(userId)
            .collection('color')
            .doc(locale)
            .collection('lessons')
            .doc(lessonName);

          await lessonRef
            .set({'progress': 0}, SetOptions(merge: true))
            .then((value) => print('Progress has been reset successfully.'))
            .onError((error, stackTrace) =>
            print("Progress Failed to reset:$error, $stackTrace"));
        } catch (e) {
          print('Error setting the progress to zero: $e');
        }
      }
      

      // Function to increment lesson progress value
      Future<void> incrementProgressValue(String lessonName, String locale, int value) async {

        try {
          if (lessonName.isEmpty) {
            print('Invalid lessonName: $lessonName');
            return;
          }

          if (userId.isEmpty) {
            print('Invalid userId: $userId');
            return;
          }

          final DocumentReference lessonRef = firestore
            .collection('userData')
            .doc(userId)
            .collection('color')
            .doc(locale)
            .collection('lessons')
            .doc(lessonName);

          await firestore
              .runTransaction((transaction) async {
                DocumentSnapshot lessonSnapshot = await transaction.get(lessonRef);
                
                if(lessonSnapshot.exists) {
                  int currentProgress = lessonSnapshot.get('progress') ?? 0;
                  int newProgress = currentProgress + value;


                  if (newProgress <= 100) {
                    transaction.update(lessonRef, {'progress': newProgress});
                  } else {
                    transaction.update(lessonRef, {'progress': 100});
                  }
                }
              })
              .then((_) => print('Progress updated sucessfully'))
              .onError((error, stackTrace) =>  print("Error updating progress: $error, $stackTrace"));

        } catch(e) {
           print('Error updating lesson data: $e');
        }
      }

      Future<void> unlockLesson(String lessonName, String locale) async {

        try {
          final CollectionReference lessonCollection = FirebaseFirestore.instance 
              .collection('userData')
              .doc(userId)
              .collection('color')
              .doc(locale)
              .collection('lessons');
              


          // Find the next lesson
          QuerySnapshot querySnapshot = await  lessonCollection
              .where('name', isGreaterThan: lessonName) // Find lessons with names greater than the current lesson
              .orderBy('name')
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
              // Unlock the next lesson
              DocumentReference nextLessonRef = querySnapshot.docs.first.reference;
              await nextLessonRef.update({'isUnlocked': true});
              print(
                  'Lesson "$lessonName" and the next lesson unlocked successfully!');
            } else {
              print('Next lesson not found for "$lessonName".');
            }
          
        } catch (e) {
          print('Error updating lesson data: $e');
        }
      }

       Future<void> unlockFirstNumbersLesson(String locale) async {
          try {
            final CollectionReference firstNumbersLesson = FirebaseFirestore.instance
                .collection('userData')
                .doc(userId)
                .collection('numbers')
                .doc(locale)
                .collection('lessons');

            QuerySnapshot querySnapshot =
                await firstNumbersLesson.orderBy('name').limit(1).get();

            if (querySnapshot.docs.isNotEmpty) {
              DocumentReference firstLesson = querySnapshot.docs.first.reference;
              await firstLesson.update({'isUnlocked': true});
              print('First numbers lesson unlocked successfully.');
            } else {
              print('No query was returned. Unable to update any data.');
            }
          } catch (e) {
            print('Error updating lesson data: $e');
          }
        }

        Future<void> clearProgress(String lessonName, String locale) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          // Check if the user is a new account
          final isNewAccount = await UserFirestore(userId: userId).getIsNewAccount(); // Implement this function to check if the user is new

          if (isNewAccount) {
            for (int i = 1; i <= 6; i++) {
              await prefs.setBool('$lessonName-completed$i', false);
            }
          }
        }

}


  