import 'package:FitGym/core/gen/assets.gen.dart';
import 'package:FitGym/core/theme/app_colors.dart';
import 'package:FitGym/core/theme/app_icon.dart';
import 'package:FitGym/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Icon, big number and label, as in the progress screen's stats row.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.icon, required this.value, required this.label});

  final SvgGenImage icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          AppIcon(icon, color: AppColors.primary, size: 22),
          Text(value, style: AppTextStyles.display(24, height: 1)),
          Text(label, style: AppTextStyles.body(12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
