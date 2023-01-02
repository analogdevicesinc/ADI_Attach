import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_logger/simple_logger.dart';

class WriteCharacteristicScreenManager extends ChangeNotifier {
  // WriteCharacteristicScreenManager();

  WriteCharacteristicTypes writeInputType = WriteCharacteristicTypes.byte;
  bool isInputValidate = false;

  void setIsInputValidate(bool setValue) {
    isInputValidate = setValue;
    notifyListeners();
  }

  void setWriteType(WriteCharacteristicTypes newValue) {
    writeInputType = newValue;
    notifyListeners();
  }

  InputDecoration getInputDecoration(String value) {
    String hintText = writeInputType.getInputDecorationHintText();
    String? errorText;
    checkInputForDecoration(value);
    if (isInputValidate || value.isEmpty) {
      errorText = null;
    } else {
      errorText = writeInputType.getErrorMessage();
    }

    return InputDecoration(
        contentPadding: const EdgeInsets.all(0.0),
        labelText: hintText,
        errorText: errorText);
  }

  TextInputType getKeyboardType() {
    return writeInputType.getKeyboardType();
  }

  List<TextInputFormatter>? getInputFormatter() {
    return writeInputType.getInputFormatter();
  }

  void checkInputValidate(String value) {
    setIsInputValidate(writeInputType.checkInputValidate(value));
  }

  bool isCurrentInputValidate(String value) {
    isInputValidate = writeInputType.checkInputValidate(value);
    return isInputValidate;
  }

  void checkInputForDecoration(String value) {
    isInputValidate = writeInputType.checkInputValidate(value);
  }

  List<int> parseInput(String value) {
    return writeInputType.parseValue(value);
  }
}

enum WriteCharacteristicTypes { byte, byteArray, hex, text }

extension WriteCharacteristicTypesExtension on WriteCharacteristicTypes {
  bool checkInputValidate(String value) {
    switch (this) {
      case WriteCharacteristicTypes.byte:
        return true;

      case WriteCharacteristicTypes.byteArray:
        return true;

      case WriteCharacteristicTypes.hex:
        return true;

      case WriteCharacteristicTypes.text:
        return true;

      default:
        return true;
    }
  }

  List<int> parseValue(String value) {
    List<int> parsedValue = [];
    switch (this) {
      case WriteCharacteristicTypes.byte:
        try {
          parsedValue.add(int.parse(value));
        } catch (e) {
          SimpleLogger().fine('Value can not parse: $value $e');
        }
        break;

      case WriteCharacteristicTypes.byteArray:
        List<String> splittedString = value.split(',');
        for (String elem in splittedString) {
          try {
            parsedValue.add(int.parse(elem));
          } catch (er) {
            SimpleLogger().fine('Value can not parse: $elem $er');
          }
        }
        break;

      case WriteCharacteristicTypes.hex:
        List<String> splittedString = value.split(',');
        for (String elem in splittedString) {
          try {
            int intValue = int.parse(elem, radix: 16);
            parsedValue.add(intValue);
          } catch (er) {
            SimpleLogger().fine('Value can not parse: $elem $er');
          }
        }
        break;

      case WriteCharacteristicTypes.text:
        try {
          parsedValue = value.codeUnits;
        } catch (er) {
          SimpleLogger().fine('Value can not parse: $value $er');
        }
        break;
    }
    SimpleLogger().fine('----Parsed List: $parsedValue');
    return parsedValue;
  }

  List<TextInputFormatter>? getInputFormatter() {
    switch (this) {
      case WriteCharacteristicTypes.byte:
        return <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];

      case WriteCharacteristicTypes.byteArray:
        return <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp("[0-9,]"))
        ];

      case WriteCharacteristicTypes.hex:
        return <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z,]"))
        ];

      case WriteCharacteristicTypes.text:
        return <TextInputFormatter>[];
      default:
        return <TextInputFormatter>[];
    }
  }

  TextInputType getKeyboardType() {
    switch (this) {
      case WriteCharacteristicTypes.byte:
        return TextInputType.number;

      case WriteCharacteristicTypes.byteArray:
        return TextInputType.text;

      case WriteCharacteristicTypes.hex:
        return TextInputType.text;

      case WriteCharacteristicTypes.text:
        return TextInputType.text;

      default:
        return TextInputType.text;
    }
  }

  String getInputDecorationHintText() {
    String hintText = 'default';
    if (this == WriteCharacteristicTypes.byte) {
      hintText = 'byte';
    } else if (this == WriteCharacteristicTypes.byteArray) {
      hintText = 'use ,';
    } else if (this == WriteCharacteristicTypes.hex) {
      hintText = '0x';
    } else if (this == WriteCharacteristicTypes.text) {
      hintText = 'ASCII';
    }
    return hintText;
  }

  String getErrorMessage() {
    switch (this) {
      case WriteCharacteristicTypes.byte:
        return 'Invalid Byte Input';
      case WriteCharacteristicTypes.byteArray:
        return 'Invalid Byte Array Input';
      case WriteCharacteristicTypes.hex:
        return 'Invalid Hex Input';
      case WriteCharacteristicTypes.text:
        return 'Invalid Text Input';
      default:
        return 'Invalid Input';
    }
  }

  String get name {
    switch (this) {
      case WriteCharacteristicTypes.byte:
        return 'Byte';
      case WriteCharacteristicTypes.byteArray:
        return 'Byte Array';
      case WriteCharacteristicTypes.hex:
        return 'Hex';
      case WriteCharacteristicTypes.text:
        return 'Text';
      default:
        return 'Text';
    }
  }
}
