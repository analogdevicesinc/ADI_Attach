import 'package:adi_attach/ui/details_tabs.dart/about.dart';
import 'package:adi_attach/ui/details_tabs.dart/license.dart';
import 'package:flutter/material.dart';

class DetailsTabPopupMenuButton extends StatelessWidget {
  const DetailsTabPopupMenuButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, [bool mounted = true]) {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          const PopupMenuItem<int>(
            value: 0,
            child: Text("About"),
          ),
          const PopupMenuItem<int>(
            value: 1,
            child: Text("License"),
          ),
          const PopupMenuItem<int>(
            value: 1,
            child: Text("Guide"),
          ),
        ];
      },
      offset: const Offset(0, kToolbarHeight),
      onSelected: (value) async {
        if (value == 0) {
          await Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => const AboutView(),
            ),
          );
        }
        if (value == 1 && mounted) {
          await Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => const LicenseView(),
            ),
          );
        }
      },
    );
  }
}
