import 'package:adi_attach/ble/ble_scanner.dart';
import 'package:adi_attach/ui/scan_filter.dart';
import 'package:adi_attach/cross_platform_ui_elements/cross_platform_ui_elements.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';

class RSSIChart extends StatefulWidget {
  const RSSIChart({Key? key}) : super(key: key);

  @override
  State<RSSIChart> createState() => _RSSIChartState();
}

class _RSSIChartState extends State<RSSIChart> {
  @override
  Widget build(BuildContext context) {
    List<DiscoveredDeviceRSSIDataPoints> filteredDevices =
        Provider.of<BleScanner>(context).applyAllFilters();
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: ListView.separated(
              itemBuilder: (context, index) => ListTile(
                    onTap: () => Provider.of<BleScanner>(context, listen: false)
                        .toggleFocus(filteredDevices[index].id!),
                    tileColor: filteredDevices[index].focus
                        ? filteredDevices[index].color.withAlpha(50)
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    minVerticalPadding: 2,
                    visualDensity: VisualDensity.compact,
                    dense: true,
                    horizontalTitleGap: 2,
                    minLeadingWidth: 30,
                    leading: Icon(Icons.bluetooth,
                        color: filteredDevices[index].color),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CPText('${filteredDevices[index].rssi}'),
                        const CPText('dBm'),
                      ],
                    ),
                    title: CPText(
                      filteredDevices[index].name!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: CPText(
                      filteredDevices[index].id!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              separatorBuilder: (context, index) => const Divider(height: 2),
              itemCount: filteredDevices.length),
        ),
        const VerticalDivider(),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScanFilter(),
              Flexible(
                child: RSSIGraphWidget(filteredDevices: filteredDevices),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RSSIGraphWidget extends StatelessWidget {
  const RSSIGraphWidget({
    Key? key,
    required this.filteredDevices,
  }) : super(key: key);

  final List<DiscoveredDeviceRSSIDataPoints> filteredDevices;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: CPText('RSSI [dBm]'),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 4, 4),
            child: _plotRssi(context, filteredDevices),
          ),
        ),
      ],
    );
  }

  Widget _plotRssi(BuildContext context,
      List<DiscoveredDeviceRSSIDataPoints> filteredDevices) {
    late List<LineChartBarData> lines;
    if (filteredDevices.isNotEmpty &&
        filteredDevices
            .map((e) => e.focus)
            .reduce((value, element) => value || element)) {
      // there are focused devices
      lines = filteredDevices
          .where((element) => element.focus)
          .map((e) => e.getLineChartBarData())
          .toList();
    } else {
      lines = filteredDevices.map((e) => e.getLineChartBarData()).toList();
    }
    return OrientationBuilder(
      builder: (context, orientation) {
        SimpleLogger().finest(orientation);
        double verticalInterval = orientation == Orientation.portrait ? 20 : 5;
        double horizontalInterval =
            orientation == Orientation.portrait ? 5 : 20;
        //context.watch<BleScanner>().devices
        return LineChart(
          //swapAnimationCurve: Curves.fastLinearToSlowEaseIn,
          swapAnimationDuration: const Duration(milliseconds: 0),
          LineChartData(
            lineBarsData: lines,
            lineTouchData: LineTouchData(enabled: false),
            maxY: 0,
            minY: -120,
            minX: -20,
            maxX: 0,
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(
                //axisNameWidget: const Text('RSSI [dBm]'),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: horizontalInterval,
                ),
              ),
              bottomTitles: AxisTitles(
                // axisNameSize: widget.xLabelMargin,
                axisNameWidget: const Text('Duration [s]'),
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value.toInt() % verticalInterval != 0 ||
                        value.toInt() != value) {
                      return SideTitleWidget(
                          axisSide: meta.axisSide, child: const Text(''));
                    }
                    return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 8.0,
                        child: Text(value.toStringAsFixed(0)));
                  },
                ),
              ),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              horizontalInterval: horizontalInterval / 2,
              verticalInterval: verticalInterval / 2,
            ),
          ),
        );
      },
    );
  }
}
