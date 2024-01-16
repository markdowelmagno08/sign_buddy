import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/front_page.dart';
import 'package:sign_buddy/modules/home_page.dart';
import 'package:sign_buddy/modules/sharedwidget/loading.dart';

class MySettings extends StatefulWidget {
  const MySettings({Key? key}) : super(key: key);

  @override
  _MySettingsState createState() => _MySettingsState();
}

class _MySettingsState extends State<MySettings> {


  bool isEnglish = true;


   @override
  void initState() {
    getLanguage();
    super.initState();
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getBool('isEnglish');

    if (mounted) {
      setState(() {
        isEnglish = locale!;
      });
    }
  }

  
  Future<void> clearCache() async {
    final cacheDir = await path_provider.getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg-signbuddy2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  title: Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'FiraSans',
                    ),
                  ),
                  backgroundColor: const Color(0xFF5A96E3).withOpacity(0.8),
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.only(bottom: 16, left: 16),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'FiraSans',
                      color: Color.fromARGB(255, 71, 63, 63),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildListTile(
                          icon: FontAwesomeIcons.language,
                          text: 'Language',
                          onPressed: () {
                            _showLanguageSelectionDialog();
                          },
                          iconTextSpacing: 15.0,
                          subtitle: isEnglish ? 'English' : 'Filipino',
                        ),
                        _buildDivider(),
                        _buildListTile(
                          icon: FontAwesomeIcons.broom,
                          text: 'Clear cache',
                          onPressed: () {
                            clearCache();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (BuildContext context) => HomePage()), 
                              (route) => false,
                            );
                            showCustomSnackBar(
                              context,
                              "Cache cleared successfully",
                            );
                          },
                          iconTextSpacing: 15.0,
                        ),
                        
                        
                        
                        _buildDivider(),
                        //hide the delete button for authenticated users
                        if (Auth().isUserAnonymous())
                        _buildListTile(
                          icon: FontAwesomeIcons.userXmark,
                          text: isEnglish ? 'Delete account' : 'Mag-delete ng account',
                          onPressed: () {
                            _showDeleteConfirmationDialog();
                          },
                          iconTextSpacing: 15.0,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

   Future<void> _showLanguageSelectionDialog() async {
      bool? selectedLanguage = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Language',
            style: TextStyle(
              fontFamily: 'FiraSans',
              fontWeight: FontWeight.bold,
            )),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: _buildCircularImage('assets/america.png'),
                  title: Text('English', 
                  style: TextStyle(
                    fontFamily: 'FiraSans',
                  )),
                  onTap: () {
                    Navigator.pop(context, true);
                  },
                ),
                ListTile(
                  leading: _buildCircularImage('assets/ph.png'),
                  title: Text('Filipino',
                  style: TextStyle(
                    fontFamily: 'FiraSans',
                  )),
                  onTap: () {
                    Navigator.pop(context, false);
                  },
                ),
              ],
            ),
          );
        },
      );

      if (selectedLanguage != null) {
      setState(() {
        isEnglish = selectedLanguage;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isEnglish', isEnglish);

      // Update the selected language in Firestore
      await updateLanguageInFirestore();

      // Navigate back to the homepage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => HomePage()), // Replace 'HomePage()' with your actual homepage widget
        (route) => false,
      );

      // Show a Snackbar indicating the successful language change
      showCustomSnackBar(
        context,
        isEnglish ? "Language changed successfully" : "Matagumpay na naipalit ang wika"
      );
    }
  }

  Widget _buildCircularImage(String imagePath) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color.fromARGB(255, 87, 87, 87),
          width: 1.0,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> updateLanguageInFirestore() async {
    showDialog(
      context: context,
      barrierDismissible: false, // prevent user from dismissing the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
    try {
      String language = isEnglish ? 'English' : 'Filipino';
      String? userId = Auth().getCurrentUserId();

      if (userId != null) {
        await FirebaseFirestore.instance.collection('userData').doc(userId).update({'language': language});
      }
    } catch (e) {
      print('Error updating language in Firestore: $e');
    }
  }

  void showCustomSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
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

  Widget _buildListTile({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    double iconTextSpacing = 0,
    String? subtitle, // New parameter for subtitle (current language)
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          FaIcon(
            icon,
            color: Colors.deepPurpleAccent,
          ),
          SizedBox(width: iconTextSpacing),
          Text(
            text,
            style: TextStyle(
              color: Color.fromARGB(255, 71, 63, 63),
              fontSize: 16,
              fontFamily: 'FiraSans',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      subtitle: subtitle != null
          ? Padding(
            padding: const EdgeInsets.only(left: 45.0),
            child: Text(
                subtitle,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontFamily: 'FiraSans',
                ),
              ),
          )
          : null,
      onTap: onPressed,
    );
  }



  Widget _buildDivider() {
    return Divider(
      color: Colors.deepPurpleAccent,
      height: 5,
      thickness: 1,
    );
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.redAccent,
              ),
              SizedBox(width: 8),
              Text(isEnglish ? 'Confirm Deletion' : 'Kumpirmahin', style: TextStyle(fontFamily: 'FiraSans', fontWeight: FontWeight.bold)),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: TextStyle(fontFamily: 'FiraSans', color: Colors.black, fontSize: 15),
              children: [
                TextSpan(
                  text: isEnglish ? 'Are you sure you want to delete your account?\n\n' : 'Sigurado ka bang nais mong burahin ang iyong account?',
                ),
                TextSpan(
                  text: isEnglish ? 'This action cannot be undone': 'Hindi maaaring bawiin ang hakbang na ito',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black45,
                  fontFamily: 'Fira Sans'
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteAccount();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              ),
              child: Text(
                'Delete',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }  


  Future<void> _deleteAccount() async {
    showDialog(
        context: context,
        barrierDismissible: false, // prevent user from dismissing the dialog
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(isEnglish ? 'Deleting account...' : 'Pagbubura ng account'),
              ],
            ),
          );
        },
      );
    // Perform necessary logic to delete the account from the Firestore database
    String? userId = Auth().getCurrentUserId();

    try {
      // Show a loading dialog
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false, // Make the loading page non-opaque
            pageBuilder: (context, _, __) {
              return const Loading(text: 'Loading . . . '); 
            },
          ),
        );
      if (userId != null) {
        // Delete user data from Firestore
        await FirebaseFirestore.instance.collection('userData').doc(userId).delete();

        // Delete the user from Firebase Authentication
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.isAnonymous) {
          await currentUser.delete();

          // Sign out if the user is not anonymous
          if (!currentUser.isAnonymous) {
            await Auth().signOut();
          }

          // Close the loading dialog
          if (!context.mounted) return;
          Navigator.pop(context);

          // Navigate back to the home screen or any other screen
          Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => const FrontPage()),
          (route) => false);
        } else {
          // Handle the case where the user is not anonymous
          print("User is not anonymous or user is null.");
          Navigator.pop(context);
        }
      } else {
        // Handle the case where user ID is null
        print("User ID is null or empty.");
        Navigator.pop(context);
      }
    } catch (e) {
      // Handle errors, e.g., show an error dialog
      print("Error deleting account: $e");
      Navigator.pop(context); // Close the loading dialog
    }
  }



}
