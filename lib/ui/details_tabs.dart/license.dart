import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LicenseView extends StatefulWidget {
  const LicenseView({Key? key}) : super(key: key);

  @override
  State<LicenseView> createState() => _LicenseViewState();
}

class _LicenseViewState extends State<LicenseView> {
  String? data;

  void _loadData() async {
    final _loadedData = await rootBundle.loadString('assets/license.txt');
    setState(() {
      data = _loadedData;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('License'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(data ?? ''),
          ),
        ));
  }
}
