import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/widgets/custom_input_text_box_widget.dart';
import 'package:pill_dispenser/widgets/custom_splash_button.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

class DefaultErrorDialog extends StatelessWidget {
  const DefaultErrorDialog({Key? key, this.title, this.message})
      : super(key: key);
  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  color: Constants.white,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        title ?? '',
                        style: const TextStyle(
                            fontSize: 19.0, fontWeight: FontWeight.w600),
                      )),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    message ?? '',
                    style: const TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DefaultDialog extends StatelessWidget {
  const DefaultDialog({Key? key, this.title, this.message}) : super(key: key);
  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  color: Constants.white,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        title ?? '',
                        style: const TextStyle(
                            fontSize: 19.0, fontWeight: FontWeight.w600),
                      )),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    message ?? '',
                    style: const TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserSuccessPage extends StatelessWidget {
  UserSuccessPage({Key? key, this.registered = false}) : super(key: key);
  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final bool registered;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(
        const Duration(seconds: 1),
      ).then((value) => Get.offAllNamed('/home'));
    });
    return MediaQuery(
      data: Get.mediaQuery.copyWith(textScaleFactor: 1.0),
      child: Scaffold(
          backgroundColor: Constants.white,
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    registered ? 'Registered!' : 'Verified!',
                    style: const TextStyle(
                        fontSize: 40.0, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(
                  height: 70.0,
                ),
                Center(
                  child: Obx(() => Text(
                        'Welcome back ${_userStateController.displayName.value}!',
                        style: const TextStyle(fontSize: 16.0),
                      )),
                ),
              ],
            ),
          )),
    );
  }
}

class ForgetPasswordPage extends StatelessWidget {
  ForgetPasswordPage({Key? key}) : super(key: key);
  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final RxString email = RxString('');
  final RxBool isLoading = false.obs;

  Future<void> onTapRecoverPassword() async {
    if (!isLoading.value) {
      try {
        await _userStateController.sendRecoverPassword(email.value).catchError(
            (error, stackTrace) =>
                throw error?.toString() ?? Exception('Unable to login'));

        isLoading.value = false;
      } catch (error) {
        await showDialog(
            context: Get.context!,
            builder: ((dialogContext) => DefaultErrorDialog(
                title: 'Unable to recover password',
                message: error.toString())));
        isLoading.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
        appBar: const StandardAppBar().appBar(),
        child: Column(
          children: [
            const SizedBox(
              height: 90.0,
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 60.0),
                child: Text(
                  'Forget Password?',
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(
              height: 50.0,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Please enter the registered email to reset your password',
                style: TextStyle(fontSize: 18.0, color: Constants.grey),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              decoration: BoxDecoration(
                color: Constants.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                      color: Constants.black.withOpacity(0.2),
                      offset: const Offset(0, 5),
                      blurRadius: 8.0)
                ],
              ),
              child: CustomInputTextBox(
                inputObs: email,
                title: 'Registered Email',
                type: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(
              height: 40.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CustomSplashButton(
                title: 'Recover Password',
                textColor: Constants.white,
                buttonColor: Constants.primary,
                splashColor: Constants.black,
                onTap: onTapRecoverPassword,
              ),
            ),
          ],
        ));
  }
}
