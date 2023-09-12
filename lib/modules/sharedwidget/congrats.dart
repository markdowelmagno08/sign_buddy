import 'package:flutter/material.dart';
import 'package:sign_buddy/modules/lessons/alphabet/letters.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';

class Congrats extends StatelessWidget {
  const Congrats({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/congrats-img.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Congratulations!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(text: '\n'),
                        TextSpan(
                          text: ' You have completed the lesson!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        // Restart the lessons (replace it with the desired action)
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: Letters(),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const Icon(
                            Icons.refresh,
                            color: Color(0xFF5BD8FF),
                          ),
                          Text(
                            'Restart',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        // Navigate to the Home page (replace it with the desired route)
                        Navigator.push(
                          context,
                          SlidePageRoute(page: const Letters()),
                        );
                      },
                      child: Column(
                        children: [
                          const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF5BD8FF),
                          ),
                          Text(
                            'Next Lesson',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
