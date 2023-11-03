// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sophon/configs/themes.dart';

Future<void> loadAllDependencies() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
}

// initialize snackbarkey to be reusable even outside context
final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

Widget universalPumper(Widget child, {NavigatorObserver? observer}) {
  return Builder(
    builder: (BuildContext context) {
      return MaterialApp(
        scaffoldMessengerKey: snackbarKey,
        home: child,
        theme: defaultTheme,
        navigatorObservers: observer != null
            ? <NavigatorObserver>[observer]
            : <NavigatorObserver>[],
      );
    },
  );
}
