import 'package:flutter/material.dart';

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Duration reverseDuration;

  SlidePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
    this.reverseDuration = const Duration(milliseconds: 400),
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {


            var tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.ease));


            return FadeTransition(
             opacity: animation.drive(tween),
              child: child,
            );
          },
        );
}
