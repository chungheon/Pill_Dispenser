import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/schedule_controller.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/models/pill.dart';
import 'package:pill_dispenser/models/schedule.dart';
import 'package:pill_dispenser/screens/forget_password_page.dart';
import 'package:pill_dispenser/widgets/custom_input_text_box_widget.dart';
import 'package:pill_dispenser/widgets/custom_splash_button.dart';
import 'package:pill_dispenser/widgets/loading_dialog.dart';
import 'package:pill_dispenser/widgets/number_selector_widget.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';
import 'package:pill_dispenser/widgets/time_spinner_dialog.dart';

class ScheduleInfoPage extends StatelessWidget {
  ScheduleInfoPage({
    Key? key,
    String? medName,
    int? pillsRec,
    int? dosageRec,
    int? typeRec,
    List<DateTime>? timings,
  }) : super(key: key) {
    name.value = medName ?? '';
    pills.value = pillsRec ?? 1;
    dailyDosage.value = dosageRec ?? 1;
    type.value = typeRec ?? 0;
    this.timings.value = timings ?? [];
  }
  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final ScheduleController _scheduleController = Get.find<ScheduleController>();
  final RxString name = RxString('');
  final RxInt pills = RxInt(1);
  final RxInt dailyDosage = RxInt(1);
  final RxInt type = RxInt(0);
  final RxList<DateTime> timings = RxList<DateTime>();
  final RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: StandardScaffold(
          appBar: const StandardAppBar().appBar(),
          child: Column(
            children: [
              const SizedBox(height: 15.0),
              Expanded(
                  child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Name of Medication',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: Constants.white,
                          borderRadius: BorderRadius.circular(15.0)),
                      child: CustomInputTextBox(
                        inputObs: name,
                        title: 'Name',
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Amount and Dosage',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              NumberSelectorWidget(
                                pills,
                                limit: 10,
                                disable: true,
                              ),
                              const SizedBox(height: 5.0),
                              Obx(() => Text('${pills.value} Pills')),
                            ],
                          )),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                              child: Column(
                            children: [
                              NumberSelectorWidget(
                                dailyDosage,
                                limit: 24,
                                disable: true,
                              ),
                              const SizedBox(height: 5.0),
                              Obx(() =>
                                  Text('${dailyDosage.value} times Daily')),
                            ],
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'When to take?',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Obx(
                            () => Container(
                              padding: const EdgeInsets.all(30.0),
                              decoration: BoxDecoration(
                                color: type.value == 0
                                    ? Constants.primary
                                    : Constants.white,
                                borderRadius: BorderRadius.circular(20.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: Constants.black.withOpacity(0.2),
                                      blurRadius: 8.0)
                                ],
                              ),
                              child: Text('After Meal',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    color: type.value == 0
                                        ? Constants.white
                                        : Constants.black,
                                  )),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              type.value = 1;
                            },
                            child: Obx(
                              () => Container(
                                padding: const EdgeInsets.all(30.0),
                                decoration: BoxDecoration(
                                  color: type.value == 0
                                      ? Constants.white
                                      : Constants.primary,
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Constants.black.withOpacity(0.2),
                                        blurRadius: 8.0)
                                  ],
                                ),
                                child: Text('Before Meal',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w600,
                                      color: type.value == 0
                                          ? Constants.black
                                          : Constants.white,
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Notification',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Obx(() {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: timings
                              .asMap()
                              .map<int, Widget>((index, time) {
                                return MapEntry(
                                    index,
                                    Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 15.0),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                      decoration: BoxDecoration(
                                        color: Constants.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Constants.black
                                                  .withOpacity(0.2),
                                              blurRadius: 10.0),
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.notifications_active,
                                            size: 40.0,
                                            color: Constants.black,
                                          ),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${time.hour.toString().padLeft(2, "0")}:${time.minute.toString().padLeft(2, "0")}',
                                              style: const TextStyle(
                                                  fontSize: 25.0,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ));
                              })
                              .values
                              .toList(),
                        ),
                      );
                    }),
                    const SizedBox(height: 30.0),
                  ],
                ),
              )),
            ],
          )),
    );
  }
}
