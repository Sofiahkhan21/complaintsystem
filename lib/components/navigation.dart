import 'package:flutter/material.dart';

class MyNavigation {
  static push(BuildContext context, Widget screen) {
    var route = MaterialPageRoute(builder: (context) => screen);
    Navigator.push(context, route);
  }

  static pushreplacement(BuildContext context, Widget screen) {
    var route = MaterialPageRoute(builder: (context) => screen);
    Navigator.pushReplacement(context, route);
  }

  static pushstatic(BuildContext context, Widget screen) {
    Navigator.pop(context);
    var route = MaterialPageRoute(builder: (context) => screen);
    Navigator.push(context, route);
  }

  static pushRemove(BuildContext context, Widget screen) {
    var newRoute = MaterialPageRoute(builder: (context) => screen);
    Navigator.pushAndRemoveUntil(context, newRoute, (route) => false);
  }
}
