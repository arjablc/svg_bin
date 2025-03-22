import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

class SvgBin extends StatelessWidget {
  const SvgBin(
    /// The path to the .vec file
    /// Preferably with the help of generated
    /// [AppAsset] class
    this.assetName, {
    /// height of the svg,
    /// takes parent's height if null
    this.height,

    /// width of the svg,
    /// takes parent's width if null
    this.width,

    /// For there is an error while
    /// loading the .vec file
    this.errorColor,

    /// Defaults to [BoxFit.contain] if null
    this.fit,

    /// [ColorFilter] for the svg
    /// Similar to the color filter
    /// you use for the flutter_svg
    /// package
    this.colorFilter,
    super.key,
  });

  final String assetName;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Color? errorColor;
  final ColorFilter? colorFilter;

  @override
  Widget build(BuildContext context) {
    return VectorGraphic(
      height: height,
      width: width,
      colorFilter: colorFilter,
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
