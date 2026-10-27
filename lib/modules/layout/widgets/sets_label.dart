import 'package:FitGym/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// `3 × 10-12`, laid out left to right so RTL doesn't flip it to `10-12 × 3`.
class SetsLabel extends StatelessWidget {
  const SetsLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, textDirection: TextDirection.ltr, style: AppTextStyles.caption);
  }
}
