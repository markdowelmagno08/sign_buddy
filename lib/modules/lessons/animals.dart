import 'package:flutter/material.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';

class Animals extends StatefulWidget {
  const Animals({Key? key}) : super(key: key);

  @override
  State<Animals> createState() => _AnimalsState();
}

class _AnimalsState extends State<Animals> {
  final List<Map<String, dynamic>> lessonAnimals = [
    {'animal': 'Bat', 'subtext': 'Learn about bats'},
    {'animal': 'Bear', 'subtext': 'Learn about bears'},
    {'animal': 'Bird', 'subtext': 'Learn about birds'},
    {'animal': 'Bull', 'subtext': 'Learn about bulls'},
    {'animal': 'Camel', 'subtext': 'Learn about camels'},
    {'animal': 'Cat', 'subtext': 'Learn about cats'},
    {'animal': 'Chicken', 'subtext': 'Learn about chickens'},
    {'animal': 'Crab/Lobster', 'subtext': 'Learn about crabs/lobsters'},
    {
      'animal': 'Crocodile/Alligator',
      'subtext': 'Learn about crocodiles/alligators'
    },
    {'animal': 'Deer', 'subtext': 'Learn about deer'},
    {'animal': 'Dog', 'subtext': 'Learn about dogs'},
    {'animal': 'Dolphin', 'subtext': 'Learn about dolphins'},
    {'animal': 'Donkey', 'subtext': 'Learn about donkeys'},
    {'animal': 'Duck', 'subtext': 'Learn about ducks'},
    {'animal': 'Elephant', 'subtext': 'Learn about elephants'},
    {'animal': 'Fish', 'subtext': 'Learn about fish'},
    {'animal': 'Flamingo', 'subtext': 'Learn about flamingos'},
    {'animal': 'Fox', 'subtext': 'Learn about foxes'},
    {'animal': 'Frog', 'subtext': 'Learn about frogs'},
    {'animal': 'Giraffe', 'subtext': 'Learn about giraffes'},
    {'animal': 'Goose', 'subtext': 'Learn about geese'},
    {'animal': 'Goat', 'subtext': 'Learn about goats'},
    {'animal': 'Gorilla', 'subtext': 'Learn about gorillas'},
    {'animal': 'Hippo', 'subtext': 'Learn about hippos'},
    {'animal': 'Horse', 'subtext': 'Learn about horses'},
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
                          'Learn Animals',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/lesson-icon/img6.png',
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
                final lesson = lessonAnimals[index];
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
                        lesson['animal'],
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
              childCount: lessonAnimals.length,
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
