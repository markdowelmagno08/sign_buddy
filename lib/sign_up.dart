import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sign_buddy/modules/home_page.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/sharedwidget/loading.dart';
import 'package:flutter/services.dart';
import 'package:sign_buddy/modules/widgets/internet_connectivity.dart'; 



class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool loading = false;
  bool isEnglish = true;
  bool passwordsMatch = false;

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    getLanguage();
   
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    setState(() {
      this.isEnglish = isEnglish;
    });
  }
  void _updatePasswordsMatch() {
    if (_confirmPassword.text.isNotEmpty) {
      if(mounted) {
        setState(() {
        passwordsMatch =
            _confirmPassword.text == _password.text;
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

  @override
  Widget build(BuildContext context) {
    return loading
        ?  Loading(
            text: isEnglish ? 'Setting up your preferences . . .' : 'Pagse-set up ng iyong mga kagustuhan'
          )
        : SafeArea(
            child: Scaffold(
              body: Form(
                key: _formKey,
                child: WillPopScope(
                  onWillPop: () async {
                    return false;
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 0, 20, 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(height: 50),
                        Container(
                          alignment: Alignment.topLeft,
                          // child: CustomBackButton(
                          //   onPressed: () {
                          //      Navigator.push(context, SlidePageRoute(page: const GetStartedPage()));// Handle routing here
                          //   },
                          // ),
                        ),
                        const SizedBox(height: 30),
                        _header(),
                        const SizedBox(height: 40),
                        _inputField(),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: () {
                              // Handle "Skip" button action here
                              // For example, navigate to the home page directly
                              Navigator.pushReplacement(
                                context,
                                SlidePageRoute(page: const HomePage()),
                              );
                            },
                            child:  Text(
                              isEnglish ? "Skip for now" : "Laktawan sa ngayon",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  _header() {
    return  Column(
      children: [
        Text(
          isEnglish ? "Sign up" : "Mag-sign up",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(isEnglish ? "So you dont lose your progress" : "Upang hindi mawala ang iyong progress"),
      ],
    );
  }

  _inputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          child: TextFormField(
            controller: _firstName,
            decoration: InputDecoration(
              hintText: isEnglish ? "First Name" :  "Pangalan",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return isEnglish ? "Please enter your first name" : "Pakilagay ang iyong pangalan" ;
              }
              return null;
            },
            inputFormatters: [
            CustomInputFormatter(maxLength: 15), // Apply the custom input formatter here
          ],
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _lastName,
          decoration: InputDecoration(
            hintText: isEnglish ? "Last Name" : "Apelyido",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.person),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return isEnglish ? "Please enter your last name" : "Pakilagay ang iyong apelyido" ;
            }
            return null;
          },
          inputFormatters: [
            CustomInputFormatter(maxLength: 15), // Apply the custom input formatter here
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _email,
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.mail),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return isEnglish ? "Please enter your email" : " Pakilagay ang iyong email";
            } else if (!RegExp(
                r'^[a-zA-Z]+[\w-]*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$')
                .hasMatch(value)) {
              return isEnglish ? "Please enter a valid email" : "Pakilagay ng wastong email";
            } else if (RegExp(r'^[0-9]+$').hasMatch(value.split('@')[0])) {
              return isEnglish ? "Email cannot consist of numbers only" : "Ang email ay hindi maaaring binubuo ng mga numero lamang";
            }
            return null;
          },
            inputFormatters: [
            EmailInputFormatter(), // Use the custom email input formatter here
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _password,
          onChanged: (value) {
            if(mounted) {
              setState(() {
                _updatePasswordsMatch();
              });
              }
          },
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              child: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
            ),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return isEnglish ? "Please enter your password" : "Pakilagay ang iyong password";
            } else {
              if (value.length < 8) {
                return isEnglish ? 'Password must be at least 8 characters long' : 'Dapat ang password ay hindi bababa\nsa walong(8) karakter ang haba';
              }
              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                return isEnglish ? 'Password must contain at least one uppercase letter' : 'Dapat maglagay ng hindi bababa\nsa isang malaking titik sa password';
              }
              if (!RegExp(r'\d').hasMatch(value)) {
                return isEnglish ? 'Password must contain at least one digit' : 'Dapat maglagay ng hindi bababa\nsa isang numero sa password';
              }
              if (!RegExp(r'[@#$%^&+=]').hasMatch(value)) {
                return isEnglish ? 'Password must contain at least one special character' : 'Dapat maglagay ng hindi bababa\nsa isang espesyal na karakter sa password';
              }
            }
            return null;
          },
          obscureText: _obscurePassword,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _confirmPassword,
          onChanged: (value) {
            if(mounted) {
              setState(() {
                _updatePasswordsMatch();
              });
              }
          },
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: isEnglish ? "Confirm Password": "Kumpirmahin ang Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              child: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
            ),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return isEnglish ? "Please enter your password" : " Pakilagay ang iyong password";
            } else if (_confirmPassword.text.isNotEmpty && value != _confirmPassword.text) {
              return isEnglish ? 'Passwords do not match' : 'Hindi tugma ang mga password';
            }
            return null;
          },
          obscureText: _obscureConfirmPassword,
        ),
        SizedBox(height: 10),
        if (_confirmPassword.text.isNotEmpty)
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
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: passwordsMatch ? _submitForm : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5BD8FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child:  Text(
            "Sign up",
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF5A5A5A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Widget _signup(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       const Text("Already have an account?"),
  //       TextButton(
  //         onPressed: () {
  //           Navigator.push(context, SlidePageRoute(page: const LoginPage()));
  //         },
  //         child: const Text(
  //           "Log in",
  //           style: TextStyle(
  //             color: Color(0xFF5BD8FF),
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

    void _submitForm() async {
    // Check for internet connectivity
    await InternetConnectivityService.checkInternetOrShowDialog(
      context: context,
      onLogin: () async {
        // If there is internet connectivity, proceed with the signup logic

        if (_formKey.currentState!.validate()) {
          // Show the loading screen
          setState(() => loading = true);

          try {
            // Check if the email already exists in Firebase Firestore
            bool emailExists = await _checkIfEmailExists(_email.text);

            if (emailExists) {
              // Email already exists, show an alert modal
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(isEnglish ? "Email Already Exists": "Nagamit na ang email na ito"),
                    content: Text(isEnglish  ? "The provided email address is already in use." : "Ginagamit na ang ibinigay na email address."),
                    actions: <Widget>[
                      TextButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the alert
                          setState(() => loading = false); // Hide the loading screen
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              // Email doesn't exist, proceed with sign-up
              User? currentUser = FirebaseAuth.instance.currentUser;

              if (currentUser != null && currentUser.isAnonymous) {
                // Convert the anonymous account to a permanent account
                AuthCredential credential = EmailAuthProvider.credential(
                  email: _email.text,
                  password: _password.text,
                );
                UserCredential userCredential =
                    await currentUser.linkWithCredential(credential);

                // Retrieve the updated user ID
                final String userId = userCredential.user!.uid;

                // Get the existing user data (gathered before signing up)
                DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                    .collection('userData')
                    .doc(currentUser.uid)
                    .get();
                Map<String, dynamic> existingData =
                    userSnapshot.data() as Map<String, dynamic>? ?? {};

                // Merge the existing data with the new data
                Map<String, dynamic> newData = {
                  'firstName': _firstName.text,
                  'lastName': _lastName.text,
                  'email': _email.text,
                  'isNewAccount': true
                };
                newData.addAll(existingData);

                // Store the merged data in Firestore with the document named after the user UID
                await FirebaseFirestore.instance
                    .collection('userData')
                    .doc(userId)
                    .set(newData);

                setState(() {
                  loading = false;
                });

                // Perform any additional actions or navigate to the desired screen
                Navigator.pushReplacement(context, SlidePageRoute(page: const HomePage()));
              } else {
                // Create a new permanent Firebase account
                UserCredential userCredential =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: _email.text,
                  password: _password.text,
                );

                // Retrieve the user ID
                final String userId = userCredential.user!.uid;

                // Store the data in Firestore with the document named after the user UID
                await FirebaseFirestore.instance
                    .collection('userData')
                    .doc(userId)
                    .set({
                  'firstName': _firstName.text,
                  'lastName': _lastName.text,
                  'email': _email.text,
                  'isNewAccount': true
                });

                // Perform any additional actions or navigate to the desired screen
                Navigator.pushReplacement(context, SlidePageRoute(page: const HomePage()));
                // Dismiss the loading screen
                setState(() {
                  loading = false;
                });
              }
            }
          } catch (e) {
            setState(() {
              loading = false;
            });
            print(e.toString());
          }
        }
      },
    );
  }

}

Future<bool> _checkIfEmailExists(String email) async {
  try {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('userData')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.isNotEmpty;
  } catch (e) {
    print(e.toString());
    return false;
  }
}




class CustomInputFormatter extends TextInputFormatter {
  final int maxLength;

  CustomInputFormatter({required this.maxLength});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only alphabetic characters with zero or one space
    final RegExp regExp = RegExp(r'^[a-zA-Z]*\s?[a-zA-Z]*$');
    
    // Check if the new value exceeds the maximum length
    if (newValue.text.length > maxLength) {
      // Truncate the text to the maximum length
      final truncatedText = newValue.text.substring(0, maxLength);
      
      // Return the truncated text with the updated selection
      return TextEditingValue(
        text: truncatedText,
        selection: TextSelection.collapsed(offset: maxLength),
      );
    }

    // If the input matches the allowed pattern, capitalize the first letter
    if (regExp.hasMatch(newValue.text)) {
      return capitalizeFirstLetter(newValue);
    }

    // If the input doesn't match the pattern, revert to the old value
    return oldValue;
  }

  TextEditingValue capitalizeFirstLetter(TextEditingValue value) {
    // Capitalize the first letter
    String newText = value.text;
    if (newText.isNotEmpty) {
      newText = newText[0].toUpperCase() + newText.substring(1);
    }
    return TextEditingValue(
      text: newText,
      selection: value.selection,
    );
  }
}

class EmailInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow alphabetic characters, numbers, "@" and ".", disallow spaces, and convert to lowercase
    final RegExp regExp = RegExp(r'^[a-z0-9@.]*$');
    String formattedValue = newValue.text.toLowerCase(); // Convert to lowercase
    
    if (regExp.hasMatch(formattedValue)) {
      return TextEditingValue(
        text: formattedValue,
        selection: newValue.selection,
      );
    }
    
    return oldValue;
  }
}