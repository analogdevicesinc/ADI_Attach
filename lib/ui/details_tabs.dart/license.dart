import 'package:flutter/material.dart';

class LicenseView extends StatelessWidget {
  const LicenseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('License'),
      ),
      body: const Center(child: Text('License Page')),
    );
  }
}
