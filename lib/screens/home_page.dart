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
import 'package:pill_dispenser/screens/pills_information_page.dart';
import 'package:pill_dispenser/screens/scheduler_page.dart';
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
      if (offlineData.isEmpty || pendingNotif.isEmpty) {
        progress.value = "Fetching Online Data";

        await _scheduleController
            .fetchOnlineData(_userStateController.user.value!.uid);
      }
      _userStateController.syncProgress.value = 30;
      progress.value = "Setting Up Notifications";
      await Future.delayed(const Duration(milliseconds: 1500));
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

  List<Map<dynamic, dynamic>> data = [];

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

  Future<void> fetchUpcomingNotifications() async {
    data.clear();
    data = await _scheduleController.getUpcomingNotifications(
        _userStateController.user.value?.uid ?? "ERROR");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
      state: scaffoldKey,
      drawer: Drawer(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
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
              title: const Text('Patient Details '),
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
              ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
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
                        title: 'Patient Details',
                        onTap: () {
                          Get.to(() => PatientDetailsPage());
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
                      CustomSplashButton(
                        title: 'Weekly Report',
                        onTap: () {
                          Get.to(() => WeeklyReportPage());
                        },
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        height: 100.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: data.length,
                          itemBuilder: ((context, index) {
                            DateTime scheduleTime =
                                data[index]['time'] ?? DateTime.now();
                            Pill pill =
                                (data[index]['schedule'] as Schedule).pill ??
                                    Pill();
                            bool taken = (data[index]['completed'] ?? false);
                            return Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Material(
                                color: taken ? Constants.primary : Colors.white,
                                clipBehavior: Clip.hardEdge,
                                borderRadius: BorderRadius.circular(15.0),
                                child: InkWell(
                                  onTap: () async {
                                    if (!taken) {
                                      bool result = await updatePill(
                                          pill.pill ?? '',
                                          scheduleTime,
                                          (pill.amount ?? 0).toString());
                                      if (result) {
                                        fetchUpcomingNotifications();
                                      }
                                    }
                                  },
                                  splashColor: Constants.primary,
                                  child: Container(
                                    width: 120.0,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                            '${scheduleTime.hour.toString().padLeft(2, "0")}:${scheduleTime.minute.toString().padLeft(2, "0")}'),
                                        Text('${pill.pill}'),
                                        Text(
                                          'Take ${pill.amount} pills',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
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
