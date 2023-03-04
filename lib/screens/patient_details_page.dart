import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/widgets/custom_input_text_box_widget.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

import '../widgets/custom_splash_button.dart';

class PatientDetailsPage extends StatefulWidget {
  PatientDetailsPage({Key? key}) : super(key: key);

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  final UserStateController _userStateController =
      Get.find<UserStateController>();

  final RxBool isEdit = false.obs;

  final RxString name = ''.obs;

  @override
  void initState() {
    super.initState();
    name.value = _userStateController.displayName.value;
  }

  Future<void> updateDetails() async {
    await _userStateController.updateDetails(name.value);
  }

  Future<bool> confirmUpdate(BuildContext context) async {
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
                            const Text("Yes to update, No to cancel update",
                                style: TextStyle(
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
    List<Widget> listItems = _readOnlyListItems();
    if (isEdit.value) {
      listItems = _writeListItems();
    }
    return StandardScaffold(
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
                      if (await confirmUpdate(context)) {
                        await updateDetails();
                      } else {
                        name.value = _userStateController.displayName.value;
                      }
                      isEdit.value = false;
                      setState(() {});
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
    ));
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
    ];
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

  Widget _buildInformationDisplay(String title, String information) {
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
