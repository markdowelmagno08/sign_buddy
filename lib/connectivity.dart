import 'dart:io'; // Import the 'dart:io' library for InternetAddress

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static ConnectivityResult previousConnectivity = ConnectivityResult.none;

  static void initializeConnectionListener(BuildContext context) async {
    // Check for initial internet connectivity
    bool isOnline = await _checkInternetConnectivity();

    // Set initial connectivity state
    previousConnectivity = isOnline ? ConnectivityResult.wifi : ConnectivityResult.none;

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _handleConnectivityResult(context, result);
    });
  }

  static Future<bool> _checkInternetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static void _handleConnectivityResult(BuildContext context, ConnectivityResult result) {
    if (previousConnectivity == ConnectivityResult.none &&
        (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile)) {
      // Internet connection restored after disconnection
      _showSnackbar(context, 'Internet Restored', Icons.wifi);
    } else if (result == ConnectivityResult.mobile) {
      _showSnackbar(context, 'Mobile Data Restored', Icons.data_usage);
    } else if (result == ConnectivityResult.none) {
      // Internet disconnected
      _showSnackbar(context, 'No Internet Connection', Icons.signal_wifi_off);
    }

    // Update the previous connectivity state
    previousConnectivity = result;
  }

  static void _showSnackbar(BuildContext context, String message, IconData iconData) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            iconData,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'FiraSans',
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFF36454F),
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
