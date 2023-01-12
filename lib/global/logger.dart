import 'package:cross_platform_ui_elements/cross_platform_ui_elements.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogState extends ChangeNotifier {
  String _appLog = '';
  void addLog(String s) {
    _appLog += '\n$s';
    notifyListeners();
  }

  void clearLog() {
    _appLog = '';
    notifyListeners();
  }

  String get appLog => _appLog;
}

class LogTab extends StatefulWidget {
  const LogTab({super.key});

  @override
  State<LogTab> createState() => _LogTabState();
}

class _LogTabState extends State<LogTab> {
  final ScrollController _logScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SelectableRegion(
      selectionControls: materialTextSelectionControls,
      focusNode: FocusNode(),
      child: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 5,
        radius: const Radius.circular(2.5),
        controller: _logScrollController,
        child: SingleChildScrollView(
          controller: _logScrollController,
          child: CPText(Provider.of<LogState>(context).appLog),
        ),
      ),
    );
  }
}
