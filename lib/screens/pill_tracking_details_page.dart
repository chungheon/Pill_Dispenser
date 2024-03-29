import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/schedule_controller.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/models/schedule.dart';
import 'package:pill_dispenser/screens/schedule_info_page.dart';
import 'package:pill_dispenser/widgets/custom_input_text_box_widget.dart';
import 'package:pill_dispenser/widgets/custom_splash_button.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

class PillTrackingDetailsPage extends StatelessWidget {
  PillTrackingDetailsPage({Key? key}) : super(key: key);
  final ScheduleController _scheduleController = Get.find<ScheduleController>();
  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final RxString searchTerm = RxString('');
  final RxList<Schedule> searchList = <Schedule>[].obs;
  final RxMap completed = {}.obs;
  final RxInt completedIntake = 0.obs;
  final RxInt viewType = 0.obs;

  Future<bool> updateAllPillsAtSpecificTime(
      List<Schedule> schedules, BuildContext context) async {
    DateTime scheduledTime = schedules.first.scheduledTimes[0];
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
                            //TEXT: FOR CONFIRMATION OF TAKING ALL PILLS AT THIS TIMING
                            Text(
                                'Have you taken all pills at ${scheduledTime.hour.toString().padLeft(2, "0")}:${scheduledTime.minute.toString().padLeft(2, "0")}?',
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
                                        DateTime currTime = DateTime.now();
                                        var dayData =
                                            _scheduleController.currDayData;
                                        for (var schedule in schedules) {
                                          List completedList = dayData[
                                                  schedule.pill?.pill ?? ''] ??
                                              [];
                                          bool isCompleted =
                                              completedList.where((element) {
                                            var pillTime =
                                                getTimeValue(scheduledTime);
                                            var completeTime = getTimeValue(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        int.tryParse(element
                                                                .keys.first
                                                                .toString()) ??
                                                            0));
                                            return pillTime == completeTime;
                                          }).isNotEmpty;
                                          if (!isCompleted) {
                                            await _scheduleController
                                                .updatePillStatus(
                                                    schedule.scheduledTimes[0],
                                                    currTime,
                                                    schedule.pill?.pill ?? "",
                                                    _userStateController
                                                            .user.value?.uid ??
                                                        'ERROR');
                                          }
                                        }
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
                            //TEXT: FOR CONFIRMATION OF TAKING PILLS
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

  int getTimeValue(DateTime dateTime) {
    return dateTime.hour * 100 + dateTime.minute;
  }

  Widget _buildPillsListSecond(List<Schedule> schedules, DateTime currTime) {
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
    List<List<Schedule>> specificTimeSchedule = [];
    List<int> hours = [];
    for (var schedule in schedules) {
      List<int> timeValues = schedule.scheduledTimes.map<int>(((e) {
        return getTimeValue(e);
      })).toList();
      hours.addAll(timeValues);
    }

    hours = hours.toSet().toList();
    hours.sort();
    for (int hour in hours) {
      List<Schedule> scheduleAtTime = [];
      for (var schedule in schedules) {
        var timingValues =
            schedule.scheduledTimes.map<int>((e) => getTimeValue(e)).toList();
        if (timingValues.contains(hour)) {
          scheduleAtTime.add(Schedule(pill: schedule.pill, scheduledTimes: [
            schedule.scheduledTimes[
                timingValues.indexWhere((element) => element == hour)]
          ]));
        }
      }
      specificTimeSchedule.add(scheduleAtTime);
    }
    var completedCounter = 0;
    return ListView.builder(
        itemCount: specificTimeSchedule.length,
        itemBuilder: ((context, index) {
          DateTime scheduledTime =
              specificTimeSchedule[index].first.scheduledTimes[0];
          bool isSkipped =
              _scheduleController.compareTime(currTime, scheduledTime) > 0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () async {
                  if (!isSkipped &&
                      !isTimeCompleted(specificTimeSchedule[index])) {
                    bool result = await updateAllPillsAtSpecificTime(
                        specificTimeSchedule[index], context);
                  }
                },
                child: Container(
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
                    '${scheduledTime.hour.toString().padLeft(2, "0")}:${scheduledTime.minute.toString().padRight(2, "0")}',
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Container(
                height: 100.0,
                margin: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 15.0),
                padding: const EdgeInsets.all(10),
                child: Obx(() {
                  Map<dynamic, dynamic> dayData =
                      _scheduleController.currDayData.value;

                  return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: specificTimeSchedule[index].length,
                      itemBuilder: ((context, scheduleIndex) {
                        Schedule currSchedule =
                            specificTimeSchedule[index][scheduleIndex];
                        List completedList =
                            dayData[currSchedule.pill?.pill ?? ''] ?? [];
                        bool isCompleted = completedList.where((element) {
                          var pillTime = getTimeValue(scheduledTime);
                          var completeTime = getTimeValue(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.tryParse(element.keys.first.toString()) ??
                                      0));
                          return pillTime == completeTime;
                        }).isNotEmpty;
                        if (isCompleted) {
                          completedCounter++;
                        }
                        return Container(
                          width: 100.0,
                          margin: const EdgeInsets.only(right: 15.0),
                          decoration: BoxDecoration(
                              color: isCompleted
                                  ? Constants.primary.withOpacity(0.5)
                                  : Constants.white,
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
                                currSchedule.pill?.pill ?? "",
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
                        );
                      }));
                }),
              )
            ],
          );
        }));
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
    return Obx(
      () {
        var dayData = _scheduleController.currDayData.value;
        return ListView.builder(
            itemCount: schedules.length,
            itemBuilder: ((context, index) {
              List completedList =
                  dayData[schedules[index].pill?.pill ?? ''] ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () {
                      var schedule = schedules[index];
                      Get.to(() => ScheduleInfoPage(
                            medName: schedule.pill?.pill ?? '',
                            pillsRec: schedule.pill?.amount ?? 1,
                            dosageRec: schedule.pill?.frequency ?? 1,
                            typeRec: schedule.pill?.ingestType?.index ?? 0,
                            timings: schedule.scheduledTimes,
                          ));
                    },
                    child: Container(
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
                        schedules[index].pill?.pill ?? '',
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w600),
                      ),
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
                                  int.tryParse(element.keys.first.toString()) ==
                                  scheduledTime.millisecondsSinceEpoch)
                              .isNotEmpty;
                          bool isSkipped = _scheduleController.compareTime(
                                  currTime, scheduledTime) >
                              0;
                          return GestureDetector(
                            onTap: () async {
                              if (!isSkipped && !isCompleted) {
                                bool result = await updatePill(
                                    schedules[index].pill?.pill ?? 'ERROR',
                                    scheduledTime,
                                    (schedules[index].pill?.amount ?? 1)
                                        .toString(),
                                    context);
                              }
                            },
                            child: Container(
                              width: 100.0,
                              margin: const EdgeInsets.only(right: 15.0),
                              decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Constants.primary.withOpacity(0.5)
                                      : Constants.white,
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
      },
    );
  }

  int getCompletedIntake(Map<dynamic, dynamic> completed) {
    int totalCompleted = 0;
    completed.forEach((key, value) {
      totalCompleted += (value as List).length;
    });
    return totalCompleted;
  }

  int getTotalIntake(Map<dynamic, dynamic> schedules) {
    var schedulesList = _scheduleController.formatToScheduleList(schedules);
    int totalIntake = 0;
    schedulesList
        .forEach(((element) => totalIntake += element.scheduledTimes.length));
    return totalIntake;
  }

  List<Schedule> getScheduleList(Map<dynamic, dynamic> data) {
    var schedules = _scheduleController.formatToScheduleList(data);
    return schedules;
  }

  bool isTimeCompleted(List<Schedule> schedules) {
    var count = 0;
    var dayData = _scheduleController.currDayData;
    DateTime scheduledTime = schedules.first.scheduledTimes[0];
    for (Schedule schedule in schedules) {
      List completedList = dayData[schedule.pill?.pill ?? ''] ?? [];
      bool isCompleted = completedList.where((element) {
        var pillTime = getTimeValue(scheduledTime);
        var completeTime = getTimeValue(DateTime.fromMillisecondsSinceEpoch(
            int.tryParse(element.keys.first.toString()) ?? 0));
        return pillTime == completeTime;
      }).isNotEmpty;
      if (isCompleted) {
        count++;
      }
    }
    return count == schedules.length;
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now().subtract(const Duration(minutes: 5));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      completed.value = _scheduleController.currDayData;
    });
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
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
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
                    'Your plan for today\n${getCompletedIntake(_scheduleController.currDayData).toString()} of ${getTotalIntake(_scheduleController.schedulesData).toString()} Completed',
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daily Review',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w400),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                            onTap: () {
                              viewType.value = 0;
                            },
                            child: Text("TIME")),
                        const SizedBox(width: 10.0),
                        GestureDetector(
                            onTap: () {
                              viewType.value = 1;
                            },
                            child: Text("PILL")),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15.0,
              ),
              Expanded(
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(overscroll: false),
                  child: Obx(() {
                    var scheduleList =
                        getScheduleList(_scheduleController.schedulesData);
                    if (searchTerm.isNotEmpty) {
                      searchList.clear();
                      for (Schedule schedule in scheduleList) {
                        if ((schedule.pill?.pill ?? "ERROR")
                            .contains(searchTerm)) {
                          searchList.add(schedule);
                        }
                      }
                      return viewType.value == 0
                          ? _buildPillsListSecond(searchList, now)
                          : _buildPillsList(searchList, now);
                    }
                    return viewType.value == 0
                        ? _buildPillsListSecond(scheduleList, now)
                        : _buildPillsList(scheduleList, now);
                  }),
                ),
              ),
            ],
          )),
    );
  }
}
