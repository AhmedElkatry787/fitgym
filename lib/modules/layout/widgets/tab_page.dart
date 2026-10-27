import 'package:FitGym/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Scrollable page body shared by the screens above the bottom bar.
class TabPage extends StatelessWidget {
  const TabPage({super.key, required this.children, this.spacing = 18, this.controller});

  final List<Widget> children;
  final double spacing;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Above the bottom bar the bottom inset is already 0; pages opened over
      // the whole screen still need it.
      body: SafeArea(
        child: SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: spacing,
            children: children,
          ),
        ),
      ),
    );
  }
}
