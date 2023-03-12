import 'package:flutter/material.dart';
import 'package:pill_dispenser/constants.dart';

class CustomSplashButton extends StatelessWidget {
  const CustomSplashButton(
      {Key? key,
      this.title,
      this.onTap,
      this.splashColor,
      this.buttonColor,
      this.isLoading,
      this.padding,
      this.textColor})
      : super(key: key);
  final String? title;
  final Function()? onTap;
  final Color? splashColor;
  final Color? buttonColor;
  final Color? textColor;
  final bool? isLoading;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      clipBehavior: Clip.hardEdge,
      elevation: 4.0,
      color: buttonColor,
      child: InkWell(
        onTap: onTap ?? () {},
        splashColor: splashColor,
        child: Container(
          alignment: Alignment.center,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 10.0),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: (isLoading ?? false)
              ? const SizedBox(
                  height: 22.0, width: 22.0, child: CircularProgressIndicator())
              : Text(
                  title ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w700,
                      color: textColor ?? Constants.black),
                ),
        ),
      ),
    );
  }
}
