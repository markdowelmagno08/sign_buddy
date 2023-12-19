import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();

  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmNewPasswordVisible = false;
  bool passwordsMatch = false;
  bool isEnglish = true;
  bool isTyping = false;

  

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();


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

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Reauthenticate the user before changing the password
        AuthCredential credential =
            EmailAuthProvider.credential(email: user.email!, password: currentPassword);
        await user.reauthenticateWithCredential(credential);

        // Change the user's password
        await user.updatePassword(newPassword);

        // Password change successful, show success message or navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password changed successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Handle errors, e.g., show an error message to the user
      print("Error changing password: $e");
      // Show error message in a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change password: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  Future<void> _showLoadingDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(isEnglish ? 'Changing password...' : 'Nagpapalit ng password'),
            ],
          ),
        );
      },
    );
  }
  void _updatePasswordsMatch() {
    if (confirmNewPasswordController.text.isNotEmpty) {
      if(mounted) {
        setState(() {
        passwordsMatch =
            confirmNewPasswordController.text == newPasswordController.text;
      });

      }
       
    } else {
      if(mounted) {
          setState(() {
          passwordsMatch = false;
        });
      }
      
    }
  }

 

  Future<void> _showConfirmationDialog() async {
    if (_formKey.currentState!.validate()) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange,
                ),
                SizedBox(width: 8), // Add some space between the icon and text
                Text(isEnglish ? 'Password change' : 'Pagpapalit ng password', style: TextStyle(fontFamily: 'FiraSans', fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(isEnglish ? 'Are you sure you want to change your password?' : 'Sigurado ka bang nais mong palitan ang iyong password?', style: TextStyle(fontFamily: 'FiraSans')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black45, 
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _changePassword();
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                ),
                child: Text(
                  isEnglish ? 'Confirm' : 'Kumpirmahin',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading dialog
        _showLoadingDialog();

        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Reauthenticate the user before changing the password
          AuthCredential credential = EmailAuthProvider.credential(
              email: user.email!, password: currentPasswordController.text);

          await user.reauthenticateWithCredential(credential);

          // Check if the new password is the same as the old password
          if (currentPasswordController.text == newPasswordController.text) {
            Navigator.of(context).pop(); // Close loading dialog
            _showSnackbar(
              isEnglish
                  ? 'New password cannot be the same as the old password.'
                  : 'Ang bagong password ay hindi maaaring katulad ng lumang password.',
            );
            return;
          }

          // Change the user's password
          await user.updatePassword(newPasswordController.text);

          // Password change successful, show success message or navigate back
          Navigator.of(context).pop(); // Close loading dialog
          _showSnackbar('Password changed successfully!');
          Navigator.of(context).pop();
        }
      } catch (e) {
        // If reauthentication fails, show an error message and return
        Navigator.of(context).pop(); // Close loading dialog
        _showSnackbar(
          isEnglish
              ? 'Password change failed. Please check your current password.'
              : 'Reauthentication error. Pakiverify ang iyong kasalukuyang password.',
        );
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }


  @override
  void dispose() {
    // Dispose the text editing controllers when the State is disposed
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg-signbuddy.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          AppBar(
                            title: Text(
                              'Change password',
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
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isEnglish ? 'Current password' : 'Kasalukuyang password',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontFamily: 'FiraSans',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextFormField(
                                      controller: currentPasswordController,
                                      obscureText: !_currentPasswordVisible,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.deepPurpleAccent,
                                          ),
                                          
                                        ),
                                        fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                        filled: true,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _currentPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            if(mounted) {
                                              setState(() {
                                                _currentPasswordVisible =
                                                    !_currentPasswordVisible;
                                              });

                                            }
                                            
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return isEnglish ? 'Please enter your current password' : 'Pakilagay ang iyong kasalukuyang password';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isEnglish ? 'New password' : 'Bagong password',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontFamily: 'FiraSans',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextFormField(
                                      controller: newPasswordController,
                                      obscureText: !_newPasswordVisible,
                                      onChanged: (value) {
                                        if(mounted) {
                                          setState(() {
                                            _updatePasswordsMatch();
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.deepPurpleAccent,
                                          ),
                                        ),
                                        fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                        filled: true,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _newPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            if(mounted) {
                                              setState(() {
                                                _newPasswordVisible = !_newPasswordVisible;
                                              });
                                            }
                                            
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return isEnglish
                                              ? 'Please enter your new password'
                                              : 'Pakilagay ang iyong bagong password';
                                        } else if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$')
                                            .hasMatch(value)) {
                                          return isEnglish
                                              ? 'Password must:\n- Be at least 8 characters long\n- Contain at least one uppercase letter\n- Contain at least one digit'
                                              : "Dapat ang password: \n Maging hindi bababa sa walong(8) karakter ang haba\n- Maglagay ng hindi bababa sa isang malaking titik\n- Maglagay ng hindi bababa sa isang numero ";
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isEnglish ? 'Confirm new password' : 'Kumpirmahin ang bagong password',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontFamily: 'FiraSans',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextFormField(
                                      controller: confirmNewPasswordController,
                                      obscureText: !_confirmNewPasswordVisible,
                                      onChanged: (value) {
                                        if(mounted) {
                                          setState(() {
                                          isTyping = true;
                                          _updatePasswordsMatch();
                                        });

                                        }
                                        
                                      },
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.deepPurpleAccent,
                                          ),
                                        ),
                                        fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                        filled: true,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _confirmNewPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            if(mounted) {
                                                setState(() {
                                                _confirmNewPasswordVisible =
                                                    !_confirmNewPasswordVisible;
                                              });    
                                            }
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return isEnglish
                                              ? 'Please confirm your new password'
                                              : 'Pakumpirmahin ang iyong bagong password';
                                        } else if (value.length < 8) {
                                          return isEnglish
                                              ? 'Password must be at least 8 characters long'
                                              : 'Ang password ay dapat hindi kukulangin sa walong(8) karakter.';
                                        } else if (value != newPasswordController.text) {
                                          return isEnglish
                                              ? 'Passwords do not match'
                                              : 'Hindi tugma ang mga password';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 10),
                                    if (confirmNewPasswordController.text.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          passwordsMatch ? Icons.check : Icons.error,
                                          color: passwordsMatch ? Colors.green : Colors.red,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                           passwordsMatch ? (isEnglish ? 'Passwords match' : 'Ang password ay nagtugma') : (isEnglish ? 'Passwords do not match' : 'Ang password ay hindi nagtugma'),
                                          style: TextStyle(
                                            color: passwordsMatch ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      child: ElevatedButton(
                        onPressed: _showConfirmationDialog,
                        style: ElevatedButton.styleFrom(        
                          backgroundColor: Color(0xFF5BD8FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 3.0,
                          padding: EdgeInsets.all(16.0),
                        ),
                        child: Text(
                          isEnglish ? 'Change password' : 'Baguhin ang password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
