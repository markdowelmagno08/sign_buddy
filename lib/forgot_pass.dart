  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:font_awesome_flutter/font_awesome_flutter.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:sign_buddy/login_screen.dart';
  import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
  import 'package:sign_buddy/modules/widgets/back_button.dart';

  class ForgotPassword extends StatefulWidget {
    const ForgotPassword({Key? key}) : super(key: key);

    @override
    _ForgotPasswordState createState() => _ForgotPasswordState();
  }

  class _ForgotPasswordState extends State<ForgotPassword> {
    final TextEditingController emailController = TextEditingController();
    bool isEnglish = true;
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    bool isTyping = false;

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

    Future<void> _sendResetCode() async {
    if (_formKey.currentState!.validate()) {
      // Show loading dialog
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
                Text('Sending Reset Link...'),
              ],
            ),
          );
        },
      );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Navigate to the ResetSuccessScreen
      Navigator.pushReplacement(
        context,
        SlidePageRoute(page: ResetSuccessScreen(email: emailController.text)),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      _showResetErrorDialog(e.toString());
    }
  }
}


    void _showResetErrorDialog(String error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange,
                ),
                SizedBox(width: 8),
                Text('Reset Email Error', style: TextStyle(fontFamily: 'FiraSans', fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text('Email does not exist', style: TextStyle(fontFamily: 'FiraSans')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }

    @override
    void dispose() {
      // Dispose the text editing controllers when the State is disposed
      emailController.dispose();

      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 50),
                  alignment: Alignment.topLeft,
                  child: CustomBackButton(
                    onPressed: () {
                      Navigator.push(context, SlidePageRoute(page: LoginPage()));
                    },
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/forgot-password-img.png', // Replace with the path to your image
                        height: 120, // Adjust the height as needed
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 35),
                      Center(
                        child: Text(
                          'Enter your email address to a link to reset your password.',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,     
                        decoration: InputDecoration(
                          prefixIcon: Icon(FontAwesomeIcons.envelope, color: Colors.deepPurpleAccent),
                          hintText:'Email',
                          border: OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          
                          fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          filled: true,
                        ),
                        inputFormatters: [
                          EmailInputFormatter(maxLength: 30),
                        ],
                        onChanged: (text) {
                          setState(() {
                            isTyping = text.isNotEmpty;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return isEnglish ? "Please enter your email" : "Pakilagay ang iyong email";
                          } else if (!RegExp(
                                  r'^[a-zA-Z]+[\w-]*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$')
                              .hasMatch(value)) {
                            return isEnglish ? "Please enter a valid email" : "Pakilagay ng wastong email";
                          } else if (RegExp(r'^[0-9]+$').hasMatch(value.split('@')[0])) {
                            return isEnglish
                                ? "Email cannot consist of numbers only"
                                : "Ang email ay hindi maaaring binubuo ng mga numero lamang";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: ElevatedButton(
                    onPressed: isTyping ? _sendResetCode : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5BD8FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 3.0,
                      padding: EdgeInsets.all(16.0),
                    ),
                    child: Text(
                      'Send link',
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
      );
    }
  }

  class EmailInputFormatter extends TextInputFormatter {
    final int maxLength;

    EmailInputFormatter({required this.maxLength});

    @override
    TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
    ) {
      final RegExp regExp = RegExp(r'^[a-zA-Z0-9@.]*$');

      if (newValue.text.length > maxLength) {
        final truncatedText = newValue.text.substring(0, maxLength);

        return TextEditingValue(
          text: truncatedText,
          selection: TextSelection.collapsed(offset: maxLength),
        );
      }

      if (regExp.hasMatch(newValue.text)) {
        return newValue;
      }

      return oldValue;
    }
  }

  class ResetSuccessScreen extends StatelessWidget {
    final String email;

    const ResetSuccessScreen({required this.email, Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                  'assets/email-img.png', // Replace with the path to your image
                height: 120, // Adjust the height as needed
              ),
              SizedBox(height: 20),
              Text(
                'Reset Email Sent',
                style: TextStyle(fontFamily: 'FiraSans', fontWeight: FontWeight.bold, fontSize: 24),
              ),
              SizedBox(height: 16),
              Center(
                child: RichText(
                  textAlign: TextAlign.center, // Set the text alignment to center
                  text: TextSpan(
                    style: TextStyle(fontFamily: 'FiraSans', fontSize: 16, color: Colors.black),
                    children: [
                      TextSpan(text: 'A password reset email has been sent to '),
                      TextSpan(
                        text: '$email',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(text: '. Please check your email and follow the instructions.'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the sign-up page
                  Navigator.pushReplacement(
                      context, SlidePageRoute(page: const LoginPage()));
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  backgroundColor: Color(0xFF5BD8FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                ),
                child: Text(
                  'Okay',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )   
            ],
          ),
        ),
      );
    }
  }
