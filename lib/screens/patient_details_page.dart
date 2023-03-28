import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/datetime_helper.dart';
import 'package:pill_dispenser/screens/add_allergies_page.dart';
import 'package:pill_dispenser/screens/guardian_request_page.dart';
import 'package:pill_dispenser/screens/patient_weekly_report_page.dart';
import 'package:pill_dispenser/screens/select_patient_page.dart';
import 'package:pill_dispenser/widgets/custom_input_text_box_widget.dart';
import 'package:pill_dispenser/widgets/loading_dialog.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

import '../widgets/custom_splash_button.dart';

class PatientDetailsPage extends StatefulWidget {
  const PatientDetailsPage({Key? key}) : super(key: key);

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  final UserStateController _userStateController =
      Get.find<UserStateController>();

  final RxBool isEdit = false.obs;

  final RxString name = ''.obs;
  final RxString contact = ''.obs;
  final Rxn<DateTime> birthday = Rxn<DateTime>();

  @override
  void initState() {
    super.initState();
    name.value = _userStateController.displayName.value;
    contact.value = _userStateController.contactDetails.value;
    birthday.value = _userStateController.birthday.value;
  }

  Future<void> updateDetails() async {
    await _userStateController.updateDetails(
        name.value, contact.value, birthday.value);
  }

  Future<bool?> confirmUpdate(BuildContext context) async {
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
                        const Text(
                            "Yes to update, No to cancel update.\nTap outside to resume editing",
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.w700)),
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
        });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listItems = _readOnlyListItems();
    if (isEdit.value) {
      listItems = _writeListItems();
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: StandardScaffold(
          child: Column(
        children: [
          PreferredSize(
            preferredSize: const Size(double.infinity, 60.0),
            child: Obx(() {
              if (isEdit.value) {
                return StandardAppBar(
                  action: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: GestureDetector(
                      onTap: () async {
                        bool? updateResult = await confirmUpdate(context);
                        if (updateResult != null) {
                          if (updateResult) {
                            await updateDetails();
                          } else {
                            name.value = _userStateController.displayName.value;
                          }
                          isEdit.value = false;
                          setState(() {});
                        }
                      },
                      child: const Icon(
                        Icons.check,
                        color: Constants.black,
                        size: 45.0,
                      ),
                    ),
                  ),
                ).appBar();
              }
              return StandardAppBar(
                action: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      isEdit.value = true;
                      setState(() {});
                    },
                    child: const Icon(
                      Icons.edit,
                      color: Constants.black,
                      size: 45.0,
                    ),
                  ),
                ),
              ).appBar();
            }),
          ),
          Expanded(
              child: ListView(
            children: listItems,
          )),
        ],
      )),
    );
  }

  List<Widget> _writeListItems() {
    return [
      const SizedBox(
        height: 10.0,
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        child:
            _buildEditInformationDisplay('Name', name, 'Enter Your New Name'),
      ),
      const SizedBox(
        height: 10.0,
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        child: _buildEditInformationDisplay(
            'Contact Details', contact, 'Enter Your New Contact'),
      ),
      const SizedBox(
        height: 10.0,
      ),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _buildUpdateBirthdayWidget()),
      const SizedBox(
        height: 10.0,
      ),
    ];
  }

  List<Widget> _readOnlyListItems() {
    return [
      const SizedBox(
        height: 10.0,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: _buildInformationDisplay(
          'Name',
          _userStateController.displayName.value,
        ),
      ),
      const SizedBox(
        height: 10.0,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: _buildInformationDisplay(
          'Contact Details',
          _userStateController.contactDetails.value,
        ),
      ),
      const SizedBox(
        height: 10.0,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: _buildInformationDisplay(
          'Birthday',
          _userStateController.birthday.value != null
              ? DateTimeHelper.formatDateTimeStr(
                  _userStateController.birthday.value!)
              : 'No birthday recorded',
        ),
      ),
      const SizedBox(
        height: 10.0,
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        child: CustomSplashButton(
          title: 'Request as Guardian',
          onTap: () {
            Get.to(() => GuardianRequestPage());
          },
        ),
      ),
      const SizedBox(
        height: 10.0,
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        child: CustomSplashButton(
          title: 'Add Allergy',
          onTap: () {
            Get.to(() => AddAllergiesPage());
          },
        ),
      ),
      const SizedBox(
        height: 10.0,
      ),
      Obx(() {
        if (_userStateController.patient.isEmpty) {
          return Container();
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CustomSplashButton(
                title: 'View Patients',
                onTap: () => Get.to(() => const SelectPatientPage()),
              ),
            )
          ],
        );
      }),
      Obx(() {
        if (_userStateController.guardian.isEmpty) {
          return Container();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10.0,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Guardians',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _userStateController.guardian.length,
                itemBuilder: ((context, index) {
                  var data = _userStateController.guardian[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 5.0),
                    child: _buildRelationDisplay(data, () {}),
                  );
                })),
          ],
        );
      }),
      const SizedBox(
        height: 10.0,
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Text(
          'Allergies',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
      const SizedBox(
        height: 10.0,
      ),
      Obx(
        () {
          if (_userStateController.allergies.isEmpty) {
            return Container(
              alignment: Alignment.center,
              child: const Text(
                'No Allergies',
                style: TextStyle(fontSize: 20.0),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _userStateController.allergies.length,
            itemBuilder: ((context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildAllergyInformation(
                  _userStateController.allergies[index],
                ),
              );
            }),
          );
        },
      ),
    ];
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

  Widget _buildRelationDisplay(Map<String, dynamic> data, Function() onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Constants.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
                color: Constants.black.withOpacity(0.2), blurRadius: 10.0),
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
                        data['email'],
                        _userStateController.user.value?.email ?? '',
                        _userStateController.user.value?.uid ?? '',
                        data['users_id']),
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
      ),
    );
  }

  Widget _buildUpdateBirthdayWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Birthday',
          style: TextStyle(fontSize: 18.0),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 18.0),
          decoration: BoxDecoration(
            color: Constants.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                  color: Constants.black.withOpacity(0.2), blurRadius: 10.0)
            ],
          ),
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () async {
              await showDatePickerDialog();
            },
            child: Text(
              birthday.value == null
                  ? 'Select a date from picker'
                  : DateTimeHelper.formatDateTimeStr(birthday.value!),
              style: const TextStyle(fontSize: 17.0),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> showDatePickerDialog() async {
    DateTime now = DateTime.now().subtract(const Duration(days: 365));
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: birthday.value ?? now,
        lastDate: DateTime(now.year, now.day),
        firstDate: DateTime(now.year - 100));
    if (picked != null && picked != birthday.value) {
      birthday.value = picked;
      setState(() {});
      return true;
    }
    return false;
    // return await showDialog(
    //         context: context,
    //         builder: (buildContext) {
    //           return Dialog();
    //         }) ??
    //     false;
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

  Widget _buildAllergyInformation(String information) {
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

  Widget _buildInformationDisplay(
    String title,
    String information,
  ) {
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          decoration: BoxDecoration(
            color: Constants.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                  color: Constants.black.withOpacity(0.2), blurRadius: 10.0)
            ],
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            information,
            style: const TextStyle(fontSize: 17.0),
          ),
        ),
      ],
    );
  }
}
