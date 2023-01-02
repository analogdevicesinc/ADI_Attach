import 'dart:async';
import 'package:adi_attach/ble/ble_scanner.dart';
import 'package:adi_attach/global/gatt.dart';
import 'package:adi_attach/ui/write_characteristic/write_characteristic_screen.dart';
import 'package:cross_platform_ui_elements/cross_platform_ui_elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:adi_attach/ble/ble_device_manager.dart';

class CharacteristicCard extends StatefulWidget {
  const CharacteristicCard(
      {Key? key, required this.characteristic, required this.device})
      : super(key: key);

  final DiscoveredCharacteristic characteristic;
  final DiscoveredDeviceRSSIDataPoints device;

  @override
  State<CharacteristicCard> createState() => _CharacteristicCardState();
}

class _CharacteristicCardState extends State<CharacteristicCard> {
  List<int>? readValue = <int>[];

  StreamSubscription<List<int>>? subscribeStream;
  late String subscribeValueStringOutput;
  late List<int> subscribeValueIntListOutput;
  late bool isSubscribe;

  @override
  void initState() {
    super.initState();

    subscribeValueStringOutput = '';
    subscribeValueIntListOutput = [];
    isSubscribe = false;
  }

  @override
  void dispose() {
    subscribeStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SimpleLogger().finest(
    //     '+++++ render characteristic card: ${widget.characteristic.characteristicId} ++++');
    readValue = context
        .read<BleDeviceManager>()
        .getReadValue(widget.characteristic.characteristicId);

    return InkWell(
      onTap: () {},
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ListTile(
          title: Text(
            GATT.getCharacteristicName(
                    widget.characteristic.characteristicId) ??
                'Custom Characteristic',
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'UUID: ${widget.characteristic.characteristicId}'
                      .toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall),
              Text(
                  'Properties: ${_charactisticsSummary(widget.characteristic)}'),
              if (widget.characteristic.isNotifiable)
                if (isSubscribe)
                  const Text('Notification enabled')
                else
                  const Text('Notification disabled'),
              if (widget.characteristic.isIndicatable)
                if (isSubscribe)
                  const Text('Indication enabled')
                else
                  const Text('Indication disabled'),
              readValue != null
                  ? Text(
                      'Value:\n${readValue?.map((e) => '0x${'${e < 16 ? '0' : ''}${e.toRadixString(16)}'.toUpperCase()}').reduce((value, element) => '$value $element') ?? ''}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontFamily: 'monospace'),
                    )
                  : const SizedBox(),
              readValue != null
                  ? intValueToString(readValue)
                  : const SizedBox(),
              subscribeValueStringOutput.isEmpty
                  ? const SizedBox()
                  : Text('Value: $subscribeValueStringOutput'),
              subscribeValueIntListOutput.isEmpty
                  ? const SizedBox()
                  : intValueToString(subscribeValueIntListOutput),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.characteristic.isReadable
                  ? IconButton(
                      onPressed: readCharacteristicByUuid,
                      icon: const Icon(Icons.download),
                    )
                  : const SizedBox(),
              widget.characteristic.isWritableWithoutResponse
                  ? IconButton(
                      onPressed: () async {
                        await showWriteDialog(
                            context, WriteType.withoutResponse);
                      },
                      icon: const Icon(Icons.upload_rounded),
                    )
                  : const SizedBox(),
              widget.characteristic.isWritableWithResponse
                  ? IconButton(
                      onPressed: () async {
                        await showWriteDialog(context, WriteType.withResponse);
                      },
                      icon: const Icon(Icons.cached_rounded))
                  : const SizedBox(),
              if (widget.characteristic.isIndicatable)
                isSubscribe
                    ? IconButton(
                        onPressed: unSubscribeToCharacteristic,
                        icon: const Icon(Icons.notifications_active_rounded))
                    : IconButton(
                        onPressed: subscribeToCharacteristic,
                        icon: const Icon(Icons.notifications_off_rounded))
              else
                const SizedBox(),
              if (widget.characteristic.isNotifiable)
                isSubscribe
                    ? IconButton(
                        onPressed: unSubscribeToCharacteristic,
                        icon: const Icon(Icons.notifications_active_outlined))
                    : IconButton(
                        onPressed: subscribeToCharacteristic,
                        icon: const Icon(Icons.notifications_off_outlined))
              else
                const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget intValueToString(List<int>? value) {
    if (value == null ||
        value
            .map((e) => e > 127)
            .reduce((value, element) => value || element) ||
        value.map((e) => e < 32).reduce((value, element) => value && element)) {
      return const SizedBox();
    }
    String stringValue = String.fromCharCodes(value);
    return Text('ASCII Value: $stringValue',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.bold));
  }

  String _charactisticsSummary(DiscoveredCharacteristic c) {
    final props = <String>[];
    if (c.isReadable) {
      props.add("read");
    }
    if (c.isWritableWithoutResponse) {
      props.add("write without response");
    }
    if (c.isWritableWithResponse) {
      props.add("write with response");
    }
    if (c.isNotifiable) {
      props.add("notify");
    }
    if (c.isIndicatable) {
      props.add("indicate");
    }
    return props.join(", ");
  }

  void readCharacteristicByUuid() async {
    await context.read<BleDeviceManager>().readCharacteristicByUuid(
          widget.characteristic.serviceId,
          widget.characteristic.characteristicId,
          widget.device,
        );
    if (!mounted) return;
    showCPSnackBar(
        context,
        CPText(
            'Characteristic read: ${widget.characteristic.characteristicId}'));
    setState(() {});
  }

  Future<void> subscribeToCharacteristic() async {
    SimpleLogger().finest('----Subscribe Characteristic------');
    subscribeStream = context
        .read<BleDeviceManager>()
        .subScribeToCharacteristic(
          widget.characteristic.serviceId,
          widget.characteristic.characteristicId,
          widget.device,
        )
        .listen((data) {
      SimpleLogger().fine(
          '************************Subscribe Characteristic: $data ------');
      showCPSnackBar(context, CPText('Subscribed Value: $data'));
      setState(() {
        subscribeValueIntListOutput = data;
        subscribeValueStringOutput = data.toString();
      });
      SimpleLogger().finest(
          '+++++Subscribe Characteristic: $subscribeValueStringOutput +++++');
    });
    showCPSnackBar(
        context,
        CPText(
            'Subscribed Characteristic: ${widget.characteristic.characteristicId}'));
    setState(() {
      isSubscribe = true;
    });
  }

  Future<void> unSubscribeToCharacteristic() async {
    try {
      SimpleLogger().finest(
          '----unSubscribe Characteristic ${widget.characteristic.characteristicId} ------');
      await subscribeStream?.cancel();
      if (!mounted) return;
      showCPSnackBar(
          context,
          CPText(
              'Unsubscribed Characteristic: ${widget.characteristic.characteristicId}'));
      setState(() {
        isSubscribe = false;
      });
    } on Exception catch (e) {
      SimpleLogger().finest(
          "Error unSubscribe Characteristic ${widget.characteristic.characteristicId}: $e");
      showCPSnackBar(
        context,
        CPText(
            'Error Unsubscribed Characteristic: ${widget.characteristic.characteristicId}'),
      );
    }
  }

  Future<String?> showWriteDialog(
      BuildContext context, WriteType writeType) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return WriteCharacteristicScreen(
          characteristic: widget.characteristic,
          device: widget.device,
          writeType: writeType,
        );
      },
    );
  }
}

enum WriteType { withResponse, withoutResponse }
