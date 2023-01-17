import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as windows;

class CPText extends StatelessWidget {
  final String data;
  final InlineSpan? textSpan;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;

  const CPText(
    this.data, {
    Key? key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textSpan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isWindows
        ? windows.Text(data,
            key: key,
            style: style,
            strutStyle: strutStyle,
            textAlign: textAlign,
            textDirection: textDirection,
            locale: locale,
            softWrap: softWrap,
            overflow: overflow,
            textScaleFactor: textScaleFactor,
            maxLines: maxLines,
            semanticsLabel: semanticsLabel,
            textWidthBasis: textWidthBasis)
        : Text(data,
            key: key,
            style: style,
            strutStyle: strutStyle,
            textAlign: textAlign,
            textDirection: textDirection,
            locale: locale,
            softWrap: softWrap,
            overflow: overflow,
            textScaleFactor: textScaleFactor,
            maxLines: maxLines,
            semanticsLabel: semanticsLabel,
            textWidthBasis: textWidthBasis);
  }
}
