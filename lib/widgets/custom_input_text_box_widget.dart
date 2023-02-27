import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';

class CustomInputTextBox extends StatelessWidget {
  CustomInputTextBox({
    Key? key,
    required this.inputObs,
    this.title,
    this.obscure,
    this.prefix,
    this.type,
  }) : super(key: key) {
    _controller.text = inputObs.value;
    _controller.addListener(() => inputObs.value = _controller.text);
  }
  final RxString inputObs;
  final String? title;
  final TextEditingController _controller = TextEditingController();
  final bool? obscure;
  final Widget? prefix;
  final TextInputType? type;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: TextField(
        controller: _controller,
        obscureText: obscure ?? false,
        onEditingComplete: () {
          inputObs.value = _controller.text;
          FocusManager.instance.primaryFocus?.unfocus();
        },
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: title ?? '',
          hintStyle: const TextStyle(
            color: Constants.grey,
          ),
          prefixIconConstraints: const BoxConstraints(
            minHeight: 0,
            minWidth: 0,
          ),
          prefixIcon: prefix,
        ),
        keyboardType: type,
        style: const TextStyle(fontSize: 17.0),
      ),
    );
  }
}