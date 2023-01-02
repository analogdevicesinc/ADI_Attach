import 'package:adi_attach/ble/ble_connect_device.dart';
import 'package:adi_attach/ble/ble_scanner.dart';
import 'package:adi_attach/global/gatt.dart';
import 'package:adi_attach/ui/device_detail.dart';
import 'package:cross_platform_ui_elements/cross_platform_ui_elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import 'package:signal_strength_indicator/signal_strength_indicator.dart';
import 'package:simple_logger/simple_logger.dart';

class BleDevicesTile extends StatelessWidget {
  const BleDevicesTile({Key? key, required this.device}) : super(key: key);

  final DiscoveredDeviceRSSIDataPoints device;

  @override
  Widget build(BuildContext context) {
    SimpleLogger().finest('---render bluetooth  tile--');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: const CircleAvatar(
          child: Icon(
            Icons.bluetooth,
            color: Colors.white,
          ),
          // backgroundColor: Colors.cyan,
        ),
        title: Text(device.name!, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4.0,
          runSpacing: 4.0,
          children: [
            Text(device.id!, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              GATT.getCompanyID(device.manufacturerData) ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SignalIndicatorIcon(
                  rssi: device.rssi!,
                ),
                // SizedBox(width: 5),
                Text(' ${device.rssi} dBm'),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_sharp, size: 12),
                const Icon(Icons.arrow_forward_sharp, size: 12),
                // SizedBox(width: 5),
                Text('${device.advertisingInterval ?? '-'} ms'),
              ],
            ),
            Text('Connectable: ${device.connecible}'),
            device.txPowerLevel != null
                ? Text('Tx Power Level: ${device.txPowerLevel} dBm')
                : const SizedBox(),
          ],
        ),
        onTap: () {
          if (Provider.of<BleScanner>(context, listen: false).isScanning) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WillPopScope(
                  child: DeviceDetailView(device: device),
                  onWillPop: ([bool mounted = true]) async {
                    try {
                      if (Provider.of<BleConnectManager>(context, listen: false)
                              .connectionState ==
                          DeviceConnectionState.connected) {
                        await Provider.of<BleConnectManager>(context,
                                listen: false)
                            .disconnect(context, device);
                        if (mounted) {
                          Provider.of<BleScanner>(context, listen: false)
                              .startScan(context);
                        }
                      }
                    } catch (e, s) {
                      SimpleLogger().warning(e);
                      SimpleLogger().warning(s);
                    }
                    return true;
                  },
                ),
              ),
            );
          } else {
            showCPSnackBar(
              context,
              const CPText('Please start scan to use BLE features'),
            );
          }
        },
      ),
    );
  }
}

class SignalIndicatorIcon extends StatelessWidget {
  const SignalIndicatorIcon({
    Key? key,
    required this.rssi,
  }) : super(key: key);

  final int rssi;
  final int barCount = 4;
  // double get size => 50;

  double calculateSignalStrength(int rssi) {
    double rssiRangeMin = 26;
    double rssiRangeMax = 120;

    double minValueBar = 0;
    double maxValueBar = 120;
    double rangeBar = maxValueBar - minValueBar;

    double rssiToPositiveElement = (-rssi - rssiRangeMin);
    double rangeEffect =
        rssiToPositiveElement * (rangeBar / (rssiRangeMax - rssiRangeMin));
    double strength = (maxValueBar - rangeEffect) * 0.01;
    return strength;
  }

  @override
  Widget build(BuildContext context) {
    return SignalStrengthIndicator.bars(
      size: 16,
      value: calculateSignalStrength(rssi),
      barCount: barCount,
      activeColor: Colors.blue,
      inactiveColor: Colors.blue[100],
    );
  }
}

/*
class _MyCardBleTile extends StatelessWidget {
  const _MyCardBleTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: const CircleAvatar(
              child: Icon(
                Icons.bluetooth,
                color: Colors.white,
              ),
              backgroundColor: Colors.blue,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Max123',
                  style: Theme.of(context).textTheme.headline5,
                ),
                const Text('00:18'),
                Wrap(
                  children: [
                    const Text('Not Bonded'),
                    SizedBox(width: 30),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.signal_cellular_4_bar),
                        const SizedBox(width: 5),
                        const Text('-52 dBm'),
                      ],
                    ),
                    SizedBox(width: 15),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.compare_arrows),
                        const SizedBox(width: 5),
                        const Text('186 ms'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('CONNECT'),
            ),
          )
        ],
      ),
    );
  }
}
*/
