import 'package:flutter/material.dart';

final Map<String, String> httpRequestHeaders = <String, String>{
  'Content-Type': 'application/json; charset=UTF-8',
};

/// Triggers a snackbar notification based on user parameters
///
/// [context] The current widget tree's `BuildContext`
///
/// [isSuccessful] Determines whether the snackbar will be green or red
///
/// [message] The message of the snackbar
void showSnackbar(
  BuildContext context, {
  required bool isSuccessful,
  required String message,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isSuccessful ? Colors.green : Colors.red,
      content: Text(
        message,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.white),
      ),
    ),
  );
}

FadeTransition fadeTransition(
  _,
  Animation<double> animation,
  __,
  Widget child,
) {
  const double begin = 0.0;
  const double end = 1.0;
  final Tween<double> tween = Tween<double>(begin: begin, end: end);
  final CurvedAnimation curvedAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOut,
  );
  return FadeTransition(
    opacity: tween.animate(curvedAnimation),
    child: child,
  );
}
