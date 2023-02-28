import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/schedule_controller.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/models/pill.dart';
import 'package:pill_dispenser/models/schedule.dart';
import 'package:pill_dispenser/widgets/custom_input_text_box_widget.dart';
import 'package:pill_dispenser/widgets/custom_splash_button.dart';
import 'package:pill_dispenser/widgets/number_selector_widget.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';
import 'package:pill_dispenser/widgets/time_spinner_dialog.dart';

class SchedulerPage extends StatelessWidget {
  SchedulerPage({
    Key? key,
    String? medName,
    int? pillsRec,
    int? dosageRec,
    int? typeRec,
    int? defaultHour,
  }) : super(key: key) {
    name.value = medName ?? '';
    pills.value = pillsRec ?? 1;
    dailyDosage.value = dosageRec ?? 1;
    type.value = typeRec ?? 0;
    DateTime now = DateTime.now();
    now = now.subtract(Duration(minutes: now.minute, seconds: now.second));
    timings.add(now);
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
  final String emptyNameMsg = 'Please enter a name';
  final String nameExists = 'Pill exists already';

  Pill _createPill() {
    return Pill(
      amount: pills.value,
      frequency: dailyDosage.value,
      ingestType: IngestType.values[type.value],
      pill: name.value,
    );
  }

  Future<void> _schedulePills() async {
    Pill pill = _createPill();
    Schedule schedule = Schedule(
      scheduledTimes: timings,
      pill: pill,
    );
    await _scheduleController.scheduleTimings(schedule);
    await _scheduleController.storeScheduleData(
        schedule, _userStateController.user.value?.uid ?? '');
  }

  bool validateName(String pillName) {
    error.clear();
    if (name.isEmpty) {
      error.add(emptyNameMsg);
    }
    if (!_scheduleController.checkIfExists(pillName)) {
      error.add(nameExists);
    }

    return error.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
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
                  Obx(() {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      validateName(name.value);
                    });
                    return Column(
                      children: [
                        for (int i = 0; i < error.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5.0, left: 20.0, right: 20.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.cancel,
                                  size: 14.0,
                                  color: Constants.error,
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  error.elementAt(i),
                                  style: const TextStyle(
                                      color: Constants.error,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )
                      ],
                    );
                  }),
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
                            Obx(() => Text('${dailyDosage.value} times Daily')),
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
                                    margin: const EdgeInsets.only(bottom: 15.0),
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
                                      borderRadius: BorderRadius.circular(20.0),
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
                                                    builder: ((dialogcontext) =>
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
                                                decoration: const BoxDecoration(
                                                    color: Constants.primary,
                                                    shape: BoxShape.circle),
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
                              isLoading.value = true;
                              await _schedulePills();
                              // _scheduleController
                              //     .getAllPendingNotifications()
                              //     .then((value) {
                              //   if (value.isEmpty) {
                              //     print('No Schedule');
                              //   }
                              //   for (var val in value) {
                              //     print(
                              //         'id:${val.id}, title:${val.title}, body:${val.body}');
                              //   }
                              // });
                              Get.back();
                            }
                          }),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                ],
              ),
            )),
          ],
        ));
  }
}
