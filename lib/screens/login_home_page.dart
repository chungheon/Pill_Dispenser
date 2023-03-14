import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/main.dart';
import 'package:pill_dispenser/screens/forget_password_page.dart';
import 'package:pill_dispenser/screens/register_page.dart';
import 'package:pill_dispenser/widgets/custom_input_text_box_widget.dart';
import 'package:pill_dispenser/widgets/custom_splash_button.dart';
import 'package:pill_dispenser/widgets/shader_mask_image_icon.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

class LoginHomePage extends StatelessWidget {
  LoginHomePage({Key? key}) : super(key: key);
  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final RxString email = RxString('');
  final RxString password = RxString('');
  final RxBool isLoading = false.obs;

  Future<void> onTapLogin() async {
    if (!isLoading.value) {
      try {
        var userCred = await _userStateController
            .loginWithEmailPassword(email.value, password.value)
            .catchError((error, stackTrace) =>
                throw error?.toString() ?? Exception('Unable to login'));
        Get.offAll(() => UserSuccessPage());
      } catch (error) {
        await showDialog(
            context: Get.context!,
            builder: ((dialogContext) => DefaultErrorDialog(
                title: 'Unable to Login', message: error.toString())));
        isLoading.value = false;
      }
    }
  }

  Future<void> onTapGoogleLogin() async {
    if (!isLoading.value) {
      try {
        var userCred = await _userStateController.loginWithGoogle().catchError(
            (error, stackTrace) =>
                throw error?.toString() ?? Exception('Unable to login'));
        Get.offAll(() => UserSuccessPage());
      } catch (error) {
        await showDialog(
            context: Get.context!,
            builder: ((dialogContext) => DefaultErrorDialog(
                title: 'Unable to Login', message: error.toString())));
        isLoading.value = false;
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
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Get.mediaQuery.size.height / 4),
                const Center(
                  child: Text(
                    'Login',
                    style:
                        TextStyle(fontSize: 25.0, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(
                  height: 60.0,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                    color: Constants.white,
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(color: Constants.black),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => ForgetPasswordPage());
                      },
                      child: const Text(
                        'Forget Password?',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w800),
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
                      title: 'Login',
                      buttonColor: Constants.white,
                      splashColor: Constants.primary,
                      textColor: Constants.black,
                      isLoading: isLoading.value,
                      onTap: onTapLogin,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Not register yet?',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => RegisterPage());
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFFF21234),
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.1,
                              color: const Color(0xFF050505),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or sign-up with',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Color(0xFF050505),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.1,
                              color: const Color(0xFF050505),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Center(
                  child: GestureDetector(
                    onTap: onTapGoogleLogin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      decoration: BoxDecoration(
                          color: Constants.white,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20.0,
                            child: Image.asset(
                              'assets/icons/google_logo.png',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          const Text(
                            'Google',
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
