import 'package:adi_attach/ble/ble_connect_device.dart';
import 'package:adi_attach/ble/ble_scanner.dart';
import 'package:adi_attach/ui/device_detail.dart';
import 'package:cross_platform_ui_elements/cross_platform_ui_elements.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectButton extends StatelessWidget {
  const ConnectButton({
    Key? key,
    required this.device,
    this.isCheckSameDevice = false,
  }) : super(key: key);

  final DiscoveredDeviceRSSIDataPoints device;
  final bool isCheckSameDevice;
  final String connect = 'CONNECT';

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (context.read<BleScanner>().isScanning) {
          context.read<BleScanner>().stopScan();
        }

        context.read<BleConnectManager>().connect(context, device);

        if (isCheckSameDevice) {
        } else {
          await Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => DeviceDetailView(device: device),
            ),
          );
        }
      },
      child: Text(connect),
    );
  }
}

class DisconnectButton extends StatelessWidget {
  const DisconnectButton({
    Key? key,
    required this.device,
  }) : super(key: key);

  final DiscoveredDeviceRSSIDataPoints device;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<BleConnectManager>().disconnect(context, device);
        showCPSnackBar(context, CPText('Disconnected to device: ${device.id}'));
      },
      child: const Text(
        'DISCONNECT',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
