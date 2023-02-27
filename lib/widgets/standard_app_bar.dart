import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';

class StandardAppBar {
  const StandardAppBar({Key? key, this.onBack, this.action});
  final Function()? onBack;
  final Widget? action;

  AppBar appBar() {
    return AppBar(
      toolbarHeight: 60.0,
      backgroundColor: Constants.white,
      actions: [action ?? Container()],
      leading: GestureDetector(
          onTap: onBack ??
              () {
                Get.back();
              },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Icon(
              Icons.arrow_back_ios,
              color: Constants.black,
              size: 40,
            ),
          )),
    );
  }
}
