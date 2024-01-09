// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:sign_buddy/login_screen.dart';
import 'package:sign_buddy/get_started.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';

class FrontPage extends StatelessWidget {
  const FrontPage({super.key});

  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to close the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'No',
              style: TextStyle(color: Colors.black),
            ),
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Yes',
              style: TextStyle(color: Colors.white),
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
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              // decoration: BoxDecoration(
              //   image: DecorationImage(
              //     image: AssetImage('assets/abc.png'), // for background image
              //     fit: BoxFit.cover,
              //   ),
              // ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 100),
                  Center(
                    child: Image.asset(
                      'assets/front-img.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Hello There!",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Discover the power of Sign Language - your gateway to a vibrant community and enhanced communication.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context, SlidePageRoute(page: GetStartedPage()));
                      },
                      child: Text(
                        "Let's Go",
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  _login(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _login(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account?"),
        TextButton(
          onPressed: () {
            Navigator.push(context, SlidePageRoute(page: LoginPage()));
          },
          child: Text("Login"),
        ),
      ],
    );
  }
}
