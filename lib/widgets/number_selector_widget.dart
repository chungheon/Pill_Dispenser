import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';

class NumberSelectorWidget extends StatelessWidget {
  NumberSelectorWidget(this.counter,
      {Key? key, this.iconSize, this.limit = 100})
      : super(key: key) {
    _textController.text = counter.value.toString();
  }
  final RxInt counter;
  final double? iconSize;
  final int limit;
  final TextEditingController _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: (() {
            if (counter.value > 1) {
              counter.value--;
              _textController.text = counter.value.toString();
            }
          }),
          child: Container(
            padding: const EdgeInsets.all(3.0),
            decoration: const BoxDecoration(
                color: Constants.primary, shape: BoxShape.circle),
            child: Icon(
              Icons.remove,
              size: iconSize ?? 20.0,
              color: Constants.white,
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            _textController.text = counter.value.toString();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Constants.white,
                  borderRadius: BorderRadius.circular(10.0)),
              child: TextField(
                controller: _textController,
                onEditingComplete: (() {
                  if (int.tryParse(_textController.text) == null) {
                    _textController.text = counter.value.toString();
                  } else {
                    if ((int.tryParse(_textController.text) ?? 0) > limit) {
                      counter.value = limit;
                      _textController.text = counter.value.toString();
                    } else {
                      counter.value = int.tryParse(_textController.text) ?? 0;
                    }
                  }
                  FocusManager.instance.primaryFocus?.unfocus();
                }),
                style: const TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.w600),
              ),
            );
          }),
        ),
        GestureDetector(
          onTap: (() {
            if (counter.value < limit) {
              counter.value++;
              _textController.text = counter.value.toString();
            }
          }),
          child: Container(
            padding: const EdgeInsets.all(3.0),
            decoration: const BoxDecoration(
                color: Constants.primary, shape: BoxShape.circle),
            child: Icon(
              Icons.add,
              size: iconSize ?? 20.0,
              color: Constants.white,
            ),
          ),
        ),
      ],
    );
  }
}
