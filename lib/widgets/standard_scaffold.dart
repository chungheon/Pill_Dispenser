import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StandardScaffold extends StatefulWidget {
  const StandardScaffold(
      {Key? key, this.state, required this.child, this.drawer, this.appBar})
      : super(key: key);
  final Widget child;
  final Drawer? drawer;
  final GlobalKey<ScaffoldState>? state;
  final AppBar? appBar;

  @override
  State<StandardScaffold> createState() => _StandardScaffoldState();
}

class _StandardScaffoldState extends State<StandardScaffold> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: Get.mediaQuery.copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        key: widget.state,
        backgroundColor: const Color(0xFFF5F5F5),
        drawer: widget.drawer,
        appBar: widget.appBar,
        body: SafeArea(
          bottom: false,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'assets/images/background.png',
                  ),
                  fit: BoxFit.cover),
            ),
            child: SizedBox.expand(child: widget.child),
          ),
        ),
      ),
    );
  }
}
