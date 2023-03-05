import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/widgets/custom_splash_button.dart';

class TimeSpinnerDialog extends StatelessWidget {
  TimeSpinnerDialog(
    DateTime dateTime, {
    Key? key,
    this.minutesInterval = 30,
  }) : super(key: key) {
    this.dateTime.value = dateTime;
  }
  final Rx<DateTime> dateTime = Rx<DateTime>(DateTime.now());
  final int minutesInterval;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TimePickerSpinner(
            is24HourMode: true,
            time: dateTime.value,
            minutesInterval: minutesInterval,
            normalTextStyle:
                const TextStyle(fontSize: 30.0, color: Constants.black),
            highlightedTextStyle: const TextStyle(
                fontSize: 30.0,
                color: Constants.primary,
                fontWeight: FontWeight.w600),
            spacing: 50,
            itemHeight: 80,
            isForce2Digits: true,
            onTimeChange: (time) {
              dateTime.value = time;
            },
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Obx(
              () => CustomSplashButton(
                title: 'Confirm ${formatDateToStrTime(dateTime.value)}',
                onTap: () {
                  // print(dateTime.toString());
                  Get.back(result: dateTime.value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatDateToStrTime(DateTime date) {
    String formattedDate = DateFormat('HH:mm').format(date);
    return formattedDate;
  }
}
