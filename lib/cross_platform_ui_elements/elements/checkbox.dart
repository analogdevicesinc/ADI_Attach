import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart' as windows;
import 'package:flutter/material.dart';

class CPCheckBox extends StatelessWidget {
  const CPCheckBox({
    Key? key,
    this.checked,
    this.onChanged,
    this.desktopStyle,
    this.content,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    this.mouseCursor,
    this.activeColor,
    this.fillColor,
    this.checkColor,
    this.tristate = false,
    this.materialTapTargetSize,
    this.visualDensity,
    this.focusColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.shape,
    this.side,
    this.tooltipMessage,
  }) : super(key: key);
  final bool? checked;
  final ValueChanged<bool?>? onChanged;
  final windows.CheckboxThemeData? desktopStyle;
  final Widget? content;
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  final MouseCursor? mouseCursor;
  final Color? activeColor;
  final MaterialStateProperty<Color?>? fillColor;
  final Color? checkColor;
  final bool tristate;
  final MaterialTapTargetSize? materialTapTargetSize;
  final VisualDensity? visualDensity;
  final Color? focusColor;
  final Color? hoverColor;
  final MaterialStateProperty<Color?>? overlayColor;
  final double? splashRadius;
  final OutlinedBorder? shape;
  final BorderSide? side;
  static const double width = 18.0;

  final String? tooltipMessage;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      windows.Checkbox checkBox = windows.Checkbox(
          checked: checked,
          onChanged: onChanged,
          style: desktopStyle,
          content: content,
          semanticLabel: semanticLabel,
          focusNode: focusNode,
          autofocus: autofocus);
      return tooltipMessage == null
          ? checkBox
          : windows.Tooltip(
              message: tooltipMessage,
              child: checkBox,
            );
    } else {
      return Checkbox(
        value: checked,
        tristate: tristate,
        onChanged: onChanged,
        mouseCursor: mouseCursor,
        activeColor: activeColor,
        fillColor: fillColor,
        checkColor: checkColor,
        focusColor: focusColor,
        hoverColor: hoverColor,
        overlayColor: overlayColor,
        splashRadius: splashRadius,
        materialTapTargetSize: materialTapTargetSize,
        visualDensity: visualDensity,
        focusNode: focusNode,
        autofocus: autofocus,
        shape: shape,
        side: side,
      );
    }
  }
}
