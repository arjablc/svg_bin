
import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

class SvgBin extends StatelessWidget {
  const SvgBin(
    this.assetName, {
    required this.height,
    required this.width,
    this.errorColor,
    this.fit,
    super.key,
  });

  final String assetName;
  final double height;
  final double width;
  final BoxFit? fit;
  final Color? errorColor;

  @override
  Widget build(BuildContext context) {
    return VectorGraphic(
      height: height,
      width: width,
      fit: fit ?? BoxFit.scaleDown,
      placeholderBuilder: (context) {
        return SizedBox();
      },
      errorBuilder: (context, object, st) {
        return Container(
          color: errorColor ?? Colors.red,
          child: Text(object.toString()),
        );
      },
      loader: AssetBytesLoader(assetName),
    );
  }
}
