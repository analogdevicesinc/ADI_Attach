import 'package:adi_attach/ble/ble_scanner.dart';
import 'package:adi_attach/ui/write_characteristic/write_characterisctic_screen_manager.dart';
import 'package:cross_platform_ui_elements/cross_platform_ui_elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import '../../ble/ble_device_manager.dart';
import '../characteristic_card.dart';

class WriteCharacteristicScreen extends StatefulWidget {
  const WriteCharacteristicScreen(
      {Key? key,
      required this.characteristic,
      required this.device,
      required this.writeType})
      : super(key: key);

  final DiscoveredCharacteristic characteristic;
  final DiscoveredDeviceRSSIDataPoints device;
  final WriteType writeType;

  @override
  State<WriteCharacteristicScreen> createState() =>
      _WriteCharacteristicScreenState();
}

class _WriteCharacteristicScreenState extends State<WriteCharacteristicScreen> {
  late TextEditingController textFieldController;

  @override
  void initState() {
    super.initState();
    textFieldController = TextEditingController();
  }

  @override
  void dispose() {
    textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WriteCharacteristicScreenManager>(
      create: (_) => WriteCharacteristicScreenManager(),
      builder: (context, child) {
        return AlertDialog(
          title: const Text('Write value'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: textFieldController,
                  onChanged: (value) {
                    context
                        .read<WriteCharacteristicScreenManager>()
                        .checkInputValidate(value);
                  },
                  decoration: context
                      .watch<WriteCharacteristicScreenManager>()
                      .getInputDecoration(textFieldController.text),
                  inputFormatters: context
                      .watch<WriteCharacteristicScreenManager>()
                      .getInputFormatter(),
                  keyboardType: context
                      .watch<WriteCharacteristicScreenManager>()
                      .getKeyboardType(),
                  onSubmitted: context
                          .read<WriteCharacteristicScreenManager>()
                          .isCurrentInputValidate(textFieldController.text)
                      ? (value) {
                          sendValue(context, widget.writeType);
                        }
                      : null,
                ),
              ),
              const Expanded(
                  child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: WriteTypeDropDown(),
              ))
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                cancelButton(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: context
                      .read<WriteCharacteristicScreenManager>()
                      .isCurrentInputValidate(textFieldController.text)
                  ? () {
                      sendValue(context, widget.writeType);
                    }
                  : null,
              child: const Text('SEND'),
            ),
          ],
        );
      },
    );
  }

  void sendValue(BuildContext context, WriteType writeType) {
    List<int> inputValue = context
        .read<WriteCharacteristicScreenManager>()
        .parseInput(textFieldController.text);
    if (writeType == WriteType.withResponse) {
      writeCharacteristicWithResponse(inputValue);
    } else if (writeType == WriteType.withoutResponse) {
      writeCharacteristicWithoutResponse(inputValue);
    }

    Navigator.pop(context);
    showCPSnackBar(
        context,
        CPText(
            'Write characteristic: ${widget.characteristic.characteristicId}'));
    textFieldController.clear();
  }

  void cancelButton(BuildContext context) {
    Navigator.pop(context);
    textFieldController.clear();
  }

  void writeCharacteristicWithResponse(List<int> value) async {
    await context.read<BleDeviceManager>().writeCharacteristicWithResponse(
        widget.characteristic.serviceId,
        widget.characteristic.characteristicId,
        widget.device,
        value);
  }

  void writeCharacteristicWithoutResponse(List<int> value) async {
    await context.read<BleDeviceManager>().writeCharacteristicWithoutResponse(
        widget.characteristic.serviceId,
        widget.characteristic.characteristicId,
        widget.device,
        value);
  }
}

class WriteTypeDropDown extends StatefulWidget {
  const WriteTypeDropDown({Key? key}) : super(key: key);

  @override
  State<WriteTypeDropDown> createState() => _WriteTypeDropDownState();
}

class _WriteTypeDropDownState extends State<WriteTypeDropDown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<WriteCharacteristicTypes>(
      value: context.watch<WriteCharacteristicScreenManager>().writeInputType,
      decoration: const InputDecoration(contentPadding: EdgeInsets.all(0.0)),
      icon: const Icon(Icons.keyboard_arrow_down),
      items:
          WriteCharacteristicTypes.values.map((WriteCharacteristicTypes items) {
        return DropdownMenuItem(
          value: items,
          child: Text(items.name),
        );
      }).toList(),
      onChanged: (WriteCharacteristicTypes? newValue) {
        context
            .read<WriteCharacteristicScreenManager>()
            .setWriteType(newValue!);
      },
    );
  }
}
