import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';

class LoadingDialog {
  static Future<dynamic> showLoadingDialog(
      Future future, BuildContext context, bool Function() isCurrent) async {
    showDialog(
        context: context,
        builder: ((dContext) {
          return GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Center(
                child: Container(
                  color: Constants.white,
                  padding: const EdgeInsets.all(15.0),
                  child: const CircularProgressIndicator(),
                ),
              ),
            ),
          );
        }));
    var result = await future.then((value) {
      if (isCurrent()) {
        Get.back();
      }
      return value;
    });

    return result;
  }
}
