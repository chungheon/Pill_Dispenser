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

class AddAllergiesPage extends StatefulWidget {
  AddAllergiesPage({Key? key, this.patientData}) : super(key: key);
  final Map<String, dynamic>? patientData;

  @override
  State<AddAllergiesPage> createState() => _AddAllergiesPageState();
}

class _AddAllergiesPageState extends State<AddAllergiesPage> {
  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final ScheduleController _scheduleController = Get.find<ScheduleController>();

  final RxString allergy = ''.obs;
  final RxBool isLoading = false.obs;

  Future<void> addAllergy() async {
    if (widget.patientData != null) {
      bool result = await LoadingDialog.showLoadingDialog(
          _scheduleController.addPatientAllergy(
              allergy.value,
              widget.patientData!['email'] ?? '',
              widget.patientData!['users_id'] ?? ''),
          context,
          () => ModalRoute.of(context)?.isCurrent != true);
      if (result) {
        widget.patientData!['allergies'][allergy.value] = true;
        _userStateController.updatePatientInfoLocally(widget.patientData ?? {});
        allergy.value = '';
      } else {
        showDialog(
            context: context,
            builder: ((context) {
              return const DefaultErrorDialog(
                title: 'Unable to add allergy',
                message: 'Error adding allergy, please try again later.',
              );
            }));
      }
    } else {
      bool result = await LoadingDialog.showLoadingDialog(
          _userStateController.addAllergy(allergy.value),
          context,
          () => ModalRoute.of(context)?.isCurrent != true);
      if (result) {
        await _userStateController.fetchUserDetailsOnline();
        allergy.value = '';
      } else {
        showDialog(
            context: context,
            builder: ((context) {
              return const DefaultErrorDialog(
                title: 'Unable to add allergy',
                message: 'Error adding allergy, please try again later.',
              );
            }));
      }
    }
  }

  Future<void> deleteAllergy(String allergyName) async {
    if (widget.patientData != null) {
      bool result = await LoadingDialog.showLoadingDialog(
          _scheduleController.removePatientAllergy(
              allergyName,
              widget.patientData!['email'] ?? '',
              widget.patientData!['users_id'] ?? ''),
          context,
          () => ModalRoute.of(context)?.isCurrent != true);
      if (result) {
        (widget.patientData!['allergies'] as Map).remove(allergyName);
        _userStateController.updatePatientInfoLocally(widget.patientData ?? {});
        allergy.value = '';
      } else {
        showDialog(
            context: context,
            builder: ((context) {
              return const DefaultErrorDialog(
                title: 'Unable to add allergy',
                message: 'Error adding allergy, please try again later.',
              );
            }));
      }
    } else {
      bool result = await LoadingDialog.showLoadingDialog(
          _userStateController.removeAllergy(allergy.value),
          context,
          () => ModalRoute.of(context)?.isCurrent != true);
      if (result) {
        await _userStateController.fetchUserDetailsOnline();
        allergy.value = '';
      } else {
        showDialog(
            context: context,
            builder: ((context) {
              return const DefaultErrorDialog(
                title: 'Unable to remove allergy',
                message: 'Error removing allergy, please try again later.',
              );
            }));
      }
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
              widget.patientData == null
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                                  'Patient Name:\n${widget.patientData!['name']}')),
                          Expanded(
                              child: Text(
                                  'Patient Email:\n${widget.patientData!['email']}'))
                        ],
                      ),
                    ),
              const SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildEditInformationDisplay(
                    'Allergy Name', allergy, 'Enter Allegry Name'),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomSplashButton(
                  title: 'Add new allergy',
                  onTap: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (!isLoading.value) {
                      isLoading.value = true;
                      print(allergy.value);
                      await addAllergy();
                      isLoading.value = false;
                      setState(() {});
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: Obx(
                  () {
                    var allergyData = _userStateController.allergies.value;
                    if (widget.patientData != null) {
                      allergyData = List<String>.from(
                          (widget.patientData!['allergies'] ?? {}).keys);
                    }
                    return ListView.builder(
                      itemCount: allergyData.length,
                      itemBuilder: ((context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child: _buildInformationDisplay(
                                      allergyData[index])),
                              GestureDetector(
                                onTap: () async {
                                  if (!isLoading.value) {
                                    isLoading.value = true;
                                    print(allergyData[index]);
                                    await deleteAllergy(allergyData[index]);
                                    isLoading.value = false;
                                    setState(() {});
                                  }
                                },
                                child: Icon(
                                  Icons.delete,
                                  size: 40.0,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildEditInformationDisplay(
      String title, RxString strObs, String hint) {
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
