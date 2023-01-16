import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as windows;

class CPDialog extends StatelessWidget {
  const CPDialog({
    Key? key,
    this.title,
    this.titlePadding = const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
    this.titleTextStyle,
    this.children,
    this.contentPadding = const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 16.0),
    this.backgroundColor,
    this.elevation,
    this.semanticLabel,
    this.clipBehavior = Clip.none,
    this.shape,
    this.alignment,
    this.content,
    this.actions = const <Widget>[],
    this.scrollController,
    this.actionScrollController,
    this.insetAnimationDuration = const Duration(milliseconds: 100),
    this.insetAnimationCurve = Curves.decelerate,
    this.contentDialogThemeData,
    this.contraints = windows.kDefaultContentDialogConstraints,
  }) : super(key: key);

  final Widget? title;
  final EdgeInsetsGeometry titlePadding;
  final TextStyle? titleTextStyle;
  final List<Widget>? children;
  final EdgeInsetsGeometry contentPadding;
  final Color? backgroundColor;
  final double? elevation;
  final String? semanticLabel;
  final Clip clipBehavior;
  final ShapeBorder? shape;
  final AlignmentGeometry? alignment;

  final Widget? content;
  final List<Widget> actions;
  final ScrollController? scrollController;
  final ScrollController? actionScrollController;
  final Duration insetAnimationDuration;
  final Curve insetAnimationCurve;

  final windows.ContentDialogThemeData? contentDialogThemeData;
  final BoxConstraints contraints;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      List<Widget> children = [];
      if (content != null) {
        children.add(content!);
      }
      children.addAll(actions);
      return SimpleDialog(
        title: title,
        backgroundColor: backgroundColor,
        shape: shape,
        alignment: alignment,
        elevation: elevation,
        contentPadding: contentPadding,
        clipBehavior: clipBehavior,
        semanticLabel: semanticLabel,
        titlePadding: titlePadding,
        titleTextStyle: titleTextStyle,
        children: children,
      );
    } else if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: title,
        content: content,
        actions: actions,
        actionScrollController: actionScrollController,
        insetAnimationCurve: insetAnimationCurve,
        insetAnimationDuration: insetAnimationDuration,
        scrollController: scrollController,
      );
    } else {
      return windows.ContentDialog(
        title: title,
        style: contentDialogThemeData,
        content: content,
        actions: actions,
        constraints: contraints,
      );
    }
  }
}

Future<dynamic> showCPDialog(
  BuildContext context, {
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor = Colors.black54,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  if (Platform.isAndroid) {
    return showDialog(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      routeSettings: routeSettings,
      useRootNavigator: useRootNavigator,
      useSafeArea: useSafeArea,
    );
  } else if (Platform.isIOS) {
    return showCupertinoDialog(
      context: context,
      builder: builder,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
    );
  } else {
    return windows.showDialog(
      context: context,
      builder: builder,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      routeSettings: routeSettings,
      useRootNavigator: useRootNavigator,
    );
  }
}
