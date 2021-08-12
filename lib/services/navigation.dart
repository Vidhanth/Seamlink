import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum Transitions {
  HORIZONTAL,
  VERTICAL,
  SCALED,
}

extension on Transitions {
  SharedAxisTransitionType get getTransition {
    if (this == Transitions.SCALED) return SharedAxisTransitionType.scaled;
    if (this == Transitions.HORIZONTAL)
      return SharedAxisTransitionType.horizontal;
    return SharedAxisTransitionType.vertical;
  }
}

class Navigate {
  static to({
    required Widget page,
    Transitions? transition,
    Duration? duration,
  }) {
    Navigator.push(
      Get.context!,
      SharedAxisPageRoute(
        page: page,
        transitionType: transition?.getTransition,
        duration: duration,
      ),
    );
  }

  static replace({
    required Widget page,
    Transitions? transition,
    Duration? duration,
  }) {
    Navigator.pushReplacement(
      Get.context!,
      SharedAxisPageRoute(
        page: page,
        transitionType: transition?.getTransition,
        duration: duration,
      ),
    );
  }
}

class SharedAxisPageRoute extends PageRouteBuilder {
  SharedAxisPageRoute({
    required Widget page,
    SharedAxisTransitionType? transitionType,
    Duration? duration,
  }) : super(
          transitionDuration: duration ?? 500.milliseconds,
          pageBuilder: (
            BuildContext context,
            Animation<double> primaryAnimation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> primaryAnimation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return SharedAxisTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              transitionType:
                  transitionType ?? SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        );
}
