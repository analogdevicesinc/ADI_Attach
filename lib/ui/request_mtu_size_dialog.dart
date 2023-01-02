import 'package:adi_attach/ble/ble_scanner.dart';
import 'package:cross_platform_ui_elements/cross_platform_ui_elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';
import '../ble/ble_connect_device.dart';

class MtuSizeSetAlertDialog extends StatefulWidget {
  const MtuSizeSetAlertDialog({
    Key? key,
    required this.device,
  }) : super(key: key);

  final DiscoveredDeviceRSSIDataPoints device;

  @override
  State<MtuSizeSetAlertDialog> createState() => _MtuSizeSetAlertDialogState();
}

class _MtuSizeSetAlertDialogState extends State<MtuSizeSetAlertDialog> {
  TextEditingController textFieldController = TextEditingController();

  bool _isValidateMtuInput = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Maximum Transfer Unit'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                checkMtuInputValidate(value);
              },
              decoration: InputDecoration(
                  labelText: 'MTU value: <23 -517>',
                  errorText: getErrorMessage()),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              controller: textFieldController,
              onSubmitted: checkMtuInputValidate(textFieldController.text)
                  ? (value) {
                      sendMtuValue(context);
                    }
                  : null,
            ),
          ),
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
          onPressed: checkMtuInputValidate(textFieldController.text)
              ? () {
                  sendMtuValue(context);
                }
              : null,
          child: const Text('SEND'),
        ),
      ],
    );
  }

  String? getErrorMessage() {
    if (_isValidateMtuInput || textFieldController.text.isEmpty) {
      return null;
    }
    return 'Value must be between 23 and 517';
  }

  bool checkMtuInputValidate(String input) {
    if (input.isNotEmpty) {
      try {
        int value = int.parse(input);
        if (value >= 23 && value <= 517) {
          setState(() {
            _isValidateMtuInput = true;
          });
          return true;
        }
      } catch (e) {
        setState(() {
          _isValidateMtuInput = false;
        });
        return false;
      }
    }
    setState(() {
      _isValidateMtuInput = false;
    });
    return false;
  }

  Future<void> sendMtuValue(BuildContext context) async {
    int mtuSize = int.parse(textFieldController.text);
    SimpleLogger().fine('--sent mtu: $mtuSize');

    int responseMtu = await context
        .read<BleConnectManager>()
        .requestMtuSize(device: widget.device, mtu: mtuSize);

    SimpleLogger().fine('--response mtu: $responseMtu');
    if (!mounted) return;
    Navigator.pop(context);
    showCPSnackBar(context, CPText('Set MTU Size: $responseMtu'));
    textFieldController.clear();
  }

  void cancelButton(BuildContext context) {
    Navigator.pop(context);
    textFieldController.clear();
  }
}
