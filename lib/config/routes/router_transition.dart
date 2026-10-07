import 'package:flutter/cupertino.dart';

Widget routerTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return CupertinoPageTransition(
    primaryRouteAnimation: animation,
    secondaryRouteAnimation: secondaryAnimation,
    linearTransition: true,
    child: child,
  );
}
