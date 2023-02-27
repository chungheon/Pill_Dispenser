import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/main.dart';
import 'package:pill_dispenser/screens/forget_password_page.dart';
import 'package:pill_dispenser/widgets/custom_input_text_box_widget.dart';
import 'package:pill_dispenser/widgets/custom_splash_button.dart';
import 'package:pill_dispenser/widgets/shader_mask_image_icon.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

import '../controllers/user_state_controller.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key}) : super(key: key);
  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final RxString email = RxString('');
  final RxString name = RxString('');
  final RxString password = RxString('');
  final RxString confirmPassword = RxString('');
  final RxBool isLoading = false.obs;
  final RxList<String> errMsg = <String>[].obs;

  bool validateFields() {
    errMsg.clear();
    if (email.isEmpty) {
      errMsg.add('Email cannot be empty');
    }
    if (name.isEmpty) {
      errMsg.add('Name cannot be empty');
    }

    if (password.value.length < 6) {
      errMsg.add('Password has to be atleast 6 characters');
    } else {
      if (password.value != confirmPassword.value) {
        errMsg.add("Please match both password in both fields");
      }
    }

    return errMsg.isEmpty;
  }

  Future<void> onTapRegister(BuildContext context) async {
    if (!isLoading.value && validateFields()) {
      isLoading.value = true;
      try {
        var userCred = await _userStateController
            .registerEmailPassword(email.value, password.value)
            .onError((error, stackTrace) {
          throw error?.toString() ?? Exception('Unable to login');
        });
        bool updateResult = await _userStateController
            .updateDisplayName(name.value, userCred: userCred);
        if (!updateResult) {
          await showDialog(
              context: Get.context!,
              builder: ((dialogContext) => const DefaultErrorDialog(
                  title: 'Unable to update name',
                  message:
                      "Failed to update name, please update the user name again")));
          _userStateController.fetchDefaultName();
        }
        Get.offAll(() => UserSuccessPage(
              registered: true,
            ));
      } catch (error) {
        await showDialog(
            context: Get.context!,
            builder: ((dialogContext) => DefaultErrorDialog(
                title: 'Unable to register', message: error.toString())));
        isLoading.value = false;
      }
    }
    if (errMsg.isNotEmpty) {
      String error = '';
      for (String msg in errMsg) {
        error += "$msg\n";
      }
      await showDialog(
          context: context,
          builder: ((dialogContext) {
            return DefaultErrorDialog(
                title: "Unable to register", message: error);
          }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
        appBar: StandardAppBar(onBack: () {
          if (!isLoading.value) {
            Get.back();
          }
        }).appBar(),
        child: SingleChildScrollView(
          child: KeyboardAvoider(
            child: Column(
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                const Center(
                  child: Text(
                    'Register',
                    style:
                        TextStyle(fontSize: 25.0, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: const Color(0xFF050505),
                    ),
                  ),
                  child: CustomInputTextBox(
                    inputObs: name,
                    title: "Name",
                    type: TextInputType.text,
                    prefix: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: ShaderMaskImageIcon(
                        width: 25.0,
                        imageUrl: 'assets/icons/user.png',
                        gradient: LinearGradient(
                            colors: [Constants.primary, Constants.primary]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: const Color(0xFF050505),
                    ),
                  ),
                  child: CustomInputTextBox(
                    inputObs: email,
                    title: "Email Address",
                    type: TextInputType.emailAddress,
                    prefix: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: ShaderMaskImageIcon(
                        width: 25.0,
                        imageUrl: 'assets/icons/mail.png',
                        gradient: LinearGradient(
                            colors: [Constants.primary, Constants.primary]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: const Color(0xFF050505),
                    ),
                  ),
                  child: CustomInputTextBox(
                    inputObs: password,
                    title: "Password",
                    obscure: true,
                    type: TextInputType.visiblePassword,
                    prefix: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: ShaderMaskImageIcon(
                        width: 25.0,
                        imageUrl: 'assets/icons/password.png',
                        gradient: LinearGradient(
                            colors: [Constants.primary, Constants.primary]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: const Color(0xFF050505),
                    ),
                  ),
                  child: CustomInputTextBox(
                    inputObs: confirmPassword,
                    title: "Confirm Password",
                    obscure: true,
                    type: TextInputType.visiblePassword,
                    prefix: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: ShaderMaskImageIcon(
                        width: 25.0,
                        imageUrl: 'assets/icons/password.png',
                        gradient: LinearGradient(
                            colors: [Constants.primary, Constants.primary]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Obx(
                    () => CustomSplashButton(
                      title: 'Register',
                      buttonColor: Constants.white,
                      splashColor: Constants.primary,
                      textColor: Constants.black,
                      isLoading: isLoading.value,
                      onTap: () => onTapRegister(context),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          ),
        ));
  }
}
