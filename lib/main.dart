import 'package:adi_attach/adi_theme.dart';
import 'package:adi_attach/ble/ble_device_manager.dart';
import 'package:adi_attach/global/gatt.dart';
import 'package:adi_attach/global/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';
import 'ble/ble_connect_device.dart';
import 'ble/ble_scanner.dart';
import 'ui/scan_view.dart';

void main() {
  SimpleLogger().setLevel(
    kDebugMode ? Level.FINER : Level.FINER,
    // Includes  caller info, but this is expensive.
    includeCallerInfo: kDebugMode,
    stackTraceLevel: kDebugMode ? Level.ALL : Level.CONFIG,
    callerInfoFrameLevelOffset: kDebugMode ? 1 : 0,
  );

  WidgetsFlutterBinding.ensureInitialized();

  final ble = FlutterReactiveBle();

  GATT.init();

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider<BleScanner>(
        create: (context) => BleScanner(ble: ble),
      ),
      ChangeNotifierProvider<BleConnectManager>(
        create: (context) => BleConnectManager(ble: ble),
      ),
      ChangeNotifierProvider<BleDeviceManager>(
        create: (context) => BleDeviceManager(ble: ble),
      ),
      ChangeNotifierProvider<LogState>(
        create: (context) => LogState(),
      ),
    ], child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    SimpleLogger().onLogged = (log, info) {
      if (info.level >= Level.INFO) {
        Provider.of<LogState>(context, listen: false).addLog(info.message);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADI Attach',
      theme: adiTheme(context),
      home: const HomeScanPage(),
    );
  }
}
