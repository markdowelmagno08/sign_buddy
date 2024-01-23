import 'package:flutter/material.dart';
import 'package:sign_buddy/modules/lessons/animals/animals.dart';

import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';

class AnimalExitConfirmationDialog {
  static void show(BuildContext context, bool isEnglish) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Image.asset(
                'assets/sad.gif',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 25),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 10),
                    Text(
                      isEnglish ? "End lesson?" : "Itigil ang aralin?",
                      style: TextStyle(
                        fontFamily: 'FiraSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Text(
            isEnglish ? "You will restart your lesson" : "Uumpisahan mo ulit ang iyong aralin",
            style: TextStyle(fontFamily: 'FiraSans'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                Navigator.pushReplacement(context, SlidePageRoute(page: Animals()));
              },
              child: Text(
                isEnglish ? "End" : "Tapusin",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                isEnglish ? 'Continue' : 'Magpatuloy',
                style: TextStyle(
                  color: Colors.white
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              ),
            ),
          ],
        );
      },
    );
  }
}
