import 'package:adi_attach/ble/ble_connect_device.dart';
import 'package:adi_attach/global/logger.dart';
import 'package:adi_attach/ui/app_stack_view.dart';
import 'package:adi_attach/ui/details_tabs.dart/details_tab_popup_menu.dart';
import 'package:adi_attach/ui/rssi_plot.dart';
import 'package:adi_attach/ui/scan_filter.dart';
import 'package:adi_attach/cross_platform_ui_elements/cross_platform_ui_elements.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adi_attach/ble/ble_scanner.dart';
import 'bluetooth_tile.dart';
import 'package:share_plus/share_plus.dart';

class HomeScanPage extends StatefulWidget {
  const HomeScanPage({Key? key}) : super(key: key);

  @override
  State<HomeScanPage> createState() => _HomeScanPageState();
}

class _HomeScanPageState extends State<HomeScanPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        ElevatedButton button = !(context.watch<BleScanner>().isScanning)
            ? ElevatedButton(
                onPressed: () => Provider.of<BleScanner>(context, listen: false)
                    .refreshScan(context),
                child: const Text(
                  'SCAN',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: context.read<BleScanner>().stopScan,
                child: const Text(
                  'STOP SCAN',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
        switch (orientation) {
          case Orientation.portrait:
            return AppStackView(
              showProgressIndicator:
                  Provider.of<BleConnectManager>(context).busy,
              child: Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  leading: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image(
                      image: AssetImage('assets/ADI-AMP-KO-White.png'),
                    ),
                  ),
                  centerTitle: false,
                  titleSpacing: 0,
                  title: const Text('ADI Attach'),
                  actions: const [
                    Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: DetailsTabPopupMenuButton(),
                    ),
                  ],
                ),
                floatingActionButton: _index == 0
                    ? button
                    : FloatingActionButton(
                        key: const Key('share_button'),
                        child: const Icon(Icons.share),
                        onPressed: () => Share.share(
                            Provider.of<LogState>(context, listen: false)
                                .appLog,
                            subject: 'ADI Attach Mobile App Log '
                                '${DateTime.now().toString().replaceAll('T', ' ').split('.').first}'),
                      ),
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: _index,
                  items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.search), label: 'Scan'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.text_snippet), label: 'Log'),
                  ],
                  onTap: (value) => setState(
                    () => _index = value,
                  ),
                ),
                body: SafeArea(
                  child: const [ScanTab(), LogTab()][_index],
                ),
              ),
            );
          case Orientation.landscape:
            return Scaffold(
              body: const SafeArea(
                child: RSSIChart(),
              ),
              floatingActionButton: button,
            );
        }
      },
    );
  }
}

class ScanTab extends StatelessWidget {
  const ScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ScanFilter(),
        const Divider(),
        CPText(
            'Filtered ${Provider.of<BleScanner>(context).filteredDeviceCount}/${Provider.of<BleScanner>(context).totalDevicesDiscovered}'),
        const Divider(),
        Expanded(
          child: _scanedDeviceList(
              context, context.watch<BleScanner>().applyAllFilters()),
        ),
      ],
    );
  }

  Widget _scanedDeviceList(
      BuildContext context, List<DiscoveredDeviceRSSIDataPoints> devices) {
    return RefreshIndicator(
      onRefresh: () {
        return Provider.of<BleScanner>(context, listen: false)
            .refreshScan(context);
      },
      child: devices.isNotEmpty
          ? ListView.builder(
              itemCount: devices.length,
              itemBuilder: (BuildContext context, int index) {
                return BleDevicesTile(device: devices[index]);
              },
            )
          : const SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 100.0),
                child: Image(
                  image: AssetImage(
                      'assets/ADI-Logo-AWP-Tagline-RGB-FullColor.png'),
                ),
              ),
            ),
    );
  }
}
