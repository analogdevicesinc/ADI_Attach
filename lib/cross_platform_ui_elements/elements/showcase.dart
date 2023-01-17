import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class CPShowcase extends StatelessWidget {
  const CPShowcase({
    Key? key,
    required this.showcaseKey,
    required this.child,
    required this.title,
    required this.description,
    this.overlayPadding = const EdgeInsets.all(5),
    this.border,
    this.borderRadius,
    this.overlayColor,
  }) : super(key: key);

  final GlobalKey showcaseKey;
  final Widget child;
  final String title;
  final String description;
  final EdgeInsets overlayPadding;
  final ShapeBorder? border;
  final BorderRadius? borderRadius;
  final Color? overlayColor;

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: showcaseKey,
      title: title,
      description: description,
      disableAnimation: false,
      shapeBorder: border,
      radius: borderRadius,
      showArrow: true,
      //tipBorderRadius: BorderRadius.all(Radius.circular(8)),
      overlayPadding: overlayPadding,
      animationDuration: const Duration(milliseconds: 500),
      overlayColor: overlayColor ?? Colors.black45,
      blurValue: 2,
      child: child,
    );
  }
}
