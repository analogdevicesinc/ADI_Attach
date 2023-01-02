import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutView extends StatefulWidget {
  const AboutView({Key? key}) : super(key: key);

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((value) => setState(
          () => _packageInfo = value,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Center(
        child: Text(_packageInfo == null
            ? ''
            : '${_packageInfo!.version}+${_packageInfo!.buildNumber}'),
      ),
    );
  }
}
