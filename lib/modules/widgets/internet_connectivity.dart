import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InternetConnectivityService {
  static Future<void> checkInternetOrShowDialog({
    required BuildContext context,
    required Function onLogin, // Function to be called if there is internet connectivity
  }) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    
    // Retrieve user's language preference
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection, show an alert dialog
      _showNoInternetDialog(context, isEnglish);
    } else {
      // Internet connection is available, call the provided function
      onLogin();
    }
  }


  static void _showNoInternetDialog(BuildContext context, bool isEnglish) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Icon(
                Icons.signal_wifi_off, // You can use any icon you prefer
                color: Colors.redAccent, // Customize the icon color
                size: 60, // Customize the icon size
              ),
              SizedBox(height: 20), // Add spacing between the icon and text
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  isEnglish ? 'No Internet Connection' : "Walang Koneksyon sa Internet",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'FiraSans', // Replace with your font family name
                  ),
                ),
              ),
              SizedBox(height: 20), // Add spacing between title and message
              Text(
                isEnglish ? 'Please check your internet connection and try again.': "Pakisuri ang iyong koneksyon sa internet at subukang muli.",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'FiraSans', // Replace with your font family name
                ),
                textAlign: TextAlign.center, // Center-align the message text
              ),
            ],
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5BD8FF),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'FiraSans',
                     color: Color(0xFF5A5A5A), // Replace with your font family name
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              
            ),
            SizedBox(height: 10),
          ],
        );
      },
    );
  }

}