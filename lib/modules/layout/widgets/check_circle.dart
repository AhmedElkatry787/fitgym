import 'package:FitGym/core/gen/assets.gen.dart';
import 'package:FitGym/core/theme/app_colors.dart';
import 'package:FitGym/core/theme/app_icon.dart';
import 'package:flutter/material.dart';

/// Filled yellow circle with a check, used for finished days and sets.
class CheckCircle extends StatelessWidget {
  const CheckCircle({super.key, required this.size, required this.iconSize});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: AppIcon(Assets.icons.check, color: AppColors.background, size: iconSize),
    );
  }
}
