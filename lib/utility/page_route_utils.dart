import 'package:flutter/material.dart';

class PageRouteUtils {
  /// Push a new page with MaterialPageRoute
  static Future<T?> push<T extends Object?>(
      BuildContext context,
      Widget page,
      ) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Replace the current page with a new one (MaterialPageRoute)
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
      BuildContext context,
      Widget page, {
        TO? result,
      }) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
      result: result,
    );
  }

  /// Remove all routes and push a new page
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
      BuildContext context,
      Widget page, {
        bool Function(Route<dynamic>)? predicate,
      }) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      predicate ?? (route) => false,
    );
  }

  /// Push a page with a fade transition
  static Future<T?> pushWithFade<T extends Object?>(
      BuildContext context,
      Widget page, {
        Duration duration = const Duration(milliseconds: 300),
      }) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: duration,
      ),
    );
  }

  /// Push a page with a slide transition from the bottom
  static Future<T?> pushWithSlide<T extends Object?>(
      BuildContext context,
      Widget page, {
        Duration duration = const Duration(milliseconds: 300),
        Offset begin = const Offset(1, 0), // Slide from the left
      }) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeInOut;
          final tween = Tween(begin: begin, end: Offset.zero).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: duration,
      ),
    );
  }

  static Future<T?> pushWithZoom<T extends Object?>(
      BuildContext context,
      Widget page, {
        Duration duration = const Duration(milliseconds: 300),
      }) {
    return Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        transitionDuration: duration,
      ),
    );
  }
}
