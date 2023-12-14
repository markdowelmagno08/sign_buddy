import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:sign_buddy/forgot_pass.dart';
import 'package:sign_buddy/front_page.dart';
import 'package:sign_buddy/get_started.dart';
import 'package:sign_buddy/modules/home_page.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:sign_buddy/modules/sharedwidget/loading.dart';
import 'package:sign_buddy/modules/widgets/internet_connectivity.dart'; 


import 'modules/sharedwidget/page_transition.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscurePassword = true;

  bool loading = false;
  String errorMessage = '';


  @override
  void dispose() {
    // Dispose the text editing controllers when the State is disposed
    _email.dispose();
    _password.dispose();


    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading(text: 'Loading . . . ')
        : Scaffold(
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 50),
                      alignment: Alignment.topLeft,
                      child: CustomBackButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, SlidePageRoute(page: FrontPage()));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                        SizedBox(height: 70),
                        _header(),
                      _inputField(),
                      SizedBox(height: 10),
                      _forgotPassword(),
                      SizedBox(height: 10), 
                      _signup(context),
                        ],
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
          );
  }

  _header() {
    return Column(
      children: [
        SizedBox(height: 40),
        Text(
          "Login",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text("Enter your credentials to login"),
      ],
    );
  }

  _inputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 30),
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
            prefixIcon: Icon(Icons.email),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return "Please enter your email";
            } else if (!RegExp(
                r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$')
                .hasMatch(value)) {
              return "Please enter a valid email";
            } else if (RegExp(r'^[0-9]+$').hasMatch(value.split('@')[0])) {
              return "Email cannot consist of numbers only";
            }
            return null;
          },

            inputFormatters: [
            EmailInputFormatter(), // Use the custom email input formatter here
          ],
          onSaved: (value) => _email.text = value!.trim(),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: _password,
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.lock),
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
              return "Please enter your password";
            }
            return null;
          },
          onSaved: (value) => _password.text = value!.trim(),
          obscureText: _obscurePassword,
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            InternetConnectivityService.checkInternetOrShowDialog(
              context: context,
              onLogin: _submitForm,
            );
          },
          child: Text(
            "Login",
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF5A5A5A),
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF5BD8FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 20),
          ),
        )
      ],
    );
  }

  _forgotPassword() {
    return TextButton(
      onPressed: () {
        Navigator.push(context, SlidePageRoute(page: ForgotPassword()));
      },
      child: Text("Forgot password?"),
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?"),
        TextButton(
          onPressed: () {
            Navigator.push(context, SlidePageRoute(page: GetStartedPage()));
          },
          child: Text("Sign up"),
        ),
      ],
    );
  }

    void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => loading = true); // Show the loading screen

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );

        _email.clear();
        _password.clear();

        // Navigate to the HomePage
        Navigator.push(context, SlidePageRoute(page: HomePage()));

        setState(() {
          _obscurePassword = true;
          loading = false;
        });
      } catch (e) {
        String errorMessage;
        if (e is FirebaseAuthException) {
          if (e.code == 'user-not-found') {
            errorMessage = 'No user found with this email. Please register first.';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Login attempts exceeded. Please try again later.\n\n Please try again later in 10 minutes.';
          } else {
            errorMessage = 'Login Failed. Please check your email and password.';
          }
        } else {
          errorMessage = 'An unexpected error occurred. Please try again later.';
        }

        setState(() {
          loading = false;
          this.errorMessage = errorMessage;
        });

        _showErrorDialog(errorMessage);
      }
    }
}


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 10),
              Text('Unable to Login',
                  style: TextStyle(
                    fontFamily: 'FiraSans',
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          content: Text(message,
              style: TextStyle(
                fontFamily: 'FiraSans',
                fontWeight: FontWeight.normal,
              )),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}


class EmailInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow alphabetic characters, numbers, "@" and ".", and disallow spaces
    final RegExp regExp = RegExp(r'^[a-zA-Z0-9@.]*$');
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}