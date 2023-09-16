import 'package:flutter/material.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';

class ColorLesson extends StatefulWidget {
  const ColorLesson({Key? key}) : super(key: key);

  @override
  State<ColorLesson> createState() => _ColorLessonState();
}

class _ColorLessonState extends State<ColorLesson> {
  final List<Map<String, dynamic>> lessonColors = [
    {'color': 'Red', 'subtext': 'Learn the sign for red'},
    {'color': 'Blue', 'subtext': 'Learn the sign for blue'},
    {'color': 'Green', 'subtext': 'Learn the sign for green'},
    {'color': 'Yellow', 'subtext': 'Learn the sign for yellow'},
    {'color': 'Orange', 'subtext': 'Learn the sign for orange'},
    {'color': 'Purple', 'subtext': 'Learn the sign for purple'},
    {'color': 'Pink', 'subtext': 'Learn the sign for pink'},
    {'color': 'Gray', 'subtext': 'Learn the sign for gray'},
    {'color': 'Light', 'subtext': 'Learn the sign for light'},
    {'color': 'Dark', 'subtext': 'Learn the sign for dark'},
    {'color': 'Rainbow', 'subtext': 'Learn the sign for rainbow'},
    {'color': 'Shiny', 'subtext': 'Learn the sign for shiny'},
    {'color': 'Bright', 'subtext': 'Learn the sign for bright'},
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
                          'Learn Colors',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/lesson-icon/img4.png',
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
                final lesson = lessonColors[index];
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
                        lesson['color'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _getColor(lesson['color']),
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
              childCount: lessonColors.length,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'gray':
        return Colors.grey;
      default:
        return Colors.black;
    }
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

