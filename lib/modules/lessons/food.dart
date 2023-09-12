import 'package:flutter/material.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';

class Food extends StatefulWidget {
  const Food({Key? key}) : super(key: key);

  @override
  State<Food> createState() => _FoodState();
}

class _FoodState extends State<Food> {
  final List<Map<String, dynamic>> lessonFood = [
    {'food': 'Bread', 'subtext': 'Learn about bread'},
    {'food': 'Cereal', 'subtext': 'Learn about cereal'},
    {'food': 'French Fries', 'subtext': 'Learn about french fries'},
    {'food': 'Hamburger', 'subtext': 'Learn about hamburgers'},
    {'food': 'Ketchup', 'subtext': 'Learn about ketchup'},
    {'food': 'Milkshake', 'subtext': 'Learn about milkshakes'},
    {'food': 'Pancake', 'subtext': 'Learn about pancakes'},
    {'food': 'Pepperoni', 'subtext': 'Learn about pepperoni'},
    {'food': 'Pizza', 'subtext': 'Learn about pizza'},
    {'food': 'Sandwich', 'subtext': 'Learn about sandwiches'},
    {'food': 'Soup', 'subtext': 'Learn about soup'},
    {'food': 'Spaghetti', 'subtext': 'Learn about spaghetti'},
    {'food': 'Taco', 'subtext': 'Learn about tacos'},
    {'food': 'Toast', 'subtext': 'Learn about toast'},
    {'food': 'Tortilla', 'subtext': 'Learn about tortillas'},
    {'food': 'Waffle', 'subtext': 'Learn about waffles'},
    {'food': 'Water', 'subtext': 'Learn about water'},
    {'food': 'Milk', 'subtext': 'Learn about milk'},
    {'food': 'Hot Chocolate', 'subtext': 'Learn about hot chocolate'},
    {'food': 'Coffee', 'subtext': 'Learn about coffee'},
    {'food': 'Tea', 'subtext': 'Learn about tea'},
    {'food': 'Juice', 'subtext': 'Learn about juice'},
    {'food': 'Soft Drinks', 'subtext': 'Learn about soft drinks'},
    {'food': 'Beer', 'subtext': 'Learn about beer'},
    {'food': 'Wine', 'subtext': 'Learn about wine'},
    {'food': 'Champagne', 'subtext': 'Learn about champagne'},
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
                          'Learn Food and Drinks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/lesson-icon/img8.png',
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
                final lesson = lessonFood[index];
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
                        lesson['food'],
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
              childCount: lessonFood.length,
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
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
