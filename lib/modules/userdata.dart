import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDataWidget extends StatelessWidget {
  const UserDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('userData')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return const Text('Error fetching data');
        }
         if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Text('No user data found');
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        var firstName = userData['firstName'];
        var lastName = userData['lastName'];

        // Capitalize the first letter
        String capitalizeFirstLetter(String name) {
          if (name.isEmpty) {
            return '';
          }
          return name[0].toUpperCase() + name.substring(1);
        }

        return Text(
         '${capitalizeFirstLetter(firstName)} ${capitalizeFirstLetter(lastName)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'FiraSans',
          ),
        );
      },
    );
  }
}
