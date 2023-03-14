import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/screens/forget_password_page.dart';
import 'package:pill_dispenser/widgets/custom_input_text_box_widget.dart';
import 'package:pill_dispenser/widgets/custom_splash_button.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

class GuardianRequestPage extends StatelessWidget {
  GuardianRequestPage({Key? key}) : super(key: key);
  final RxString patientEmail = ''.obs;
  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final RxBool isLoading = false.obs;
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
            _buildEditInformationDisplay(
                'Patient Email', patientEmail, 'Enter Patient\'s Email'),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              child: Obx(
                () => CustomSplashButton(
                  title: 'Request',
                  isLoading: isLoading.value,
                  onTap: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (!isLoading.value) {
                      isLoading.value = true;
                      bool result = await _userStateController
                          .reqGuardian(patientEmail.value.trim().toLowerCase());
                      if (result) {
                        await _userStateController.fetchRelationships();
                        isLoading.value = false;
                        return showDialog(
                            context: context,
                            builder: ((context) => const DefaultDialog(
                                  title: 'Request Succeeded',
                                  message:
                                      'Your request has been sent to patient',
                                )));
                      } else {
                        return showDialog(
                            context: context,
                            builder: ((context) => DefaultDialog(
                                  title: 'Request Failed',
                                  message:
                                      'Unable to request to ${patientEmail.value}',
                                )));
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditInformationDisplay(
      String title, RxString strObs, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20.0,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 18.0),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
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
      ),
    );
  }
}
