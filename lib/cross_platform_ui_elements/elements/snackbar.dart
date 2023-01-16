import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart' as windows;
import 'package:flutter/material.dart';

void showCPSnackBar(BuildContext context, Widget content,
    {Duration? duration, Color? backgroundColor}) {
  duration ??= const Duration(seconds: 2);
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    windows.showSnackbar(
      context,
      windows.Snackbar(content: windows.Flexible(child: content)),
      duration: duration,
    );
  } else {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: content,
      duration: duration,
      backgroundColor: backgroundColor,
    ));
  }
}

void dismissCPSnackBar(BuildContext context) {
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
  } else {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }
}
