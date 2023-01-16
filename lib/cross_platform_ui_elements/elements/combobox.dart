import 'dart:io';
import 'package:flutter/material.dart';

class CPComboBox<T> extends StatelessWidget {
  const CPComboBox({
    Key? key,
    required this.items,
    this.value,
    this.hint,
    this.disabledHint,
    required this.onChanged,
    this.onTap,
    this.elevation = 8,
    this.style,
    this.underline,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 24.0,
    this.isDense = true,
    this.isExpanded = false,
    this.itemHeight,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.dropdownColor,
    this.menuMaxHeight,
    this.enableFeedback,
    this.alignment = AlignmentDirectional.centerStart,
    this.borderRadius,
    this.placeholder,
    this.comboboxColor,
  }) : super(key: key);

  final List<CPComboBoxItem<T>> items;
  final T? value;
  final Widget? placeholder;
  final Widget? disabledHint;
  final ValueChanged<T?>? onChanged;
  final VoidCallback? onTap;
  final int elevation;
  final TextStyle? style;
  final Widget? icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double iconSize;
  final bool isExpanded;
  final double? itemHeight;
  final Color? focusColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? comboboxColor;
  final Widget? hint;
  final Widget? underline;
  final bool isDense;
  final Color? dropdownColor;
  final double? menuMaxHeight;
  final bool? enableFeedback;
  final AlignmentGeometry alignment;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget dropdownButton = DropdownButton(
      items: items
          .map((e) => DropdownMenuItem(
                value: e.value,
                onTap: e.onTap,
                child: e.child,
              ))
          .toList(),
      value: value,
      autofocus: autofocus,
      focusNode: focusNode,
      focusColor: focusColor,
      itemHeight: itemHeight,
      isExpanded: isExpanded,
      iconSize: iconSize,
      iconEnabledColor: iconEnabledColor,
      iconDisabledColor: iconDisabledColor,
      icon: icon,
      style: style,
      elevation: elevation,
      onTap: onTap,
      onChanged: onChanged,
      disabledHint: disabledHint,
      alignment: alignment,
      borderRadius: borderRadius,
      dropdownColor: dropdownColor,
      enableFeedback: enableFeedback,
      hint: hint,
      isDense: isDense,
      menuMaxHeight: menuMaxHeight,
      underline: underline,
    );
    return Platform.isWindows
        ? /*windows.Combobox(
            items: items
                .map((e) => windows.ComboboxItem(
                      child: e.child,
                      value: e.value,
                      onTap: e.onTap,
                    ))
                .toList(),
            value: value,
            placeholder: placeholder,
            disabledHint: disabledHint,
            onChanged: onChanged,
            onTap: onTap,
            elevation: elevation,
            style: style,
            icon: icon,
            iconDisabledColor: iconDisabledColor,
            iconEnabledColor: iconEnabledColor,
            iconSize: iconSize,
            isExpanded: isExpanded,
            itemHeight: itemHeight,
            focusColor: focusColor,
            focusNode: focusNode,
            autofocus: autofocus,
            comboboxColor: comboboxColor,
          )*/
        Material(
            child: dropdownButton,
          )
        : dropdownButton;
  }
}

class CPComboBoxItem<T> {
  const CPComboBoxItem(
      {Key? key, required this.child, required this.value, this.onTap});

  final Widget child;
  final T value;
  final VoidCallback? onTap;
}
