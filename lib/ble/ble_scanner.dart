import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cross_platform_ui_elements/cross_platform_ui_elements.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:app_settings/app_settings.dart';
import 'package:simple_logger/simple_logger.dart';

typedef DeviceSortingFunction = int Function(
    DiscoveredDeviceRSSIDataPoints a, DiscoveredDeviceRSSIDataPoints b);

class BleScanner extends ChangeNotifier {
  Timer? sortTimer;
  Timer? updateTimer;

  BleScanner({
    required FlutterReactiveBle ble,
  }) : _ble = ble;

  final FlutterReactiveBle _ble;

  bool isScanning = false;
  StreamSubscription? _subscription;

  String searchNameFilterValue = '';
  int rssiFilterValue = 120;

  SortFor _sortFor = SortFor.rssi;
  SortMode _sortMode = SortMode.ascending;

  SortFor get sortFor => _sortFor;
  set sortFor(SortFor val) {
    _sortFor = val;
    notifyListeners();
  }

  SortMode get sortMode => _sortMode;
  set sortMode(SortMode val) {
    _sortMode = val;
    sortDevices();
  }

  void toggleSortMode() {
    _sortMode = SortMode.values[(SortMode.values.indexOf(_sortMode) + 1) % 2];
    sortDevices();
  }

  void clearDevicesList() {
    //_devices.clear();
    notifyListeners();
  }

  int get totalDevicesDiscovered => _devices.length;
  int get filteredDeviceCount => applyAllFilters().length;

  Future<bool> _requestPermission(BuildContext context,
      [bool mounted = true]) async {
    if (Platform.isIOS) {
      if (!await Permission.bluetooth.request().isGranted) {
        showNoPermissionDialog(
            context,
            'Need Bluetooth permission to operate. '
                'Bluetooth permission is not granted. '
                'Please go to privacy settings and grant Bluetooth permission.',
            'Open Bluetooth Permissions',
            () => AppSettings.openBluetoothSettings());
        return false;
      }
      return true;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      if (int.parse(androidInfo.version.release?.split('.').first ?? '0') <
          12) {
        if (!await Permission.locationWhenInUse.request().isGranted &&
            mounted) {
          showNoPermissionDialog(
              context,
              'Need Location When in Use permission to operate. '
                  'Location When in Use permission is not granted. '
                  'Please go to privacy settings and grant Location When in Use permission.',
              'Open App Permissions',
              () => AppSettings.openAppSettings());
          return false;
        }
        return true;
      } else {
        if ((!await Permission.bluetoothConnect.request().isGranted ||
                !await Permission.bluetoothScan.request().isGranted) &&
            mounted) {
          showNoPermissionDialog(
              context,
              'Need Bluetooth permission to operate. '
                  'Bluetooth permission is not granted. '
                  'Please go to privacy settings and grant Bluetooth permission.',
              'Open App Permissions',
              () => AppSettings.openAppSettings());
          return false;
        }
        return true;
      }
    } else {
      SimpleLogger().fine('Unsupported platform');
      return false;
    }
  }

  DeviceSortingFunction sort(SortFor sortFor, SortMode sortMode) {
    switch (sortFor) {
      case SortFor.rssi:
        return (a, b) {
          if (a.rssi == null && b.rssi == null) {
            if (a.name == null && b.name == null) {
              return 0;
            } else if (a.name == null) {
              return 1;
            } else {
              return -1;
            }
          } else if (a.rssi == null) {
            return 1;
          } else if (b.rssi == null) {
            return -1;
          } else if (a.rssi!.compareTo(b.rssi!) == 0) {
            return a.name!.toUpperCase().compareTo(b.name!.toUpperCase());
          } else {
            switch (sortMode) {
              case SortMode.descending:
                return a.rssi!.compareTo(b.rssi!);
              case SortMode.ascending:
                return b.rssi!.compareTo(a.rssi!);
            }
          }
        };
      case SortFor.name:
        return (a, b) {
          if (a.name == null && b.name == null) {
            return 0;
          } else if (a.name == null) {
            return 1;
          } else if (b.name == null) {
            return -1;
          } else if (a.name!.toUpperCase().compareTo(b.name!.toUpperCase()) ==
              0) {
            return a.rssi!.compareTo(b.rssi!);
          }
          switch (sortMode) {
            case SortMode.ascending:
              return a.name!.toUpperCase().compareTo(b.name!.toUpperCase());
            case SortMode.descending:
              return b.name!.toUpperCase().compareTo(a.name!.toUpperCase());
          }
        };
      case SortFor.advertisingInterval:
        return (a, b) {
          if (a.advertisingInterval == null && b.advertisingInterval == null) {
            if (a.name == null && b.name == null) {
              return 0;
            } else if (a.name == null) {
              return 1;
            } else {
              return -1;
            }
          } else if (a.advertisingInterval == null) {
            return 1;
          } else if (b.advertisingInterval == null) {
            return -1;
          } else if (a.rssi!.compareTo(b.rssi!) == 0) {
            return a.name!.compareTo(b.name!);
          } else {
            switch (sortMode) {
              case SortMode.ascending:
                return a.advertisingInterval!.compareTo(b.advertisingInterval!);
              case SortMode.descending:
                return b.advertisingInterval!.compareTo(a.advertisingInterval!);
            }
          }
        };
    }
  }

  void sortDevices() {
    SimpleLogger().finest(
        '# of points: ${_devices.map((e) => e._dataPoints.length).reduce((value, element) => value + element)}');
    _devices.sort(sort(sortFor, sortMode));
    notifyListeners();
  }

  void startScan(BuildContext context) async {
    if (await _requestPermission(context)) {
      sortTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        for (var element in _devices) {
          element.computeAdvertisingInterval();
        }
        sortDevices();
      });
      updateTimer = Timer.periodic(
        const Duration(milliseconds: 50),
        (timer) {
          notifyListeners();
        },
      );
      SimpleLogger().finest('--------Scan Started---------');

      isScanning = true;
      //clearDevicesList();
      _subscription = _ble.scanForDevices(
          withServices: [], scanMode: ScanMode.lowLatency).listen(
        (device) {
          if (device.rssi != 127) {
            final knownDeviceIndex =
                _devices.indexWhere((d) => d.id == device.id);
            if (knownDeviceIndex >= 0) {
              try {
                _devices[knownDeviceIndex].addDataPoint(device);
              } catch (e, s) {
                SimpleLogger().shout(e);
                SimpleLogger().shout(s);
              }
            } else {
              SimpleLogger().finest(device.manufacturerData);
              SimpleLogger().finest(device.serviceData);
              SimpleLogger().finest(device.serviceUuids);

              _devices.add(DiscoveredDeviceRSSIDataPoints(device: device));
              SimpleLogger().finest('---------------');
              SimpleLogger().finest(_devices.length);
              SimpleLogger().finest('---------------');
              SimpleLogger().finest(_devices);
              SimpleLogger().finest('---------------');
            }
          } else {
            SimpleLogger().finest(device);
          }
          for (var element in _devices) {
            element.removeOlderPoints(DateTime.now().millisecondsSinceEpoch -
                _oldestPointAllowed * 1000);
          }
          _devices.removeWhere((element) => element.isEmpty);
          //notifyListeners();
        },
        onError: (er) {
          isScanning = false;
          notifyListeners();
          SimpleLogger().fine(er);
        },
        onDone: () {
          stopScan();
          notifyListeners();
        },
        cancelOnError: true,
      );
    }
  }

  Future<void> showNoPermissionDialog(
    BuildContext context,
    String explanation,
    String buttonText,
    Future<void> Function() openSettings,
  ) async =>
      showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) => AlertDialog(
          title: const Text('No Bluetooth Permission '),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(explanation),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: openSettings,
              child: Text(buttonText),
            ),
          ],
        ),
      );

  Future<void> stopScan() async {
    updateTimer?.cancel();
    sortTimer?.cancel();
    SimpleLogger().finest('++++++++Trying Scsan Stopped+++++++++++++');
    if (isScanning) {
      SimpleLogger().finest('++++++++Scan Stopped+++++++++++++');
      isScanning = false;
      await _subscription?.cancel();
      _subscription = null;
      notifyListeners();
    }
  }

  Future<void> refreshScan(BuildContext context, [bool mounted = true]) async {
    await stopScan();
    if (!mounted) return;
    reset();
    startScan(context);
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      showCPSnackBar(context, const CPText('Rotate device for RSSI chart'));
    }
  }

  List<DiscoveredDeviceRSSIDataPoints> applyAllFilters() {
    try {
      return _devices.where((element) {
        final deviceName = element.name!.toLowerCase();
        final input = searchNameFilterValue.toLowerCase();

        int rssiFilter = rssiFilterValue.round();
        rssiFilter *= -1;

        if (element.rssi! > rssiFilter &&
            deviceName.contains(input) &&
            !(deviceName == '' && _hideUnnamed) &&
            !(_hideUnconnectable && !element.connecible)) {
          return true;
        }
        return false;
      }).toList();
    } catch (e, s) {
      SimpleLogger().warning(e);
      SimpleLogger().warning(s);
      return [];
    }
  }

  bool _hideUnconnectable = true;
  bool get hideUnconnectable => _hideUnconnectable;
  set hideUnconnectable(bool val) {
    _hideUnconnectable = val;
    notifyListeners();
  }

  bool _hideUnnamed = true;

  bool get hideUnnamed => _hideUnnamed;

  void toggleHideUnnamed(bool value) {
    _hideUnnamed = value;
    notifyListeners();
  }

  void setSearchNameFilterValue(String value) {
    searchNameFilterValue = value;
    notifyListeners();
  }

  void setrssiFilterValue(double value) {
    rssiFilterValue = value.round();
    notifyListeners();
  }

  final int _oldestPointAllowed = 19;
  final List<DiscoveredDeviceRSSIDataPoints> _devices = [];

  void reset() {
    _devices.clear();
  }

  void toggleFocus(String id) {
    int index = _devices.indexWhere((element) => element.id == id);
    if (index >= 0) {
      _devices[index].focus = !_devices[index].focus;
      notifyListeners();
    }
  }
}

class DiscoveredDeviceRSSIDataPoints {
  int? advertisingInterval;
  final List<DiscoveredDeviceWithTimestamp> _dataPoints = [];
  late Color _color;
  bool focus = false;

  String? get name => _dataPoints.isNotEmpty ? _dataPoints.last.name : null;
  String? get id => _dataPoints.isNotEmpty ? _dataPoints.last.id : null;
  int? get rssi =>
      _dataPoints
          .map((e) => e.rssi)
          .reduce((value, element) => value + element) ~/
      _dataPoints.length;
  bool get isEmpty => _dataPoints.isEmpty;
  Uint8List get manufacturerData => _dataPoints.last.manufacturerData;
  Color get color => _color;
  int? get txPowerLevel => _dataPoints.last.getTxPowerLevel;
  bool get connecible => _dataPoints.last.isConnectable;

  DiscoveredDeviceRSSIDataPoints({DiscoveredDevice? device}) {
    _color = Color.fromARGB(200, Random().nextInt(200), Random().nextInt(200),
        Random().nextInt(200));
    if (device != null) {
      addDataPoint(device);
    }
  }

  void addDataPoint(DiscoveredDevice device) {
    _dataPoints.add(DiscoveredDeviceWithTimestamp(device, DateTime.now()));
  }

  LineChartBarData getLineChartBarData() => LineChartBarData(
        spots: _dataPoints
            .map(
              (e) => FlSpot(
                (e.timestamp.millisecondsSinceEpoch -
                        DateTime.now().millisecondsSinceEpoch) *
                    0.001,
                e.rssi.toDouble(),
              ),
            )
            .toList(),
        dotData: FlDotData(show: _dataPoints.length < 2),
        color: _color,
      );

  void removeOlderPoints(int millisecondsSinceEpoch) {
    _dataPoints.removeWhere((element) =>
        element.timestamp.millisecondsSinceEpoch < millisecondsSinceEpoch);
  }

  void computeAdvertisingInterval() {
    if (_dataPoints.length > 1) {
      int sum = 0;
      for (var i = 1; i < _dataPoints.length; i++) {
        sum += _dataPoints[i].timestamp.millisecondsSinceEpoch -
            _dataPoints[i - 1].timestamp.millisecondsSinceEpoch;
      }
      advertisingInterval = sum ~/ (_dataPoints.length - 1);
    } else {
      advertisingInterval = null;
    }
  }
}

class DiscoveredDeviceWithTimestamp extends DiscoveredDevice {
  final DateTime timestamp;

  DiscoveredDeviceWithTimestamp(DiscoveredDevice device, this.timestamp)
      : super(
          id: device.id,
          manufacturerData: device.manufacturerData,
          name: device.name,
          rssi: device.rssi,
          serviceData: device.serviceData,
          serviceUuids: device.serviceUuids,
          txPowerLevel: device.txPowerLevel,
          isConnectable: device.isConnectable,
        );
}

enum SortFor {
  rssi,
  name,
  advertisingInterval,
}

enum SortMode {
  ascending,
  descending,
}
