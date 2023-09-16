import 'package:flutter/material.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';

class Shapes extends StatefulWidget {
  const Shapes({Key? key}) : super(key: key);

  @override
  State<Shapes> createState() => _ShapesState();
}

class _ShapesState extends State<Shapes> {
  final List<Map<String, dynamic>> lessonShapes = [
    {'shape': 'Circle', 'subtext': 'Learn about circles'},
    {'shape': 'Triangle', 'subtext': 'Learn about triangles'},
    {'shape': 'Square', 'subtext': 'Learn about squares'},
    {'shape': 'Rectangle', 'subtext': 'Learn about rectangles'},
    {'shape': 'Pentagon', 'subtext': 'Learn about pentagons'},
    {'shape': 'Hexagon', 'subtext': 'Learn about hexagons'},
    {'shape': 'Octagon', 'subtext': 'Learn about octagons'},
    {'shape': 'Diamond', 'subtext': 'Learn about diamond'},
    {'shape': 'Star', 'subtext': 'Learn about star'},
    {'shape': 'Heart', 'subtext': 'Learn about heart'},
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
                          'Learn Shapes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/lesson-icon/img5.png',
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
                final lesson = lessonShapes[index];
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
                        lesson['shape'],
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
              childCount: lessonShapes.length,
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

