import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:json_schema2/json_schema2.dart';
import 'package:simple_logger/simple_logger.dart';

class GATT {
  static List<Map<String, dynamic>>? _servicesUuids;
  static List<Map<String, dynamic>>? _characteristicUuids;
  static List<Map<String, dynamic>>? _companyIds;

  static init() async {
    JsonSchema attributeSchema = JsonSchema.createSchema(await rootBundle
        .loadString('bluetooth-numbers-database/v1/attribute_schema.json'));
    SimpleLogger().finest('attribute_schema\n$attributeSchema');
    //SimpleLogger().config('${attribute_schema.description}');
    // Characteristics
    List<dynamic> characteristicUuids = json.decode(await rootBundle
        .loadString('bluetooth-numbers-database/v1/characteristic_uuids.json'));
    SimpleLogger().config('Characteristic JSON is valid: '
        '${attributeSchema.validate(characteristicUuids, parseJson: true)}');
    if (attributeSchema.validate(characteristicUuids, parseJson: true)) {
      SimpleLogger().finest(characteristicUuids[0].runtimeType);
      SimpleLogger().finest(characteristicUuids[0]);
      try {
        _characteristicUuids =
            characteristicUuids.map((e) => e as Map<String, dynamic>).toList();
        SimpleLogger().finest('_characteristic_uuids\n$_characteristicUuids');
        SimpleLogger().config('Characteristic JSON is parsed.');
      } catch (e, s) {
        SimpleLogger().warning(e);
        SimpleLogger().warning(s);
      }
    }

    // Services
    List<dynamic> serviceUuids = json.decode(await rootBundle
        .loadString('bluetooth-numbers-database/v1/service_uuids.json'));
    SimpleLogger().config('Service JSON is valid: '
        '${attributeSchema.validate(serviceUuids, parseJson: true)}');
    if (attributeSchema.validate(serviceUuids, parseJson: true)) {
      SimpleLogger().finest(serviceUuids[0].runtimeType);
      SimpleLogger().finest(serviceUuids[0]);
      try {
        _servicesUuids =
            serviceUuids.map((e) => e as Map<String, dynamic>).toList();
        SimpleLogger().finest('_service_uuids\n$serviceUuids');
        SimpleLogger().config('Service JSON is parsed.');
      } catch (e, s) {
        SimpleLogger().warning(e);
        SimpleLogger().warning(s);
      }
    }

    JsonSchema companySchema = JsonSchema.createSchema(await rootBundle
        .loadString('bluetooth-numbers-database/v1/company_schema.json'));
    SimpleLogger().finest('company_schema\n$attributeSchema');
    //SimpleLogger().config('${attribute_schema.description}');
    // Characteristics
    List<dynamic> companyIds = json.decode(await rootBundle
        .loadString('bluetooth-numbers-database/v1/company_ids.json'));
    SimpleLogger().config('Company IDs JSON is valid: '
        '${companySchema.validate(companyIds, parseJson: true)}');
    if (companySchema.validate(companyIds, parseJson: true)) {
      SimpleLogger().finest(companyIds[0].runtimeType);
      SimpleLogger().finest(companyIds[0]);
      try {
        _companyIds = companyIds.map((e) => e as Map<String, dynamic>).toList();
        SimpleLogger().finest('_company_ids\n$_characteristicUuids');
        SimpleLogger().config('Company IDs JSON is parsed.');
      } catch (e, s) {
        SimpleLogger().warning(e);
        SimpleLogger().warning(s);
      }
    }

    // ADI custom
    // Characteristics
    characteristicUuids = json.decode(
        await rootBundle.loadString('assets/custom_characteristics.json'));
    SimpleLogger().config('Custom Characteristic JSON is valid: '
        '${attributeSchema.validate(characteristicUuids, parseJson: true)}');
    if (attributeSchema.validate(characteristicUuids, parseJson: true)) {
      SimpleLogger().finest(characteristicUuids[0].runtimeType);
      SimpleLogger().finest(characteristicUuids[0]);
      try {
        _characteristicUuids
            ?.addAll(characteristicUuids.map((e) => e as Map<String, dynamic>));
        SimpleLogger().finest('_characteristic_uuids\n$_characteristicUuids');
        SimpleLogger().config('Custom Characteristic JSON is parsed.');
      } catch (e, s) {
        SimpleLogger().warning(e);
        SimpleLogger().warning(s);
      }
    }

    // Services
    serviceUuids =
        json.decode(await rootBundle.loadString('assets/custom_services.json'));
    SimpleLogger().config('Custom Service JSON is valid: '
        '${attributeSchema.validate(serviceUuids, parseJson: true)}');
    if (attributeSchema.validate(serviceUuids, parseJson: true)) {
      SimpleLogger().finest(serviceUuids[0].runtimeType);
      SimpleLogger().finest(serviceUuids[0]);
      try {
        _servicesUuids
            ?.addAll(serviceUuids.map((e) => e as Map<String, dynamic>));
        SimpleLogger().finest('_service_uuids\n$serviceUuids');
        SimpleLogger().config('Custom Service JSON is parsed.');
      } catch (e, s) {
        SimpleLogger().warning(e);
        SimpleLogger().warning(s);
      }
    }
  }

  static String? getServiceName(Uuid uuid) {
    try {
      SimpleLogger().finest(uuid);
      late Iterable<int> uuidOctet;
      if (uuid.data.length == 2) {
        uuidOctet = uuid.data.getRange(0, 2);
      } else if (uuid.data.length >= 4) {
        uuidOctet = uuid.data.getRange(2, 4);
      } else {
        return null;
      }
      String uuidString = uuidOctet
          .map(
              (e) => '${e < 16 ? '0' : ''}${e.toRadixString(16)}'.toUpperCase())
          .reduce((value, element) => value + element);
      SimpleLogger().finest('uuidString: $uuidString');
      SimpleLogger().finest(_servicesUuids?.first['uuid'].runtimeType);
      SimpleLogger().finest(
          _servicesUuids?.where((element) => element['uuid'] == uuidString));
      return _servicesUuids
          ?.where((element) => element['uuid'] == uuidString)
          .first['name'];
    } catch (e, s) {
      SimpleLogger().finest(e);
      SimpleLogger().finest(s);
      return null;
    }
  }

  static String? getCharacteristicName(Uuid uuid) {
    try {
      SimpleLogger().finest(uuid);
      late Iterable<int> uuidOctet;
      if (uuid.data.length == 2) {
        uuidOctet = uuid.data.getRange(0, 2);
      } else if (uuid.data.length >= 4) {
        uuidOctet = uuid.data.getRange(2, 4);
      } else {
        return null;
      }
      SimpleLogger().finest(uuidOctet
          .map((e) => e.toRadixString(16))
          .reduce((value, element) => '$value $element'));
      String uuidString = uuidOctet
          .map(
              (e) => '${e < 16 ? '0' : ''}${e.toRadixString(16)}'.toUpperCase())
          .reduce((value, element) => value + element);
      SimpleLogger().finest('uuidString: $uuidString');
      SimpleLogger().finest(_characteristicUuids?.first['uuid'].runtimeType);
      SimpleLogger().finest(_characteristicUuids
          ?.where((element) => element['uuid'] == uuidString));
      return _characteristicUuids
          ?.where((element) => element['uuid'] == uuidString)
          .first['name'];
    } catch (e, s) {
      SimpleLogger().finest(e);
      SimpleLogger().finest(s);
      return null;
    }
  }

  static String? getCompanyID(Uint8List bytes) {
    SimpleLogger().finest(bytes);
    if (bytes.length < 2) {
      return null;
    }
    try {
      int idCode = bytes[0] + 256 * bytes[1];
      SimpleLogger().finest('Company ID: $idCode');
      SimpleLogger().finest(_companyIds?.first);
      SimpleLogger().finest(_companyIds?.first.runtimeType);
      SimpleLogger().finest(_companyIds?.first['code'].runtimeType);
      SimpleLogger()
          .finest(_companyIds?.where((element) => element['code'] == idCode));
      return _companyIds
          ?.where((element) => element['code'] == idCode)
          .first['name'];
    } catch (e, s) {
      SimpleLogger().finest(e);
      SimpleLogger().finest(s);
      return null;
    }
  }
}
