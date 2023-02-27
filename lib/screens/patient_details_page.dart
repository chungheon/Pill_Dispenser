import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/schedule_controller.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/main.dart';
import 'package:pill_dispenser/models/schedule.dart';
import 'package:pill_dispenser/screens/login_home_page.dart';
import 'package:pill_dispenser/widgets/custom_input_text_box_widget.dart';
import 'package:pill_dispenser/widgets/custom_splash_button.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

class PatientDetailsPage extends StatelessWidget {
  PatientDetailsPage({Key? key}) : super(key: key);
  final ScheduleController _scheduleController = Get.find<ScheduleController>();
  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final RxString searchTerm = RxString('');
  final RxList<Schedule> scheduleList = <Schedule>[].obs;
  final RxList<Schedule> searchList = <Schedule>[].obs;
  final RxMap completed = {}.obs;
  final RxInt completedIntake = 0.obs;
  final RxInt totalIntake = 0.obs;

  Future<bool> updatePill(
      String pillName, DateTime time, String amt, BuildContext context) async {
    return await showDialog(
            context: context,
            builder: (dialogContext) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                            color: Constants.white,
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                'Have you taken $amt $pillName pills at ${time.hour.toString().padLeft(2, "0")}:${time.minute.toString().padLeft(2, "0")}?',
                                style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: CustomSplashButton(
                                      title: 'Yes',
                                      onTap: () async {
                                        await _scheduleController
                                            .updatePillStatus(
                                                time,
                                                DateTime.now(),
                                                pillName,
                                                _userStateController
                                                        .user.value?.uid ??
                                                    'ERROR');
                                        Get.back(result: true);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20.0,
                                ),
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: CustomSplashButton(
                                    title: 'No',
                                    onTap: () {
                                      Get.back(result: false);
                                    },
                                  ),
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }) ??
        false;
  }

  Widget _buildPillsList(List<Schedule> schedules, DateTime currTime) {
    if (schedules.isEmpty) {
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          decoration: BoxDecoration(
              color: Constants.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                    color: Constants.black.withOpacity(0.2),
                    blurRadius: 10.0,
                    offset: const Offset(0, 2.0))
              ]),
          child: Text(
            "No pills with $searchTerm scheduled",
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    return ListView.builder(
        itemCount: schedules.length,
        itemBuilder: ((context, index) {
          List completedList =
              completed[schedules[index].pill?.pill ?? ''] ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin:
                    const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 10.0),
                decoration: BoxDecoration(
                    color: Constants.white,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                          color: Constants.black.withOpacity(0.2),
                          blurRadius: 10.0,
                          offset: const Offset(0, 2.0))
                    ]),
                child: Text(
                  scheduleList[index].pill?.pill ?? '',
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                height: 100.0,
                margin: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 15.0),
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    clipBehavior: Clip.none,
                    itemCount: schedules[index].scheduledTimes.length,
                    itemBuilder: ((context, timeIndex) {
                      DateTime scheduledTime =
                          schedules[index].scheduledTimes[timeIndex];
                      bool isCompleted = completedList
                          .where((element) =>
                              element.keys.first ==
                              scheduledTime.millisecondsSinceEpoch)
                          .isNotEmpty;
                      bool isSkipped = _scheduleController.compareTime(
                              currTime, scheduledTime) >
                          0;
                      return Container(
                        width: 100.0,
                        margin: const EdgeInsets.only(right: 15.0),
                        decoration: BoxDecoration(
                            color: Constants.white,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Constants.black.withOpacity(0.2),
                                blurRadius: 10.0,
                              )
                            ]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${scheduledTime.hour.toString().padLeft(2, "0")}:${scheduledTime.minute.toString().padRight(2, "0")}',
                              style: const TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              isCompleted
                                  ? 'Completed'
                                  : isSkipped
                                      ? 'Skipped'
                                      : 'Upcoming',
                              style: const TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    })),
              )
            ],
          );
        }));
  }

  Future<void> updateSchedule() async {
    Map<dynamic, dynamic> data = _scheduleController.fetchOfflineData();
    completed.value = await _scheduleController
        .getCurrDayData(_userStateController.user.value?.uid ?? "ERROR");
    completed.forEach((key, value) {
      if (value.runtimeType == List) {
        completedIntake.value += (value as List).length;
      }
    });
    var schedules = _scheduleController.formatToScheduleList(data);
    schedules.forEach(
        ((element) => totalIntake.value += element.scheduledTimes.length));
    scheduleList.clear();
    scheduleList.addAll(schedules);
    scheduleList.refresh();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      updateSchedule();
    });
    DateTime now = DateTime.now().subtract(const Duration(minutes: 5));
    return StandardScaffold(
        appBar: const StandardAppBar().appBar(),
        child: Column(
          children: [
            const SizedBox(height: 15.0),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              decoration: BoxDecoration(
                  color: Constants.white,
                  borderRadius: BorderRadius.circular(15.0)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search,
                    size: 24.0,
                    color: Constants.grey,
                  ),
                  Expanded(
                    child: CustomInputTextBox(
                      inputObs: searchTerm,
                      title: 'Search',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.all(20.0),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  color: Constants.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                        color: Constants.primary.withOpacity(0.6),
                        blurRadius: 8.0)
                  ]),
              child: Obx(
                () => Text(
                  'Your plan for today\n${completedIntake.toString()} of ${totalIntake.toString()} Completed',
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text(
                'Daily Review',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
              ),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: Obx(() {
                  if (searchTerm.isNotEmpty) {
                    searchList.clear();
                    for (Schedule schedule in scheduleList) {
                      if ((schedule.pill?.pill ?? "ERROR")
                          .contains(searchTerm)) {
                        searchList.add(schedule);
                      }
                    }
                    return _buildPillsList(searchList, now);
                  }
                  if (scheduleList.isEmpty) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                            top: 15.0, left: 20.0, right: 20.0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10.0),
                        decoration: BoxDecoration(
                            color: Constants.white,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Constants.black.withOpacity(0.2),
                                  blurRadius: 10.0,
                                  offset: const Offset(0, 2.0))
                            ]),
                        child: const Text(
                          "No pills scheduled",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                      itemCount: scheduleList.length,
                      itemBuilder: ((context, scheduleIndex) {
                        List completedList = completed[
                                scheduleList[scheduleIndex].pill?.pill ?? ''] ??
                            [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                  top: 15.0, left: 20.0, right: 20.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                  color: Constants.white,
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Constants.black.withOpacity(0.2),
                                        blurRadius: 10.0,
                                        offset: const Offset(0, 2.0))
                                  ]),
                              child: Text(
                                scheduleList[scheduleIndex].pill?.pill ?? '',
                                style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              height: 100.0,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 15.0),
                              padding: const EdgeInsets.all(10),
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  clipBehavior: Clip.none,
                                  itemCount: scheduleList[scheduleIndex]
                                      .scheduledTimes
                                      .length,
                                  itemBuilder: ((context, timeIndex) {
                                    DateTime scheduledTime =
                                        scheduleList[scheduleIndex]
                                            .scheduledTimes[timeIndex];
                                    bool isCompleted = completedList
                                        .where((element) =>
                                            element.keys.first ==
                                            scheduledTime
                                                .millisecondsSinceEpoch)
                                        .isNotEmpty;
                                    bool isSkipped = _scheduleController
                                            .compareTime(now, scheduledTime) >
                                        0;
                                    return GestureDetector(
                                      onTap: () async {
                                        if (!isCompleted && !isSkipped) {
                                          bool res = await updatePill(
                                              scheduleList[scheduleIndex]
                                                      .pill
                                                      ?.pill ??
                                                  'ERROR',
                                              scheduledTime,
                                              (scheduleList[scheduleIndex]
                                                          .pill
                                                          ?.amount ??
                                                      1)
                                                  .toString(),
                                              context);
                                          if (res) {
                                            updateSchedule();
                                          }
                                        }
                                      },
                                      child: Container(
                                        width: 100.0,
                                        margin:
                                            const EdgeInsets.only(right: 15.0),
                                        decoration: BoxDecoration(
                                            color: Constants.white,
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Constants.black
                                                    .withOpacity(0.2),
                                                blurRadius: 10.0,
                                              )
                                            ]),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${scheduledTime.hour.toString().padLeft(2, "0")}:${scheduledTime.minute.toString().padRight(2, "0")}',
                                              style: const TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              isCompleted
                                                  ? 'Completed'
                                                  : isSkipped
                                                      ? 'Skipped'
                                                      : 'Upcoming',
                                              style: const TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  })),
                            )
                          ],
                        );
                      }));
                }),
              ),
            ),
          ],
        ));
  }
}
