import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/schedule_controller.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/models/pill.dart';
import 'package:pill_dispenser/models/schedule.dart';
import 'package:pill_dispenser/widgets/custom_input_text_box_widget.dart';
import 'package:pill_dispenser/widgets/custom_splash_button.dart';
import 'package:pill_dispenser/widgets/loading_dialog.dart';
import 'package:pill_dispenser/widgets/number_selector_widget.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';
import 'package:pill_dispenser/widgets/time_spinner_dialog.dart';

import 'forget_password_page.dart';

class ReschedulerPage extends StatelessWidget {
  ReschedulerPage(
    this.currSchedule, {
    Key? key,
    this.patientData,
  }) : super(key: key) {
    name.value = this.currSchedule.pill?.pill ?? '';
    pills.value = this.currSchedule.pill?.amount ?? 1;
    dailyDosage.value = this.currSchedule.pill?.frequency ?? 1;
    type.value = this.currSchedule.pill?.ingestType?.index ?? 0;
    timings.value = this.currSchedule.scheduledTimes;
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
  final RxList<String> error = RxList<String>();
  final Schedule currSchedule;
  final Map<String, dynamic>? patientData;

  Pill _createPill() {
    return Pill(
      amount: pills.value,
      frequency: dailyDosage.value,
      ingestType: IngestType.values[type.value],
      pill: name.value,
    );
  }

  Future<bool> _reschedulePill() async {
    if (patientData != null) {
      bool result = await _scheduleController.schedulePillForPatient(
          name.value,
          pills.value,
          dailyDosage.value,
          type.value,
          timings.map((e) => e.millisecondsSinceEpoch).toList(),
          patientData!['email'] ?? '',
          patientData!['users_id'] ?? '');
      if (result) {
        await _userStateController.fetchPatientData(
            patientData?['users_id'] ?? '',
            refreshSchedule: true);
        _userStateController.patient.refresh();
      }
      return result;
    } else {
      Pill pill = _createPill();
      Schedule schedule = Schedule(
        scheduledTimes: timings,
        pill: pill,
      );
      await _scheduleController.updateSchedule(
        schedule,
        _userStateController.user.value?.uid ?? "ERROR",
      );
      await _scheduleController.storeScheduleData(
          schedule, _userStateController.user.value?.uid ?? '');
      return true;
    }
  }

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Patient: ${patientData?["name"] ?? ""} ${patientData?["email"] ?? ""}',
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.w500),
                ),
              ),
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
                              NumberSelectorWidget(pills, limit: 10),
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
                          GestureDetector(
                            onTap: () {
                              type.value = 0;
                            },
                            child: Obx(
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
                                      child: Row(children: [
                                        const Icon(
                                          Icons.notifications_active,
                                          size: 40.0,
                                          color: Constants.black,
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () async {
                                              DateTime? response =
                                                  await showDialog(
                                                      context: context,
                                                      builder:
                                                          ((dialogcontext) =>
                                                              TimeSpinnerDialog(
                                                                  time)));
                                              if (response != null) {
                                                timings[index] = response;
                                                timings.refresh();
                                              }
                                            },
                                            child: Text(
                                              '${time.hour.toString().padLeft(2, "0")}:${time.minute.toString().padLeft(2, "0")}',
                                              style: const TextStyle(
                                                  fontSize: 25.0,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ),
                                        timings.length <= 1
                                            ? Container()
                                            : GestureDetector(
                                                onTap: () {
                                                  timings.removeAt(index);
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color:
                                                              Constants.primary,
                                                          shape:
                                                              BoxShape.circle),
                                                  child: const Icon(
                                                    Icons.remove,
                                                    size: 50.0,
                                                    color: Constants.white,
                                                  ),
                                                ),
                                              ),
                                        const SizedBox(
                                          width: 20.0,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            timings.add(time);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(3.0),
                                            decoration: const BoxDecoration(
                                                color: Constants.primary,
                                                shape: BoxShape.circle),
                                            child: const Icon(
                                              Icons.add,
                                              size: 50.0,
                                              color: Constants.white,
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ));
                              })
                              .values
                              .toList(),
                        ),
                      );
                    }),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Obx(
                        () => CustomSplashButton(
                            title: 'Schedule',
                            isLoading: isLoading.value,
                            onTap: () async {
                              //SAVE everything
                              if (!isLoading.value && error.isEmpty) {
                                bool result =
                                    await LoadingDialog.showLoadingDialog(
                                        _reschedulePill(), context, () {
                                  return ModalRoute.of(context)?.isCurrent !=
                                      true;
                                });
                                await showDialog(
                                    context: context,
                                    builder: (dContext) {
                                      return DefaultDialog(
                                          title: result ? 'Success' : 'Failed',
                                          message: result
                                              ? 'Successfully updated patient\'s schedule'
                                              : 'Failed to update patient\'s schedule.\n' +
                                                  'Please try again later.');
                                    });
                                if (result) {
                                  Get.back();
                                }
                                isLoading.value = false;
                              }
                            }),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                  ],
                ),
              )),
            ],
          )),
    );
  }
}
