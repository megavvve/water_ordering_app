import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
void SetPageWithBack(BuildContext context, String routeName) {
  Navigator.pushNamed(context, routeName);
}

// ignore: non_constant_identifier_names
void SetPageWithoutBack(dynamic context, String routeName) {
  Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
}
