import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart' as windows;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CPTextBox extends StatelessWidget {
  const CPTextBox({
    Key? key,
    this.controller,
    this.focusNode,
    this.padding = windows.kTextBoxPadding,
    this.clipBehavior = Clip.antiAlias,
    this.placeholder,
    this.placeholderStyle,
    this.header,
    this.headerStyle,
    this.outsidePrefix,
    this.prefix,
    this.prefixMode = windows.OverlayVisibilityMode.always,
    this.outsidePrefixMode = windows.OverlayVisibilityMode.always,
    this.outsideSuffix,
    this.suffix,
    this.suffixMode = windows.OverlayVisibilityMode.always,
    this.outsideSuffixMode = windows.OverlayVisibilityMode.always,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.decoration,
    this.foregroundDecoration,
    this.highlightColor,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.toolbarOptions,
    this.textAlignVertical,
    this.readOnly = false,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = false,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = false,
    this.maxLines = 1,
    this.minLines,
    this.minHeight,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.showCursor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.scrollPhysics,
    this.scrollController,
    this.onTap,
    this.autofillHints,
    this.restorationId,
    this.iconButtonThemeData,
    this.textDirection,
    this.onAppPrivateCommand,
    this.selectionControls,
    this.mouseCursor,
    this.buildCounter,
    this.enableIMEPersonalizedLearning = true,
  }) : super(key: key);
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;
  final String? placeholder;
  final TextStyle? placeholderStyle;
  final String? header;
  final TextStyle? headerStyle;
  final Widget? outsidePrefix;
  final Widget? prefix;
  final windows.OverlayVisibilityMode prefixMode;
  final windows.OverlayVisibilityMode outsidePrefixMode;
  final Widget? outsideSuffix;
  final Widget? suffix;
  final windows.OverlayVisibilityMode suffixMode;
  final windows.OverlayVisibilityMode outsideSuffixMode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final BoxDecoration? decoration;
  final BoxDecoration? foregroundDecoration;
  final Color? highlightColor;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final ToolbarOptions? toolbarOptions;
  final TextAlignVertical? textAlignVertical;
  final bool readOnly;
  final bool autofocus;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final double? minHeight;
  final bool expands;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final bool? showCursor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool enableInteractiveSelection;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;

  bool get selectionEnabled => enableInteractiveSelection;
  final GestureTapCallback? onTap;
  final Iterable<String>? autofillHints;
  final String? restorationId;
  final windows.ButtonThemeData? iconButtonThemeData;
  final TextDirection? textDirection;
  static const int noMaxLength = -1;
  final AppPrivateCommandCallback? onAppPrivateCommand;
  final TextSelectionControls? selectionControls;
  final MouseCursor? mouseCursor;
  final InputCounterWidgetBuilder? buildCounter;
  final bool enableIMEPersonalizedLearning;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return windows.TextBox(
        controller: controller,
        focusNode: focusNode,
        padding: padding,
        clipBehavior: clipBehavior,
        placeholder: placeholder,
        placeholderStyle: placeholderStyle,
        prefix: prefix,
        outsidePrefix: outsidePrefix,
        prefixMode: prefixMode,
        outsidePrefixMode: outsidePrefixMode,
        suffix: suffix,
        outsideSuffix: outsideSuffix,
        suffixMode: suffixMode,
        outsideSuffixMode: outsideSuffixMode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: style ??
            windows.FluentTheme.of(context)
                .typography
                .body
                ?.copyWith(fontFamily: 'Consolas', fontSize: 16),
        strutStyle: strutStyle,
        textAlign: textAlign,
        textAlignVertical: textAlignVertical,
        readOnly: readOnly,
        toolbarOptions: toolbarOptions,
        showCursor: showCursor,
        autofocus: autofocus,
        obscuringCharacter: obscuringCharacter,
        obscureText: obscureText,
        autocorrect: autocorrect,
        smartDashesType: smartDashesType,
        smartQuotesType: smartQuotesType,
        enableSuggestions: enableSuggestions,
        maxLines: maxLines,
        minLines: minLines,
        minHeight: minHeight,
        expands: expands,
        maxLength: maxLength,
        maxLengthEnforcement: maxLengthEnforcement,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        onSubmitted: onSubmitted,
        inputFormatters: inputFormatters,
        enabled: enabled,
        cursorWidth: cursorWidth,
        cursorHeight: cursorHeight,
        cursorRadius: cursorRadius,
        cursorColor: cursorColor,
        keyboardAppearance: keyboardAppearance,
        scrollPadding: scrollPadding,
        enableInteractiveSelection: enableInteractiveSelection,
        onTap: onTap,
        scrollController: scrollController,
        scrollPhysics: scrollPhysics,
        autofillHints: autofillHints,
        restorationId: restorationId,
        textCapitalization: textCapitalization,
        header: header,
        headerStyle: headerStyle,
        iconButtonThemeData: iconButtonThemeData,
        decoration: decoration,
        foregroundDecoration: foregroundDecoration,
        highlightColor: highlightColor,
      );
    } else {
      return TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textAlignVertical: textAlignVertical,
        textDirection: textDirection,
        readOnly: readOnly,
        toolbarOptions: toolbarOptions,
        showCursor: showCursor,
        autofocus: autofocus,
        obscuringCharacter: obscuringCharacter,
        obscureText: obscureText,
        autocorrect: autocorrect,
        smartDashesType: smartDashesType,
        smartQuotesType: smartQuotesType,
        enableSuggestions: enableSuggestions,
        maxLines: maxLines,
        minLines: minLines,
        expands: expands,
        maxLength: maxLength,
        maxLengthEnforcement: maxLengthEnforcement,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        onSubmitted: onSubmitted,
        onAppPrivateCommand: onAppPrivateCommand,
        inputFormatters: inputFormatters,
        enabled: enabled,
        cursorWidth: cursorWidth,
        cursorHeight: cursorHeight,
        cursorRadius: cursorRadius,
        cursorColor: cursorColor,
        keyboardAppearance: keyboardAppearance,
        scrollPadding: scrollPadding,
        enableInteractiveSelection: enableInteractiveSelection,
        selectionControls: selectionControls,
        onTap: onTap,
        mouseCursor: mouseCursor,
        buildCounter: buildCounter,
        scrollController: scrollController,
        scrollPhysics: scrollPhysics,
        autofillHints: autofillHints,
        clipBehavior: clipBehavior,
        restorationId: restorationId,
        enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
      );
    }
  }
}
