import 'package:flutter/material.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';

class TimeAndDays extends StatefulWidget {
  const TimeAndDays({Key? key}) : super(key: key);

  @override
  State<TimeAndDays> createState() => _TimeAndDaysState();
}

class _TimeAndDaysState extends State<TimeAndDays> {
  final List<Map<String, dynamic>> lessonTimeAndDays = [
    {'time': 'Time', 'subtext': 'Learn about time'},
    {'time': 'Second', 'subtext': 'Learn about seconds'},
    {'time': 'Minute', 'subtext': 'Learn about minutes'},
    {'time': 'Hour', 'subtext': 'Learn about hours'},
    {'time': 'Day', 'subtext': 'Learn about days'},
    {'time': 'Week', 'subtext': 'Learn about weeks'},
    {'time': 'Month', 'subtext': 'Learn about months'},
    {'time': 'Year', 'subtext': 'Learn about years'},
    {'time': 'Morning', 'subtext': 'Learn about mornings'},
    {'time': 'Afternoon', 'subtext': 'Learn about afternoons'},
    {'time': 'Evening', 'subtext': 'Learn about evenings'},
    {'time': 'Night', 'subtext': 'Learn about nights'},
    {'time': 'Monday', 'subtext': 'Learn about Mondays'},
    {'time': 'Tuesday', 'subtext': 'Learn about Tuesdays'},
    {'time': 'Wednesday', 'subtext': 'Learn about Wednesdays'},
    {'time': 'Thursday', 'subtext': 'Learn about Thursdays'},
    {'time': 'Friday', 'subtext': 'Learn about Fridays'},
    {'time': 'Saturday', 'subtext': 'Learn about Saturdays'},
    {'time': 'Sunday', 'subtext': 'Learn about Sundays'},
    {'time': 'January', 'subtext': 'Learn about January'},
    {'time': 'February', 'subtext': 'Learn about February'},
    {'time': 'March', 'subtext': 'Learn about March'},
    {'time': 'April', 'subtext': 'Learn about April'},
    {'time': 'May', 'subtext': 'Learn about May'},
    {'time': 'June', 'subtext': 'Learn about June'},
    {'time': 'July', 'subtext': 'Learn about July'},
    {'time': 'August', 'subtext': 'Learn about August'},
    {'time': 'September', 'subtext': 'Learn about September'},
    {'time': 'October', 'subtext': 'Learn about October'},
    {'time': 'November', 'subtext': 'Learn about November'},
    {'time': 'December', 'subtext': 'Learn about December'},
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
                          'Learn Time and Days',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/lesson-icon/img9.png',
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
                final lesson = lessonTimeAndDays[index];
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
                        lesson['time'],
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
              childCount: lessonTimeAndDays.length,
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

