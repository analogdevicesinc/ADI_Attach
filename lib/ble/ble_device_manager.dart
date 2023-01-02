import 'dart:async';
import 'dart:io';

import 'package:adi_attach/ble/ble_scanner.dart';
import 'package:adi_attach/global/gatt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:simple_logger/simple_logger.dart';

class BleDeviceManager extends ChangeNotifier {
  bool busy = false;

  BleDeviceManager({
    required FlutterReactiveBle ble,
  }) : _ble = ble;

  final FlutterReactiveBle _ble;

  List<DiscoveredService> connectedDiscoveredServices = <DiscoveredService>[];
  Map<Uuid, List<int>> readValuesCharacteristicsByUuid = {};

  List<int>? getReadValue(Uuid characteristicId) {
    return readValuesCharacteristicsByUuid[characteristicId];
  }

  Future<void> discoverServices(DiscoveredDeviceRSSIDataPoints device) async {
    SimpleLogger().finest(device);
    busy = true;
    try {
      SimpleLogger().finer('Start discovering services for: $device');
      final result = await _ble.discoverServices(device.id!);
      SimpleLogger().finer('${Platform.operatingSystem} $result');
      SimpleLogger().finer('Discovering services finished');
      connectedDiscoveredServices = result;
      SimpleLogger().info('${device.name}\n'
          'Discovered Services:\n'
          '${connectedDiscoveredServices.map((e) => GATT.getServiceName(e.serviceId)).toList()}');
      busy = false;
      notifyListeners();
    } on Exception catch (e) {
      busy = false;
      notifyListeners();
      SimpleLogger().shout(
          '${device.name}\n' 'Error occured when discovering services: $e');
      rethrow;
    }
  }

  void clearDiscoveredServices() {
    connectedDiscoveredServices = [];
    readValuesCharacteristicsByUuid = {};
    notifyListeners();
  }

/*
  Future<List<int>> readCharacteristic(
      Uuid serviceId, Uuid characteristicId, String deviceId) async {
    try {
      final characteristic = QualifiedCharacteristic(
          serviceId: serviceId,
          characteristicId: characteristicId,
          deviceId: deviceId);
      final response = await _ble.readCharacteristic(characteristic);
      SimpleLogger().finer('=====Response: $response ======');
      return response;
    } on Exception catch (e, s) {
      SimpleLogger().finer(
        'Error occured when reading ${characteristicId} : $e',
      );
      SimpleLogger().finer(s);
      rethrow;
    }
  }
  */

  Future<void> readAllCharacteristics(
      DiscoveredDeviceRSSIDataPoints device) async {
    busy = true;
    notifyListeners();
    SimpleLogger().finer('--- reading all characteristics ---');
    for (var i = 0; i < connectedDiscoveredServices.length; i++) {
      for (var j = 0;
          j < connectedDiscoveredServices[i].characteristics.length;
          j++) {
        if (connectedDiscoveredServices[i].characteristics[j].isReadable) {
          await readCharacteristicByUuid(
              connectedDiscoveredServices[i].serviceId,
              connectedDiscoveredServices[i]
                  .characteristics[j]
                  .characteristicId,
              device);
        }
      }
    }
    busy = false;
    notifyListeners();
  }

  Future<void> readCharacteristicByUuid(Uuid serviceId, Uuid characteristicId,
      DiscoveredDeviceRSSIDataPoints device) async {
    busy = true;
    notifyListeners();
    try {
      final characteristic = QualifiedCharacteristic(
          serviceId: serviceId,
          characteristicId: characteristicId,
          deviceId: device.id!);
      final response = await _ble.readCharacteristic(characteristic);

      readValuesCharacteristicsByUuid[characteristicId] = response;

      SimpleLogger().info('${device.name}\n'
          'Read ${GATT.getServiceName(serviceId)} Service :\n'
          '${GATT.getCharacteristicName(characteristicId)} Characteristic :\n'
          '$response');

      SimpleLogger().finer('=====Response: $response ======');
      busy = false;
      notifyListeners();
    } on Exception catch (e, s) {
      SimpleLogger().shout(
        'Error occured when reading ${GATT.getServiceName(serviceId)} Service :\n'
        '${GATT.getCharacteristicName(characteristicId)} Characteristic\n'
        '$e',
      );
      SimpleLogger().fine(s);
      busy = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> writeCharacteristicWithResponse(
    Uuid serviceId,
    Uuid characteristicId,
    DiscoveredDeviceRSSIDataPoints device,
    List<int> value, {
    bool silent = false,
  }) async {
    busy = true;
    notifyListeners();
    try {
      SimpleLogger().finer('--Write with response sent value: $value');
      final characteristic = QualifiedCharacteristic(
          serviceId: serviceId,
          characteristicId: characteristicId,
          deviceId: device.id!);
      await _ble.writeCharacteristicWithResponse(characteristic, value: value);

      if (!silent) {
        SimpleLogger().info('${device.name}\n'
            'Wrote with response ${GATT.getServiceName(serviceId)} Service :\n'
            '${GATT.getCharacteristicName(characteristicId)} Characteristic :\n'
            '$value');
      }

      busy = false;
      notifyListeners();
    } on Exception catch (e, s) {
      SimpleLogger().shout(
        '${device.name}\n'
        'Error occured when writing with response ${GATT.getServiceName(serviceId)} Service :\n'
        '${GATT.getCharacteristicName(characteristicId)} Characteristic\n'
        '$e',
      );
      SimpleLogger().fine(s);
      busy = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> writeCharacteristicWithoutResponse(
    Uuid serviceId,
    Uuid characteristicId,
    DiscoveredDeviceRSSIDataPoints device,
    List<int> value, {
    bool silent = false,
  }) async {
    busy = true;
    notifyListeners();
    try {
      SimpleLogger().finest('--Write without response sent value: $value');
      final characteristic = QualifiedCharacteristic(
          serviceId: serviceId,
          characteristicId: characteristicId,
          deviceId: device.id!);
      await _ble.writeCharacteristicWithoutResponse(characteristic,
          value: value);

      if (!silent) {
        SimpleLogger().info('${device.name}\n'
            'Wrote without response ${GATT.getServiceName(serviceId)} Service :\n'
            '${GATT.getCharacteristicName(characteristicId)} Characteristic :\n'
            '$value');
      }

      busy = false;
      notifyListeners();
    } on Exception catch (e, s) {
      SimpleLogger().shout(
        '${device.name}\n'
        'Error occured when writing without response ${GATT.getServiceName(serviceId)} Service :\n'
        '${GATT.getCharacteristicName(characteristicId)} Characteristic\n'
        '$e',
      );
      SimpleLogger().fine(s);
      busy = false;
      notifyListeners();
      rethrow;
    }
  }

  Stream<List<int>> subScribeToCharacteristic(Uuid serviceId,
      Uuid characteristicId, DiscoveredDeviceRSSIDataPoints device) {
    busy = true;
    notifyListeners();
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceId,
        characteristicId: characteristicId,
        deviceId: device.id!);

    SimpleLogger().info('${device.name}\n'
        'Subscribing to ${GATT.getServiceName(serviceId)} :\n'
        '${GATT.getCharacteristicName(characteristicId)}');

    busy = false;
    notifyListeners();
    return _ble.subscribeToCharacteristic(characteristic);
  }
}
