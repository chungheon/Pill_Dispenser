import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/controllers/schedule_controller.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/screens/forget_password_page.dart';
import 'package:pill_dispenser/widgets/custom_input_text_box_widget.dart';
import 'package:pill_dispenser/widgets/custom_splash_button.dart';
import 'package:pill_dispenser/widgets/loading_dialog.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

import '../constants.dart';

class AddPillInformationPage extends StatefulWidget {
  const AddPillInformationPage({
    Key? key,
    this.patientData,
  }) : super(key: key);
  final Map<String, dynamic>? patientData;
  @override
  State<AddPillInformationPage> createState() => _AddPillInformationPageState();
}

class _AddPillInformationPageState extends State<AddPillInformationPage> {
  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final ScheduleController _scheduleController = Get.find<ScheduleController>();

  final RxString pillName = ''.obs;
  final RxString pillInformation = ''.obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> patientData = RxMap<String, dynamic>();
  @override
  void initState() {
    patientData.addAll(widget.patientData ?? {});
    _userStateController.setPillData(patientData['pill_info'] ?? {});
    super.initState();
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildEditInformationDisplay(
                      'Pill Name', pillName, 'Enter Pill Name'),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildEditInformationDisplay(
                      'Pill Information', pillInformation, 'Enter Pill Info',
                      maxLines: 5),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomSplashButton(
                    title: 'Add new information',
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (!isLoading.value &&
                          pillName.value.trim().isNotEmpty &&
                          pillInformation.value.trim().isNotEmpty) {
                        isLoading.value = true;
                        bool result = await LoadingDialog.showLoadingDialog(
                            _scheduleController
                                .updatePillsInformationForPatient(
                              pillName.value,
                              pillInformation.value,
                              widget.patientData?['users_id'] ?? '',
                            ),
                            context,
                            () => ModalRoute.of(context)?.isCurrent != true);
                        if (result) {
                          await _userStateController.fetchPatientData(
                              widget.patientData?['users_id'] ?? '',
                              refreshInfo: true);
                          patientData.value = _userStateController
                              .getPatientData(patientData['users_id']);
                          _userStateController
                              .setPillData(patientData['pill_info']);

                          pillName.value = '';
                          pillInformation.value = '';
                        } else {
                          showDialog(
                              context: context,
                              builder: ((context) {
                                return const DefaultErrorDialog(
                                  title: 'Unable to add information',
                                  message:
                                      'Error adding pill information, please try again later.',
                                );
                              }));
                        }
                        isLoading.value = false;
                        setState(() {});
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 15.0),
                  decoration: BoxDecoration(
                      color: Constants.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                            color: Constants.black.withOpacity(0.2),
                            blurRadius: 10.0)
                      ]),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Information on Pills',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w600),
                        ),
                      ),
                      ScrollConfiguration(
                        behavior:
                            const ScrollBehavior().copyWith(overscroll: false),
                        child: Obx(
                          () => ListView.builder(
                            shrinkWrap: true,
                            itemCount: _userStateController.pillsList.length,
                            itemBuilder: (context, index) {
                              String pillKey = _userStateController
                                  .pillsList.value.keys
                                  .elementAt(index)
                                  .toString();
                              return itemWidget(pillKey,
                                  _userStateController.pillsList[pillKey]);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Future<bool> _removePillInformation(String pillName) async {
    bool result = await _userStateController.removePillInformationPatient(
        [pillName], patientData['users_id'] ?? '');
    if (result) {
      await _userStateController.fetchPatientData(patientData['users_id'] ?? '',
          refreshInfo: true);
      patientData.value =
          _userStateController.getPatientData(patientData['users_id']);
      _userStateController.setPillData(patientData['pill_info']);
    }
    return result;
  }

  Widget itemWidget(String pillName, String pillInformation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(
          color: Constants.black,
          width: 2.0,
        )),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pillName,
                style: const TextStyle(
                    fontSize: 21.0, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () {
                  LoadingDialog.showLoadingDialog(
                      _removePillInformation(pillName),
                      context,
                      () => ModalRoute.of(context)?.isCurrent != true);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 21.0),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            pillInformation
                .toString()
                .replaceAll("\\n", '\n')
                .replaceAll('\\', ''),
            style: const TextStyle(
              fontSize: 21.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditInformationDisplay(
      String title, RxString strObs, String hint,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18.0),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Constants.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                  color: Constants.black.withOpacity(0.2), blurRadius: 10.0)
            ],
          ),
          alignment: Alignment.centerLeft,
          child: CustomInputTextBox(
            inputObs: strObs,
            title: hint,
            maxLines: maxLines,
          ),
        ),
      ],
    );
  }

  Widget _buildInformationDisplay(String information) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
      decoration: BoxDecoration(
          color: Constants.white,
          border: Border.all(color: Constants.black, width: 1.0)),
      alignment: Alignment.centerLeft,
      child: Text(
        information,
        style: const TextStyle(fontSize: 17.0),
      ),
    );
  }
}
