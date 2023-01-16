import 'package:adi_attach/ble/ble_scanner.dart';
import 'package:adi_attach/cross_platform_ui_elements/cross_platform_ui_elements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScanFilter extends StatefulWidget {
  const ScanFilter({Key? key}) : super(key: key);

  @override
  State<ScanFilter> createState() => _ScanFilterState();
}

class _ScanFilterState extends State<ScanFilter> {
  TextEditingController filterNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      //margin: const EdgeInsets.all(0),
      //shadowColor: c1A,
      //shape: Border.all(color: c1A, width: 4),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: const CPText('Filter & Sort'),
      children: [
        SizedBox(
          height: 32,
          child: TextField(
            maxLines: 1,
            controller: filterNameController,
            decoration: const InputDecoration(
                hintText: 'Device Name', prefixIcon: Icon(Icons.search)),
            onChanged: (value) {
              context.read<BleScanner>().setSearchNameFilterValue(value);
            },
          ),
        ),
        const Divider(height: 4),
        SizedBox(
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CPText('RSSI:'),
              Expanded(
                child: CupertinoSlider(
                  value: Provider.of<BleScanner>(context)
                      .rssiFilterValue
                      .toDouble(),
                  max: 120,
                  min: 26,
                  divisions: 74,
                  // label: rssiFilterValue.round().toString(),
                  onChanged: (double value) {
                    setState(() =>
                        Provider.of<BleScanner>(context, listen: false)
                            .setrssiFilterValue(value));
                  },
                ),
              ),
              CPText(
                  '-${Provider.of<BleScanner>(context).rssiFilterValue} dBm'),
            ],
          ),
        ),
        const Divider(height: 4),
        SizedBox(
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CPText('Hide Unconnectable'),
              CPCheckBox(
                tristate: false,
                checked: Provider.of<BleScanner>(context).hideUnconnectable,
                onChanged: (value) =>
                    Provider.of<BleScanner>(context, listen: false)
                        .hideUnconnectable = value!,
              ),
              const CPText('Hide Unnamed'),
              CPCheckBox(
                tristate: false,
                checked: Provider.of<BleScanner>(context).hideUnnamed,
                onChanged: (value) =>
                    Provider.of<BleScanner>(context, listen: false)
                        .toggleHideUnnamed(value!),
              )
            ],
          ),
        ),
        const Divider(height: 4),
        SizedBox(
          height: 32,
          child: Row(
            children: [
              const CPText('Sort by: '),
              Flexible(
                child: CPComboBox(
                  isExpanded: true,
                  isDense: true,
                  value: Provider.of<BleScanner>(context).sortFor,
                  items: SortFor.values
                      .map(
                        (e) => CPComboBoxItem(
                          child: CPText(
                            e.name
                                .split(beforeCapitalLetter)
                                .reduce((value, element) => '$value $element')
                                .toUpperCase(),
                          ),
                          value: e,
                        ),
                      )
                      .toList(),
                  onChanged: (SortFor? value) {
                    if (value != null) {
                      Provider.of<BleScanner>(context, listen: false).sortFor =
                          value;
                    }
                  },
                ),
              ),
              IconButton(
                iconSize: 24,
                onPressed: Provider.of<BleScanner>(context, listen: false)
                    .toggleSortMode,
                icon: Icon(Provider.of<BleScanner>(context).sortMode ==
                        SortMode.descending
                    ? Icons.arrow_downward
                    : Icons.arrow_upward),
              ),
            ],
          ),
        )
      ],
    );
  }
}

// Single character look-ahead for capital letter.
final beforeCapitalLetter = RegExp(r"(?=[A-Z])");
