import 'package:adi_attach/adi_theme.dart';
import 'package:adi_attach/ble/ble_scanner.dart';
import 'package:adi_attach/global/gatt.dart';
import 'package:adi_attach/ui/app_stack_view.dart';
import 'package:adi_attach/ui/bluetooth_tile.dart';
import 'package:adi_attach/ui/rssi_plot.dart';
import 'package:cross_platform_ui_elements/elements/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:adi_attach/ble/ble_connect_device.dart';
import 'package:adi_attach/ble/ble_device_manager.dart';
import 'device_detail_popup_menu.dart';
import 'device_services_card.dart';

class DeviceDetailView extends StatefulWidget {
  const DeviceDetailView({Key? key, required this.device}) : super(key: key);

  final DiscoveredDeviceRSSIDataPoints device;

  @override
  State<DeviceDetailView> createState() => _DeviceDetailViewState();
}

class _DeviceDetailViewState extends State<DeviceDetailView> {
  @override
  Widget build(BuildContext context) {
    DeviceConnectionState connectState =
        context.watch<BleConnectManager>().connectionState;

    ElevatedButton? floatingActionButton;

    switch (connectState) {
      case DeviceConnectionState.connecting:
      case DeviceConnectionState.connected:
      case DeviceConnectionState.disconnecting:
        break;
      case DeviceConnectionState.disconnected:
        if (!Provider.of<BleScanner>(context).isScanning) {
          floatingActionButton = ElevatedButton(
            child: const CPText('Scan'),
            onPressed: () {
              context.read<BleScanner>().startScan(context);
            },
          );
        } else {
          floatingActionButton = ElevatedButton(
            child: const CPText('Connect'),
            onPressed: () async {
              if (context.read<BleScanner>().isScanning) {
                context.read<BleScanner>().stopScan();
              }
              context.read<BleConnectManager>().connect(context, widget.device);
            },
          );
        }
        break;
    }

    if (widget.device.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: CPText(
            'Device lost!\nPlease return to scan screen.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return AppStackView(
      showProgressIndicator: Provider.of<BleDeviceManager>(context).busy ||
          Provider.of<BleConnectManager>(context).busy,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Text(widget.device.name!),
          actions: connectState == DeviceConnectionState.connected
              ? [
                  PopupMenuButton(
                    tooltip: 'Legend',
                    icon: const Icon(Icons.info_rounded),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Row(
                            children: const [
                              Icon(Icons.download, color: c1A),
                              Expanded(
                                child: CPText('Read characteristic'),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: const [
                              Icon(Icons.upload_rounded, color: c1A),
                              Expanded(
                                child: CPText(
                                    'Write characteristic with no response'),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: const [
                              Icon(Icons.cached_rounded, color: c1A),
                              Expanded(
                                child: CPText(
                                    'Write characteristic with response'),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: const [
                              Icon(Icons.notifications_active_rounded,
                                  color: c1A),
                              Expanded(
                                child: CPText(
                                    'Subscribed to characteristic, unsubscribe'),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: const [
                              Icon(Icons.notifications_off_rounded, color: c1A),
                              Expanded(
                                child: CPText('Subscribe to characteristic'),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                  DeviceDetailPopupMenuButton(
                    device: widget.device,
                  ),
                ]
              : [],
        ),
        floatingActionButton: floatingActionButton,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(widget.device.id!,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                //const Text('Not Bonded'),
                //const SizedBox(width: 4),
                Text(
                  GATT.getCompanyID(widget.device.manufacturerData) ?? '',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SignalIndicatorIcon(
                        rssi: widget.device.rssi!,
                      ),
                      // SizedBox(width: 5),
                      Text(' ${widget.device.rssi} dBm'),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back_sharp, size: 12),
                    const Icon(Icons.arrow_forward_sharp, size: 12),
                    // SizedBox(width: 5),
                    Text('${widget.device.advertisingInterval ?? '-'} ms'),
                  ],
                ),
                Text('Connectable: ${widget.device.connecible}'),
                widget.device.txPowerLevel != null
                    ? Text('Tx Power Level: ${widget.device.txPowerLevel} dBm')
                    : const SizedBox(),
                Provider.of<BleScanner>(context).isScanning
                    ? SizedBox(
                        height: 250,
                        child: RSSIGraphWidget(
                          filteredDevices: Provider.of<BleScanner>(context)
                              .applyAllFilters()
                              .where(
                                  (element) => element.id == widget.device.id)
                              .toList(),
                        ),
                      )
                    : const SizedBox(),
                deviceServicesBuilder(
                    context,
                    context
                        .watch<BleDeviceManager>()
                        .connectedDiscoveredServices,
                    Provider.of<BleConnectManager>(context).connectionState ==
                        DeviceConnectionState.connected),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget deviceServicesBuilder(
      BuildContext context, List<DiscoveredService> services, bool connected) {
    return services.isNotEmpty && connected
        ? Column(
            children: services
                .map((e) =>
                    DeviceServicesCard(service: e, device: widget.device))
                .toList(),
          )
        : const SizedBox(
            height: 150,
            child: Center(
              child: Text(
                'Service not found\n' 'Please reconnect or refresh',
                textAlign: TextAlign.center,
              ),
            ),
          );
  }
}
