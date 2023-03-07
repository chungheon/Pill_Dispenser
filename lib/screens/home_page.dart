import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/schedule_controller.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/main.dart';
import 'package:pill_dispenser/models/pill.dart';
import 'package:pill_dispenser/models/schedule.dart';
import 'package:pill_dispenser/screens/login_home_page.dart';
import 'package:pill_dispenser/screens/patient_details_page.dart';
import 'package:pill_dispenser/screens/pill_tracking_details_page.dart';
import 'package:pill_dispenser/screens/pills_information_page.dart';
import 'package:pill_dispenser/screens/schedule_appointment_page.dart';
import 'package:pill_dispenser/screens/scheduler_page.dart';
import 'package:pill_dispenser/screens/view_appointment_page.dart';
import 'package:pill_dispenser/screens/weekly_report_page.dart';
import 'package:pill_dispenser/widgets/custom_splash_button.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final ScheduleController _scheduleController = Get.find<ScheduleController>();
  final RxString progress = "".obs;

  Future<void> syncData() async {
    if (_userStateController.syncProgress < 100) {
      progress.value = "Setting up Local Storage...";
      await _scheduleController.setBox(_userStateController.user.value!.uid);
      _userStateController.syncProgress.value = 10;
      final offlineData = _scheduleController.fetchOfflineData();
      final pendingNotif =
          await _scheduleController.getAllPendingNotifications();

      progress.value = "Fetching Online Data";
      await _scheduleController
          .fetchReportOnlineData(_userStateController.user.value!.uid);
      _userStateController.syncProgress.value = 30;
      progress.value = "Setting Up Notifications";
      await _scheduleController
          .fetchOnlineData(_userStateController.user.value!.uid);
      _userStateController.syncProgress.value = 60;
      await _scheduleController
          .fetchAppointmentsData(_userStateController.user.value!.uid);
      _userStateController.syncProgress.value = 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_userStateController.user.value != null) {
        if (_userStateController.syncProgress.value <= 0) {
          syncData();
        }
        if (_userStateController.syncProgress.value >= 100) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            Get.off(() => const UserHomePage());
          });
          return const Scaffold(
            backgroundColor: Constants.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          backgroundColor: Constants.white,
          body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: SizedBox(
                      width: 60.0,
                      height: 60.0,
                      child: CircularProgressIndicator()),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Center(
                  child: Text(
                    progress.value,
                    style: const TextStyle(
                        fontSize: 22.0, fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
        );
      }
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Get.offAll(() => LoginHomePage());
      });
      return const Scaffold(
        backgroundColor: Constants.white,
        body: Center(
          child: SizedBox(
              width: 60.0, height: 60.0, child: CircularProgressIndicator()),
        ),
      );
    });
  }
}

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key}) : super(key: key);

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage>
    with WidgetsBindingObserver, RouteAware {
  final UserStateController _userStateController =
      Get.find<UserStateController>();

  final ScheduleController _scheduleController = Get.find<ScheduleController>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  AppLifecycleState _lastState = AppLifecycleState.resumed;

  final RxList<int> hours = <int>[].obs;
  final RxList<List<Schedule>> specificTimeSchedule = <List<Schedule>>[].obs;
  final RxMap completed = {}.obs;
  final Rx<DateTime> currTime =
      DateTime.now().subtract(const Duration(minutes: 5)).obs;
  @override
  void initState() {
    routeObserver.subscribe(this, Get.rawRoute as PageRoute);
    super.initState();
    fetchUpcomingNotifications();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  @override
  void didPopNext() {
    fetchUpcomingNotifications();
    super.didPopNext();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _lastState == AppLifecycleState.paused) {
      fetchUpcomingNotifications();
    }
    _lastState = state;
    super.didChangeAppLifecycleState(state);
  }

  int getTimeValue(DateTime dateTime) {
    return dateTime.hour * 100 + dateTime.minute;
  }

  Future<void> fetchUpcomingNotifications() async {
    currTime.value = DateTime.now().subtract(const Duration(minutes: 5));
    Map<dynamic, dynamic> allTrack = _scheduleController.fetchOfflineData();
    List<Schedule> scheduleList =
        _scheduleController.formatToScheduleList(allTrack);
    specificTimeSchedule.clear();
    hours.clear();
    for (var schedule in scheduleList) {
      List<int> timeValues = schedule.scheduledTimes.map<int>(((e) {
        return getTimeValue(e);
      })).toList();
      hours.addAll(timeValues);
    }
    hours.removeWhere(((element) => element < getTimeValue(currTime.value)));
    hours.sort();

    for (int hour in hours) {
      List<Schedule> scheduleAtTime = [];
      for (var schedule in scheduleList) {
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

    completed.value = await _scheduleController
        .getCurrDayData(_userStateController.user.value?.uid ?? "ERROR");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 300))
          .then((time) => setState(() {}));
    });
  }

  Future<bool> updatePill(String pillName, DateTime time, String amt) async {
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
                                        for (var schedule in schedules) {
                                          await _scheduleController
                                              .updatePillStatus(
                                                  schedule.scheduledTimes[0],
                                                  currTime,
                                                  schedule.pill?.pill ?? "",
                                                  _userStateController
                                                          .user.value?.uid ??
                                                      'ERROR');
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

  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
      state: scaffoldKey,
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Constants.primary,
              ),
              child: Column(
                children: [
                  Text(
                    'Hi, ${_userStateController.displayName.value}!',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    height: 55.0,
                    width: 55.0,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        image: DecorationImage(
                            image: AssetImage('assets/images/hero_image.png'),
                            fit: BoxFit.fitHeight)),
                  ),
                  const SizedBox(
                    width: 15.0,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Patient Details'),
              onTap: () {
                Get.back();
                Get.to(() => PatientDetailsPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () async {
                await _scheduleController.logOut();
                _userStateController.logOut();
                Get.offAllNamed('/');
              },
            ),
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: KeyboardAvoider(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              userBar(),
              const SizedBox(
                height: 40.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Column(children: [
                  CustomSplashButton(
                    title: 'Information on Pills',
                    onTap: () {
                      Get.to(() => PillsInformationPage());
                    },
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  CustomSplashButton(
                    title: 'Tracker',
                    onTap: () {
                      Get.to(() => PillTrackingDetailsPage());
                    },
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  CustomSplashButton(
                    title: 'QR Code Scan',
                    onTap: () {
                      Get.toNamed('/scanner');
                    },
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  CustomSplashButton(
                    title: 'Scheduling',
                    onTap: () {
                      Get.to(() => SchedulerPage());
                    },
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: CustomSplashButton(
                          title: 'Schedule Appt',
                          onTap: () {
                            Get.to(() => ScheduleAppointmentPage());
                          },
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                        ),
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        child: CustomSplashButton(
                          title: 'View Appt',
                          onTap: () {
                            Get.to(() => ViewAppointmentPage());
                          },
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  CustomSplashButton(
                    title: 'Weekly Report',
                    onTap: () async {
                      // await _scheduleController.fetchReportOnlineData(
                      //     _userStateController.user.value!.uid);
                      Get.to(() => WeeklyReportPage());
                    },
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Obx(
                    () => ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: specificTimeSchedule.length,
                        itemBuilder: ((context, index) {
                          DateTime scheduledTime = specificTimeSchedule[index]
                              .first
                              .scheduledTimes[0];
                          bool isSkipped = _scheduleController.compareTime(
                                  currTime.value, scheduledTime) >
                              0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (!isSkipped) {
                                    bool result =
                                        await updateAllPillsAtSpecificTime(
                                            specificTimeSchedule[index],
                                            context);
                                    if (result) {
                                      fetchUpcomingNotifications();
                                    }
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 15.0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10.0),
                                  decoration: BoxDecoration(
                                      color: Constants.white,
                                      borderRadius: BorderRadius.circular(20.0),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Constants.black
                                                .withOpacity(0.2),
                                            blurRadius: 10.0,
                                            offset: const Offset(0, 2.0))
                                      ]),
                                  child: Text(
                                    '${scheduledTime.hour.toString().padLeft(2, "0")}:${scheduledTime.minute.toString().padRight(2, "0")}',
                                    style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                                padding: const EdgeInsets.all(10),
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  children: [
                                    for (int schIndex = 0;
                                        schIndex <
                                            specificTimeSchedule[index].length;
                                        schIndex++)
                                      _getTimePillDisplay(index, schIndex,
                                          scheduledTime, isSkipped)
                                  ],
                                ),
                              ),
                            ],
                          );
                        })),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getTimePillDisplay(
      int index, int scheduleIndex, scheduledTime, bool isSkipped) {
    Schedule currSchedule = specificTimeSchedule[index][scheduleIndex];
    List completedList = completed[currSchedule.pill?.pill ?? ''] ?? [];
    bool isCompleted = completedList
        .where((element) =>
            element.keys.first == scheduledTime.millisecondsSinceEpoch)
        .isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(15.0),
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
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
          ),
          Text(
            isCompleted
                ? 'Completed'
                : isSkipped
                    ? 'Skipped'
                    : 'Upcoming',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget userBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          scaffoldKey.currentState?.openDrawer();
        },
        child: const Icon(
          Icons.menu,
          size: 40.0,
          color: Constants.black,
        ),
      ),
    );
  }
}
