import 'package:adi_attach/adi_theme.dart';
import 'package:flutter/material.dart';

class AppStackView extends StatelessWidget {
  const AppStackView(
      {Key? key, required this.child, required this.showProgressIndicator})
      : super(key: key);

  final bool showProgressIndicator;
  final Scaffold child;

  @override
  Widget build(BuildContext context) {
    List<Widget> stack = [child];
    if (showProgressIndicator) {
      stack.add(
        Container(
          color: Colors.black.withAlpha(128),
          child: const Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                backgroundColor: c1A,
                color: c1F,
              ),
            ),
          ),
        ),
      );
    }
    return Stack(
      children: stack,
    );
  }
}
