import 'package:flutter/material.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';

class Greetings extends StatefulWidget {
  const Greetings({Key? key}) : super(key: key);

  @override
  State<Greetings> createState() => _GreetingsState();
}

class _GreetingsState extends State<Greetings> {
  final List<Map<String, dynamic>> lessonGreetings = [
    {'greeting': 'Hello', 'subtext': 'Learn about greeting: Hello'},
    {
      'greeting': 'Good Morning',
      'subtext': 'Learn about greeting: Good Morning'
    },
    {
      'greeting': 'Good Afternoon',
      'subtext': 'Learn about greeting: Good Afternoon'
    },
    {
      'greeting': 'Good Evening',
      'subtext': 'Learn about greeting: Good Evening'
    },
    {'greeting': 'Good Night', 'subtext': 'Learn about greeting: Good Night'},
    {
      'greeting': 'How are you?',
      'subtext': 'Learn about greeting: How are you?'
    },
    {
      'greeting': 'Nice to meet you',
      'subtext': 'Learn about greeting: Nice to meet you'
    },
    {'greeting': 'Thank you', 'subtext': 'Learn about greeting: Thank you'},
    {
      'greeting': 'You\'re welcome',
      'subtext': 'Learn about greeting: You\'re welcome'
    },
    {'greeting': 'Goodbye', 'subtext': 'Learn about greeting: Goodbye'},
    {
      'greeting': 'See you later',
      'subtext': 'Learn about greeting: See you later'
    },
    {
      'greeting': 'Have a nice day',
      'subtext': 'Learn about greeting: Have a nice day'
    },
    {
      'greeting': 'How are you doing?',
      'subtext': 'Learn about greeting: How are you doing?'
    },
    {'greeting': 'What\'s up?', 'subtext': 'Learn about greeting: What\'s up?'},
    {
      'greeting': 'How\'s it going?',
      'subtext': 'Learn about greeting: How\'s it going?'
    },
    {
      'greeting': 'Good to see you',
      'subtext': 'Learn about greeting: Good to see you'
    },
    {'greeting': 'Take care', 'subtext': 'Learn about greeting: Take care'},
    {'greeting': 'I\'m sorry', 'subtext': 'Learn about greeting: I\'m sorry'},
    {'greeting': 'Excuse me', 'subtext': 'Learn about greeting: Excuse me'},
    {
      'greeting': 'Congratulations',
      'subtext': 'Learn about greeting: Congratulations'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 100,
              maxHeight: 150,
              bottomPadding: 20.0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF5A96E3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 50, 36, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: CustomBackButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/homePage');
                          },
                        ),
                      ),
                      const Visibility(
                        child: Text(
                          'Learn Greetings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/lesson-icon/img10.png',
                        width: 50,
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final lesson = lessonGreetings[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      leading: const Icon(Icons.menu_book_outlined, size: 30),
                      title: Text(
                        lesson['greeting'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(lesson['subtext']),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 15),
                      onTap: () {
                        // Perform your desired action here
                      },
                    ),
                  ),
                );
              },
              childCount: lessonGreetings.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
    this.bottomPadding = 0.0, // Add a topPadding property
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;
  final double bottomPadding; // Add topPadding property

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding), // Apply top padding
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

