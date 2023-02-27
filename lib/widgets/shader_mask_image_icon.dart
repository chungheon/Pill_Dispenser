import 'package:flutter/material.dart';

class ShaderMaskImageIcon extends StatelessWidget {
  const ShaderMaskImageIcon(
      {required this.imageUrl,
      this.width,
      this.height,
      required this.gradient,
      Key? key})
      : super(key: key);
  final String imageUrl;
  final double? width;
  final double? height;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ShaderMask(
        shaderCallback: (bounds) {
          return gradient.createShader(bounds);
        },
        blendMode: BlendMode.srcATop,
        child: Image.asset(
          imageUrl,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}