import 'package:flutter/material.dart';

double screenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double screenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

showSnackBar(String content, BuildContext context,Color? color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: color,duration: Duration(seconds: 1),
    content: Text(content),
  ));
}
