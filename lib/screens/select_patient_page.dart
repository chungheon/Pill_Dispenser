import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/datetime_helper.dart';
import 'package:pill_dispenser/models/schedule.dart';
import 'package:pill_dispenser/screens/add_pill_information_page.dart';
import 'package:pill_dispenser/screens/patient_weekly_report_page.dart';
import 'package:pill_dispenser/screens/qr_scan_page.dart';
import 'package:pill_dispenser/screens/rescheduler_page.dart';
import 'package:pill_dispenser/screens/scheduler_page.dart';
import 'package:pill_dispenser/widgets/custom_splash_button.dart';
import 'package:pill_dispenser/widgets/loading_dialog.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

class SelectPatientPage extends StatefulWidget {
  const SelectPatientPage({Key? key}) : super(key: key);

  @override
  State<SelectPatientPage> createState() => _SelectPatientPageState();
}

class _SelectPatientPageState extends State<SelectPatientPage> {
  final UserStateController _userStateController =
      Get.find<UserStateController>();

  final isLoading = false.obs;
  final RxList<bool> showDetails = <bool>[].obs;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      isLoading.value = true;
      setState(() {});
      await _userStateController.fetchAllPatientsData();
      isLoading.value = false;
      setState(() {});
    });
    showDetails.value =
        List<bool>.generate(_userStateController.patient.length, (index) {
      return false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
      appBar: const StandardAppBar().appBar(),
      child: Column(
        children: [
          const SizedBox(
            height: 15.0,
          ),
          isLoading.value
              ? Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: const [
                      SizedBox(
                          height: 40.0,
                          width: 40.0,
                          child: FittedBox(
                            child: CircularProgressIndicator(),
                          )),
                      Text('Fetching Patient Data...'),
                    ],
                  ),
                )
              : Expanded(
                  child: Obx(() {
                    if (_userStateController.patient.isEmpty) {
                      return const Center(child: Text('No Patients'));
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'Patients',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: _userStateController.patient.length,
                              itemBuilder: ((context, index) {
                                index =
                                    index % _userStateController.patient.length;
                                var data = _userStateController.patient[index];

                                bool isPending = !data.containsKey('name');

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: isPending
                                            ? _buildPendingDisplay(data)
                                            : _buildRelationDisplay(data)),
                                    isPending
                                        ? Container()
                                        : _buildPatientOptions(index, data),
                                    Container(
                                      height: 1.0,
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 20.0),
                                      color: Constants.black,
                                    ),
                                  ],
                                );
                              })),
                        ),
                      ],
                    );
                  }),
                ),
        ],
      ),
    );
  }

  Widget _buildPatientOptions(
    int index,
    Map<String, dynamic> data,
  ) {
    var allergies = Map<String, dynamic>.from(data['allergies'] ?? {});
    var userAllergies = allergies.keys.toList();
    userAllergies.removeWhere((element) {
      return allergies[element] != 'true';
    });
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                      color: Constants.white, border: Border.all()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Patients Pills And Allergies',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Material(
                        color: Constants.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () {
                            showDetails[index] = !showDetails[index];
                            showDetails.refresh();
                          },
                          splashColor: Constants.primary,
                          customBorder: const CircleBorder(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            color: Colors.transparent,
                            child: Icon(
                              showDetails[index]
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 25.0,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                      minHeight: 0, maxHeight: !showDetails[index] ? 0 : 300),
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                          decoration: BoxDecoration(
                              color: Constants.white, border: Border.all()),
                          child: const Text(
                            'Allergies',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        _buildAllergies(userAllergies),
                        Container(
                          padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                          decoration: BoxDecoration(
                              color: Constants.white, border: Border.all()),
                          child: const Text(
                            'Pills',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        _buildPills(data),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(
            height: 20.0,
          ),
          CustomSplashButton(
            title: 'Patient Weekly Report',
            onTap: () async {
              Get.to(() =>
                  PatientWeeklyReportPage(_userStateController.patient[index]));
            },
            padding: const EdgeInsets.symmetric(vertical: 15.0),
          ),
          const SizedBox(
            height: 20.0,
          ),
          CustomSplashButton(
            title: 'Add Pill Information',
            onTap: () async {
              Get.to(() => AddPillInformationPage(
                  patientData: _userStateController.patient[index]));
            },
            padding: const EdgeInsets.symmetric(vertical: 15.0),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            children: [
              Expanded(
                child: CustomSplashButton(
                  title: 'Schedule Pill',
                  onTap: () {
                    Get.to(() => SchedulerPage(
                          patientData: _userStateController.patient[index],
                        ));
                  },
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
              ),
              const SizedBox(
                width: 20.0,
              ),
              Expanded(
                child: CustomSplashButton(
                  title: 'Schedule Pill \nQrCode Scan',
                  onTap: () {
                    Get.to(() => QrScanPage(
                          patientData: _userStateController.patient[index],
                        ));
                  },
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllergies(List<String> allergies) {
    if (allergies.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        decoration: BoxDecoration(color: Constants.white, border: Border.all()),
        child: Text('No Allergies', style: TextStyle(fontSize: 18.0)),
      );
    } else {
      return Column(
        children: [
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allergies.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                      color: Constants.white, border: Border.all()),
                  child: Text(allergies[index],
                      style: const TextStyle(fontSize: 18.0)),
                );
              }),
        ],
      );
    }
  }

  Widget _buildPills(Map<String, dynamic> data) {
    var pills = Map<String, dynamic>.from(data['schedule'] ?? {});
    List<String> pillNames = pills.keys.toList();
    if (pills.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        decoration: BoxDecoration(color: Constants.white, border: Border.all()),
        child: Text('No Pills', style: TextStyle(fontSize: 18.0)),
      );
    } else {
      return Column(
        children: [
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pillNames.length,
              itemBuilder: (context, index) {
                String displayText = pillNames[index];
                var pillData =
                    Map<String, dynamic>.from(pills[pillNames[index]]);
                var schedule = Schedule.fromJson(pillData);

                displayText += ' - Amount: ${schedule.pill?.amount ?? 0}';
                displayText += ' - Freq: ${schedule.pill?.frequency ?? 0}';
                displayText +=
                    '\n- Type: ${(schedule.pill?.ingestType?.index ?? 0) == 0 ? "After meal" : "Before meal"}';
                for (var timing in schedule.scheduledTimes) {
                  displayText +=
                      '\n ${DateTimeHelper.formatDateToStrTime(timing)}';
                }
                return Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                      color: Constants.white, border: Border.all()),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(displayText,
                              style: const TextStyle(fontSize: 18.0))),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => ReschedulerPage(
                                schedule,
                                patientData: data,
                              ));
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(Icons.edit),
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ],
      );
    }
  }

  Widget _buildPendingDisplay(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Constants.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(color: Constants.black.withOpacity(0.2), blurRadius: 10.0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email: ${data.keys.first}',
            style: const TextStyle(fontSize: 17.0),
          ),
          const Text(
            'Waiting for user to accept',
            style: TextStyle(fontSize: 17.0),
          )
        ],
      ),
    );
  }

  Widget _buildRelationDisplay(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Constants.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(color: Constants.black.withOpacity(0.2), blurRadius: 10.0),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: ${data["name"]}',
                  style: const TextStyle(fontSize: 17.0),
                ),
                Text(
                  'Email: ${data["email"]}',
                  style: const TextStyle(fontSize: 17.0),
                ),
                Text(
                  'Contact Details: ${data["contact_details"]}',
                  style: const TextStyle(fontSize: 17.0),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              bool result = await LoadingDialog.showLoadingDialog(
                  _userStateController.removeRelationship(
                    _userStateController.user.value?.email ?? '',
                    data['email'],
                    data['users_id'],
                    _userStateController.user.value?.uid ?? '',
                  ),
                  context,
                  () => ModalRoute.of(context)?.isCurrent != true);
              if (result) {
                _userStateController.updateRelationships();
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
