import 'package:adi_attach/ble/ble_scanner.dart';
import 'package:adi_attach/global/gatt.dart';
import 'package:adi_attach/ui/otas_dialog.dart';
import 'package:cross_platform_ui_elements/cross_platform_ui_elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'characteristic_card.dart';

class DeviceServicesCard extends StatefulWidget {
  const DeviceServicesCard(
      {Key? key, required this.service, required this.device})
      : super(key: key);

  final DiscoveredService service;
  final DiscoveredDeviceRSSIDataPoints device;

  @override
  State<DeviceServicesCard> createState() => _DeviceServicesCardState();
}

class _DeviceServicesCardState extends State<DeviceServicesCard> {
  @override
  Widget build(BuildContext context) {
    String? serviceName = GATT.getServiceName(widget.service.serviceId);

    return Card(
      child: ExpansionTile(
        maintainState: true,
        title: Text(
          serviceName ?? 'Custom Service',
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UUID: ${widget.service.serviceId}'.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall),
            Text(
                '# of Characteristics: ${widget.service.characteristics.length}'),
            _wdxService(serviceName),
          ],
        ),
        children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: widget.service.characteristics.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return CharacteristicCard(
                  characteristic: widget.service.characteristics[index],
                  device: widget.device,
                );
              }),
        ],
      ),
    );
  }

  Widget _wdxService(String? serviceName) {
    if (serviceName == null || serviceName != 'WDX Service') {
      return const SizedBox();
    } else {
      return Row(
        children: [
          CPButton(
            child: const CPText('Program'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OTASDialog(
                          device: widget.device,
                        ),
                    fullscreenDialog: true),
              );
            },
          ),
        ],
      );
    }
  }
}
