import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  final String text;

  const Loading({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF5A96E3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitSpinningLines(
            color: Color(0xFFFEE8B0),
            size: 70.0,
          ),
          const SizedBox(height: 20),
          DefaultTextStyle(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontFamily: 'FiraSans',
              fontWeight: FontWeight.normal,
            ),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
