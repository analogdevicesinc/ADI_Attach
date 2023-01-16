import 'dart:async';
import 'package:adi_attach/ble/ble_device_manager.dart';
import 'package:adi_attach/ble/ble_scanner.dart';
import 'package:adi_attach/cross_platform_ui_elements/cross_platform_ui_elements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';

class BleConnectManager extends ChangeNotifier {
  bool busy = false;

  BleConnectManager({
    required FlutterReactiveBle ble,
  }) : _ble = ble;

  final FlutterReactiveBle _ble;

  StreamSubscription<ConnectionStateUpdate>? _connection;
  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();

  void _setConnectionState(DeviceConnectionState state, BuildContext context) {
    SimpleLogger().fine(state);
    switch (state) {
      case DeviceConnectionState.disconnecting:
      case DeviceConnectionState.connecting:
        busy = true;
        break;
      case DeviceConnectionState.disconnected:
      case DeviceConnectionState.connected:
        busy = false;
        break;
    }
    _connectionState = state;
    notifyListeners();
  }

  DeviceConnectionState _connectionState = DeviceConnectionState.disconnected;
  DeviceConnectionState get connectionState => _connectionState;

  Future<void> connect(
      BuildContext context, DiscoveredDeviceRSSIDataPoints device) async {
    Provider.of<BleScanner>(context, listen: false).stopScan();
    Provider.of<BleDeviceManager>(context, listen: false)
        .clearDiscoveredServices();
    _setConnectionState(DeviceConnectionState.connecting, context);

    _connection = _ble
        .connectToDevice(
      id: device.id!,
      connectionTimeout: const Duration(seconds: 2),
    )
        .listen(
      (update) {
        SimpleLogger().info('${device.name} ${update.connectionState.name}');
        _deviceConnectionController.add(update);
        _setConnectionState(update.connectionState, context);
        SimpleLogger().finer(
            '.........My connection state........ $_connectionState ........');
        notifyListeners();
        if (_connectionState == DeviceConnectionState.connected) {
          SimpleLogger().finer('----connected-----');

          context.read<BleDeviceManager>().discoverServices(device);
        } else if (_connectionState == DeviceConnectionState.disconnected) {
          SimpleLogger().info('\n');
        }
        showCPSnackBar(
            context, CPText('Connection state: ${_connectionState.name}'));
        // _deviceConnectionController.add(update);
      },
      onError: (Object e) => SimpleLogger().finer(
          '++++++++++++++++Connecting to device ${device.name!} resulted in error $e'),
    );
  }

  Future<void> disconnect(
      BuildContext context, DiscoveredDeviceRSSIDataPoints device) async {
    try {
      SimpleLogger().finest('disconnecting to device: ${device.id}');
      await _connection?.cancel();
    } on Exception catch (e) {
      SimpleLogger().finest("Error disconnecting from a device: $e");
    } finally {
      SimpleLogger().finest('1111111----disconnecting to device: ${device.id}');
      _deviceConnectionController.add(
        ConnectionStateUpdate(
          deviceId: device.id!,
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      );
      SimpleLogger().finest('2222222----disconnecting to device: ${device.id}');
      _setConnectionState(DeviceConnectionState.disconnected, context);
      // context.read<BleDeviceManager>().clearDiscoveredServices();
    }
  }

  Future<void> requestConnectionPriority(DiscoveredDeviceRSSIDataPoints device,
      ConnectionPriority priority) async {
    try {
      await _ble.requestConnectionPriority(
          deviceId: device.id!, priority: priority);
    } catch (e) {
      SimpleLogger().finest("Error request connection priority: $e");
    }
  }

  Future<int> requestMtuSize({
    required DiscoveredDeviceRSSIDataPoints device,
    required int mtu,
  }) async {
    final responseMtu = await _ble.requestMtu(deviceId: device.id!, mtu: mtu);
    // SimpleLogger().finest('---response: $responseMtu');
    return responseMtu;
  }
}
