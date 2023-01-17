import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart' as windows;
import 'package:flutter/material.dart';

class CPButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final ButtonStyle? style;
  final windows.ButtonStyle? windowsStyle;
  final FocusNode? focusNode;
  final bool autofocus;
  final Widget child;
  final String? tooltipMessage;

  const CPButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.windowsStyle,
    this.tooltipMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      windows.Button button = windows.Button(
        onPressed: onPressed,
        onLongPress: onLongPress,
        focusNode: focusNode,
        autofocus: autofocus,
        style: windowsStyle,
        child: Center(
          child: child,
        ),
      );
      return tooltipMessage == null
          ? button
          : windows.Tooltip(
              message: tooltipMessage,
              child: button,
            );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHover: onHover,
        onFocusChange: onFocusChange,
        style: style,
        focusNode: focusNode,
        autofocus: autofocus,
        child: Center(
          child: child,
        ),
      );
    }
  }
}
