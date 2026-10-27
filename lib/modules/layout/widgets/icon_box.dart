import 'package:FitGym/core/gen/assets.gen.dart';
import 'package:FitGym/core/theme/app_icon.dart';
import 'package:FitGym/modules/layout/widgets/app_surface.dart';
import 'package:flutter/material.dart';

/// A square icon tile, a button when [onPressed] is set.
class IconBox extends StatelessWidget {
  const IconBox({
    super.key,
    required this.icon,
    required this.background,
    required this.iconColor,
    this.iconSize = 20,
    this.size = 44,
    this.radius = 14,
    this.label,
    this.onPressed,
  });

  final SvgGenImage icon;
  final Color background;
  final Color iconColor;
  final double iconSize;
  final double size;
  final double radius;
  final String? label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      color: background,
      radius: radius,
      onTap: onPressed,
      semanticLabel: label,
      child: SizedBox.square(
        dimension: size,
        child: Center(child: AppIcon(icon, color: iconColor, size: iconSize)),
      ),
    );
  }
}
