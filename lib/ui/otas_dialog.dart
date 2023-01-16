import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:adi_attach/ble/ble_connect_device.dart';
import 'package:adi_attach/ble/ble_device_manager.dart';
import 'package:adi_attach/ble/ble_scanner.dart';
import 'package:adi_attach/global/crc32_wrapper.dart';
import 'package:adi_attach/global/gatt.dart';
import 'package:adi_attach/global/logger.dart';
import 'package:adi_attach/ui/app_stack_view.dart';
import 'package:adi_attach/cross_platform_ui_elements/cross_platform_ui_elements.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:async/async.dart';

class OTASDialog extends StatefulWidget {
  const OTASDialog({super.key, required this.device});

  final DiscoveredDeviceRSSIDataPoints device;

  @override
  State<OTASDialog> createState() => _OTASDialogState();
}

class _OTASDialogState extends State<OTASDialog> {
  final TextEditingController _filePickerController = TextEditingController();
  double _progress = 0;
  File? _file;
  List<int> _expectedEvent = [];
  bool _busy = false;
  Map<Uuid, StreamSubscription> _streams = {};
  late DeviceConnectionState _connectionState;
  final CancelableCompleter _completer = CancelableCompleter(onCancel: () {});

  @override
  Widget build(BuildContext context) {
    _connectionState = context.watch<BleConnectManager>().connectionState;
    if (_connectionState == DeviceConnectionState.disconnected) {
      _cancelOtas();
    }
    return AppStackView(
      showProgressIndicator: Provider.of<BleDeviceManager>(context).busy ||
          Provider.of<BleConnectManager>(context).busy ||
          _busy,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          key: const Key('share_button'),
          child: const Icon(Icons.share),
          onPressed: () => Share.share(
              Provider.of<LogState>(context, listen: false).appLog,
              subject: 'ADI Attach Mobile App Log '
                  '${DateTime.now().toString().replaceAll('T', ' ').split('.').first}'),
        ),
        appBar: AppBar(
          title: const CPText('OTAS'),
        ),
        body: SafeArea(
          child: _connectionState == DeviceConnectionState.connected
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                            hintText: 'Click to pick a program file.'),
                        readOnly: true,
                        controller: _filePickerController,
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(allowMultiple: false);
                          if (result != null) {
                            if (result.names.single!.endsWith('.bin')) {
                              // ignore: unused_local_variable
                              _file = File(result.files.single.path!);
                              setState(() {
                                _filePickerController.text =
                                    result.names.single!;
                              });
                            } else {
                              if (mounted) {
                                showCPSnackBar(context,
                                    const CPText('Please pick a .bin file.'));
                              }
                            }
                          } else {
                            // User canceled the picker
                          }
                        },
                      ),
                    ),
                    /*CPButton(
                      child: const CPText('Pick File'),
                      onPressed: () {
                        if (_filePickerController.text == '') {
                          showCPSnackBar(
                              context, const CPText('Please pick a file first'));
                        } else {
                          showCPDialog(
                            context,
                            builder: (context) => CPDialog(
                              title: const CPText('Programming device'),
                              content: Column(children: const [
                                CircularProgressIndicator(),
                                CPText('This is a placeholder.')
                              ]),
                            ),
                          );
                        }
                      },
                    ),*/
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _filePickerController.text == ''
                            ? const SizedBox()
                            : CPButton(
                                onPressed: () async {
                                  _startOtas();
                                },
                                child: const CPText('Load'),
                              ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(value: _progress),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CPText('%${(_progress * 100).toStringAsFixed(1)}'),
                      ],
                    ),
                    const Expanded(
                      child: LogTab(),
                    ),
                  ],
                )
              : Center(
                  child: CPText(
                    'Device lost!\nPlease return to scan screen.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _startOtas() async {
    _completer.complete(Future.value(_otas()));
  }

  void _cancelOtas() async {
    await _completer.operation.cancel();
    _unsubscribeFromChars();
  }

  Future<void> _otas() async {
    try {
      List<DiscoveredService> services = _discoverServices();
      _streams = _subscribeToChars(services);
      if (mounted) {
        if (!await _fileDiscovery()) {
          return _failed();
        }
        setState(
          () {
            _progress = 0.1;
          },
        );
      }
      if (mounted) {
        await _sendHeader();
        setState(
          () {
            _progress += 0.1;
          },
        );
      }
      if (mounted) {
        if (!await _sendPutReq()) {
          return _failed();
        }
        setState(
          () {
            _progress += 0.1;
          },
        );
      }
      if (mounted) {
        if (!await _sendFile()) {
          return _failed();
        }
        setState(
          () {
            _progress = 0.8;
          },
        );
      }
      if (mounted) {
        if (!await _sendVerifyFileReq()) {
          return _failed();
        }
        setState(
          () {
            _progress += 0.1;
          },
        );
      }
      if (mounted) {
        await _sendResetReq();
        setState(
          () {
            _progress += 0.1;
          },
        );
      }
      _success();
      _unsubscribeFromChars();
    } catch (e) {
      _failed();
    }

    return;
  }

  Future<void> _success() async {
    return showCPDialog(context,
        builder: (context) => const CPDialog(
              content: CPText('File successfully loaded'),
            ));
  }

  List<DiscoveredService> _discoverServices() {
    return Provider.of<BleDeviceManager>(context, listen: false)
        .connectedDiscoveredServices;
  }

  Map<Uuid, StreamSubscription> _subscribeToChars(
      List<DiscoveredService> serviceList) {
    return Map.fromEntries(
      serviceList.expand(
        (element) => element.characteristics.map(
          (e) {
            return MapEntry(
              e.characteristicId,
              Provider.of<BleDeviceManager>(context, listen: false)
                  .subScribeToCharacteristic(
                      element.serviceId, e.characteristicId, widget.device)
                  .listen(
                (event) {
                  SimpleLogger().info('New bytes from\n'
                      'Characteristic: ${GATT.getServiceName(e.serviceId)}\n'
                      'Characteristic: ${GATT.getCharacteristicName(e.characteristicId)}'
                      '\nBytes: $event');
                  if (GATT.getCharacteristicName(e.characteristicId) ==
                      'WDX File Transfer Control Characteristic') {
                    setState(() {
                      _busy = !listEquals(event, _expectedEvent);
                    });
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _fileDiscovery() async {
    setState(() => _busy = true);
    try {
      _expectedEvent = [10, 0, 0];
      int WDX_FLIST_HANLD = 0;
      int WDX_FLIST_FORMAT_VER = 1;
      int WDX_FLIST_HDR_SIZE = 7;
      int WDX_FLIST_RECORD_SIZE = 40;
      int DATC_WDXC_MAX_FILES = 4;
      List<int> WDX_FTC_OP_GET_REQ = [0x01];
      List<int> WDX_FILE_HANDLE = [0x00, 0x00];
      List<int> WDX_FILE_OFFSET = [0x00, 0x00, 0x00, 0x00];
      List<int> maxFileRecordLength = Uint8List(4)
        ..buffer.asByteData().setInt32(
            0,
            WDX_FLIST_RECORD_SIZE * DATC_WDXC_MAX_FILES + WDX_FLIST_HDR_SIZE,
            Endian.little);
      List<int> WDX_FILE_TYPE = [0x00];
      List<int> rawBytes = WDX_FTC_OP_GET_REQ +
          WDX_FILE_HANDLE +
          WDX_FILE_OFFSET +
          maxFileRecordLength +
          WDX_FILE_TYPE;
      SimpleLogger().info('File Discovery');
      SimpleLogger().fine('Bytes sent $rawBytes');
      await Provider.of<BleDeviceManager>(context, listen: false)
          .writeCharacteristicWithoutResponse(
        _discoverServices()
            .singleWhere((element) =>
                GATT.getServiceName(element.serviceId) == 'WDX Service')
            .serviceId,
        _discoverServices()
            .singleWhere((element) =>
                GATT.getServiceName(element.serviceId) == 'WDX Service')
            .characteristicIds
            .singleWhere((element) =>
                GATT.getCharacteristicName(element) ==
                'WDX File Transfer Control Characteristic'),
        widget.device,
        rawBytes,
      );
    } catch (e) {}

    return _waitResponse(1000);
  }

  Future<void> _sendHeader() async {
    setState(() => _busy = true);
    SimpleLogger().fine(_filePickerController.text);
    try {
      int crc32 = Crc32Wrapper().crc32(await _file!.readAsBytes());
      SimpleLogger().fine('CRC32 0x${crc32.toRadixString(16)}');
      List<int> crc32r = Uint8List(4)
        ..buffer.asByteData().setInt32(0, crc32, Endian.little);
      SimpleLogger().fine('CRC32 LE ${crc32r.map((e) => e.toRadixString(16))}');
      SimpleLogger().fine(
          'CRC32 BE ${(Uint8List(4)..buffer.asByteData().setInt32(0, crc32, Endian.big)).map((e) => e.toRadixString(16))}');
      List<int> fileLen = Uint8List(4)
        ..buffer.asByteData().setInt32(0, await _file!.length(), Endian.little);
      List<int> rawBytes = fileLen + crc32r;

      if (mounted) {
        SimpleLogger().info('Sending Header');
        SimpleLogger().fine('Bytes sent $rawBytes');
        await Provider.of<BleDeviceManager>(context, listen: false)
            .writeCharacteristicWithoutResponse(
          _discoverServices()
              .singleWhere((element) =>
                  GATT.getServiceName(element.serviceId) ==
                  'ARM Propietary Data Service')
              .serviceId,
          _discoverServices()
              .singleWhere((element) =>
                  GATT.getServiceName(element.serviceId) ==
                  'ARM Propietary Data Service')
              .characteristicIds
              .singleWhere((element) =>
                  GATT.getCharacteristicName(element) ==
                  'ARM Propietary Data Characteristic'),
          widget.device,
          rawBytes,
        );
      }
    } catch (e) {
      SimpleLogger().fine('Error occurred while sending header');
    }
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _busy = false);
  }

  Future<bool> _sendPutReq() async {
    setState(() => _busy = true);
    try {
      _expectedEvent = [4, 1, 0, 0, 0, 48, 0];
      List<int> WDX_FTC_OP_PUT_REQ = [0x03];
      List<int> WDX_FILE_OFFSET = [0x00, 0x00, 0x00, 0x00];
      List<int> WDX_FILE_TYPE = [0x00];
      List<int> fileLen = Uint8List(4)
        ..buffer.asByteData().setInt32(0, await _file!.length(), Endian.little);
      List<int> rawBytes = WDX_FTC_OP_PUT_REQ +
          [0x01, 0x00] +
          WDX_FILE_OFFSET +
          fileLen +
          fileLen +
          WDX_FILE_TYPE;
      if (mounted) {
        SimpleLogger().info('Sending Put Request');
        SimpleLogger().fine('Bytes sent $rawBytes');
        await Provider.of<BleDeviceManager>(context, listen: false)
            .writeCharacteristicWithoutResponse(
          _discoverServices()
              .singleWhere((element) =>
                  GATT.getServiceName(element.serviceId) == 'WDX Service')
              .serviceId,
          _discoverServices()
              .singleWhere((element) =>
                  GATT.getServiceName(element.serviceId) == 'WDX Service')
              .characteristicIds
              .singleWhere((element) =>
                  GATT.getCharacteristicName(element) ==
                  'WDX File Transfer Control Characteristic'),
          widget.device,
          rawBytes,
        );
      }
    } catch (e) {}

    return _waitResponse(2500);
  }

  Future<bool> _sendFile() async {
    setState(() => _busy = true);
    _expectedEvent = [10, 1, 0];
    try {
      Uint8List bytes = await _file!.readAsBytes();

      SimpleLogger().info('Sending File');
      int packetSize = await _requestMtuForFileTransfer();
      await _setConnectionPriority();
      SimpleLogger().info('Packet Size: $packetSize');
      int loopCount = (bytes.length / packetSize.toDouble()).ceil();
      for (int i = 0; i < loopCount; i++) {
        if (mounted) {
          if (_connectionState == DeviceConnectionState.connected) {
            int startAddr = i*packetSize;
            int endAddr = min(startAddr + packetSize, bytes.length);

            await writeChar(startAddr, bytes.sublist(startAddr, endAddr)).timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                SimpleLogger().fine('Timeout while write operation');
              },
            );
          } else {
            SimpleLogger().fine('End sending due disconnect');
            break;
          }
          if (mounted) {
            setState(
              () {
                _progress += 0.5 / loopCount;
              },
            );
          }
          await Future.delayed(const Duration(milliseconds: 25));
        }
      }
    } catch (e) {
      SimpleLogger().fine('Error occurred while sending file');
    }
    return _waitResponse(5000);
  }

  Future<void> writeChar(int addr, Uint8List bytes) async {
    List<int> packet = [];
    // add address, little endian
    packet.add((addr>>0) & 0xff);
    packet.add((addr>>8) & 0xff);
    packet.add((addr>>16) & 0xff);
    packet.add((addr>>24) & 0xff);
    // add data
    packet.addAll(bytes);
    
    await Provider.of<BleDeviceManager>(context, listen: false)
        .writeCharacteristicWithoutResponse(
      _discoverServices()
          .singleWhere((element) =>
              GATT.getServiceName(element.serviceId) == 'WDX Service')
          .serviceId,
      _discoverServices()
          .singleWhere((element) =>
              GATT.getServiceName(element.serviceId) == 'WDX Service')
          .characteristicIds
          .singleWhere((element) =>
              GATT.getCharacteristicName(element) ==
              'WDX File Transfer Data Characteristic'),
      widget.device,
      packet,
      silent: true,
    );
  }

  Future<bool> _sendVerifyFileReq() async {
    setState(() => _busy = true);
    try {
      _expectedEvent = [8, 1, 0, 0];
      SimpleLogger().info('Sending Verify File Request');
      SimpleLogger().fine('Bytes sent ${[7, 1, 0]}');
      await Provider.of<BleDeviceManager>(context, listen: false)
          .writeCharacteristicWithoutResponse(
        _discoverServices()
            .singleWhere((element) =>
                GATT.getServiceName(element.serviceId) == 'WDX Service')
            .serviceId,
        _discoverServices()
            .singleWhere((element) =>
                GATT.getServiceName(element.serviceId) == 'WDX Service')
            .characteristicIds
            .singleWhere((element) =>
                GATT.getCharacteristicName(element) ==
                'WDX File Transfer Control Characteristic'),
        widget.device,
        [7, 1, 0],
      );
    } catch (e) {}

    return await _waitResponse(5000);
  }

  Future<void> _sendResetReq() async {
    SimpleLogger().info('Sending Reset Request');
    SimpleLogger().fine('Bytes sent ${[2, 37]}');
    try {
      await Provider.of<BleDeviceManager>(context, listen: false)
          .writeCharacteristicWithResponse(
        _discoverServices()
            .singleWhere((element) =>
                GATT.getServiceName(element.serviceId) == 'WDX Service')
            .serviceId,
        _discoverServices()
            .singleWhere((element) =>
                GATT.getServiceName(element.serviceId) == 'WDX Service')
            .characteristicIds
            .singleWhere((element) =>
                GATT.getCharacteristicName(element) ==
                'WDX Device Configuration Characteristic'),
        widget.device,
        [2, 37],
      );
    } catch (e) {}

    return;
    if (mounted) {
      Provider.of<BleConnectManager>(context, listen: false)
          .disconnect(context, widget.device);
    }
  }

  Future<int> _requestMtuForFileTransfer() async {
    int maxMtu = await Provider.of<BleConnectManager>(context, listen: false)
        .requestMtuSize(device: widget.device, mtu: 247);
    return ((maxMtu - 10) ~/ 20) * 20;
  }

  Future<void> _setConnectionPriority() async {
    return Provider.of<BleConnectManager>(context, listen: false)
        .requestConnectionPriority(widget.device, ConnectionPriority.lowPower);
  }

  Future<bool> _waitResponse(int milliseconds) async {
    int counter = 0;
    while (_busy) {
      await Future.delayed(const Duration(milliseconds: 1));
      if (counter++ > milliseconds) {
        setState(() {
          _busy = false;
        });
        return false;
      }
    }
    return true;
  }

  void _unsubscribeFromChars() {
    _streams.forEach((key, value) {
      SimpleLogger()
          .info('Unsubscribing from ${GATT.getCharacteristicName(key)}');
      value.cancel();
    });
  }

  Future<void> _failed() async {
    if (mounted) {
      return showCPDialog(context,
          builder: (context) => const CPDialog(
                content: CPText('Failed'),
              )).then((value) {
        _unsubscribeFromChars();
        // if (_connectionState == DeviceConnectionState.disconnected) {
        //   Future.delayed(Duration(seconds: 1), () => Navigator.pop(context));
        // }
      });
    }
  }
}
