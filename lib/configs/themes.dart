import 'package:flutter/material.dart';
import 'package:sophon/gen/fonts.gen.dart';

final ThemeData defaultTheme = _buildDefaultTheme();
const Color kPink = Color(0xFFE21E6A);
ThemeData _buildDefaultTheme() {
  return ThemeData(
    fontFamily: FontFamily.openSans,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPink,
      brightness: Brightness.dark,
    ),
    brightness: Brightness.dark,
  );
}

Color shimmerBase = kPink.withOpacity(0.2);
Color shimmerGlow = kPink.withOpacity(0.5);
