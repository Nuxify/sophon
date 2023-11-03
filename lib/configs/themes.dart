import 'package:flutter/material.dart';
import 'package:sophon/gen/fonts.gen.dart';

const Color kPink = Color(0xFFfe6796);
const Color kPink2 = Color(0xFFfe8cb3);

final ThemeData defaultTheme = _buildDefaultTheme();

ThemeData _buildDefaultTheme() {
  final ThemeData base = ThemeData.light();
  return ThemeData(
    fontFamily: FontFamily.poppins,
    primaryColor: kPink,
    colorScheme: base.colorScheme.copyWith(
      secondary: const Color(0xFF004e92),
    ),
  );
}

const List<Color> flirtGradient = <Color>[
  Color(0xFFfdbad3),
  Color(0xFFfe8cb3),
  Color(0xFFfe8cb3),
];
