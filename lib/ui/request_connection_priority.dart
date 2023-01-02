import 'package:adi_attach/ble/ble_connect_device.dart';
import 'package:adi_attach/ble/ble_scanner.dart';
import 'package:cross_platform_ui_elements/cross_platform_ui_elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class RequestConnectionPriorityButton extends StatelessWidget {
  const RequestConnectionPriorityButton({
    Key? key,
    required this.device,
  }) : super(key: key);

  final DiscoveredDeviceRSSIDataPoints device;

  @override
  Widget build(BuildContext context, [bool mounted = true]) {
    return PopupMenuButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Request Connection Priority"),
          Icon(Icons.arrow_right, color: Colors.black),
        ],
      ),
      itemBuilder: (_) {
        return [
          const PopupMenuItem(
            value: 10,
            child: Text("HIGH"),
          ),
          const PopupMenuItem(
            value: 20,
            child: Text("BALANCED"),
          ),
          const PopupMenuItem(
            value: 30,
            child: Text("LOW POWER"),
          )
        ];
      },
      onSelected: (value) async {
        ConnectionPriority priority = ConnectionPriority.balanced;
        switch (value) {
          case 10:
            priority = ConnectionPriority.highPerformance;
            break;
          case 20:
            priority = ConnectionPriority.balanced;
            break;
          case 30:
            priority = ConnectionPriority.lowPower;
            break;
        }
        await context
            .read<BleConnectManager>()
            .requestConnectionPriority(device, priority);
        if (!mounted) return;
        showCPSnackBar(
            context, CPText('Connection Priority: ${priority.name}'));
      },
    );
  }
}
