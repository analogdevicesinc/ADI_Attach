import 'dart:io';

import 'package:adi_attach/ble/ble_scanner.dart';
import 'package:adi_attach/ui/request_connection_priority.dart';
import 'package:adi_attach/ui/request_mtu_size_dialog.dart';
import 'package:adi_attach/cross_platform_ui_elements/cross_platform_ui_elements.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ble/ble_device_manager.dart';

class DeviceDetailPopupMenuButton extends StatelessWidget {
  const DeviceDetailPopupMenuButton({
    Key? key,
    required this.device,
  }) : super(key: key);

  final DiscoveredDeviceRSSIDataPoints device;

  @override
  Widget build(BuildContext context, [bool mounted = true]) {
    return PopupMenuButton(
      itemBuilder: (context) {
        List<PopupMenuItem<int>> actions = [
          const PopupMenuItem<int>(
            value: 0,
            child: Text("Read all characteristics"),
          ),
        ];
        if (Platform.isIOS) {
        } else if (Platform.isAndroid) {
          actions.addAll(
            [
              const PopupMenuItem<int>(
                value: 1,
                child: Text("Request MTU size"),
              ),
              PopupMenuItem(
                child: RequestConnectionPriorityButton(device: device),
              ),
            ],
          );
        } else {
          return [];
        }
        return actions;
      },
      offset: const Offset(0, kToolbarHeight),
      onSelected: (value) async {
        if (value == 0) {
          await context.read<BleDeviceManager>().readAllCharacteristics(device);
          if (!mounted) return;
          showCPSnackBar(context, const CPText('All characteristics read'));
        }
        if (value == 1) {
          if (!mounted) return;
          await showWriteDialog(context);
        }
      },
    );
  }

  Future<String?> showWriteDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return MtuSizeSetAlertDialog(device: device);
      },
    );
  }
}
