import 'package:flutter/material.dart';

const Color kViolet = Color(0xFF532b88);

ThemeData buildDefaultTheme(BuildContext context) {
  final ThemeData base = ThemeData.light();

  return base.copyWith(
    textTheme: _buildDefaultTextTheme(base.textTheme),
    // scaffoldBackgroundColor: Colors.black,
    primaryColor: kViolet,
    colorScheme: base.colorScheme.copyWith(
      primary: kViolet,
      // error: kRed,
    ),
  );
}

TextTheme _buildDefaultTextTheme(TextTheme base) {
  return base.copyWith(
    headline6: base.headline6?.copyWith(fontFamily: 'Poppins'),
    headline5: base.headline5?.copyWith(fontFamily: 'Poppins'),
    headline4: base.headline4?.copyWith(fontFamily: 'Poppins'),
    headline3: base.headline3?.copyWith(fontFamily: 'Poppins'),
    headline2: base.headline2?.copyWith(fontFamily: 'Poppins'),
    headline1: base.headline1?.copyWith(fontFamily: 'Poppins'),
    subtitle2: base.subtitle2?.copyWith(fontFamily: 'Poppins'),
    subtitle1: base.subtitle1?.copyWith(fontFamily: 'Poppins'),
    bodyText2: base.bodyText2?.copyWith(fontFamily: 'Poppins'),
    bodyText1: base.bodyText1?.copyWith(fontFamily: 'Poppins'),
    caption: base.caption?.copyWith(fontFamily: 'Poppins'),
    button: base.button?.copyWith(fontFamily: 'Poppins'),
    overline: base.overline?.copyWith(fontFamily: 'Poppins'),
  );
}


// const List<Color> orangeGradient = <Color>[
//   kYellow,
//   Color(0xffF68A01),
// ];
