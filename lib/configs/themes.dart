import 'package:flutter/material.dart';

const Color kViolet = Color(0xFF532b88);
const Color kDarkViolet = Color(0xFF2F184B);
const Color kLightViolet = Color(0xFFC8B1E4);
const Color kPink = Color(0xFFfe6796);

ThemeData buildDefaultTheme(BuildContext context) {
  final ThemeData base = ThemeData.dark();

  return base.copyWith(
    textTheme: _buildDefaultTextTheme(base.textTheme),
    primaryColor: kPink,
    colorScheme: base.colorScheme.copyWith(
      primary: kPink,
      // error: kRed,
    ),
  );
}

TextTheme _buildDefaultTextTheme(TextTheme base) {
  return base.copyWith(
    headline6: base.headline6?.copyWith(fontFamily: 'Raleway'),
    headline5: base.headline5?.copyWith(fontFamily: 'Raleway'),
    headline4: base.headline4?.copyWith(fontFamily: 'Raleway'),
    headline3: base.headline3?.copyWith(fontFamily: 'Raleway'),
    headline2: base.headline2?.copyWith(fontFamily: 'Raleway'),
    headline1: base.headline1?.copyWith(fontFamily: 'Raleway'),
    subtitle2: base.subtitle2?.copyWith(fontFamily: 'Raleway'),
    subtitle1: base.subtitle1?.copyWith(fontFamily: 'Raleway'),
    bodyText2: base.bodyText2?.copyWith(fontFamily: 'Raleway'),
    bodyText1: base.bodyText1?.copyWith(fontFamily: 'Raleway'),
    caption: base.caption?.copyWith(fontFamily: 'Raleway'),
    button: base.button?.copyWith(fontFamily: 'Raleway'),
    overline: base.overline?.copyWith(fontFamily: 'Raleway'),
  );
}

const List<Color> violetGradient = <Color>[
  Color(0xFF532B88),
  Color(0xFFF4EFFA),
];

const List<Color> flirtGradient = <Color>[
  Color(0xFFfe8cb3),
  Color(0xFFfe6796),
  Color(0xFFfe5464),
];
